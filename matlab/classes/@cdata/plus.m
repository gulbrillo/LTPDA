% PLUS implements addition operator for cdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PLUS implements addition operator for two cdata objects.
%
% CALL:        a = d1+d2
%              a = plus(d1,d2);
%
% <a href="matlab:utils.helper.displayMethodInfo('cdata', 'plus')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = plus(varargin)
  
  % get two data objects
  d1 = copy(varargin{1}, nargout);
  d2 = copy(varargin{2}, nargout);
  
  % check units
  d1.yaxis.units.simplify();
  d2.yaxis.units.simplify();
  
  if ~isempty(d1.yaxis.units.strs) && ~isempty(d2.yaxis.units.strs) && ~isequal(d1.yaxis.units, d2.yaxis.units)
    error('### When adding two data objects, the yunits must be the same');
  end
  
  % add the data
  dout = applyoperator(d1,d2,'plus');
  
  % handle units: since both are the same, we take the first non-empty unit
  if isempty(d1.yaxis.units.strs)
    dout.setYunits(d2.yaxis.units);
  else
    dout.setYunits(d1.yaxis.units);
  end
  
  % handle errors
  err = @(err1, err2) sqrt(err1 .^2 + err2.^2);
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

  
  % Single output
  varargout{1} = dout;
  
end

