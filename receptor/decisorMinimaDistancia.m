function indices = decisorMinimaDistancia(muestras, tabla)
%DECISORMINIMADISTANCIA Elige el punto de la constelación más cercano.
%   indices = decisorMinimaDistancia(muestras, tabla)
%
%   muestras : muestras recibidas (una por símbolo)
%   tabla    : constelación de referencia (la misma del transmisor)
%   indices  : posición (1..M) del punto elegido para cada muestra
%
%   Con símbolos equiprobables y ruido gaussiano, el detector de máxima
%   verosimilitud (ML) es el de mínima distancia euclidiana:
%       a_hat = arg min_i |y - s_i|^2
%   Se procesa por bloques para no crear matrices enormes (N x M).

    TAMANO_BLOQUE = 20000;

    numMuestras = numel(muestras);
    indices = zeros(1, numMuestras);
    for inicio = 1:TAMANO_BLOQUE:numMuestras
        fin = min(inicio + TAMANO_BLOQUE - 1, numMuestras);
        bloque = muestras(inicio:fin);
        distancias = abs(bloque(:) - tabla(:).').^2;   % matriz bloque x M
        [~, indices(inicio:fin)] = min(distancias, [], 2);
    end
end
