% FILTER overrides the filter function for analysis objects.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: FILTER overrides the filter function for analysis objects.
%              Applies the input digital IIR/FIR filter to the input analysis
%              object. If the input analysis object contains a
%              time-series (tsdata) then the filter is applied using the normal
%              recursion algorithm. The output analysis object contains a tsdata
%              object.
%
%              If the input analysis object contains a frequency-series (fsdata)
%              then the response of the filter is computed and then multiplied
%              with the input frequency series. The output analysis object
%              contains a frequency series.
%
% CALL:        >> b = filter(a,pl)
%              >> b = filter(a,filt,pl)
%              >> b = filter(a,pl)
%
% INPUTS:      pl   - a parameter list
%              a    - input analysis object
%
% OUTPUTS:
%              b    - output analysis object containing the filtered data.
%
% PROCINFO:    The input filter object with the history values filled in are
%              always stored with a plist in the 'procinfo' property of the AO.
%              The key of the plist to get the filter is 'FILTER'.
%
%
% <a href="matlab:utils.helper.displayMethodInfo('ao', 'filter')">Parameters Description</a>
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = filter(varargin)

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
  [pl, pl_invars] = utils.helper.collect_objects(varargin(:), 'plist', in_names);
  [fobjs, f_invars] = utils.helper.collect_objects(varargin(:), 'ltpda_filter', in_names);
  [fbobjs, fb_invars] = utils.helper.collect_objects(varargin(:), 'filterbank', in_names);
  [mobjs, m_invars] = utils.helper.collect_objects(varargin(:), 'matrix', in_names);

  % Make copies or handles to inputs
  bs   = copy(as, nargout);

  % combine plists
  pl = applyDefaults(getDefaultPlist(), pl);
  
  % Filter with a filterbank object or a matrix
  filterbankName = '';
  if ~isempty(fbobjs)
    filterbankName = fbobjs.name;
    fobjs = fbobjs.filters;
    pl.pset('bank', fbobjs.type);
  elseif ~isempty(mobjs)
    fobjs = mobjs.objs;
    % check we do not have more than one object into the matrix, if this is
    % the case the problem is considered a N-dimensional filtering problem
    % that can be solved by matrix/filter
    if numel(mobjs.objs)>1
      error(['### Filter matrix has more than one object. '...
        'This seems to be a N-dimensional filtering problem that has to be solved with matrix/filter. '...
        'Type help matrix/filter for more information ###']);
    end
    if isa(fobjs,'filterbank') % in case of filterbanks
      pl.pset('bank', fobjs.type);
      filterbankName = fobjs.name;
      fobjs = fobjs.filters;  
    end
  end

  if isempty(fobjs)
    fobjs = find_core(pl, 'filter');
    % check if we have filterbank or matrix
    if isa(fobjs,'filterbank') % in case of filterbank
      pl.pset('bank', fobjs.type);
      filterbankName = fobjs.name;
      fobjs = fobjs.filters;
    elseif isa(fobjs,'matrix') % in case of matrix
      fobjs = fobjs.objs;
      % check we do not have more than one object into the matrix, if this is
      % the case the problem is considered a N-dimensional filtering problem
      % that can be solved by matrix/filter
      if numel(fobjs)>1
        error(['### Filter matrix has more than one object. '...
          'This seems to be a N-dimensional filtering problem that has to be solved with matrix/filter. '...
          'Type help matrix/filter for more information ###']);
      end
      if isa(fobjs,'filterbank') % in case of filterbanks
        pl.pset('bank', fobjs.type);
        fobjs = fobjs.filters;  
      end
    end
  end
  
  
  % decide to initialize or not
  init = utils.prog.yes2true(find_core(pl, 'initialize'));
  % decide to remove group delay or not
  gdoff = utils.prog.yes2true(find_core(pl, 'gdoff'));
  
  % check inputs
  if ~isa(fobjs, 'miir') && ~isa(fobjs, 'mfir')
    error('### the filter input should be an miir/mfir object.');
  end

  if numel(bs) > 1 && nargout > 1
    error('### It is only possible to output a bank of filters when applied to a single AO.');
  end

  for jj = 1:numel(bs)

    % Copy filter so we can change it
    fobjs_copy = copy(fobjs, true);
    % keep the history to suppress the history of the intermediate steps
    inhist = bs(jj).hist;

    if isa(bs(jj).data, 'tsdata')
      %------------------------------------------------------------------------
      %------------------------   Time-series filter   ------------------------
      %------------------------------------------------------------------------
      % get input data
      if isa(fobjs_copy, 'mfir')
        % apply filter
        utils.helper.msg(msg.PROC1, 'filtering with FIR filter');
        [ydata, Zf] = filter(fobjs_copy.a, 1, bs(jj).data.y, fobjs_copy.histout);
        bs(jj).data.setY(ydata);
        % remove group delay
        if ~gdoff
          gd = floor(fobjs_copy.gd);
          bs(jj).data.setXY(bs(jj).data.getX(1:end-gd),bs(jj).data.getY(1+gd:end));
          bs(jj).data.collapseX;
        end

        % set filter output history
        fobjs_copy.setHistout(Zf);
        
        % set units of the output data as we go
        bs(jj).data.setYunits(bs(jj).data.yunits.*fobjs_copy.ounits./fobjs_copy.iunits);

      else %if isa(fobjs_copy, 'miir')
        utils.helper.msg(msg.PROC1, 'filtering with IIR filter');
        % initialise data vector
        bank = find_core(pl, 'bank');
        switch lower(bank)
          case 'parallel'
            y = zeros(size(bs(jj).data.getY));
          case 'serial'
            y = ones(size(bs(jj).data.getY));
          otherwise
            error('### Unknown filter bank option. Choose ''serial'' or ''parallel''.');
        end
        % Loop over filters
        iu = fobjs_copy(1).iunits;
        ou = fobjs_copy(1).ounits;        
        for ff = 1:numel(fobjs_copy)

          % check sample rate
          if ~utils.helper.eq2eps(bs(jj).data.fs, fobjs_copy(ff).fs)
            warning('!!! Filter is designed for a different sample rate of data. [%f ~= %f]', bs(jj).data.fs, fobjs_copy(ff).fs);
            % Adjust/redesign if this is a standard filter
            fobjs_copy(ff) = fobjs_copy(ff).redesign(bs(jj).data.fs);
          end
                    
          % Choose filtering type
          switch lower(bank)
            
            case 'parallel'
              % check units
              if ~isequal(iu, fobjs_copy(ff).iunits)
                error('### Input units of each filter must match for a parallel filter bank.');
              end
              if ~isequal(ou, fobjs_copy(ff).ounits)
                error('### Output units of each filter must match for a parallel filter bank.');
              end
              % Initialise the state to avoid transients if necessary and
              % explicitely required
              if ((~any(fobjs_copy(ff).histout) || isempty(fobjs_copy(ff).histout)) && init)
                zi = utils.math.iirinit(fobjs_copy(ff).a,fobjs_copy(ff).b);
                % setting new histout
                fobjs_copy(ff).setHistout(zi*bs(jj).data.y(1));
              end
              % filter data
              [yf, Zf] = filter(fobjs_copy(ff).a, fobjs_copy(ff).b, bs(jj).data.y, fobjs_copy(ff).histout);
              if ~isequal(size(yf),size(y))
                yf = yf.';
              end
              y = y + yf;
              
            case 'serial'
              if ff == 1
                y = bs(jj).data.y;
              end
              % Initialise the state to avoid transients if necessary
              if ~any(fobjs_copy(ff).histout) || isempty(fobjs_copy(ff).histout)
                zi = utils.math.iirinit(fobjs_copy(ff).a,fobjs_copy(ff).b);
                % setting new histout
                fobjs_copy(ff).setHistout(zi*y(1));
              end
              % filter data
              [yf, Zf] = filter(fobjs_copy(ff).a, fobjs_copy(ff).b, y, fobjs_copy(ff).histout);
              if ~isequal(size(yf),size(y))
                y = yf.';
              else
                y = yf;
              end
              % set units of the output data as we go
              bs(jj).data.setYunits(bs(jj).data.yunits.*fobjs_copy(ff).ounits./fobjs_copy(ff).iunits);
            otherwise
              error('### Unknown filter bank option. Choose ''serial'' or ''parallel''.');
          end
          % set filter output history
          fobjs_copy(ff).setHistout(Zf);
        end % End loop over filters
        
        % set output data
        bs(jj).data.setY(y);
        % clear errors
        bs(jj).clearErrors;
        
        % if this was a parallel filter bank, we should set the units now
        if strcmpi(bank, 'parallel')
          % set units of the output data
          bs(jj).data.setYunits(bs(jj).data.yunits.*fobjs_copy(1).ounits./fobjs_copy(1).iunits);
          bs(jj).data.yunits.simplify;
        end
        
      end % End filter type

    elseif isa(bs(jj).data, 'fsdata')
      %------------------------------------------------------------------------
      %----------------------   Frequency-series filter   ---------------------
      %------------------------------------------------------------------------

      utils.helper.msg(msg.PROC1, 'filtering with %s filter', upper(class(fobjs_copy)));

      % apply filter
      if numel(fobjs_copy)==1
        bs(jj) = bs(jj).*resp(fobjs_copy, plist('f', bs(jj).x));
      else
        bank = find_core(pl, 'bank');
        iu = fobjs_copy(1).iunits;
        ou = fobjs_copy(1).ounits;
        switch lower(bank)
          case 'parallel'
            sfr = resp(fobjs_copy, plist('f', bs(jj).x));
            fr = sfr(1);
            for ff = 2:numel(fobjs_copy)
              if ~isequal(iu, fobjs_copy(ff).iunits)
                error('### Input units of each filter must match for a parallel filter bank.');
              end
              if ~isequal(ou, fobjs_copy(ff).ounits)
                error('### Output units of each filter must match for a parallel filter bank.');
              end
              fr = fr + sfr(ff);
            end
            bs(jj) = bs(jj).*fr;
          case 'serial'
            sfr = resp(fobjs_copy, plist('f', bs(jj).x));
            fr = sfr(1);
            for ff = 2:numel(sfr)
              fr = fr.*sfr(ff);
            end
            bs(jj) = bs(jj).*fr;
        end
      end
      
    else
      error('### unknown data type.');
    end

    % name for this object
    if isempty(filterbankName)
      bs(jj).name = sprintf('%s(%s)', fobjs_copy.name, ao_invars{jj});
    else
      bs(jj).name = sprintf('%s(%s)', filterbankName, ao_invars{jj});
    end
    
    % Collect the filters into procinfo
    bs(jj).procinfo = plist('filter', fobjs_copy);
    % add history
    bs(jj).addHistory(getInfo('None'), pl, ao_invars(jj), [inhist fobjs_copy(:).hist]);
  end

  % Set outputs
  varargout = utils.helper.setoutputs(nargout, bs);
