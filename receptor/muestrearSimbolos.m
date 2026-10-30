function muestras = muestrearSimbolos(senalFiltrada, sps, span, numSimbolos)
%MUESTREARSIMBOLOS Toma una muestra por símbolo en el instante óptimo.
%   muestras = muestrearSimbolos(senalFiltrada, sps, span, numSimbolos)
%
%   Cada filtro (transmisor y receptor) tiene un retardo de span*sps/2
%   muestras (la mitad de su longitud). El retardo total es span*sps, así
%   que el primer símbolo está en la muestra span*sps + 1 y los demás cada
%   sps muestras (centro del ojo, donde el coseno alzado no tiene ISI).

    retardo = span * sps;
    indices = retardo + 1 + (0:numSimbolos - 1) * sps;
    muestras = senalFiltrada(indices);
end
