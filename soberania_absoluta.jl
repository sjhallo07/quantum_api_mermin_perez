using .Ecosistema
module SoberaniaCuantica
    using ..Ecosistema
    using LinearAlgebra
    using Distributions

    function validar_estado_base()
        # Usamos el ancla del Ecosistema
        media_teorica = Ecosistema.GL * Ecosistema.IDENTIDAD_8X8
        media_actual = mean(Ecosistema.DISTRIBUCION_BASE)
        
        if isapprox(media_actual, media_teorica, atol=1e-1)
            println("✅ [Soberanía]: Distribución Wishart alineada con Ecosistema.")
            return true
        else
            error("🚨 [Alerta]: Desviación detectada.")
        end
    end
end
