import os
import plotly.graph_objects as go
import sys
import configparser

def parse_gcode(filepath):
    x, y, z = 0.0, 0.0, 0.0
    xs, ys, zs = [], [], []

    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith(('G0', 'G1')):
                if 'X' in line:
                    try:
                        x = float(line.split('X')[1].split()[0])
                    except:
                        pass
                if 'Y' in line:
                    try:
                        y = float(line.split('Y')[1].split()[0])
                    except:
                        pass
                if 'Z' in line:
                    try:
                        z = float(line.split('Z')[1].split()[0])
                    except:
                        pass
                xs.append(x)
                ys.append(y)
                zs.append(z)

    return xs, ys, zs

def detectar_anomalias(puntos, max_x, max_y, max_z, long_threshold):
    movimientos_normales = []
    movimientos_anomalos = []

    for i in range(1, len(puntos)):
        p1 = puntos[i - 1]
        p2 = puntos[i]

        distancia = ((p1[0] - p2[0]) ** 2 +
                     (p1[1] - p2[1]) ** 2 +
                     (p1[2] - p2[2]) ** 2) ** 0.5

        fuera_de_limites = (
            p2[0] > max_x or p2[1] > max_y or p2[2] > max_z
            or p2[0] < 0 or p2[1] < 0 or p2[2] < 0
        )

        if distancia > long_threshold or fuera_de_limites:
            movimientos_anomalos.append((p1, p2))
        else:
            movimientos_normales.append((p1, p2))

    return movimientos_normales, movimientos_anomalos

def graficar_3d(puntos, max_x, max_y, max_z, long_threshold, output_path):
    normales, anomalos = detectar_anomalias(puntos, max_x, max_y, max_z, long_threshold)

    fig = go.Figure()

    for p1, p2 in normales:
        fig.add_trace(go.Scatter3d(
            x=[p1[0], p2[0]],
            y=[p1[1], p2[1]],
            z=[p1[2], p2[2]],
            mode='lines',
            line=dict(color='blue', width=4),
            showlegend=False
        ))

    for p1, p2 in anomalos:
        fig.add_trace(go.Scatter3d(
            x=[p1[0], p2[0]],
            y=[p1[1], p2[1]],
            z=[p1[2], p2[2]],
            mode='lines',
            line=dict(color='red', width=6),
            showlegend=False
        ))

    fig.update_layout(
        title="Simulación de trayectorias G-Code",
        scene=dict(
            xaxis_title="X",
            yaxis_title="Y",
            zaxis_title="Z"
        )
    )

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    fig.write_html(output_path)
    print(f"Visualización guardada en {output_path}")

def leer_parametros(path):
    config = configparser.ConfigParser()
    config.read(path)
    max_x = float(config.get('PRINTER', 'MAX_X'))
    max_y = float(config.get('PRINTER', 'MAX_Y'))
    max_z = float(config.get('PRINTER', 'MAX_Z'))
    long_threshold = float(config.get('PRINTER', 'LONG_MOVE_THRESHOLD'))
    return max_x, max_y, max_z, long_threshold

if __name__ == "__main__":
    carpeta_tests = "tests"
    carpeta_resultados = os.path.join(carpeta_tests, "results")
    archivo_propiedades = os.path.join(carpeta_tests, "printer.properties")

    if not os.path.exists(archivo_propiedades):
        print(f"El archivo {archivo_propiedades} no existe.")
        sys.exit(1)

    max_x, max_y, max_z, long_threshold = leer_parametros(archivo_propiedades)

    archivos_gcode = [f for f in os.listdir(carpeta_tests) if f.lower().endswith('.gcode')]

    if not archivos_gcode:
        print("No se encontraron archivos .gcode en la carpeta tests.")
        sys.exit(1)

    if len(archivos_gcode) > 1:
        print("Error: Solo debe existir un archivo .gcode en la carpeta tests.")
        sys.exit(1)

    archivo = archivos_gcode[0]
    ruta_archivo = os.path.join(carpeta_tests, archivo)
    xs, ys, zs = parse_gcode(ruta_archivo)
    puntos = list(zip(xs, ys, zs))
    nombre = os.path.splitext(archivo)[0]
    salida = os.path.join(carpeta_resultados, f"{nombre}_visualizacion.html")
    graficar_3d(puntos, max_x, max_y, max_z, long_threshold, salida)

    # Crear archivo passed.log si el HTML fue generado
    os.makedirs(carpeta_resultados, exist_ok=True)
    ruta_passed = os.path.join(carpeta_resultados, "passed.log")
    with open(ruta_passed, 'w') as f:
        pass  # crea archivo vacío
    print(f"Archivo {ruta_passed} creado exitosamente.")
