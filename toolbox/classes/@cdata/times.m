% TIMES implements element multiplication for cdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: TIMES implements element multiplication for two cdata objects.
%
% CALL:
%              a = d1.*d2
%              a = times(d1,d2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('cdata', 'times')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = times(varargin)
  
  % get two data objects
  d1 = copy(varargin{1}, nargout);
  d2 = copy(varargin{2}, nargout);
  
  % check units
  d1.yaxis.units.simplify();
  d2.yaxis.units.simplify();
    
  % add the data
  dout = applyoperator(d1,d2,'times');
  
  % handle units: multiply the units
  dout.setYunits(d1.yaxis.units.*d2.yaxis.units);
  
  % handle errors
  err = @(err1, err2, val1, val2) sqrt( (err1./val1).^2 + (err2./val2).^2 ) .* abs(val1.*val2);
  if ~isempty(d1.yaxis.ddata) || ~isempty(d2.yaxis.ddata)    
    if isempty(d1.yaxis.ddata)
      d1.setDy(zeros(size(d2.yaxis.ddata)));
    end
    if isempty(d2.yaxis.ddata)
      d2.setDy(zeros(size(d1.yaxis.ddata)));
    end    
    dout.setDy(err(d1.dy, d2.dy, d1.y, d2.y));
  else
    dout.setDy([]);
  end

  % Single output
  varargout{1} = dout;
  
end

