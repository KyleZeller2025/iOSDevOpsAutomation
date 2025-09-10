#!/bin/bash

# Simple script to set up Semgrep for the iOS DevOps Automation app
# This creates a Python script that can be bundled with the app

set -e

echo "🔍 Setting up Semgrep for iOS DevOps Automation..."

# Create resources directory if it doesn't exist
RESOURCES_DIR="iOSDevOpsAutomation/Resources"
mkdir -p "$RESOURCES_DIR"

# Create a simple Python script that uses the system's Python to run Semgrep
cat > "$RESOURCES_DIR/semgrep" << 'EOF'
#!/usr/bin/env python3
"""
Semgrep wrapper for iOS DevOps Automation app.
This script attempts to run Semgrep using the system's Python installation.
"""

import sys
import subprocess
import os

def main():
    # Try different ways to run semgrep
    commands_to_try = [
        ["python3", "-m", "semgrep"] + sys.argv[1:],
        ["python", "-m", "semgrep"] + sys.argv[1:],
        ["semgrep"] + sys.argv[1:],
    ]
    
    for cmd in commands_to_try:
        try:
            # Try to run the command
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
            
            # If successful, print output and exit with same code
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr, file=sys.stderr)
            
            sys.exit(result.returncode)
            
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
            # Command failed, try next one
            continue
    
    # If all commands failed
    print("Error: Semgrep is not available. Please install it using:", file=sys.stderr)
    print("  pip install semgrep", file=sys.stderr)
    print("  or", file=sys.stderr)
    print("  brew install semgrep", file=sys.stderr)
    sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# Make it executable
chmod +x "$RESOURCES_DIR/semgrep"

echo "✅ Semgrep wrapper created at: $RESOURCES_DIR/semgrep"

# Test the wrapper
echo "🧪 Testing Semgrep wrapper..."
if "$RESOURCES_DIR/semgrep" --version > /dev/null 2>&1; then
    echo "✅ Semgrep wrapper is working correctly"
    "$RESOURCES_DIR/semgrep" --version
else
    echo "⚠️  Semgrep wrapper created but Semgrep is not installed on this system"
    echo "   The app will show installation instructions to users"
fi

echo "🎉 Semgrep setup complete!"
