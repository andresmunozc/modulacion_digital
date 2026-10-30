function Es = energiaSimboloTeorica(esquema, M, A)
%ENERGIASIMBOLOTEORICA Energía promedio por símbolo de la constelación.
%   Es = energiaSimboloTeorica(esquema, M, A)
%
%   Con símbolos equiprobables, Es = (1/M) * sum |s_i|^2 (el pulso tiene
%   energía unitaria, así que no modifica el resultado).
%
%   M-PAM, niveles +-A, +-3A, ..., +-(M-1)A:
%       Es = (A^2 / M) * sum (2i - 1 - M)^2 = (M^2 - 1) A^2 / 3
%   M-QAM cuadrada = dos PAM de sqrt(M) niveles (I y Q):
%       Es = 2 * (M - 1) A^2 / 3
%   M-PSK, todos los puntos en un círculo de radio A:
%       Es = A^2
%
%   Consecuencia: al subir M con A fija, PAM y QAM gastan más energía por
%   símbolo; PSK no, pero sus puntos quedan más juntos.

    switch esquema
        case 'PAM'
            Es = (M^2 - 1) * A^2 / 3;
        case 'QAM'
            Es = 2 * (M - 1) * A^2 / 3;
        case 'PSK'
            Es = A^2;
        otherwise
            error('energiaSimboloTeorica:esquema', 'Esquema no soportado: %s', esquema);
    end
end
