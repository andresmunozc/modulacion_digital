function graficarConstelacion(ax, muestras, tabla)
%GRAFICARCONSTELACION Muestras recibidas sobre la constelación ideal.
%   graficarConstelacion(ax, muestras, tabla)
%
%   Puntos azules: muestras a la salida del filtro acoplado (una por
%   símbolo). Cruces rojas: puntos ideales del transmisor. La nube
%   alrededor de cada punto ideal es el ruido; su desviación estándar es
%   sqrt(N0/2) en cada eje.
%   Programado con plot, sin scatterplot.

    MAX_PUNTOS = 5000;

    muestras = muestras(1 : min(end, MAX_PUNTOS));
    plot(ax, real(muestras), imag(muestras), '.', 'Color', [0.2 0.4 0.9], 'MarkerSize', 4);
    hold(ax, 'on');
    plot(ax, real(tabla), imag(tabla), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    hold(ax, 'off');

    limite = 1.3 * max(abs([muestras(:); tabla(:)]));
    axis(ax, 'equal');
    xlim(ax, [-limite limite]);
    ylim(ax, [-limite limite]);
    grid(ax, 'on');
    xlabel(ax, 'En fase (I)');
    ylabel(ax, 'Cuadratura (Q)');
    title(ax, 'Constelación (Rx)');
end
