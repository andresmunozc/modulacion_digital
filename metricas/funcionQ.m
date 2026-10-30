function q = funcionQ(x)
%FUNCIONQ Función Q gaussiana: probabilidad de que N(0,1) supere x.
%   q = funcionQ(x) = 0.5 * erfc(x / sqrt(2))
%
%   Se escribe con erfc (función matemática básica de MATLAB) en lugar de
%   qfunc, que pertenece al Communications Toolbox.

    q = 0.5 * erfc(x / sqrt(2));
end
