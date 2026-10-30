function g = binarioAGray(n)
%BINARIOAGRAY Convierte enteros en código binario natural a código Gray.
%   g = binarioAGray(n)
%
%   Regla: g = n XOR (n desplazado un bit a la derecha).
%   Ejemplo (3 bits): 0 1 2 3 4 5 6 7  ->  0 1 3 2 6 7 5 4
%   Dos enteros consecutivos en Gray difieren en un solo bit.

    g = bitxor(n, bitshift(n, -1));
end
