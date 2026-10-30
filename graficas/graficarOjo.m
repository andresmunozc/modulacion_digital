function graficarOjo(ax, senalFiltrada, sps, span, numSimbolos)
%GRAFICAROJO Diagrama de ojo de la rama I a la salida del filtro acoplado.
%   graficarOjo(ax, senalFiltrada, sps, span, numSimbolos)
%
%   Se superponen trazos de 2 periodos de símbolo, cada uno centrado en
%   un instante de muestreo. La apertura vertical del ojo en t = 0 indica
%   el margen frente al ruido; la apertura horizontal, la tolerancia a
%   errores de sincronismo. Con más roll-off el ojo se abre más en
%   horizontal (las colas del pulso decaen más rápido).
%   Programado a mano, sin la función eyediagram.

    MAX_TRAZOS = 300;

    rama = real(senalFiltrada);
    retardo = span * sps;                      % primer instante de muestreo
    tRelativo = (-sps : sps) / sps;            % de -Ts a +Ts

    % Se omiten los primeros y últimos símbolos (colas del filtro)
    primeros = 2;
    ultimo = min(numSimbolos - 2, primeros + MAX_TRAZOS);
    cla(ax);
    hold(ax, 'on');
    for k = primeros:ultimo
        centro = retardo + 1 + (k - 1)*sps;
        plot(ax, tRelativo, rama(centro - sps : centro + sps), 'b');
    end
    hold(ax, 'off');
    grid(ax, 'on');
    xlim(ax, [-1 1]);
    xlabel(ax, 't / T_s');
    ylabel(ax, 'Amplitud (rama I)');
    title(ax, 'Diagrama de ojo (Rx)');
end
