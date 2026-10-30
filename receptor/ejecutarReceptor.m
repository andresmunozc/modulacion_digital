function rx = ejecutarReceptor(senalRecibida, tx, p, sps, fs)
%EJECUTARRECEPTOR Bloque receptor completo.
%   rx = ejecutarReceptor(senalRecibida, tx, p, sps, fs)
%
%   demodulador coherente -> filtro acoplado RRC -> muestreo
%   -> decisor de mínima distancia -> demapeo
%
%   Usa del transmisor solo lo que el receptor conoce de antemano:
%   el pulso h, la constelación (tabla) y el número de símbolos.

    numSimbolos = numel(tx.simbolos);

    rx.senalBandaBase = demoduladorPasabanda(senalRecibida, p.fc, fs);
    rx.senalFiltrada  = filtroAcoplado(rx.senalBandaBase, tx.h, fs);
    rx.muestras       = muestrearSimbolos(rx.senalFiltrada, sps, p.SPAN_FILTRO, numSimbolos);

    % En PAM la información está solo en la rama I; la rama Q es solo ruido
    % y se descarta.
    if strcmp(p.esquema, 'PAM')
        rx.muestras = real(rx.muestras);
    end

    rx.indices = decisorMinimaDistancia(rx.muestras, tx.tabla);
    rx.bits    = demapearSimbolos(rx.indices, p.M);
end
