function salida = filtroAcoplado(senal, h, fs)
%FILTROACOPLADO Filtra la señal con h(-t) (igual a h(t) porque es simétrico).
%   salida = filtroAcoplado(senal, h, fs)
%
%   La convolución discreta se multiplica por dt = 1/fs para aproximar la
%   integral de convolución en tiempo continuo:
%       y(t) = integral r(tau) h(t - tau) dtau
%   Con ese escalamiento, en el instante óptimo la salida vale a_k (el
%   símbolo transmitido) más ruido de varianza N0/2 por componente.

    hAcoplado = fliplr(h);     % h(-t); para el RRC es el mismo h
    salida = conv(senal, hAcoplado) / fs;
end
