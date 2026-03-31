% STARTPOLES defines starting poles for fitting procedures ctfit, dtfit.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION
%
%     Defines the starting poles for the fitting procedure with ctfit or
%     dtfit. Starting poles definition process is different for s-domain
%     and z-domain.
%     s-domain identification:
%     Starting poles can be real or complex in conjugate couples. Real
%     poles are chosen on the [-2*pi*f(1),-2*pi*f(end)] intervall. Complex poles can
%     be defined with the real and imaginary parts logspaced or linespaced
%     on the intervall [2\pi f(1),2\pi f(end)]. Ratio between real and
%     imaginary part can be setted by the user.
%     z-domain identification:
%     Starting poles can be real or come in complex conjugate couples. Real
%     poles are chosen on the [-1,1] intervall. Complex poles are
%     chosen inside the unit circle as:
%     \alfa e^{j\pi\theta}
%     where \theta is linespaced inside the intervall [0,2\pi]. In this
%     case two different methods are used: the first method define angles
%     as \theta = linspace(0,pi,N/2+1), then take out the first element and
%     construct the complex conjugate couples. If N is odd the first
%     element is added as real pole. With this method the last two
%     conjugates poles have a real part very similar to that of the real
%     pole. This may generate problems so a second method is implemented in
%     which the angle are generated as \theta = linspace(0,pi,N/2+2). Then
%     the first and the last elements of the set are taken out and the
%     first element is used only for N odd. The last element instead is
%     never used. This allow to have well distributed poles on the unit
%     circle. The amplitude parameter \alfa can be set by the user.
%
% CALL:
%
%     spoles = startpoles(order,f,params)
%
% INPUT:
%
%     order: is the function order, ie. the number of desired poles
%     f: is the frequency vector in Hz
%     params: is a struct with the setting parameters
%
%       params.type = 'CONT' --> Output a set of poles for s-domain
%       identification
%       params.type = 'DISC' --> Output a set of poles for z-domain
%       identification
%
%       params.spolesopt = 1 --> generate linear spaced real poles on
%       the intervall [-2*pi*f(1),-2*pi*f(end)] for s-domain and [-1,1] for z-domain.
%       params.spolesopt = 2 --> in case of s-domain generates logspaced
%       complex conjugates poles. In case of z-domain generates complex
%       conjugates poles with \theta = linspace(0,pi,N/2+1).
%       params.spolesopt = 3 --> in case of s-domain generates linespaced
%       complex conjugates poles.  In case of z-domain generates complex
%       conjugates poles with \theta = linspace(0,pi,N/2+2). We advice to
%       make use of this option for z-domain identification.
%
%       params.pamp = # --> s-domain: set the ratio \alfa/\beta between
%       poles real and imaginary parts. Adviced value is 0.01.
%       params.pamp = # --> z-domain: set the amplitude of the poles.
%       Adviced value is 0.98.
%
% OUTPUT:
%
%     spoles: is the set of starting poles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spoles = startpoles(order,f,params)
  
  % Default input struct
  defaultparams = struct('spolesopt',1, 'type','CONT', 'pamp', 0.98);
  
  names = {'spolesopt', 'type', 'pamp'};
  
  % collecting input and default params
  if ~isempty(params)
    for jj=1:length(names)
      if isfield(params, names(jj))
        defaultparams.(names{1,jj}) = params.(names{1,jj});
      end
    end
  end
  
  type = defaultparams.type;
  spolesopt = defaultparams.spolesopt;
  pamp = defaultparams.pamp;
  
  N = order;
  
  % switching between continuous and discrete
  switch type
    case 'CONT'
      switch spolesopt
        
        case 0
          disp(' Using external starting poles')
        
        case 1 % real starting poles
          spoles = -1.*2.*pi.*linspace(f(1),f(end),N).';
          
        case 2 % complex logspaced starting poles
          if f(1)==0
            bet=2.*pi.*logspace(log10(f(2)),log10(f(end)),N/2);
          else
            bet=2.*pi.*logspace(log10(f(1)),log10(f(end)),N/2);
          end
          spoles=[];
          for n=1:length(bet)
            alf=-bet(n)*pamp;
            spoles=[spoles;(alf-1i*bet(n));(alf+1i*bet(n))];
          end
          if (N-2*floor(N/2)) ~= 0
%             rpl = rand(1,1);
%             if rpl > 0
%               rpl = -1*rpl;
%             end
            rpl = -1;
            spoles = [rpl; spoles];
          end
          
        case 3 % complex linspaced starting poles
          bet=linspace(2*pi*f(1),2*pi*f(end),N/2);
          spoles=[];
          for n=1:length(bet)
            alf=-bet(n)*pamp;
            spoles=[spoles;(alf-1i*bet(n));(alf+1i*bet(n))];
          end
          if (N-2*floor(N/2)) ~= 0
%             rpl = rand(1,1);
%             if rpl > 0
%               rpl = -1*rpl;
%             end
            rpl = -1;
            spoles = [rpl; spoles];
          end
          
      end
    case 'DISC'
      switch spolesopt
        
        case 0
          disp(' Using external starting poles')
          
        case 1 % real starting poles
          spoles = linspace(-0.99,0.99,N).';
          
        case 2 % complex starting poles
          ang = linspace(0,pi,N/2+1);
          spoles=[];
          for nn=2:length(ang)
            spoles=[spoles; exp(1i*ang(nn)); exp(-1i*ang(nn))]; % Taking complex conjugate pairs on the unit circle
          end
          if (N-2*floor(N/2)) ~= 0
            rpl = exp(1i*ang(1));
            spoles = [rpl; spoles];
          end
          spoles = spoles.*pamp; % shifting starting ?poles a little inside the unit circle
          
        case 3 % complex starting poles
          ang = linspace(0,pi,N/2+2);
          spoles=[];
          for nn=2:length(ang)-1
            spoles=[spoles; exp(1i*ang(nn)); exp(-1i*ang(nn))]; % Taking complex conjugate pairs on the unit circle
          end
          if (N-2*floor(N/2)) ~= 0
            rpl = exp(1i*ang(1));
            spoles = [rpl; spoles];
          end
          spoles = spoles.*pamp; % shifting starting ?poles a little inside the unit circle
          
      end
      
  end
  
end