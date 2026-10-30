function [f, dep] = calcularEspectro(x, fs, tamanoSegmento)
%CALCULARESPECTRO Densidad espectral de potencia por promedio de periodogramas.
%   [f, dep] = calcularEspectro(x, fs, tamanoSegmento)
%
%   x              : señal (real o compleja)
%   fs             : frecuencia de muestreo [Hz]
%   tamanoSegmento : muestras por segmento (potencia de 2 recomendada)
%   f              : eje de frecuencias [Hz], de -fs/2 a fs/2
%   dep            : densidad espectral de potencia [W/Hz]
%
%   Método (Welch, programado a mano sin pwelch ni hann):
%     1. Dividir x en segmentos de N muestras con 50 % de traslape.
%     2. Multiplicar cada segmento por una ventana de Hann,
%        w[n] = 0.5 - 0.5 cos(2 pi n / (N-1)), para reducir la fuga
%        espectral.
%     3. Periodograma de cada segmento: |FFT|^2 / (fs * sum(w^2)).
%     4. Promediar los periodogramas (reduce la varianza de la estimación).
%   Se devuelve el espectro bilateral, centrado en 0 con fftshift.

    x = x(:).';
    N = tamanoSegmento;
    if numel(x) < N
        N = numel(x);
    end

    n = 0:N-1;
    ventana = 0.5 - 0.5*cos(2*pi*n/(N - 1));
    normalizacion = fs * sum(ventana.^2);

    paso = floor(N/2);
    inicios = 1:paso:(numel(x) - N + 1);
    acumulado = zeros(1, N);
    for i = 1:numel(inicios)
        segmento = x(inicios(i) : inicios(i) + N - 1) .* ventana;
        acumulado = acumulado + abs(fft(segmento)).^2;
    end
    dep = fftshift(acumulado / (numel(inicios) * normalizacion));
    f   = (-N/2 : N/2 - 1) * (fs / N);
end
