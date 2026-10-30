function res = simularSistema(p, ebN0Db)
%SIMULARSISTEMA Ejecuta la cadena completa transmisor -> canal -> receptor.
%   res = simularSistema(p, ebN0Db)
%
%   p      : parámetros (ver parametrosPorDefecto)
%   ebN0Db : Eb/N0 del canal [dB]; usar Inf para un canal sin ruido
%   res    : estructura con tx, rx, señal recibida, N0, BER, sps y fs
%
%   La semilla se fija aquí, así dos ejecuciones con los mismos
%   parámetros dan exactamente el mismo resultado (RNF3).

    [sps, fs, esValido, mensaje] = calcularMuestreo(p);
    if ~esValido
        error('simularSistema:muestreo', '%s', mensaje);
    end

    rng(p.semilla);

    % --- Transmisor ---
    tx = ejecutarTransmisor(p, sps, fs);

    % --- Canal ---
    if isinf(ebN0Db)
        senalRecibida = tx.senalPasabanda;
        N0 = 0;
    else
        [senalRecibida, N0] = canalAwgn(tx.senalPasabanda, tx.Eb, ebN0Db, fs);
    end

    % --- Receptor ---
    rx = ejecutarReceptor(senalRecibida, tx, p, sps, fs);

    % --- Desempeño ---
    [ber, numErrores] = calcularBer(tx.bits, rx.bits);

    res.tx = tx;
    res.rx = rx;
    res.senalRecibida = senalRecibida;
    res.N0 = N0;
    res.ber = ber;
    res.numErrores = numErrores;
    res.sps = sps;
    res.fs = fs;
end
