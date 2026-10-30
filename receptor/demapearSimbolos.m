function bits = demapearSimbolos(indices, M)
%DEMAPEARSIMBOLOS Convierte los símbolos decididos de nuevo en bits.
%   bits = demapearSimbolos(indices, M)
%
%   indices(i) = b + 1, donde b es el entero cuyos bits (con Gray ya
%   incluido en la tabla) se asignaron a ese punto en el transmisor.
%   Es la operación inversa de mapearSimbolos.

    k = log2(M);
    bits = enteroABits(indices - 1, k);
end
