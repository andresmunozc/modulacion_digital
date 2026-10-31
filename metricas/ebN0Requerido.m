function ebN0Db = ebN0Requerido(esquema, M, berObjetivo)
%EBN0REQUERIDO Eb/N0 [dB] necesario para alcanzar una BER (teórica).
%   ebN0Db = ebN0Requerido(esquema, M, berObjetivo)
%
%   Se invierte la expresión teórica berTeorica por el método de
%   bisección: la BER disminuye al aumentar Eb/N0 (función monótona), así
%   que si en [a, b] la BER pasa de estar por encima a por debajo del
%   objetivo, la solución está en ese intervalo. En cada iteración se
%   parte el intervalo a la mitad y se conserva la mitad que contiene la
%   solución. Con 60 iteraciones el error es (b - a) / 2^60 ~ 0.
%
%   berObjetivo puede ser un vector; se resuelve cada valor por separado.

    LIMITE_INFERIOR_DB = -10;
    LIMITE_SUPERIOR_DB = 60;
    ITERACIONES = 60;

    ebN0Db = zeros(size(berObjetivo));
    for i = 1:numel(berObjetivo)
        objetivo = berObjetivo(i);
        a = LIMITE_INFERIOR_DB;
        b = LIMITE_SUPERIOR_DB;
        if berTeorica(esquema, M, a) < objetivo || berTeorica(esquema, M, b) > objetivo
            ebN0Db(i) = NaN;     % el objetivo está fuera del rango buscado
            continue;
        end
        for k = 1:ITERACIONES
            medio = (a + b) / 2;
            % Se compara en escala logarítmica (la BER varía muchos órdenes)
            if log10(berTeorica(esquema, M, medio)) > log10(objetivo)
                a = medio;       % aún hay demasiados errores: más Eb/N0
            else
                b = medio;
            end
        end
        ebN0Db(i) = (a + b) / 2;
    end
end
