include("soberania_absoluta.jl")
#!/usr/bin/env julia

using Pkg
println("Checking and installing script dependencies...")
Pkg.activate(temp=true)
Pkg.add(["CSV", "DataFrames"])

using CSV, DataFrames, Dates

ENV["PYTHONHASHSEED"] = "0"

const INPUT_FASTA   = "CHAPTER3/Repset/repset.fasta"
const INPUT_TSV     = "CHAPTER3/ASV_table.txt"

const STAGING_DIR   = "./pic_inputs"
const OUTPUT_DIR    = "./pic_out"

rm(STAGING_DIR, force=true, recursive=true)
rm(OUTPUT_DIR, force=true, recursive=true)
mkpath(STAGING_DIR)
mkpath(OUTPUT_DIR)

# ------------------------------------------------------------------------------
# 1. PRE-FLIGHT CHECK (Validación de IDs)
# ------------------------------------------------------------------------------
println("[$(now())] INFO: Running Pre-flight Check...")

df_tsv = CSV.read(INPUT_TSV, DataFrame, delim=' ')
excel_ids = Set(string.(df_tsv[:, 1])) 

fasta_ids = Set{String}()
open(INPUT_FASTA, "r") do file
    for line in eachline(file)
        if startswith(line, ">")
            id = strip(replace(line, ">" => ""))
            push!(fasta_ids, id)
        end
    end
end

if excel_ids == fasta_ids
    total_asvs = length(excel_ids)
    println("[$(now())] SUCCESS: FASTA vs Table ID intersection = $total_asvs / $total_asvs (Full match).")
else
    error("CRITICAL: Pre-flight check failed!")
end

# ------------------------------------------------------------------------------
# 2. PREPARACIÓN DE ENTRADAS NATIVAS
# ------------------------------------------------------------------------------
const STAGED_TSV   = joinpath(STAGING_DIR, "ASV_table.txt")
const STAGED_FASTA = joinpath(STAGING_DIR, "repset.fasta")

CSV.write(STAGED_TSV, df_tsv, delim='\t')
cp(INPUT_FASTA, STAGED_FASTA, force=true)

# ------------------------------------------------------------------------------
# 3. AUTO-INSTALACIÓN VIA MINIFORGE (GITHUB MIRROR)
# ------------------------------------------------------------------------------
const CONDA_BIN = "/root/miniforge3/bin/conda"
const PICRUST_BIN = "/root/miniforge3/envs/picrust2/bin/picrust2_pipeline.py"

if !isfile(PICRUST_BIN)
    println("[$(now())] WARNING: PICRUSt2 environment not found. Initiating Miniforge deployment...")
    
    if !isfile(CONDA_BIN)
        println("[$(now())] INFO: Downloading Miniforge from GitHub Releases...")
        rm("miniforge.sh", force=true)
        # Descarga desde los servidores de contenido de GitHub, evadiendo el bloqueo de Anaconda
        run(`wget -q https://github.com -O miniforge.sh`)
        
        println("[$(now())] INFO: Installing Miniforge silently to /root/miniforge3...")
        run(`bash miniforge.sh -b -p /root/miniforge3`)
        rm("miniforge.sh", force=true)
    end
    
    println("[$(now())] INFO: Installing PICRUSt2 v2.6.3 via Bioconda channel...")
    run(`$CONDA_BIN create -n picrust2 -c bioconda picrust2=2.6.3 -y`)
end

# ------------------------------------------------------------------------------
# 4. EJECUCIÓN CONTROLADA DE PICRUST2
# ------------------------------------------------------------------------------
println("[$(now())] WARNING: Invoking PICRUSt2 pipeline...")

picrust_cmd = `$PICRUST_BIN -s $STAGED_FASTA -i $STAGED_TSV -o $OUTPUT_DIR -p 1 --hsp_method mp --max_nsti 2.0`

try
    run(picrust_cmd)
    println("[$(now())] SUCCESS: Pipeline finished. Results written to $OUTPUT_DIR")
catch e
    println("[$(now())] CRITICAL ERROR: Execution failed even after deployment.")
    rethrow(e)
end
