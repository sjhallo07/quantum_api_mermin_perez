using LinearAlgebra

# Definición del sistema (La lógica del cuadrado)
I2 = [1 0; 0 1]; X = [0 1; 1 0]; Z = [1 0; 0 -1]; Y = [0 -1im; 1im 0]
CuadradoMP = [(kron(X,I2), kron(I2,X), kron(X,X)), (kron(I2,Z), kron(Z,I2), kron(Z,Z)), (kron(X,Z), kron(Z,X), kron(Y,Y))]

# Función de cálculo directo (El "Motor de la Realidad")
function calcular(f, c)
    Fila = CuadradoMP[f][1] * CuadradoMP[f][2] * CuadradoMP[f][3]
    Col = CuadradoMP[1][c] * CuadradoMP[2][c] * CuadradoMP[3][c]
    return round(Int, real(tr(Fila * Col) / 4))
end

# Secuencia de 10 turnos (Coordenadas predefinidas para probar)
secuencia_alice = [(1,1), (2,2), (3,3), (1,2), (2,1), (3,2), (1,3), (2,3), (3,1), (1,1)]
secuencia_bob =   [(2,3), (1,1), (2,2), (3,3), (1,2), (2,1), (3,2), (1,3), (2,3), (3,1)]

println("=== INICIANDO COMUNICACIÓN DETERMINISTA (10 TURNOS) ===")

for i in 1:10
    a_coord = secuencia_alice[i]
    b_coord = secuencia_bob[i]
    
    # Alice envía, Bob recibe y procesa
    res_a = calcular(a_coord[1], a_coord[2])
    res_b = calcular(b_coord[1], b_coord[2])
    
    println("Turno $i: Alice envia $(a_coord) -> Bob responde $(b_coord)")
    println("   -> Resultado Alice: $res_a | Resultado Bob: $res_b")
end
