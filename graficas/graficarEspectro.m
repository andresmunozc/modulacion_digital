function graficarEspectro(ax, x, fs, tipo, p)
%GRAFICARESPECTRO Dibuja la densidad espectral de potencia en dB.
%   graficarEspectro(ax, x, fs, tipo, p)
%
%   ax   : ejes donde dibujar
%   x    : señal
%   fs   : frecuencia de muestreo [Hz]
%   tipo : 'bandaBase' (se marca +-W) o 'pasabanda' (se marca fc +- W)
%   p    : parámetros (fc, Rs, rollOff)
%
%   Las líneas punteadas muestran el ancho de banda teórico del coseno
%   alzado, W = (1 + alpha) Rs / 2, para comparar con el espectro medido.

    TAMANO_SEGMENTO = 4096;
    PISO_DB = -80;                      % evita log(0) en la gráfica

    [f, dep] = calcularEspectro(x, fs, TAMANO_SEGMENTO);
    depDb = 10*log10(dep / max(dep));   % normalizado: el máximo es 0 dB
    depDb(depDb < PISO_DB) = PISO_DB;

    W = (1 + p.rollOff) * p.Rs / 2;
    switch tipo
        case 'bandaBase'
            marcas = [-W W];
            limites = 3 * W * [-1 1];
            titulo = 'Espectro banda base (Tx)';
        case 'pasabanda'
            % Señal real: el espectro es simétrico, se muestra f >= 0
            marcas = p.fc + [-W W];
            limites = [0 min(fs/2, 2*p.fc + 3*W)];
            titulo = 'Espectro pasabanda (Rx)';
        otherwise
            error('graficarEspectro:tipo', 'Tipo no válido: %s', tipo);
    end

    plot(ax, f/1e3, depDb, 'LineWidth', 1);
    hold(ax, 'on');
    for i = 1:numel(marcas)
        plot(ax, [marcas(i) marcas(i)]/1e3, [PISO_DB 5], 'r--');
    end
    hold(ax, 'off');
    grid(ax, 'on');
    xlim(ax, limites/1e3);
    ylim(ax, [PISO_DB 5]);
    xlabel(ax, 'Frecuencia [kHz]');
    ylabel(ax, 'DEP normalizada [dB]');
    title(ax, titulo);
end
