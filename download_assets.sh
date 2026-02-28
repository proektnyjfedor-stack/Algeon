#!/bin/bash

# 🎵 Assets Download Script for MathPilot
# Downloads free sound effects and animations

set -e

echo "🎵 Downloading assets for MathPilot..."
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from math_pilot root directory"
    exit 1
fi

# Create directories
mkdir -p assets/sounds
mkdir -p assets/animations

info "Created asset directories"

echo ""
echo "📥 Downloading sounds..."
echo ""

# Note: These are placeholder URLs
# Replace with actual licensed sound files

# Correct sound (успех)
info "Downloading correct.mp3..."
# curl -L "URL_TO_CORRECT_SOUND" -o assets/sounds/correct.mp3
echo "TODO: Add correct.mp3 manually from freesound.org"

# Wrong sound (ошибка)
info "Downloading wrong.mp3..."
# curl -L "URL_TO_WRONG_SOUND" -o assets/sounds/wrong.mp3
echo "TODO: Add wrong.mp3 manually"

# Complete sound (завершение)
info "Downloading complete.mp3..."
# curl -L "URL_TO_COMPLETE_SOUND" -o assets/sounds/complete.mp3
echo "TODO: Add complete.mp3 manually"

# Achievement sound
info "Downloading achievement.mp3..."
# curl -L "URL_TO_ACHIEVEMENT_SOUND" -o assets/sounds/achievement.mp3
echo "TODO: Add achievement.mp3 manually"

# Click sound
info "Downloading click.mp3..."
# curl -L "URL_TO_CLICK_SOUND" -o assets/sounds/click.mp3
echo "TODO: Add click.mp3 manually"

echo ""
echo "🎨 Downloading animations..."
echo ""

# Confetti animation
info "Downloading confetti.json..."
# curl -L "URL_TO_CONFETTI_ANIMATION" -o assets/animations/confetti.json
echo "TODO: Add confetti.json from lottiefiles.com"

# Success animation
info "Downloading success.json..."
# curl -L "URL_TO_SUCCESS_ANIMATION" -o assets/animations/success.json
echo "TODO: Add success.json manually"

# Error animation
info "Downloading error.json..."
# curl -L "URL_TO_ERROR_ANIMATION" -o assets/animations/error.json
echo "TODO: Add error.json manually"

# Loading animation
info "Downloading loading.json..."
# curl -L "URL_TO_LOADING_ANIMATION" -o assets/animations/loading.json
echo "TODO: Add loading.json manually"

echo ""
echo "======================================"
echo "📝 Manual steps required:"
echo ""
echo "1. Visit Freesound.org and download:"
echo "   - Correct sound (success tone)"
echo "   - Wrong sound (error buzz)"
echo "   - Complete sound (level up)"
echo "   - Achievement sound (fanfare)"
echo "   - Click sound (UI feedback)"
echo ""
echo "2. Visit LottieFiles.com and download:"
echo "   - Confetti animation"
echo "   - Success checkmark animation"
echo "   - Error cross animation"
echo "   - Loading spinner animation"
echo ""
echo "3. Place downloaded files in:"
echo "   - assets/sounds/"
echo "   - assets/animations/"
echo ""
echo "4. Check ASSETS_GUIDE.md for direct links"
echo ""
success "Asset directories created!"
echo ""
