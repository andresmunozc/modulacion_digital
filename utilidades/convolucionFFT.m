function y = convolucionFFT(x, h)
%CONVOLUCIONFFT Convolución lineal calculada con la FFT.
%   y = convolucionFFT(x, h)
%
%   Da el mismo resultado que conv(x, h) (longitud numel(x)+numel(h)-1),
%   pero mucho más rápido cuando h es largo.
%
%   Teorema de convolución: convolucionar en el tiempo equivale a
%   multiplicar en frecuencia. Para que la convolución circular de la FFT
%   sea igual a la lineal, ambas señales se rellenan con ceros hasta
%   N = numel(x) + numel(h) - 1:
%       y = IFFT( FFT(x, N) .* FFT(h, N) )
%   Costo: O(N log N), contra O(numel(x) * numel(h)) de la directa.

    x = x(:).';
    h = h(:).';
    N = numel(x) + numel(h) - 1;
    y = ifft(fft(x, N) .* fft(h, N));

    % Si ambas entradas son reales, la salida es real (se elimina el
    % residuo imaginario numérico de la FFT, del orden de 1e-16).
    if isreal(x) && isreal(h)
        y = real(y);
    end
end
