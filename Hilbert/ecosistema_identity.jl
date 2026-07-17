# ============================================
# ECOSISTEMA IDENTITY – Matriz de Identidad Suprema
# Uso: include("Hilbert/ecosistema_identity.jl")
# ============================================
using NPZ, JSON, LinearAlgebra, SHA

# Cargar matriz y metadatos (ejecutado una sola vez)
const IDENTITY_MATRIX = NPZ.npzread("Hilbert/identity_matrix_130.npz")
const IDENTITY_METADATA = JSON.parsefile("Hilbert/identity_metadata.json")
const FIRMA_106 = Float64.(JSON.parsefile("qre_validation_core.json")["vector_probabilidades"])
const ENGINE_HASH_ESPERADO = bytes2hex(sha256(read("engine_instance.json")))

println("[EcosistemaIdentity] Matriz 130×130 y metadatos cargados.")

# Verifica que la matriz de identidad sea auténtica
function verificar_identidad()
    # Verificar firma
    if IDENTITY_MATRIX[1:106,1:106] ≈ Diagonal(FIRMA_106)
        println("✅ Firma cuántica intacta.")
    else
        println("❌ Firma cuántica CORRUPTA.")
        return false
    end

    # Verificar hash del motor
    if IDENTITY_METADATA["source_engine_hash"] == ENGINE_HASH_ESPERADO
        println("✅ Hash del motor coincide.")
    else
        println("❌ Hash del motor NO coincide.")
        return false
    end

    println("🔐 Identidad del ecosistema verificada con éxito.")
    return true
end

# Verifica si un PDF dado (por ruta) está registrado en los metadatos
function verificar_pdf(ruta_pdf::String)
    hash_actual = bytes2hex(sha256(read(ruta_pdf)))
    nombre = basename(ruta_pdf)
    clave_hash = replace(nombre, ".pdf" => "_hash")
    if haskey(IDENTITY_METADATA, clave_hash) &&
       IDENTITY_METADATA[clave_hash] == hash_actual
        println("✅ PDF '$nombre' auténtico.")
        return true
    else
        println("❌ PDF '$nombre' NO registrado o corrupto.")
        return false
    end
end

# Al cargar, verificar automáticamente (pero permitir desactivar)
if get(ENV, "ECOSYSTEM_SILENT", "false") != "true"
    verificar_identidad()
end
