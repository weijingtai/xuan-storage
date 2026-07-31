#!/bin/bash
set -e
BUCKET=$1
echo "Importing Firestore from ${BUCKET}..."
gcloud firestore import "${BUCKET}"
echo "Import complete."
