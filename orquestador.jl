include("soberania_absoluta.jl")
using HTTP
using JSON3
using LinearAlgebra
using Distributions

# 1. Cargar o emular el motor cuántico
if isfile("mermin_peres_real.jl")
    include("mermin_peres_real.jl")
else
    global I_m = ComplexF64[1 0; 0 1]; global X_m = ComplexF64[0 1; 1 0]
    global Y_m = ComplexF64[0 -im; im 0]; global Z_m = ComplexF64[1 0; 0 -1]
    global grid = Matrix{Matrix{ComplexF64}}(undef, 3, 3)
    grid[1,1]=kron(X_m, I_m); grid[1,2]=kron(I_m, X_m); grid[1,3]=kron(X_m, X_m)
    grid[2,1]=kron(I_m, Z_m); grid[2,2]=kron(Z_m, I_m); grid[2,3]=kron(Z_m, Z_m)
    grid[3,1]=kron(X_m, Z_m); grid[3,2]=kron(Z_m, X_m); grid[3,3]=kron(Y_m, Y_m)
end

# Endpoints
function api_normal(params)
    return Dict("status" => "success", "message" => "Procesamiento clasico estandar", "data" => params)
end

function api_cuantica(params)
    tipo = get(params, "tipo", "fila")
    idx = get(params, "idx", 1)
    if idx < 1 || idx > 3 return Dict("status" => "error", "message" => "Indice fuera de rango") end
    res = (tipo == "fila") ? grid[idx,1] * grid[idx,2] * grid[idx,3] : grid[1,idx] * grid[2,idx] * grid[3,idx]
    return Dict("status" => "quantum_ok", "tipo" => tipo, "idx" => idx, "resultado_real" => real(res))
end

function api_estadistica(params)
    mu = Float64(get(params, "media", 0.0))
    sigma = Float64(get(params, "desviacion", 0.1))
    return Dict("status" => "stats_ready", "ruido_simulado" => rand(Normal(mu, sigma)))
end

# Despachador (Router) con FIX de String
function request_handler(req::HTTP.Request)
    try
        # FIX: Forzamos la lectura del buffer como String antes de parsear el JSON
        raw_body = String(req.body)
        body = JSON3.read(raw_body)
        
        endpoint = body[:endpoint]
        payload = get(body, :payload, Dict())
        
        if endpoint == "normal"
            resp = api_normal(payload)
        elseif endpoint == "cuantico"
            resp = api_cuantica(payload)
        elseif endpoint == "estadistica"
            resp = api_estadistica(payload)
        else
            return HTTP.Response(404, JSON3.write(Dict("error" => "Endpoint no encontrado")))
        end
        
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))
    catch e
        return HTTP.Response(400, JSON3.write(Dict("error" => "Malformed JSON o Error Interno", "details" => string(e))))
    end
end

println("=========================================================================")
println("🚀 MÚSCULO COMPLETO ACTIVADO: Servidor corriendo en http://localhost:8080")
println("=========================================================================")
HTTP.serve(request_handler, "0.0.0.0", 8080)
