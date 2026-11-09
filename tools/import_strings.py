import csv
import os
import re

def format_dart_string(val):
    val = val.replace('\n', r'\n')
    if "'" not in val:
        return f"'{val}'"
    elif '"' not in val:
        return f'"{val}"'
    else:
        escaped = val.replace("'", r"\'")
        return f"'{escaped}'"

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    strings_file = os.path.join(root, 'lib', 'app', 'strings.dart')
    csv_file = os.path.join(root, 'tools', 'strings.csv')
    
    if not os.path.exists(csv_file):
        raise FileNotFoundError(f"Cannot find {csv_file}")
        
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        
    si_lines = ["const _si = <String, String>{"]
    
    for row in rows:
        key = row.get('key', '').strip()
        sinhala = row.get('sinhala', '').strip()
        reviewed_val = row.get('reviewed', '').strip().lower()
        has_reviewed_col = 'reviewed' in (reader.fieldnames or [])
        
        # Keep English fallback when Sinhala cell is empty
        if not sinhala:
            continue
            
        dart_val = format_dart_string(sinhala)
        # If reviewed column exists and is yes/true/1, marked reviewed.
        # Otherwise keep // TODO native speaker review
        if has_reviewed_col and reviewed_val in ('yes', 'true', '1'):
            comment = ""
        else:
            comment = " // TODO native speaker review"
            
        si_lines.append(f"  '{key}': {dart_val},{comment}")
        
    si_lines.append("};")
    new_si_block = "\n".join(si_lines)
    
    with open(strings_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    si_pattern = r'const\s+_si\s*=\s*<String,\s*String>\s*\{.*?\};'
    if not re.search(si_pattern, content, re.DOTALL):
        raise ValueError("Could not locate const _si map in strings.dart")
        
    updated = re.sub(si_pattern, new_si_block, content, flags=re.DOTALL)
    
    with open(strings_file, 'w', encoding='utf-8', newline='\n') as f:
        f.write(updated)
        
    print(f"Successfully regenerated _si map in {strings_file}")

if __name__ == '__main__':
    main()

