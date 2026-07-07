using LinearAlgebra
using Printf

const TARGET = 1.0 / 3.0
const PSI0 = [0.0, 1.0/sqrt(2.0), -1.0/sqrt(2.0), 0.0]
const OB   = [1.0, -1.0, 1.0, -1.0]
const S1   = sqrt(0.5)
const BUF_A = zeros(Float64, 4)
const BUF_F = zeros(Float64, 4)

@inline function szb(psi::Vector{Float64})::Float64
    s = 0.0
    @inbounds for i in 1:4; s += OB[i] * psi[i]^2; end
    return s
end

@inline function delta_polchinski(w::Float64)::Float64
    @inbounds BUF_A[1] = PSI0[1] * S1
    @inbounds BUF_A[2] = PSI0[2] * S1
    @inbounds BUF_A[3] = PSI0[3] * w
    @inbounds BUF_A[4] = PSI0[4] * w
    n2 = 0.0
    @inbounds for i in 1:4; n2 += BUF_A[i]^2; end
    inv_n = 1.0 / sqrt(n2)
    @inbounds for i in 1:4; BUF_F[i] = BUF_A[i] * inv_n; end
    return abs(szb(BUF_F) - szb(PSI0))
end

function density_check()
    rho  = PSI0 * PSI0'
    eigs = eigvals(Symmetric(rho))
    @printf("rho=psi*psi': tr=%.1f eigs=%s valid=%s\n",
            tr(rho), string(round.(eigs,digits=4)),
            string(all(e >= -1e-12 for e in eigs)))
end

function polchinski_exacto()
    d = delta_polchinski(1.0)
    n2 = S1^2*(PSI0[1]^2+PSI0[2]^2) + 1.0^2*(PSI0[3]^2+PSI0[4]^2)
    @printf("w=1: delta=%.16f target=%.16f err=%.4e\n",
            d, 1.0/3.0, abs(d-1.0/3.0))
    @printf("norm_atk=%.16f sqrt(3)/2=%.16f err=%.4e\n",
            sqrt(n2), sqrt(3.0)/2.0, abs(sqrt(n2)-sqrt(3.0)/2.0))
end

function rsi(w0, lr, max_ep)
    w = w0; h = 1e-7
    @printf("ep    w               delta           loss            grad\n")
    for ep in 1:max_ep
        d  = delta_polchinski(w)
        dp = delta_polchinski(w+h)
        loss = (d-TARGET)^2
        grad = 2.0*(dp-TARGET)*(dp-d)/h
        w -= lr*grad
        w  = clamp(w, 0.0, 2.0)
        @printf("%-5d %-15.10f %-15.10f %-15.8e %-15.8e\n", ep, w, d, loss, grad)
        loss < 1e-14 && (println("converged ep=$ep"); break)
    end
    return w
end

println("=== polchinski_real.jl ===")
density_check()
polchinski_exacto()
delta_polchinski(1.0)
alloc = @allocated delta_polchinski(1.0)
@printf("@allocated = %d bytes\n\n", alloc)
w_opt = rsi(1.0, 0.1, 30)
d_opt = delta_polchinski(w_opt)
@printf("result: w=%.12f delta=%.12f err=%.4e\n", w_opt, d_opt, abs(d_opt-TARGET))
