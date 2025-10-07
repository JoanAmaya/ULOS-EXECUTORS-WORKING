# GCode Executor
The GCode Executor is a tool for dynamic analysis of G-Code files, designed to validate whether a file can be correctly executed by a specific 3D printer. This validation is performed taking into account the printer's physical restrictions (print volume and maximum allowed paths) defined in a configuration file (printer.properties).

## What does it do?
- It analyzes G0/G1 movements in .gcode files.
- It detects anomalous movements, such as:
    * Paths that are too long.
    * Coordinates outside the defined print volume.
    * It generates an interactive 3D visualization of the paths using Plotly.
    * It records the validation in a log (passed.log) if the visualization is generated correctly.

## Project Structure
```
ULOS-EXECUTORS/gcode-executor
│
├── gcode_visualizer.py         # Main executor script
├── Dockerfile                  # Docker image to run the executor
├── test-files/
│   ├── printer.properties      # Physical printer properties
│   ├── test.gcode              # G-Code test file
│   └── results/
│       ├── test_visualizacion.html  # Visualization result
│       └── passed.log               # Log created if everything is successful
```
## Parameter Configuration (`printer.properties`)

```ini
[PRINTER]
MAX_X = 800
MAX_Y = 800
MAX_Z = 800
LONG_MOVE_THRESHOLD = 100
```

- `MAX_X`, `MAX_Y`, `MAX_Z`: maximum limits of the print volume in millimeters.  
- `LONG_MOVE_THRESHOLD`: maximum allowed distance between two consecutive points before being considered an anomaly.

---

## Requirements
Docker installed on your system.

## Running with Docker
From the project root:

``` bash
docker build -t gcode-visualizer .
docker run --rm -v "$(pwd)/test-files:/app/tests" gcode-visualizer
```

This will do the following:

- Load the printer properties from printer.properties.
- Parse the .gcode file in the test-files folder.
- Generate a 3D visualization of the file.
- Save the generated HTML to test-files/results/.
- If successful, a passed.log file will be created in results/.

## Output

- A 3D visualization in `.html` format is generated in `test-files/results/`, showing:
  - Normal movements in blue.
  - Anomalous movements in red.
- A `passed.log` file is created if the process finishes successfully.
