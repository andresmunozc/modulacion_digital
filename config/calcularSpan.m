function span = calcularSpan(p)
%CALCULARSPAN Duración del filtro RRC (en símbolos) según el roll-off.
%   span = calcularSpan(p)
%
%   El pulso RRC ideal dura infinito; en la simulación se recorta a
%   'span' símbolos. Sus colas decaen más lento cuanto menor es alpha
%   (con alpha = 0 es una sinc, que decae como 1/t). Si se recorta
%   demasiado, la cascada Tx-Rx deja de cumplir Nyquist y aparece ISI.
%
%   Regla usada (verificada por simulación):  span = 2 * ceil(1/alpha),
%   limitada entre SPAN_MINIMO y SPAN_MAXIMO. Ejemplos:
%     alpha >= 0.2 -> 10 símbolos     alpha = 0.1  -> 20
%     alpha = 0.05 -> 40              alpha = 0    -> SPAN_MAXIMO
%   Con alpha = 0 ni siquiera SPAN_MAXIMO elimina la ISI: el pulso de
%   Nyquist ideal no es realizable, por eso en la práctica alpha > 0.

    if p.rollOff > 0
        span = 2 * ceil(1 / p.rollOff);
    else
        span = p.SPAN_MAXIMO;
    end
    span = min(p.SPAN_MAXIMO, max(p.SPAN_MINIMO, span));
end
