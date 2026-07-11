using LinearAlgebra

# Definición explícita de matrices
I_mat = ComplexF64[1 0; 0 1]
X_mat = ComplexF64[0 1; 1 0]

# Usamos la función kron nativa para evitar problemas de alcance
# El producto tensorial es kron(A, B)
# Estado |Φ⁺⟩
ket00 = ComplexF64[1, 0, 0, 0]
ket11 = ComplexF64[0, 0, 0, 1]
Phi_plus = (ket00 + ket11) / sqrt(2)

# Definimos los operadores de Alice y Bob
# X ⊗ I
O_Alice = kron(X_mat, I_mat)
# I ⊗ X
O_Bob   = kron(I_mat, X_mat)
# X ⊗ X
O_Conjunto = kron(X_mat, X_mat)

# Cálculos
valor_esperado = Phi_plus' * (O_Conjunto * Phi_plus)

println("Valor esperado ⟨Φ⁺| X⊗X |Φ⁺⟩: ", real(valor_esperado))
display(Phi_plus)
