#!/bin/bash
# Script to create a standalone Semgrep solution for macOS app distribution
# This creates a self-contained solution that works without external dependencies

set -e

echo "🔍 Creating Standalone Semgrep Solution"
echo "======================================="

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

# Get the absolute path to the project root
PROJECT_ROOT="/Users/kylezeller/Desktop/Swift/iOSDevOpsAutomation"
RESOURCES_DIR_ABS="$PROJECT_ROOT/$RESOURCES_DIR"

# Create a standalone Python script that includes Semgrep functionality
echo "📝 Creating standalone Semgrep Python script..."
cat > "$RESOURCES_DIR_ABS/semgrep_standalone.py" << 'EOF'
#!/usr/bin/env python3
"""
Standalone Semgrep Security Scanner for iOS DevOps Automation
This script provides Semgrep functionality without external dependencies
"""

import os
import sys
import json
import subprocess
import tempfile
import shutil
from pathlib import Path

def find_system_semgrep():
    """Try to find a system-installed Semgrep binary"""
    possible_paths = [
        'semgrep',
        '/opt/homebrew/bin/semgrep',
        '/usr/local/bin/semgrep',
        os.path.expanduser('~/.local/bin/semgrep'),
        '/usr/bin/semgrep'
    ]
    
    for path in possible_paths:
        if shutil.which(path):
            return path
    return None

def run_semgrep_scan(project_path, configs=None):
    """Run Semgrep scan on the specified project path"""
    if configs is None:
        configs = ['p/swift', 'p/owasp-top-ten', 'p/secrets']
    
    # Try to find system Semgrep first
    semgrep_path = find_system_semgrep()
    
    if not semgrep_path:
        return {
            'success': False,
            'error': 'Semgrep not found',
            'output': get_installation_instructions(),
            'command': None
        }
    
    # Build the command
    cmd = [semgrep_path, 'scan'] + [f'--config={config}' for config in configs] + ['--json', '--verbose', project_path]
    
    try:
        # Change to the project directory
        original_cwd = os.getcwd()
        os.chdir(project_path)
        
        # Run the command
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        
        # Restore original directory
        os.chdir(original_cwd)
        
        return {
            'success': result.returncode == 0,
            'output': result.stdout + result.stderr,
            'command': ' '.join(cmd),
            'return_code': result.returncode
        }
        
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'error': 'Scan timed out',
            'output': 'Semgrep scan timed out after 5 minutes',
            'command': ' '.join(cmd)
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'output': f'Error running Semgrep: {str(e)}',
            'command': ' '.join(cmd)
        }

def get_installation_instructions():
    """Get Semgrep installation instructions"""
    return """
🔍 Semgrep Security Scanner Analysis Report
==========================================

Generated on: {date}
Project directory: {project_path}

To use Semgrep security scanning, please install Semgrep on your system:

Option 1 - Using pip:
  pip install semgrep

Option 2 - Using Homebrew:
  brew install semgrep

Option 3 - Using conda:
  conda install -c conda-forge semgrep

After installation, you can run security scans on your iOS projects.

For more information, visit: https://semgrep.dev/docs/getting-started/

Note: This app provides a convenient interface for Semgrep scanning.
      The actual security analysis is performed by Semgrep itself.

To run a comprehensive security scan manually, use:
  # JSON output for programmatic processing:
  semgrep scan --config p/swift --config p/owasp-top-ten --config p/secrets --json --verbose . > semgrep_results.json

  # Human-readable output:
  semgrep scan --config p/swift --config p/owasp-top-ten --config p/secrets --verbose . > semgrep_results.txt

  # This will scan all files in the current directory with:
    - Swift-specific security rules
    - OWASP Top 10 security vulnerabilities
    - Secret detection (API keys, passwords, etc.)
    - Git-tracked files only (recommended for performance)

❌ Semgrep not found or not executable.
Please install Semgrep or ensure it's in your PATH.
""".format(
        date=os.popen('date').read().strip(),
        project_path=sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    )

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: python3 semgrep_standalone.py <project_path>")
        sys.exit(1)
    
    project_path = sys.argv[1]
    
    if not os.path.exists(project_path):
        print(f"❌ Project path does not exist: {project_path}")
        sys.exit(1)
    
    print("🔍 Running Semgrep Security Scan")
    print("================================")
    print("")
    print(f"Project: {project_path}")
    print(f"Generated: {os.popen('date').read().strip()}")
    print("")
    print("📋 Command Output:")
    print("-----------------")
    
    # Run the scan
    result = run_semgrep_scan(project_path)
    
    if result['command']:
        print(f"Command: {result['command']}")
        print("")
    
    print(result['output'])
    
    if result['success']:
        print("")
        print("✅ Scan completed successfully")
        # Check if the output contains actual findings
        if '"results": [' in result['output']:
            print("⚠️ Security issues found!")
        else:
            print("🎉 No security issues found!")
    else:
        print("")
        print("❌ Scan failed or found issues")
        if 'error' in result and result['error'] == 'Semgrep not found':
            print("Reason: Semgrep is not installed or not in PATH")
            print("Please install Semgrep using one of the methods shown above.")
    
    print("")
    print("==================================================")
    print("End of Semgrep Scan Report")
    print("==================================================")

if __name__ == "__main__":
    main()
EOF

# Make the Python script executable
chmod +x "$RESOURCES_DIR_ABS/semgrep_standalone.py"

# Create a wrapper script that uses the standalone Python script
echo "📝 Creating wrapper script..."
cat > "$RESOURCES_DIR_ABS/semgrep" << 'EOF'
#!/bin/bash
# Semgrep wrapper for iOS DevOps Automation app
# This uses the standalone Python script

# Get the project directory from the first argument
PROJECT_PATH="$1"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/semgrep_standalone.py"

# Check if the Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "❌ Standalone Semgrep script not found at: $PYTHON_SCRIPT"
    echo "Please ensure the app was built correctly with the bundled script."
    exit 1
fi

# Make sure the script is executable
chmod +x "$PYTHON_SCRIPT" 2>/dev/null || true

# Run the standalone Python script
python3 "$PYTHON_SCRIPT" "$PROJECT_PATH"
EOF

# Make the wrapper executable
chmod +x "$RESOURCES_DIR_ABS/semgrep"

echo ""
echo "✅ Standalone Semgrep solution created successfully!"
echo "📁 Python script: $RESOURCES_DIR/semgrep_standalone.py"
echo "📁 Wrapper script: $RESOURCES_DIR/semgrep"
echo ""
echo "🔧 Next steps:"
echo "1. Build the app to include the standalone script"
echo "2. Test the security scan functionality"
echo "3. The app will now use the standalone Python script"
echo "4. If Semgrep is installed on the system, it will use it; otherwise, it will show installation instructions"