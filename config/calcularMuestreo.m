function [sps, fs, esValido, mensaje] = calcularMuestreo(p)
%CALCULARMUESTREO Elige la frecuencia de muestreo a partir de fc, Rs y alpha.
%   [sps, fs, esValido, mensaje] = calcularMuestreo(p)
%
%   sps : muestras por símbolo (entero)
%   fs  : frecuencia de muestreo, fs = sps * Rs  [Hz]
%
%   Justificación:
%   - La señal en banda base ocupa |f| <= W, con W = (1 + alpha) * Rs / 2.
%   - La señal pasabanda ocupa fc - W <= |f| <= fc + W.
%   - Condición 1 (sin traslape con frecuencias negativas): fc > W.
%   - Condición 2 (Nyquist): fs > 2 * (fc + W). Esta misma condición
%     garantiza que, al demodular, la componente en 2*fc no se pliegue
%     (aliasing) sobre la banda base.
%   Se usa un margen (MARGEN_NYQUIST) y un mínimo de muestras por símbolo
%   para que el diagrama de ojo se vea bien.

    sps = NaN; fs = NaN; esValido = false;

    W = (1 + p.rollOff) * p.Rs / 2;          % ancho de banda en banda base
    if p.fc <= W
        mensaje = sprintf(['La portadora fc = %g Hz debe ser mayor que (1+alpha)Rs/2 = %g Hz ' ...
                           'para que el espectro pasabanda no se traslape.'], p.fc, W);
        return;
    end

    fsMinimo = p.MARGEN_NYQUIST * 2 * (p.fc + W);
    sps = max(p.SPS_MINIMO, ceil(fsMinimo / p.Rs));
    if sps > p.SPS_MAXIMO
        mensaje = sprintf(['fc = %g Hz es demasiado alta frente a Rs = %g sím/s: se necesitarían ' ...
                           '%d muestras por símbolo (máximo %d). Aumente Rs o reduzca fc.'], ...
                           p.fc, p.Rs, sps, p.SPS_MAXIMO);
        return;
    end

    fs = sps * p.Rs;
    esValido = true;
    mensaje = '';
end
