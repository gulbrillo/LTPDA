% VALIDATE checks that the input Analysis Object is reproducible and valid.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: VALIDATE checks that the input Analysis Object is
%              reproducible and valid.
%
% CALL:        b = validate(a)
%
% INPUTS:      a - a vector, matrix or cell array of Analysis Objects
%
% OUTPUTS:     b - a vector, matrix or cell array of logical results:
%              0 - input object failed
%              1 - input object passed
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'validate')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = validate(varargin)

  % Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  import utils.const.*
  utils.helper.msg(msg.PROC3, 'running %s/%s', mfilename('class'), mfilename);
  
  % Collect input variable names
  in_names = cell(size(varargin));
  try for ii = 1:nargin,in_names{ii} = inputname(ii); end; end

  % Collect all AOs and plists
  [as, ao_invars] = utils.helper.collect_objects(varargin(:), 'ao', in_names);

  % --- Initial set up
  versions = []; % initialised with function: ltpda_versions
  v = ver('LTPDA');
  warning('!!! This method (%s) doesn''t work for the moment. The script ltpda_versions.m doesn''t exist in LTPDA %s only in 1.9.1. We have to update this method.', mfilename, v.Version);
  return
  ltpda_versions;
  passed = zeros(1, numel(as));

  % Check each input analysis object
  for ec=1:numel(as)
    % get a list of files that built this object
    [n,a,nodes] = getNodes(as(ec).hist);

    % Initialise the match vector
    matches = zeros(length(nodes),1);

    % Loop over each history node, i.e., each function
    for jj=1:length(nodes)
      % This node
      node = nodes(jj);
      % Assume failure to start with
      matches(jj) = 0;
      % get fcn name
      fcnname = node.hist.methodInfo.mname;
      % Find all functions in MATLAB path with this name
      mfiles = which(fcnname, '-ALL');
      % Find all matches in versions{}
      idx = ismember(versions(:,2), fcnname);
      ltpdafiles = versions(find(idx==1), 1);
      % check against each one found
      for kk=1:length(mfiles)
        mfile = mfiles{kk};
        % make file hash
        try
          % Load the full file contents
          fd = fopen(mfile, 'r');
          fc = fscanf(fd, '%s');
          fclose(fd);
          % Make MD5 hash
          mhash = utils.prog.hash(fc, 'MD5');
          % Check against all ltpda files with this function name
          for ll=1:length(ltpdafiles)
            % this file
            lfile = ltpdafiles{ll};
            % Load file contents
            fd = fopen(lfile, 'r');
            fc = fscanf(fd, '%s');
            fclose(fd);
            % Make MD5 hash
            lhash = utils.prog.hash(fc, 'MD5');
            % Compares hashes
            if strcmp(mhash, lhash)
              matches(jj) = 1;
            end
          end
        catch
          warning('!!! failed to test against: %s', mfile);
        end
      end % End loop over files on MATLAB path

      if matches(jj)==0
        fails = which(fcnname, '-ALL');
        for ff=1:length(fails)
          utils.helper.msg(msg.PROC1, 'Illegal function: %s', fails{ff});
        end
      end
    end % end loop over nodes

    % Decide whether or not this AO is valid
    if sum(matches) == length(nodes)
      passed(ec) = 1;
      utils.helper.msg(msg.PROC1, 'AO validated');
    else
      passed(ec) = 0;
      utils.helper.msg(msg.PROC1, 'AO not validated');
    end
  end % end loop over all objects

  % Set outputs
  varargout{1} = passed;
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pl   = [];
  else
    sets = {'Default'};
    pl   = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.helper, '', sets, pl);
  ii.setModifier(false);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if exist('pl', 'var')==0 || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  pl = plist.EMPTY_PLIST;
end
% END

