# Docker Image for ANTLR Grammars

This repository provides a generic Docker image for generating and running ANTLR-based parsers in Go (or any other supported language target). With a single build you can produce language-specific parser images simply by supplying the grammar directory and entry rule.

---

> ⚠️ Before you begin, make sure you have read the [instructions](./antlr-grammars/README.md) for adding a new grammar.

## 1. Build a New Grammar Image

1. Clone or `cd` into the root of this repo.  
2. (Optional) Review any language-specific notes under `antlr-grammars/<GRAMMAR_DIR>/README.md`.  
3. Run:

   ```bash
   docker build \
     -f Dockerfile.grammar \
     -t <IMAGE_NAME> \
     --build-arg GRAMMAR_DIR="<GRAMMAR_DIR>" \
     --build-arg ROOT_RULE="<ROOT_RULE>" \
     .
   ```

   - **IMAGE_NAME**: e.g. `cypress-grammar`, `swift-grammar`, `kotlin-grammar`.  
   - **GRAMMAR_DIR**: subfolder inside `antlr-grammars/` (lowercase), e.g. `cypress`, `kotlin`.  
   - **ROOT_RULE**: entry-point parser rule (case-sensitive), e.g. `FileSpec`, `KotlinFile`, `Expression`.  

   > **IMPORTANT:** `ROOT_RULE` **must** be capitalized to match the Go parser constructor (`New<ROOT_RULE>Parser`), even if your `grammar` declaration in the `.g4` file is lowercase.

   **Example:**

   ```bash
   docker build \
     -f Dockerfile.grammar \
     -t cypress-grammar \
     --build-arg GRAMMAR_DIR="cypress" \
     --build-arg ROOT_RULE="FileSpec" \
     .
   ```

---

## 2. Run Your Grammar Image

```bash
docker run --rm -it \
  -v /path/on/host/:/mnt/tests/ \
  -e DIRECTORY_PATH="<DIRECTORY_PATH>" \
  -e FILES_DIR="<RELATIVE_PATH>" \
  -e FILE_EXT="<FILE_EXTENSION>" \
  <IMAGE_NAME>
```

> ⚠️ `/path/on/host` must be a directory on you local machine where you have stored the testing files

| Environment Variable | Description                                                                                           |
| -------------------- | ----------------------------------------------------------------------------------------------------- |
| `DIRECTORY_PATH`     | Top-level folder (or archive name) under `/mnt/tests/` containing your test files. This is the root of the `.zip` file that would be fetched from the FTP server.                     |
| `FILES_DIR`          | Path inside `DIRECTORY_PATH` to scan for source files (use `.` for root of that folder)               |
| `FILE_EXT`           | File extension (or substring) to match target files, e.g. `cy.js`, `kt`, `swift`. **Please note that the first `.` must be omitted.**                     |

> The container mounts your host directory at `/mnt/tests/` and will:
>
> 1. `cd /mnt/tests/$DIRECTORY_PATH`  
> 2. Scan `$FILES_DIR` for files matching `*.$FILE_EXT`  
> 3. Parse them  
> 4. Write `results/parse_results.json` and, if all passed, `results/passed.log`

**Example:**

```bash
docker run --rm -it \
  -v /tmp/:/mnt/tests/ \
  -e DIRECTORY_PATH="my-tests" \
  -e FILES_DIR="cypress/e2e" \
  -e FILE_EXT="cy.js" \
  cypress-grammar
```

- Finds `*.cy.js` under `/tmp/my-tests/cypress/e2e`  
- Outputs `/tmp/my-tests/results/parse_results.json` (+ `passed.log` if no errors)

---

## 3. Directory Layout

```txt
.
├── Dockerfile.grammar        # Generic build definition
├── entrypoint.sh             # Dynamic entrypoint script
├── parser.template.go        # Go parser template with placeholders
├── main.go                   # CLI driver logic
├── utils.go                  # File discovery & result writing
└── antlr-grammars/           # Subdirectories of language grammars
    ├── cypress/              # example grammar folder
    │   └── Cypress.g4        # first line: grammar Cypress;
    ├── kotlin/
    │   └── Kotlin.g4         # first line: grammar Kotlin;
    └── swift/
        └── Swift.g4          # first line: grammar Swift;
```

---

## 4. Troubleshooting

- **Legacy builder warning**: You can install Docker BuildKit with  

  ```bash
  docker buildx create --use
  ```

- **Undefined symbols (`_modeStack`, `popMode`)**: Ensure you generate grammars with the same ANTLR version (4.13.1) used by the Go runtime.
