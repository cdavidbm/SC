// =======================================================
// TUTORIAL COMPLETO DE SUPERCOLLIDER
// Guía exhaustiva de programación de audio
// =======================================================

// SECCIÓN 1: CONFIGURACIÓN INICIAL
// ==============================

// 1.1 Preparación del entorno de trabajo
(
s.boot;                    // Inicia el servidor de audio de SuperCollider
p = ProxySpace.push(s);    // Crea y activa un nuevo espacio de trabajo (ProxySpace)
p.fadeTime = 3;            // CrossFade
)

// SECCIÓN 2: REPRODUCCIÓN Y MONITOREO BÁSICO
// ========================================

// 2.1 Configuración de salida básica
~out.play;    // Activa la reproducción en los buses de hardware
~out.stop(4);

// 2.2 Ejemplos básicos de síntesis
// Oscilador sinusoidal simple en estéreo
~out = { SinOsc.ar([400, 445] * 0.8, 0, 0.2) };
// [400, 408]: frecuencias ligeramente diferentes para cada canal
// 0.8: factor de multiplicación para bajar la frecuencia
// 0.2: amplitud

// Generación de sonido más complejo con modulación aleatoria
~out = { SinOsc.ar([443, 600 - Rand(0,200)], 0, 0.2) };

// Combinación de resonador y oscilador
~out = {
    Resonz.ar(
        Saw.ar(40 + [0,0.2], 1),    // Onda sierra con ligero detune
        [1200, 1600],               // Frecuencias de resonancia
        0.1                         // Ancho de banda del filtro
    ) +
    SinOsc.ar(60 * [1,1.1], 0, 0.2) // Oscilador de baja frecuencia añadido
};

// Ruido rosa con paneo automático
~out = { Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(2)) };

// SECCIÓN 3: CONTROL DE PARÁMETROS
// ==============================

// 3.1 Control mediante argumentos
~out = { arg rate = 2; Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(rate)) };
~out.set(\rate, 30);    // Modifica el parámetro rate en tiempo real

// 3.2 Control de densidad de partículas
~out = { arg rate = 2; Pan2.ar(Dust.ar(2000, 0.2), LFClipNoise.kr(rate)) };
~out.set(\rate, 2);

// SECCIÓN 4: REFERENCIAS ENTRE PROXIES
// =================================

// 4.1 Modulación mediante LFO
~lfo = { LFNoise2.kr(30, 300, 500) };    // Oscilador de baja frecuencia con ruido
~out = { SinOsc.ar(~lfo.kr, 0, 0.15) };  // Usa el LFO para modular frecuencia

// 4.2 Modulación compleja
~out = {
    SinOsc.ar(
        ~lfo.kr * [1, 1.2],                  // Modulación de frecuencia estéreo
        0,
        0.1
    ) *
    Pulse.ar(~lfo.kr * [0.1, 0.125], 0.5)    // Modulación de amplitud
};

// 4.3 Modulación con múltiples fuentes
~lfo = {
    LFNoise1.kr(30, 40) +                    // Ruido de baja frecuencia
    SinOsc.kr(0.1, 0, 200, 500)             // Oscilador sinusoidal lento
};

// SECCIÓN 5: OPERACIONES MATEMÁTICAS
// ===============================

// 5.1 Operadores unarios
~lfo2 = { SinOsc.kr(0.5, 0, 600, 100) };
~lfo = ~lfo2.abs;    // Valor absoluto

// 5.2 Operadores binarios
~lfo3 = { LFTri.kr(0.5, 0, 80, 300) };    // Oscilador triangular
~lfo = ~lfo2 + ~lfo3;                      // Suma de señales

// 5.3 Operaciones complejas
~lfo = (~lfo3 / 50).sin * 200 + 500 * {
    LFTri.kr(
        ~lfo.kr * 0.0015,    // Modulación de frecuencia
        0,
        0.1 * ~lfo3.kr / 90,
        1
    )
};

// SECCIÓN 6: RETROALIMENTACIÓN
// =========================

// 6.1 Retroalimentación básica (delay de un buffer)
~out = {
    SinOsc.ar(
        [220, 330],                          // Frecuencias base
        ~out.ar(2).reverse * LFNoise2.kr(0.5, 4pi),  // Modulación de fase con feedback
        0.4                                  // Amplitud
    )
};

