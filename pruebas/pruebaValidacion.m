%PRUEBAVALIDACION Verifica el manejo de entradas no permitidas (RNF1).
%   Ejecutar desde la carpeta raíz del proyecto:  run('pruebas/pruebaValidacion.m')
%
%   Cada caso modifica una entrada válida con un valor prohibido y
%   comprueba que validarParametros lo rechace, sin lanzar errores, y
%   señale el campo correcto.

clear; clc;
addpath(fullfile(fileparts(mfilename('fullpath')), '..'));   % raíz del proyecto
agregarRutas();

% Entradas válidas (como las leería la interfaz)
base.esquema = 'QAM';  base.M = 16;      base.rollOff = 0.5;  base.amplitud = 1;
base.fc = 10e3;        base.Rs = 1e3;    base.ebN0Db = 10;
base.ebN0Inicio = 0;   base.ebN0Fin = 12; base.ebN0Paso = 1;
base.numBits = 1e5;    base.semilla = 1;

fallos = 0;

% 1. Las entradas válidas deben aceptarse
[p, ok, msg] = validarParametros(base);
if ~ok
    fprintf('FALLA: se rechazó una entrada válida: %s\n', msg); fallos = fallos + 1;
else
    fprintf('Entrada válida aceptada (%d puntos de BER)\n\n', numel(p.ebN0RangoDb));
end

% 2. Casos prohibidos: {campo, valor, campo que debe marcarse}
casos = {
    'esquema',    'FSK', 'esquema'
    'M',          8,     'M'          % QAM no cuadrada
    'M',          6,     'M'          % no es potencia de 2
    'M',          NaN,   'M'          % texto no numérico
    'M',          1024,  'M'          % demasiado grande
    'rollOff',    1.5,   'rollOff'    % mayor que 1
    'rollOff',    -0.1,  'rollOff'
    'rollOff',    NaN,   'rollOff'
    'amplitud',   0,     'amplitud'
    'Rs',         -100,  'Rs'
    'fc',         0,     'fc'
    'fc',         500,   'fc'         % fc < (1+alpha)Rs/2: traslape
    'fc',         1e7,   'fc'         % demasiadas muestras por símbolo
    'ebN0Db',     100,   'ebN0Db'
    'ebN0Inicio', NaN,   'ebN0Inicio'
    'ebN0Fin',    -5,    'ebN0Fin'    % menor que el inicio
    'ebN0Paso',   0,     'ebN0Paso'
    'ebN0Paso',   0.1,   'ebN0Paso'   % demasiados puntos
    'numBits',    10,    'numBits'
    'numBits',    1e5+0.5, 'numBits'
    'numBits',    5e7,   'numBits'
    'semilla',    -1,    'semilla'
    'semilla',    2.5,   'semilla'
};

for c = 1:size(casos, 1)
    e = base;
    e.(casos{c, 1}) = casos{c, 2};
    try
        [~, ok, msg, campo] = validarParametros(e);
    catch err
        fprintf('FALLA: error no controlado con %s = %g: %s\n', casos{c, 1}, casos{c, 2}, err.message);
        fallos = fallos + 1;
        continue;
    end
    valorTexto = casos{c, 2};
    if isnumeric(valorTexto), valorTexto = num2str(valorTexto); end
    if ok
        fprintf('FALLA: se aceptó %s = %s\n', casos{c, 1}, valorTexto); fallos = fallos + 1;
    elseif ~strcmp(campo, casos{c, 3})
        fprintf('FALLA: %s = %s marcó el campo %s\n', casos{c, 1}, valorTexto, campo); fallos = fallos + 1;
    else
        fprintf('  %-10s = %-8s -> %s\n', casos{c, 1}, valorTexto, msg);
    end
end

% 3. Un caso límite que sí debe aceptarse: alpha = 0 y alpha = 1
for alpha = [0 1]
    e = base; e.rollOff = alpha;
    [~, ok] = validarParametros(e);
    if ~ok
        fprintf('FALLA: se rechazó alpha = %g\n', alpha); fallos = fallos + 1;
    end
end

if fallos == 0
    fprintf('\nTODAS LAS PRUEBAS DE VALIDACIÓN PASARON\n');
else
    fprintf('\n%d FALLOS EN LAS PRUEBAS DE VALIDACIÓN\n', fallos);
end
