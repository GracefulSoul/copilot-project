#!/usr/bin/env python3
"""
Code Complexity Analyzer
Calculates cyclomatic and cognitive complexity metrics
"""

import os
import json
import sys
from pathlib import Path
from typing import Dict, List, Any

def analyze_complexity(file_path: str) -> Dict[str, Any]:
    """
    Analyze complexity of a single file
    
    Args:
        file_path: Path to the source file
        
    Returns:
        Dictionary with complexity metrics
    """
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Count control flow structures
    control_flows = {
        'if': content.count('if '),
        'for': content.count('for '),
        'while': content.count('while '),
        'case': content.count('case '),
        'catch': content.count('catch'),
        'ternary': content.count('?'),
        'boolean_and': content.count('&&'),
        'boolean_or': content.count('||'),
    }
    
    # Cyclomatic complexity estimate
    cyclomatic = sum(control_flows.values()) + 1
    
    # Cognitive complexity
    cognitive = cyclomatic + control_flows['ternary']
    
    return {
        'file': file_path,
        'lines': len(content.split('\n')),
        'cyclomatic_complexity': cyclomatic,
        'cognitive_complexity': cognitive,
        'control_flows': control_flows,
        'high_complexity': cyclomatic > 10,
    }

def main():
    """Main entry point"""
    path = sys.argv[1] if len(sys.argv) > 1 else '.'
    
    results = {
        'summary': {
            'total_files': 0,
            'high_complexity_count': 0,
            'average_complexity': 0,
        },
        'files': [],
    }
    
    # Find all source files
    extensions = ['.js', '.ts', '.py', '.java', '.go', '.rs']
    total_complexity = 0
    
    for ext in extensions:
        for file_path in Path(path).rglob(f'*{ext}'):
            if 'node_modules' in str(file_path) or '__pycache__' in str(file_path):
                continue
            
            try:
                metrics = analyze_complexity(str(file_path))
                results['files'].append(metrics)
                
                total_complexity += metrics['cyclomatic_complexity']
                results['summary']['total_files'] += 1
                
                if metrics['high_complexity']:
                    results['summary']['high_complexity_count'] += 1
            except Exception as e:
                print(f"Error analyzing {file_path}: {e}", file=sys.stderr)
    
    # Calculate averages
    if results['summary']['total_files'] > 0:
        results['summary']['average_complexity'] = (
            total_complexity / results['summary']['total_files']
        )
    
    # Sort by complexity
    results['files'].sort(
        key=lambda x: x['cyclomatic_complexity'],
        reverse=True
    )
    
    # Output JSON
    print(json.dumps(results, indent=2))

if __name__ == '__main__':
    main()
