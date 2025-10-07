# Android Deployer Docker Container

This Docker container automates the process of **building, installing, and launching** an Android (Kotlin or Java) app directly from a mounted project directory. It uses `adb` to deploy the APK to an emulator or physical device via TCP.

---

## 🧩 Prerequisites

- **Docker** installed on your system.
- An **Android emulator or device** accessible via ADB over TCP (default port: 5555).
- A valid Android project with a `gradlew` script.

Example for enabling ADB over TCP:

```bash
adb devices                     # Check that your emulator/device is listed
adb -s <serial> tcpip 5555      # Enable TCP mode
adb connect <device-ip>:5555
adb devices                     # Should list <device-ip>:5555 as 'device'
```

---

## ⚙️ Build the Docker Image

```bash
docker build -t android-deployer .
```

This builds an image with:

* `openjdk:17-jdk-slim`
* Android SDK (command-line tools, build-tools 35.0.0, platform-tools)
* `adb`, `zip`, `unzip`, `bash`, and more
* The `deploy.sh` script that manages the build → install → launch flow

---

## 🚀 Run: Build and Deploy

```bash
docker run --rm -it \
  -e INNER_DIR="" \
  -e APK_REL="app/build/outputs/apk/debug/app-debug.apk" \
  -e PACKAGE="com.example.budgetbuddy" \
  -e ACTIVITY="com.example.budgetbuddy.MainActivity" \
  -e ADB_HOST="127.0.0.1" \
  -e ADB_PORT="5555" \
  -v "/path/to/your/project:/app" \
  android-deployer
```

* `/path/to/your/project` should contain your `gradlew` script.
* Use `INNER_DIR` only if your Android project is in a subdirectory inside the mounted volume.
* `APK_REL` is the relative path to the generated APK from the root of the project.

---

## 📄 Deployment Results

At the end of the process, the container will generate:

* `results/resultados_despliegue.json`: JSON report with the status of each step.
* `results/passed.log`: Empty file created only if all steps succeed.

These files are written to the `results/` folder inside the mounted project.

Example `resultados_despliegue.json`:

```json
{
  "compilacion": "exitoso",
  "instalacion": "exitoso",
  "ejecucion": "exitoso",
  "estado_proceso_general": "exitoso"
}
```

---

## 🌐 Environment Variables

| Variable    | Description                                                                  |
| ----------- | ---------------------------------------------------------------------------- |
| `INNER_DIR` | Subdirectory where the project is located (empty if it's at the root).       |
| `APK_REL`   | **Relative** path to the generated APK from the project root.                |
| `PACKAGE`   | Application package name.                                                    |
| `ACTIVITY`  | Fully-qualified main Activity class.                                         |
| `ADB_HOST`  | IP or hostname of the ADB-over-TCP target (default: `host.docker.internal`). |
| `ADB_PORT`  | TCP port where ADB is listening (default: `5555`).                           |

---

Happy deploying! 🚀
