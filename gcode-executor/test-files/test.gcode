; Inicia configuración
G21 ; Unidades en milímetros
G90 ; Posicionamiento absoluto
G28 ; Home en todos los ejes
G1 Z0.3 F300 ; Subir a altura inicial segura

; Imprimir base cuadrada (20x20 mm)
G1 X0 Y0 Z0.3 F1500
G1 X20 Y0 Z0.3 F1500
G1 X20 Y20 Z0.3 F1500
G1 X0 Y20 Z0.3 F1500
G1 X0 Y0 Z0.3 F1500 ; cerrar el perímetro base

; Subir capa por capa
G1 Z0.6 F300
G1 X20 Y0 Z0.6 F1500
G1 X20 Y20 Z0.6 F1500
G1 X0 Y20 Z0.6 F1500
G1 X0 Y0 Z0.6 F1500

G1 Z0.9 F300
G1 X20 Y0 Z0.9 F1500
G1 X20 Y20 Z0.9 F1500
G1 X0 Y20 Z0.9 F1500
G1 X0 Y0 Z0.9 F1500

; Repetir hasta 20 mm
; ...
; Aquí se podrían automatizar los bloques para cada capa (cada 0.3 mm de Z) hasta Z=20

; Cierre
G1 Z21 F300 ; Subir para finalizar
G1 X0 Y0 F1500
M84 ; Desactivar motores
