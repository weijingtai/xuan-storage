import { onObjectFinalized } from 'firebase-functions/v2/storage';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db, COLLECTIONS } from './index';
import * as admin from 'firebase-admin';

export const onMediaUploaded = onObjectFinalized(
  { region: 'asia-east1' },
  async (event) => {
    const filePath = event.data.name;
    if (!filePath) return;

    const match = filePath.match(/^playground_media\/([^/]+)\/([^/]+)\//);
    if (!match) return;

    const [, userId, uploadSessionId] = match;

    const mediaSnap = await db
      .collection(COLLECTIONS.media)
      .where('upload_session_id', '==', uploadSessionId)
      .where('owner_user_id', '==', userId)
      .get();

    if (mediaSnap.empty) return;

    const mediaDoc = mediaSnap.docs[0];
    const metadata = event.data.metadata || {};

    await mediaDoc.ref.update({
      status: 'ready',
      bucket_path: filePath,
      file_size: event.data.size,
      content_type: event.data.contentType,
      finalized_at: admin.firestore.FieldValue.serverTimestamp(),
    } as any);
  },
);

export const cleanupOrphanMedia = onSchedule(
  { schedule: 'every 60 minutes', region: 'asia-east1' },
  async () => {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const pendingSnap = await db
      .collection(COLLECTIONS.media)
      .where('status', '==', 'pending')
      .where('created_at', '<', cutoff)
      .get();

    const batch = db.batch();
    pendingSnap.docs.forEach((doc) => {
      batch.update(doc.ref, { status: 'orphan' } as any);
    });
    await batch.commit();

    for (const doc of pendingSnap.docs) {
      const bucketPath = doc.get('bucket_path') as string | undefined;
      if (bucketPath) {
        try {
          const bucket = admin.storage().bucket();
          await bucket.file(bucketPath).delete();
        } catch (err) {
          console.error(`Failed to delete orphan media file: ${bucketPath}`, err);
        }
      }
    }

    console.log(`Orphan media cleanup: marked ${pendingSnap.size} as orphan`);
  },
);
