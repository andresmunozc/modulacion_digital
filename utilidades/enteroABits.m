function bits = enteroABits(enteros, k)
%ENTEROABITS Convierte enteros a sus k bits (MSB primero).
%   bits = enteroABits(enteros, k)
%
%   Operación inversa de bitsAEntero. Devuelve un vector fila de bits.
%   Se programa sin de2bi (Communications Toolbox) para cumplir RNF2.

    enteros = enteros(:).';
    % Fila i = bit de peso 2^(k-i); se extrae con división entera y módulo.
    pesos = 2 .^ (k-1:-1:0).';
    grupos = mod(floor(enteros ./ pesos), 2);
    bits = grupos(:).';
end
