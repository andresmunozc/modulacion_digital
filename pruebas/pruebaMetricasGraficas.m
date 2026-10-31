%PRUEBAMETRICASGRAFICAS Valida las métricas (RF4) y dibuja las gráficas (RF3).
%   Ejecutar desde la carpeta raíz del proyecto:
%       run('pruebas/pruebaMetricasGraficas.m')
%
%   Pruebas:
%     1. Energía de símbolo y potencia medidas en la señal pasabanda
%        coinciden con las fórmulas teóricas, para varios esquemas y A.
%     2. El espectro en banda base concentra casi toda la potencia dentro
%        de |f| <= W = (1 + alpha) Rs / 2.
%     3. El espectro pasabanda tiene su máximo cerca de fc.
%     4. Tabla de eficiencia espectral y ancho de banda según alpha.
%   Al final dibuja las cinco gráficas del sistema con los parámetros
%   por defecto.

clear; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));   % raíz del proyecto
agregarRutas();

p = parametrosPorDefecto();
p.numBits = 4e4;
fallos = 0;

% --- 1. Energía y potencia ---
fprintf('1. Energía de símbolo y potencia (teórica vs medida):\n');
casos = {'PAM', 4, 1; 'PAM', 8, 1; 'QAM', 4, 1; 'QAM', 16, 2; 'PSK', 8, 1; 'PSK', 4, 3};
for c = 1:size(casos, 1)
    q = p; q.esquema = casos{c, 1}; q.M = casos{c, 2}; q.amplitud = casos{c, 3};
    res = simularSistema(q, Inf);
    m = calcularMetricas(q, res);
    errorEs = abs(m.EsMedida - m.EsTeorica) / m.EsTeorica;
    fprintf('   %3d-%s, A = %d: Es teórica = %7.3f J, medida = %7.3f J | P teórica = %8.1f W, medida = %8.1f W\n', ...
            q.M, q.esquema, q.amplitud, m.EsTeorica, m.EsMedida, m.potenciaTeorica, m.potenciaMedida);
    if errorEs > 0.03
        fprintf('   FALLA: Es medida difiere %.1f %%\n', 100*errorEs); fallos = fallos + 1;
    end
end

% --- 2. Potencia dentro del ancho de banda teórico ---
res = simularSistema(p, Inf);
[f, dep] = calcularEspectro(res.tx.senalBandaBase, res.fs, 4096);
W = (1 + p.rollOff) * p.Rs / 2;
fraccion = sum(dep(abs(f) <= W)) / sum(dep);
fprintf('2. Potencia dentro de |f| <= W = %g Hz: %.2f %%\n', W, 100*fraccion);
if fraccion < 0.99
    fprintf('   FALLA: el espectro no está limitado a W\n'); fallos = fallos + 1;
end

% --- 3. Pico del espectro pasabanda ---
[f, dep] = calcularEspectro(res.tx.senalPasabanda, res.fs, 4096);
positivas = f >= 0;
fPos = f(positivas); depPos = dep(positivas);
centroide = sum(fPos .* depPos) / sum(depPos);   % frecuencia "promedio"
fprintf('3. Centro del espectro pasabanda = %.1f Hz (fc = %g Hz)\n', centroide, p.fc);
if abs(centroide - p.fc) > 0.05 * p.Rs
    fprintf('   FALLA: el espectro no está centrado en fc\n'); fallos = fallos + 1;
end

% --- 4. Eficiencia espectral ---
fprintf('4. Eficiencia espectral eta = k / (1 + alpha) y ancho de banda B = (1 + alpha) Rs:\n');
fprintf('   %-8s %-6s %-10s %-12s\n', 'Esquema', 'alpha', 'B [Hz]', 'eta [b/s/Hz]');
for M = [4 16]
    for alpha = [0 0.5 1]
        q = p; q.M = M; q.rollOff = alpha;
        res = simularSistema(setfield(q, 'numBits', 1e3), Inf);
        m = calcularMetricas(q, res);
        fprintf('   %-8s %-6.2f %-10.0f %-12.3f\n', sprintf('%d-QAM', M), alpha, m.anchoBanda, m.eficiencia);
    end
end

% --- Resultado ---
if fallos == 0
    fprintf('\nTODAS LAS PRUEBAS DE MÉTRICAS PASARON\n');
else
    fprintf('\n%d FALLOS EN LAS PRUEBAS DE MÉTRICAS\n', fallos);
end

% --- Gráficas del sistema (vista previa de lo que mostrará la interfaz) ---
p = parametrosPorDefecto();
res = simularSistema(p, p.ebN0Db);
[berSim, berTeo] = curvaBer(p);

figure('Name', 'Gráficas del sistema', 'Position', [50 50 1300 700]);
graficarOjo(subplot(2, 3, 1), res.rx.senalFiltrada, res.sps, res.tx.span, numel(res.tx.simbolos));
graficarConstelacion(subplot(2, 3, 2), res.rx.muestras, res.tx.tabla);
graficarBer(subplot(2, 3, 3), p.ebN0RangoDb, berSim, berTeo, sprintf('%d-%s', p.M, p.esquema));
graficarEspectro(subplot(2, 3, 4), res.tx.senalBandaBase, res.fs, 'bandaBase', p);
graficarEspectro(subplot(2, 3, 5), res.senalRecibida, res.fs, 'pasabanda', p);

m = calcularMetricas(p, res);
if res.numErrores == 0
    textoBer = sprintf('BER a %g dB: < %.1e (0 errores)', p.ebN0Db, 1/numel(res.tx.bits));
else
    textoBer = sprintf('BER a %g dB: %.2e', p.ebN0Db, res.ber);
end
textoMetricas = { ...
    sprintf('Esquema: %d-%s, alpha = %.2f', p.M, p.esquema, p.rollOff), ...
    sprintf('Eficiencia espectral: %.3f bit/s/Hz', m.eficiencia), ...
    sprintf('Energía de símbolo: %.4f J', m.EsTeorica), ...
    sprintf('Ancho de banda: %.0f Hz', m.anchoBanda), ...
    sprintf('Potencia: %.2f W (medida %.2f W)', m.potenciaTeorica, m.potenciaMedida), ...
    textoBer};
ax = subplot(2, 3, 6);
axis(ax, 'off');
text(ax, 0, 0.5, textoMetricas, 'FontSize', 10, 'VerticalAlignment', 'middle');
title(ax, 'Métricas');
