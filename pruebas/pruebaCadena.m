%PRUEBACADENA Valida la cadena completa transmisor -> canal -> receptor.
%   Ejecutar desde la carpeta raíz del proyecto:  run('pruebas/pruebaCadena.m')
%
%   Pruebas:
%     1. El pulso RRC tiene energía 1 y la cascada RRC*RRC no tiene ISI.
%     2. Sin ruido, todos los esquemas recuperan los bits (BER = 0) y las
%        muestras de decisión coinciden con los símbolos transmitidos.
%     3. La varianza del ruido en la muestra de decisión es N0/2 por
%        componente (justifica el cálculo del canal AWGN).
%     4. La BER simulada coincide con la teórica.
%     5. Reproducibilidad: dos ejecuciones iguales dan la misma BER.
%   Al final grafica BER simulada vs teórica para 4-PAM, 4-QAM y 4-PSK.

clear; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));   % raíz del proyecto
agregarRutas();

p = parametrosPorDefecto();
fallos = 0;

% --- 1. Pulso RRC ---
[sps, fs] = calcularMuestreo(p);
h = filtroRaizCosenoAlzado(p.rollOff, sps, p.SPAN_FILTRO, fs);
energiaPulso = sum(h.^2) / fs;
cascada = conv(h, h) / fs;                      % coseno alzado
centro = (numel(cascada) + 1) / 2;
otrosSimbolos = cascada(centro + sps*(1:p.SPAN_FILTRO - 1));
isiMaxima = max(abs(otrosSimbolos)) / cascada(centro);
fprintf('1. Energía del pulso = %.6f, ISI máxima = %.2e\n', energiaPulso, isiMaxima);
if abs(energiaPulso - 1) > 1e-9 || isiMaxima > 1e-2
    fprintf('   FALLA en el pulso RRC\n'); fallos = fallos + 1;
end

% --- 2. Sin ruido ---
casos = {'PAM', 2; 'PAM', 4; 'PAM', 8; 'QAM', 4; 'QAM', 16; 'QAM', 64; ...
         'PSK', 2; 'PSK', 4; 'PSK', 8; 'PSK', 16};
fprintf('2. Canal sin ruido:\n');
for c = 1:size(casos, 1)
    q = p; q.esquema = casos{c, 1}; q.M = casos{c, 2}; q.numBits = 2e4;
    res = simularSistema(q, Inf);
    errorMuestras = max(abs(res.rx.muestras - res.tx.simbolos));
    fprintf('   %3d-%s: BER = %g, error máx. en muestras = %.1e\n', ...
            q.M, q.esquema, res.ber, errorMuestras);
    if res.ber ~= 0 || errorMuestras > 0.05
        fprintf('   FALLA sin ruido\n'); fallos = fallos + 1;
    end
end

% --- 3. Varianza del ruido en la decisión ---
q = p; q.esquema = 'QAM'; q.M = 4; q.numBits = 1e5;
res = simularSistema(q, 5);
ruidoDecision = res.rx.muestras - res.tx.simbolos;
varI = var(real(ruidoDecision));
varQ = var(imag(ruidoDecision));
fprintf('3. Varianza I = %.4e, Q = %.4e, teórica N0/2 = %.4e\n', varI, varQ, res.N0/2);
if abs(varI/(res.N0/2) - 1) > 0.05 || abs(varQ/(res.N0/2) - 1) > 0.05
    fprintf('   FALLA en la varianza del ruido\n'); fallos = fallos + 1;
end

% --- 4. BER simulada vs teórica ---
fprintf('4. BER simulada vs teórica:\n');
casos = {'PAM', 2; 'PAM', 4; 'QAM', 4; 'QAM', 16; 'PSK', 4; 'PSK', 8};
for c = 1:size(casos, 1)
    q = p; q.esquema = casos{c, 1}; q.M = casos{c, 2}; q.numBits = 2e5;
    for ebN0Db = [2 6]
        res = simularSistema(q, ebN0Db);
        teorica = berTeorica(q.esquema, q.M, ebN0Db);
        errorRelativo = abs(res.ber - teorica) / teorica;
        fprintf('   %3d-%s, Eb/N0 = %d dB: simulada = %.3e, teórica = %.3e (%d errores, dif. %.1f %%)\n', ...
                q.M, q.esquema, ebN0Db, res.ber, teorica, res.numErrores, 100*errorRelativo);
        if res.numErrores >= 100 && errorRelativo > 0.15
            fprintf('   FALLA: la BER simulada no coincide con la teórica\n'); fallos = fallos + 1;
        end
    end
end

% --- 5. Reproducibilidad ---
q = p; q.numBits = 5e4;
ber1 = simularSistema(q, 4).ber;
ber2 = simularSistema(q, 4).ber;
fprintf('5. Reproducibilidad: BER1 = %.6e, BER2 = %.6e\n', ber1, ber2);
if ber1 ~= ber2
    fprintf('   FALLA: resultados distintos con la misma semilla\n'); fallos = fallos + 1;
end

% --- Resultado ---
if fallos == 0
    fprintf('\nTODAS LAS PRUEBAS DE LA CADENA PASARON\n');
else
    fprintf('\n%d FALLOS EN LAS PRUEBAS DE LA CADENA\n', fallos);
end

% --- Gráfica BER simulada vs teórica ---
ebN0Rango = 0:1:10;
casos = {'PAM', 4; 'QAM', 4; 'PSK', 4};
marcadores = {'o', 's', '^'};
figure('Name', 'BER simulada vs teórica');
for c = 1:size(casos, 1)
    q = p; q.esquema = casos{c, 1}; q.M = casos{c, 2}; q.numBits = 2e5;
    berSim = zeros(size(ebN0Rango));
    for i = 1:numel(ebN0Rango)
        berSim(i) = simularSistema(q, ebN0Rango(i)).ber;
    end
    berSim(berSim == 0) = NaN;    % no se puede dibujar 0 en escala log
    semilogy(ebN0Rango, berTeorica(q.esquema, q.M, ebN0Rango), '-', 'LineWidth', 1.2);
    hold on;
    semilogy(ebN0Rango, berSim, marcadores{c}, 'LineWidth', 1.2);
end
hold off; grid on;
xlabel('E_b/N_0 [dB]'); ylabel('BER');
legend('4-PAM teórica', '4-PAM simulada', '4-QAM teórica', '4-QAM simulada', ...
       '4-PSK teórica', '4-PSK simulada', 'Location', 'southwest');
title('BER simulada vs teórica');
ylim([1e-6 1]);
