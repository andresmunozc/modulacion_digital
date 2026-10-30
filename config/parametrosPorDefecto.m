function p = parametrosPorDefecto()
%PARAMETROSPORDEFECTO Valores iniciales y constantes del sistema.
%   p = parametrosPorDefecto() devuelve una estructura con todos los
%   parámetros que usa la simulación. La interfaz gráfica parte de estos
%   valores y el usuario puede modificarlos.
%
%   Campos de configuración (modificables por el usuario):
%     esquema      : 'PSK', 'QAM' o 'PAM'
%     M            : orden de la modulación (número de símbolos)
%     rollOff      : factor de roll-off del filtro RRC, 0 <= alpha <= 1
%     fc           : frecuencia portadora [Hz]
%     Rs           : tasa de símbolo [símbolos/s]
%     ebN0Db       : Eb/N0 para ojo y constelación [dB]
%     ebN0RangoDb  : vector de Eb/N0 para la curva BER [dB]
%     numBits      : número de bits a transmitir
%     semilla      : semilla del generador aleatorio (reproducibilidad)
%
%   Constantes (no modificables desde la interfaz):
%     ESQUEMAS_VALIDOS : lista de esquemas soportados
%     M_MAXIMO         : orden máximo permitido
%     SPAN_FILTRO      : duración del filtro RRC en símbolos
%     SPS_MINIMO       : muestras por símbolo mínimas
%     SPS_MAXIMO       : muestras por símbolo máximas (límite de memoria)
%     MARGEN_NYQUIST   : fs >= MARGEN_NYQUIST * 2 * frecuencia máxima

    % --- Configuración modificable ---
    p.esquema     = 'QAM';
    p.M           = 4;
    p.rollOff     = 0.5;
    p.fc          = 10e3;        % 10 kHz
    p.Rs          = 1e3;         % 1000 símbolos/s
    p.ebN0Db      = 10;
    p.ebN0RangoDb = 0:1:12;
    p.numBits     = 1e5;
    p.semilla     = 1;

    % --- Constantes ---
    p.ESQUEMAS_VALIDOS = {'PSK', 'QAM', 'PAM'};
    p.M_MAXIMO         = 256;
    p.SPAN_FILTRO      = 10;     % el RRC dura 10 símbolos
    p.SPS_MINIMO       = 8;      % al menos 8 muestras por símbolo
    p.SPS_MAXIMO       = 400;    % evita vectores de cientos de millones de muestras
    p.MARGEN_NYQUIST   = 1.25;   % 25 % por encima del mínimo de Nyquist
end
