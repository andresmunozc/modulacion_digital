%TABLACOMPARATIVA Análisis 4-PAM, 4-QAM y 4-PSK (condiciones de entrega, punto 4).
%   Ejecutar desde la carpeta raíz del proyecto:  run('analisis/tablaComparativa.m')
%
%   1. Calcula el Eb/N0 que necesita cada esquema para BER = 1e-2 ... 1e-7:
%      - Teórico: invirtiendo la expresión de BER (bisección).
%      - Simulado: interpolando la curva de BER por Monte Carlo. Solo
%        hasta 1e-5: medir 1e-6 o 1e-7 con ~100 errores exigiría 1e8 a 1e9
%        bits por punto (horas de simulación).
%   2. Imprime la tabla de diferencias de Eb/N0 entre pares de esquemas.
%   3. Grafica las curvas de BER, las diferencias y las constelaciones.
%   4. Guarda tabla y figuras en la carpeta resultados/.
%
%   Duración aproximada en MATLAB: 2 a 4 minutos.

clear; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));   % raíz del proyecto
agregarRutas();

% --- Configuración del análisis ---
BER_OBJETIVO    = [1e-2 1e-3 1e-4 1e-5 1e-6 1e-7];
BER_MIN_SIMULADA = 1e-5;          % por debajo solo se usa la teoría
EBN0_SIMULACION = 0:1:14;         % puntos de la curva simulada [dB]
MIN_ERRORES     = 100;            % errores por punto (estimación confiable)
MAX_BITS        = 1e7;            % bits máximos por punto
BITS_POR_BLOQUE = 2e5;

esquemas  = {'PAM', 'QAM', 'PSK'};
nombres   = {'4-PAM', '4-QAM', '4-PSK'};
M = 4;
p = parametrosPorDefecto();
p.M = M;

carpetaResultados = fullfile(fileparts(mfilename('fullpath')), '..', 'resultados');
if ~exist(carpetaResultados, 'dir')
    mkdir(carpetaResultados);
end

% ------------------------------------------------------------------------
% 1. Eb/N0 requerido: teórico y simulado
% ------------------------------------------------------------------------
numEsquemas = numel(esquemas);
ebN0Teorico  = zeros(numEsquemas, numel(BER_OBJETIVO));
ebN0Simulado = NaN(numEsquemas, numel(BER_OBJETIVO));
berSimulada  = NaN(numEsquemas, numel(EBN0_SIMULACION));

for e = 1:numEsquemas
    ebN0Teorico(e, :) = ebN0Requerido(esquemas{e}, M, BER_OBJETIVO);

    q = p;
    q.esquema = esquemas{e};
    fprintf('Simulando %s ', nombres{e});
    for i = 1:numel(EBN0_SIMULACION)
        % No vale la pena simular donde la BER teórica ya es mucho menor
        % que la mínima que se quiere medir.
        if berTeorica(q.esquema, M, EBN0_SIMULACION(i)) < BER_MIN_SIMULADA / 10
            break;
        end
        [berSimulada(e, i), numErrores] = berMonteCarlo(q, EBN0_SIMULACION(i), ...
                                              MIN_ERRORES, MAX_BITS, BITS_POR_BLOQUE);
        if numErrores == 0
            berSimulada(e, i) = NaN;
        end
        fprintf('.');
    end
    fprintf(' listo\n');

    medibles = BER_OBJETIVO >= BER_MIN_SIMULADA;
    ebN0Simulado(e, medibles) = ebN0DesdeCurva(EBN0_SIMULACION, berSimulada(e, :), BER_OBJETIVO(medibles));
end

% ------------------------------------------------------------------------
% 2. Tabla de diferencias
% ------------------------------------------------------------------------
% Índices: 1 = 4-PAM, 2 = 4-QAM, 3 = 4-PSK
% Columnas pedidas en el enunciado: 4PAM-4QAM, 4PSK-4QAM, 4QAM-4PAM.
% Se agrega 4PSK-4PAM, porque la tercera columna del enunciado repite el
% par de la primera (con el signo cambiado).
pares = [1 2; 3 2; 2 1; 3 1];
nombresPares = {'4PAM-4QAM', '4PSK-4QAM', '4QAM-4PAM', '4PSK-4PAM'};

