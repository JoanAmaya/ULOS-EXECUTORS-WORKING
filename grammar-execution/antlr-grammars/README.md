# ANTLR Grammars Directory

This directory hosts ANTLR grammar definitions used for generating Go-based lexers and parsers within the Docker build process.

## Adding a New Grammar

To integrate a new grammar into the system, follow these steps:

1. **Create a Subdirectory**
   - Under `antlr-grammars/`, create a new folder named after your target language or framework, using lowercase letters (e.g., `cypress`, `swift`, `kotlin`).

2. **Add the Grammar File**
   - Within the new subdirectory, add a single `.g4` file whose filename matches the subdirectory name with an initial uppercase letter (e.g., `Cypress.g4`, `Swift.g4`, `Kotlin.g4`).

3. **Define the Grammar Name**
   - Ensure the grammar file’s first line declares the grammar using the same capitalized name, for example:

     ```g4
     grammar Cypress;
     ```

4. **Verify Naming Consistency**
   - The file name, subdirectory name, and grammar declaration must align exactly (case-sensitive) to allow the Docker build script to correctly replace placeholders and generate Go code.

## Example Structure

```txt
antlr-grammars/
├── cypress/
│   └── Cypress.g4    # grammar Cypress;
├── swift/
│   └── Swift.g4      # grammar Swift;
└── kotlin/
    └── Kotlin.g4     # grammar Kotlin;
```

By adhering to these conventions, the automated Docker build will locate the grammar files, generate the corresponding Go lexer/parser, and compile the `grammar-execution` tool seamlessly.
