function tx = ejecutarTransmisor(p, sps, fs)
%EJECUTARTRANSMISOR Bloque transmisor completo.
%   tx = ejecutarTransmisor(p, sps, fs)
%
%   fuente de bits -> mapeo Gray -> conformación RRC -> modulador pasabanda
%
%   Devuelve una estructura con las señales de cada etapa (se usan para
%   las gráficas) y los valores de energía de referencia:
%     tx.bits, tx.simbolos, tx.tabla, tx.h, tx.span
%     tx.senalBandaBase, tx.senalPasabanda, tx.t
%     tx.Es : energía promedio por símbolo [J] (según la amplitud A)
%     tx.Eb : energía por bit, Eb = Es / k

    k = log2(p.M);

    % Energía por símbolo que corresponde a la amplitud A elegida.
    % La constelación sale de construirConstelacion con Es = 1 y se escala
    % por sqrt(Es) para que tenga exactamente esa energía.
    EsDiseno = energiaSimboloTeorica(p.esquema, p.M, p.amplitud);

    tx.bits = generarBits(p.numBits, k);
    [simbolosUnitarios, tablaUnitaria] = mapearSimbolos(tx.bits, p.esquema, p.M);
    tx.simbolos = sqrt(EsDiseno) * simbolosUnitarios;
    tx.tabla    = sqrt(EsDiseno) * tablaUnitaria;

    tx.span = calcularSpan(p);       % duración del filtro según alpha
    tx.h = filtroRaizCosenoAlzado(p.rollOff, sps, tx.span, fs);
    tx.senalBandaBase = conformarPulso(tx.simbolos, tx.h, sps);
    [tx.senalPasabanda, tx.t] = moduladorPasabanda(tx.senalBandaBase, p.fc, fs);

    % Energías de referencia: Es = mean|a|^2 * (energía del pulso = 1)
    energiaPulso = sum(tx.h.^2) / fs;
    tx.Es = mean(abs(tx.tabla).^2) * energiaPulso;
    tx.Eb = tx.Es / k;
end
