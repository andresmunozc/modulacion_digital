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
    largoTrazo = numel(tRelativo);

    % Se omiten los primeros y últimos símbolos (colas del filtro)
    simbolos = 2 : min(numSimbolos - 2, 1 + MAX_TRAZOS);
    numTrazos = numel(simbolos);

    % Todos los trazos se unen en un solo vector separado por NaN: se
    % dibuja como un único objeto (mucho más rápido que un plot por trazo).
    x = NaN(1, numTrazos * (largoTrazo + 1));
    y = NaN(1, numTrazos * (largoTrazo + 1));
    for i = 1:numTrazos
        centro = retardo + 1 + (simbolos(i) - 1)*sps;
        posiciones = (i - 1)*(largoTrazo + 1) + (1:largoTrazo);
        x(posiciones) = tRelativo;
        y(posiciones) = rama(centro - sps : centro + sps);
    end

    plot(ax, x, y, 'Color', [0.1 0.3 0.8]);
    grid(ax, 'on');
    xlim(ax, [-1 1]);
    xlabel(ax, 't / T_s');
    ylabel(ax, 'Amplitud (rama I)');
    title(ax, 'Diagrama de ojo (Rx)');
end
