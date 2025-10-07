#!/usr/bin/env bash
set -euo pipefail

# —————— CONFIGURACIÓN (pueden pasarse con -e al docker run) ——————
# ZIP_FILE y PROJECT_DIR ya no son necesarios ya que el proyecto se monta.
INNER_DIR=${INNER_DIR:-} # Directorio dentro del volumen montado donde realmente está el proyecto Android. Vacío si está en la raíz del montaje.
APK_REL=${APK_REL:-app/build/outputs/apk/debug/app-debug.apk}
PACKAGE=${PACKAGE:-com.example.budgetbuddy}
ACTIVITY=${ACTIVITY:-com.example.budgetbuddy.MainActivity}
ADB_HOST=${ADB_HOST:-host.docker.internal}
ADB_PORT=${ADB_PORT:-5555}
ANDROID_HOME=${ANDROID_HOME:-/sdk} # Esta es la ruta DENTRO del contenedor
# ————————————————————————————————————————————————————————————————

# --- Capturar el directorio de trabajo inicial dentro del contenedor (punto de montaje) ---
INITIAL_PWD_CONTAINER=$(pwd) # Ej: /app si WORKDIR es /app
RESULTS_DIR_IN_CONTAINER="$INITIAL_PWD_CONTAINER/results" # Ej: /app/results (se reflejará en el host)

# --- Inicializar Estados para el Informe ---
STATUS_COMPILACION="fallido"
STATUS_INSTALACION="fallido"
STATUS_EJECUCION="fallido"
ESTADO_PROCESO_GENERAL="fallido"
NOMBRE_ARCHIVO_JSON_RESULTADOS="resultados_despliegue.json"
NOMBRE_ARCHIVO_PASSED_LOG="passed.log"

# --- Función para generar el informe JSON y el archivo passed.log ---
generar_informe() {
  # Determinar el estado general del proceso
  if [ "$STATUS_COMPILACION" = "exitoso" ] && \
     [ "$STATUS_INSTALACION" = "exitoso" ] && \
     [ "$STATUS_EJECUCION" = "exitoso" ]; then
    ESTADO_PROCESO_GENERAL="exitoso"
  else
    ESTADO_PROCESO_GENERAL="fallido"
  fi

  # Asegurar que el directorio de resultados exista DENTRO del contenedor
  # Esto se reflejará en el host debido al montaje de volumen.
  mkdir -p "$RESULTS_DIR_IN_CONTAINER"

  local json_path="$RESULTS_DIR_IN_CONTAINER/$NOMBRE_ARCHIVO_JSON_RESULTADOS"
  local log_path="$RESULTS_DIR_IN_CONTAINER/$NOMBRE_ARCHIVO_PASSED_LOG"

  echo "Generando archivo de resultados en '$json_path' (dentro del contenedor)..."
  printf '{\n' > "$json_path"
  printf '  "compilacion": "%s",\n' "$STATUS_COMPILACION" >> "$json_path"
  printf '  "instalacion": "%s",\n' "$STATUS_INSTALACION" >> "$json_path"
  printf '  "ejecucion": "%s",\n' "$STATUS_EJECUCION" >> "$json_path"
  printf '  "estado_proceso_general": "%s"\n' "$ESTADO_PROCESO_GENERAL" >> "$json_path"
  printf '}\n' >> "$json_path"
  echo "Archivo JSON generado en '$json_path'."

  if [ "$ESTADO_PROCESO_GENERAL" = "exitoso" ]; then
    echo "Todos los pasos completados exitosamente. Creando '$log_path'..."
    touch "$log_path"
  else
    echo "El proceso no se completó exitosamente. Eliminando '$log_path' si existe."
    rm -f "$log_path"
  fi
}

# Registrar la función generar_informe para que se ejecute al salir del script
trap generar_informe EXIT

# --- Lógica Principal del Script ---

# Determinar la carpeta raíz del proyecto Android (APP_ROOT) dentro del contenedor
if [ -n "$INNER_DIR" ]; then
  APP_ROOT="$INITIAL_PWD_CONTAINER/$INNER_DIR"
else
  APP_ROOT="$INITIAL_PWD_CONTAINER"
fi

echo "[1] Carpeta del proyecto Android (APP_ROOT) configurada en: '$APP_ROOT' (dentro del contenedor)."
echo "[INFO] Los resultados se guardarán en '$RESULTS_DIR_IN_CONTAINER' (dentro del contenedor), que debería estar mapeado a una carpeta 'results' en tu host."

