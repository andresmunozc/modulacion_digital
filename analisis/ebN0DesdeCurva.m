function ebN0Db = ebN0DesdeCurva(ebN0Curva, berCurva, berObjetivo)
%EBN0DESDECURVA Eb/N0 [dB] para una BER objetivo, leído de una curva simulada.
%   ebN0Db = ebN0DesdeCurva(ebN0Curva, berCurva, berObjetivo)
%
%   Se interpola linealmente log10(BER) contra Eb/N0 [dB]: entre dos
%   puntos cercanos la curva de BER es casi recta en esa escala. Si el
%   objetivo está fuera de lo simulado (por ejemplo, BER más baja que la
%   medida), se devuelve NaN en lugar de extrapolar.

    validos = isfinite(berCurva) & berCurva > 0;
    x = ebN0Curva(validos);
    y = log10(berCurva(validos));

    ebN0Db = NaN(size(berObjetivo));
    for i = 1:numel(berObjetivo)
        objetivo = log10(berObjetivo(i));
        % Primer tramo donde la curva cruza el objetivo hacia abajo
        for j = 1:numel(y) - 1
            if y(j) >= objetivo && y(j + 1) <= objetivo && y(j) ~= y(j + 1)
                fraccion = (y(j) - objetivo) / (y(j) - y(j + 1));
                ebN0Db(i) = x(j) + fraccion * (x(j + 1) - x(j));
                break;
            end
        end
    end
end
