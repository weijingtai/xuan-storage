#!/bin/bash
set -e
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BUCKET="gs://xuan-backups/firestore/${TIMESTAMP}"
echo "Exporting Firestore to ${BUCKET}..."
gcloud firestore export "${BUCKET}" --collection-ids=playground_posts,playground_replies,playground_verifications,playground_outcome_feedback,playground_likes,playground_bookmarks,playground_profiles,playground_notifications,playground_conversations,playground_messages,playground_reports,playground_media,playground_idempotency,identity_map,fcm_tokens
echo "Export complete: ${BUCKET}"
