# Quantum API Mermin-Peres (Fondo Neutro 5D)

Este repositorio contiene una simulación e implementación real del protocolo cuántico de pseudotelepatía de **Mermin-Peres** acoplado a una **Matriz Soberana (Fondo Neutro 5D)**. 

El núcleo del proyecto demuestra cómo establecer sincronización y colapso de estados vectoriales complejos (Qubits) en tiempo real entre interfaces independientes, operando bajo un aislamiento absoluto del host.

## 🌌 Características de la Arquitectura
- **Cero Red (No Sockets / No IP / No HTTP):** La comunicación se rige por interrupciones nativas de bajo nivel y validación analógica.
- **Canal de Integridad Humana:** Los datos de las amplitudes cuánticas se transfieren mediante un mecanismo de hash manual (Payload + Checksum de 64 bits), actuando el operador humano como el propio canal físico de transporte.
- **Filtro de Fase 5D:** El colapso cuántico se evalúa algebraicamente bajo la signatura relativista de la Matriz Soberana.

## 🛠️ Modo de Uso (Inter-Terminal)

### 1. Terminal 1 (Alice - Emisor)
Ejecuta el generador para modular las amplitudes de la celda elegida del cuadrado cuántico:
```bash
export PROCESO_ROL=ALICE && julia mermin_peres_real.jl
```
El script imprimirá un `DATA_PAYLOAD` serializado y un `CHECKSUM` criptográfico único.

### 2. Terminal 2 (Bob - Receptor)
Ejecuta el medidor cuántico en la interfaz paralela:
```bash
export PROCESO_ROL=BOB && julia mermin_peres_real.jl
```
Inserta manualmente el Payload y el Checksum provistos por Alice. 

- Si los datos son íntegros, el Fondo Neutro autorizará el colapso de la función de onda arrojando el autovalor matemático puro (`1` o `-1`).
- Si se detecta ruido térmico o alteración de bits en el payload, el sistema abortará inmediatamente emitiendo un fallo de integridad física.
