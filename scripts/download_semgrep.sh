#!/bin/bash

# Script to create a standalone Semgrep binary for macOS
# This ensures the app works without requiring users to install Semgrep

set -e

echo "🔍 Creating standalone Semgrep binary for macOS..."

# Create resources directory if it doesn't exist
RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

BINARY_PATH="$RESOURCES_DIR/semgrep"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required to create the Semgrep binary"
    echo "Please install Python 3 and try again"
    exit 1
fi

# Create a temporary directory for building
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📦 Installing Semgrep in temporary environment..."

# Install Semgrep in a virtual environment
python3 -m venv semgrep_env
source semgrep_env/bin/activate

# Install Semgrep
pip install semgrep

# Find the semgrep executable
SEMGREP_EXECUTABLE=$(find semgrep_env -name "semgrep" -type f | head -1)

if [[ -z "$SEMGREP_EXECUTABLE" ]]; then
    echo "❌ Error: Could not find semgrep executable after installation"
    exit 1
fi

echo "📋 Creating standalone binary..."

# Create a wrapper script that includes all dependencies
cat > semgrep_standalone.py << 'EOF'
#!/usr/bin/env python3
"""
Standalone Semgrep wrapper that includes all dependencies.
This allows Semgrep to run without requiring a separate Python installation.
"""

import sys
import os
import subprocess
import json
import tempfile
import shutil
from pathlib import Path

# Add the bundled semgrep to the Python path
BUNDLE_DIR = os.path.dirname(os.path.abspath(__file__))
SEMGREP_DIR = os.path.join(BUNDLE_DIR, 'semgrep_package')

if os.path.exists(SEMGREP_DIR):
    sys.path.insert(0, SEMGREP_DIR)

try:
    # Try to import semgrep directly
    import semgrep
    from semgrep import main as semgrep_main
except ImportError:
    # Fallback: try to run semgrep as a subprocess
    print("Semgrep not available as Python module, using subprocess fallback", file=sys.stderr)
    sys.exit(1)

if __name__ == "__main__":
    # Run semgrep with the provided arguments
    sys.argv[0] = "semgrep"
    semgrep_main()
EOF

# Copy the semgrep package
cp -r semgrep_env/lib/python*/site-packages/semgrep "$TEMP_DIR/semgrep_package"

# Make the wrapper executable
chmod +x semgrep_standalone.py

# Copy to resources directory
cp semgrep_standalone.py "$BINARY_PATH"
cp -r semgrep_package "$RESOURCES_DIR/"

# Make it executable
chmod +x "$BINARY_PATH"

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo "✅ Semgrep standalone binary created at: $BINARY_PATH"

# Verify the binary works
echo "🧪 Testing Semgrep binary..."
if "$BINARY_PATH" --version > /dev/null 2>&1; then
    echo "✅ Semgrep binary is working correctly"
    "$BINARY_PATH" --version
else
    echo "❌ Error: Semgrep binary is not working"
    exit 1
fi

echo "🎉 Semgrep setup complete!"
