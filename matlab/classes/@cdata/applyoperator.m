% APPLYOPERATOR applys the given operator to the two input data objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYOPERATOR applys the given operator to the two input
%              cdata objects.
%
% CALL:        d = applyoperator(d1, d2, pl)
%
% INPUTS:      d1 - a cdata object
%              d2 - a ltpda_data object (cdata, tsdata, fsdata, xydata)
%              pl     - a plist of configuration options
%
% PARAMETERS: 'op'     - the operator to apply, e.g. 'power'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = applyoperator(varargin)

  % Get the objects we have in the correct order
  objs = varargin(1:2);

  % Get the operator to apply
  op = varargin{3};
  
  if numel(objs) ~= 2
    error('### cdata/applyoperator requires two input data objects to work on.');
  end
  
  % Decide the type of the output object
  if isa(objs{1}, 'data2D')
    %%% The first object in objs could not be a data2D because
    %%% then calls MATLAB data2D/applyoperator
    error('### Could/should not happen. Class obj1 [%s] class obj2 [%s]', class(objs{1}), class(objs{2}))
  elseif isa(objs{2}, 'data2D')
    dout = objs{2};
  else
    dout = objs{1};
  end
    

  % Here we make some checks  
  s1 = size(objs{1}.yaxis.data);
  s2 = size(objs{2}.yaxis.data);
  trans = false;
  
  % The exponent size should be the same OR one of the two should be 1
  if ~isequal(s1, s2)
    if isequal(s1, flipdim(s2, 2))
      % We will need to transpose one vector
      trans = true;
    elseif ~isequal(s1, [1 1]) && ~isequal(s2, [1 1])
      error('### Mismatch between the data and the exponent size')
    end
  end
  
  % Calculate the uncertainty
  if ~isempty(objs{1}.yaxis.ddata)
    switch op
      case 'power'
        if trans
          dout.setDy(objs{1}.yaxis.ddata .* abs(objs{2}.yaxis.data' .* objs{1}.yaxis.data.^(objs{2}.yaxis.data'-1)));
        else
          dout.setDy(objs{1}.yaxis.ddata .* abs(objs{2}.yaxis.data .* objs{1}.yaxis.data.^(objs{2}.yaxis.data-1)));
        end
      case 'mpower'
        if length(dout.y) == 1
          dout.setDy(objs{1}.dy .* abs(objs{2}.y .* objs{1}.y.^(objs{2}.y-1)));
        else
          dout.setDy([]);
        end
      otherwise
        dout.setDy([]);
    end
  end
  
  % Finally, apply the operator to the data
  if trans
    dout.setY(feval(op, objs{1}.yaxis.data, objs{2}.yaxis.data'));
  else
    dout.setY(feval(op, objs{1}.yaxis.data, objs{2}.yaxis.data));
  end

  varargout{1} = dout;
end


