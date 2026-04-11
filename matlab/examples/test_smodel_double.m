% test_smodel_double tests the double method of the SMODEL class.
%
% M Hueller 02-05-2011
%
% $Id$
%
function results = test_smodel_double(varargin)
  
  %% List of runs
  if nargin == 1
    list = varargin{1};
    if isa(list, 'cell')
      list = list{:};
    end
  else
    list = [];
  end
  
  if isempty(list)
    list = [10 11 20 21 30 31 40 41 50 51];
  end
  
  %% Run tests
  results = [];
  
  %% 10 Oscillator step, default values
  test = 10;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'oscillator_step';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 100;
    fs    = 1;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    F0     = find(pl, 'F0');
    toff   = find(pl, 'toff');
    m      = find(pl, 'm');
    k      = find(pl, 'k');
    tau    = find(pl, 'tau');
    x0     = find(pl, 'x0');
    v0     = find(pl, 'v0');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'m','k','tau','F0','x0','v0','toff'}, {m,k,tau,F0,x0,v0,toff});
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tolerance', TOL))];
  end
  
  %% 11 Oscillator step, high fs and high nsecs
  test = 11;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'oscillator_step';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 10000;
    fs    = 1000;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    F0     = find(pl, 'F0');
    toff   = find(pl, 'toff');
    m      = find(pl, 'm');
    k      = find(pl, 'k');
    tau    = find(pl, 'tau');
    x0     = find(pl, 'x0');
    v0     = find(pl, 'v0');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'m','k','tau','F0','x0','v0','toff'}, {m,k,tau,F0,x0,v0,toff});
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tolerance', TOL))];
  end
  
  %% 20 Oscillator sine, default values
  test = 20;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'oscillator_sine';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 1e-14;
    
    % Set parameters: duration and rate
    nsecs = 100;
    fs    = 1;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    F0     = find(pl, 'F0');
    toff   = find(pl, 'toff');
    phi    = find(pl, 'phi');
    phi = 0.0;
    f      = find(pl, 'f');
    m      = find(pl, 'm');
    k      = find(pl, 'k');
    tau    = find(pl, 'tau');
    x0     = find(pl, 'x0');
    x0 = 0.0;
    v0     = find(pl, 'v0');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs, 'x0', x0, 'phi', phi));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'m','k','tau','F0','f','phi','x0','v0','toff'}, {m,k,tau,F0,f,phi,x0,v0,toff});
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 21 Oscillator sine, high fs and high nsecs
  test = 21;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'oscillator_sine';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 1e-12;
    
    % Set parameters: duration and rate
    nsecs = 10000;
    fs    = 1000;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    F0     = find(pl, 'F0');
    toff   = find(pl, 'toff');
    phi    = find(pl, 'phi');
    f      = find(pl, 'f');
    m      = find(pl, 'm');
    k      = find(pl, 'k');
    tau    = find(pl, 'tau');
    x0     = find(pl, 'x0');
    v0     = find(pl, 'v0');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'m','k','tau','F0','f','phi','x0','v0','toff'}, {m,k,tau,F0,f,phi,x0,v0,toff});
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 30 Sinewave, default values
  test = 30;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'sinewave';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 100;
    fs    = 1;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    A      = find(pl, 'A');
    phi    = find(pl, 'phi');
    f      = find(pl, 'f');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'A','f','phi'}, {A,f,phi});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 31 Sinewave, high fs and high nsecs
  test = 31;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'sinewave';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 10000;
    fs    = 1000;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    A      = find(pl, 'A');
    phi    = find(pl, 'phi');
    f      = find(pl, 'f');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'A','f','phi'}, {A,f,phi});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 40 Squarewave, default values
  test = 40;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'squarewave';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 100;
    fs    = 1;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    phi    = find(pl, 'phi');
    f      = find(pl, 'f');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'f','phi'}, {f,phi});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 41 Squarewave, high fs and high nsecs
  test = 41;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'squarewave';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 10000;
    fs    = 1000;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    phi    = find(pl, 'phi');
    f      = find(pl, 'f');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'f','phi'}, {f,phi});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 50 Step, default values
  test = 50;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'step';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 100;
    fs    = 1;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    A    = find(pl, 'A');
    toff = find(pl, 'toff');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'A','toff'}, {A,toff});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
  %% 51 Step, high fs and high nsecs
  test = 51;
  if any(ismember(list, test))
    
    % Pick the model
    model_def = 'step';
    
    % Decide the tolerance of the test ([] or 0 for no tolerance)
    TOL = 0;
    
    % Set parameters: duration and rate
    nsecs = 10000;
    fs    = 1000;
    
    % Extract the information from the ao model default plist
    ao_mdl_info = eval(['ao_model_' model_def '(''info'')']);
    pl = ao_mdl_info.plists;
    
    A    = find(pl, 'A');
    toff = find(pl, 'toff');
    
    % Build the ao model
    ao_mdl = ao(plist('built-in', model_def, 'nsecs', nsecs, 'fs', fs));
    
    % Build the smodel model
    smodel_mdl = smodel(plist('built-in', model_def));
    
    % Set smodel parameters
    smodel_mdl.setParameters({'A','toff'}, {A,toff});
    
    % Set smodel yunits
    smodel_mdl.setYunits(ao_mdl.yunits);
    
    % Set smodel xvals
    smodel_mdl.setXvals(ao_mdl.x);
    
    % Eval the smodel
    d = smodel_mdl.double();
    
    % Compare the numbers
    results = [results; test check_correctness(d, ao_mdl.y, plist('tol', TOL))];
  end
  
end

function atest = check_correctness(smodel_y, ao_y, pl)
  
  % Exceptions plist for ao/isequal
  ple = plist('Exceptions', ...
    {'created', 'proctime', 'UUID', 'param/desc', 'name', 'methodInvars', 'version'});
  
  % Start testing
  atest = true;
  
  % Strict check or with tolerance?
  tol = mfind(pl, 'tolerance', 'tol');
  if ~isempty(tol) && tol > 0
    % Check within tolerance
    if any(abs(smodel_y - ao_y) ./ max(abs(smodel_y)) >= tol)
      atest = false;
    end
  else
    % Strict check on the values
    if ~isequal(smodel_y, ao_y)
      atest = false;
    end
  end
  
end
