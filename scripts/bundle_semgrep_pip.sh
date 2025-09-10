#!/bin/bash
# Script to bundle Semgrep using pip in a virtual environment
# This creates a self-contained Semgrep binary that can be distributed with the app

set -e

echo "🔍 Bundling Semgrep Binary using pip"
echo "===================================="

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

# Create a temporary directory for the virtual environment
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

cd "$TEMP_DIR"

# Create a virtual environment
echo "🐍 Creating Python virtual environment..."
python3 -m venv semgrep_env
source semgrep_env/bin/activate

# Install Semgrep
echo "⬇️  Installing Semgrep..."
pip install --upgrade pip
pip install semgrep

# Find the semgrep binary
SEMGREP_BINARY=$(find semgrep_env -name "semgrep" -type f | head -1)

if [ -z "$SEMGREP_BINARY" ]; then
    echo "❌ Semgrep binary not found in virtual environment"
    exit 1
fi

echo "📦 Found Semgrep binary at: $SEMGREP_BINARY"

# Test the binary
echo "🧪 Testing Semgrep binary..."
if "$SEMGREP_BINARY" --version > /dev/null 2>&1; then
    echo "✅ Semgrep binary is working"
    "$SEMGREP_BINARY" --version
else
    echo "❌ Semgrep binary test failed"
    exit 1
fi

# Get the absolute path to the project root (assuming we're running from the project root)
PROJECT_ROOT="/Users/kylezeller/Desktop/Swift/iOSDevOpsAutomation"
RESOURCES_DIR_ABS="$PROJECT_ROOT/$RESOURCES_DIR"

# Copy the binary to Resources directory
echo "📦 Copying binary to app Resources..."
mkdir -p "$RESOURCES_DIR_ABS"
cp "$SEMGREP_BINARY" "$RESOURCES_DIR_ABS/semgrep_binary"

# Also copy any required Python libraries
echo "📚 Copying required Python libraries..."
PYTHON_LIB_DIR="$RESOURCES_DIR_ABS/python_libs"
mkdir -p "$PYTHON_LIB_DIR"

# Copy the entire site-packages directory
cp -r semgrep_env/lib/python*/site-packages/* "$PYTHON_LIB_DIR/" 2>/dev/null || true

# Create a wrapper script that uses the bundled binary
echo "📝 Creating wrapper script..."
cat > "$RESOURCES_DIR_ABS/semgrep" << 'EOF'
#!/bin/bash
# Semgrep wrapper for iOS DevOps Automation app
# This uses the bundled Semgrep binary

# Get the project directory from the first argument, or use current directory
PROJECT_ROOT="${1:-$(pwd)}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUNDLED_SEMGREP="$SCRIPT_DIR/semgrep_binary"
PYTHON_LIBS="$SCRIPT_DIR/python_libs"

# Check if the bundled binary exists
if [ ! -f "$BUNDLED_SEMGREP" ]; then
    echo "❌ Bundled Semgrep binary not found at: $BUNDLED_SEMGREP"
    echo "Please ensure the app was built correctly with the bundled binary."
    exit 1
fi

# Make sure the binary is executable
chmod +x "$BUNDLED_SEMGREP" 2>/dev/null || true

# Set up Python path for the bundled libraries
export PYTHONPATH="$PYTHON_LIBS:$PYTHONPATH"

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
chmod +x "$RESOURCES_DIR_ABS/semgrep"

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Semgrep binary successfully bundled!"
echo "📁 Binary location: $RESOURCES_DIR/semgrep_binary"
echo "📁 Python libraries: $RESOURCES_DIR/python_libs"
echo "📁 Wrapper script: $RESOURCES_DIR/semgrep"
echo ""
echo "🔧 Next steps:"
echo "1. Build the app to include the bundled binary and libraries"
echo "2. Test the security scan functionality"
echo "3. The app will now use the bundled Semgrep binary instead of system Semgrep"
