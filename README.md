# modulacion_digital

Repositorio para el segundo corte de la materia Comunicaciones Digitales 2026 II
(Universidad del Cauca).

Simulación de un sistema de comunicación digital M-PAM, M-QAM y M-PSK en MATLAB,
sin funciones de alto nivel (`qammod`, `pskmod`, `awgn`, `rcosdesign`, ...).

## Cadena simulada

```
bits -> mapeo Gray -> filtro RRC -> modulación pasabanda -> canal AWGN
     -> demodulación coherente -> filtro acoplado -> muestreo -> decisor -> demapeo -> BER
```

## Estructura

| Carpeta       | Contenido                                                        |
|---------------|------------------------------------------------------------------|
| `config/`     | Parámetros por defecto, constantes y validación de entradas      |
| `utilidades/` | Conversiones bits/enteros y binario/Gray                         |
| `transmisor/` | Fuente de bits, mapeo, conformación de pulso, modulador          |
| `canal/`      | Canal AWGN                                                       |
| `receptor/`   | Demodulador, filtro acoplado, decisor, demapeo                   |
| `metricas/`   | BER, energías, ancho de banda, eficiencia espectral, potencia    |
| `graficas/`   | Diagrama de ojo, constelación, espectros, curvas BER             |
| `gui/`        | Interfaz gráfica                                                 |
| `analisis/`   | Tabla comparativa 4PAM / 4QAM / 4PSK                             |
| `pruebas/`    | Scripts de validación                                            |

## Uso

Desde la carpeta raíz del proyecto en MATLAB:

```matlab
main                                    % abre la interfaz gráfica
```

Pruebas de validación:

```matlab
run('pruebas/pruebaMapeo.m')            % mapeo Gray y energía de las constelaciones
run('pruebas/pruebaCadena.m')           % cadena completa, ruido y BER vs teoría
run('pruebas/pruebaMetricasGraficas.m') % métricas y espectros
run('pruebas/pruebaValidacion.m')       % manejo de entradas no permitidas
```

## Convenciones de código

- Funciones y variables en camelCase (`mapearSimbolos`, `numBits`).
- Constantes en MAYÚSCULAS (`M_MAXIMO`, `SPAN_MINIMO`).
- Una función pública por archivo, con encabezado de ayuda (`help nombreFuncion`).
