#!/bin/bash

# Script to create a working Semgrep binary for App Store distribution
# This creates a standalone Python environment with Semgrep that actually works

set -e

echo "🔍 Creating working Semgrep binary for App Store distribution..."

RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Remove any existing semgrep files
rm -f "$RESOURCES_DIR/semgrep"
rm -rf "$RESOURCES_DIR/semgrep_env"

# Create a virtual environment
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
# Working Semgrep wrapper for iOS DevOps Automation app
# This uses the bundled Python environment with Semgrep

# Get the directory where this script is located
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="\$SCRIPT_DIR/semgrep_env"

# Check if the virtual environment exists
if [ ! -d "\$VENV_DIR" ]; then
    echo "❌ Error: Semgrep environment not found at \$VENV_DIR"
    echo "Please reinstall the app or contact support."
    exit 1
fi

# Activate the virtual environment
source "\$VENV_DIR/bin/activate"

# Run Semgrep with all passed arguments
exec python -m semgrep "\$@"
EOF

# Make the wrapper executable
chmod +x "$WRAPPER_PATH"

echo "✅ Working Semgrep binary created successfully!"
echo "📁 Location: $WRAPPER_PATH"
echo "📁 Environment: $VENV_DIR"

# Test the wrapper
echo "🧪 Testing the wrapper..."
if "$WRAPPER_PATH" --version > /dev/null 2>&1; then
    echo "✅ Wrapper test successful!"
    "$WRAPPER_PATH" --version
else
    echo "❌ Wrapper test failed!"
    exit 1
fi

echo "🎉 Semgrep is now ready for App Store distribution!"
