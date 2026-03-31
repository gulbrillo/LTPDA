% CPF finds the partial fraction expansion of the ratio of two polynomials A(s)/B(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: CPF finds the residues, poles and direct terms of the
% partial fraction expansion of the ratio of two polynomials A(s)/B(s).
% This function assumes that the input continous filter is written in the
% rational form or in poles, zeros and gain factorization:
%
%         A(s)    a(1)s^m + a(2)s^{m-1} + ... + a(m+1)
%   H(s)= ---- = --------------------------------------
%         B(s)    b(1)s^n + b(2)s^{n-1} + ... + b(n+1)
%
% or
%
%         A(s)     (s-z1)...(s-zn)
%   H(s)= ---- = g ----------------
%         B(s)     (s-p1)...(s-pn)
%
%
%   It inputs a plist containing the coefficients vectors and the
%   repeated-root tolerance.
%   Eg:
%       A = [a(1), a(2), ..., a(m+1)]
%       B = [b(1), b(2), ..., b(m+1)]
%
% or
%
%       Z = [z(1), z(2), ..., z(m)]
%       P = [p(1), p(2), ..., p(m)]
%       G = g (Gain is a scalar)
%
%
%   If there are no multiple roots,
%
%      A(s)       R(1)       R(2)             R(n)
%      ----  =  -------- + -------- + ... + -------- + K(s)
%      B(s)     s - P(1)   s - P(2)         s - P(n)
%
%   The number of poles is n = length(B)-1 = length(R) = length(P).
%   The direct term coefficient vector is empty if length(A) < length(B),
%   otherwise length(K) = length(A)-length(B)+1.
%   K(s) is returned in the form:
%
%       K(s) = k(1)*s^(m-n) + ... + k(m-n)*s + k(m-n+1)
%
%   so that the output vector of direct terms is:
%       K = [k(1), ..., k(m-n), k(m-n+1)]
%
%   If P(j) = ... = P(j+m-1) is a pole of multplicity m, then the
%   expansion includes terms of the form
%                R(j)        R(j+1)                R(j+m-1)
%              -------- + ------------   + ... + ------------
%              s - P(j)   (s - P(j))^2           (s - P(j))^m
%
%   The function is also capable to convert a partial fraction expanded
%   function to its rational form by setting the 'PARFRACT' input option.
%   In this case the output is composed by a plist containing the vactors
%   of numerator and denominator polynomial coefficients.
%
%
%
% CALL:     varargout = cpf(varargin)
%
%
%
% INPUTS:
%           Input options are:
%           'INOPT' define the input function type
%             'RAT' input the continous function in rational form.
%             then you have to input the vector of coefficients:
%               'NUM' is the vector with numerator coefficients.
%               'DEN' is the vector of denominator coefficienets.
%             'PZ' input the continuous function in poles and
%             zeros form. Then you have to input the vectors with poles
%             and zeros:
%               'POLES' the vector with poles
%               'ZEROS' the vector with zeros
%               'GAIN' the value of the gain
%             'PF' input the coefficients of a partial fraction
%             expansion of the transfer function. When this option is
%             setted the function performs the conversion from partial
%             fraction to rational transfer function. You have to input the
%             vectors containing the residues, poles and direct terms:
%               'RES' the vector with residues
%               'POLES' the vector with poles
%               'DTERMS' the vector with direct terms
%           'MODE' Is the used mode for the calculation of the roots of a
%           polynomial. It is an useful option only with rational functions
%           at the input. Admitted values are:
%             'SYM' uses symbolic roots calculation (you need symbolic
%             math toolbox to use this option)
%             'DBL' uses the standard numerical matlab style roots
%             claculation (double precision)
%           'RRTOL' the repeated-root tolerance default value is
%           1e-15. If two roots differs less than rrtolerance value, they
%           are reported as multiple roots
%
%
%
% OUTPUTS:
%
%           When 'INOPT' is set to 'RAT' or 'PZ', outputs
%           are:
%           RES vector of residues coefficients
%           POLES vector of poles coefficients
%           DTERMS vector of direct terms coefficients
%           PMul vector of poles multiplicity
%
%           When 'INOPT' is setted  to 'PF', outputs are:
%           NUM the vector with the numerator polynomial
%           coefficients
%           DEN the vector with the denominator polynomial
%           coefficents
%
%
%
% NOTE:
%         - 'SYM' option for 'MODE' requires the Symblic Math Toolbox. It
%         is used only for rational function input
%
%
%
% EXAMPLES:
%           - Input a function in rational form and output the partial
%           fraction expansion
%           [Res, Poles, DTerms, PMul] = cpf('INOPT', 'RAT',
%           'NUM', [], 'DEN', [], 'MODE','SYM',  'RRTOL', 1e-15)
%           - Input a function in poles and zeros and output the partial
%           fraction expansion
%           [Res, Poles, DTerms, PMul] = cpf('INOPT', 'PZ',
%           'POLES', [], 'ZEROS', [], 'GAIN', #,  'RRTOL', 1e-15)
%           - Input a function in partial fractions and output the rational
%           expression
%           [Num, Den] = cpf('INOPT', 'PF', 'POLES', [], 'RES',
%           [], 'DTERMS', [],  'RRTOL', 1e-15)
%
%
%
% REFERENCES:
%         [1] Alan V. Oppenheim, Allan S. Willsky and Ian T. Young, Signals
%         and Systems, Prentice-Hall Signal Processing Series, Prentice
%         Hall (June 1982), ISBN-10: 0138097313. Pages 767 - 776.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = cpf(varargin)
  
  %% Extracting parameters
  
  % default parameters
  inopt = 'RAT';
  mode = 'DBL';
  tol = 1e-15;
  
  % Finding input parameters
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'INOPT')
        inopt = varargin{j+1};
      end
      if strcmp(varargin{j},'MODE')
        mode = varargin{j+1};
      end
      if strcmp(varargin{j},'RRTOL')
        tol = varargin{j+1};
      end
    end
  end
  
  % Switching between input options and setup inputs for proper calculation
  switch inopt;
    case 'RAT'
      % etracting numerator and denominator vectors
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'NUM')
          u = varargin{jj+1};
        end
        if strcmp(varargin{jj},'DEN')
          v = varargin{jj+1};
        end
      end
      
      % For the conversion we need the denominator factored in poles and the
      % numerator in polynomial form
      switch mode
        case 'DBL'
          % adopt numerical calculation
          poles_vect = roots(v);
        case 'SYM'
          % adopt symbolic calculation
