#!/bin/sh
set -e

PROJECT_PATH="$1"
npx kraken-node doctor
# Validar argumento
if [ -z "$PROJECT_PATH" ]; then
  echo "Debes pasar la ruta del proyecto Kraken como argumento"
  echo "Ejemplo:"
  echo "   docker run --rm -v /ruta/local/proyecto:/app/proyecto kraken-runner /app/proyecto"
  exit 1
fi

# Validar que la ruta exista
if [ ! -d "$PROJECT_PATH" ]; then
  echo "La ruta $PROJECT_PATH no existe o no es un directorio"
  exit 1
fi

cd "$PROJECT_PATH"

echo "Iniciando servidor gráfico virtual (Xvfb) en :99 ..."
Xvfb :99 -screen 0 1280x1024x24 &

# Esperar medio segundo a que arranque Xvfb
sleep 0.5

# Exportar display virtual
export DISPLAY=:99

echo "Ejecutando pruebas Kraken (modo headless + display virtual) en $PROJECT_PATH ..."
echo "-----------------------------------------------"

# Ejecutar Kraken y guardar log
HEADLESS=1 DISPLAY=:99 npx kraken-node run | tee kraken_output.txt

echo "-----------------------------------------------"
echo "✅ Pruebas finalizadas. Log guardado en $PROJECT_PATH/kraken_output.txt"
