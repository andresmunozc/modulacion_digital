function [ber, numErrores] = calcularBer(bitsTx, bitsRx)
%CALCULARBER Tasa de error de bit por conteo directo.
%   [ber, numErrores] = calcularBer(bitsTx, bitsRx)
%
%   BER = (bits diferentes) / (bits transmitidos)
%   Para que la estimación sea confiable se necesitan del orden de 100
%   errores: medir BER = 1e-5 requiere ~1e7 bits.

    numErrores = sum(bitsTx ~= bitsRx);
    ber = numErrores / numel(bitsTx);
end