# Verificar que APP_ROOT exista antes de intentar usarla
if [ ! -d "$APP_ROOT" ]; then
  echo "❌ No se encontró la carpeta del proyecto en '$APP_ROOT'."
  echo "Asegúrate de que el volumen esté montado correctamente en '$INITIAL_PWD_CONTAINER' y que INNER_DIR ('$INNER_DIR') sea correcto (si se usa)."
  exit 1 # El trap se ejecutará aquí
fi

if [ ! -f "$APP_ROOT/gradlew" ]; then
  echo "❌ No se encontró 'gradlew' en '$APP_ROOT'. Verifica la estructura de tu proyecto y el montaje del volumen."
  exit 1
fi

echo "[2.1] Eliminando CRLF de gradlew y marcando ejecutable en '$APP_ROOT/gradlew'..."
# Es importante que $APP_ROOT sea la ruta correcta al directorio que contiene gradlew
sed -i 's/\r$//' "$APP_ROOT/gradlew" 2>/dev/null || true # Suprimir error si no hay CRLF
chmod +x "$APP_ROOT/gradlew"

echo "[2.2] Generando local.properties en '$APP_ROOT/local.properties' con sdk.dir=$ANDROID_HOME…"
cat > "$APP_ROOT/local.properties" <<EOF
sdk.dir=$ANDROID_HOME
EOF

# —————— COMPILACIÓN ——————
echo "[3] Cambiando al directorio del proyecto '$APP_ROOT'..."
cd "$APP_ROOT" # A partir de aquí, CWD (PWD) es la raíz del proyecto Android.

echo "[3.1] Compilando siempre con Gradle…"
# Si gradlew falla, set -e hará que el script salga y el trap se ejecute.
# STATUS_COMPILACION permanecerá "fallido".
bash gradlew assembleDebug

# Verificar que el APK exista después de la compilación
if [ ! -f "$APK_REL" ]; then # $APK_REL es relativo al CWD actual ($APP_ROOT)
  echo "❌ APK no generado. No se encontró en '$PWD/$APK_REL' después del intento de compilación."
  exit 1 # El trap se ejecutará aquí
fi
# Si llegamos aquí, la compilación fue exitosa y el APK existe.
STATUS_COMPILACION="exitoso"
echo "[4] APK listo en '$PWD/$APK_REL'"


# —————— DESPLIEGUE ADB ——————
echo "[5] Conectando ADB a $ADB_HOST:$ADB_PORT…"
adb kill-server
adb start-server
adb connect "$ADB_HOST:$ADB_PORT"
# El comando timeout tiene su propio estado de salida. set -e actuará sobre él.
# Si el timeout falla, el script sale, el trap se ejecuta. STATUS_INSTALACION/EJECUCION permanecerán "fallido".
timeout 30 bash -c \
  'until adb devices | grep -qE "^$ADB_HOST:$ADB_PORT[[:space:]]+device$"; do echo "Esperando conexión del emulador en $ADB_HOST:$ADB_PORT..."; sleep 1; done' \
  || { echo "❌ Emulador no conectado en $ADB_HOST:$ADB_PORT después de 30 segundos."; adb devices; exit 1; } # El trap se ejecutará aquí
echo "Conexión ADB establecida con $ADB_HOST:$ADB_PORT."

# Usamos "$PWD/$APK_REL" para pasar la ruta absoluta del APK a adb install (PWD es $APP_ROOT aquí).
echo "[6] Instalando APK desde '$PWD/$APK_REL'…"
# Si adb install falla, set -e hará que el script salga y el trap se ejecute.
# STATUS_INSTALACION permanecerá "fallido".
adb -s "$ADB_HOST:$ADB_PORT" install -r "$PWD/$APK_REL"
# Si llegamos aquí, la instalación fue exitosa.
STATUS_INSTALACION="exitoso"

echo "[7] Lanzando la app: $PACKAGE/$ACTIVITY…"
# Si adb shell am start falla, set -e hará que el script salga y el trap se ejecute.
# STATUS_EJECUCION permanecerá "fallido".
adb -s "$ADB_HOST:$ADB_PORT" shell am start -n "$PACKAGE/$ACTIVITY"
# Si llegamos aquí, el lanzamiento fue exitoso.
STATUS_EJECUCION="exitoso"

echo "✅ Despliegue completado."
# El script termina normalmente, el trap EXIT se ejecutará y generará el informe final.
# En este punto, todos los estados deberían ser "exitoso".