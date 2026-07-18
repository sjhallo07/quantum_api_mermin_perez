# ============================================
# ECOSISTEMA IDENTITY – Matriz de Identidad Suprema
# Uso: include("Hilbert/ecosistema_identity.jl")
# ============================================
include("identity_pure.jl")          # immutable ENGINE_HASH and verificar_firma_pura
include("../mi_matriz_propia.jl")    # loads IDENTITY_MATRIX, FIRMA_106, etc.

const IDENTITY_MATRIX = MI_MATRIZ_IDENTIDAD
const IDENTITY_METADATA = MI_METADATA_IDENTIDAD
const FIRMA_106 = MI_FIRMA_106
const ENGINE_HASH_ESPERADO = ENGINE_HASH   # from identity_pure.jl

println("[EcosistemaIdentity] Matriz 130×130 y metadatos cargados.")

function verificar_identidad()
    if IDENTITY_MATRIX[1:106,1:106] ≈ Diagonal(FIRMA_106)
        println("✅ Firma cuántica intacta.")
    else
        println("❌ Firma cuántica CORRUPTA.")
        return false
    end

    if IDENTITY_METADATA["source_engine_hash"] == ENGINE_HASH_ESPERADO
        println("✅ Hash del motor coincide (inmutable).")
    else
        println("❌ Hash del motor NO coincide.")
        return false
    end

    println("🔐 Identidad del ecosistema verificada con éxito.")
    return true
end

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

if get(ENV, "ECOSYSTEM_SILENT", "false") != "true"
    verificar_identidad()
end
