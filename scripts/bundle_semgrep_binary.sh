#!/bin/bash
# Script to bundle a static Semgrep binary for macOS app distribution
# This creates a self-contained Semgrep binary that can be distributed with the app

set -e

echo "🔍 Bundling Semgrep Binary for macOS App Distribution"
echo "====================================================="

# Create the Resources directory if it doesn't exist
RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
echo "📱 Detected architecture: $ARCH"

# Download Semgrep binary for macOS
echo "⬇️  Downloading Semgrep binary..."

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the appropriate Semgrep binary
if [[ "$ARCH" == "arm64" ]]; then
    # Apple Silicon (M1/M2/M3)
    SEMGREP_URL="https://github.com/returntocorp/semgrep/releases/latest/download/semgrep-macos-arm64"
    BINARY_NAME="semgrep-macos-arm64"
else
    # Intel Mac
    SEMGREP_URL="https://github.com/returntocorp/semgrep/releases/latest/download/semgrep-macos-x86_64"
    BINARY_NAME="semgrep-macos-x86_64"
fi

echo "📥 Downloading from: $SEMGREP_URL"
curl -L -o "$BINARY_NAME" "$SEMGREP_URL"

# Make it executable
chmod +x "$BINARY_NAME"

# Test the binary
echo "🧪 Testing Semgrep binary..."
if ./"$BINARY_NAME" --version > /dev/null 2>&1; then
    echo "✅ Semgrep binary is working"
    ./"$BINARY_NAME" --version
else
    echo "❌ Semgrep binary test failed"
    exit 1
fi

# Copy to Resources directory
echo "📦 Copying binary to app Resources..."
cp "$BINARY_NAME" "../../$RESOURCES_DIR/semgrep_binary"

# Create a wrapper script that uses the bundled binary
echo "📝 Creating wrapper script..."
cat > "../../$RESOURCES_DIR/semgrep" << 'EOF'
#!/bin/bash
# Semgrep wrapper for iOS DevOps Automation app
# This uses the bundled Semgrep binary

# Get the project directory from the first argument, or use current directory
PROJECT_ROOT="${1:-$(pwd)}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLED_SEMGREP="$SCRIPT_DIR/semgrep_binary"

# Check if the bundled binary exists
if [ ! -f "$BUNDLED_SEMGREP" ]; then
    echo "❌ Bundled Semgrep binary not found at: $BUNDLED_SEMGREP"
    echo "Please ensure the app was built correctly with the bundled binary."
    exit 1
fi

# Make sure the binary is executable
chmod +x "$BUNDLED_SEMGREP" 2>/dev/null || true

# Build the Semgrep command
SEMGREP_CMD="scan --config p/swift --config p/owasp-top-ten --config p/secrets --json --verbose"

echo "🔍 Running Semgrep Security Scan"
echo "================================"
echo ""
echo "Command: $BUNDLED_SEMGREP $SEMGREP_CMD $PROJECT_ROOT"
echo "Project: $PROJECT_ROOT"
echo "Generated: $(date)"
echo ""
echo "📋 Command Output:"
echo "-----------------"

# Change to the project directory and run semgrep
cd "$PROJECT_ROOT" 2>/dev/null || {
    echo "❌ Cannot access project directory: $PROJECT_ROOT"
    echo "This may be due to app sandbox restrictions."
    echo ""
    echo "📋 Manual Installation Instructions:"
    echo "-----------------------------------"
    echo ""
    echo "To run Semgrep manually on your project:"
    echo "1. Open Terminal"
    echo "2. Navigate to your project: cd \"$PROJECT_ROOT\""
    echo "3. Run: semgrep scan --config p/swift --config p/owasp-top-ten --config p/secrets --json --verbose ."
    echo ""
    echo "Install Semgrep if not available:"
    echo "  brew install semgrep"
    echo ""
    echo "For more information, visit: https://semgrep.dev/docs/getting-started/"
    exit 1
}

# Run the actual semgrep command and capture both stdout and stderr
if "$BUNDLED_SEMGREP" $SEMGREP_CMD . 2>&1; then
    echo ""
    echo "✅ Scan completed successfully"
else
    echo ""
    echo "❌ Scan failed or found issues"
fi

echo ""
echo "=================================================="
echo "End of Semgrep Scan Report"
echo "=================================================="
EOF

# Make the wrapper executable
chmod +x "../../$RESOURCES_DIR/semgrep"

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Semgrep binary successfully bundled!"
echo "📁 Binary location: $RESOURCES_DIR/semgrep_binary"
echo "📁 Wrapper script: $RESOURCES_DIR/semgrep"
echo ""
echo "🔧 Next steps:"
echo "1. Build the app to include the bundled binary"
echo "2. Test the security scan functionality"
echo "3. The app will now use the bundled Semgrep binary instead of system Semgrep"
