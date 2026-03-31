% PLUS Implements addition operator for time objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Implements addtion operator for time objects. Numeric and string
% operands are transparently handled converting them to time objects. Vector
% operands are handled accordingly to MATLAB conventions.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t = plus(t1, t2)

  if isnumeric(t1)
    d1 = t1*1e3;
  elseif ischar(t1)
    t1 = time(t1);
    d1 = [t1.utc_epoch_milli];
  elseif isa(t1, 'time')
    d1 = [t1.utc_epoch_milli];
  else
    error('LTPDA:TypeError', ...
          '### unsupported operand classes for plus: ''%s'' and ''%s''', ...
          class(t1), class(t2));
  end

  if isnumeric(t2)
    d2 = t2*1e3;
  elseif ischar(t2)
    t2 = time(t2);
    d2 = [time(t2).utc_epoch_milli];
  elseif isa(t2, 'time')
    d2 = [t2.utc_epoch_milli];
  else
    error('LTPDA:TypeError', ...
          '### unsupported operand classes for plus: ''%s'' and ''%s''', ...
          class(t1), class(t2));
  end
  
  t = time((d1 + d2)/1e3);
end
