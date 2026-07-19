include("Hilbert/mi_matriz_propia.jl")
module Ecosistema
using ..Main: RoyalMatrixEnvironment, ejecutar_api_soberana
const ECO_30Q_SABER = RoyalMatrixEnvironment("Marcos Alejandro Mora Abreu", "V-14915920", "ROYAL MATRIX", 5368709120, true, true)
function inicializar_campo_30q()
    dv, Sc, Ss, tp, validado = ejecutar_api_soberana(ECO_30Q_SABER)
    return validado
end
end
