function [t,y,x] = do_a_run_mat(Nruns, Nsamples, Nstates, Nstatesout, Ninputs, Noutputs)
  
  lastX     = zeros(Nstates,1);
  A         = 0.1*rand(Nstates);
  Coutputs  = rand(Noutputs,Nstates);
  Cstates   = eye(Nstates);
  Cstates   = Cstates(1:Nstatesout,1:Nstates);
  Baos      = rand(Nstates,Ninputs);
  Daos      = rand(Noutputs, Ninputs);
  input     = randn(Ninputs, Nsamples);
  
  
  tic
  for rr=1:Nruns
    [y,x,lx] = mat_ssmsim(lastX, A, Coutputs, Cstates, Baos, Daos, input);
  end
  mxtime = toc;
  t = mxtime/Nruns;
end
