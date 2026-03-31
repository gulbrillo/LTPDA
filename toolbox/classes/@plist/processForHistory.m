% PROCESSFORHISTORY process the plist ready for adding to the history tree.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:    PROCESSFORHISTORY process the plist ready for adding to the history tree.
%
%
% CALL:        plout = processForHistory(pl, Nobjs, idx, keys)
%
% PARAMETERS:    pl: the input plist 
%             Nobjs: the number of objects that this plist is being used to process
%               idx: the index of the object currently being processed
%              keys: a list of keys which support multiple values and which
%                    may be modified by this method.
% 
% NOTE: The point is to handle the keys which support multiple values and
% to ensure that a particular object gets the correct history plist. This
% needs to be used in the case where we are adding history to a single
% object (in a loop). Using it in any other case will likely cause
% problems.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = processForHistory(varargin)

  pl    = varargin{1};
  nobjs = varargin{2};
  idx   = varargin{3};
  keys  = varargin{4};
  
  plout = copy(pl, 1);
  
  for kk=1:numel(keys)
    key = keys{kk};
    if pl.isparam_core(key)
      val = pl.find_core(key);
      if iscell(val)
        if numel(val) == 1
          plout.pset(key, val{1});
        else
          if numel(val) ~= nobjs
            error('The number of values for key %s does not match the number of objects', key);
          end
          plout.pset(key, val{idx});
        end
      end
    end
  end
  
  varargout{1} = plout;
end
