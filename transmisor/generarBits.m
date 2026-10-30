function bits = generarBits(numBits, k)
%GENERARBITS Fuente digital: genera bits aleatorios equiprobables.
%   bits = generarBits(numBits, k)
%
%   numBits : cantidad de bits pedida
%   k       : bits por símbolo, k = log2(M)
%
%   La cantidad se redondea hacia arriba al múltiplo de k más cercano para
%   que todos los símbolos estén completos.
%   La semilla se fija antes de llamar a esta función (rng), lo que hace
%   la simulación reproducible (RNF3).

    numBits = ceil(numBits / k) * k;
    bits = double(rand(1, numBits) > 0.5);   % P(0) = P(1) = 1/2
end
