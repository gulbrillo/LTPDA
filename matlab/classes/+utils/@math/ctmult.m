function d = ctmult(C, A)
  % Multiplication function designed for the
  % purposes of the log-likelihood calculations:
  % The first input is transformed to it's conjugate
  for ii=1:size(C,2)

    m(:,ii) = conj(C(:,ii)).*A(:,ii);

  end
  
  d = sum(m,2);

end