function d = mult(C, A)
  % Multiplication function designed specially for the
  % purposes of the log-likelihood calculations
  for ii=1:size(C,2)
    for jj=1:size(A,2)

      Cn = C(:,ii,:);
      m(:,jj) = Cn(:,jj).*A(:,jj);

    end
    
    d(:,ii) = sum(m,2);
    
  end

end