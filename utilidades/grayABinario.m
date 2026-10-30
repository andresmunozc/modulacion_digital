function n = grayABinario(g)
%GRAYABINARIO Convierte enteros en código Gray a binario natural.
%   n = grayABinario(g)
%
%   Es la operación inversa de binarioAGray: se acumula el XOR de g con
%   todas sus versiones desplazadas a la derecha.

    n = g;
    desplazado = bitshift(g, -1);
    while any(desplazado(:) > 0)
        n = bitxor(n, desplazado);
        desplazado = bitshift(desplazado, -1);
    end
end
