% DOUBLE tries to evaluate a msym to a double.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DOUBLE tries to evaluate a msym to a double.
%
% CALL:        n = double(obj)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = double(o)
  try
    a = eval(o.s);
  catch Me
    disp(Me.message);
    error('### Evaluation of the symbolic expression failed. Perhaps it contains undefined parameters');
  end
end

