using JSON

# Cargamos resultados y el sello (la huella digital)
data = JSON.parse(read("results.json", String))
hash_sello = strip(read("results.seal", String))

# Generamos el manifiesto con la Firma de Integridad
open("manifiesto_tep.tex", "w") do f
    write(f, """
\\documentclass[11pt,a4paper]{article}
\\usepackage[utf8]{inputenc}
\\usepackage{amsmath,amssymb}
\\usepackage[margin=2.5cm]{geometry}

\\begin{document}
\\title{Manifiesto TEP: Validación Científica}
\\author{Sistema de Auditoría Automática}
\\maketitle

\\section*{Resultados de la Simulación}
\\begin{itemize}
    \\item \\textbf{Tiempo de ejecución:} $(data["tiempo"]) segundos
    \\item \\textbf{Nonce:} $(data["nonce"])
    \\item \\textbf{Estado:} $(data["resultado"])
\\end{itemize}

\\section*{Certificación de Integridad (Sello Criptográfico)}
Para garantizar la autenticidad de estos datos, se ha generado una firma SHA-256 única. 
Si el hash de los datos originales no coincide con esta firma, los resultados han sido alterados.

\\textbf{Hash Oficial (Sello):}
\\vspace{0.3cm}
\\texttt{$hash_sello}

\\end{document}
""")
end
println("✅ Manifiesto listo para compilar con su Firma de Integridad.")
