% GETINITSTATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
%
%     Initialize filters for noise generation
%
%
% CALL:             
%
% INPUT:
%
%     - res
%     - poles
%     - S0
%
% OUTPUT:
%
%     Zi
% 
% REFERENCES:
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Zi = getinitstate(res,poles,S0,varargin)

  % default value for the method used
  mtd = 'svd';
  
  if ~isempty(varargin)
    for j=1:length(varargin)
      if strcmpi(varargin{j},'mtd')
        mtd = lower(varargin{j+1});
      end
    end
  end
  
  % get problem dimesionality, it is assumed that res for a given filter are
  % input as columns and that each different filter has the same number of
  % residues and poles
  [rw,cl] = size(res);

  N = numel(res(:,1));

      
      % check size
      if cl == 1 % one dimensional
        A = res(:);
        p = poles(:);
        
        % Marking complex and real poles
        % cindex = 1; pole is complex, next conjugate pole is marked with cindex
        % = 2. cindex = 0; pole is real
        cindex=zeros(numel(p),1);
        for mm=1:numel(p) 
          if imag(p(mm))~=0  
            if mm==1 
              cindex(mm)=1;
            else
              if cindex(mm-1)==0 || cindex(mm-1)==2
                cindex(mm)=1; cindex(mm+1)=2; 
              else
                cindex(mm)=2;
              end
            end 
          end
        end
        
        NA = numel(A);

        % Build covariance matrix for filter states
        H = zeros(NA);
        for aa = 1:NA
          for bb = 1:NA
            H(aa,bb) = (p(aa)*conj(p(bb))*A(aa)*conj(A(bb))*S0)/(1-p(aa)*conj(p(bb)));
          end
        end
        
        % avoiding problems caused by roundoff errors
        HH = triu(H,0); % get upper triangular part of H
        HH1 = triu(H,1); % get upper triangular part of H above principal diagonal
        HH2 = HH1'; % do transpose conjugate
        H = HH + HH2; % reconstruct H in order to be really hermitian
        
        % switch between methods
        switch mtd
          case 'svd'
            % get decomposition of Hr
            [U,S,V] = svd(H,0);
            % output initial states for gaussian data series
            ZZ = V*(sqrt(diag(S)).*randn(N,1));
            
            % cleaning up results for numerical approximations
            idx = imag(poles(:,1))==0;
            ZZ(idx) = real(ZZ(idx));
            
            % cleaning up results for numerical roundoff errors
            % states associated to complex conjugate poles must be complex
            % conjugate
            for jj = 1:numel(ZZ)
              if cindex(jj)==1
                ZZ(jj+1) = conj(ZZ(jj));
              end
            end
            
          case 'mvnorm'
            
            ZZ = mvnrnd(zeros(N,1),H,1);
            % willing to work with columns
            if size(ZZ,2)>1
              ZZ = ZZ.';
            end
            if imag(ZZ(1))~=0 && imag(p(1))==0
              % flip
              ZZ = flipud(ZZ);
            end
            
            % cleaning up results for numerical roundoff errors
            % states associated to complex conjugate poles must be complex
            % conjugate
            for jj = 1:numel(ZZ)
              if cindex(jj)==1
                ZZ(jj+1) = conj(ZZ(jj));
              end
            end
            
        end
        
        
        
      else % cl dmensional

        % join residues and poles
        A = [];
        p = [];
        pdim = [];
        
        for ii=1:cl
          % Join poles and residues as a single column
          A = [A; res(:,ii)];
          p = [p; poles(:,ii)];
          pdim = [pdim; numel(poles(:,ii))];
        end
        
        % Marking complex and real poles
        % cindex = 1; pole is complex, next conjugate pole is marked with cindex
        % = 2. cindex = 0; pole is real
        cindex=zeros(numel(p),1);
        for mm=1:numel(p) 
          if imag(p(mm))~=0  
            if mm==1 
              cindex(mm)=1;
            else
              if cindex(mm-1)==0 || cindex(mm-1)==2
                cindex(mm)=1; cindex(mm+1)=2; 
              else
                cindex(mm)=2;
              end
            end 
          end
        end
        
        % sanity check, search if poles are equals
        eqpoles = false;
        if ~all(logical(diff(pdim))) % is executed if the elements of pdim are equal
          % compare poles series
          for ii=2:cl
            if all((poles(:,ii)-poles(:,ii-1))<eps)
              eqpoles = true;
            end
          end
        end
        
        if ~eqpoles % poles are different

          NA = numel(A);

          % Build covariance matrix for filter states
          H = zeros(NA);
          for aa = 1:NA
            for bb = 1:NA
              H(aa,bb) = (p(aa)*conj(p(bb))*A(aa)*conj(A(bb))*S0)/(1-p(aa)*conj(p(bb)));
            end
          end

          % avoiding problems caused by roundoff errors
          HH = triu(H,0); % get upper triangular part of H
          HH1 = triu(H,1); % get upper triangular part of H above principal diagonal
          HH2 = HH1'; % do transpose conjugate
          H = HH + HH2; % reconstruct H in order to be really hermitian

          % get full rank H
          [U,S,V] = svd(H,0);

          % reducing size
          Ur = U(1:N,1:N);
          Sr = S(1:N,1:N);
          Vr = V(1:N,1:N);

          % New full rank covariance
          Hr = Vr*Sr*Vr';

          % avoiding problems caused by roundoff errors
          HH = triu(Hr,0); % get upper triangular part of H
          HH1 = triu(Hr,1); % get upper triangular part of H above principal diagonal
          HH2 = HH1'; % do transpose conjugate
          Hr = HH + HH2; % reconstruct H in order to be really hermitian

          % switch between methods
          switch mtd
            case 'svd'
              % get decomposition of Hr
              [UU,SS,VV] = svd(Hr,0);
              % output initial states for gaussian data series
              ZZ = VV*(sqrt(diag(SS)).*randn(N,1));

              % cleaning up results for numerical roundoff errors
              idx = imag(p)==0;
              ZZ(idx) = real(ZZ(idx));

              % cleaning up results for numerical roundoff errors
              % states associated to complex conjugate poles must be complex
              % conjugate
              for jj = 1:numel(ZZ)
                if cindex(jj)==1
                  ZZ(jj+1) = conj(ZZ(jj));
                end
              end


            case 'mvnorm'

              ZZ = mvnrnd(zeros(N,1),Hr,1);
              % willing to work with columns
              if size(ZZ,2)>1
                ZZ = ZZ.';
              end
              if imag(ZZ(1))~=0 && imag(p(1))==0
                % flip
                ZZ = flipud(ZZ);
              end

              % cleaning up results for numerical roundoff errors
              % states associated to complex conjugate poles must be complex
              % conjugate
              for jj = 1:numel(ZZ)
                if cindex(jj)==1
                  ZZ(jj+1) = conj(ZZ(jj));
                end
              end

          end
        
        else % poles are in common
          
          NA = numel(A);

          % Build block diagonal covariance matrix for filter states
          H = zeros(NA);
          for ii = 1:numel(pdim)
            for aa = 1+(ii-1)*pdim(ii):(ii-1)*pdim(ii)+pdim(ii)
              for bb = 1+(ii-1)*pdim(ii):(ii-1)*pdim(ii)+pdim(ii)
                H(aa,bb) = (p(aa)*conj(p(bb))*A(aa)*conj(A(bb))*S0)/(1-p(aa)*conj(p(bb)));
              end
            end
          end

          % avoiding problems caused by roundoff errors
          HH = triu(H,0); % get upper triangular part of H
          HH1 = triu(H,1); % get upper triangular part of H above principal diagonal
          HH2 = HH1'; % do transpose conjugate
          H = HH + HH2; % reconstruct H in order to be really hermitian

          % switch between methods
          switch mtd
            case 'svd'
              % get decomposition of Hr
              [UU,SS,VV] = svd(H,0);
              % output initial states for gaussian data series
              rd = randn(N,1);
              rdv = [];
              for jj = 1:numel(pdim);
                rdv = [rdv; rd];
              end
              ZZ = VV*(sqrt(diag(SS)).*rdv);

              % cleaning up results for numerical roundoff errors
              idx = imag(p)==0;
              ZZ(idx) = real(ZZ(idx));

              % cleaning up results for numerical roundoff errors
              % states associated to complex conjugate poles must be complex
              % conjugate
              for jj = 1:numel(ZZ)
                if cindex(jj)==1
                  ZZ(jj+1) = conj(ZZ(jj));
                end
              end


            case 'mvnorm'

              ZZ = mvnrnd(zeros(N,1),H,1);
              % willing to work with columns
              if size(ZZ,2)>1
                ZZ = ZZ.';
              end
              if imag(ZZ(1))~=0 && imag(p(1))==0
                % flip
                ZZ = flipud(ZZ);
              end

              % cleaning up results for numerical roundoff errors
              % states associated to complex conjugate poles must be complex
              % conjugate
              for jj = 1:numel(ZZ)
                if cindex(jj)==1
                  ZZ(jj+1) = conj(ZZ(jj));
                end
              end

          end
        
        end
        
      end
      
      Zi = ZZ;

end