function lineas = generarTextoMetricas(p, m, res)
%GENERARTEXTOMETRICAS Arma el texto del panel de métricas (RF4).
%   lineas = generarTextoMetricas(p, m, res)
%
%   p   : parámetros
%   m   : métricas (calcularMetricas)
%   res : resultado de simularSistema
%   lineas : celda de textos, una línea por elemento

    if res.numErrores == 0
        textoBer = sprintf('< %.1e (0 errores)', 1/numel(res.tx.bits));
    else
        textoBer = sprintf('%.3e (%d errores)', res.ber, res.numErrores);
    end

    lineas = {
        sprintf('Sistema: %d-%s, alpha = %.2f', p.M, p.esquema, p.rollOff)
        ''
        sprintf('Eficiencia espectral: %.3f bit/s/Hz', m.eficiencia)
        sprintf('Ancho de banda (pasab.): %.1f Hz', m.anchoBanda)
        sprintf('Ancho de banda (b. base): %.1f Hz', m.anchoBandaBase)
        sprintf('Tasa de bit Rb: %.1f bit/s', m.Rb)
        ''
        sprintf('Energía de símbolo Es: %.4g J', m.EsTeorica)
        sprintf('   medida en la señal: %.4g J', m.EsMedida)
        sprintf('Energía de bit Eb: %.4g J', m.EbTeorica)
        sprintf('Potencia señal modulada: %.4g W', m.potenciaTeorica)
        sprintf('   medida en la señal: %.4g W', m.potenciaMedida)
        ''
        sprintf('N0 a %g dB: %.4g W/Hz', p.ebN0Db, res.N0)
        sprintf('BER a %g dB: %s', p.ebN0Db, textoBer)
        ''
        sprintf('Muestreo: fs = %.1f Hz (%d muestras/símbolo)', m.fs, m.sps)
    };
end
