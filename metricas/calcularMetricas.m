function m = calcularMetricas(p, res)
%CALCULARMETRICAS Métricas del sistema (RF4), teóricas y medidas.
%   m = calcularMetricas(p, res)
%
%   p   : parámetros
%   res : resultado de simularSistema
%
%   Definiciones (k = log2 M, Ts = 1/Rs):
%     Tasa de bit:          Rb = k * Rs                        [bit/s]
%     Ancho de banda:       B  = (1 + alpha) * Rs              [Hz]
%       Pasabanda, centrado en fc. En banda base la señal ocupa
%       W = B/2 = (1 + alpha) Rs / 2; al modular aparecen las dos bandas
%       laterales (fc - W ... fc + W) y el ancho se duplica.
%     Eficiencia espectral: eta = Rb / B = k / (1 + alpha)     [bit/s/Hz]
%     Energía de símbolo:   Es (fórmula según el esquema y A)  [J]
%     Energía de bit:       Eb = Es / k                        [J]
%     Potencia:             P  = Es / Ts = Es * Rs             [W]
%
%   Valores medidos sobre la señal pasabanda simulada (sin las colas de
%   los filtros), para verificar las fórmulas:
%     P_medida  = promedio de s(t)^2
%     Es_medida = P_medida * Ts

    k = log2(p.M);

    m.Rb          = k * p.Rs;
    m.anchoBanda  = (1 + p.rollOff) * p.Rs;
    m.anchoBandaBase = m.anchoBanda / 2;
    m.eficiencia  = m.Rb / m.anchoBanda;

    m.EsTeorica   = energiaSimboloTeorica(p.esquema, p.M, p.amplitud);
    m.EbTeorica   = m.EsTeorica / k;
    m.potenciaTeorica = m.EsTeorica * p.Rs;

    % Parte estable de la señal: se descartan span/2 símbolos al inicio y
    % al final, donde el filtro todavía no ha "llenado" sus colas.
    colas  = res.tx.span * res.sps;
    s      = res.tx.senalPasabanda(colas + 1 : end - colas);
    m.potenciaMedida = mean(s.^2);
    m.EsMedida       = m.potenciaMedida / p.Rs;

    m.sps = res.sps;
    m.fs  = res.fs;
end
