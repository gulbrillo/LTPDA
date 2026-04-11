% COLLAPSEX Checks whether the x vector is evenly sampled and then removes it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Checks whether the x vector is evenly sampled and then removes
%              it after setting the t0 field.
%
% CALL:        obj = collapseX(obj)
%
% INPUT:       obj - tsdata object
%
% OUTPUT:      obj - tsdata object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = collapseX(varargin)

  obj = varargin{1};

  %%% decide whether we modify the tsdata object, or create a new one.
  obj = copy(obj, nargout);
  
  if ~isempty(obj.xaxis.data)
    
    % check if the can remove X samples
    [fs, ~, unevenly] = tsdata.fitfs(obj.xaxis.data);
    obj.fs = fs;

    if ~unevenly
      % adjust toffset
      obj.toffset = obj.toffset + obj.xaxis.data(1)*1e3;
      
      % remove X samples
      % ATTENTION: It is not allowed to use the setter function (tsdata)
      %            because the setter sets the toffset to 0.
      obj.xaxis.setData([]);
    end
  end

  % Eventually, we might have to adjust nsecs
  obj.fixNsecs();
  
  varargout{1} = obj;
end

