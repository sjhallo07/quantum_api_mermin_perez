const ENGINE_HASH = "e1526db067f2eaf63a2dbf8a34d703bb69724431700ad6136c39ac0df99e84de"

function verificar_firma_pura()
    diag_vals = [IDENTITY_MATRIX[i,i] for i in 1:106]
    if diag_vals == FIRMA_106
        println("✅ Firma cuántica intacta.")
        return true
    else
        println("❌ Firma cuántica CORRUPTA.")
        return false
    end
end
