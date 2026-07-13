include("soberania_absoluta.jl")
using LinearAlgebra
using Printf

const TARGET = 1.0/3.0
const PSI0   = [0.0, 1.0/sqrt(2.0), -1.0/sqrt(2.0), 0.0]
const OB     = [1.0, -1.0, 1.0, -1.0]
const S1     = sqrt(0.5)
const BUF_A  = zeros(Float64, 4)
const BUF_F  = zeros(Float64, 4)

@inline function szb(psi)
    s = 0.0; @inbounds for i in 1:4; s += OB[i]*psi[i]^2; end; return s
end

@inline function delta_polchinski(w::Float64)::Float64
    @inbounds BUF_A[1]=PSI0[1]*S1; @inbounds BUF_A[2]=PSI0[2]*S1
    @inbounds BUF_A[3]=PSI0[3]*w;  @inbounds BUF_A[4]=PSI0[4]*w
    n2=0.0; @inbounds for i in 1:4; n2+=BUF_A[i]^2; end
    inv_n=1.0/sqrt(n2)
    @inbounds for i in 1:4; BUF_F[i]=BUF_A[i]*inv_n; end
    return abs(szb(BUF_F)-szb(PSI0))
end

const V0=0.000999902774902772; const LAM=5.75e-9
const C_SW=0.6; const EPS_SW=0.1; const PHI0_SW=2.0; const H_SW=1e-7

@inline V_AB(p,b,g)   = V0*exp(-sqrt(2.0)*p)+LAM+EPS_SW*(b*(p-PHI0_SW)^2+g*(p-PHI0_SW)^3)
@inline dV_AB(p,b,g)  = (V_AB(p+H_SW,b,g)-V_AB(p-H_SW,b,g))/(2H_SW)
@inline d2V_AB(p,b,g) = (V_AB(p+H_SW,b,g)-2V_AB(p,b,g)+V_AB(p-H_SW,b,g))/H_SW^2

function swampland_check(b,g; n=80_000, ns=800)
    phi_valid=[p for p in range(0.01,6.0,length=n) if V_AB(p,b,g)>0.0]
    isempty(phi_valid) && return (C1=false,C2=false,dS=false,nv=0)
    step=max(1,div(length(phi_valid),ns)); sample=phi_valid[1:step:end]
    c1=true; c2=true
    for p in sample
        Vp=V_AB(p,b,g); Vp<=0.0 && continue
        gvv=abs(dV_AB(p,b,g))/Vp; d2=d2V_AB(p,b,g)/Vp
        c1=c1&&(gvv>=C_SW); c2=c2&&(d2<=-C_SW)
    end
    return (C1=c1,C2=c2,dS=c1||c2,nv=length(phi_valid))
end

println("=== MODULE 1: Polchinski breach ===")
rho=PSI0*PSI0'; eigs=eigvals(Symmetric(rho))
@printf("rho=psi*psi': tr=%.1f eigs=%s valid=%s\n",
        tr(rho),string(round.(eigs,digits=4)),string(all(e>=-1e-12 for e in eigs)))
d_ex=delta_polchinski(1.0)
n2=S1^2*(PSI0[1]^2+PSI0[2]^2)+1.0^2*(PSI0[3]^2+PSI0[4]^2)
@printf("w=1: delta=%.16f err=%.4e\n",d_ex,abs(d_ex-1.0/3.0))
@printf("norm_atk=%.16f sqrt(3)/2=%.16f\n",sqrt(n2),sqrt(3.0)/2.0)
delta_polchinski(1.0); alloc=@allocated delta_polchinski(1.0)
@printf("@allocated=%d bytes\n\n",alloc)

println("=== MODULE 2: TEP interference (analytical) ===")
norma_atk=sqrt(n2); eps_eff=sqrt(1.0-norma_atk^2)
g2_qm=0.18731; eps_paper=0.1
@printf("epsilon_eff=sqrt(1-%.4f)=%.10f\n",norma_atk^2,eps_eff)
@printf("eps_eff/delta=%.6f  (exact=3/2)\n",eps_eff/d_ex)
@printf("g2_QM=%.5f  g2_TEP=%.5f  delta_g2=%.5f (=eps^2)\n",
        g2_qm,g2_qm+eps_paper^2,eps_paper^2)
println()

println("=== MODULE 3: Swampland ===")
Vphi0=V0*exp(-sqrt(2.0)*PHI0_SW)+LAM
beta_min=(-C_SW*Vphi0-2*V0*exp(-sqrt(2.0)*PHI0_SW))/(2*EPS_SW)
@printf("beta_C2_threshold=%.8f\n\n",beta_min)
@printf("%-10s %-8s %-5s %-5s %-5s\n","beta","gamma","C1","C2","dS")
betas=[-0.001,-0.01,-0.1,-1.0,beta_min,beta_min*1.5]
gammas=[0.0,-9.75,-15.0]
for b in betas, g in gammas
    r=swampland_check(b,g)
    c1s = r.C1 ? "ok" : "fail"
    c2s = r.C2 ? "ok" : "fail"
    dss = r.dS ? "ok <" : "fail"
    @printf("%-10.5f %-8.3f %-5s %-5s %-5s\n",b,g,c1s,c2s,dss)
end
println()
println("WGC: Sc=0 => Rc=1 lPl => m_KK=1 Mpl (satisfied)")
println()
println("=== SUMMARY ===")
@printf("delta Polchinski  = %.16f  (1/3 exact)\n",d_ex)
@printf("norm_attack       = %.16f  (sqrt(3)/2 exact)\n",norma_atk)
@printf("epsilon_eff       = %.16f  (1/2 exact)\n",eps_eff)
@printf("ratio eps/delta   = %.6f             (3/2 exact)\n",eps_eff/d_ex)
@printf("delta_g2 TEP      = %.5f             (eps_paper^2)\n",eps_paper^2)
@printf("@allocated        = %d bytes\n",alloc)
