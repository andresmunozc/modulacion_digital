function senalBandaBase = conformarPulso(simbolos, h, sps)
%CONFORMARPULSO Sobremuestreo y filtrado con el pulso RRC.
%   senalBandaBase = conformarPulso(simbolos, h, sps)
%
%   Construye s(t) = sum_k a_k h(t - k Ts):
%     1. Sobremuestreo: se coloca cada símbolo a_k en la muestra k*sps y
%        ceros entre ellos (tren de impulsos).
%     2. Convolución con h: cada impulso se reemplaza por un pulso RRC.
%
%   La salida es compleja (I + jQ); en PAM la parte Q es cero.

    numSimbolos = numel(simbolos);
    trenImpulsos = zeros(1, numSimbolos * sps);
    trenImpulsos(1:sps:end) = simbolos;

    senalBandaBase = convolucionFFT(trenImpulsos, h);
end
