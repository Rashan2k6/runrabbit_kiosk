import csv
import os
import re

def parse_dart_map(content, map_name):
    # Find block: const _en = <String, String>{ ... };
    pattern = rf'const\s+{map_name}\s*=\s*<String,\s*String>\s*\{{(.*?)\}};'
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        raise ValueError(f"Could not find {map_name} map in strings.dart")
    
    block = match.group(1)
    
    # Matches: 'key': ... or "key": ...
    entry_pattern = re.compile(
        r'''(?P<comment_before>(?:\s*//[^\n]*\n)*)\s*['"](?P<key>[^'"]+)['"]\s*:\s*(?P<val>(?:(?:'[^'\\]*(?:\\.[^'\\]*)*'|"[^"\\]*(?:\\.[^"\\]*)*")\s*)+)\s*,\s*(?P<comment_inline>//[^\n]*)?''',
        re.MULTILINE
    )

    str_token_pattern = re.compile(r'''(?:'([^'\\]*(?:\\.[^'\\]*)*)'|"([^"\\]*(?:\\.[^"\\]*)*)")''')
    
    entries = {}
    for m in entry_pattern.finditer(block):
        key = m.group('key')
        val_raw = m.group('val')
        comment_inline = m.group('comment_inline') or ''
        comment_before = m.group('comment_before') or ''
        
        # Concatenate adjacent string tokens
        parts = []
        for token in str_token_pattern.finditer(val_raw):
            part = token.group(1) if token.group(1) is not None else token.group(2)
            part = part.replace(r"\'", "'").replace(r'\"', '"').replace(r'\n', '\n')
            parts.append(part)
        val = "".join(parts)
        
        has_todo = "TODO native speaker review" in comment_inline or "TODO native speaker review" in comment_before
        entries[key] = {
            'value': val,
            'reviewed': not has_todo,
            'raw_comment': comment_inline
        }
        
    return entries

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    strings_file = os.path.join(root, 'lib', 'app', 'strings.dart')
    csv_file = os.path.join(root, 'tools', 'strings.csv')
    
    with open(strings_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    en_entries = parse_dart_map(content, '_en')
    si_entries = parse_dart_map(content, '_si')
    
    rows = []
    for key, en_info in en_entries.items():
        en_text = en_info['value']
        si_info = si_entries.get(key)
        if si_info:
            si_text = si_info['value']
            reviewed = 'yes' if si_info['reviewed'] else 'no'
        else:
            si_text = ''
            reviewed = 'no'
        rows.append({
            'key': key,
            'english': en_text,
            'sinhala': si_text,
            'reviewed': reviewed
        })
        
    with open(csv_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['key', 'english', 'sinhala', 'reviewed'])
        writer.writeheader()
        writer.writerows(rows)
        
    print(f"Exported {len(rows)} string entries to {csv_file}")

if __name__ == '__main__':
    main()

