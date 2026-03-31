% Override getInfo test which is failing
%

function res = test_getInfo(varargin)
  
  utp = varargin{1};
  
  utp.expectedSets = {'Default','Mean','Line','Constrained Gaussian'};
  
  % Create empty plsit
  pl_common = plist();
  
  % Indices
  p = param(...
    {'Indices', ['List of start/stop index pairs for data to be subsituted'...
    ' (Nx2). Can either be an array of doubles or a cdata ao']},...
    paramValue.EMPTY_DOUBLE...
    );
  pl_common.append(p);
  
  % Mode
  p = param(...
    {'Mode',['Method to use for calculating replacement data.<ul>'...
    '<li>Constant - Replace with constant value</li>', ...
    '<li>Mean - Replace with average of interval edges</li>', ...
    '<li>Line - Replace with straight line between interval edges</li>', ...
    '<li>Constrained Gaussian - Replace with random data obeying statistics specified in IACF</li></ul>']},...
    {1, {'Constant', 'Mean', 'Line', 'Constrained Gaussian'}, paramValue.SINGLE});
  pl_common.append(p);
  
  %-------- For Default
  % values
  pl_values = param(...
        {'Value', ['Value(s) to fill specified intervals. Can be a scalar or Nx1 array of doubles or ao [where y values will be taken]']},...
        paramValue.DOUBLE_VALUE(0)...
        );
  pl_values.addAlternativeKey('Values');
  
  pl(1) = pl_common.append(pl_values);
  
  %-------- For Mean
  pl(2) = copy(pl_common,1);
  
  %-------- For Line
  pl(3) = copy(pl_common,1);
  
  %-------- For Constrained Gaussian
  pl(4) = copy(pl_common,1);
  % Detrending Order (use factory)
  pl(4).append(plist.WELCH_PLIST.subset('order'));
  
  % Seed
  p = param(...
    {'Seed', ['Value(s) to fill specified intervals. Can be a scalar or Nx1 array of doubles or ao [where y values will be taken]']},...
    paramValue.EMPTY_DOUBLE...
    );
  pl(4).append(p);
  
  % Inverse auto-correlation function
  p = param(...
    {'IACF', ['Inverse Auto-Correlation Function (IACF) for filling gaps. Can be array of doubles of xydata ao.']},...
    paramValue.EMPTY_DOUBLE...
    );
  pl(4).append(p);
  
  
  utp.expectedPlists = pl;
  
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
  
  
  
end


