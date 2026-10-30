function graficarBer(ax, ebN0Db, berSimulada, berTeo, etiqueta)
%GRAFICARBER Curva de desempeño BER vs Eb/N0 (simulada y teórica).
%   graficarBer(ax, ebN0Db, berSimulada, berTeo, etiqueta)
%
%   Línea: expresión teórica. Marcadores: simulación (Monte Carlo).
%   Si el sistema está bien implementado, los marcadores caen sobre la
%   línea. Los puntos sin errores (NaN) no se dibujan.

    semilogy(ax, ebN0Db, berTeo, '-', 'LineWidth', 1.5);
    hold(ax, 'on');
    semilogy(ax, ebN0Db, berSimulada, 'o', 'LineWidth', 1.5);
    hold(ax, 'off');
    grid(ax, 'on');
    xlabel(ax, 'E_b/N_0 [dB]');
    ylabel(ax, 'BER');
    title(ax, 'Curva de desempeño');
    legend(ax, [etiqueta ' teórica'], [etiqueta ' simulada'], 'Location', 'southwest');

    piso = min([berTeo(:); berSimulada(:)]);
    ylim(ax, [max(1e-7, 10^floor(log10(piso))) 1]);
    xlim(ax, [min(ebN0Db) max(ebN0Db)]);
end
