function [h, t] = filtroRaizCosenoAlzado(alpha, sps, span, fs)
%FILTRORAIZCOSENOALZADO Respuesta al impulso del filtro RRC (sin rcosdesign).
%   [h, t] = filtroRaizCosenoAlzado(alpha, sps, span, fs)
%
%   alpha : factor de roll-off (0 <= alpha <= 1)
%   sps   : muestras por símbolo
%   span  : duración del filtro en símbolos (número par)
%   fs    : frecuencia de muestreo [Hz]
%   h     : coeficientes, con energía unitaria: sum(h.^2) / fs = 1
%   t     : instantes de cada coeficiente [s]
%
%   Por qué raíz de coseno alzado: el transmisor usa h(t) y el receptor el
%   filtro acoplado h(-t) = h(t). La cascada de ambos es un coseno alzado,
%   que cumple el criterio de Nyquist (cero ISI en los instantes de
%   muestreo) y además el filtro acoplado maximiza la SNR.
%
%   Fórmula (tiempo normalizado tn = t/Ts):
%            sin(pi tn (1-a)) + 4 a tn cos(pi tn (1+a))
%   h(tn) = --------------------------------------------
%                   pi tn (1 - (4 a tn)^2)
%   Casos especiales donde el denominador vale cero:
%     tn = 0          -> h = 1 - a + 4a/pi
%     tn = +-1/(4a)   -> h = (a/sqrt(2)) [(1+2/pi) sin(pi/(4a)) + (1-2/pi) cos(pi/(4a))]

    TOLERANCIA = 1e-10;

    n  = -span*sps/2 : span*sps/2;          % índices simétricos (longitud impar)
    tn = n / sps;                            % tiempo en unidades de símbolo
    h  = zeros(size(tn));

    for i = 1:numel(tn)
        x = tn(i);
        if abs(x) < TOLERANCIA
            h(i) = 1 - alpha + 4*alpha/pi;
        elseif alpha > 0 && abs(abs(x) - 1/(4*alpha)) < TOLERANCIA
            h(i) = (alpha/sqrt(2)) * ((1 + 2/pi)*sin(pi/(4*alpha)) + ...
                                      (1 - 2/pi)*cos(pi/(4*alpha)));
        else
            h(i) = (sin(pi*x*(1 - alpha)) + 4*alpha*x*cos(pi*x*(1 + alpha))) / ...
                   (pi*x*(1 - (4*alpha*x)^2));
        end
    end

    % Energía unitaria en tiempo continuo: integral h^2 dt = sum(h^2)/fs = 1.
    % Así un símbolo a_k conformado con h tiene energía |a_k|^2.
    h = h / sqrt(sum(h.^2) / fs);
    t = n / fs;
end
