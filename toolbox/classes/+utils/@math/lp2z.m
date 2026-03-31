% LP2Z converts a continous TF in to a discrete TF.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: LP2Z converts a continous (lapalce notation) transfer
% function in a discrete (z transfor formalism) partial fractioned transfer
% function.
% 
% Input function can be in rational, poles and zeros or partial fractions
% form:
% The rational case assumes an input function of the type:
%
%           a(1)s^m + a(2)s^{m-1} + ... + a(m+1)
%   H(s) = --------------------------------------
%           b(1)s^n + b(2)s^{n-1} + ... + b(n+1)
% 
% The poles and zeros case assumes an impution function of the type:
% 
%             (s-Z(1))(s-Z(2))...(s-Z(n))
%   H(s) =  K ---------------------------
%             (s-P(1))(s-P(2))...(s-P(n))
% 
% The partail fraction case assumes an input function of the type:
%
%                 R(1)       R(2)             R(n)
%      H(s)  =  -------- + -------- + ... + -------- + K(s)
%               s - P(1)   s - P(2)         s - P(n)
%
% LP2Z function is also capable to handling input transfer functions with
% multiple poles.
%
%
%
% CALL:
%           pfstruct = lp2z(varargin)
%           [res,poles,dterm] = lp2z(varargin)
%           [pfstruct,res,poles,dterm] = lp2z(varargin)
%
%
%
% INPUTS:
%           Input parameters are:
%           'FS' sampling frequency
%           'RRTOL' the repeated-root tolerance, default value is
%           1e-15. If two roots differs less than rrtolerance value, they
%           are reported as multiple roots.
%           'INOPT' define the input function type
%               'PF' use this option if you want to input a function
%               expanded in partial fractions. Then you have to input the
%               vectors containing:
%                 'RES' the vector containig the residues
%                 'POLES' The vector containing the poles
%                 'DTERMS' The vector containing the direct terms
%               'RAT' input the continous function in rational form.
%               then you have to input the vector of coefficients:
%                 'NUM' is the vector with numerator coefficients.
%                 'DEN' is the vector of denominator coefficienets.
%               'PZ' input the continuous function in poles and
%               zeros form. Then you have to input the vectors with poles
%               and zeros:
%                 'POLES' the vector with poles
%                 'ZEROS' the vector with zeros
%                 'GAIN' the value of the gain
%           'MODE' Is the mode used for the calculation of the roots of a
%           polynomial. Admitted values are:
%               'SYM' uses symbolic roots calculation (you need Symbolic
%               Math Toolbox to use this option)
%               'DBL' uses the standard numerical matlab style roots
%               claculation (double precision)
%
%
% OUTPUTS:
%           Function output is a structure array with two fields: 'num' and
%           'den' respectively. Each term of the partial fraction expansion
%           can be seen as rational transfer function in z domain. These
%           reduced transfer functions can be used to filter in parallel a
%           series of data. This representation is particularly useful when
%           poles with multiplicity higher than one are present. In this
%           case the corresponding terms of the partial fraction expansion
%           are really rational transfer functions whose order depends from
%           the pole multiplicity [1].
%           As a sencond option residues, poles and direct term are output
%           as standard vectors (this possibility works only with simple
%           poles).
%           The third possibility is to call the function with four output,
%           1st is a struct, 2nd are residues, 3rd are ples and 4th is the
%           direct term.
% 
%           NOTE1: The function is capable to convert in partial fractions
%           only rational functions with numerator of order lower or equal
%           to the order of the denominator. When the order of the
%           numerator is higher than the order of the denominator (improper
%           rational functions) the expansion in partial fractions is not
%           useful and other methods are preferable.
%
%           NOTE2: 'SYM' calculation mode requires Symbolic Math Toolbox
%           to work
%
%
%
% REFERENCES:
%         [1] Alan V. Oppenheim, Allan S. Willsky and Ian T. Young, Signals
%         and Systems, Prentice-Hall Signal Processing Series, Prentice
%         Hall (June 1982), ISBN-10: 0138097313. Pages 767 - 776.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = lp2z(varargin)
  
  
  %% Finding input parameters

  % Default values for the parameters
  fs = 10;
  inopt = 'RAT';
  tol = 1e-15;
  mode = 'DBL';

  % Finding input parameters
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmp(varargin{j},'INOPT')
        inopt = varargin{j+1};
      end
      if strcmp(varargin{j},'FS')
        fs = varargin{j+1};
      end
      if strcmp(varargin{j},'MODE')
        mode = varargin{j+1};
      end
      if strcmp(varargin{j},'RRTOL')
        tol = varargin{j+1};
      end
    end
  end


  %% Conversion to partial fractions and discretization

  % swithing between input options
  switch inopt
    case 'RAT'
      % Finding proper parameters
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'NUM')
          num = varargin{jj+1};
        end
        if strcmp(varargin{jj},'DEN')
          den = varargin{jj+1};
        end
      end
      % conversion in partail fractions cP is the vector of residues, cP is the
      % vector of poles and cK is the vector of direct terms
      [cR, cP, cK, mul] = utils.math.cpf('INOPT', 'RAT', 'NUM', num,...
        'DEN', den, 'MODE', mode, 'RRTOL', tol);

    case 'PZ'
      % Finding proper parameters
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'ZEROS')
          zer = varargin{jj+1};
        end
        if strcmp(varargin{jj},'POLES')
          pol = varargin{jj+1};
        end
        if strcmp(varargin{jj},'GAIN')
          gain = varargin{jj+1};
        end
      end
      % conversion in partail fractions cP is the vector of residues, cP is the
      % vector of poles and cK is the vector of direct terms
      [cR, cP, cK, mul] = utils.math.cpf('INOPT', 'PZ', 'ZEROS', zer,...
        'POLES', pol, 'GAIN', gain, 'RRTOL', tol);

    case 'PF'
      % Finding proper parameters
      for jj=1:length(varargin)
        if strcmp(varargin{jj},'RES')
          cR = varargin{jj+1};
        end
        if strcmp(varargin{jj},'POLES')
          cP = varargin{jj+1};
        end
        if strcmp(varargin{jj},'DTERMS')
          cK = varargin{jj+1};
        end
      end
      % finding poles multiplicity
      mul = mpoles(cP,tol,0);
  end

  % Checking for not proper functions
  if length(cK)>1
    error('Unable to directly discretize not proper continuous functions ')
  end

  % disctretization
  T = 1/fs;

  dpls = exp(cP.*T); % poles discretization

  % Construct a struct array in which the elements of the partial
  % fractions expansion are stored. Each partial fraction can be
  % considered as rational function with proper numerator and denominator
  % coefficients
  pfstruct = struct();

  indxmul = 0;
  for kk=1:length(mul)
    if mul(kk)==1
      pfstruct(kk).num = cR(kk).*T;
      pfstruct(kk).den = [1 -1*dpls(kk)];
    else
      coeffs = PolyLogCoeffs(1-mul(kk),exp(cP(kk)*T));
      coeffs = flipdim(coeffs,2);
      pfstruct(kk).num = (cR(kk)*T^mul(kk)/prod(1:mul(kk)-1)).*coeffs;
      pfstruct(kk).den = BinomialExpansion(mul(kk),exp(cP(kk)*T));
      indxmul = 1;
    end
  end

  % Inserting the coefficients relative to the presence of a direct term
  if ((length(cK)==1)&&(not(cK(1)==0)))
    pfstruct(length(mul)+1).num =  cK.*T;
    pfstruct(length(mul)+1).den = [1 0];
  end

  % Output also the vector of residues, poles and direct term if non multiple
  % poles are found
  if indxmul == 0
    res = cR.*T;
    poles = dpls;
    dterm = cK.*T;
  else
    res = [];
    poles = [];
    dterm = [];
  end
  
  % Output empty fields struct in case of no input
  if isempty(cR)||isempty(cP)
    pfstruct.num = [];
    pfstruct.den = [];
  end

  %% Output data

  if indxmul == 1
    disp( ' Found poles with multiplicity higher than one. Results are output in struct form only. ')
  end

  if nargout == 1
    varargout{1} = pfstruct;
  elseif nargout == 3
    varargout{1} = res;
    varargout{2} = poles;
    varargout{3} = dterm;
  elseif nargout == 4
    varargout{1} = pfstruct;
    varargout{2} = res;
    varargout{3} = poles;
    varargout{4} = dterm;
  else
    error('Unespected number of outputs! Output must be 1, 3 or 4')
  end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:     Eulerian Number
