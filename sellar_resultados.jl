using SHA
using Printf

const FIRMA_HARDWARE = "-1.0|1.0|1.0|1.0|1.0"
const METRICAS_ESTADO = "0.44814735|7.20e-09"

function crear_sello_bloque()
    # Combinamos la matriz de hardware con las métricas cognitivas para el hash
    payload = FIRMA_HARDWARE * "||" * METRICAS_ESTADO
    hash_digital = bytes2hex(sha256(payload))
    
    @printf("✅ Sello creado con hash: %s\n", hash_digital)
end

crear_sello_bloque()