end

%--------------------------------------------------------------------------
% Get Info Object
%--------------------------------------------------------------------------
function ii = getInfo(varargin)
  if nargin == 1 && strcmpi(varargin{1}, 'None')
    sets = {};
    pls  = [];
  else
    sets = {'Default'};
    pls  = getDefaultPlist;
  end
  % Build info object
  ii = minfo(mfilename, mfilename('class'), 'ltpda', utils.const.categories.sigproc, '', sets, pls);
end

%--------------------------------------------------------------------------
% Get Default Plist
%--------------------------------------------------------------------------
function plout = getDefaultPlist()
  persistent pl;  
  if ~exist('pl', 'var') || isempty(pl)
    pl = buildplist();
  end
  plout = pl;  
end

function pl = buildplist()
  
  pl = plist();
  
  % Filter
  p = param({'filter', 'The filter(s) to apply to the data.'}, paramValue.EMPTY_STRING);
  pl.append(p);
  
  % GDoff
  p = param({'GDOFF', 'Switch off correction for group delay.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
  % Bank
  p = param({'bank', 'Specify what type of filter bank is being applied.'}, {1, {'parallel', 'serial'}, paramValue.SINGLE});
  pl.append(p);
  
  % Initialize
  p = param({'initialize', 'Initialize the filter to avoid startup transients.'}, paramValue.FALSE_TRUE);
  pl.append(p);
  
end

% PARAMETERS:  filter - the filter object to use to filter the data
%              bank   - For IIR filtering, specify if the bank of filters
%                       is intended to be 'serial' or 'parallel' [default]
%              initialize - true or false if you want the filter being
%                           automatically initialized or not.
