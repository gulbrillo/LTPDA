% PLUS implements addition operator for data2D objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLUS implements addition operator for two data2D objects.
%
% CALL:
%              a = d1+d2
%              a = plus(d1,d2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('data2D', 'plus')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plus(varargin)
  
  % get two data objects
  d1 = copy(varargin{1}, nargout);
  d2 = copy(varargin{2}, nargout);
  
  % check units
  d1.yaxis.units.simplify();
  d2.yaxis.units.simplify();
  d1.xaxis.units.simplify();
  d2.xaxis.units.simplify();
  
  if ~isempty(d1.yaxis.units.strs) && ~isempty(d2.yaxis.units.strs) && ~isequal(d1.yaxis.units, d2.yaxis.units)
    error('### When adding two data objects, the yunits must be the same');
  end
  if ~isempty(d1.xaxis.units.strs) && ~isempty(d2.xaxis.units.strs) && ~isequal(d1.xaxis.units, d2.xaxis.units)
    error('### When adding two data objects, the xunits must be the same');
  end
  
  % add the data
  dout = applyoperator(d1,d2,'plus');
  
  % handle units: since both are the same, we take the first non-empty unit
  if isempty(d1.yaxis.units.strs)
    dout.setYaxis(copy(d2.yaxis.units, 1));
  else
    dout.setYunits(copy(d1.yaxis.units, 1));
  end
  if isempty(d1.xaxis.units.strs)
    dout.setXunits(copy(d2.xaxis.units, 1));
  else
    dout.setXunits(copy(d1.xaxis.units, 1));
  end
  
  % handle errors
  err = @(err1, err2, val1, val2) sqrt(err1 .^2 + err2.^2);
  if ~isempty(d1.getDy) || ~isempty(d2.getDy)    
    if isempty(d1.getDy)
      d1.setDy(zeros(size(d2.getDy)));
    end
    if isempty(d2.getDy)
      d2.setDy(zeros(size(d1.getDy)));
    end    
    dout.setDy(err(d1.getDy, d2.getDy, d1.getY, d2.getY));
  else
    dout.setDy([]);
  end
  if ~isempty(d1.getDx) || ~isempty(d2.getDx)    
    if isempty(d1.getDx)
      d1.setDx(zeros(size(d2.getDx)));
    end
    if isempty(d2.getDx)
      d2.setDx(zeros(size(d1.getDx)));
    end    
    dout.setDx(err(d1.getDx, d2.getDx, d1.getX, d2.getX));
  else
    dout.setDx([]);
  end

  
  % Single output
  varargout{1} = dout;
  
end

