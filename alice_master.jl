using LinearAlgebra

println("=============================================================")
println("👑   ALICE - EMISOR MASTER ROYAL (ALCANCE INTEGRADO)   👑")
println("=============================================================")

# Canal unificado en la memoria física compartida del teléfono que la PC lee por USB
const canal_fisico = "/sdcard/puerto_cuantico.raw"
const canal_respuesta = "/sdcard/puerto_respuesta.raw"

# DEFINICIÓN GLOBAL DE VARIABLES PARA EVITAR EL UNDEFVARERROR
tiempo_crudo = time()
f_fase = round(0.5 + (tiempo_crudo % 2.0), digits=2)
println("[Alice] Factor entrópico del procesador móvil: $f_fase")

# TU MATRIZ EXACTA
const MATRIZ_PROPIA_ALICE = Float64[
    -1.0*f_fase  0.0  0.0  0.0  0.0;
     0.0  1.0*f_fase  0.0  0.0  0.0;
     0.0  0.0  1.0*f_fase  0.0  0.0;
     0.0  0.0  0.0  1.0*f_fase  0.0;
     0.0  0.0  0.0  0.0  1.0*f_fase
]

const MATRIZ_DIRECCION_BOB = Float64[
     1.0   0.0  0.0   0.0  0.0;
     0.0  -1.0  0.0   0.0  0.0;
     0.0   0.0  1.5   0.0  0.0;
     0.0   0.0  0.0  -2.0  0.0;
     0.0   0.0  0.0   0.0  1.0
]

# Firma predictiva calculada globalmente para que Python pueda heredarla en el catch
traza_esperada = round(f_fase * 4.5, digits=2)
println("[Alice] Firma dinámica esperada en el ordenador: $traza_esperada")

try
    # Intento de inicialización nativa en Julia
    open(canal_respuesta, "w") do f write(f, "0.0") end

    println("[Julia] Proyectando sintonía cruzada en el espacio de estados...")
    operador_canal = MATRIZ_PROPIA_ALICE * MATRIZ_DIRECCION_BOB
    payload = join(vec(operador_canal), ",")

    open(canal_fisico, "w") do archivo
        write(archivo, payload * "\n")
    end
    
    println("\n🔎 [BÚSQUEDA ACTIVA] Escaneando la memoria local esperando el eco de Bob...")
    
    tiempo_inicio = time()
    contenedor_firma = [0.0]
    
    while true
        if isfile(canal_respuesta)
            contenido_res = strip(read(canal_respuesta, String))
            if contenido_res != "0.0" && !isempty(contenido_res)
                contenedor_firma = parse(Float64, contenido_res)
                break
            end
        end
        sleep(0.3)
        if time() - tiempo_inicio > 20.0
            error("Timeout en entorno nativo Julia.")
        end
    end
    
    firma_bob = contenedor_firma
    println("\n[Julia] ¡Firma del ordenador localizada en el canal!: $firma_bob")
    
    if round(firma_bob, digits=2) == traza_esperada
        println("✅ [Alice] SINTONÍA COMPLETADA: Canal seguro. Entrelazamiento nativo verificado.")
    else
        println("⚠️ [Alice] ALERTA DE SEGURIDAD: La firma devuelta no coincide con el cálculo.")
    end

catch e
    println("\n⚠️ [FALLBACK ACTIVADO] Redirigiendo de forma segura al motor Python de rescate...")
    alice_str = join(vec(MATRIZ_PROPIA_ALICE), ", ")
    bob_str = join(vec(MATRIZ_DIRECCION_BOB), ", ")
    
    python_code = """
import time, sys, os

try:
    A_list = [$alice_str]
    B_list = [$bob_str]
    A = [A_list[i:i+5] for i in range(0, 25, 5)]
    B = [B_list[i:i+5] for i in range(0, 25, 5)]
    
    operador_plano = []
    for i in range(5):
        for j in range(5):
            suma = sum(A[i][k] * B[k][j] for k in range(5))
            operador_plano.append(str(suma))
            
    payload = ",".join(operador_plano)
    
    # Python escribe directamente en el éter del almacenamiento compartido /sdcard/
    with open('$canal_fisico', 'w') as f:
        f.write(payload)
    print('[Fallback] Matriz inyectada con éxito en /sdcard/')
    
    print('[Fallback] Iniciando radar de BÚSQUEDA ACTIVA en almacenamiento...')
    start = time.time()
    firma = 0.0
    while True:
        try:
            with open('$canal_respuesta', 'r') as f:
                content = f.read().strip()
                if content and content != "0.0":
                    firma = float(content)
                    break
        except:
            pass
        time.sleep(0.3)
        if time.time() - start > 20.0:
            print('❌ [Fallback] Timeout crítico: El ordenador no ha respondido en /sdcard/.')
            sys.exit(1)
            
    print(f'\\n[Fallback] ¡Firma de respuesta localizada por Python!: {firma}')
    if round(firma, 2) == $traza_esperada:
        print('✅ [Fallback] SINTONÍA COMPLETADA CON ÉXITO: Ecosistema entrelazado.')
    else:
        print('⚠️ [Fallback] ALERTA: La firma mutada no coincide.')
except Exception as ex:
    print(f'❌ [Fallback] Error crítico interno: {ex}')
"""
    run(`python3 -c $python_code`)
end
