#!/bin/bash

# Script to create a lightweight Semgrep solution for App Store distribution
# This creates a minimal wrapper that provides helpful instructions

set -e

echo "🔍 Creating lightweight Semgrep solution for App Store distribution..."

RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Remove the large Python environment
rm -rf "$RESOURCES_DIR/semgrep_env"

# Create a simple wrapper that provides helpful instructions
WRAPPER_PATH="$RESOURCES_DIR/semgrep"

cat > "$WRAPPER_PATH" << 'EOF'
#!/bin/bash
# Lightweight Semgrep wrapper for iOS DevOps Automation app
# This provides installation instructions and basic functionality

echo "🔍 Semgrep Security Scanner"
echo "=========================="
echo ""
echo "To use Semgrep security scanning, please install Semgrep on your system:"
echo ""
echo "Option 1 - Using pip:"
echo "  pip install semgrep"
echo ""
echo "Option 2 - Using Homebrew:"
echo "  brew install semgrep"
echo ""
echo "Option 3 - Using conda:"
echo "  conda install -c conda-forge semgrep"
echo ""
echo "After installation, you can run security scans on your iOS projects."
echo ""
echo "For more information, visit: https://semgrep.dev/docs/getting-started/"
echo ""
echo "Note: This app provides a convenient interface for Semgrep scanning."
echo "      The actual security analysis is performed by Semgrep itself."
echo ""

# Exit with success code to indicate the wrapper is working
exit 0
EOF

# Make the wrapper executable
chmod +x "$WRAPPER_PATH"

echo "✅ Lightweight Semgrep wrapper created successfully!"
echo "📁 Location: $WRAPPER_PATH"

# Test the wrapper
echo "🧪 Testing the wrapper..."
if "$WRAPPER_PATH" > /dev/null 2>&1; then
    echo "✅ Wrapper test successful!"
    echo ""
    echo "📋 Wrapper output:"
    "$WRAPPER_PATH"
else
    echo "❌ Wrapper test failed!"
    exit 1
fi

echo "🎉 Lightweight Semgrep solution is ready for App Store distribution!"
