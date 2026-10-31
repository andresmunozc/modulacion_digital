function [p, esValido, mensaje, campo] = validarParametros(e)
%VALIDARPARAMETROS Revisa las entradas del usuario y arma los parámetros.
%   [p, esValido, mensaje, campo] = validarParametros(e)
%
%   e : estructura con los valores ingresados (números; NaN si el texto
%       no era un número). Campos: esquema, M, rollOff, amplitud, fc, Rs,
%       ebN0Db, ebN0Inicio, ebN0Fin, ebN0Paso, numBits, semilla.
%   p        : parámetros listos para simular (si esValido es true)
%   esValido : true si todas las entradas son correctas
%   mensaje  : explicación del primer error encontrado
%   campo    : nombre del campo con error ('' si no hay), para resaltarlo
%
%   Nunca lanza errores: la interfaz muestra el mensaje y sigue
%   funcionando (RNF1).

    p = parametrosPorDefecto();
    esValido = false;

    % --- Esquema ---
    campo = 'esquema';
    if ~any(strcmp(e.esquema, p.ESQUEMAS_VALIDOS))
        mensaje = 'Seleccione un esquema de modulación válido (PSK, QAM o PAM).';
        return;
    end

    % --- Orden M ---
    campo = 'M';
    [ordenValido, mensaje] = validarOrden(e.esquema, e.M, p.M_MAXIMO);
    if ~ordenValido
        return;
    end

    % --- Roll-off ---
    campo = 'rollOff';
    if ~esNumero(e.rollOff) || e.rollOff < 0 || e.rollOff > 1
        mensaje = 'El factor de roll-off debe ser un número entre 0 y 1.';
        return;
    end

    % --- Amplitud ---
    campo = 'amplitud';
    if ~esNumero(e.amplitud) || e.amplitud <= 0
        mensaje = 'La amplitud A debe ser un número mayor que 0.';
        return;
    end

    % --- Tasa de símbolo ---
    campo = 'Rs';
    if ~esNumero(e.Rs) || e.Rs <= 0
        mensaje = 'La tasa de símbolo Rs debe ser un número mayor que 0.';
        return;
    end

    % --- Frecuencia portadora (el detalle se revisa con el muestreo) ---
    campo = 'fc';
    if ~esNumero(e.fc) || e.fc <= 0
        mensaje = 'La frecuencia portadora fc debe ser un número mayor que 0 Hz.';
        return;
    end

    % --- Eb/N0 para ojo y constelación ---
    campo = 'ebN0Db';
    if ~esNumero(e.ebN0Db) || e.ebN0Db < p.EBN0_MIN_DB || e.ebN0Db > p.EBN0_MAX_DB
        mensaje = sprintf('Eb/N0 debe estar entre %d y %d dB.', p.EBN0_MIN_DB, p.EBN0_MAX_DB);
        return;
    end

    % --- Rango de Eb/N0 para la curva BER ---
    campo = 'ebN0Inicio';
    if ~esNumero(e.ebN0Inicio) || e.ebN0Inicio < p.EBN0_MIN_DB || e.ebN0Inicio > p.EBN0_MAX_DB
        mensaje = sprintf('Eb/N0 inicial debe estar entre %d y %d dB.', p.EBN0_MIN_DB, p.EBN0_MAX_DB);
        return;
    end
    campo = 'ebN0Fin';
    if ~esNumero(e.ebN0Fin) || e.ebN0Fin < p.EBN0_MIN_DB || e.ebN0Fin > p.EBN0_MAX_DB
        mensaje = sprintf('Eb/N0 final debe estar entre %d y %d dB.', p.EBN0_MIN_DB, p.EBN0_MAX_DB);
        return;
    end
    if e.ebN0Fin <= e.ebN0Inicio
        mensaje = 'Eb/N0 final debe ser mayor que Eb/N0 inicial.';
        return;
    end
    campo = 'ebN0Paso';
    if ~esNumero(e.ebN0Paso) || e.ebN0Paso <= 0
        mensaje = 'El paso de Eb/N0 debe ser un número mayor que 0.';
        return;
    end
    rango = e.ebN0Inicio : e.ebN0Paso : e.ebN0Fin;
    if numel(rango) < 2 || numel(rango) > p.MAX_PUNTOS_BER
        mensaje = sprintf(['Con ese paso la curva BER tendría %d puntos; ' ...
                           'debe tener entre 2 y %d.'], numel(rango), p.MAX_PUNTOS_BER);
        return;
    end

    % --- Número de bits ---
    campo = 'numBits';
    if ~esNumero(e.numBits) || e.numBits ~= round(e.numBits) || ...
            e.numBits < p.NUM_BITS_MIN || e.numBits > p.NUM_BITS_MAX
        mensaje = sprintf('El número de bits debe ser un entero entre %g y %g.', ...
                          p.NUM_BITS_MIN, p.NUM_BITS_MAX);
        return;
    end

    % --- Semilla ---
    campo = 'semilla';
    if ~esNumero(e.semilla) || e.semilla ~= round(e.semilla) || ...
            e.semilla < 0 || e.semilla >= 2^32
        mensaje = 'La semilla debe ser un entero entre 0 y 4294967295.';
        return;
    end

    % --- Armar los parámetros ---
    p.esquema     = e.esquema;
    p.M           = e.M;
    p.rollOff     = e.rollOff;
    p.amplitud    = e.amplitud;
    p.fc          = e.fc;
    p.Rs          = e.Rs;
    p.ebN0Db      = e.ebN0Db;
    p.ebN0RangoDb = rango;
    p.numBits     = e.numBits;
    p.semilla     = e.semilla;

    % --- Relación entre fc, Rs y alpha (Nyquist y traslape espectral) ---
    campo = 'fc';
    [sps, ~, muestreoValido, mensaje] = calcularMuestreo(p);
    if ~muestreoValido
        return;
    end

    % --- Memoria: longitud de la señal muestreada ---
    campo = 'numBits';
    numSimbolos = ceil(p.numBits / log2(p.M));
    numMuestras = (numSimbolos + 2*calcularSpan(p)) * sps;
    if numMuestras > p.MAX_MUESTRAS
        mensaje = sprintf(['La señal tendría %.2g muestras (máximo %.2g). ' ...
                           'Reduzca el número de bits o la relación fc/Rs.'], ...
                           numMuestras, p.MAX_MUESTRAS);
        return;
    end

    esValido = true;
    mensaje  = '';
    campo    = '';
end

% ------------------------------------------------------------------------
function resultado = esNumero(x)
% Verdadero si x es un número real, escalar y finito.
    resultado = isnumeric(x) && isscalar(x) && isreal(x) && isfinite(x);
end
