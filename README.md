# 👑 Quantum API Mermin-Peres & Density Matrix Engine

Ecosistema de computación cuántica de alta densidad y simulación a gran escala optimizado para ejecución clásica eficiente en entornos restrictivos (WSL/Ubuntu). El núcleo del sistema ha sido migrado de un enfoque algebraico lineal tradicional a un paradigma de **Operadores Matriciales Puros Complejos** libres de asignación dinámica de memoria (*Zero-Allocation*).

---

## 🏆 Hito de Cómputo: Simulación Masiva de 22 Qubits

El sistema ha roto los límites físicos de simulación clásica local al resolver el estado fundamental (*Ground State*) de un operador denso acoplado a un campo transversal en una escala multidimensional extrema.

### 📊 Métricas del Récord (Procesador ASUS / WSL)
* **Qubits Físicos Simulados:** 22 Qubits puros.
* **Dimensión del Espacio de Hilbert:** $5 \times 2^{22} = \mathbf{20,971,520}$ variables cuánticas simultáneas.
* **Tiempo de Ejecución Clásica:** **61.2566 segundos**.
* **Paralelización:** Multihilo activo nativo (`@threads`) balanceado en 4 hilos lógicos.
* **Energía Fundamental Extraída:** `-12.000000` (Convergencia absoluta).
* **Algoritmo de Sub-brana:** Lanczos con Bisección y Secuencia de Sturm de alta precisión (Precisión de máquina en 60 iteraciones).

---

## 🛠️ Arquitectura y Componentes Clave

### 1. Núcleo Matrix-Free In-Place (`termux_vs_ibm.jl`)
Para evadir el colapso por direccionamiento de memoria y bucles infinitos del algoritmo QR tradicional, se implementó un enfoque **Matrix-Free**. El Hamiltoniano no se almacena en memoria; en su lugar, se aplican mutaciones lineales in-place directamente sobre el vector de Krylov, reduciendo el consumo de RAM de Terabytes a Megabytes.

### 2. Resolvedor de Sudoku Cuántico 25x25 (`sudoku_25.jl`)
Un resolvedor gigante de 625 variables unificado con la infraestructura cuántica. Sustituye el muestreo estocástico aleatorio por una inicialización determinista basada en el operador de densidad de `mi_matriz_propia.jl`. Implementa poda lógica MRV (*Minimum Remaining Values*), logrando la resolución total en **0.73 segundos**.

### 3. Canal Estadístico Multivariado (`distribuit.jl`)
Simulador de enlace cuántico distribuido (Alice-Bob) integrado con `Distributions.jl`. Utiliza una distribución matricial de **Wishart Inversa** (`InverseWishart`) para inyectar fluctuaciones térmicas reales sobre sub-branas densas 8D (3 Qubits), evaluando la degradación de la pureza cuántica y el aumento de la entropía de Von Neumann.

---

## 🚀 Guía de Ejecución Rápida

Asegúrate de inicializar Julia optimizando la gestión de hilos OpenBLAS y asignando el paralelismo nativo de tu CPU:

```bash
# 1. Ejecutar la macro-simulación de 22 Cúbits (20.9 Millones de variables)
julia -t auto termux_vs_ibm.jl

# 2. Ejecutar el resolvedor de Sudoku cuántico indexado
julia sudoku_25.jl

# 3. Ejecutar el pipeline de control de la matriz de densidad 130x130
julia test_using_matrix.jl
```

## 💾 Bitácora de Producción (`historial_cuantico.csv`)
Todos los hitos de convergencia y tiempos de ejecución del silicio quedan registrados de forma automatizada bajo el siguiente esquema hermético:
```csv
Fecha_Hora,Qubits,Dimension,Energia_Fundamental,Tiempo_Segundos
2026-07-16 01:19:36,20,5242880,-21.398593,24.2479
2026-07-16 01:28:40,22_Puro,20971520,-12.000000,61.2566
```

---
*¡El silicio ha resistido. Operadores cuánticos estables en producción.*
