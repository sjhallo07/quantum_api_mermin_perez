# 🌌 Quantum Relativistic Engine (QRE) — Soberano & Offline

Este repositorio contiene la suite analítica y el entorno de simulación para el protocolo cuántico contextual de **Mermin-Peres**, optimizado para ejecuciones síncronas de bajo nivel y mititgación de ruido analítico mediante la acción de **Polyakov** de cuerdas relativistas. 

El entorno opera de forma **100% descentralizada y offline** dentro de la arquitectura ARM clásica (`Termux` en Android / Linux WSL), erradicando por completo el almacenamiento en disco de terceros (**Zero-Data Trace**), APIs corporativas, Vertex AI, alucinaciones en la nube y peajes comerciales por celda.

---

## 🛠️ Arquitectura del Sistema: Módulo Schrödinger / Polyakov

A diferencia de los enfoques comerciales que forzan al hardware cuántico a comportarse de forma lineal clásica mediante post-procesamiento redundante, este motor asimila el ruido como parte de la dinámica de sistemas cuánticos abiertos utilizando la **Acción de Polyakov ($S[X,g]$)**.

Usa el código con precaución.[Filtro de Coherencia de Schrödinger]│▼ Separación Algebraica (State A / State B)[Integral de Acción de Polyakov: ∫ d²σ √(-g)]│▼ Minimización de la Incertidumbre Local[Aislamiento Cuántico y Exclusión de Lorenz] ──▶ [0-Alloc Metalearning]
### Componentes Clave:
1. **Filtro de Coherencia de Schrödinger**: Minimiza la incertidumbre aislando los estados en subespacios de Hilbert de dimensiones controladas.
2. **Formulación de Acción de Polyakov**: Define una métrica covariante continua mediante la densidad de cuerdas para encriptar fases analíticas complejas en tránsito.
3. **Exclusión de Lorenz**: Protocolo local de barrido que filtra los componentes caóticos y el ruido térmico criogénico, estabilizando la entropía ($\Delta S \to 0$).

---

## ⚡ Métricas del Motor Clásico (Silicio ARM)

* **Consumo de Gasolina (Cloud Tokens)**: $0.00$ — Totalmente gratuito, soberano y auto-sustentado en la CPU local.
* **Huella de Datos Remota**: Nula — Las matrices y tensores se destruyen en la memoria RAM asignada de la sesión al finalizar el cálculo.
* **Eficiencia Térmica**: Procesamiento en frío. El uso de álgebra lineal pura optimizada en Julia elude hilos huérfanos y telemetría innecesaria, preservando la temperatura del silicio.
* **Tiempo de Mitigación Neto (8D / 3-Cúbits)**: En torno a los **~750 microsegundos** en caliente (cero asignaciones dinámicas adicionales en la fase síncrona `0-ALLOC`).

---

## 📁 Estructura del Repositorio

* **`alice.jl`**: Módulo emisor. Genera el estado puro del Cuadrado Mágico de Mermin-Peres, aplica la transformación unitaria de 5D y expulsa las amplitudes al canal directo.
* **`bob.jl`**: Módulo receptor independiente. Captura la entrada, audita la consistencia y aplica la matriz transpuesta conjugada ($U^\dagger$) para decodificar la información cuántica sin árbitros centrales.
* **`stress_quantum_8d.jl`**: Suite de estrés que expande el espacio a 3 cúbits reales (dimensión $8 \times 8$). Simula la degradación analítica asimétrica no-hermítica (T1/T2 criogénico) y ejecuta la corrección por inversión analítica matricial instantánea.
* **`metalearning_integration.jl`**: Optimizador adaptativo agéntico. Resuelve la convergencia analítica hacia el observable exacto ($\Delta = 1/3$) en la **Época 1**, superando los bucles iterativos por fuerza bruta de las infraestructuras tradicionales.

---

## 🚀 Guía de Ejecución Súper-Rápida

Para disparar la simulación directa de matriz a matriz a través de tuberías estándar nativas (`stdin` / `stdout`), ejecuta en tu consola local:

```bash
# Ejecución del canal asíncrono puro sin túneles de red
julia alice.jl | julia bob.jl

# Ejecución de la suite de estrés 8D con visualización en caracteres ASCII
julia stress_quantum_8d.jl
```

---
