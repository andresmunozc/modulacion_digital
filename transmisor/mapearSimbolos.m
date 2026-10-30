function [simbolos, tabla] = mapearSimbolos(bits, esquema, M)
%MAPEARSIMBOLOS Mapeo digital: convierte bits en símbolos complejos.
%   [simbolos, tabla] = mapearSimbolos(bits, esquema, M)
%
%   bits     : vector de 0 y 1 (longitud múltiplo de log2(M))
%   esquema  : 'PSK', 'QAM' o 'PAM'
%   M        : orden de la modulación
%   simbolos : vector fila de símbolos (complejos; en PAM la parte
%              imaginaria es cero)
%   tabla    : constelación usada (se reutiliza en el receptor)
%
%   Pasos:
%     1. Agrupar los bits de k = log2(M) en k  ->  entero b
%     2. Buscar el punto tabla(b+1) de la constelación Gray normalizada

    k        = log2(M);
    tabla    = construirConstelacion(esquema, M);
    enteros  = bitsAEntero(bits, k);
    simbolos = tabla(enteros + 1);
end
