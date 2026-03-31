% PARSE a plist for strings which can be converted into numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: PARSE a plist for strings which can be converted into numbers
%              depending on the default plist
%
% CALL:        plo = parse(pl, dpl)
%
% EXAMPLE:      pl = plist('x', '3', 'y', 'x+5', 'z', 'x-y')
%              dpl = plist('x', [], 'y', [], 'z', [])
%
%               pl = plist('x', '1:12', 'y', 'randn(length(x),1)')
%              dpl = plist('x', [], 'y', [], 'z', [])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ppl = parse(varargin)
  
  %%% Check if this is a call for parameters
  if nargin == 3 && utils.helper.isinfocall(varargin{:})
    ppl = getInfo(varargin{3});
    return
  end
  
  if nargin > 0
    pl = varargin{1};
  else
    error('### Input at least one plist.');
  end
  
  % if we don't get a default plist, then we can't parse
  if nargin == 1
    ppl = copy(pl, nargout);
    return
  end
  
  if nargin > 1
    dpl = varargin{2};
  else
    dpl = plist();
  end
  
  if isempty(pl)
    pl = plist();
  end
  if isempty(dpl)
    dpl = plist();
  end
  
  % combine
  if numel(pl) > 1
    pl  = combine(pl); % in case we get more than one input plist
  end
  ppl = combine(pl, dpl);
  
  % check each parameter and replace key names with upper-case key names
  matches = zeros(size(ppl.params));
  for kk=1:numel(ppl.params)
    sval  = ppl.params(kk).getVal;
    if ( ischar(sval) || isnumeric(sval) )
      if ischar(sval)
        if any(matchKeys_core(dpl, ppl.params(kk).key))
          if isnumeric(find(dpl, ppl.params(kk).defaultKey))
            % look for matching key strings
            for jj=1:numel(ppl.params)
              if jj ~= kk
                key = ppl.params(jj).defaultKey;
                % get words out of sval
                words = regexp(sval, '(\w+)', 'match');
                wordidxs = regexp(sval, '(\w+)');
                % do any of these words match the key?
                idx = strcmpi(words, key);
                for ll=1:numel(idx)
                  if idx(ll)
                    word = words{ll};
                    matches(kk) = 1;
                    val = ppl.params(kk).getVal;
                    sidx = wordidxs(ll):wordidxs(ll)+length(word)-1;
                    val(sidx) = upper(val(sidx));
                    ppl.params(kk).setVal(val);
%                     ppl.params(kk).setVal(strrep(ppl.params(kk).getVal, word, upper(word)));
                  end % If matched
                end % end loop over matches
              end
            end % End loop over params
          else % not numeric parameter
            matches(kk) = -1;
          end
        else % key is not present in default plist
          matches(kk) = -1;
        end
      else % param value is not char
        matches(kk) = 0;
      end
    else % param value is neither char nor numeric
      matches(kk) = -1;
    end
  end % end loop over params
  
  % Don't eval parameters in default plist if they are not in the input
  % plist
  for kk=1:numel(ppl.params)
    if ~any(matchKeys_core(pl, ppl.params(kk).key))
      matches(kk) = -1;
    end
  end
  
  % First eval all non-dependent keys
  for kk=1:numel(ppl.params)
    if matches(kk) == 0
      if ischar(ppl.params(kk).getVal)
        try
          ev = eval(ppl.params(kk).getVal);
          ppl.params(kk).setVal(ev);
        catch me
          utils.helper.warn(utils.const.msg.MNAME, sprintf('Unable to evaluate non-dependent parameter [%s]. Leaving it as char.', ppl.params(kk).getVal));
        end
      else
        ev = ppl.params(kk).getVal;
      end
      % If they are needed later, put them in this workspace
      if any(matches>0)
        cmd = [ppl.params(kk).defaultKey '=' mat2str(ev) ';'];
        eval(cmd);
      end
    end
  end
  
  % Now evaluate dependent parameters
  count = 0;
  while any(matches>0) && count < 100
    for kk=1:numel(ppl.params)
      if matches(kk)==1
        try
          ppl.params(kk).setVal(eval(ppl.params(kk).getVal));
          cmd = sprintf('%s = %s;', ppl.params(kk).defaultKey, mat2str(ppl.params(kk).getVal));
          eval(cmd);
          matches(kk) = 0;
        end
      end
    end
    count = count + 1;
  end
  
  % did we reach maximum number of tries?
  if count >= 100
    for kk=1:numel(matches)
      if matches(kk) == 1
        warning('!!! Can''t resolve dependency in parameter: %s', ppl.params(kk).defaultKey);
        % Chenge the value back to the input values in case of dependency.
        % It might be that we changed this value to upper case.
        ppl.params(kk).setVal(pl.find(ppl.params(kk).key));
      end
    end
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               Local Functions                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getInfo
%
% DESCRIPTION: Get Info Object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.internal, '', sets, pl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plo = getDefaultPlist()
  plo = plist();
end


