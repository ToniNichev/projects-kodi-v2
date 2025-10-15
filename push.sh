#!/bin/bash

# Kodi V2 - Push Improvements to GitHub
# This script will push your improvements to origin/main

echo "════════════════════════════════════════════════════════"
echo "  Pushing Kodi V2 Improvements to GitHub"
echo "════════════════════════════════════════════════════════"
echo ""
echo "What will be pushed:"
echo "  • Volume controls"
echo "  • Haptic feedback"
echo "  • Connection testing"
echo "  • Input validation"
echo "  • All documentation"
echo ""
echo "This will REPLACE origin/main with your local version."
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Push cancelled."
    exit 0
fi

echo ""
echo "Pushing to GitHub..."
git push origin main --force-with-lease

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Your improvements are now on GitHub!"
    echo ""
    echo "Verify at: https://github.com/ToniNichev/projects-kodi-v2"
    echo ""
else
    echo ""
    echo "❌ Push failed. You may need to:"
    echo "  1. Enter your GitHub credentials"
    echo "  2. Use a Personal Access Token if you have 2FA"
    echo "  3. Check your network connection"
    echo ""
fi

