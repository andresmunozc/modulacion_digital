function [berSimulada, berTeo, numErrores] = curvaBer(p)
%CURVABER BER simulada y teórica para cada valor de p.ebN0RangoDb.
%   [berSimulada, berTeo, numErrores] = curvaBer(p)
%
%   El transmisor se ejecuta una sola vez (mismos bits para todos los
%   puntos) y para cada Eb/N0 solo se repiten canal y receptor. Así la
%   curva es más rápida y los puntos son comparables entre sí.
%
%   Si un punto no tiene errores, la BER real es menor que 1/numBits y
%   no se puede medir con esos bits: se devuelve NaN (no se dibuja).

    [sps, fs, esValido, mensaje] = calcularMuestreo(p);
    if ~esValido
        error('curvaBer:muestreo', '%s', mensaje);
    end

    rng(p.semilla);
    tx = ejecutarTransmisor(p, sps, fs);

    numPuntos   = numel(p.ebN0RangoDb);
    berSimulada = zeros(1, numPuntos);
    numErrores  = zeros(1, numPuntos);
    for i = 1:numPuntos
        senalRecibida = canalAwgn(tx.senalPasabanda, tx.Eb, p.ebN0RangoDb(i), fs);
        rx = ejecutarReceptor(senalRecibida, tx, p, sps, fs);
        [berSimulada(i), numErrores(i)] = calcularBer(tx.bits, rx.bits);
    end
    berSimulada(numErrores == 0) = NaN;

    berTeo = berTeorica(p.esquema, p.M, p.ebN0RangoDb);
end
