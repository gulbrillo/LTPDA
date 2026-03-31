function dx_dt = free_flight_ode(t,x_comp,p,varargin)

    
   % we cannot look up the parameter each time because it takes too long 
   % tm_params = plist(plist('built-in','tm_parameters'));
   % m = tm_params.find('EOM_TM2_M');
    
   % x_comp denotes the x component of the r vector
   % x denotes the parameter Omega_x = x(1) and c_x = x(2) to be estimated
   
   % remember: the third fit parameter is the initial velocity which
   % doesn't appear as a parameter
   % cross_o1_o12 = x(4)
                                                                                                                                                    
   
   % collect all doubles = (data from corss-coupling time series)
   numericInputs = {};
   for ii = 1:numel(varargin)
     if isnumeric(varargin{ii})
       numericInputs{end+1} = varargin{ii};
     end
   end
   f_values = numericInputs{1};
   data = numericInputs{2};
   
   % [d] = utils.helper.collect_objects(varargin(:), 'double');
   % collect all chars = (expression to be evaluated)
   cmd = utils.helper.collect_objects(varargin(:), 'char');
   %  collect all strings = 
   %  names of all the cross-coupling paramters so that they can be used
   %  when evaluating the ode
   s = utils.helper.collect_objects(varargin(:), 'cell');
   
   % we start with 2 because first column is the x1 data we don't need
   for ii=2:size(data,2)
     
     dummyVals = interp1(f_values,data(:,ii),t,'spline');
     tmp = sprintf('%s = dummyVals;', s{ii});
     eval(tmp);
   end  
    
   dx_dt = zeros(2,1); % a column vector (column is mandatory)
    
   dx_dt(1) = x_comp(2);
    

   %dx_dt(2) = (1/1.96)*(x(2))+x(1)^2*x_comp(1)+x(4)*eta1+x(5)*phi1+x(6)*eta2+x(7)*phi2;
   dx_dt(2) = eval(cmd);  
    

end