// 6.2 Retroalimentación con impulsos
~out = { Impulse.ar(1 ! 2) + (~out.ar(2) * 0.99) };

// 6.3 Ecuaciones diferenciales en SuperCollider
~out = {
    SinOsc.ar(
        Slope.ar(~out.ar) * MouseX.kr(1000, 18000, 1)
    ) * 0.1 +
    SinOsc.ar(100, 0, 0.1)
};

// SECCIÓN 7: CONTROL MÚLTIPLE
// ========================

// 7.1 Control mediante arrays
(
~out = { arg freqOffest;
    var ctl;
    ctl = Control.names(\array).kr(Array.rand(8, 400, 1000));
    Pan2.ar(
        Mix(SinOsc.ar(ctl + freqOffest, 0, 0.1 / 8)),
        LFNoise0.kr(2)
    )
};
)

// 7.2 Configuración de parámetros
~out.setn(\array, Array.exprand(8, 400, 2000));
~out.set(\freqOffest, rrand(300,200));
~out.map(\freqOffest, ~lfo);

// SECCIÓN 8: MEZCLA DE SEÑALES
// =========================

// 8.1 Mezcla directa
~out1 = { SinOsc.ar(600, 0, 0.1) };
~out2 = { SinOsc.ar(500, 0, 0.1) };
~out3 = { SinOsc.ar(400, 0, 0.1) };
~out = ~out2 + ~out1 + ~out3;

// 8.2 Mezcla mediante adición
~out = { SinOsc.ar(600, 0, 0.1) };
~out.add({ SinOsc.ar(500, 0, 0.1) });
~out.add({ SinOsc.ar(400, 0, 0.1) });

// SECCIÓN 9: SÍNTESIS GRANULAR
// =========================

// 9.1 Definición del grano
(
SynthDef("grain", { arg i_out = 0, pan;
    var env;
    env = EnvGen.kr(
        Env.perc(0.001, 0.003, 0.2),    // Envolvente muy corta
        doneAction: Done.freeSelf        // Libera el synth al terminar
    );
    Out.ar(
        i_out,
        Pan2.ar(
            FSinOsc.ar(Rand(1000,10000)),    // Frecuencia aleatoria
            pan
        ) * env
    )
}).send(s);
)

// 9.2 Generación de granos
(
t = Task({
    loop({
        s.sendMsg("/s_new", "grain", -1, 0, 0,
            \i_out, ~someInput.index,
            \pan, [1, 1, -1].choose * 0.2
        );
        [0.01, 0.02].choose.wait;
    })
});
)

// SECCIÓN 10: ESPACIOS MÚLTIPLES
// ===========================

// 10.1 Creación de espacios independientes
(
p = ProxySpace(s);
q = ProxySpace(s);

// Configuración del primer espacio
p.use({
    ~out = { Resonz.ar(~in.ar, ~freq.kr, 0.01) };
    ~in = { WhiteNoise.ar(0.5) };
    ~freq = { LFNoise2.kr(1, 1000, 2000) };
});

// Configuración del segundo espacio
q.use({
    ~in = { Dust.ar(20, 0.1) };
    ~out = { Resonz.ar(~in.ar * 450, ~freq.kr, 0.005) };
    ~freq = { LFNoise2.kr(1, 400, 2000) };
});
)

// SECCIÓN 11: GRABACIÓN
// ===================

// 11.1 Configuración de grabación
r = p.record(\out, "proxySpace.aiff");    // Prepara la grabación

// 11.2 Control de grabación
r.unpause;    // Inicia grabación
r.pause;      // Pausa grabación
r.close;      // Finaliza grabación

// SECCIÓN 12: LIMPIEZA Y FINALIZACIÓN
// ================================

// 12.1 Liberación de recursos
currentEnvironment.free;    // Libera todos los nodos proxy
~out.stop;                 // Detiene la reproducción
ProxySpace.pop;            // Restaura el entorno original

// 12.2 Comandos de mantenimiento
~out.clean;     // Limpia nodos no utilizados
p.clear;        // Limpia todo el espacio de trabajo