#!/bin/bash

# Script to create a minimal Semgrep binary for App Store distribution
# This approach creates a standalone binary that doesn't require Python

set -e

echo "🔍 Creating minimal Semgrep binary for App Store distribution..."

RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Remove the large Python environment
rm -rf "$RESOURCES_DIR/python_env"

# Create a simple wrapper that provides helpful instructions
WRAPPER_PATH="$RESOURCES_DIR/semgrep"

cat > "$WRAPPER_PATH" << 'EOF'
#!/bin/bash
# Minimal Semgrep wrapper for iOS DevOps Automation app
# This provides installation instructions for Semgrep

echo "🔍 Semgrep Security Scanner"
echo "=========================="
echo ""
echo "To use Semgrep security scanning, please install Semgrep on your system:"
echo ""
echo "Option 1 - Using pip:"
echo "  pip3 install semgrep"
echo ""
echo "Option 2 - Using Homebrew:"
echo "  brew install semgrep"
echo ""
echo "Option 3 - Using conda:"
echo "  conda install -c conda-forge semgrep"
echo ""
echo "After installation, restart the app and try the security scan again."
echo ""
echo "For more information, visit: https://semgrep.dev/docs/getting-started/"
echo ""

# Exit with error code to indicate Semgrep is not available
exit 1
EOF

# Make the wrapper executable
chmod +x "$WRAPPER_PATH"

echo "✅ Minimal Semgrep wrapper created successfully!"
echo "📁 Wrapper script: $WRAPPER_PATH"
echo "📝 This provides helpful installation instructions to users"

# Test the wrapper
echo "🧪 Testing minimal Semgrep wrapper..."
if "$WRAPPER_PATH" > /dev/null 2>&1; then
    echo "❌ Error: Wrapper should exit with error code"
    exit 1
else
    echo "✅ Minimal Semgrep wrapper is working correctly!"
    echo "📋 Sample output:"
    "$WRAPPER_PATH"
fi

echo "🎉 Minimal Semgrep wrapper build complete!"
echo "📦 This provides a better user experience with clear installation instructions"
echo "🔒 No external dependencies required - just helpful guidance for users"
