function tx = ejecutarTransmisor(p, sps, fs)
%EJECUTARTRANSMISOR Bloque transmisor completo.
%   tx = ejecutarTransmisor(p, sps, fs)
%
%   fuente de bits -> mapeo Gray -> conformación RRC -> modulador pasabanda
%
%   Devuelve una estructura con las señales de cada etapa (se usan para
%   las gráficas) y los valores de energía de referencia:
%     tx.bits, tx.simbolos, tx.tabla, tx.h
%     tx.senalBandaBase, tx.senalPasabanda, tx.t
%     tx.Es : energía promedio por símbolo = mean|a|^2 * integral h^2 = 1
%     tx.Eb : energía por bit, Eb = Es / k

    k = log2(p.M);

    tx.bits = generarBits(p.numBits, k);
    [tx.simbolos, tx.tabla] = mapearSimbolos(tx.bits, p.esquema, p.M);

    tx.h = filtroRaizCosenoAlzado(p.rollOff, sps, p.SPAN_FILTRO, fs);
    tx.senalBandaBase = conformarPulso(tx.simbolos, tx.h, sps);
    [tx.senalPasabanda, tx.t] = moduladorPasabanda(tx.senalBandaBase, p.fc, fs);

    % Energías de referencia (definidas por diseño, no estimadas):
    % la constelación tiene mean|a|^2 = 1 y el pulso tiene energía 1.
    energiaPulso = sum(tx.h.^2) / fs;
    tx.Es = mean(abs(tx.tabla).^2) * energiaPulso;
    tx.Eb = tx.Es / k;
end
