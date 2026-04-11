% PLUS implements addition operator for data3D objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLUS implements addition operator for two data3D objects.
%
% CALL:
%              a = d1+d2
%              a = plus(d1,d2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('data3D', 'plus')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plus(varargin)
  
  % get two data objects
  d1 = copy(varargin{1}, nargout);
  d2 = copy(varargin{2}, nargout);
  
  % check units
  d1.zaxis.units.simplify();
  d2.zaxis.units.simplify();
  d1.yaxis.units.simplify();
  d2.yaxis.units.simplify();
  d1.xaxis.units.simplify();
  d2.xaxis.units.simplify();
  
  if ~isempty(d1.zaxis.units.strs) && ~isempty(d2.zaxis.units.strs) && ~isequal(d1.zaxis.units, d2.zaxis.units)
    error('### When adding two data objects, the zunits must be the same');
  end
  if ~isempty(d1.yaxis.units.strs) && ~isempty(d2.yaxis.units.strs) && ~isequal(d1.yaxis.units, d2.yaxis.units)
    error('### When adding two data objects, the yunits must be the same');
  end
  if ~isempty(d1.xaxis.units.strs) && ~isempty(d2.xaxis.units.strs) && ~isequal(d1.xaxis.units, d2.xaxis.units)
    error('### When adding two data objects, the xunits must be the same');
  end
  
  % add the data
  dout = applyoperator(d1,d2,'plus');
  
  % handle units: since both are the same, we take the first non-empty unit
  if isempty(d1.zaxis.units.strs)
    dout.setZunits(copy(d2.zaxis.units, 1));
  else
    dout.setZunits(copy(d1.zaxis.units, 1));
  end
  if isempty(d1.yaxis.units.strs)
    dout.setYunits(copy(d2.yaxis.units, 1));
  else
    dout.setYunits(copy(d1.yaxis.units, 1));
  end
  if isempty(d1.xaxis.units.strs)
    dout.setXunits(copy(d2.xaxis.units, 1));
  else
    dout.setXunits(copy(d1.xaxis.units, 1));
  end
  
  % handle errors
  err = @(err1, err2) sqrt(err1 .^2 + err2.^2);
  if ~isempty(d1.zaxis.ddata) || ~isempty(d2.zaxis.ddata)    
    if isempty(d1.zaxis.ddata)
      d1.setDz(zeros(size(d2.zaxis.ddata)));
    end
    if isempty(d2.zaxis.ddata)
      d2.setDz(zeros(size(d1.zaxis.ddata)));
    end    
    dout.setDz(err(d1.zaxis.ddata, d2.zaxis.ddata));
  else
    dout.setDz([]);
  end
  if ~isempty(d1.yaxis.ddata) || ~isempty(d2.yaxis.ddata)    
    if isempty(d1.yaxis.ddata)
      d1.setDy(zeros(size(d2.yaxis.ddata)));
    end
    if isempty(d2.yaxis.ddata)
      d2.setDy(zeros(size(d1.yaxis.ddata)));
    end    
    dout.setDy(err(d1.yaxis.ddata, d2.yaxis.ddata));
  else
    dout.setDy([]);
  end
  if ~isempty(d1.xaxis.ddata) || ~isempty(d2.xaxis.ddata)    
    if isempty(d1.xaxis.ddata)
      d1.setDx(zeros(size(d2.xaxis.ddata)));
    end
    if isempty(d2.xaxis.ddata)
      d2.setDx(zeros(size(d1.xaxis.ddata)));
    end    
    dout.setDx(err(d1.xaxis.ddata, d2.xaxis.ddata));
  else
    dout.setDx([]);
  end
  
  % Single output
  varargout{1} = dout;
  
end

