function senalBandaBase = demoduladorPasabanda(senalRecibida, fc, fs)
%DEMODULADORPASABANDA Demodulación coherente: pasa la señal a banda base.
%   senalBandaBase = demoduladorPasabanda(senalRecibida, fc, fs)
%
%   Se multiplica por las portadoras locales (misma frecuencia y fase que
%   el transmisor, receptor coherente):
%     rama I:  r(t) *  sqrt(2) cos(2 pi fc t)
%     rama Q:  r(t) * -sqrt(2) sin(2 pi fc t)
%   Ejemplo en la rama I:
%     sqrt(2) I cos * sqrt(2) cos = I (1 + cos(4 pi fc t))
%   queda la señal I más una componente en 2 fc. Esa componente la elimina
%   el filtro acoplado (paso bajo) que viene después.

    t = (0:numel(senalRecibida) - 1) / fs;
    ramaI =  senalRecibida .* (sqrt(2) * cos(2*pi*fc*t));
    ramaQ = -senalRecibida .* (sqrt(2) * sin(2*pi*fc*t));
    senalBandaBase = ramaI + 1j * ramaQ;
end
