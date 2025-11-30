#!/usr/bin/env python3

import json
import re
import sys
from datetime import datetime
from pathlib import Path


class FeatureResult:
    def __init__(self):
        self.feature_name = ""
        self.scenarios_total = 0
        self.scenarios_passed = 0
        self.scenarios_failed = 0
        self.scenarios_skipped = 0
        self.steps_total = 0
        self.steps_passed = 0
        self.steps_failed = 0
        self.steps_skipped = 0
        self.execution_time = ""
        self.passed = True

    def to_dict(self):
        return {
            "feature_name": self.feature_name,
            "scenarios_total": self.scenarios_total,
            "scenarios_passed": self.scenarios_passed,
            "scenarios_failed": self.scenarios_failed,
            "scenarios_skipped": self.scenarios_skipped,
            "steps_total": self.steps_total,
            "steps_passed": self.steps_passed,
            "steps_failed": self.steps_failed,
            "steps_skipped": self.steps_skipped,
            "execution_time": self.execution_time,
            "result": self.passed
        }


class CompleteResults:
    def __init__(self):
        self.kraken_version = ""
        self.browser = ""
        self.device = ""
        self.features = ""
        self.passed = True
        self.timestamp = ""
        self.has_screenshots = False
        self.screenshots_location = ""
        self.execution_time = ""
        self.detail = []

    def to_dict(self):
        return {
            "kraken_version": self.kraken_version,
            "browser": self.browser,
            "device": self.device,
            "features": self.features,
            "passed": self.passed,
            "timestamp": self.timestamp,
            "has_screenshots": self.has_screenshots,
            "screenshots_location": self.screenshots_location if self.has_screenshots else None,
            "execution_time": self.execution_time,
            "detail": [feature.to_dict() for feature in self.detail]
        }


def parse_kraken_output(input_file):
    """Parse Kraken execution output file"""
    
    result = CompleteResults()
    current_feature = FeatureResult()
    
    # Regex patterns
    devtools_pattern = re.compile(r'INFO devtools')
    puppeteer_pattern = re.compile(r'INFO devtools:puppeteer')
    launch_chrome_pattern = re.compile(r'Launch Google Chrome')
    screenshot_pattern = re.compile(r'COMMAND takeScreenshot\(\)')
    
    # Results patterns
    scenarios_pattern = re.compile(r'(\d+)\s+scenarios?\s+\(([^)]+)\)')
    steps_pattern = re.compile(r'(\d+)\s+steps?\s+\(([^)]+)\)')
    time_pattern = re.compile(r'(\d+m[\d.]+s)')
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.split('\n')
        
        for line in lines:
            # Detect browser from Chrome launch
            if launch_chrome_pattern.search(line):
                result.browser = "Google Chrome"
                if '--headless' in line:
                    result.browser += " (headless)"
            
            # Detect screenshots
            if screenshot_pattern.search(line):
                result.has_screenshots = True
                result.screenshots_location = "/kraken/screenshots/"
            
            # Parse scenario results
            scenarios_match = scenarios_pattern.search(line)
            if scenarios_match:
                total = int(scenarios_match.group(1))
                details = scenarios_match.group(2)
                
                current_feature.scenarios_total = total
                
                # Parse details: "1 passed" or "2 failed, 1 passed"
                passed_match = re.search(r'(\d+)\s+passed', details)
                failed_match = re.search(r'(\d+)\s+failed', details)
                skipped_match = re.search(r'(\d+)\s+skipped', details)
                
                if passed_match:
                    current_feature.scenarios_passed = int(passed_match.group(1))
                if failed_match:
                    current_feature.scenarios_failed = int(failed_match.group(1))
                if skipped_match:
                    current_feature.scenarios_skipped = int(skipped_match.group(1))
                
                current_feature.passed = current_feature.scenarios_failed == 0
            
            # Parse steps results
            steps_match = steps_pattern.search(line)
            if steps_match:
                total = int(steps_match.group(1))
                details = steps_match.group(2)
                
                current_feature.steps_total = total
                
                passed_match = re.search(r'(\d+)\s+passed', details)
                failed_match = re.search(r'(\d+)\s+failed', details)
                skipped_match = re.search(r'(\d+)\s+skipped', details)
                
                if passed_match:
                    current_feature.steps_passed = int(passed_match.group(1))
                if failed_match:
                    current_feature.steps_failed = int(failed_match.group(1))
                if skipped_match:
                    current_feature.steps_skipped = int(skipped_match.group(1))
            
            # Parse execution time
            time_match = time_pattern.search(line)
            if time_match:
                current_feature.execution_time = time_match.group(1)
                result.execution_time = time_match.group(1)
    
    # Set feature name from file or default
    current_feature.feature_name = Path(input_file).stem.replace('_execution_output', '')
    
    # Add feature to results
    if current_feature.scenarios_total > 0 or current_feature.steps_total > 0:
        result.detail.append(current_feature)
    
    # Determine overall pass/fail
    result.passed = all(feature.passed for feature in result.detail)
    
    # Set timestamp
    result.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Set metadata
    result.kraken_version = "Unknown"
    result.device = Path(input_file).stem.split('_')[0] if '_' in Path(input_file).stem else "Unknown"
    result.features = f"{len(result.detail)} feature(s)"
    
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python kraken_parser.py <input_file>")
        print("Example: python kraken_parser.py /results/chrome_execution_output.txt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    # Extract browser/device name from filename
    filename = Path(input_file).name
    device = filename.split('_')[0] if '_' in filename else 'unknown'
    
    output_dir = Path(input_file).parent
    output_prefix = f"{device}_"
    
    print(f"[INFO] Device: {device} | Input File: {input_file} | Output To: {output_dir}/{output_prefix}")
    
    # Check if file exists
    if not Path(input_file).exists():
        print(f"[ERROR] File not found: {input_file}")
        sys.exit(1)
    
    print(f"[INFO] Parsing execution output from {input_file}...")
    
    # Parse the output
    results = parse_kraken_output(input_file)
    
    # Output JSON file
    json_output_file = output_dir / f"{output_prefix}execution_results.json"
    with open(json_output_file, 'w', encoding='utf-8') as f:
        json.dump(results.to_dict(), f, indent=2, ensure_ascii=False)
    
    print(f"[INFO] Test result has been written to {json_output_file}")
    
    # Create passed log file if all tests passed
    if results.passed:
        log_output_file = output_dir / f"{output_prefix}execution_passed.log"
        log_output_file.touch()
        print(f"[INFO] All tests passed! Created {log_output_file}")
    else:
        print("[INFO] Some tests failed. No passed.log created.")
    
    # Print summary
    print("\n" + "="*50)
    print("EXECUTION SUMMARY")
    print("="*50)
    print(f"Overall Status: {'PASSED' if results.passed else 'FAILED'}")
    print(f"Execution Time: {results.execution_time}")
    print(f"Features: {len(results.detail)}")
    
    for feature in results.detail:
        print(f"\nFeature: {feature.feature_name}")
        print(f"  Scenarios: {feature.scenarios_passed}/{feature.scenarios_total} passed")
        print(f"  Steps: {feature.steps_passed}/{feature.steps_total} passed")
        print(f"  Status: {'✓ PASSED' if feature.passed else '✗ FAILED'}")


if __name__ == "__main__":
    main()