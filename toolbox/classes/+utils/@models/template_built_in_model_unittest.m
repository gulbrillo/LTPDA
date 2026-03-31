% test_<CLASS>_model_<NAME> - Returns a TestSuite with the test plan of the built-in model <NAME>.
function ts = test_<CLASS>_model_<NAME>(utc, varargin)
  ts = utc.getBaselineTestSuite(mfilename);
  ts.configPlist = plist('My Parameter', 'PLIST for the common tests.');
  
  % Add some additional test
  ts.appendTestFromSubFcn(@check_a_local_function)
  
end

function r = check_a_local_function(utc, ts, varargin)
  % check_a_local_function: Checks that ... This is a description which goes into the result object of a test run.
  
  % Invikes the model with the PLIST you have defined in the main function.
  objOut = ts.runModel();
  
  % Invokes the model with the new parameter list.
  objOut = ts.runModel(plist('my', 'own PLIST'));
  
  assert(false, 'This assert failes because nobody has updated the test.');
  
  r = 'Checked that ... This masseg also goes into the result object of a test run.';
end
