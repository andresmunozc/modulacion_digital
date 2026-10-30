function [esValido, mensaje] = validarOrden(esquema, M, mMaximo)
%VALIDARORDEN Verifica que el orden M sea permitido para el esquema.
%   [esValido, mensaje] = validarOrden(esquema, M, mMaximo)
%
%   Reglas:
%     - M debe ser un entero potencia de 2, con 2 <= M <= mMaximo,
%       para que cada símbolo lleve k = log2(M) bits enteros.
%     - En QAM, M además debe ser un cuadrado perfecto (4, 16, 64, 256)
%       porque se construye como dos PAM de raiz(M) niveles (I y Q).
%
%   No lanza errores: devuelve esValido = false y un mensaje explicativo,
%   para que la interfaz lo muestre sin detener la aplicación.

    esValido = false;

    if ~isnumeric(M) || ~isscalar(M) || ~isfinite(M) || M ~= round(M)
        mensaje = 'El orden M debe ser un número entero.';
        return;
    end
    if M < 2 || M > mMaximo
        mensaje = sprintf('El orden M debe estar entre 2 y %d.', mMaximo);
        return;
    end
    k = log2(M);
    if k ~= round(k)
        mensaje = 'El orden M debe ser potencia de 2 (2, 4, 8, 16, ...).';
        return;
    end
    if strcmp(esquema, 'QAM')
        L = sqrt(M);
        if L ~= round(L)
            mensaje = 'En M-QAM el orden debe ser un cuadrado perfecto (4, 16, 64, 256).';
            return;
        end
    end

    esValido = true;
    mensaje  = '';
end
