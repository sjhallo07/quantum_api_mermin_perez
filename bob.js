const { spawn, execSync } = require('child_process');

// Auto-descubrimiento: encuentra la ruta exacta de Julia en tu sistema
const JULIA_PATH = execSync('which julia').toString().trim();

console.log(`[BOB] Julia detectada en: ${JULIA_PATH}`);

// Lanzar Julia
const alice = spawn(JULIA_PATH, ['alice.jl']);

const solicitud = {
    matriz: [[3, 3], [8, 3]],
    vector: [6, 6]
};

// Capturar respuesta
alice.stdout.on('data', (data) => {
    const resultado = JSON.parse(data.toString());
    console.log("[BOB] Resultado recibido:", resultado);
    alice.kill();
    process.exit(0);
});

// Enviar solicitud
alice.stdin.write(JSON.stringify(solicitud) + '\n');

// Manejo de errores
alice.stderr.on('data', (data) => {
    console.error(`[ALICE ERROR]: ${data}`);
});
