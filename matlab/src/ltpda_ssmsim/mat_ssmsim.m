function [y,x,lastX] = mat_ssmsim(lastX, A, Coutputs, Cstates, Baos, Daos, input)
  
  Nsamples = size(input,2);
  y = zeros(size(Coutputs,1),Nsamples);
  x = zeros(size(Cstates,1),Nsamples);
  
  for k = 1:Nsamples
    y(:,k) = Coutputs*lastX + Daos*input(:,k);
    x(:,k) = Cstates*lastX;
    lastX  = A*lastX + Baos*input(:,k);
  end
  
  
end