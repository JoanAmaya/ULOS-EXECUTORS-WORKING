# ULOS - Worker Nodes

ULOS emerges out of the need of both students and staff at Universidad de los Andes to, respectively, receive and deliver high quality feedback for software and lab based assignments. The university wishes to offer its range of remote and on-premise laboratories, as well as computation resources, in a more efficient and organized manner with the ultimate goal of increasing their capacity.

This repository contains the files related to the contenerization of the different task types in the ULOS system.

- 🌐 Web test automation (with Cypress)
- 📱 Mobile test automation
- 🦾 Robotic arm
- 🖨️ 3D printers
- 🔌 Electric Grid

## Index

- [**Static Analysis - Grammars**](/grammar-execution/)
- **Dynamic Analysis**
  - [Cypress Execution](/cypress-executor/)
  - [Kotlin - Mobile Application Execution](/kotlin-executor/)

## Communication protocol with orchestrator

All new workers must adhere to the established communication protocol between nodes and the orchestration system. This protocol allows the orchestrator to take action based on the result of the analysis while maintaining decoupled components.

- Workers will create an empty file named `task.log` while executing to indicate that it is in progress
- Workers will create an empty file named and a `passed.log` file to indicate that execution was successful, the lack of this file indicates a failure.
- It is the responsibility of the orchestrator to remove the `passed.log` file before proceeding to the next execution step.
- All results produced by the worker will be in `JSON` format. Each use-case must describe in its `README` the structure of their output results.

## Future Work

- [ ] Expand the grammar for the Cypress framework to include all commands and their specific syntax. Currently the following commands are completed: `visit`, `get`, `click`, `type`, `should`, `contains`, `screenshot`, `scrollTo`
- [ ] Process Cypress configuration styles and determine browsers in which to test at runtime.
- [ ] Integrate the analysis of other types of tasks including, but not limited to:
  - [ ] Mobile App Development in Swift (UIKit and SwiftUI)
  - [ ] Robotic arm digital twins and real-world tests
  - [ ] Monkey testing for web applications
- [ ] Pre-static analysis stage: In this stage, the system would conduct a completion review based on each area. For example, in a Kotlin application checking for `.kotlin` files, an apk etc.
