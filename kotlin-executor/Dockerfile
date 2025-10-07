# Usa un JDK compatible con Gradle
FROM openjdk:17-jdk-slim

# 1. Dependencias mínimas
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      wget unzip zip android-tools-adb && \
    rm -rf /var/lib/apt/lists/*

# 2. Variables de entorno para SDK
ENV ANDROID_SDK_ROOT=/sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# 3. Descarga e instala las Command-Line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm /tmp/cmdline-tools.zip && \
    if [ -d "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" ]; then \
      mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest; \
    fi

# 4. Acepta licencias y descarga platform-tools, build-tools y platform
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
      "platform-tools" \
      "build-tools;35.0.0" \
      "platforms;android-35"

# Define donde estará el código de la app montada
ENV APP_PROJECT_DIR=/app
WORKDIR ${APP_PROJECT_DIR}

# 5. Copia tu script a una ubicación ESTABLE y dale permisos
COPY deploy.sh /usr/local/bin/deploy_app.sh
RUN sed -i 's/\r$//' /usr/local/bin/deploy_app.sh && chmod +x /usr/local/bin/deploy_app.sh

ENTRYPOINT ["/usr/local/bin/deploy_app.sh"]