%
% DESCRIPTION: Calculates the Eulerian Number
%
% HISTORY:  12-05-2008 L Ferraioli
%               Creation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function enum = eulerian(n,k)

  enum = 0;
  for jj = 0:k+1;
    enum = enum + ((-1)^jj)*(prod(1:n+1)/(prod(1:n+1-jj)*prod(1:jj)))*(k-jj+1)^n;
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: PloyLogCoeffs
%
% DESCRIPTION: Computes the coefficients of a poly-logarithm expansion for
% negative n values
%
% HISTORY:  12-05-2008 L Ferraioli
%               Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function coeffs = PolyLogCoeffs(n,x)

  if n>=0
    error('n must be a negative integer!')
  else
    % Now we keep the absolute value of n
    n = -1*n;
  end

  coeffs = [];
  for ii=0:n;
    coeffs = [coeffs eulerian(n,ii)*(x^(n-ii))];
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION: BinomialExpansion
%
% DESCRIPTION: Performs the binomial expamsion of the expression (1-x)^n
%
% HISTORY:  12-05-2008 L Ferraioli
%               Creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function binexp = BinomialExpansion(n,x)

  binexp = [];
  for jj=0:n
    binexp = [binexp ((-1)^jj)*(prod(1:n)/(prod(1:n-jj)*prod(1:jj))*(x^jj))];
  end
