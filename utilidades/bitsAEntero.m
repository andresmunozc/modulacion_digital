function enteros = bitsAEntero(bits, k)
%BITSAENTERO Agrupa bits de k en k y los convierte a enteros.
%   enteros = bitsAEntero(bits, k)
%
%   bits    : vector de 0 y 1, de longitud múltiplo de k
%   k       : bits por símbolo, k = log2(M)
%   enteros : vector fila con valores entre 0 y 2^k - 1
%
%   El primer bit de cada grupo es el más significativo (MSB).
%   Se programa sin bi2de (Communications Toolbox) para cumplir RNF2.

    bits = bits(:).';
    if mod(numel(bits), k) ~= 0
        error('bitsAEntero:longitud', ...
              'La cantidad de bits (%d) no es múltiplo de k = %d.', numel(bits), k);
    end

    % Cada columna es un grupo de k bits; la fila 1 es el MSB.
    grupos  = reshape(bits, k, []);
    pesos   = 2 .^ (k-1:-1:0);          % [2^(k-1) ... 2 1]
    enteros = pesos * grupos;
end
