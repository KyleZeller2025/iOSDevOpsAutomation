#!/usr/bin/env python3
"""
Script to add the Resources folder to the Xcode project.
This ensures the bundled Semgrep binary is included in the app.
"""

import os
import re
import uuid

def add_resources_to_project():
    project_file = "iOSDevOpsAutomation.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ Project file not found")
        return False
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Generate unique IDs for the new entries
    resources_group_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    semgrep_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    
    # Find the main group section and add Resources folder
    main_group_pattern = r'(/\* Begin PBXGroup section \*/\s+[^}]+mainGroup = \{[^}]+children = \(\s+)([^}]+)(\s+\);[^}]+};)'
    
    def add_resources_to_main_group(match):
        prefix = match.group(1)
        children = match.group(2)
        suffix = match.group(3)
        
        # Add Resources group reference
        resources_entry = f"\t\t\t\t{resources_group_id} /* Resources */,\n"
        
        # Insert after the last existing entry
        lines = children.split('\n')
        # Find the last non-empty line with a group reference
        last_group_line = -1
        for i, line in enumerate(lines):
            if '/*' in line and '*/' in line and '/*' in line.split('/*')[1]:
                last_group_line = i
        
        if last_group_line >= 0:
            lines.insert(last_group_line + 1, resources_entry)
        else:
            lines.append(resources_entry)
        
        return prefix + '\n'.join(lines) + suffix
    
    # Add Resources group to main group
    content = re.sub(main_group_pattern, add_resources_to_main_group, content, flags=re.DOTALL)
    
    # Add the Resources group definition
    resources_group_def = f"""
\t\t{resources_group_id} /* Resources */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{semgrep_file_id} /* semgrep */,
\t\t\t);
\t\t\tpath = Resources;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    # Insert before the "End PBXGroup section" comment
    content = re.sub(
        r'(/\* End PBXGroup section \*/)',
        resources_group_def + r'\n\n\t\t/* End PBXGroup section */',
        content
    )
    
    # Add the semgrep file reference
    semgrep_file_ref = f"""
\t\t{semgrep_file_id} /* semgrep */ = {{
\t\t\tisa = PBXFileReference;
\t\t\tlastKnownFileType = text.script.python;
\t\t\tpath = semgrep;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    # Insert before the "End PBXFileReference section" comment
    content = re.sub(
        r'(/\* End PBXFileReference section \*/)',
        semgrep_file_ref + r'\n\n\t\t/* End PBXFileReference section */',
        content
    )
    
    # Add semgrep to the Resources build phase
    resources_build_phase_pattern = r'(02DAD4482E70CC2D00BB3786 /\* Resources \*/ = \{[^}]+files = \(\s+)([^}]+)(\s+\);[^}]+};)'
    
    def add_semgrep_to_resources(match):
        prefix = match.group(1)
        files = match.group(2)
        suffix = match.group(3)
        
        # Add semgrep file reference
        semgrep_build_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
        semgrep_entry = f"\t\t\t\t{semgrep_build_file_id} /* semgrep in Resources */,\n"
        
        # Insert the file reference
        files_lines = files.split('\n')
        files_lines.append(semgrep_entry)
        
        return prefix + '\n'.join(files_lines) + suffix
    
    content = re.sub(resources_build_phase_pattern, add_semgrep_to_resources, content, flags=re.DOTALL)
    
    # Add the build file reference
    semgrep_build_file_id = str(uuid.uuid4()).replace('-', '').upper()[:24]
    semgrep_build_file_ref = f"""
\t\t{semgrep_build_file_id} /* semgrep in Resources */ = {{
\t\t\tisa = PBXBuildFile;
\t\t\tfileRef = {semgrep_file_id} /* semgrep */;
\t\t}};"""
    
    # Insert before the "End PBXBuildFile section" comment
    content = re.sub(
        r'(/\* End PBXBuildFile section \*/)',
        semgrep_build_file_ref + r'\n\n\t\t/* End PBXBuildFile section */',
        content
    )
    
    # Write the updated content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Resources folder added to Xcode project")
    return True

if __name__ == "__main__":
    add_resources_to_project()