diferenciaTeorica  = zeros(numel(BER_OBJETIVO), size(pares, 1));
diferenciaSimulada = zeros(numel(BER_OBJETIVO), size(pares, 1));
for k = 1:size(pares, 1)
    diferenciaTeorica(:, k)  = ebN0Teorico(pares(k, 1), :)  - ebN0Teorico(pares(k, 2), :);
    diferenciaSimulada(:, k) = ebN0Simulado(pares(k, 1), :) - ebN0Simulado(pares(k, 2), :);
end

fprintf('\nEb/N0 REQUERIDO [dB]  (teórico / simulado)\n');
fprintf('%-8s', 'BER');
fprintf('%-20s', nombres{:});
fprintf('\n');
for b = 1:numel(BER_OBJETIVO)
    fprintf('%-8.0e', BER_OBJETIVO(b));
    for e = 1:numEsquemas
        fprintf('%-20s', textoValor(ebN0Teorico(e, b), ebN0Simulado(e, b)));
    end
    fprintf('\n');
end

fprintf('\nDIFERENCIA DE Eb/N0 ENTRE ESQUEMAS [dB]  (teórica / simulada)\n');
fprintf('%-8s', 'BER');
fprintf('%-20s', nombresPares{:});
fprintf('\n');
for b = 1:numel(BER_OBJETIVO)
    fprintf('%-8.0e', BER_OBJETIVO(b));
    for k = 1:size(pares, 1)
        fprintf('%-20s', textoValor(diferenciaTeorica(b, k), diferenciaSimulada(b, k)));
    end
    fprintf('\n');
end
fprintf('\nLímite asintótico 4PAM-4QAM: 10*log10(5/2) = %.2f dB\n', 10*log10(5/2));
fprintf('"-" = no simulado (BER demasiado baja para medirla con %g bits por punto)\n', MAX_BITS);

% Guardar la tabla en CSV (separador ; para abrirla en Excel en español)
archivo = fopen(fullfile(carpetaResultados, 'tabla_diferencias.csv'), 'w');
fprintf(archivo, 'BER');
for k = 1:size(pares, 1)
    fprintf(archivo, ';%s teorica [dB];%s simulada [dB]', nombresPares{k}, nombresPares{k});
end
fprintf(archivo, '\n');
for b = 1:numel(BER_OBJETIVO)
    fprintf(archivo, '%.0e', BER_OBJETIVO(b));
    fprintf(archivo, ';%.3f;%.3f', [diferenciaTeorica(b, :); diferenciaSimulada(b, :)]);
    fprintf(archivo, '\n');
end
fclose(archivo);

% ------------------------------------------------------------------------
% 3. Gráficas
% ------------------------------------------------------------------------
estilos = {'-', '--', ':'};
marcadores = {'o', 's', '^'};
colores = [0.85 0.33 0.10; 0.00 0.45 0.74; 0.47 0.67 0.19];
ebN0Fino = -2:0.05:16;

% Figura 1: curvas de BER teóricas y simuladas, con los niveles de la tabla
fig1 = figure('Name', 'BER 4-PAM, 4-QAM, 4-PSK', 'Position', [60 60 900 600]);
for e = 1:numEsquemas
    semilogy(ebN0Fino, berTeorica(esquemas{e}, M, ebN0Fino), estilos{e}, ...
             'Color', colores(e, :), 'LineWidth', 1.8, 'DisplayName', [nombres{e} ' teórica']);
    hold on;
    semilogy(EBN0_SIMULACION, berSimulada(e, :), marcadores{e}, 'Color', colores(e, :), ...
             'LineWidth', 1.5, 'MarkerSize', 7, 'DisplayName', [nombres{e} ' simulada']);
end
for b = 1:numel(BER_OBJETIVO)
    plot([-2 16], BER_OBJETIVO(b)*[1 1], ':', 'Color', [0.6 0.6 0.6], 'HandleVisibility', 'off');