%           syms s
%           % Construct the symbolic polynomial
%           numel = length(v);
%           PowerVector = [];
%           for ii=1:numel
%             PowerVector = [PowerVector v(ii)*s^(numel-ii)];
%           end
%           PowerMatrix = diag(PowerVector);
%           Polyv = trace(PowerMatrix);
%           % Solve the polynomial in order to find the roots
%           Sp = solve(Polyv,s);
%           % output of the poles vector in Matlab double format
%           numpoles = length(Sp);
%           poles_vect = zeros(1,numpoles);
%           for jj=1:numpoles
%             poles_vect(jj) = double(Sp(jj));
%           end

        n = length(v);
        cN = -1.*v(2:end)./v(1);
        A = sym(diag(ones(1,n-2),-1));
        A(1,:) = cN;
        sol = eig(A);
        poles_vect = double(sol);
      end
      % setting the output option to residues and poles
      outopt = 'RP';
      
    case 'PZ'
      % Extracting zeros, poles and gain from inputs
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'ZEROS')
          zeros_vect = varargin{jj+1};
        end
        if strcmp(varargin{jj},'POLES')
          poles_vect = varargin{jj+1};
        end
        if strcmp(varargin{jj},'GAIN')
          gain = varargin{jj+1};
        end
      end
      
      u = poly(zeros_vect).*gain;
      v = poly(poles_vect);
      if ((~isempty(v)) && (v(1)~=1))
        u = u ./ v(1); v = v ./ v(1);   % Normalize.
      end
      % setting the output option to residues and poles
      outopt = 'RP';
      
    case 'PF'
      % Calculate numerator and denominator of a transfer function expanded
      % in partial fractions
      % etracting residues, poles and direct terms
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'RES')
          u = varargin{jj+1};
        end
        if strcmp(varargin{jj},'POLES')
          v = varargin{jj+1};
        end
        if strcmp(varargin{jj},'DTERMS')
          k = varargin{jj+1};
        end
      end
      % setting the output option to Transfer Function
      outopt = 'TF';
  end
  
  
  
  %% Partial fractions expansion
  
  % Switching between output cases
  % Note: rational input and poles zeros are equivalent from this point on,
  % so PF expansion is calculated in the same way
  switch outopt
    
    case 'RP'
      % Direct terms calculation
      if length(u) >= length(v)
        [dterms,new_u]=deconv(u,v);
      else
        dterms = 0;
        new_u = u;
      end
      
      % identification of multiple poles
      poles_vect = sort(poles_vect); % sort the poles in ascending order
      mul = mpoles(poles_vect,tol,0); % find the multiplicity
      
      mmul = mul;
      for kk=1:length(mmul)
        if mmul(kk)>1
          for hh=1:mmul(kk)
            mmul(kk-hh+1)=mmul(kk);
          end
        end
      end
      
      % finding the residues
      resids = zeros(length(poles_vect),1);
      
      for ii=1:length(poles_vect)
        
        den = v;
        p = [1 -poles_vect(ii)];
        for hh=1:mmul(ii)
          den = deconv(den,p);
        end
        
        dnum = new_u;
        dden = den;
        
        c = 1;
        if mmul(ii)>mul(ii)
          c = prod(1:(mmul(ii)-mul(ii)));
          
          for jj=1:(mmul(ii)-mul(ii))
            [dnum,dden] = polyder(dnum,dden);
          end
          
        end
        
        resids(ii)=(polyval(dnum,poles_vect(ii))./polyval(dden,poles_vect(ii)))./c;
      end
      
      % Converting from partial fractions to rational function
    case 'TF'
      % This code is directly taken from matlab 'residue' function
      [mults,i]=mpoles(v,tol,0);
      p=v(i); r=u(i);
      n = length(p);
      q = [p(:).' ; mults(:).'];   % Poles and multiplicities.
      v = poly(p); u = zeros(1,n,class(u));
      for indx = 1:n
        ptemp = q(1,:);
        i = indx;
        for j = 1:q(2,indx), ptemp(i) = nan; i = i-1; end
        ptemp = ptemp(find(~isnan(ptemp))); temp = poly(ptemp);
        j = length(temp);
        if j < n, temp = [zeros(1,n-j) temp]; end
        u = u + (r(indx) .* temp);
      end
      if ~isempty(k)
        if any(k ~= 0)
          u = [zeros(1,length(k)) u];
          k = k(:).';
          temp = conv(k,v);
          u = u + temp;
        end
      end
      num = u; den = v;    % Rename.
  end
  
  %% Output data
  
  switch outopt
    case 'RP'
      if nargout == 1
        varargout{1} = [resids poles_vect dterms mul];
      elseif nargout == 2
        varargout{1} = resids;
        varargout{2} = poles_vect;
      elseif nargout == 3
        varargout{1} = resids;
        varargout{2} = poles_vect;
        varargout{3} = dterms;
      elseif nargout == 4
        varargout{1} = resids;
        varargout{2} = poles_vect;
        varargout{3} = dterms;
        varargout{4} = mul;
      else
        error('Unespected number of outputs! Set 1, 2, 3 or 4')
      end
      %     plout = plist('RESIDUES', resids, 'POLES', poles_vect, 'PMul', mul, 'DIRECT_TERMS', dterms);
      % %     plout = combine(plout, pl);
    case 'TF'
      if nargout == 1
        varargout{1} = [num den];
      elseif nargout == 2
        varargout{1} = num;
        varargout{2} = den;
      else
        error('Unespected number of outputs! Set 1 or 2')
      end
      %     plout = plist('NUMERATOR', num, 'DENOMINATOR', den);
  end
  
end
% END




