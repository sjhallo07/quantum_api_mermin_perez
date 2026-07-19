# ====================================================================
# PIPELINE DE CONTROL: CIRCUITO CUÁNTICO CATEGÓRICO Y MEDICIÓN (nLab)
# ====================================================================
struct CircuitoCuanticonLab
    propietario_legal::String; cedula_identidad::String; tag_soberano::String
    dimension_krylov::Int64; es_reversible::Bool
end
const CIRCUITO_30Q_ASUS = CircuitoCuanticonLab("Marcos Alejandro Mora Abreu", "V-14915920", "ROYAL MATRIX", 5368709120, false)
