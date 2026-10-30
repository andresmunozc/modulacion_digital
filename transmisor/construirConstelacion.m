function tabla = construirConstelacion(esquema, M)
%CONSTRUIRCONSTELACION Tabla de mapeo con código Gray y energía unitaria.
%   tabla = construirConstelacion(esquema, M)
%
%   tabla(b+1) es el símbolo complejo que corresponde al grupo de bits cuyo
%   valor entero es b (b = 0 ... M-1). El transmisor la usa para mapear y
%   el receptor para decidir (punto más cercano) y demapear.
%
%   La constelación se normaliza para que la energía promedio por símbolo
%   sea 1 (Es = 1). Así la potencia del ruido se define solo con Eb/N0.

    switch esquema
        case 'PAM'
            tabla = constelacionPam(M);
        case 'QAM'
            tabla = constelacionQam(M);
        case 'PSK'
            tabla = constelacionPsk(M);
        otherwise
            error('construirConstelacion:esquema', ...
                  'Esquema no soportado: %s', esquema);
    end

    % Normalización: Es_promedio = (1/M) * sum(|s_i|^2) = 1
    energiaPromedio = mean(abs(tabla).^2);
    tabla = tabla / sqrt(energiaPromedio);
end

% ------------------------------------------------------------------------
function tabla = constelacionPam(M)
% M-PAM: niveles reales -(M-1), ..., -3, -1, 1, 3, ..., (M-1).
% Antes de normalizar, Es = (M^2 - 1)/3 (distancia mínima 2).
% La posición p (0 = nivel más negativo) recibe el código Gray de p, de
% modo que niveles vecinos difieren en un solo bit.
    p       = 0:M-1;
    niveles = 2*p - (M - 1);
    tabla   = zeros(1, M);
    tabla(binarioAGray(p) + 1) = niveles;
end

% ------------------------------------------------------------------------
function tabla = constelacionQam(M)
% M-QAM cuadrada: dos M-PAM independientes de L = sqrt(M) niveles.
% Los primeros k/2 bits eligen el nivel en fase (I) y los siguientes k/2
% el nivel en cuadratura (Q). Como cada eje usa Gray, los vecinos
% horizontales y verticales difieren en un solo bit.
% Antes de normalizar, Es = 2(M - 1)/3.
    L    = round(sqrt(M));
    pam  = constelacionPamSinNormalizar(L);
    b    = 0:M-1;
    bI   = floor(b / L);       % bits más significativos -> eje I
    bQ   = mod(b, L);          % bits menos significativos -> eje Q
    tabla = pam(bI + 1) + 1j * pam(bQ + 1);
end

% ------------------------------------------------------------------------
function tabla = constelacionPamSinNormalizar(L)
% Igual que constelacionPam, se usa como bloque de construcción de QAM.
    p       = 0:L-1;
    niveles = 2*p - (L - 1);
    tabla   = zeros(1, L);
    tabla(binarioAGray(p) + 1) = niveles;
end

% ------------------------------------------------------------------------
function tabla = constelacionPsk(M)
% M-PSK: M puntos sobre la circunferencia unitaria, fase 2*pi*p/M + fase0.
% La posición angular p recibe el código Gray de p, así que dos fases
% vecinas difieren en un solo bit.
% Para M >= 4 se rota pi/M: con M = 4 los puntos quedan en las diagonales
% y 4-PSK coincide exactamente con 4-QAM. Para M = 2 no se rota (BPSK
% sobre el eje real, igual a 2-PAM).
    if M == 2
        fase0 = 0;
    else
        fase0 = pi / M;
    end
    p     = 0:M-1;
    fases = 2*pi*p/M + fase0;
    tabla = zeros(1, M);
    tabla(binarioAGray(p) + 1) = exp(1j * fases);
end
