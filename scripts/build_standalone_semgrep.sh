#!/bin/bash

# Script to build a standalone Semgrep binary for macOS App Store distribution
# This creates a self-contained Python environment with Semgrep

set -e

echo "🔍 Building standalone Semgrep for App Store distribution..."

RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Create a virtual environment specifically for this app
VENV_DIR="$RESOURCES_DIR/semgrep_env"
echo "📦 Creating virtual environment at: $VENV_DIR"

# Use the system Python to create a virtual environment
python3 -m venv "$VENV_DIR"

# Activate the virtual environment and install Semgrep
echo "📥 Installing Semgrep in virtual environment..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install semgrep

# Create a wrapper script that uses the bundled Python environment
WRAPPER_PATH="$RESOURCES_DIR/semgrep"

cat > "$WRAPPER_PATH" << EOF
#!/bin/bash
# Standalone Semgrep wrapper for iOS DevOps Automation app
# This script uses the bundled Python environment

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="\$SCRIPT_DIR/semgrep_env/bin/python"
SEMGREP_MODULE="\$SCRIPT_DIR/semgrep_env/bin/semgrep"

# Check if the bundled Python environment exists
if [ ! -f "\$PYTHON_BIN" ]; then
    echo "❌ Error: Bundled Python environment not found at: \$PYTHON_BIN" >&2
    echo "Please reinstall the app or contact support." >&2
    exit 1
fi

# Check if Semgrep is installed in the bundled environment
if [ ! -f "\$SEMGREP_MODULE" ]; then
    echo "❌ Error: Bundled Semgrep not found at: \$SEMGREP_MODULE" >&2
    echo "Please reinstall the app or contact support." >&2
    exit 1
fi

# Run Semgrep using the bundled environment
exec "\$SEMGREP_MODULE" "\$@"
EOF

# Make the wrapper executable
chmod +x "$WRAPPER_PATH"

echo "✅ Standalone Semgrep created successfully!"
echo "📁 Virtual environment: $VENV_DIR"
echo "🔧 Wrapper script: $WRAPPER_PATH"

# Test the wrapper
echo "🧪 Testing standalone Semgrep..."
if "$WRAPPER_PATH" --version > /dev/null 2>&1; then
    echo "✅ Standalone Semgrep is working correctly!"
    "$WRAPPER_PATH" --version
else
    echo "❌ Error: Standalone Semgrep test failed"
    exit 1
fi

echo "🎉 Standalone Semgrep build complete!"
echo "📦 This can now be distributed with your app to the App Store"
