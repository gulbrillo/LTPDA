% FPSDER performs the numeric time derivative
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FPSDER (Five Points Stencil Derivative) performs the numeric
% time derivative using the method of five points stencil.
% The function can perform first, second, third and fourth derivetive
% of a series of input data.
% Given a discrete series of data points, the five-point-stencil method for
% the derivative approximation, at a given time t0, is calculated by means
% of finite differences between the element at t0 with its four neighbors.
% The n-order derivative at a certain time can be approximated by a five
% point difference equation:
%
% d^{n}y[k]
% --------- = (1/T^n) * {a*y[k-2] + b*y[k-1] + c*y[k] + d*y[k+1] + e*y[k+2]}
%  dt^{n}
%
% It can be demonstrated [1,2] that the five coefficients [a, b, c, d, e] can
% be written in terms of only one of them. In fpsder the independent
% coefficient is fixed to be the first and is called m. It can be input as
% a parameter when the function is called.
%
%
% CALL:                 Deriv = fpsder(data, params)
%
% INPUTS:
%
%         - a is a vector containing the data to be differentiated.
%         - params is a struct with the input parameters:
%
%         - 'ORDER' set the derivative order. Its allowed options are:
%             - 'ZERO' perform data smoothing using the couefficients
%             vector d0 = [m -4*m 1+6*m -4*m m].
%             - 'FIRST' perform the first derivative using the
%             couefficients vector d1 = [m -(0.5+2*m) 0 (0.5+2*m) m]./T.
%             Recomended values of m are in the interval [-0.1, 0.1].
%             - 'SECOND' perform the second derivative using the
%             coefficients vector d2 = [m 1-4*m 6*m-2 1-4*m m]./(T^2).
%             Recomended values of m are in the interval [-0.11, 0.3].
%             - 'THIRD' perform the third derivative using the
%             coefficients vector d3 = []./(T^3)
%             - 'FOURTH' perform the third derivative using the
%             coefficients vector d4 = []./(T^4)
%
%         - 'COEFF' set m coefficient values.
%           In case of data smoothing: m = -3/35 correspond to the
%           parabolic fit approximation.
%           In case of first order derivative: m = -1/5 correspond to the
%           parabolic fit approximation, m = 1/12 correspond to the
%           Taylor series approximation.
%           In case of second order derivative: m = 2/7 corresponds to
%           the parabolic fit approximation, m = -1/12 corresponds to the
%           Taylor series approximation and m = 1/4 gives the notch
%           feature at the Nyquist frequency
%
%         - 'FS' set the data sampling frequency in Hz
%
%         NOTE1: T is the sampling period
%         NOTE2: The default option for 'ORDER' is 'SECOND'
%         NOTE3: The default option for 'COEFF' is 2/7
%         NOTE4: The default option for 'FS' is 10
%
% OUTPUTS:
%           - D is a vector containing the resulting data after the
%           differentiation procedure
%
% REFERENCES:
% [1] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction,
%     <a
%     href="matlab:web('http://www.iop.org/EJ/abstract/0264-9381/26/9/094013/','-browser')">Class. Quantum Grav. 26 (2009) 094013.</a>
% [2] L. Ferraioli, M. Hueller and S. Vitale, Discrete derivative
%     estimation in LISA Pathfinder data reduction,
%     <a
%     href="matlab:web('http://arxiv.org/abs/0903.0324v1','-browser')">http://arxiv.org/abs/0903.0324v1</a>
%
% EXAMPLES:
%           - Performing the second order derivative of a series of data, m
%           coefficient is fixed to 2/7 and data sampling frequency is
%           fixed to 10 Hz.
%           params = struct('ORDER', 'SECOND', 'COEFF', 2/7, 'FS', 10);
%           Deriv = fpsder(data, params);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function   Deriv = fpsder(a, params)

  % Getting input parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Collect inputs

  % Default input struct
  defaultparams = struct('ORDER','SECOND',...
    'COEFF',2/7,...
    'FS',10);

  names = {'ORDER','COEFF','FS'};

  % collecting input and default params
  if ~isempty(params)
    for jj=1:length(names)
      if isfield(params, names(jj)) && ~isempty(params.(names{1,jj}))
       defaultparams.(names{1,jj}) = params.(names{1,jj});
      end
    end
  end

  % values for input variables
  order = defaultparams.ORDER;
  m = defaultparams.COEFF;
  fs = defaultparams.FS;
  
  % willing to work with columns
  if size(a,2)>1
    a = a.';
  end

  % Assigning coefficients values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Assigning coefficients values based on the input options
  switch upper(order)
    case 'ZERO'
      Coeffs = [m -4*m 1+6*m -4*m m];
    case 'FIRST'
      Coeffs = [m -(0.5+2*m) 0 (0.5+2*m) -m];
    case 'SECOND'
      Coeffs = [m 1-4*m 6*m-2 1-4*m m];
    case 'THIRD'
      Coeffs = [0 0 0 0 0];
      disp('Not yet implemented, sorry!');
    case 'FOURTH'
      Coeffs = [0 0 0 0 0];
      disp('Not yet implemented, sorry!');
    otherwise
      error('### Unknown order %s', order);
  end

  % Sampling period
  T = 1/fs;

  % Building vectors for calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Building the 'extended' vector for calculation
  % a_temp = [a(1);a(1);a(1);a(1);a;a(end);a(end);a(end);a(end)];
  a_temp = [2*a(1)-a((4+1):-1:2);a;2*a(end)-a((end-1):-1:end-4)];

  % Switching between the input options differentiate
  switch upper(order)
    case 'ZERO'
      Deriv = (Coeffs(1)*a_temp(1:end-4) + Coeffs(2)*a_temp(2:end-3) + Coeffs(3)*a_temp(3:end-2) + Coeffs(4)*a_temp(4:end-1) + Coeffs(5)*a_temp(5:end));
      Deriv = Deriv(3:end-2);
    case 'FIRST'
      Deriv = (1/T).*(Coeffs(1)*a_temp(1:end-4) + Coeffs(2)*a_temp(2:end-3) + Coeffs(3)*a_temp(3:end-2) + Coeffs(4)*a_temp(4:end-1) + Coeffs(5)*a_temp(5:end));
      Deriv = Deriv(3:end-2);
    case 'SECOND'
      Deriv = (1/T^2).*(Coeffs(1)*a_temp(1:end-4) + Coeffs(2)*a_temp(2:end-3) + Coeffs(3)*a_temp(3:end-2) + Coeffs(4)*a_temp(4:end-1) + Coeffs(5)*a_temp(5:end));
      Deriv = Deriv(3:end-2);
    case 'THIRD'
      Deriv = (1/T^3).*(Coeffs(1)*a_temp(1:end-4) + Coeffs(2)*a_temp(2:end-3) + Coeffs(3)*a_temp(3:end-2) + Coeffs(4)*a_temp(4:end-1) + Coeffs(5)*a_temp(5:end));
      Deriv = Deriv(3:end-2);
    case 'FOURTH'
      Deriv = (1/T^4).*(Coeffs(1)*a_temp(1:end-4) + Coeffs(2)*a_temp(2:end-3) + Coeffs(3)*a_temp(3:end-2) + Coeffs(4)*a_temp(4:end-1) + Coeffs(5)*a_temp(5:end));
      Deriv = Deriv(3:end-2);
    otherwise
      error('### Unknown order %s', order);
  end

end
