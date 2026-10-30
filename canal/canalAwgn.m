function [senalRecibida, N0] = canalAwgn(senal, Eb, ebN0Db, fs)
%CANALAWGN Canal de ruido blanco gaussiano aditivo (sin la función awgn).
%   [senalRecibida, N0] = canalAwgn(senal, Eb, ebN0Db, fs)
%
%   senal  : señal pasabanda real
%   Eb     : energía por bit de la señal transmitida [J]
%   ebN0Db : relación Eb/N0 deseada [dB]
%   fs     : frecuencia de muestreo [Hz]
%   N0     : densidad espectral de potencia del ruido [W/Hz]
%
%   Cálculo del ruido:
%     1. Eb/N0 lineal = 10^(ebN0Db/10)        ->  N0 = Eb / (Eb/N0)
%     2. El ruido blanco real tiene PSD bilateral N0/2 en todas las
%        frecuencias. Al muestrearlo a fs, el ancho de banda observado es
%        fs/2 en cada lado, así que la varianza por muestra es
%            sigma^2 = (N0/2) * fs
%     3. ruido = sigma * randn  (gaussiano de media cero)
%   Con esto, después del filtro acoplado de energía unitaria, cada
%   componente (I y Q) de la muestra de decisión tiene varianza N0/2,
%   que es la base de las expresiones teóricas de BER.

    ebN0Lineal = 10^(ebN0Db / 10);
    N0 = Eb / ebN0Lineal;

    varianza = (N0 / 2) * fs;
    ruido = sqrt(varianza) * randn(size(senal));

    senalRecibida = senal + ruido;
end
