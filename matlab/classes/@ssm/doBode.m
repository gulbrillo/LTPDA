% DOBODE makes a bode computation from the given inputs to outputs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: makes a bode computation from all the inputs to all outputs.
%
% CALL:    varargout = doBode(a, b, c, d, w, Ts)
%
% INPUTS:
%         'sys' - ssm object
%         'inputnames, statenames, outputnames'  - 3 cellstr
%
% OUTPUTS:
%
%        'as' - array of output TFs containing the requested responses.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = doBode(a, b, c, d, w, Ts)

    f = w/(2*pi);

    %% dealing with timestep
    if(Ts ~= 0)
        % Compute discrete freq:
        f_disc = f*Ts;
        % Compute z = e^jw (with w discrete)
        z = exp(1i*2*pi*f_disc);
    end

    %% getting matrices properly ordered

    %% stop warnings
    s = warning;
    warning('off','MATLAB:nearlySingularMatrix'); % turn all warnings off

    %% looping over SISO systems
    Ni = size(b,2);
    No = size(c,1);
    G = zeros(No,Ni,length(f));
    G2 = zeros(No,Ni,length(f));
    %% compute responses
    % To conserve accuracy, the system is transformed to Hessenberg form [1]
    % Laub, A.J., "Efficient Multivariable Frequency Response Computations",
    % IEEE Transactions on Automatic Control, AC-26 (1981), pp. 407-408

    % This transformation leads to a faster resolution and at the
    % same time to a more accurate and precise answer of C*(jw - A)^-1 *B + D

    reduce_a = a;
    reduce_c = c;

    %% loop on inputs
    if (Ts == 0)
        for ii=1:Ni
            reduce_b = b(:,ii);
            reduce_d = d(:,ii);
            [num,den] = ss2tf(reduce_a,reduce_b,reduce_c,reduce_d);
            denr = polyval(den, 2*pi*1i*f);
            for jj = 1:No
                numr = polyval(num(jj,:), 2*pi*1i*f);
                G(jj,ii,:) = numr./denr;
            end
        end
    else
        [T,H]=hess(reduce_a);
        % Step 1:
        P = reduce_c*T;
        reduce_b = b(:,1:Ni);
        reduce_d = d(1:No,1:Ni);
        Q = T'*reduce_b;
        I = eye(size(reduce_a));

        %% time discrete
        for ff = 1:length(f)
            G(1:No,1:Ni,ff) = (P/(z(ff)*I - H))*(Q) + reduce_d;
        end
    end

    %% execute warnings
    [msg, msgid] = lastwarn;
    if(strcmp(msgid,'MATLAB:nearlySingularMatrix') == 1)
        %warning('This frequency response may be unaccurate because the system matrix is close to singular or badly scaled.') %#ok<WNTAG>
    end
    warning(s)  % restore the warning state

    %% output
    varargout = {G};
end