end
% Flecha de la separación 4-PAM / 4-QAM en BER = 1e-5
yFlecha = 1e-5;
plot([ebN0Teorico(2, 4) ebN0Teorico(1, 4)], yFlecha*[1 1], 'k-', 'LineWidth', 2, 'HandleVisibility', 'off');
text(mean([ebN0Teorico(2, 4) ebN0Teorico(1, 4)]), yFlecha*2.2, ...
     sprintf('%.2f dB', diferenciaTeorica(4, 1)), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
hold off; grid on;
xlim([-2 16]); ylim([1e-8 1]);
xlabel('E_b/N_0 [dB]'); ylabel('BER');
title('Desempeño de 4-PAM, 4-QAM y 4-PSK en AWGN');
legend('Location', 'southwest');

% Figura 2: diferencia de Eb/N0 en función de la BER objetivo
fig2 = figure('Name', 'Diferencia de Eb/N0', 'Position', [100 100 900 500]);
semilogx(BER_OBJETIVO, diferenciaTeorica(:, 1), '-o', 'LineWidth', 1.8, 'Color', colores(1, :), ...
         'DisplayName', '4PAM-4QAM teórica');
hold on;
semilogx(BER_OBJETIVO, diferenciaSimulada(:, 1), 's', 'LineWidth', 1.8, 'MarkerSize', 9, ...
         'Color', colores(1, :), 'DisplayName', '4PAM-4QAM simulada');
semilogx(BER_OBJETIVO, diferenciaTeorica(:, 2), '-o', 'LineWidth', 1.8, 'Color', colores(3, :), ...
         'DisplayName', '4PSK-4QAM teórica');
semilogx(BER_OBJETIVO, diferenciaSimulada(:, 2), 's', 'LineWidth', 1.8, 'MarkerSize', 9, ...
         'Color', colores(3, :), 'DisplayName', '4PSK-4QAM simulada');
semilogx([1e-8 1e-1], 10*log10(5/2)*[1 1], 'k--', 'DisplayName', 'Límite 10log_{10}(5/2) = 3.98 dB');
hold off; grid on;
set(gca, 'XDir', 'reverse');            % de BER alta (izquierda) a baja
xlim([5e-8 2e-2]); ylim([-0.5 4.5]);
xlabel('BER objetivo'); ylabel('\Delta E_b/N_0 [dB]');
title('Eb/N0 adicional respecto a 4-QAM');
legend('Location', 'east');

% Figura 3: constelaciones con la misma energía por bit (Eb = 1)
fig3 = figure('Name', 'Constelaciones con igual Eb', 'Position', [140 140 1000 380]);
for e = 1:numEsquemas
    tabla = construirConstelacion(esquemas{e}, M) * sqrt(2);   % Es = 2 -> Eb = 1
    subplot(1, numEsquemas, e);
    plot(real(tabla), imag(tabla), 'o', 'MarkerSize', 10, 'MarkerFaceColor', colores(e, :), ...
         'Color', colores(e, :));
    distancias = abs(tabla.' - tabla);
    distancias(1:M+1:end) = inf;
    dMin = min(distancias(:));
    grid on; axis equal; xlim([-2.2 2.2]); ylim([-2.2 2.2]);
    xlabel('I'); ylabel('Q');
    title(sprintf('%s: d_{min} = %.3f', nombres{e}, dMin));
end

print(fig1, fullfile(carpetaResultados, 'ber_4pam_4qam_4psk.png'), '-dpng', '-r150');
print(fig2, fullfile(carpetaResultados, 'diferencia_ebn0.png'), '-dpng', '-r150');
print(fig3, fullfile(carpetaResultados, 'constelaciones_igual_eb.png'), '-dpng', '-r150');
fprintf('\nTabla y figuras guardadas en: %s\n', carpetaResultados);

% ------------------------------------------------------------------------
function texto = textoValor(teorico, simulado)
% Formatea "teórico / simulado"; "-" si no hay valor simulado.
    if isnan(simulado)
        texto = sprintf('%6.2f / -', teorico);
    else
        texto = sprintf('%6.2f / %5.2f', teorico, simulado);
    end
end
