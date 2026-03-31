% DISP overloads display functionality for timespan objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: DISP overloads display functionality for timespan objects.
%
% CALL:        txt = disp(ts)
%
% INPUT:       ts  - timespan object
%
% OUTPUT:      txt - cell array with strings to display the timespan object
%
% <a href="matlab:utils.helper.displayMethodInfo('timespan', 'disp')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = disp(varargin)

  %%% Check if this is a call for parameters
  if utils.helper.isinfocall(varargin{:})
    varargout{1} = getInfo(varargin{3});
    return
  end

  % Collect all time-objects
  ts = utils.helper.collect_objects(varargin(:), 'timespan');

  txt = {};

  % Print emtpy object
  if isempty(ts)
    hdr = sprintf('------ %s -------', class(ts));
    ftr(1:length(hdr)) = '-';
    txt = [txt; {hdr}];
    txt = [txt; sprintf('empty-object [%d,%d]',size(ts))];
    txt = [txt; {ftr}];
  end
  
  for ii = 1:numel(ts)
    t = ts(ii);

    b_banner = sprintf('---------- timespan %02d ----------', ii);
    txt{end+1} = b_banner;
    txt{end+1} = ' ';

    % Fields to show
    fields = {'name', 'startT', 'endT', 'hist', 'description', 'UUID'};
    max_length = length(fields{1});
    for jj = 2:length(fields)
      if length(fields{jj}) > max_length
        max_length = length(fields{jj});
      end
    end

    for jj = 1:length(fields)
      field = fields{jj};

      str_field = [];
      str_field(1:max_length-length(field)) = ' ';
      str_field = [str_field field];

      % Display: Number
      if isnumeric(t.(field))
        txt{end+1} = sprintf ('%s: %s',str_field, num2str(t.(field)));

        % Display: Strings
      elseif ischar(t.(field))
        txt{end+1} = sprintf ('%s: %s',str_field, t.(field));

        % Display: Logicals
      elseif islogical(t.(field))
        if t.(field) == true
          txt{end+1} = sprintf ('%s: true',str_field);
        else
          txt{end+1} = sprintf ('%s: false',str_field);
        end

        % Display: Objects
      elseif isobject(t.(field))
        if isa(t.(field), 'time') || isa(t.(field), 'timeformat') || isa(t.(field), 'plist') || isa(t.(field), 'provenance')
          txt{end+1} = sprintf ('%s: %s',str_field, char(t.(field)));
        else
          txt{end+1} = sprintf ('%s: %s-object',str_field, class(t.(field)));
        end
        
      elseif iscell(t.(field))
        txt{end+1} = sprintf('%s: %s',str_field, utils.helper.val2str(t.(field)));

      else
        error ('### Please define the output for this property %s', field)
      end

    end


    e_banner(1:length(b_banner)) = '-';
    txt{end+1} = e_banner;

    txt{end+1} = ' ';
    txt{end+1} = ' ';

  end

  if nargout == 0
    for ii=1:length(txt)
      disp(txt{ii});
    end
  else
    varargout{1} = txt;
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
% HISTORY:     11-07-07 M Hewitson
%                Creation.
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
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.output, '', sets, pl);
  ii.setModifier(false);
  ii.setOutmin(0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    getDefaultPlist
%
% DESCRIPTION: Get Default Plist
%
% HISTORY:     11-07-07 M Hewitson
%                Creation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

