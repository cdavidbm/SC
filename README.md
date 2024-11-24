# Notas de SuperCollider

## Guía de ProxySpace

---
1. [Configuración Inicial](#configuración-inicial)
2. [Reproducción y Monitoreo Básico](#reproducción-y-monitoreo-básico)
3. [Control de Parámetros](#control-de-parámetros)
4. [Referencias entre Proxies](#referencias-entre-proxies)
5. [Operaciones Matemáticas](#operaciones-matemáticas)
6. [Retroalimentación](#retroalimentación)
7. [Control Múltiple](#control-múltiple)
8. [Mezcla de Señales](#mezcla-de-señales)
9. [Síntesis Granular](#síntesis-granular)
10. [Espacios Múltiples](#espacios-múltiples)
11. [Grabación](#grabación)
12. [Limpieza y Finalización](#limpieza-y-finalización)
---

## Configuración Inicial

Inicia el servidor de audio y prepara un ProxySpace para trabajar:
```supercollider
(
s.boot;                    // Inicia el servidor de audio
p = ProxySpace.push(s);    // Crea y activa un nuevo ProxySpace
)
```

---

## Reproducción y Monitoreo Básico

### Configuración de salida básica
```supercollider
~out.play;    // Activa la reproducción en los buses de hardware
```

### Ejemplo: Oscilador sinusoidal en estéreo
```supercollider
~out = { SinOsc.ar([400, 408] * 0.8, 0, 0.2) };
```

### Generación de ruido con paneo automático
```supercollider
~out = { Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(2)) };
```

---

## Control de Parámetros

### Control mediante argumentos
```supercollider
~out = { arg rate = 2; Pan2.ar(PinkNoise.ar(0.1), LFClipNoise.kr(rate)) };
~out.set(\rate, 30);    // Modifica el parámetro rate en tiempo real
```

---

## Referencias entre Proxies

### Modulación mediante LFO
```supercollider
~lfo = { LFNoise2.kr(30, 300, 500) };
~out = { SinOsc.ar(~lfo.kr, 0, 0.15) };
```

---

## Operaciones Matemáticas

### Operadores unarios y binarios
```supercollider
~lfo = ~lfo2.abs + ~lfo3;
```

### Operaciones complejas
```supercollider
~lfo = (~lfo3 / 50).sin * 200 + 500;
```

---

## Retroalimentación

### Retroalimentación básica
```supercollider
~out = { SinOsc.ar([220, 330], ~out.ar(2).reverse * LFNoise2.kr(0.5, 4pi), 
0.4) };
```

---

## Control Múltiple

### Control mediante arrays
```supercollider
~out = {
    var ctl = Control.names(\array).kr(Array.rand(8, 400, 1000));
    Pan2.ar(Mix(SinOsc.ar(ctl, 0, 0.1 / 8)), LFNoise0.kr(2))
};
~out.setn(\array, Array.exprand(8, 400, 2000));
```

---

## Mezcla de Señales

### Mezcla directa
```supercollider
~out = ~out1 + ~out2 + ~out3;
```

---

## Síntesis Granular

### Definición de granos
```supercollider
SynthDef("grain", { arg i_out = 0, pan;
    var env = EnvGen.kr(Env.perc(0.001, 0.003, 0.2), doneAction: 
Done.freeSelf);
    Out.ar(i_out, Pan2.ar(FSinOsc.ar(Rand(1000, 10000)), pan) * env);
}).send(s);
```

---

## Espacios Múltiples

### Creación de espacios independientes
```supercollider
(
p.use({
    ~out = { Resonz.ar(~in.ar, ~freq.kr, 0.01) };
    ~in = { WhiteNoise.ar(0.5) };
    ~freq = { LFNoise2.kr(1, 1000, 2000) };
});
q.use({
    ~in = { Dust.ar(20, 0.1) };
    ~out = { Resonz.ar(~in.ar * 450, ~freq.kr, 0.005) };
    ~freq = { LFNoise2.kr(1, 400, 2000) };
});
)
```

---

## Grabación

### Configuración y control de grabación
```supercollider
r = p.record(\out, "proxySpace.aiff");    // Configura la grabación
r.unpause;    // Inicia grabación
r.pause;      // Pausa grabación
r.close;      // Finaliza grabación
```

---

## Limpieza y Finalización

### Liberación de recursos
```supercollider
currentEnvironment.free;    // Libera los recursos asignados
```

