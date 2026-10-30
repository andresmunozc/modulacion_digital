function [senalPasabanda, t] = moduladorPasabanda(senalBandaBase, fc, fs)
%MODULADORPASABANDA Traslada la señal de banda base a la portadora fc.
%   [senalPasabanda, t] = moduladorPasabanda(senalBandaBase, fc, fs)
%
%   s(t) = sqrt(2) * [ I(t) cos(2 pi fc t) - Q(t) sin(2 pi fc t) ]
%        = sqrt(2) * Re{ s_bb(t) * exp(j 2 pi fc t) }
%
%   El factor sqrt(2) hace que la energía de la señal pasabanda sea igual a
%   la de banda base (cos^2 promedia 1/2). Así Es no cambia al modular.
%   La señal resultante es real, como la que se transmite físicamente.
%   En PAM, Q(t) = 0 y queda s(t) = sqrt(2) I(t) cos(2 pi fc t).

    t = (0:numel(senalBandaBase) - 1) / fs;
    I = real(senalBandaBase);
    Q = imag(senalBandaBase);
    senalPasabanda = sqrt(2) * (I .* cos(2*pi*fc*t) - Q .* sin(2*pi*fc*t));
end
