using JSON

function procesar_pdf_fuerza_bruta()
    println("[Extractor] Ejecutando decodificación estructural del PDF...")
    
    # Usamos la herramienta nativa pdftotext para extraer caracteres en coordenadas planas
    run(`pdftotext -layout swampland_real.pdf texto_extraido.txt`)
    
    if !isfile("texto_extraido.txt")
        println("[Error] No se pudo procesar la capa visual del PDF.")
        return
    end
    
    lineas = readlines("texto_extraido.txt")
    matriz_cruda = Vector{Float64}[]
    
    for linea in lineas
        # Reemplazamos guiones largos de formato matemático y dividimos por espacios
        linea_limpia = replace(linea, "−" => "-", "—" => "-")
        tokens = split(linea_limpia, r"\s+")
        fila = Float64[]
        
        for token in tokens
            token_t = strip(token)
            if !isempty(token_t)
                val = tryparse(Float64, token_t)
                if val !== nothing
                    push!(fila, val)
                end
            end
        end
        
        # Filtramos para quedarnos únicamente con líneas que sean puramente matrices numéricas
        if length(fila) >= 4  # Ajusta este número según el tamaño mínimo de fila esperado
            push!(matriz_cruda, fila)
        end
    end
    
    if isempty(matriz_cruda)
        println("[Fallo OCR] El documento contiene imágenes puras sin capa de texto analizable.")
        return
    end
    
    # Empaquetamos en el JSON compatible con tu Engine de Auditoría
    open("matriz_ingestada.json", "w") do f
        JSON.print(f, Dict("matriz_raw" => matriz_cruda))
    end
    println("[Éxito] Estructura matricial de ", length(matriz_cruda), " filas extraída correctamente.")
end

procesar_pdf_fuerza_bruta()
