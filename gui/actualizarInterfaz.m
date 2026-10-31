function actualizarInterfaz(fig)
%ACTUALIZARINTERFAZ Valida, simula y redibuja todo. Callback de la interfaz.
%   actualizarInterfaz(fig)
%
%   1. Lee los controles y valida las entradas. Si hay un error, marca el
%      campo en rojo y muestra un mensaje (uialert) sin detener la app.
%   2. Simula el sistema al Eb/N0 elegido (ojo, constelación, espectros,
%      métricas) y calcula la curva BER en el rango elegido.
%   3. Cualquier error inesperado también se muestra en un mensaje; la
%      aplicación nunca queda bloqueada (RNF1).
%
%   Si el usuario cambia algo mientras se simula, el cambio se anota en
%   "pendiente" y se vuelve a simular al terminar.

    if ~isvalid(fig)
        return;
    end
    if fig.UserData.ocupado
        fig.UserData.pendiente = true;
        return;
    end

    fig.UserData.ocupado = true;
    limpieza = onCleanup(@() liberarInterfaz(fig)); %#ok<NASGU> se usa al salir

    repetir = true;
    while repetir
        fig.UserData.pendiente = false;
        simularYDibujar(fig);
        repetir = isvalid(fig) && fig.UserData.pendiente;
    end
end

% ------------------------------------------------------------------------
function simularYDibujar(fig)
    ROLLOFF_AVISO = 0.05;    % debajo de este alpha se avisa de ISI residual

    datos = fig.UserData;

    % --- 1. Validación ---
    entradas = leerEntradas(datos.controles);
    [p, esValido, mensaje, campo] = validarParametros(entradas);
    marcarCampo(datos.controles, campo);
    if ~esValido
        datos.estado.Text = 'Corrija el parámetro marcado en rojo.';
        datos.estado.FontColor = [0.75 0 0];
        uialert(fig, mensaje, 'Parámetro no válido', 'Icon', 'warning');
        return;
    end

    datos.estado.Text = 'Simulando...';
    datos.estado.FontColor = [0 0 0];
    drawnow;

    % --- 2. Simulación y gráficas ---
    try
        res = simularSistema(p, p.ebN0Db);
        [berSim, berTeo] = curvaBer(p);
        m = calcularMetricas(p, res);

        ejes = datos.ejes;
        graficarOjo(ejes.ojo, res.rx.senalFiltrada, res.sps, res.tx.span, numel(res.tx.simbolos));
        graficarConstelacion(ejes.constelacion, res.rx.muestras, res.tx.tabla);
        graficarBer(ejes.ber, p.ebN0RangoDb, berSim, berTeo, sprintf('%d-%s', p.M, p.esquema));
        graficarEspectro(ejes.espectroBase, res.tx.senalBandaBase, res.fs, 'bandaBase', p);
        graficarEspectro(ejes.espectroPasa, res.senalRecibida, res.fs, 'pasabanda', p);

        datos.textoMetricas.Value = generarTextoMetricas(p, m, res);
        datos.estado.Text = sprintf('Listo: %d-%s, %d bits simulados, filtro RRC de %d símbolos.', ...
                                    p.M, p.esquema, numel(res.tx.bits), res.tx.span);
        if p.rollOff < ROLLOFF_AVISO
            datos.estado.Text = [datos.estado.Text, sprintf([' Aviso: con alpha < %g el pulso ' ...
                'casi es una sinc ideal, que no se puede truncar sin ISI; la BER simulada ' ...
                'queda por encima de la teórica.'], ROLLOFF_AVISO)];
        end
    catch err
        if ~isvalid(fig)
            return;      % el usuario cerró la ventana durante la simulación
        end
        datos.estado.Text = 'La simulación no se pudo completar.';
        datos.estado.FontColor = [0.75 0 0];
        uialert(fig, sprintf('Error durante la simulación:\n%s', err.message), ...
                'Error', 'Icon', 'error');
    end
end

% ------------------------------------------------------------------------
function marcarCampo(controles, campoConError)
% Pone en rojo claro el campo con error y en blanco los demás.
    COLOR_NORMAL = [1 1 1];
    COLOR_ERROR  = [1 0.82 0.82];

    nombres = fieldnames(controles);
    for i = 1:numel(nombres)
        if strcmp(nombres{i}, campoConError)
            controles.(nombres{i}).BackgroundColor = COLOR_ERROR;
        else
            controles.(nombres{i}).BackgroundColor = COLOR_NORMAL;
        end
    end
end

% ------------------------------------------------------------------------
function liberarInterfaz(fig)
% Se ejecuta siempre al terminar (incluso si hubo un error).
    if isvalid(fig)
        fig.UserData.ocupado = false;
    end
end
