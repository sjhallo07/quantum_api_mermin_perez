using LinearAlgebra
using Printf

const PSI0 = [0.0, 1.0/sqrt(2.0), -1.0/sqrt(2.0), 0.0]
const A_QRE = zeros(Float64, 4); const F_QRE = zeros(Float64, 4)
const A_COR = zeros(Float64, 4); const F_COR = zeros(Float64, 4)
const S1 = sqrt(0.5)

@inline function obs_qre(psi::Vector{Float64})::Float64
    @inbounds return psi[2]^2 + psi[4]^2
end
@inline function obs_cor(psi::Vector{Float64})::Float64
    @inbounds return psi[1]^2 - psi[2]^2 + psi[3]^2 - psi[4]^2
end
@inline function delta_qre(w::Float64)::Float64
    @inbounds A_QRE[1]=PSI0[1]; @inbounds A_QRE[2]=PSI0[2]
    @inbounds A_QRE[3]=PSI0[3]*w; @inbounds A_QRE[4]=PSI0[4]*w
    n2=0.0; @inbounds for i in 1:4; n2+=A_QRE[i]^2; end
    inv_n=1.0/sqrt(n2)
    @inbounds for i in 1:4; F_QRE[i]=A_QRE[i]*inv_n; end
    return abs(obs_qre(F_QRE)-obs_qre(PSI0))
end
@inline function delta_cor(w::Float64)::Float64
    @inbounds A_COR[1]=PSI0[1]*S1; @inbounds A_COR[2]=PSI0[2]*S1
    @inbounds A_COR[3]=PSI0[3]*w;  @inbounds A_COR[4]=PSI0[4]*w
    n2=0.0; @inbounds for i in 1:4; n2+=A_COR[i]^2; end
    inv_n=1.0/sqrt(n2)
    @inbounds for i in 1:4; F_COR[i]=A_COR[i]*inv_n; end
    return abs(obs_cor(F_COR)-obs_cor(PSI0))
end

function rsi(eval_fn, w0::Float64, target::Float64, lr::Float64, max_ep::Int, label::String)
    w=w0; h=1e-7; converged=false
    @printf("\n%s  w0=%.8f  target=%.10f\n", label, w0, target)
    @printf("%-4s  %-14s  %-14s  %-12s\n","ep","w","delta","loss")
    for ep in 1:max_ep
        d=eval_fn(w); dp=eval_fn(w+h)
        loss=(d-target)^2
        grad=2.0*(dp-target)*(dp-d)/h
        w-=lr*grad; w=clamp(w,0.0,2.0)
        @printf("%-4d  %-14.10f  %-14.10f  %-12.4e\n",ep,w,d,loss)
        if loss < 1e-14; converged=true; println("  converged ep=$ep"); break; end
    end
    d_final=eval_fn(w)
    @printf("  result: w=%.12f  delta=%.12f  err=%.4e  conv=%s\n",
            w,d_final,abs(d_final-target),string(converged))
    return w, d_final
end

println("=== metalearning_integration.jl ===\n")
delta_qre(0.44856123); delta_cor(1.0)
aq=@allocated delta_qre(0.44856123); ac=@allocated delta_cor(1.0)
@printf("@allocated: delta_qre=%d  delta_cor=%d bytes\n\n",aq,ac)

println("--- COMPARISON ---")
@printf("%-26s  %-16s  %-16s\n","property","original_QRE","corrected")
println("-"^60)
@printf("%-26s  %-16s  %-16s\n","operator","diag(1,1,w,w)","diag(s1,s1,1,1)")
@printf("%-26s  %-16s  %-16s\n","observable","|psi2|^2+|psi4|^2","<sz>_B via I2xsz")
@printf("%-26s  %-16.6f  %-16.6f\n","val_B_initial",obs_qre(PSI0),obs_cor(PSI0))
@printf("%-26s  %-16s  %-16s\n","solution_w","1/sqrt(5)~0.4472","1.0 exact")
@printf("%-26s  %-16.4e  %-16.4e\n","loss at solution",
        (delta_qre(1/sqrt(5))-1.0/3.0)^2,(delta_cor(1.0)-1.0/3.0)^2)
@printf("%-26s  %-16.4e  %-16.4e\n","loss at WEINBERG_INICIAL",
        (delta_qre(0.44856123)-0.332838)^2,(delta_cor(1.0)-1.0/3.0)^2)
println()

rsi(delta_qre, 0.44856123, 0.332838, 0.05, 20, "QRE_original")
rsi(delta_qre, 0.5,        1.0/3.0,  0.05, 20, "QRE_exact_target")
rsi(delta_cor, 1.0,        1.0/3.0,  0.10, 10, "corrected_szB")

println("\n--- KEY INSIGHT ---")
@printf("1/sqrt(5)      = %.12f  <- QRE solution\n", 1.0/sqrt(5.0))
@printf("w=1.0          = %.12f  <- corrected solution\n", 1.0)
@printf("both give delta=1/3 but via DIFFERENT operators and observables\n")
