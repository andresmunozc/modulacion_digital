function fig = crearInterfaz()
%CREARINTERFAZ Construye la ventana del simulador (RF1).
%   fig = crearInterfaz()
%
%   Izquierda: panel de parámetros (campos de texto, para poder mostrar
%   mensajes propios cuando un valor no es válido).
%   Derecha: las cinco gráficas (RF3) y el panel de métricas (RF4).
%
%   Cada vez que el usuario cambia un valor, se vuelve a simular y se
%   actualizan todas las gráficas (actualizarInterfaz).

    p = parametrosPorDefecto();

    fig = uifigure('Name', 'Simulador de sistema de comunicación digital', ...
                   'Position', [40 40 1450 820]);

    principal = uigridlayout(fig, [1 2]);
    principal.ColumnWidth = {300, '1x'};

    % ------------------------------------------------------------------
    % Panel de parámetros
    % ------------------------------------------------------------------
    panel = uipanel(principal, 'Title', 'Parámetros del sistema', 'FontWeight', 'bold');
    g = uigridlayout(panel, [16 2]);
    g.ColumnWidth = {'1.35x', '1x'};
    g.RowHeight = [repmat({26}, 1, 15), {'1x'}];   % la última fila crece

    controles.esquema = uidropdown(g, 'Items', p.ESQUEMAS_VALIDOS, 'Value', p.esquema);
    ubicar(g, 1, 'Esquema de modulación', controles.esquema);

    controles.M          = campoTexto(g, 2,  'Orden M',                    p.M);
    controles.rollOff    = campoTexto(g, 3,  'Roll-off α (0 a 1)',         p.rollOff);
    controles.amplitud   = campoTexto(g, 4,  'Amplitud A',                 p.amplitud);
    controles.fc         = campoTexto(g, 5,  'Frecuencia portadora [Hz]',  p.fc);
    controles.Rs         = campoTexto(g, 6,  'Tasa de símbolo [sím/s]',    p.Rs);
    controles.ebN0Db     = campoTexto(g, 7,  'Eb/N0 ojo y const. [dB]',    p.ebN0Db);

    titulo = uilabel(g, 'Text', 'Curva BER', 'FontWeight', 'bold');
    titulo.Layout.Row = 8; titulo.Layout.Column = [1 2];

    controles.ebN0Inicio = campoTexto(g, 9,  'Eb/N0 inicial [dB]',         p.ebN0RangoDb(1));
    controles.ebN0Fin    = campoTexto(g, 10, 'Eb/N0 final [dB]',           p.ebN0RangoDb(end));
    controles.ebN0Paso   = campoTexto(g, 11, 'Paso [dB]',                  p.ebN0RangoDb(2) - p.ebN0RangoDb(1));
    controles.numBits    = campoTexto(g, 12, 'Número de bits',             p.numBits);
    controles.semilla    = campoTexto(g, 13, 'Semilla aleatoria',          p.semilla);

    boton = uibutton(g, 'push', 'Text', 'Simular', 'FontWeight', 'bold');
    boton.Layout.Row = 15; boton.Layout.Column = [1 2];

    estado = uilabel(g, 'Text', '', 'WordWrap', 'on', 'VerticalAlignment', 'top');
    estado.Layout.Row = 16; estado.Layout.Column = [1 2];

    % ------------------------------------------------------------------
    % Gráficas y métricas
    % ------------------------------------------------------------------
    graficas = uigridlayout(principal, [2 3]);

    ejes.ojo          = crearEjes(graficas, 1, 1);
    ejes.constelacion = crearEjes(graficas, 1, 2);
    ejes.ber          = crearEjes(graficas, 1, 3);
    ejes.espectroBase = crearEjes(graficas, 2, 1);
    ejes.espectroPasa = crearEjes(graficas, 2, 2);

    panelMetricas = uipanel(graficas, 'Title', 'Métricas', 'FontWeight', 'bold');
    panelMetricas.Layout.Row = 2; panelMetricas.Layout.Column = 3;
    gm = uigridlayout(panelMetricas, [1 1]);
    textoMetricas = uitextarea(gm, 'Editable', 'off', 'FontName', 'Consolas', 'FontSize', 12);

    % ------------------------------------------------------------------
    % Estado compartido y callbacks
    % ------------------------------------------------------------------
    datos.controles     = controles;
    datos.ejes          = ejes;
    datos.textoMetricas = textoMetricas;
    datos.estado        = estado;
    datos.ocupado       = false;     % hay una simulación en curso
    datos.pendiente     = false;     % hubo cambios durante la simulación
    fig.UserData = datos;

    nombres = fieldnames(controles);
    for i = 1:numel(nombres)
        controles.(nombres{i}).ValueChangedFcn = @(~, ~) actualizarInterfaz(fig);
    end
    boton.ButtonPushedFcn = @(~, ~) actualizarInterfaz(fig);

    % Primera simulación con los valores por defecto
    actualizarInterfaz(fig);
end

% ------------------------------------------------------------------------
function campo = campoTexto(g, fila, etiqueta, valor)
% Crea una etiqueta y un campo de texto en la fila indicada.
    campo = uieditfield(g, 'text', 'Value', num2str(valor));
    ubicar(g, fila, etiqueta, campo);
end

% ------------------------------------------------------------------------
function ubicar(g, fila, etiqueta, control)
% Coloca la etiqueta en la columna 1 y el control en la columna 2.
    texto = uilabel(g, 'Text', etiqueta);
    texto.Layout.Row = fila;     texto.Layout.Column = 1;
    control.Layout.Row = fila;   control.Layout.Column = 2;
end

% ------------------------------------------------------------------------
function ax = crearEjes(g, fila, columna)
% Crea unos ejes en la celda indicada de la cuadrícula.
    ax = uiaxes(g);
    ax.Layout.Row = fila;
    ax.Layout.Column = columna;
end
