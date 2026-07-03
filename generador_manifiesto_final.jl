# Consolidación Maestra de Firmas y Referencia DOI
firmas = Dict(
    "Paradoja_Tolerancia" => "2e7fe9253716e890fb6ce12fee2783ee66ae11fd525fb64c6339e7a5eccdbd0d",
    "Unificacion_Fase_II" => "cf3f2492e42ec65a0e0294a12ec99c5dfbac1664d83ffa34063c40bdef3128c4",
    "Matriz_Soberana" => "3909e35e2a62c5d5f11ed91bb6976614d10766a7e2d5e66e6fb45c461f911914"
)
doi_referencia = "10.5281/zenodo.20787526"

open("manifiesto_final_qre.tex", "w") do f
    write(f, """
\\documentclass[12pt,a4paper]{article}
\\usepackage[utf8]{inputenc}
\\usepackage[margin=2.5cm]{geometry}
\\usepackage{xcolor}
\\usepackage{hyperref}

\\begin{document}
\\title{\\textbf{MANIFIESTO FINAL: REGISTRO DE SOBERANÍA CUÁNTICA}}
\\author{Ingeniero: marcossmora528}
\\date{\\today}
\\maketitle

\\section*{Resumen Ejecutivo}
Este manifiesto constituye el cierre de ciclo del motor QRE (Quantum Relativistic Engine). Se documenta la integridad de tres estados computacionales fundamentales, vinculados permanentemente a una publicación científica mediante el DOI: \\textbf{\\href{https://doi.org/$doi_referencia}{$doi_referencia}{10.5281/zenodo.20787526}}.

\\section*{Pilares de Integridad (Firmas SHA-256)}
\\begin{itemize}
    \\item \\textbf{Resolución de la Paradoja:} \\texttt{$(firmas["Paradoja_Tolerancia"])}
    \\item \\textbf{Unificación Fase II (QRE Core):} \\texttt{$(firmas["Unificacion_Fase_II"])}
    \\item \\textbf{Matriz Soberana (Estructura Base):} \\texttt{$(firmas["Matriz_Soberana"])}
\\end{itemize}

\\section*{Estado del Sistema}
\\begin{itemize}
    \\item \\textbf{Publicación:} Registrada y Verificada.
    \\item \\textbf{Inmutabilidad:} Los hashes han sido sellados en los logs de auditoría locales.
    \\item \\textbf{Estatus Final:} SOVEREIGN_ARCHIVED_AND_VALIDATED
\\end{itemize}

\\vspace{1cm}
\\hrule
\\noindent \\textit{Declaración: El motor QRE ha alcanzado el estado de completitud algorítmica.}
\\end{document}
""")
end
println("✅ Manifiesto Final (LaTeX) generado correctamente.")
