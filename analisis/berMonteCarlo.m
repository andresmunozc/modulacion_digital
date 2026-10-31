function [ber, numErrores, numBits] = berMonteCarlo(p, ebN0Db, minErrores, maxBits, bitsPorBloque)
%BERMONTECARLO BER simulada acumulando bloques hasta tener errores suficientes.
%   [ber, numErrores, numBits] = berMonteCarlo(p, ebN0Db, minErrores, maxBits, bitsPorBloque)
%
%   Para BER bajas hacen falta muchos bits: con N bits y BER = Pb se
%   esperan N*Pb errores, y la estimación es confiable (error relativo de
%   ~10 %) cuando hay unos 100 errores. Simular 10^7 bits de una vez no
%   cabe en memoria, por eso se simulan bloques de bitsPorBloque bits, cada
%   uno con una semilla distinta (semilla, semilla+1, ...), y se suman los
%   errores hasta llegar a minErrores o a maxBits.
%
%   El resultado es reproducible: las semillas de los bloques son fijas.

    numErrores = 0;
    numBits = 0;
    bloque = 0;
    q = p;
    q.numBits = bitsPorBloque;
    while numErrores < minErrores && numBits < maxBits
        q.semilla = p.semilla + bloque;
        res = simularSistema(q, ebN0Db);
        numErrores = numErrores + res.numErrores;
        numBits = numBits + numel(res.tx.bits);
        bloque = bloque + 1;
    end
    ber = numErrores / numBits;
end
