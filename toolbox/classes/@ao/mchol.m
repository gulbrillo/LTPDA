% MCHOL.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: MCHOL
%
% CALL:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = mchol(m)

  leng = length(m);
  for i=1:leng
    dets(i) = det(m(1:i, 1:i));
  end

  sqdet = sqrt(dets);
  if isreal('sqdet')==0
    error('### matrix not positive definite')
  end

  if(isa(m,'sym'))
    M = m;
    n = length( M );
    L = vpa(zeros( n, n ));
    for i=1:n
      L(i, i) = sqrt( M(i, i) - L(i, :)*L(i, :)' );
      for j=(i + 1):n
        L(j, i) = ( M(j, i) - L(i, :)*L(j, :)' )/L(i, i);
      end
    end
    % L = solve('L');
    varargout{1} = L;
  end

end
