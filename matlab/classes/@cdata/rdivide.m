% RDIVIDE implements element division for cdata objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: RDIVIDE implements element division for two cdata objects.
%
% CALL:
%              a = d1./d2
%              a = rdivide(d1,d2);
%
%
% <a href="matlab:utils.helper.displayMethodInfo('cdata', 'rdivide')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = rdivide(varargin)
  
  % get two data objects
  d1 = copy(varargin{1}, nargout);
  d2 = copy(varargin{2}, nargout);
  
  % check units
  d1.yaxis.units.simplify();
  d2.yaxis.units.simplify();  
  
  % add the data
  dout = applyoperator(d1,d2,'rdivide');
  
  % handle units: divide the units
  dout.setYunits(d1.yaxis.units./d2.yaxis.units);
  
  % handle errors
  err = @(err1, err2, val1, val2) sqrt( (err1./val1).^2 + (err2./val2).^2 ) .* abs(val1./val2);
  if ~isempty(d1.yaxis.ddata) || ~isempty(d2.yaxis.ddata)    
    if isempty(d1.yaxis.ddata)
      d1.setDy(zeros(size(d2.yaxis.ddata)));
    end
    if isempty(d2.yaxis.ddata)
      d2.setDy(zeros(size(d1.yaxis.ddata)));
    end    
    dout.setDy(err(d1.yaxis.ddata, d2.yaxis.ddata, d1.yaxis.data, d2.yaxis.data));
  else
    dout.setDy([]);
  end

  % Single output
  varargout{1} = dout;
  
end

