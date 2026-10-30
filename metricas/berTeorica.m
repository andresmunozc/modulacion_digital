function ber = berTeorica(esquema, M, ebN0Db)
%BERTEORICA BER teórica en AWGN con mapeo Gray.
%   ber = berTeorica(esquema, M, ebN0Db)
%
%   g = Eb/N0 lineal, k = log2(M), Q(x) = funcionQ(x).
%   Con Gray, un error de símbolo casi siempre cambia un solo bit, por eso
%   Pb ~ Ps / k.
%
%   M-PAM:  Ps = 2(M-1)/M * Q( sqrt(6 k g / (M^2 - 1)) )
%   M-QAM:  Ps ~ 4(1 - 1/sqrt(M)) * Q( sqrt(3 k g / (M - 1)) )
%   M-PSK:  M = 2 o 4: Pb = Q( sqrt(2 g) )   (exacta)
%           M > 4:     Ps ~ 2 Q( sqrt(2 k g) sin(pi/M) )
%
%   Para M = 2 y M = 4 (PAM, QAM, PSK) las expresiones son exactas.

    g = 10.^(ebN0Db / 10);
    k = log2(M);

    switch esquema
        case 'PAM'
            ps = 2*(M - 1)/M * funcionQ(sqrt(6*k*g / (M^2 - 1)));
            ber = ps / k;
        case 'QAM'
            ps = 4*(1 - 1/sqrt(M)) * funcionQ(sqrt(3*k*g / (M - 1)));
            ber = ps / k;
        case 'PSK'
            if M <= 4
                ber = funcionQ(sqrt(2*g));
            else
                ps = 2 * funcionQ(sqrt(2*k*g) * sin(pi/M));
                ber = ps / k;
            end
        otherwise
            error('berTeorica:esquema', 'Esquema no soportado: %s', esquema);
    end
end
