%PRUEBAMAPEO Valida la etapa de mapeo de las tres modulaciones.
%   Ejecutar desde la carpeta raíz del proyecto:  run('pruebas/pruebaMapeo.m')
%
%   Pruebas:
%     1. Conversión bits <-> enteros sin pérdida.
%     2. Conversión binario <-> Gray sin pérdida.
%     3. Energía promedio de cada constelación igual a 1.
%     4. Código Gray: los vecinos más cercanos difieren en un solo bit.
%     5. 4-PSK y 4-QAM producen la misma constelación.
%     6. Validación de órdenes no permitidos.
%   Al final dibuja las constelaciones con sus etiquetas de bits.

clear; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));   % raíz del proyecto
agregarRutas();

TOLERANCIA = 1e-12;
ordenes.PAM = [2 4 8 16];
ordenes.QAM = [4 16 64 256];
ordenes.PSK = [2 4 8 16];
esquemas = fieldnames(ordenes);
fallos = 0;

% --- 1. bits <-> enteros ---
rng(1);
for k = 1:8
    bits = generarBits(1000, k);
    recuperados = enteroABits(bitsAEntero(bits, k), k);
    if ~isequal(bits, recuperados)
        fprintf('FALLA bits<->enteros con k = %d\n', k); fallos = fallos + 1;
    end
end
fprintf('Prueba 1 (bits <-> enteros): terminada\n');

% --- 2. binario <-> Gray ---
n = 0:255;
if ~isequal(grayABinario(binarioAGray(n)), n)
    fprintf('FALLA conversión Gray\n'); fallos = fallos + 1;
end
fprintf('Prueba 2 (binario <-> Gray): terminada\n');

% --- 3 y 4. Energía unitaria y propiedad Gray ---
for e = 1:numel(esquemas)
    esquema = esquemas{e};
    for M = ordenes.(esquema)
        tabla = construirConstelacion(esquema, M);
        k = log2(M);

        % 3. Energía promedio
        es = mean(abs(tabla).^2);
        if abs(es - 1) > TOLERANCIA
            fprintf('FALLA Es = %.4f en %d-%s\n', es, M, esquema); fallos = fallos + 1;
        end

        % 4. Gray: para cada punto, sus vecinos a distancia mínima deben
        %    diferir en exactamente un bit.
        distancias = abs(tabla.' - tabla);         % matriz M x M
        distancias(1:M+1:end) = inf;               % ignorar la diagonal
        dMin = min(distancias(:));
        etiquetas = reshape(enteroABits(0:M-1, k), k, M);
        for i = 1:M
            vecinos = find(abs(distancias(i, :) - dMin) < 1e-9);
            for j = vecinos
                bitsDistintos = sum(etiquetas(:, i) ~= etiquetas(:, j));
                if bitsDistintos ~= 1
                    fprintf('FALLA Gray en %d-%s (puntos %d y %d)\n', M, esquema, i-1, j-1);
                    fallos = fallos + 1;
                end
            end
        end
    end
end
fprintf('Prueba 3 (Es = 1) y 4 (Gray): terminadas\n');

% --- 5. 4-PSK = 4-QAM ---
% Se comparan los conjuntos de puntos (geometría). El orden de las
% etiquetas puede diferir, pero ambas son Gray, así que la BER es igual.
puntosPsk = sort(round(construirConstelacion('PSK', 4) * 1e9) / 1e9);
puntosQam = sort(round(construirConstelacion('QAM', 4) * 1e9) / 1e9);
if max(abs(puntosPsk - puntosQam)) > TOLERANCIA
    fprintf('FALLA: 4-PSK y 4-QAM difieren\n'); fallos = fallos + 1;
end
fprintf('Prueba 5 (4-PSK = 4-QAM): terminada\n');

% --- 6. Validación de órdenes ---
casosInvalidos = {'QAM', 8; 'QAM', 32; 'PSK', 6; 'PAM', 1; 'PAM', 3.5; 'PSK', 512};
for c = 1:size(casosInvalidos, 1)
    [ok, msg] = validarOrden(casosInvalidos{c, 1}, casosInvalidos{c, 2}, 256);
    if ok
        fprintf('FALLA: se aceptó M = %g en %s\n', casosInvalidos{c, 2}, casosInvalidos{c, 1});
        fallos = fallos + 1;
    else
        fprintf('  Rechazado M = %g en %s: %s\n', casosInvalidos{c, 2}, casosInvalidos{c, 1}, msg);
    end
end
fprintf('Prueba 6 (validación de M): terminada\n');

% --- Resultado ---
if fallos == 0
    fprintf('\nTODAS LAS PRUEBAS DE MAPEO PASARON\n');
else
    fprintf('\n%d FALLOS EN LAS PRUEBAS DE MAPEO\n', fallos);
end

% --- Gráfica de constelaciones con etiquetas Gray ---
figure('Name', 'Constelaciones con mapeo Gray', 'Position', [100 100 1200 420]);
casosGrafica = {'PAM', 4; 'QAM', 16; 'PSK', 8};
for c = 1:size(casosGrafica, 1)
    esquema = casosGrafica{c, 1};
    M = casosGrafica{c, 2};
    k = log2(M);
    tabla = construirConstelacion(esquema, M);
    etiquetas = reshape(enteroABits(0:M-1, k), k, M);

    subplot(1, 3, c);
    plot(real(tabla), imag(tabla), 'o', 'MarkerFaceColor', 'b');
    hold on;
    for i = 1:M
        text(real(tabla(i)), imag(tabla(i)) + 0.12, char(etiquetas(:, i).' + '0'), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    hold off;
    axis equal; grid on;
    limite = 1.5 * max(abs(tabla));
    xlim([-limite limite]); ylim([-limite limite]);
    xlabel('En fase (I)'); ylabel('Cuadratura (Q)');
    title(sprintf('%d-%s', M, esquema));
end
