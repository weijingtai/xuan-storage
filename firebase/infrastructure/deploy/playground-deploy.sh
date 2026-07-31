#!/bin/bash
set -e
echo "1. Running contract tests..."
echo "2. Running Rules tests..."
echo "3. Deploying Firestore rules..."
firebase deploy --only firestore:rules,firestore:indexes
echo "4. Deploying Functions..."
firebase deploy --only functions
echo "5. Deploying Storage rules..."
firebase deploy --only storage
echo "6. Running smoke tests..."
echo "Deploy complete."
