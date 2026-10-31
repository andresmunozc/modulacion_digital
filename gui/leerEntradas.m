function e = leerEntradas(controles)
%LEERENTRADAS Lee los controles de la interfaz y convierte el texto a número.
%   e = leerEntradas(controles)
%
%   str2double devuelve NaN cuando el texto no es un número (por ejemplo
%   "abc" o una celda vacía); validarParametros detecta ese NaN y muestra
%   el mensaje correspondiente, sin que la aplicación se detenga.
%   Se acepta coma decimal (0,5) además de punto (0.5).

    e.esquema = controles.esquema.Value;

    nombres = {'M', 'rollOff', 'amplitud', 'fc', 'Rs', 'ebN0Db', ...
               'ebN0Inicio', 'ebN0Fin', 'ebN0Paso', 'numBits', 'semilla'};
    for i = 1:numel(nombres)
        texto = strtrim(controles.(nombres{i}).Value);
        texto = strrep(texto, ',', '.');
        e.(nombres{i}) = str2double(texto);
    end
end
