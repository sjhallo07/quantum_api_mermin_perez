module ProcesadorDocumentos

using PDFIO
using LinearAlgebra

export parsear_y_generar_matriz

# Función principal para detectar la extensión y procesar
function parsear_y_generar_matriz(ruta_archivo::String)
    if !isfile(ruta_archivo)
            println("[-] Error: El archivo no existe.")
                    return nothing
    end
    
    texto = ""
    if endswith(ruta_archivo, ".pdf")
        texto = extraer_texto_pdf(ruta_archivo)
            elseif endswith(ruta_archivo, ".md") || endswith(ruta_archivo, ".txt") || endswith(ruta_archivo, ".html")
        texto = read(ruta_archivo, String)
    else
        println("[-] Formato no soportado. Use .md, .txt o .pdf")
        return nothing
    end
    
    return extraer_numeros_y_crear_matriz(texto)
    end

# Extractor de texto para archivos PDF
function extraer_texto_pdf(ruta::String)
    texto_acumulado = ""
    try
        doc = pdDocOpen(ruta)
        n_paginas = pdDocGetPageCount(doc)
                for i in 1:n_paginas
            page = pdDocGetPage(doc, i)
            # Extrae el texto plano de la página actual
            texto_acumulado *= pdPageGetText(page) 
                    end
        pdDocClose(doc)
    catch e
        println("[-] Error leyendo el PDF: ", e)
    end
    return texto_acumulado
    end

# Busca números flotantes/enteros y los formatea en una matriz cuadrada
function extraer_numeros_y_crear_matriz(texto::String)
    println("[+] Analizando texto del documento...")
        
            # Expresión regular para capturar números (enteros, decimales y negativos)
                patron = r"[-+]?\b\d+\.?\d*\b"
                    coincidencias = eachmatch(patron, texto)
    
    numeros = Float64[]
    for m in coincidencias
            push!(numeros, parse(Float64, m.match))
    end
    
    total_elementos = length(numeros)
        if total_elementos == 0
        println("[-] No se encontraron datos numéricos en el documento.")
                return nothing
    end
    
    # Calcular la dimensión de la matriz cuadrada más grande posible
    n = floor(Int, sqrt(total_elementos))
        if n == 0
        println("[-] Elementos insuficientes para crear una matriz.")
                return nothing
    end
    
    elementos_necesarios = n * n
    numeros_finales = numeros[1:elementos_necesarios]
        
            # Construir la matriz de N x N
    matriz = reshape(numeros_finales, n, n)
    println("[✔] Matriz de ", n, "x", n, " generada exitosamente a partir del documento.")
        return matriz
end

end # module
