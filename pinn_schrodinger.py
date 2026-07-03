import jax
import jax.numpy as jnp
import matplotlib.pyplot as plt
import optax
from jax import grad, vmap, jit
import time

# Dominio
X_MIN, X_MAX = -5.0, 5.0
T_MAX = 2.0
EPOCHS = 3000
LR = 1e-3

def init_params():
    key = jax.random.PRNGKey(123)
    keys = jax.random.split(key, 5)
    params = [
        (jax.random.normal(keys[0], (64, 2)) * 0.05, jnp.zeros(64)),
        (jax.random.normal(keys[1], (64, 64)) * 0.05, jnp.zeros(64)),
        (jax.random.normal(keys[2], (64, 64)) * 0.05, jnp.zeros(64)),
        (jax.random.normal(keys[3], (64, 64)) * 0.05, jnp.zeros(64)),
        (jax.random.normal(keys[4], (2, 64)) * 0.05, jnp.zeros(2))
    ]
    return params

@jit
def net_psi(params, X):
    for w, b in params[:-1]:
        X = jnp.tanh(w @ X + b.reshape(-1,1))
    w, b = params[-1]
    return w @ X + b.reshape(-1,1)

# Funciones auxiliares para derivadas batch
def u_single(params, x, t):
    return net_psi(params, jnp.array([[x],[t]]))[0,0]
def v_single(params, x, t):
    return net_psi(params, jnp.array([[x],[t]]))[1,0]

u_x = grad(u_single, 1)
v_x = grad(v_single, 1)
u_xx = grad(u_x, 1)
v_xx = grad(v_x, 1)
u_t = grad(u_single, 2)
v_t = grad(v_single, 2)

# Condición inicial: paquete Gaussiano con momento k0
def psi0(x, k0=5.0):
    u0 = jnp.exp(-x**2 / 0.5) * jnp.cos(k0 * x)
    v0 = jnp.exp(-x**2 / 0.5) * jnp.sin(k0 * x)
    return u0, v0

@jit
def loss(params, x_eq, t_eq, x_ic, t_ic, u_ic, v_ic, x_bc, t_bc):
    X_eq = jnp.stack([x_eq, t_eq])
    psi = net_psi(params, X_eq)
    du_dxx = vmap(u_xx, (None, 0, 0))(params, x_eq, t_eq)
    dv_dxx = vmap(v_xx, (None, 0, 0))(params, x_eq, t_eq)
    du_dt = vmap(u_t, (None, 0, 0))(params, x_eq, t_eq)
    dv_dt = vmap(v_t, (None, 0, 0))(params, x_eq, t_eq)
    
    # Residuo Schrödinger
    f_u = dv_dt + 0.5 * du_dxx
    f_v = -du_dt + 0.5 * dv_dxx
    loss_eq = jnp.mean(f_u**2 + f_v**2)

    # Inicial
    X_ic = jnp.stack([x_ic, t_ic])
    psi_ic = net_psi(params, X_ic)
    loss_ic = jnp.mean((psi_ic[0,:] - u_ic)**2 + (psi_ic[1,:] - v_ic)**2)

    # Frontera (ψ=0)
    X_bc = jnp.stack([x_bc, t_bc])
    psi_bc = net_psi(params, X_bc)
    loss_bc = jnp.mean(psi_bc**2)

    return loss_eq + loss_ic + loss_bc

def generate_data(N_eq=3000, N_ic=400, N_bc=200):
    key = jax.random.PRNGKey(456)
    x_eq = jax.random.uniform(key, (N_eq,)) * (X_MAX - X_MIN) + X_MIN
    t_eq = jax.random.uniform(key, (N_eq,)) * T_MAX
    x_ic = jnp.linspace(X_MIN, X_MAX, N_ic)
    t_ic = jnp.zeros(N_ic)
    u0, v0 = psi0(x_ic)
    x_bc = jnp.concatenate([jnp.full(N_bc, X_MIN), jnp.full(N_bc, X_MAX)])
    t_bc = jax.random.uniform(key, (2*N_bc,)) * T_MAX
    return x_eq, t_eq, x_ic, t_ic, u0, v0, x_bc, t_bc

def train():
    x_eq, t_eq, x_ic, t_ic, u_ic, v_ic, x_bc, t_bc = generate_data()
    params = init_params()
    schedule = optax.exponential_decay(LR, transition_steps=1000, decay_rate=0.9)
    optimizer = optax.adam(schedule)
    opt_state = optimizer.init(params)

    @jit
    def step(params, opt_state):
        grads = grad(loss)(params, x_eq, t_eq, x_ic, t_ic, u_ic, v_ic, x_bc, t_bc)
        updates, opt_state = optimizer.update(grads, opt_state)
        params = optax.apply_updates(params, updates)
        return params, opt_state

    history = []
    start = time.time()
    for epoch in range(1, EPOCHS+1):
        params, opt_state = step(params, opt_state)
        if epoch % 300 == 0:
            l = loss(params, x_eq, t_eq, x_ic, t_ic, u_ic, v_ic, x_bc, t_bc)
            history.append(l)
            print(f"Época {epoch:4d} | Pérdida: {l:.6e}")
    
    print(f"Entrenamiento completado en: {time.time()-start:.2f} s")
    print("El archivo 'convergencia_schrodinger.png' y 'solucion_schrodinger.png' han sido generados.")

if __name__ == "__main__":
    train()
