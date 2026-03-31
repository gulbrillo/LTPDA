% COPY copies all fields of the ltpda_uoh class to the new object.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COPY copies all fields of the ltpda_uoh class to the new
%              object.
%
% CALL:        b = copy(new, old, flag)
%
% INPUTS:      new  - new object which should be created in the sub class.
%              old  - old object
%              flag - 1: make a deep copy, 0: return copies of handles
%
% OUTPUTS:     b - copy of inputs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = copy(new, old, deepcopy, addHist)
  
  if deepcopy
    obj = copy@ltpda_uo(new, old, 1);
    
    for kk = 1:numel(obj)
      %%% copy all fields of the ltpda_uoh class
      obj(kk).hist        = old(kk).hist;
      if ~isempty(old(kk).procinfo)
        obj(kk).procinfo = copy(old(kk).procinfo,1);
      end
      if ~isempty(old(kk).plotinfo)
        obj(kk).plotinfo = copy(old(kk).plotinfo,1);
      end
      if ~isempty(old(kk).timespan)
        obj(kk).timespan = copy(old(kk).timespan,1);
      end
      
      if addHist == 1
        mi = minfo(mfilename(), class(new), 'ltpda', utils.const.categories.helper, '', {}, []);
        obj(kk).addHistory(mi, [], [], obj(kk).hist);
      end
      
    end
    
  else
    obj = old;
  end
  
  varargout{1} = obj;
end
