% TEST_GETINFO tests getting the method info from the method.
function res = test_getInfo(varargin)
  
  
  utp = varargin{1};
  
  utp.expectedSets = {'For bode', 'For simulate', 'For kalman', 'For cpsd', 'For resp', ...
    'For psd', 'for cpsdforindependentinputs', 'for cpsdforcorrelatedinputs'};
  
  % Default plist  
  
  pset = param({'set','Choose for which operation the ssm iois re-organized is done'},...
    {7, utp.expectedSets, paramValue.SINGLE});
  
  % Set 1: For bode
  pl1 = plist(pset);
  p = param({'inputs', 'A cell-array of input ports and blocks.'}, 'ALL' );
  pl1.append(p);
  p = param({'outputs', 'A cell-array of output ports and blocks.'}, 'ALL' );
  pl1.append(p);
  p = param({'states', 'A cell-array of states ports and blocks.'}, 'NONE' );
  pl1.append(p);
        
  % Set 2: For simulate
  pl2 = plist(pset);  
  p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl2.append(p);
  p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl2.append(p);
  p = param({'aos variable names', 'A cell-array of input port names corresponding to the different input AOs.'}, paramValue.EMPTY_CELL);
  pl2.append(p);
  p = param({'constant variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl2.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl2.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl2.append(p);
  
  % Set 3: 'for kalman'
  pl3 = plist(pset);  
  p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl3.append(p);
  p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl3.append(p);
  p = param({'aos variable names', 'A cell-array of input port names corresponding to the different input AOs.'}, paramValue.EMPTY_CELL);
  pl3.append(p);
  p = param({'constant variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl3.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl3.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl3.append(p);
  p = param({'known output variable names', 'A cell-array of strings of the known output variable names.'}, paramValue.EMPTY_CELL);
  pl3.append(p);
  
  % Set 4: 'for cpsd'
  pl4 = plist(pset);
  p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl4.append(p);
  p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl4.append(p);
  p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl4.append(p);
  p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
  pl4.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl4.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl4.append(p);
  
  % Set 5: 'for resp'
  pl5 = plist(pset);
  p = param({'inputs', 'A cell-array of input ports and blocks.'}, 'ALL' );
  pl5.append(p);
  p = param({'outputs', 'A cell-array of output ports and blocks.'}, 'ALL' );
  pl5.append(p);
  p = param({'states', 'A cell-array of states ports and blocks.'}, 'NONE' );
  pl5.append(p);
    
  % Set 6: 'for psd'
  pl6 = plist(pset);
  p = param({'variance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl6.append(p);
  p = param({'PSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl6.append(p);
  p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl6.append(p);
  p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
  pl6.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl6.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl6.append(p);
  
  % Set 7: 'for cpsdforindependentinputs'
  pl7 = plist(pset);
  p = param({'variance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl7.append(p);
  p = param({'PSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl7.append(p);
  p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl7.append(p);
  p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
  pl7.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl7.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl7.append(p);
  
  % Set 8: 'for cpsdforcorrelatedinputs'
  pl8 = plist(pset);
  p = param({'covariance variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl8.append(p);
  p = param({'CPSD variable names', 'A cell-array of strings specifying the desired input variable names.'}, paramValue.EMPTY_CELL );
  pl8.append(p);
  p = param({'PZmodel variable names', 'A cell-array of strings of the desired input variable names.'}, paramValue.EMPTY_CELL);
  pl8.append(p);
  p = param({'aos variable names', 'A cell-array of input defined with AOs spectrums.'}, paramValue.EMPTY_CELL);
  pl8.append(p);
  p = param({'return states', 'A cell-array of names of state ports to return.'}, paramValue.EMPTY_CELL);
  pl8.append(p);
  p = param({'return outputs', 'A cell-array of output ports to return.'}, paramValue.EMPTY_CELL);
  pl8.append(p);

  % Set 
  
  utp.expectedPlists = [pl1 pl2 pl3 pl4 pl5 pl6 pl7 pl8];  
  
  % Call super class 
  res = test_getInfo@ltpda_uoh_method_tests(varargin{:});
end
% END