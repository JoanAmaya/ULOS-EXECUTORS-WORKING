import os
import re
import sys
import json
import time
from datetime import datetime

class StepResult:
    def __init__(self, filename):
        self.filename = filename
        self.steps_passed = 0
        self.steps_failed = 0
        self.passed = True

class CompleteResults:
    def __init__(self):
        self.kraken_version = None
        self.environment = None
        self.specs = None
        self.passed = True
        self.timestamp = None
        self.has_logs = False
        self.log_location = None
        self.detail = []

def main():
    work_dir = os.getcwd()

    if len(sys.argv) < 2:
        print("[ERROR] Missing required argument: path to Kraken output file.")
        sys.exit(1)

    results_file = sys.argv[1]  # e.g. /results/chrome_execution_output.txt
    env_name = os.path.basename(results_file).split("_")[0]
    output_file_prefix = f"/results/{env_name}_"

    print(f"[INFO] Environment: {env_name} | Input File: {results_file} | Output Prefix: {output_file_prefix}")

    try:
        with open(work_dir + results_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"[ERROR] Could not open {results_file}: {e}")
        sys.exit(1)

    print(f"[INFO] Parsing execution output from {work_dir + results_file}...")

    result = CompleteResults()
    current_suite = None
    test_suites = []

    # Regex patterns expected in Kraken execution logs
    kraken_version_re = re.compile(r"Kraken\s+version:\s+([\d\.]+)")
    env_re = re.compile(r"Running environment:\s+(\S+)")
    running_re = re.compile(r"Running:\s+(\S+)")
    step_passed_re = re.compile(r"✓\s+(Given|When|Then|And|But)\s+")
    step_failed_re = re.compile(r"✗\s+(Given|When|Then|And|But)\s+")
    log_detect_re = re.compile(r"(Logs\s+saved\s+to:)")
    error_trace_re = re.compile(r"(Traceback|Exception|Error:)")

    for line in lines:
        line = line.strip()

        # Kraken version
        match = kraken_version_re.search(line)
        if match:
            result.kraken_version = match.group(1)

        # Environment
        match = env_re.search(line)
        if match:
            result.environment = match.group(1)

        # Start of a new feature/scenario file
        match = running_re.search(line)
        if match:
            # Save previous suite if exists
            if current_suite:
                current_suite.passed = current_suite.steps_failed == 0
                test_suites.append(current_suite)

            filename = match.group(1)
            current_suite = StepResult(filename)
            continue

        # Steps passed
        if step_passed_re.search(line):
            if current_suite:
                current_suite.steps_passed += 1
            continue

        # Steps failed
        if step_failed_re.search(line):
            if current_suite:
                current_suite.steps_failed += 1
                current_suite.passed = False
            continue

        # Detect logs
        if log_detect_re.search(line):
            result.has_logs = True
            result.log_location = "/kraken/logs/"
            continue

        # Detect runtime errors
        if error_trace_re.search(line):
            if current_suite:
                current_suite.steps_failed += 1
                current_suite.passed = False
            continue

    # Append last suite
    if current_suite:
        current_suite.passed = current_suite.steps_failed == 0
        test_suites.append(current_suite)

    result.detail = [
        {
            "filename": s.filename,
            "steps_passed": s.steps_passed,
            "steps_failed": s.steps_failed,
            "result": s.passed
        } for s in test_suites
    ]

    result.timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    result.passed = all(s.passed for s in test_suites)

    json_data = {
        "kraken_version": result.kraken_version,
        "environment": result.environment or env_name,
        "specs": "Step Definitions",
        "passed": result.passed,
        "timestamp": result.timestamp,
        "has_logs": result.has_logs,
        "log_location": result.log_location,
        "detail": result.detail
    }

    results_output_file = work_dir + output_file_prefix + "execution_results.json"
    log_output_file = work_dir + output_file_prefix + "execution_passed.log"

    try:
        with open(results_output_file, "w", encoding="utf-8") as f:
            json.dump(json_data, f, indent=2)
        print(f"[INFO] Test result written to {results_output_file}")
    except Exception as e:
        print(f"[ERROR] Could not write results: {e}")
        sys.exit(1)

    if result.passed:
        try:
            with open(log_output_file, "w") as f:
                f.write("All step definitions passed successfully.\n")
            print(f"[INFO] Execution PASSED. Log created at {log_output_file}")
        except Exception as e:
            print(f"[ERROR] Could not create pass log: {e}")

if __name__ == "__main__":
    main()
