%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute Signal-to-Noise Ratio for temperature annealing in mcmc as  
% described in Neil J. Cornish et al (arXiv:gr-qc/0701167v1).
% Returns SNR for each channel.
%
% - Inputs for a 2x2 system are 
%
% 
% Karnesis 24-07-2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function snrexp = stnr(in, out, S, TF)

% Get the template
h = mult(TF, in);

% Get H*s
hs = ctmult(h,mult(S, out));

hh = ctmult(h,mult(S, h));

snrexp = sqrt(2)*sum(hs)/sqrt(sum(hh));
 
end

function d = mult(C, A)
  % Multiplication function designed specially for the
  % purposes of the SNR calculations
  for ii=1:size(C,2)
    for jj=1:size(A,2)

      Cn = squeeze(C(:,ii,:));
      An = squeeze(A(:,jj));
      m(:,jj) = Cn(:,jj).*An;

    end
    
    d(:,ii) = sum(m,2);
    
  end

end

function d = ctmult(C, A)
  % Multiplication function designed for the
  % purposes of the SNR calculations:
  % The first input is transformed to it's conjugate
  for ii=1:size(C,2)

    Cn = conj(squeeze(C(:,ii)));
    An = squeeze(A(:,ii));
    m(:,ii) = Cn.*An;

  end
  
  d = sum(m,2);

end

% END