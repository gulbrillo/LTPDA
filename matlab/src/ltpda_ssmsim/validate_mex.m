function [yx,xx,lxx,y,x,lx] = validate_mex(Nsamples, Nstates, Nstatesout, Ninputs, Noutputs)
  
  lastX     = zeros(Nstates,1);
  A         = 0.1*rand(Nstates);
  Coutputs  = rand(Noutputs,Nstates);
  Cstates   = eye(Nstates);
  Cstates   = Cstates(1:Nstatesout,1:Nstates);
  Baos      = rand(Nstates,Ninputs);
  Daos      = rand(Noutputs, Ninputs);
  input     = randn(Ninputs, Nsamples);
  
  xx = [];
  [yx,lxx] = ltpda_ssmsim(lastX, A.', Coutputs.', Cstates, Baos.', Daos.', input);
  [y,x,lx] = mat_ssmsim(lastX, A, Coutputs, Cstates, Baos, Daos, input);
  
  
    
end
