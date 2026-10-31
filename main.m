%MAIN Punto de entrada del simulador de comunicación digital.
%   Ejecutar desde la carpeta raíz del proyecto:  main
%
%   Agrega las carpetas del proyecto al path y abre la interfaz gráfica.
%
%   Proyecto II - Comunicaciones Digitales 2026 II, Universidad del Cauca.
%   Simulación M-PAM, M-QAM y M-PSK: mapeo, conformación de pulso RRC,
%   modulación pasabanda, canal AWGN, demodulación coherente, filtro
%   acoplado, decisor y demapeo.

clc;
addpath(fileparts(mfilename('fullpath')));
agregarRutas();
crearInterfaz();
