% PF2SS Convert partial fraction models to state space matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DESCRIPTION:
% 
%     Convert partial fraction models to state space matrices. This method
%     works only for poles of multiplicity one. In case of multiple parfrac
%     models they must have the same set of poles.
%
% 
% CALL:
% 
%     [A,B,C,D] = pf2ss(pf)
% 
% INPUTS:
% 
%     Assuming to have M pf models with N poles (common to every model)
% 
%     - res, vector of matrix of residuals NxM, M is the number of pf
%     models
%     - poles, vector of poles Nx1
%     - dterm, vector of direct terms, Mx1
% 
% OUTPUT:
% 
%     - A matrix
%     - B matrix
%     - C matrix
%     - D matrix
% 
%
% 
% NOTE:
% 
% This method works only for poles of multiplicity one.
% In case of multiple parfrac models they must have the same set of poles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D] = pf2ss(res,poles,dterm)

  [N,M]=size(res);

  % pf = varargin{:};
  % 
  % %%% get poles, residues and direct terms
  % poles = pf(1).poles; % a common set of poles is assumed
  % 
  % N = length(poles);
  % M = numel(pf);
  % 
  % res = zeros(N,M); % init residues matrix
  % 
  % if size(poles,2)>1
  %   poles = poles.';
  % end
  % dterm = zeros(M,1); % init dterm matrix
  % 
  % for ii=1:M
  %   r = pf(ii).res;
  %   if size(r,2)>1
  %     r = r.';
  %   end
  %   res(:,ii) = r;
  %   dterm(ii,1) = pf(ii).dir;
  % end

  %%% Marking complex and real poles
  % cindex = 1; pole is complex, next conjugate pole is marked with cindex
  % = 2. cindex = 0; pole is real
  cindex=zeros(1,N);
  for m=1:N 
    if imag(poles(m))~=0  
      if m==1 
        cindex(m)=1;
      else
        if cindex(m-1)==0 || cindex(m-1)==2
          cindex(m)=1; cindex(m+1)=2; 
        else
          cindex(m)=2;
        end
      end 
    end
  end

  %%% Build SS matrices
  % init matrices
  A = diag(poles);
  B = ones(N,M);
  C = res.';
  D = dterm;

  for kk = 1:N
    if cindex(kk) == 1
      A(kk,kk)=real(poles(kk));
      A(kk,kk+1)=imag(poles(kk));
      A(kk+1,kk)=-1*imag(poles(kk));
      A(kk+1,kk+1)=real(poles(kk));
      B(kk,:) = 2;
      B(kk+1,:) = 0;
      C(:,kk+1) = imag(C(:,kk));
      C(:,kk) = real(C(:,kk));
    end
  end

end

