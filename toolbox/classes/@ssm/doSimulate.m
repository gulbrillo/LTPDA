% DOSIMULATE simulates a discrete ssm with given inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOSIMULATE simulates a discrete ssm with given inputs.
%
% CALL:  [x, y, lastX] = doSimulate(SSini, Nsamples, A, Baos, Coutputs, Cstates, Daos, Bnoise, Dnoise, Bcst, Dcst, aos_vect, doTerminate, terminationCond, displayTime, timestep)
%
% INPUTS:
%
% OUTPUTS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TO DO: Check input aos for the timestep, tsdata, and ssm.timestep
% options to be defined (NL case)
% add check if one input mach no ssm input variable
% allow use of other LTPDA functions to generate white noise


function [x, y, lastX] = doSimulate(SSini, Nsamples, A, Baos, Coutputs, Cstates, Daos, Bnoise, Dnoise, Bcst, Dcst, aos_vect, doTerminate, terminationCond, displayTime, timestep, forceComplete)
  
  % We do a simple simulate if all these are satisfied:
  % 1) Bnoise is empty or all zeros
  % 2) Cstates is empty
  % 3) Dnoise is empty or all zeros
  % 4) Bcst is empty or all zeros
  % 5) Dcst is empty or all zeros
  % 6) doTerminate is false
  
  if  (isempty(Bnoise) || all(all(Bnoise==0))) && ...
      isempty(Cstates) && ...
      (isempty(Dnoise) || all(all(Dnoise==0))) && ...
      (isempty(Bcst) || all(all(Bcst==0))) && ...
      (isempty(Dcst) || all(all(Dcst==0))) && ...
      ~doTerminate && ...
      ~forceComplete
    % do a fast simulation
    Nstates = numel(SSini);
    
    if Nstates >= 100
      % except if Matlab is faster
      [x,y,lastX] = doSimulateSimple(SSini, Nsamples, A, Baos, Coutputs, Daos, aos_vect, displayTime);
    else
      try
        % call to the mex file
        x = [];
        [y,lastX] = ltpda_ssmsim(SSini, A.', Coutputs.', Cstates.', Baos.', Daos.', aos_vect);
      catch
        % backup if the mex-file is broken
        warning('Failed to run mex file ltpda_ssmsim');
        [x,y,lastX] = doSimulateSimple(SSini, Nsamples, A, Baos, Coutputs, Daos, aos_vect, displayTime);
      end
    end
  else
    % the standard old script, more complete (DC and noise inputs)
    [x,y,lastX] = doSimulateComplete(SSini, Nsamples, A, Baos, Coutputs, Cstates, Daos, Bnoise, Dnoise, Bcst, Dcst, aos_vect, doTerminate, terminationCond, displayTime, timestep);
  end
  
end


function [x,y,lastX] = doSimulateSimple(lastX, Nsamples, A, Baos, Coutputs, Daos, aos_vect, displayTime)
  
  if displayTime
    disp('Running simulate simple...');
  end
  % initializing fields
  x = [];
  y = zeros(size(Coutputs,1), Nsamples);
  
  % state equations are
  % x(k+1) = A*x(k) + B*u(k)
  % y(k)   = C*x(k) + D*u(k)
  % Assuming our simulation starts at k=1
  % the lastX input to doSimulate is x(k) at k=1
  % E.g. the lastX input is produced by a previous simulation that has
  % ended at the step 0 of the current simulation. Therefore in the last
  % state advancing step it has produced x(1) = A'*x(0) + B'*x(0)
  % This mean that when we start out simulation we already know x(1) and we
  % can directly calculate y(1) = C*x(1) + D*u(1)
  % in other words we do not need the following step
  %lastX  = A*lastX + Baos*aos_vect(:,1); % originally uncommented
  
  % time for displaying remaining time
  
  % simulation loop
  for k = 1:Nsamples
    % computing and storing outputs
    y(:,k) = Coutputs*lastX + Daos*aos_vect(:,k);
    % computing and storing states
    lastX  = A*lastX + Baos*aos_vect(:,k);
  end
  
end

function [x,y,lastX] = doSimulateComplete(lastX, Nsamples, A, Baos, Coutputs, Cstates, Daos, Bnoise, Dnoise, Bcst, Dcst, aos_vect, doTerminate, terminationCond, displayTime, timestep)
  
  if displayTime 
    disp('Running simulate complete...');
  end
  
  %% converting to sparse matrices
  if numel(A)>0; if(sum(sum(A==0))/numel(A))>0.5; A = sparse(A); end, end
  if numel(Baos)>0; if(sum(sum(Baos==0))/numel(Baos))>0.5; Baos = sparse(Baos); end, end
  if numel(Coutputs)>0; if(sum(sum(Coutputs==0))/numel(Coutputs))>0.5; Coutputs = sparse(Coutputs); end, end
  if numel(Cstates)>0; if(sum(sum(Cstates==0))/numel(Cstates))>0.5; Cstates = sparse(Cstates); end, end
  if numel(Daos)>0; if(sum(sum(Daos==0))/numel(Daos))>0.5; Daos = sparse(Daos); end, end
  if numel(Bnoise)>0; if(sum(sum(Bnoise==0))/numel(Bnoise))>0.5; Bnoise = sparse(Bnoise); end, end
  if numel(Dnoise)>0; if(sum(sum(Dnoise==0))/numel(Dnoise))>0.5; Dnoise = sparse(Dnoise); end, end
  if numel(Bcst)>0; if(sum(sum(Bcst==0))/numel(Bcst))>0.5; Bcst = sparse(Bcst); end, end
  if numel(Dcst)>0; if(sum(sum(Dcst==0))/numel(Dcst))>0.5; Dcst = sparse(Dcst); end, end
  
  %% initializing fields
  x = zeros(size(Cstates,1), Nsamples);
  y = zeros(size(Coutputs,1), Nsamples);
  Nnoise = size(Bnoise,2);
  BLOCK_SIZE = min( [ floor(1e6/(size(Baos,2) + size(Baos,1) + size(Bnoise,2) + 1)) , Nsamples]);
 
  BLOCK_N   = 10;
  BLOCK_SIZE = floor(Nsamples/BLOCK_N);
  BLOCK_REST = mod(Nsamples, BLOCK_SIZE);
  BLOCK_SAMPLES = BLOCK_SIZE*BLOCK_N;
  
  % noise_array = randn(Nnoise,BLOCK_SIZE); 
  
  % state equations are
  % x(k+1) = A*x(k) + B*u(k)
  % y(k)   = C*x(k) + D*u(k)
  % Assuming our simulation starts at k=1
  % the lastX input to doSimulate is x(k) at k=1
  % E.g. the lastX input is produced by a previous simulation that has
  % ended at the step 0 of the current simulation. Therefore in the last
  % state advancing step it has produced x(1) = A'*x(0) + B'*x(0)
  % This mean that when we start out simulation we already know x(1) and we
  % can directly calculate y(1) = C*x(1) + D*u(1)
  % in other words we do not need the following step
  % lastX  = A*lastX +  Bcst + Bnoise*noise_array(:,1) + Baos*aos_vect(:,1);
  % originally uncommented
  
  
  
  % time for displaying remaining time
  time1=time;
  
  %% simulation loop
  for kk = 1:Nsamples
    %% writing white noise and displaying time
    if mod(kk-1, BLOCK_SIZE) == 0
       noise_array = randn(Nnoise, BLOCK_SIZE);
      if displayTime
        display( ['         simulation time : ',num2str(kk*timestep) ]);
        time2 = time;
        tloop = floor(time2.utc_epoch_milli-time1.utc_epoch_milli)/1000;
        display( ['remaining computing time : ',num2str(tloop*(Nsamples-kk+1)/kk), 's' ]);
      end
    end
    
    %% evaluating differences
    if kk <= BLOCK_SAMPLES
      knoise = mod(kk, BLOCK_SIZE);
      if knoise == 0, knoise = BLOCK_SIZE; end
      noise = noise_array(:, knoise);
    else
      noise = randn(Nnoise, 1);
    end
    
    %% computing and storing outputs
     y(:,kk) = Coutputs*lastX +  Dcst + Dnoise*noise + Daos*aos_vect(:,kk);
%     noise_array = randn(Nnoise, 1);
%     y(:,k) = Coutputs*lastX +  Dcst + Dnoise*noise_array + Daos*aos_vect(:,k);
    
    %% computing and storing states
    x(:,kk) = Cstates*lastX;
   lastX  = A*lastX +  Bcst + Bnoise*noise + Baos*aos_vect(:,kk);
%     lastX  = A*lastX +  Bcst + Bnoise*noise_array + Baos*aos_vect(:,k);
    
    %% checking possible termination condition
    if doTerminate
      if eval(terminationCond)
        x = x(:,1:kk);
        y = y(:,1:kk);
        break;
      end
    end
    
  end
  
end

