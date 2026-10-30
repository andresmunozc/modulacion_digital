function agregarRutas()
%AGREGARRUTAS Agrega al path de MATLAB todas las carpetas del proyecto.
%   Se llama al inicio de main.m y de los scripts de prueba, para que
%   las funciones de transmisor, canal, receptor, etc. sean visibles.

    raiz = fileparts(mfilename('fullpath'));
    carpetas = {'config', 'utilidades', 'transmisor', 'canal', 'receptor', ...
                'metricas', 'graficas', 'gui', 'analisis', 'pruebas'};
    for i = 1:numel(carpetas)
        addpath(fullfile(raiz, carpetas{i}));
    end
end
