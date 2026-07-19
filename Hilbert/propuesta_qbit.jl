# ====================================================================
# PROPUESTA FORMAL: TIPO DE DATOS QBIT / QDIT (nLab GEOMETRIC QUANTIZATION)
# ====================================================================
struct QuantumDataType
    denominacion::String; dimension_espacio::Int64; clase_chern::Int; tag_soberano::String
end
const QBIT_NATIVO = QuantumDataType("QBit Standard", 2, 1, "ROYAL MATRIX")
const QDIT_NATIVO = QuantumDataType("QDit Expandido (30Q)", 5368709120, 1, "ROYAL MATRIX")
