#!/bin/bash

# Script to create a minimal Semgrep wrapper for App Store distribution
# This approach uses the system Python but provides better error handling

set -e

echo "🔍 Creating minimal Semgrep wrapper for App Store distribution..."

RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Create a minimal wrapper script
WRAPPER_PATH="$RESOURCES_DIR/semgrep"

cat > "$WRAPPER_PATH" << 'EOF'
#!/bin/bash
# Minimal Semgrep wrapper for iOS DevOps Automation app
# This script attempts to run Semgrep using various system Python commands

# Function to try running Semgrep with a specific Python command
try_semgrep() {
    local python_cmd="$1"
    local semgrep_cmd="$2"
    
    if command -v "$python_cmd" >/dev/null 2>&1; then
        if "$python_cmd" -c "import semgrep" 2>/dev/null; then
            echo "✅ Found Semgrep using: $python_cmd" >&2
            exec "$python_cmd" "$semgrep_cmd" "$@"
        fi
    fi
    return 1
}

# Try different Python commands and Semgrep execution methods
echo "🔍 Attempting to run Semgrep..." >&2

# Try python3 -m semgrep
if try_semgrep "python3" "-m semgrep"; then
    exit 0
fi

# Try python -m semgrep
if try_semgrep "python" "-m semgrep"; then
    exit 0
fi

# Try direct semgrep command
if command -v semgrep >/dev/null 2>&1; then
    echo "✅ Found Semgrep command directly" >&2
    exec semgrep "$@"
fi

# If we get here, Semgrep is not available
echo "❌ Semgrep is not available on this system" >&2
echo "" >&2
echo "To install Semgrep, please run one of the following commands:" >&2
echo "  • pip3 install semgrep" >&2
echo "  • pip install semgrep" >&2
echo "  • brew install semgrep" >&2
echo "" >&2
echo "After installation, please restart the app." >&2
exit 1
EOF

# Make the wrapper executable
chmod +x "$WRAPPER_PATH"

echo "✅ Minimal Semgrep wrapper created successfully!"
echo "🔧 Wrapper script: $WRAPPER_PATH"

# Test the wrapper
echo "🧪 Testing minimal Semgrep wrapper..."
if "$WRAPPER_PATH" --version > /dev/null 2>&1; then
    echo "✅ Minimal Semgrep wrapper is working correctly!"
    "$WRAPPER_PATH" --version
else
    echo "⚠️  Minimal Semgrep wrapper created but Semgrep is not installed on this system"
    echo "   The app will show installation instructions to users"
fi

echo "🎉 Minimal Semgrep wrapper setup complete!"
echo "📦 This can now be distributed with your app to the App Store"
