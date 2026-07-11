using LinearAlgebra
using SHA

const I2 = [1.0 0.0; 0.0 1.0]
const X  = [0.0 1.0; 1.0 0.0]
const Z  = [1.0 0.0; 0.0 -1.0]
const Y  = [0.0 -1.0im; 1.0im 0.0]

const CuadradoMP = [
    (kron(X, I2), kron(I2, X), kron(X, X)),
    (kron(I2, Z), kron(Z, I2), kron(Z, Z)),
    (kron(X, Z),  kron(Z, X),  kron(Y, Y))
]

println("=== [BOB API V1.0] - SISTEMA INICIADO ===")
println("Uso: ACTION:POST|DATA:f,c|HASH:chk  o  ACTION:GET|RESOURCE:ops|COORD:f,c")
print("> ")
cmd = readline()

parts = split(cmd, '|')
action = split(parts[1], ':')[2]

if action == "POST"
    data = split(parts[2], ':')[2]
    chk  = split(parts[3], ':')[2]
    
    if bytes2hex(sha256(data)) == chk
        println("[200 OK] Integridad validada. Procesando cálculo...")
        f, c = parse.(Int, split(data, ','))
        
        # Álgebra lineal pura
        Fila_Alice = CuadradoMP[f][1] * CuadradoMP[f][2] * CuadradoMP[f][3]
        Columna_Bob = CuadradoMP[1][c] * CuadradoMP[2][c] * CuadradoMP[3][c]
        res = round(Int, real(tr(Fila_Alice * Columna_Bob) / 4))
        
        println("[RESULTADO] Medición colapsada: $res")
    else
        println("[403 FORBIDDEN] Integridad comprometida. Hash no coincide.")
    end

elseif action == "GET"
    res = split(parts[2], ':')[2]
    coord = parse.(Int, split(split(parts[3], ':')[2], ','))
    f, c = coord
    
    println("[200 OK] Extrayendo operadores para ($f, $c)...")
    println("Fila Alice operando: $(CuadradoMP[f])")
    println("Columna Bob operando: $(CuadradoMP[1][c]), $(CuadradoMP[2][c]), $(CuadradoMP[3][c])")
else
    println("[400 BAD REQUEST] Método desconocido.")
end
