using OpenQuantumBase, Test

A = (s) -> (1 - s)
B = (s) -> s
u = [1.0 + 0.0im, 1] / sqrt(2)
ρ = u * u'

H = DenseHamiltonian([A, B], [σx, σz])

@test size(H) == (2, 2)
@test H(0) == 2π * σx
@test evaluate(H, 0) == σx
@test H(0.5) == π * (σx + σz)
@test evaluate(H, 0.5) == (σx + σz) / 2
@test get_cache(H) ≈ π * (σx + σz)

# update_cache method
C = similar(σz)
update_cache!(C, H, 10, 0.5)
@test C == -1im * π * (σx + σz)

# update_vectorized_cache method
C = get_cache(H)
C = C⊗C
update_vectorized_cache!(C, H, 10, 0.5)
temp = -1im * π * (σx + σz)
@test C == σi ⊗ temp - transpose(temp) ⊗ σi

# in-place update for matrices
du = [1.0 + 0.0im 0; 0 0]
H(du, ρ, 2, 0.5)
@test du ≈ -1.0im * π * ((σx + σz) * ρ - ρ * (σx + σz))

# eigen-decomposition
w, v = eigen_decomp(H, 0.5)
@test w ≈ [-1, 1] / sqrt(2)
w, v = eigen_decomp(H, 0.0)
@test w ≈ [-1, 1]
@test v ≈ [-1 1; 1 1] / sqrt(2)
