% LTPDA Toolbox
% Version 3.0.13 (R2017a) 04-08-17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Toolbox        LTPDA
%
% Version        3.0.13 (R2017a) 04-08-17
%
% Contents path  /Users/hewitson/matlab/ltpda_toolbox/ltpda_toolbox/ltpda
%
%
%%%%%%%%%%%%%%%%%%%%   path:    %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help MakeContents">MakeContents</a> -  makes Contents file in current working directory and subdirectories
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+const/@categories   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+const/@categories/categories">classes/+utils/+const/@categories/categories</a> -  class that defines LTPDA method categories.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+const/@ltp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+const/@ltp/ltp">classes/+utils/+const/@ltp/ltp</a> -  class that defines constants for LTP.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+const/@msg   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+const/@msg/msg">classes/+utils/+const/@msg/msg</a> -  class that defines constants for different message levels.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+const/@physics   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+const/@physics/physics">classes/+utils/+const/@physics/physics</a> -  class that defines common physical constants.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+const/@warnings   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+const/@warnings/warnings">classes/+utils/+const/@warnings/warnings</a> -  class that defines different warning labels.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+gui/@BaseGUI   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+gui/@BaseGUI/BaseGUI">classes/+utils/+gui/@BaseGUI/BaseGUI</a>      -  is a base class for graphical user interface in LTPDA.
%   <a href="matlab:help classes/+utils/+gui/@BaseGUI/cb_guiClosed">classes/+utils/+gui/@BaseGUI/cb_guiClosed</a> -  callback for closing the BaseGUI class
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+gui/@QueryResultsTable   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+gui/@QueryResultsTable/QueryResultsTable">classes/+utils/+gui/@QueryResultsTable/QueryResultsTable</a>           -  is a graphical user interface for query the LTPDA repository.
%   <a href="matlab:help classes/+utils/+gui/@QueryResultsTable/cb_guiClosed">classes/+utils/+gui/@QueryResultsTable/cb_guiClosed</a>                -  callback for closing the QueryResultsTable GUI
%   <a href="matlab:help classes/+utils/+gui/@QueryResultsTable/cb_retrieveObjectsFromTable">classes/+utils/+gui/@QueryResultsTable/cb_retrieveObjectsFromTable</a> -  callback for retrieving objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/+gui/@RepositoryRetrieve   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/+gui/@RepositoryRetrieve/RepositoryRetrieve">classes/+utils/+gui/@RepositoryRetrieve/RepositoryRetrieve</a> -  is a graphical user interface for query the LTPDA repository.
%   <a href="matlab:help classes/+utils/+gui/@RepositoryRetrieve/cb_guiClosed">classes/+utils/+gui/@RepositoryRetrieve/cb_guiClosed</a>       -  callback for closing the QueryResultsTable GUI
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@autoReporter   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@autoReporter/autoReporter">classes/+utils/@autoReporter/autoReporter</a> -  class, for reporting automatization.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@bin   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@bin/bin">classes/+utils/@bin/bin</a> -  class for wrapping of executable binary files.
%   <a href="matlab:help classes/+utils/@bin/fil">classes/+utils/@bin/fil</a> -  a wrapper for the LISO fil executable.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@credentials   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@credentials/credentials">classes/+utils/@credentials/credentials</a> - end % properties
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@helper   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@helper/CPUbenchmark">classes/+utils/@helper/CPUbenchmark</a>                  - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@helper/addLicenseToFile">classes/+utils/@helper/addLicenseToFile</a>              - fprintf(2, 'No rule for extension: [%s]', ext);
%   <a href="matlab:help classes/+utils/@helper/buildSearchDatabase">classes/+utils/@helper/buildSearchDatabase</a>           -  Build LTPDA documentation search database.
%   <a href="matlab:help classes/+utils/@helper/callerIsMethod">classes/+utils/@helper/callerIsMethod</a>                - CALLERISMETHOD(varargin) checks if a method was called by another LTPDA method.
%   <a href="matlab:help classes/+utils/@helper/checkFilterOptions">classes/+utils/@helper/checkFilterOptions</a>            -  checks the options to the different filter
%   <a href="matlab:help classes/+utils/@helper/checkMatlabVersion">classes/+utils/@helper/checkMatlabVersion</a>            -  checks the current MATLAB version.
%   <a href="matlab:help classes/+utils/@helper/class2plist">classes/+utils/@helper/class2plist</a>                   -  create a plist from the class properties.
%   <a href="matlab:help classes/+utils/@helper/classFromStruct">classes/+utils/@helper/classFromStruct</a>               -  returns a class name that matches the structure.
%   <a href="matlab:help classes/+utils/@helper/collect_objects">classes/+utils/@helper/collect_objects</a>               -  Collect objects of the required class.
%   <a href="matlab:help classes/+utils/@helper/collect_values">classes/+utils/@helper/collect_values</a>                -  convert numeric values in to AOs.
%   <a href="matlab:help classes/+utils/@helper/createUniqueNames">classes/+utils/@helper/createUniqueNames</a>             -  This function make sure that the input cell contains only unique strings.
%   <a href="matlab:help classes/+utils/@helper/displayConstructorExamples">classes/+utils/@helper/displayConstructorExamples</a>    - % Get the class which we want to display from the input
%   <a href="matlab:help classes/+utils/@helper/displayMethodInfo">classes/+utils/@helper/displayMethodInfo</a>             -  displays the information about a method in the MATLAB browser.
%   <a href="matlab:help classes/+utils/@helper/dunzip">classes/+utils/@helper/dunzip</a>                        -  - decompress DZIP output to recover original data
%   <a href="matlab:help classes/+utils/@helper/dzip">classes/+utils/@helper/dzip</a>                          -  - losslessly compress data into smaller memory space
%   <a href="matlab:help classes/+utils/@helper/eq2eps">classes/+utils/@helper/eq2eps</a>                        -  returns True if the two values are equal to within 2*eps of the
%   <a href="matlab:help classes/+utils/@helper/err">classes/+utils/@helper/err</a>                           -  prints the error message to the MATLAB terminal and to the
%   <a href="matlab:help classes/+utils/@helper/errorDlg">classes/+utils/@helper/errorDlg</a>                      -  Create and open error dialog box.
%   <a href="matlab:help classes/+utils/@helper/extractTransitionTimes">classes/+utils/@helper/extractTransitionTimes</a>        - UTILS.HELPER.EXTRACTTRANSITIONTIMES
%   <a href="matlab:help classes/+utils/@helper/feval">classes/+utils/@helper/feval</a>                         -  a wrapper of MATLAB's feval
%   <a href="matlab:help classes/+utils/@helper/generic_getInfo">classes/+utils/@helper/generic_getInfo</a>               -  generic version of the getInfo function
%   <a href="matlab:help classes/+utils/@helper/genvarname">classes/+utils/@helper/genvarname</a>                    -  is a wrapper for the different MATLAB versions.
%   <a href="matlab:help classes/+utils/@helper/getClassFromStruct">classes/+utils/@helper/getClassFromStruct</a>            - pubCnames = {p(idxPub).Name}; % public and not hidden properties. (same as properties(cl))
%   <a href="matlab:help classes/+utils/@helper/getClasses">classes/+utils/@helper/getClasses</a>                    -  lists all the LTPDA object types.
%   <a href="matlab:help classes/+utils/@helper/getDefaultValue">classes/+utils/@helper/getDefaultValue</a>               -  Returns the default value of a class property.
%   <a href="matlab:help classes/+utils/@helper/getHelpPath">classes/+utils/@helper/getHelpPath</a>                   -  return the full path of the LTPDA toolbox help
%   <a href="matlab:help classes/+utils/@helper/getObjectFromStruct">classes/+utils/@helper/getObjectFromStruct</a>           - % Call constructor of the data class
%   <a href="matlab:help classes/+utils/@helper/getPublicMethods">classes/+utils/@helper/getPublicMethods</a>              -  returns a cell array of the public methods for the given
%   <a href="matlab:help classes/+utils/@helper/getUserClasses">classes/+utils/@helper/getUserClasses</a>                -  lists all the LTPDA user object types.
%   <a href="matlab:help classes/+utils/@helper/helper">classes/+utils/@helper/helper</a>                        -  helper class for helpful utility functions.
%   <a href="matlab:help classes/+utils/@helper/isSubclassOf">classes/+utils/@helper/isSubclassOf</a>                  -  determines if the one class is a subclass of another
%   <a href="matlab:help classes/+utils/@helper/isSubmissionPlist">classes/+utils/@helper/isSubmissionPlist</a>             -  Checks if the input plist is a submission plist.
%   <a href="matlab:help classes/+utils/@helper/isdeprecated">classes/+utils/@helper/isdeprecated</a>                  -  attempts to determine if a given method of a class is
%   <a href="matlab:help classes/+utils/@helper/isinfocall">classes/+utils/@helper/isinfocall</a>                    -  defines the condition for an 'info' call
%   <a href="matlab:help classes/+utils/@helper/ismember">classes/+utils/@helper/ismember</a>                      -  a simpler version that just checks if the given string(s) is/are in the
%   <a href="matlab:help classes/+utils/@helper/isobject">classes/+utils/@helper/isobject</a>                      -  checks that the input objects are one of the LTPDA object types.
%   <a href="matlab:help classes/+utils/@helper/jArrayList2CellArray">classes/+utils/@helper/jArrayList2CellArray</a>          -  Converts a java ArrayList into a MATLAB cell array.
%   <a href="matlab:help classes/+utils/@helper/ltpda_classes">classes/+utils/@helper/ltpda_classes</a>                 -  lists all the LTPDA object types.
%   <a href="matlab:help classes/+utils/@helper/ltpda_non_abstract_classes">classes/+utils/@helper/ltpda_non_abstract_classes</a>    -  lists all non abstract LTPDA object classes.
%   <a href="matlab:help classes/+utils/@helper/ltpda_userclasses">classes/+utils/@helper/ltpda_userclasses</a>             -  lists all the LTPDA user object types.
%   <a href="matlab:help classes/+utils/@helper/make_class_diagram">classes/+utils/@helper/make_class_diagram</a>            -  script to plot nicely the class structure of the LTPDA Toolbox,
%   <a href="matlab:help classes/+utils/@helper/mat2str">classes/+utils/@helper/mat2str</a>                       -  overloads the mat2str operator to set the precision at a central place.
%   <a href="matlab:help classes/+utils/@helper/msg">classes/+utils/@helper/msg</a>                           -  writes a message to the MATLAB terminal.
%   <a href="matlab:help classes/+utils/@helper/msg_nnl">classes/+utils/@helper/msg_nnl</a>                       -  writes a message to the MATLAB terminal without a new line character
%   <a href="matlab:help classes/+utils/@helper/num2str">classes/+utils/@helper/num2str</a>                       -  uses sprintf to convert a data vector to a string with a fixed precision.
%   <a href="matlab:help classes/+utils/@helper/obj2tex">classes/+utils/@helper/obj2tex</a>                       -  converts the input data to TeX code
%   <a href="matlab:help classes/+utils/@helper/objdisp">classes/+utils/@helper/objdisp</a>                       -  displays the input object.
%   <a href="matlab:help classes/+utils/@helper/parseMethodInfo">classes/+utils/@helper/parseMethodInfo</a>               -  parses the standard function information.
%   <a href="matlab:help classes/+utils/@helper/plotTraces">classes/+utils/@helper/plotTraces</a>                    - (No help available)
%   <a href="matlab:help classes/+utils/@helper/plot_gauss_hist">classes/+utils/@helper/plot_gauss_hist</a>               - % Check if this is a call for parameters
%   <a href="matlab:help classes/+utils/@helper/process_smodel_diff_options">classes/+utils/@helper/process_smodel_diff_options</a>   -  checks the options for the parameters needed by smodel methods like diff
%   <a href="matlab:help classes/+utils/@helper/process_smodel_transf_options">classes/+utils/@helper/process_smodel_transf_options</a> -  checks the options for the parameters needed by smodel methods like transforms
%   <a href="matlab:help classes/+utils/@helper/process_spectral_options">classes/+utils/@helper/process_spectral_options</a>      -  checks the options for the parameters needed by spectral estimators, recalculating  and/or resetting them if needed.
%   <a href="matlab:help classes/+utils/@helper/readGZip">classes/+utils/@helper/readGZip</a>                      - Reads a GZip file in full and puts the contents into the output variable.
%   <a href="matlab:help classes/+utils/@helper/remove_cvs_from_matlabpath">classes/+utils/@helper/remove_cvs_from_matlabpath</a>    - newpath = remove_cvs_from_matlabpath(oldpath)
%   <a href="matlab:help classes/+utils/@helper/remove_git_from_matlabpath">classes/+utils/@helper/remove_git_from_matlabpath</a>    - newpath = remove_git_from_matlabpath(oldpath)
%   <a href="matlab:help classes/+utils/@helper/remove_svn_from_matlabpath">classes/+utils/@helper/remove_svn_from_matlabpath</a>    - newpath = remove_svn_from_matlabpath(oldpath)
%   <a href="matlab:help classes/+utils/@helper/saveobj">classes/+utils/@helper/saveobj</a>                       -  saves an object to a file.
%   <a href="matlab:help classes/+utils/@helper/setoutputs">classes/+utils/@helper/setoutputs</a>                    -  sets the output cell-array for LTPDA methods.
%   <a href="matlab:help classes/+utils/@helper/time_data_worsener">classes/+utils/@helper/time_data_worsener</a>            -  introduces missing points and/or unvenly sampling time
%   <a href="matlab:help classes/+utils/@helper/truncateString">classes/+utils/@helper/truncateString</a>                -  truncates a string or cell-array of strings to a given number of characters.
%   <a href="matlab:help classes/+utils/@helper/val2str">classes/+utils/@helper/val2str</a>                       -  converts each value into a string
%   <a href="matlab:help classes/+utils/@helper/ver2num">classes/+utils/@helper/ver2num</a>                       -  converts a version string into a number.
%   <a href="matlab:help classes/+utils/@helper/warn">classes/+utils/@helper/warn</a>                          -  - prints the warning message to the MATLAB terminal.
%   <a href="matlab:help classes/+utils/@helper/warnDlg">classes/+utils/@helper/warnDlg</a>                       -  Create and open warn dialog box.
%   <a href="matlab:help classes/+utils/@helper/warn_no_bt">classes/+utils/@helper/warn_no_bt</a>                    -  - prints the warning message to the MATLAB terminal without backtrace informations.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@html   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@html/beginBody">classes/+utils/@html/beginBody</a>     -   returns an html string to start the body of the document.
%   <a href="matlab:help classes/+utils/@html/beginItemize">classes/+utils/@html/beginItemize</a>  -   returns an html string  to start a items list in HTML
%   <a href="matlab:help classes/+utils/@html/bold">classes/+utils/@html/bold</a>          -   returns an html string rep  
%   <a href="matlab:help classes/+utils/@html/center">classes/+utils/@html/center</a>        -   returns an html string to center the given text 
%   <a href="matlab:help classes/+utils/@html/color">classes/+utils/@html/color</a>         -   returns an html string that represents given text with given font color  
%   <a href="matlab:help classes/+utils/@html/comment">classes/+utils/@html/comment</a>       -   returns an html string representing a hidden comment   
%   <a href="matlab:help classes/+utils/@html/endBody">classes/+utils/@html/endBody</a>       -   returns an html string to end the body of the document.
%   <a href="matlab:help classes/+utils/@html/endItemize">classes/+utils/@html/endItemize</a>    - ENDINITEMIZE  returns an html string  to end an items list in HTML
%   <a href="matlab:help classes/+utils/@html/figure">classes/+utils/@html/figure</a>        -   returns an html string  to embed an image  to a HTML document
%   <a href="matlab:help classes/+utils/@html/html">classes/+utils/@html/html</a>          -  helper class for helpful utility functions.
%   <a href="matlab:help classes/+utils/@html/item">classes/+utils/@html/item</a>          -   returns an html string  add an enumeration item with given text, in HTML
%   <a href="matlab:help classes/+utils/@html/label">classes/+utils/@html/label</a>         -   returns an html string  to add a location label in a HTML document
%   <a href="matlab:help classes/+utils/@html/lineBreak">classes/+utils/@html/lineBreak</a>     -   returns an html string with a line break 
%   <a href="matlab:help classes/+utils/@html/lineSeparator">classes/+utils/@html/lineSeparator</a> -  returns an html string representing a vertical line 
%   <a href="matlab:help classes/+utils/@html/link">classes/+utils/@html/link</a>          -   returns an html string that is a link to a given URL, in html.
%   <a href="matlab:help classes/+utils/@html/pageFooter">classes/+utils/@html/pageFooter</a>    -  returns an html string suitable for ending an html page.
%   <a href="matlab:help classes/+utils/@html/pageHeader">classes/+utils/@html/pageHeader</a>    -   returns an html string suitable for starting an html page.
%   <a href="matlab:help classes/+utils/@html/paragraph">classes/+utils/@html/paragraph</a>     -   returns an html string  to add a paragrapgh to a HTML document
%   <a href="matlab:help classes/+utils/@html/reference">classes/+utils/@html/reference</a>     -   returns an html string that is a link to a previously set
%   <a href="matlab:help classes/+utils/@html/table">classes/+utils/@html/table</a>         -  returns an html string containing a table of the given quantities.
%   <a href="matlab:help classes/+utils/@html/title">classes/+utils/@html/title</a>         -   returns an html string that is a title with given level
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@jmysql   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@jmysql/getsinfo">classes/+utils/@jmysql/getsinfo</a> -   Retrieved objects metadata from the repository
%   <a href="matlab:help classes/+utils/@jmysql/jmysql">classes/+utils/@jmysql/jmysql</a>   - UTILS.JMYSQL  Interface to MySQL databases
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@math   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@math/Chi2cdf">classes/+utils/@math/Chi2cdf</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Chi2inv">classes/+utils/@math/Chi2inv</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Fcdf">classes/+utils/@math/Fcdf</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Finv">classes/+utils/@math/Finv</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Fpdf">classes/+utils/@math/Fpdf</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Ftest">classes/+utils/@math/Ftest</a>                        -  perfomes an F-Test.
%   <a href="matlab:help classes/+utils/@math/Kurt">classes/+utils/@math/Kurt</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Normcdf">classes/+utils/@math/Normcdf</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Norminv">classes/+utils/@math/Norminv</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Rcovmat">classes/+utils/@math/Rcovmat</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/SFtest">classes/+utils/@math/SFtest</a>                       -  perfomes a Spectral F-Test on PSDs.
%   <a href="matlab:help classes/+utils/@math/SKcriticalvalues">classes/+utils/@math/SKcriticalvalues</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/Skew">classes/+utils/@math/Skew</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/autocfit">classes/+utils/@math/autocfit</a>                     -  performs a fitting loop to identify model order and parameters.
%   <a href="matlab:help classes/+utils/@math/autodfit">classes/+utils/@math/autodfit</a>                     -  perform a fitting loop to identify model order and parameters.
%   <a href="matlab:help classes/+utils/@math/blwhitenoise">classes/+utils/@math/blwhitenoise</a>                 -  return a band limited gaussian distributed white noise
%   <a href="matlab:help classes/+utils/@math/boxplot">classes/+utils/@math/boxplot</a>                      -  draw box plot on data
%   <a href="matlab:help classes/+utils/@math/cauchy">classes/+utils/@math/cauchy</a>                       - (No help available)
%   <a href="matlab:help classes/+utils/@math/cdfplot">classes/+utils/@math/cdfplot</a>                      -  makes cumulative distribution plot
%   <a href="matlab:help classes/+utils/@math/chi2">classes/+utils/@math/chi2</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/chisquare_ssm_td">classes/+utils/@math/chisquare_ssm_td</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/chop">classes/+utils/@math/chop</a>                         - (No help available)
%   <a href="matlab:help classes/+utils/@math/computeDftPeriodogram">classes/+utils/@math/computeDftPeriodogram</a>        -  compute periodogram with dft
%   <a href="matlab:help classes/+utils/@math/computepsd">classes/+utils/@math/computepsd</a>                   - Slight modification of original MATLAB's computepsd to include correct scaling for the variance, i.e var(a*x) = a^2*var(x)
%   <a href="matlab:help classes/+utils/@math/corr2cov">classes/+utils/@math/corr2cov</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/cov2corr">classes/+utils/@math/cov2corr</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/cpf">classes/+utils/@math/cpf</a>                          -  finds the partial fraction expansion of the ratio of two polynomials A(s)/B(s).
%   <a href="matlab:help classes/+utils/@math/cpsd">classes/+utils/@math/cpsd</a>                         - UTILS.MATH.CPSD: Pure Matlab function that performs the CPSD using LTPDA machinery
%   <a href="matlab:help classes/+utils/@math/crank">classes/+utils/@math/crank</a>                        -  calculate ranks for Spearman correlation
%   <a href="matlab:help classes/+utils/@math/csd2tf">classes/+utils/@math/csd2tf</a>                       -  Input cross spectral density matrix and output stable transfer function 
%   <a href="matlab:help classes/+utils/@math/csd2tf2">classes/+utils/@math/csd2tf2</a>                      -  Input cross spectral density matrix and output stable transfer function 
%   <a href="matlab:help classes/+utils/@math/ctfit">classes/+utils/@math/ctfit</a>                        -  fits a continuous model to a frequency response.
%   <a href="matlab:help classes/+utils/@math/ctmult">classes/+utils/@math/ctmult</a>                       - % Multiplication function designed for the
%   <a href="matlab:help classes/+utils/@math/deg2rad">classes/+utils/@math/deg2rad</a>                      -  Convert degrees to radians
%   <a href="matlab:help classes/+utils/@math/dft">classes/+utils/@math/dft</a>                          -  Compute discrete fourier transform at a given frequency
%   <a href="matlab:help classes/+utils/@math/diffStepFish">classes/+utils/@math/diffStepFish</a>                 - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/diffStepFish_1x1">classes/+utils/@math/diffStepFish_1x1</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/dispersion_1x1">classes/+utils/@math/dispersion_1x1</a>               - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/dispersion_2x2">classes/+utils/@math/dispersion_2x2</a>               - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/downsampleSpectrum">classes/+utils/@math/downsampleSpectrum</a>           -  spectrum in order to ensure independence between frequency
%   <a href="matlab:help classes/+utils/@math/drawSampleM">classes/+utils/@math/drawSampleM</a>                  - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/drawSampleT">classes/+utils/@math/drawSampleT</a>                  -   Draw a sample from the Student's t distribution
%   <a href="matlab:help classes/+utils/@math/dtfit">classes/+utils/@math/dtfit</a>                        -  fits a discrete model to a frequency response.
%   <a href="matlab:help classes/+utils/@math/ecdf">classes/+utils/@math/ecdf</a>                         -  Compute empirical cumulative distribution function
%   <a href="matlab:help classes/+utils/@math/eigcsd">classes/+utils/@math/eigcsd</a>                       -  calculates TFs from 2D cross-correlated spectra.
%   <a href="matlab:help classes/+utils/@math/eigpsd">classes/+utils/@math/eigpsd</a>                       -  calculates TFs from 2D cross-correlated spectra.
%   <a href="matlab:help classes/+utils/@math/fdfilt_delay_core">classes/+utils/@math/fdfilt_delay_core</a>            -  core method to implement fractional delay filtering
%   <a href="matlab:help classes/+utils/@math/fftdelay_core">classes/+utils/@math/fftdelay_core</a>                -  applies a delay to a timeseries using the FFT/IFFT method
%   <a href="matlab:help classes/+utils/@math/filtfilt_filterbank">classes/+utils/@math/filtfilt_filterbank</a>          -  computes filtfilt for filterbank objects
%   <a href="matlab:help classes/+utils/@math/filtpz">classes/+utils/@math/filtpz</a>                       - (No help available)
%   <a href="matlab:help classes/+utils/@math/findShapeParamKStestSpectrum">classes/+utils/@math/findShapeParamKStestSpectrum</a> -  find shape parameter for kstest on the
%   <a href="matlab:help classes/+utils/@math/fisher">classes/+utils/@math/fisher</a>                       - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/fisher_1x1">classes/+utils/@math/fisher_1x1</a>                   - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/fisher_2x2">classes/+utils/@math/fisher_2x2</a>                   - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/fitPrior">classes/+utils/@math/fitPrior</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/fminsearchbnd_core">classes/+utils/@math/fminsearchbnd_core</a>           - --------------------------------------------------------------------------
%   <a href="matlab:help classes/+utils/@math/fpsder">classes/+utils/@math/fpsder</a>                       -  performs the numeric time derivative
%   <a href="matlab:help classes/+utils/@math/fq2ri">classes/+utils/@math/fq2ri</a>                        -  Convert frequency/Q pole/zero representation into real
%   <a href="matlab:help classes/+utils/@math/fq2ri2">classes/+utils/@math/fq2ri2</a>                       -  Convert frequency/Q pole/zero representation into real
%   <a href="matlab:help classes/+utils/@math/free_flight_ode">classes/+utils/@math/free_flight_ode</a>              - % we cannot look up the parameter each time because it takes too long
%   <a href="matlab:help classes/+utils/@math/freqCorr">classes/+utils/@math/freqCorr</a>                     -  Compute correlation between frequency bins
%   <a href="matlab:help classes/+utils/@math/gammacdf">classes/+utils/@math/gammacdf</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/gammapdf">classes/+utils/@math/gammapdf</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/getCorr">classes/+utils/@math/getCorr</a>                      - (No help available)
%   <a href="matlab:help classes/+utils/@math/getdc">classes/+utils/@math/getdc</a>                        -  get the DC gain factor for a pole-zero model
%   <a href="matlab:help classes/+utils/@math/getfftfreq">classes/+utils/@math/getfftfreq</a>                   - GETFFTFREQ: get frequencies for fft
%   <a href="matlab:help classes/+utils/@math/getinitstate">classes/+utils/@math/getinitstate</a>                 - (No help available)
%   <a href="matlab:help classes/+utils/@math/getjacobian">classes/+utils/@math/getjacobian</a>                  -  Calculate Jacobian of a given model function.
%   <a href="matlab:help classes/+utils/@math/getk">classes/+utils/@math/getk</a>                         -  get the mathematical gain factor for a pole-zero model
%   <a href="matlab:help classes/+utils/@math/heaviside">classes/+utils/@math/heaviside</a>                    - (No help available)
%   <a href="matlab:help classes/+utils/@math/iirinit">classes/+utils/@math/iirinit</a>                      -  defines the initial state of an IIR filter.
%   <a href="matlab:help classes/+utils/@math/intfact">classes/+utils/@math/intfact</a>                      -  computes integer factorisation
%   <a href="matlab:help classes/+utils/@math/isequal">classes/+utils/@math/isequal</a>                      -  test if two matrices are equal to within the given tolerance.
%   <a href="matlab:help classes/+utils/@math/jr2cov">classes/+utils/@math/jr2cov</a>                       -  Calculates coefficients covariance matrix from Jacobian and Residuals.
%   <a href="matlab:help classes/+utils/@math/kstest">classes/+utils/@math/kstest</a>                       -  perform the Kolmogorov - Smirnov statistical hypothesis test
%   <a href="matlab:help classes/+utils/@math/linfit">classes/+utils/@math/linfit</a>                       -  returns the fit parameters for a linear fit of the form  y = m*x + b.
%   <a href="matlab:help classes/+utils/@math/linfitsvd">classes/+utils/@math/linfitsvd</a>                    - Linear fit with singular value decomposition
%   <a href="matlab:help classes/+utils/@math/linlsqsvd">classes/+utils/@math/linlsqsvd</a>                    -  Linear least squares with singular value decomposition
%   <a href="matlab:help classes/+utils/@math/logLmath">classes/+utils/@math/logLmath</a>                     - (No help available)
%   <a href="matlab:help classes/+utils/@math/loglikelihood">classes/+utils/@math/loglikelihood</a>                - (No help available)
%   <a href="matlab:help classes/+utils/@math/loglikelihood_matrix">classes/+utils/@math/loglikelihood_matrix</a>         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/loglikelihood_ssm">classes/+utils/@math/loglikelihood_ssm</a>            - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/loglikelihood_ssm_td">classes/+utils/@math/loglikelihood_ssm_td</a>         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/loglikelihood_td">classes/+utils/@math/loglikelihood_td</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/lp2z">classes/+utils/@math/lp2z</a>                         -  converts a continous TF in to a discrete TF.
%   <a href="matlab:help classes/+utils/@math/math">classes/+utils/@math/math</a>                         -  helper class for math utility functions.
%   <a href="matlab:help classes/+utils/@math/mhsample">classes/+utils/@math/mhsample</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/mhsample_td">classes/+utils/@math/mhsample_td</a>                  - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/mtxiirresp">classes/+utils/@math/mtxiirresp</a>                   -  calculate iir resp by matrix product
%   <a href="matlab:help classes/+utils/@math/mtxiirresp2">classes/+utils/@math/mtxiirresp2</a>                  -  calculate iir resp by matrix product
%   <a href="matlab:help classes/+utils/@math/mtxratresp2">classes/+utils/@math/mtxratresp2</a>                  - MTXIIRRESP calculate rational resp by matrix product
%   <a href="matlab:help classes/+utils/@math/mult">classes/+utils/@math/mult</a>                         - % Multiplication function designed specially for the
%   <a href="matlab:help classes/+utils/@math/music">classes/+utils/@math/music</a>                        -   Implements the heart of the MUSIC algorithm of line spectra estimation.
%   <a href="matlab:help classes/+utils/@math/ndeigcsd">classes/+utils/@math/ndeigcsd</a>                     -  calculates TFs from ND cross-correlated spectra.
%   <a href="matlab:help classes/+utils/@math/normalPDF">classes/+utils/@math/normalPDF</a>                    - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/overlapCorr">classes/+utils/@math/overlapCorr</a>                  -  Compute correlation introduced by segment overlapping
%   <a href="matlab:help classes/+utils/@math/pf2ss">classes/+utils/@math/pf2ss</a>                        -  Convert partial fraction models to state space matrices
%   <a href="matlab:help classes/+utils/@math/pfallps">classes/+utils/@math/pfallps</a>                      -  all pass filtering in order to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallps2">classes/+utils/@math/pfallps2</a>                     -  all pass filtering to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallpsyms">classes/+utils/@math/pfallpsyms</a>                   - (No help available)
%   <a href="matlab:help classes/+utils/@math/pfallpsyms2">classes/+utils/@math/pfallpsyms2</a>                  -  all pass filtering to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallpsymz">classes/+utils/@math/pfallpsymz</a>                   -  all pass filtering in order to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallpsymz2">classes/+utils/@math/pfallpsymz2</a>                  -  all pass filtering to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallpz">classes/+utils/@math/pfallpz</a>                      -  all pass filtering to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfallpz2">classes/+utils/@math/pfallpz2</a>                     -  all pass filtering to stabilize TF poles and zeros.
%   <a href="matlab:help classes/+utils/@math/pfresp">classes/+utils/@math/pfresp</a>                       -  returns frequency response of a partial fraction TF.
%   <a href="matlab:help classes/+utils/@math/phase">classes/+utils/@math/phase</a>                        -  return the phase in degrees for a given complex input.
%   <a href="matlab:help classes/+utils/@math/ppplot">classes/+utils/@math/ppplot</a>                       -  makes probability-probability plot
%   <a href="matlab:help classes/+utils/@math/psd">classes/+utils/@math/psd</a>                          - UTILS.MATH.PSD: Pure Matlab function that performs the PSD using LTPDA machinery
%   <a href="matlab:help classes/+utils/@math/psd2tf">classes/+utils/@math/psd2tf</a>                       -  Input power spectral density (psd) and output a stable and minimum
%   <a href="matlab:help classes/+utils/@math/psd2wf">classes/+utils/@math/psd2wf</a>                       - PSD2WF: Input power spectral density (psd) and output a corresponding
%   <a href="matlab:help classes/+utils/@math/psdvectorfit">classes/+utils/@math/psdvectorfit</a>                 - AUTOCFIT performs a fitting loop to identify model order and parameters.
%   <a href="matlab:help classes/+utils/@math/psdzfit">classes/+utils/@math/psdzfit</a>                      - PSDZFIT: Fit discrete partial fraction model to PSD
%   <a href="matlab:help classes/+utils/@math/psre">classes/+utils/@math/psre</a>                         - (No help available)
%   <a href="matlab:help classes/+utils/@math/pzmodel2SSMats">classes/+utils/@math/pzmodel2SSMats</a>               - % computing the A matrix
%   <a href="matlab:help classes/+utils/@math/qqplot">classes/+utils/@math/qqplot</a>                       -  makes quantile-quantile plot
%   <a href="matlab:help classes/+utils/@math/rand">classes/+utils/@math/rand</a>                         -  return a random number between r1 and r2
%   <a href="matlab:help classes/+utils/@math/randelement">classes/+utils/@math/randelement</a>                  - RANDELEMENT(VECTOR,J) returns J random samples chosen in the VECTOR array.
%   <a href="matlab:help classes/+utils/@math/randomWalkGen">classes/+utils/@math/randomWalkGen</a>                - Generate a random walk
%   <a href="matlab:help classes/+utils/@math/regularizePSDForFit">classes/+utils/@math/regularizePSDForFit</a>          - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/ri2fq">classes/+utils/@math/ri2fq</a>                        -  Convert complex pole/zero into frequency/Q pole/zero representation.
%   <a href="matlab:help classes/+utils/@math/rjsample">classes/+utils/@math/rjsample</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/rootmusic">classes/+utils/@math/rootmusic</a>                    -    Computes the frequencies and powers of sinusoids via the
%   <a href="matlab:help classes/+utils/@math/roundn">classes/+utils/@math/roundn</a>                       -   Round to multiple of 10^n
%   <a href="matlab:help classes/+utils/@math/slopefit">classes/+utils/@math/slopefit</a>                     -  returns the fit parameters for a linear fit of the form  y = m*x.
%   <a href="matlab:help classes/+utils/@math/spcorr">classes/+utils/@math/spcorr</a>                       -  calculate Spearman Rank-Order Correlation Coefficient
%   <a href="matlab:help classes/+utils/@math/spflat">classes/+utils/@math/spflat</a>                       -  measures the flatness of a given spectrum
%   <a href="matlab:help classes/+utils/@math/startpoles">classes/+utils/@math/startpoles</a>                   -  defines starting poles for fitting procedures ctfit, dtfit.
%   <a href="matlab:help classes/+utils/@math/stnr">classes/+utils/@math/stnr</a>                         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/stopfit">classes/+utils/@math/stopfit</a>                      -  verify fit accuracy checking for specified condition.
%   <a href="matlab:help classes/+utils/@math/stpdf">classes/+utils/@math/stpdf</a>                        -   Probability density function for Student's T distribution
%   <a href="matlab:help classes/+utils/@math/unitStep">classes/+utils/@math/unitStep</a>                     - (No help available)
%   <a href="matlab:help classes/+utils/@math/unwrapdeg">classes/+utils/@math/unwrapdeg</a>                    -  Unwrap a phase vector given in degrees.
%   <a href="matlab:help classes/+utils/@math/vcfit">classes/+utils/@math/vcfit</a>                        -  Fits continuous models to frequency responses
%   <a href="matlab:help classes/+utils/@math/vdfit">classes/+utils/@math/vdfit</a>                        - VDFIT: Fit discrete models to frequency responses
%   <a href="matlab:help classes/+utils/@math/welchdft">classes/+utils/@math/welchdft</a>                     -  welch method with dft
%   <a href="matlab:help classes/+utils/@math/welchscale">classes/+utils/@math/welchscale</a>                   -  scales the output of welch to be in the required units
%   <a href="matlab:help classes/+utils/@math/wfun">classes/+utils/@math/wfun</a>                         -  defines weighting factor for fitting procedures ctfit, dtfit.
%   <a href="matlab:help classes/+utils/@math/xCovmat">classes/+utils/@math/xCovmat</a>                      - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help classes/+utils/@math/ymcd">classes/+utils/@math/ymcd</a>                         - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@models   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@models/displayModelOverview">classes/+utils/@models/displayModelOverview</a>             -  displays the model overview in the MATLAB browser.
%   <a href="matlab:help classes/+utils/@models/functionForVersion">classes/+utils/@models/functionForVersion</a>               -  returns the function handle for a given version string
%   <a href="matlab:help classes/+utils/@models/getBuiltinModelSearchPaths">classes/+utils/@models/getBuiltinModelSearchPaths</a>       - % Get a list of user model directories
%   <a href="matlab:help classes/+utils/@models/getDefaultPlist">classes/+utils/@models/getDefaultPlist</a>                  -  returns a default plist for the model 
%   <a href="matlab:help classes/+utils/@models/getDescription">classes/+utils/@models/getDescription</a>                   -  builds a description string from the model
%   <a href="matlab:help classes/+utils/@models/getInfo">classes/+utils/@models/getInfo</a>                          -  Get Info Object
%   <a href="matlab:help classes/+utils/@models/mainFnc">classes/+utils/@models/mainFnc</a>                          -  is the main function call for all built-in models.
%   <a href="matlab:help classes/+utils/@models/makeBuiltInModel">classes/+utils/@models/makeBuiltInModel</a>                 -  prepares a new built-in model template
%   <a href="matlab:help classes/+utils/@models/models">classes/+utils/@models/models</a>                           -  helper class for built-in model utility functions.
%   <a href="matlab:help classes/+utils/@models/processModelInputs">classes/+utils/@models/processModelInputs</a>               -  processes the various input options for built-in
%   <a href="matlab:help classes/+utils/@models/template_built_in_model">classes/+utils/@models/template_built_in_model</a>          -  built-in model of class <CLASS> called <NAME>
%   <a href="matlab:help classes/+utils/@models/template_built_in_model_unittest">classes/+utils/@models/template_built_in_model_unittest</a> - test_<CLASS>_model_<NAME> - Returns a TestSuite with the test plan of the built-in model <NAME>.
%   <a href="matlab:help classes/+utils/@models/template_class_TestCaseModel">classes/+utils/@models/template_class_TestCaseModel</a>     - TCM_<MODULE>_Misc_<CLASS> - Defines the tests for all <CLASS> models in the <MODULE> module.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@modules   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@modules/buildModule">classes/+utils/@modules/buildModule</a>               -  builds a new module structure in the location specified by
%   <a href="matlab:help classes/+utils/@modules/copyHashFile">classes/+utils/@modules/copyHashFile</a>              -  copies an hash file for an LTPDA Extension module into the LTPDA hash folder
%   <a href="matlab:help classes/+utils/@modules/generateHash">classes/+utils/@modules/generateHash</a>              -  generates a hash file for an LTPDA Extension module
%   <a href="matlab:help classes/+utils/@modules/generateVCSHash">classes/+utils/@modules/generateVCSHash</a>           -  generates a hash file for an LTPDA Extension module
%   <a href="matlab:help classes/+utils/@modules/getExtensionDirs">classes/+utils/@modules/getExtensionDirs</a>          - % Get a list of user extension directories
%   <a href="matlab:help classes/+utils/@modules/installExtensions">classes/+utils/@modules/installExtensions</a>         -  all extension modules declared in the user's preferences.
%   <a href="matlab:help classes/+utils/@modules/installExtensionsForDir">classes/+utils/@modules/installExtensionsForDir</a>   -  installs the toolbox extensions found under the
%   <a href="matlab:help classes/+utils/@modules/makeMethod">classes/+utils/@modules/makeMethod</a>                -  prepares a new LTPDA method
%   <a href="matlab:help classes/+utils/@modules/method_template">classes/+utils/@modules/method_template</a>           - <METHOD_UPPER> performs actions on <CLASS> objects.
%   <a href="matlab:help classes/+utils/@modules/method_unittest_template">classes/+utils/@modules/method_unittest_template</a>  - TEST_<CLASS>_<METHOD> runs tests for the <CLASS> method <METHOD>.
%   <a href="matlab:help classes/+utils/@modules/moduleInfo">classes/+utils/@modules/moduleInfo</a>                -  returns a structure containing information about the module.
%   <a href="matlab:help classes/+utils/@modules/modules">classes/+utils/@modules/modules</a>                   -  helper class for LTPDA extension modules.
%   <a href="matlab:help classes/+utils/@modules/releaseModule">classes/+utils/@modules/releaseModule</a>             -  prepares an extension module for release.
%   <a href="matlab:help classes/+utils/@modules/uninstallExtensions">classes/+utils/@modules/uninstallExtensions</a>       -  all extension modules declared in the user's preferences.
%   <a href="matlab:help classes/+utils/@modules/uninstallExtensionsForDir">classes/+utils/@modules/uninstallExtensionsForDir</a> -  uninstalls the toolbox extensions found under the
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@mysql   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@mysql/connect">classes/+utils/@mysql/connect</a> -  Opens a connection to the given database.
%   <a href="matlab:help classes/+utils/@mysql/execute">classes/+utils/@mysql/execute</a> -  Execute the given QUERY with optional parameters VARARGIN
%   <a href="matlab:help classes/+utils/@mysql/mysql">classes/+utils/@mysql/mysql</a>   - UTILS.MYSQL  MySQL database utilities.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@plottools   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@plottools/addPlotProvenance">classes/+utils/@plottools/addPlotProvenance</a>          -  adds a discrete text label to a figure with details of
%   <a href="matlab:help classes/+utils/@plottools/addRepositoryPatch">classes/+utils/@plottools/addRepositoryPatch</a>         - ADDPLOTPROVENANCE adds a discrete text label to a figure with details of
%   <a href="matlab:help classes/+utils/@plottools/adjustErrorbarTick">classes/+utils/@plottools/adjustErrorbarTick</a>         -  Adjust the width of y-errorbars.
%   <a href="matlab:help classes/+utils/@plottools/allLines">classes/+utils/@plottools/allLines</a>                   -  Set all the line styles and widths on the current axes
%   <a href="matlab:help classes/+utils/@plottools/allMarkers">classes/+utils/@plottools/allMarkers</a>                 -  Set all the markers on the current axes
%   <a href="matlab:help classes/+utils/@plottools/allgrid">classes/+utils/@plottools/allgrid</a>                    -  Set all the grids to 'state'
%   <a href="matlab:help classes/+utils/@plottools/allowedLinestyles">classes/+utils/@plottools/allowedLinestyles</a>          -  returns a cell-array of valid MATLAB line styles.
%   <a href="matlab:help classes/+utils/@plottools/allowedMarkers">classes/+utils/@plottools/allowedMarkers</a>             -  returns a cell-array of valid MATLAB markers.
%   <a href="matlab:help classes/+utils/@plottools/allxaxis">classes/+utils/@plottools/allxaxis</a>                   - ALLXSCALE Set all the x scales on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/allxlabel">classes/+utils/@plottools/allxlabel</a>                  -  Set all the x-axis labels on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/allxscale">classes/+utils/@plottools/allxscale</a>                  -  Set all the x scales on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/allyaxis">classes/+utils/@plottools/allyaxis</a>                   -  Set all the yaxis ranges on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/allylabel">classes/+utils/@plottools/allylabel</a>                  -  Set all the y-axis labels on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/allyscale">classes/+utils/@plottools/allyscale</a>                  -  Set all the Y scales on the current figure.
%   <a href="matlab:help classes/+utils/@plottools/backupDefaultPlotSettings">classes/+utils/@plottools/backupDefaultPlotSettings</a>  -  Backup the current default plot settings.
%   <a href="matlab:help classes/+utils/@plottools/box">classes/+utils/@plottools/box</a>                        -  applies box to all the given axes handles.
%   <a href="matlab:help classes/+utils/@plottools/cacheObjectInUserData">classes/+utils/@plottools/cacheObjectInUserData</a>      -  cache a copy of the object in the figure handle's
%   <a href="matlab:help classes/+utils/@plottools/consolidatePlot">classes/+utils/@plottools/consolidatePlot</a>            -  creates a collection object from the objects contained
%   <a href="matlab:help classes/+utils/@plottools/convertXunits">classes/+utils/@plottools/convertXunits</a>              - -----------------------------------------------
%   <a href="matlab:help classes/+utils/@plottools/cscale">classes/+utils/@plottools/cscale</a>                     -  Set the color range of the current figure
%   <a href="matlab:help classes/+utils/@plottools/datacursormode">classes/+utils/@plottools/datacursormode</a>             - Display the position of the data cursor
%   <a href="matlab:help classes/+utils/@plottools/errorbarxy">classes/+utils/@plottools/errorbarxy</a>                 -  Customizable error bar plot in X and Y direction
%   <a href="matlab:help classes/+utils/@plottools/fixAxisLabel">classes/+utils/@plottools/fixAxisLabel</a>               -  performs some substitutions on the axis label string.
%   <a href="matlab:help classes/+utils/@plottools/getAxes">classes/+utils/@plottools/getAxes</a>                    -  gets an array of axes from the given figure handle.
%   <a href="matlab:help classes/+utils/@plottools/getLegends">classes/+utils/@plottools/getLegends</a>                 -  gets an array of legends from the given figure handle.
%   <a href="matlab:help classes/+utils/@plottools/hold">classes/+utils/@plottools/hold</a>                       -  applies hold to all the given axes handles.
%   <a href="matlab:help classes/+utils/@plottools/horizontalLine">classes/+utils/@plottools/horizontalLine</a>             -  plots a horizontal line(s) to an axes handle.
%   <a href="matlab:help classes/+utils/@plottools/islinespec">classes/+utils/@plottools/islinespec</a>                 -  checks a string to the line spec syntax.
%   <a href="matlab:help classes/+utils/@plottools/label">classes/+utils/@plottools/label</a>                      -  makes the input string into a suitable string for using on plots.
%   <a href="matlab:help classes/+utils/@plottools/legendAdd">classes/+utils/@plottools/legendAdd</a>                  -  Add a string to the current legend.
%   <a href="matlab:help classes/+utils/@plottools/makeDraft">classes/+utils/@plottools/makeDraft</a>                  -  labels a figure as draft, or not.
%   <a href="matlab:help classes/+utils/@plottools/msuptitle">classes/+utils/@plottools/msuptitle</a>                  -  Puts a title above all subplots.
%   <a href="matlab:help classes/+utils/@plottools/plottools">classes/+utils/@plottools/plottools</a>                  -  class for tools to manipulate the current object/figure/axis.
%   <a href="matlab:help classes/+utils/@plottools/restoreDefaultPlotSettings">classes/+utils/@plottools/restoreDefaultPlotSettings</a> -  Restore the saved plot settings.
%   <a href="matlab:help classes/+utils/@plottools/retrieveFigure">classes/+utils/@plottools/retrieveFigure</a>             -  retreives a figure plist from an LTPDA repository.
%   <a href="matlab:help classes/+utils/@plottools/setLegendLocation">classes/+utils/@plottools/setLegendLocation</a>          -  gets an array of legends from the given figure handle
%   <a href="matlab:help classes/+utils/@plottools/submitFigure">classes/+utils/@plottools/submitFigure</a>               -  submits the given figure to an LTPDA repository.
%   <a href="matlab:help classes/+utils/@plottools/verticalLine">classes/+utils/@plottools/verticalLine</a>               -  plots a vertical line(s) to an axes handle.
%   <a href="matlab:help classes/+utils/@plottools/xaxis">classes/+utils/@plottools/xaxis</a>                      -  Set the X axis range of the current figure
%   <a href="matlab:help classes/+utils/@plottools/xlim">classes/+utils/@plottools/xlim</a>                       -  applies xlim to all the given axes handles.
%   <a href="matlab:help classes/+utils/@plottools/xscale">classes/+utils/@plottools/xscale</a>                     -  Set the X scale of the current axis
%   <a href="matlab:help classes/+utils/@plottools/xticks">classes/+utils/@plottools/xticks</a>                     -  set the input vector as the x-ticks of the current axis.
%   <a href="matlab:help classes/+utils/@plottools/yaxis">classes/+utils/@plottools/yaxis</a>                      -  Set the Y axis range of the current figure
%   <a href="matlab:help classes/+utils/@plottools/ylim">classes/+utils/@plottools/ylim</a>                       -  applies ylim to all the given axes handles.
%   <a href="matlab:help classes/+utils/@plottools/yscale">classes/+utils/@plottools/yscale</a>                     -  Set the Y scale of the current axis
%   <a href="matlab:help classes/+utils/@plottools/yticks">classes/+utils/@plottools/yticks</a>                     -  set the input vector as the y-ticks of the current axis.
%   <a href="matlab:help classes/+utils/@plottools/zaxis">classes/+utils/@plottools/zaxis</a>                      -  Set the Z axis range of the current figure
%   <a href="matlab:help classes/+utils/@plottools/zscale">classes/+utils/@plottools/zscale</a>                     -  Set the Z scale of the current axis
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@prog   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@prog/cell2str">classes/+utils/@prog/cell2str</a>             -  Convert a 2-D cell array to a string in MATLAB syntax.
%   <a href="matlab:help classes/+utils/@prog/convertComString">classes/+utils/@prog/convertComString</a>     - replaceString changes the input string accordingly to a predefined list of rules
%   <a href="matlab:help classes/+utils/@prog/csv">classes/+utils/@prog/csv</a>                  -  makes comma separated list of numbers
%   <a href="matlab:help classes/+utils/@prog/csvFile2struct">classes/+utils/@prog/csvFile2struct</a>       -  Reads a CSV file into a structure
%   <a href="matlab:help classes/+utils/@prog/cutString">classes/+utils/@prog/cutString</a>            -  Cuts a string to maximum length
%   <a href="matlab:help classes/+utils/@prog/dirscan">classes/+utils/@prog/dirscan</a>              -  recursively scans the given directory for subdirectories that match the given pattern.
%   <a href="matlab:help classes/+utils/@prog/disp">classes/+utils/@prog/disp</a>                 -  display a formatted string to screen.
%   <a href="matlab:help classes/+utils/@prog/fields2list">classes/+utils/@prog/fields2list</a>          -  splits a string containing fields seperated by ','
%   <a href="matlab:help classes/+utils/@prog/filescan">classes/+utils/@prog/filescan</a>             -  recursively scans the given directory for files that end in 'ext'
%   <a href="matlab:help classes/+utils/@prog/find_in_models">classes/+utils/@prog/find_in_models</a>       -  Search full block diagram hierarchy
%   <a href="matlab:help classes/+utils/@prog/findchildren">classes/+utils/@prog/findchildren</a>         - This function retrieves the handles of all blocks children of a given
%   <a href="matlab:help classes/+utils/@prog/findparent">classes/+utils/@prog/findparent</a>           - This function retrieves the handles of all blocks parents of a given
%   <a href="matlab:help classes/+utils/@prog/funchash">classes/+utils/@prog/funchash</a>             -  compute MD5 hash of a MATLAB m-file.
%   <a href="matlab:help classes/+utils/@prog/gcbsh">classes/+utils/@prog/gcbsh</a>                -  gets the handles for the currently selected blocks.
%   <a href="matlab:help classes/+utils/@prog/get_curr_m_file_path">classes/+utils/@prog/get_curr_m_file_path</a> -  returns the path for a mfile.
%   <a href="matlab:help classes/+utils/@prog/hash">classes/+utils/@prog/hash</a>                 -  - Convert an input variable into a message digest.
%   <a href="matlab:help classes/+utils/@prog/issubclass">classes/+utils/@prog/issubclass</a>           - % check this level
%   <a href="matlab:help classes/+utils/@prog/jcolor2mcolor">classes/+utils/@prog/jcolor2mcolor</a>        -  converts a java color object to a MATLAB color array.
%   <a href="matlab:help classes/+utils/@prog/label">classes/+utils/@prog/label</a>                -  makes the input string into a suitable string for using on plots.
%   <a href="matlab:help classes/+utils/@prog/mcell2str">classes/+utils/@prog/mcell2str</a>            -  recursively converts a cell-array to an executable string.
%   <a href="matlab:help classes/+utils/@prog/mcolor2jcolor">classes/+utils/@prog/mcolor2jcolor</a>        -  converts a MATLAB color to a java Color object.
%   <a href="matlab:help classes/+utils/@prog/mup2mat">classes/+utils/@prog/mup2mat</a>              -  converts Mupad string to MATLAB string
%   <a href="matlab:help classes/+utils/@prog/obj2binary">classes/+utils/@prog/obj2binary</a>           -  Converts an object to binary representation
%   <a href="matlab:help classes/+utils/@prog/obj2xml">classes/+utils/@prog/obj2xml</a>              -  Converts an object to an XML representation
%   <a href="matlab:help classes/+utils/@prog/prog">classes/+utils/@prog/prog</a>                 -  helper class for prog utility functions.
%   <a href="matlab:help classes/+utils/@prog/rnfield">classes/+utils/@prog/rnfield</a>              -  Rename Structure Fields.
%   <a href="matlab:help classes/+utils/@prog/rstruct">classes/+utils/@prog/rstruct</a>              -  recursively converts an object into a structure.
%   <a href="matlab:help classes/+utils/@prog/str2cells">classes/+utils/@prog/str2cells</a>            -  Take a single string and separate out individual "elements" into a new cell array.
%   <a href="matlab:help classes/+utils/@prog/strjoin">classes/+utils/@prog/strjoin</a>              -  Concatenate an array into a single string.
%   <a href="matlab:help classes/+utils/@prog/strpad">classes/+utils/@prog/strpad</a>               -  Pads a string with blank spaces until it is N characters long.
%   <a href="matlab:help classes/+utils/@prog/strs2cells">classes/+utils/@prog/strs2cells</a>           -  convert a set of input strings to a cell array.
%   <a href="matlab:help classes/+utils/@prog/struct2csvFile">classes/+utils/@prog/struct2csvFile</a>       -  Saves a structure as a CSV file.
%   <a href="matlab:help classes/+utils/@prog/structcat">classes/+utils/@prog/structcat</a>            -  concatonate structures to make one large structure.
%   <a href="matlab:help classes/+utils/@prog/wrapstring">classes/+utils/@prog/wrapstring</a>           -  wraps a string to a cell array of strings with each cell less than n characters long.
%   <a href="matlab:help classes/+utils/@prog/yes2true">classes/+utils/@prog/yes2true</a>             -  converts strings containing 'yes'/'no' into boolean true/false
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@repository   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@repository/adjustPlist">classes/+utils/@repository/adjustPlist</a>           - ADJUSTPLIST(CONN, PL) Removes CONN, USERNAME, PASSWORD parameters
%   <a href="matlab:help classes/+utils/@repository/createCollection">classes/+utils/@repository/createCollection</a>      -   Creates a new collection.
%   <a href="matlab:help classes/+utils/@repository/existObjectInDB">classes/+utils/@repository/existObjectInDB</a>       -  checks if a given name exist in the database table objmeta.name
%   <a href="matlab:help classes/+utils/@repository/findDuplicates">classes/+utils/@repository/findDuplicates</a>        -  returns the IDs of duplicated objects for given database.
%   <a href="matlab:help classes/+utils/@repository/getCollectionIDs">classes/+utils/@repository/getCollectionIDs</a>      -   Return the IDs of the objects composing a collection.
%   <a href="matlab:help classes/+utils/@repository/getIDfromUUID">classes/+utils/@repository/getIDfromUUID</a>         -  returns the UUID for given database IDs.
%   <a href="matlab:help classes/+utils/@repository/getLatestObject">classes/+utils/@repository/getLatestObject</a>       -  Performs a mySQL query on a LTPDA repository and returns
%   <a href="matlab:help classes/+utils/@repository/getObjectIdInTimespan">classes/+utils/@repository/getObjectIdInTimespan</a> -  returns the object ID for a given timespan which fits into the timespan of the metadata.keywords.
%   <a href="matlab:help classes/+utils/@repository/getObjectMetaData">classes/+utils/@repository/getObjectMetaData</a>     -  Retrieved objects metadata from the repository
%   <a href="matlab:help classes/+utils/@repository/getObjectType">classes/+utils/@repository/getObjectType</a>         -   Return the type of the object.
%   <a href="matlab:help classes/+utils/@repository/getUUIDfromID">classes/+utils/@repository/getUUIDfromID</a>         -  returns the UUID for given database IDs.
%   <a href="matlab:help classes/+utils/@repository/getUser">classes/+utils/@repository/getUser</a>               -   Return username and userid of the current database user.
%   <a href="matlab:help classes/+utils/@repository/insertObjMetadata">classes/+utils/@repository/insertObjMetadata</a>     - an utility to insert entries for various object metadata in the
%   <a href="matlab:help classes/+utils/@repository/insertObjMetadataV1">classes/+utils/@repository/insertObjMetadataV1</a>   - an utility to insert entries for various object metadata in the
%   <a href="matlab:help classes/+utils/@repository/listDatabases">classes/+utils/@repository/listDatabases</a>         -  returns a list of database names on the server.
%   <a href="matlab:help classes/+utils/@repository/report">classes/+utils/@repository/report</a>                - UTILS.REPOSITORY.REPORT Dumps the records of a database to a file
%   <a href="matlab:help classes/+utils/@repository/repository">classes/+utils/@repository/repository</a>            - UTILS.REPOSITORY  Utility functions to operate with LTPDA Repositories
%   <a href="matlab:help classes/+utils/@repository/search">classes/+utils/@repository/search</a>                -  searches for objects by name and timespan in a repository
%   <a href="matlab:help classes/+utils/@repository/updateObjMetadata">classes/+utils/@repository/updateObjMetadata</a>     - an utility to update entries for various object metadata in the
%   <a href="matlab:help classes/+utils/@repository/updateObjMetadataV1">classes/+utils/@repository/updateObjMetadataV1</a>   - an utility to update entries for various object metadata in the
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@timetools   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@timetools/getTimezone">classes/+utils/@timetools/getTimezone</a>   - GETIMEZONE Get the list of supported time zones.
%   <a href="matlab:help classes/+utils/@timetools/gps2utc">classes/+utils/@timetools/gps2utc</a>       -  converts GPS seconds to UTC time.
%   <a href="matlab:help classes/+utils/@timetools/gpsnow">classes/+utils/@timetools/gpsnow</a>        - Returns the current system time as a GPS second.
%   <a href="matlab:help classes/+utils/@timetools/reformat_date">classes/+utils/@timetools/reformat_date</a> -  reformats the input date
%   <a href="matlab:help classes/+utils/@timetools/timetools">classes/+utils/@timetools/timetools</a>     -  class for tools to manipulate the time.
%   <a href="matlab:help classes/+utils/@timetools/utc2gps">classes/+utils/@timetools/utc2gps</a>       -  Converts UTC time to GPS seconds.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/+utils/@xml   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/+utils/@xml/attachCellToDom">classes/+utils/@xml/attachCellToDom</a>       - % Store the cell shape in the parent node
%   <a href="matlab:help classes/+utils/@xml/attachCellstrToDom">classes/+utils/@xml/attachCellstrToDom</a>    - % Store the original shape of the string
%   <a href="matlab:help classes/+utils/@xml/attachCharToDom">classes/+utils/@xml/attachCharToDom</a>       - % Store the original shape of the string
%   <a href="matlab:help classes/+utils/@xml/attachEmptyObjectNode">classes/+utils/@xml/attachEmptyObjectNode</a> - emptyNode.setAttribute('shape', sprintf('%dx%d', size(objs)));
%   <a href="matlab:help classes/+utils/@xml/attachMatrixToDom">classes/+utils/@xml/attachMatrixToDom</a>     - shape = sprintf('%dx%d', size(numbers));
%   <a href="matlab:help classes/+utils/@xml/attachNumberToDom">classes/+utils/@xml/attachNumberToDom</a>     - % Store the original shape
%   <a href="matlab:help classes/+utils/@xml/attachStructToDom">classes/+utils/@xml/attachStructToDom</a>     - % Store the structure shape in the parent node
%   <a href="matlab:help classes/+utils/@xml/attachSymToDom">classes/+utils/@xml/attachSymToDom</a>        - % Attach the string as a content to the parent node
%   <a href="matlab:help classes/+utils/@xml/attachVectorToDom">classes/+utils/@xml/attachVectorToDom</a>     - shape = sprintf('%dx%d', size(numbers));
%   <a href="matlab:help classes/+utils/@xml/cellstr2str">classes/+utils/@xml/cellstr2str</a>           - % Check if empty cell or empty string
%   <a href="matlab:help classes/+utils/@xml/getCell">classes/+utils/@xml/getCell</a>               - % Get shape
%   <a href="matlab:help classes/+utils/@xml/getCellstr">classes/+utils/@xml/getCellstr</a>            - % Get the shape from the attribute
%   <a href="matlab:help classes/+utils/@xml/getChildByName">classes/+utils/@xml/getChildByName</a>        - expression = XPATH.compile(sprintf('child::%s', childName));
%   <a href="matlab:help classes/+utils/@xml/getChildrenByName">classes/+utils/@xml/getChildrenByName</a>     - expression = XPATH.compile(sprintf('child::%s', childName));
%   <a href="matlab:help classes/+utils/@xml/getFromType">classes/+utils/@xml/getFromType</a>           - % It might be possible that a NON LTPDA class is stored inside a LTPDA
%   <a href="matlab:help classes/+utils/@xml/getHistoryFromUUID">classes/+utils/@xml/getHistoryFromUUID</a>    - error('### Didn''t find a history object with the UUID [%s]', inhistUUID)
%   <a href="matlab:help classes/+utils/@xml/getMatrix">classes/+utils/@xml/getMatrix</a>             - % Get node name
%   <a href="matlab:help classes/+utils/@xml/getNumber">classes/+utils/@xml/getNumber</a>             - % Special case for an empty double.
%   classes/+utils/@xml/getObject             - (No help available)
%   <a href="matlab:help classes/+utils/@xml/getShape">classes/+utils/@xml/getShape</a>              -  = sscanf(utils.xml.mchar(node.getAttribute('shape')), '%dx%d')';
%   <a href="matlab:help classes/+utils/@xml/getString">classes/+utils/@xml/getString</a>             - % Get node content
%   classes/+utils/@xml/getStringFromNode     - (No help available)
%   <a href="matlab:help classes/+utils/@xml/getStruct">classes/+utils/@xml/getStruct</a>             - % Get shape
%   <a href="matlab:help classes/+utils/@xml/getSym">classes/+utils/@xml/getSym</a>                - % Get node content
%   classes/+utils/@xml/getType               - (No help available)
%   <a href="matlab:help classes/+utils/@xml/getVector">classes/+utils/@xml/getVector</a>             - % Get node name
%   <a href="matlab:help classes/+utils/@xml/mat2str">classes/+utils/@xml/mat2str</a>               -  overloads the mat2str operator to set the precision at a central place.
%   classes/+utils/@xml/mchar                 - (No help available)
%   <a href="matlab:help classes/+utils/@xml/num2str">classes/+utils/@xml/num2str</a>               -  uses sprintf to convert a data vector to a string with a fixed precision.
%   <a href="matlab:help classes/+utils/@xml/prepareString">classes/+utils/@xml/prepareString</a>         - % Convert the string into one line.
%   classes/+utils/@xml/prepareVersionString  - (No help available)
%   <a href="matlab:help classes/+utils/@xml/read_sinfo_xml">classes/+utils/@xml/read_sinfo_xml</a>        -  reads a submission info struct from a simple XML file.
%   <a href="matlab:help classes/+utils/@xml/recoverString">classes/+utils/@xml/recoverString</a>         - % Recover the new line character.
%   classes/+utils/@xml/recoverVersionString  - (No help available)
%   <a href="matlab:help classes/+utils/@xml/save_sinfo_xml">classes/+utils/@xml/save_sinfo_xml</a>        -  saves a submission info struct to a simple XML file.
%   <a href="matlab:help classes/+utils/@xml/xml">classes/+utils/@xml/xml</a>                   -  helper class for helpful xml functions.
%   <a href="matlab:help classes/+utils/@xml/xmlread">classes/+utils/@xml/xmlread</a>               -  Reads a XML object
%   <a href="matlab:help classes/+utils/@xml/xmlwrite">classes/+utils/@xml/xmlwrite</a>              -  Add an object to a xml DOM project.
%
%
%%%%%%%%%%%%%%%%%%%%   class: LTPDADatabaseConnectionManager   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help LTPDADatabaseConnectionManager/LTPDADatabaseConnectionManager">LTPDADatabaseConnectionManager/LTPDADatabaseConnectionManager</a> - end % private properties
%
%
%%%%%%%%%%%%%%%%%%%%   class: LTPDAModelBrowser   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help LTPDAModelBrowser/LTPDAModelBrowser">LTPDAModelBrowser/LTPDAModelBrowser</a> -  is a graphical user interface for browsing the
%
%
%%%%%%%%%%%%%%%%%%%%   class: LTPDANamedItem   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help LTPDANamedItem/LTPDANamedItem">LTPDANamedItem/LTPDANamedItem</a>      -  is a base class for naming various items.
%   <a href="matlab:help LTPDANamedItem/attachToDom">LTPDANamedItem/attachToDom</a>         - % Create empty ao node with the attribute 'shape'
%   <a href="matlab:help LTPDANamedItem/copy">LTPDANamedItem/copy</a>                -  makes a (deep) copy of the input LTPDANamedItem objects.
%   <a href="matlab:help LTPDANamedItem/disp">LTPDANamedItem/disp</a>                -  display plist object.
%   <a href="matlab:help LTPDANamedItem/fromDom">LTPDANamedItem/fromDom</a>             - %%%%%%%%%% Call super-class
%   <a href="matlab:help LTPDANamedItem/fromStruct">LTPDANamedItem/fromStruct</a>          -  creates from a structure a LTPDANAMEDITEM object.
%   <a href="matlab:help LTPDANamedItem/ismember">LTPDANamedItem/ismember</a>            -  returns true for set member.
%   <a href="matlab:help LTPDANamedItem/listContentsOfGroup">LTPDANamedItem/listContentsOfGroup</a> -  lists the MTelemetry constructors for the
%   <a href="matlab:help LTPDANamedItem/listGroups">LTPDANamedItem/listGroups</a>          -  lists the different telemetry groups.
%   <a href="matlab:help LTPDANamedItem/loadobj">LTPDANamedItem/loadobj</a>             -  is called by the load function for user objects.
%   <a href="matlab:help LTPDANamedItem/obj2cmds">LTPDANamedItem/obj2cmds</a>            - This method is only necessary for the LTPDA method type() which
%   <a href="matlab:help LTPDANamedItem/retrieve">LTPDANamedItem/retrieve</a>            -  retrieves LTPDA objects from an LTPDA repository with help of a LTPDANamedItem object.
%   <a href="matlab:help LTPDANamedItem/sort">LTPDANamedItem/sort</a>                -  returns a sorted set of parameters.
%   <a href="matlab:help LTPDANamedItem/string">LTPDANamedItem/string</a>              -  converts an LTPDANamedItem object to a command string which will recreate the plist object.
%   <a href="matlab:help LTPDANamedItem/toHTML">LTPDANamedItem/toHTML</a>              -  creates and HTML table of the input objects
%   <a href="matlab:help LTPDANamedItem/unique">LTPDANamedItem/unique</a>              -  returns a set of parameters where non have the same name.
%   <a href="matlab:help LTPDANamedItem/update_struct">LTPDANamedItem/update_struct</a>       -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: LTPDARepositoryQuery   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help LTPDARepositoryQuery/LTPDARepositoryQuery">LTPDARepositoryQuery/LTPDARepositoryQuery</a> -  is a graphical user interface for query the LTPDA repository.
%   <a href="matlab:help LTPDARepositoryQuery/cb_executeQuery">LTPDARepositoryQuery/cb_executeQuery</a>      -  callback for executing the query
%   <a href="matlab:help LTPDARepositoryQuery/cb_guiClosed">LTPDARepositoryQuery/cb_guiClosed</a>         -  callback for closing the LTPDARepositoryQuery GUI
%
%
%%%%%%%%%%%%%%%%%%%%   class: LTPDAprefs   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help LTPDAprefs/LTPDAprefs">LTPDAprefs/LTPDAprefs</a>             -  is a graphical user interface for editing LTPDA preferences.
%   <a href="matlab:help LTPDAprefs/cb_addExtensionPath">LTPDAprefs/cb_addExtensionPath</a>    -  callback for adding a extensions path
%   <a href="matlab:help LTPDAprefs/cb_guiClosed">LTPDAprefs/cb_guiClosed</a>           -  callback for closing the LTPDAprefs GUI
%   <a href="matlab:help LTPDAprefs/cb_plotPrefsChanged">LTPDAprefs/cb_plotPrefsChanged</a>    - cb_addModelPath callback for adding a model path
%   <a href="matlab:help LTPDAprefs/cb_removeExtensionPath">LTPDAprefs/cb_removeExtensionPath</a> -  callback for removing a extensions path
%   <a href="matlab:help LTPDAprefs/cb_timeformatChanged">LTPDAprefs/cb_timeformatChanged</a>   - cb_verboseLevelChanged callback if the user change the verbose level
%   <a href="matlab:help LTPDAprefs/cb_timezoneChanged">LTPDAprefs/cb_timezoneChanged</a>     - cb_verboseLevelChanged callback if the user change the verbose level
%   <a href="matlab:help LTPDAprefs/cb_verboseLevelChanged">LTPDAprefs/cb_verboseLevelChanged</a> -  callback if the user change the verbose level
%   <a href="matlab:help LTPDAprefs/getPreferences">LTPDAprefs/getPreferences</a>         -  returns the LTPDA preference instance.
%   <a href="matlab:help LTPDAprefs/loadPrefs">LTPDAprefs/loadPrefs</a>              -  a static method which loads the preferences from a XML file.
%   <a href="matlab:help LTPDAprefs/setApplicationData">LTPDAprefs/setApplicationData</a>     -  sets the application data from the preferences object.
%   <a href="matlab:help LTPDAprefs/setPreference">LTPDAprefs/setPreference</a>          -  A static method which sets a new value to the specified preference.
%   <a href="matlab:help LTPDAprefs/upgradeFromPlist">LTPDAprefs/upgradeFromPlist</a>       -  upgrades the old preference strucure to the new structure.
%
%
%%%%%%%%%%%%%%%%%%%%   class: MCMC   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help MCMC/MCMC">MCMC/MCMC</a>                 -  - Markov Chain Monte Carlo algorithm
%   <a href="matlab:help MCMC/ao2strucArrays">MCMC/ao2strucArrays</a>       - AO2NUMMATRICES.m
%   <a href="matlab:help MCMC/attachToDom">MCMC/attachToDom</a>          - % Create empty ao node with the attribute 'shape'
%   <a href="matlab:help MCMC/buildLogLikelihood">MCMC/buildLogLikelihood</a>   - (No help available)
%   <a href="matlab:help MCMC/buildplist">MCMC/buildplist</a>           - (No help available)
%   <a href="matlab:help MCMC/calculateCovariance">MCMC/calculateCovariance</a>  - (No help available)
%   <a href="matlab:help MCMC/checkDiffStep">MCMC/checkDiffStep</a>        - (No help available)
%   <a href="matlab:help MCMC/checkP0class">MCMC/checkP0class</a>         - (No help available)
%   <a href="matlab:help MCMC/checkXo">MCMC/checkXo</a>              - --------------------------------------------------------------------------
%   <a href="matlab:help MCMC/collectOutputAOs">MCMC/collectOutputAOs</a>     - (No help available)
%   <a href="matlab:help MCMC/computeBeta">MCMC/computeBeta</a>          - (No help available)
%   <a href="matlab:help MCMC/computeICSMatrix">MCMC/computeICSMatrix</a>     - (No help available)
%   <a href="matlab:help MCMC/copy">MCMC/copy</a>                 -  makes a (deep) copy of the input MCMCs.
%   <a href="matlab:help MCMC/decision">MCMC/decision</a>             - DECISION: Compute the MH acceptance ratio
%   <a href="matlab:help MCMC/defineLogLikelihood">MCMC/defineLogLikelihood</a>  - (No help available)
%   <a href="matlab:help MCMC/drawAdaptiveSample">MCMC/drawAdaptiveSample</a>   - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help MCMC/drawSample">MCMC/drawSample</a>           - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help MCMC/fromDom">MCMC/fromDom</a>              - % Get shape
%   <a href="matlab:help MCMC/fromStruct">MCMC/fromStruct</a>           -  creates from a structure a TIMESPAN object.
%   <a href="matlab:help MCMC/getLikelihood">MCMC/getLikelihood</a>        -  Get the likelihood function in a mfh object.
%   MCMC/getParamNames        - (No help available)
%   <a href="matlab:help MCMC/getPest">MCMC/getPest</a>              -  Get the estimated parameters in a pest object.
%   <a href="matlab:help MCMC/handle_data_for_icsm">MCMC/handle_data_for_icsm</a> - (No help available)
%   <a href="matlab:help MCMC/initObjectWithSize">MCMC/initObjectWithSize</a>   - (No help available)
%   <a href="matlab:help MCMC/jump">MCMC/jump</a>                 - JUMP: Propose new point on the parameter space
%   <a href="matlab:help MCMC/loadobj">MCMC/loadobj</a>              -  is called by the load function for user objects.
%   <a href="matlab:help MCMC/logDecision">MCMC/logDecision</a>          - LOGDECISION: Compute the logarithm of the MH acceptance ratio
%   <a href="matlab:help MCMC/main">MCMC/main</a>                 - (No help available)
%   <a href="matlab:help MCMC/mhsample">MCMC/mhsample</a>             -  The Metropolis - Hastings algorithm
%   <a href="matlab:help MCMC/mhutils">MCMC/mhutils</a>              - --------------------------------------------------------------------------
%   <a href="matlab:help MCMC/performDataChecks">MCMC/performDataChecks</a>    - (No help available)
%   <a href="matlab:help MCMC/plotLogLikelihood">MCMC/plotLogLikelihood</a>    - (No help available)
%   <a href="matlab:help MCMC/preprocess">MCMC/preprocess</a>           - MCMC.preprocess.
%   <a href="matlab:help MCMC/preprocessMFH">MCMC/preprocessMFH</a>        - (No help available)
%   <a href="matlab:help MCMC/preprocessModel">MCMC/preprocessModel</a>      - --------------------------------------------------------------------------
%   <a href="matlab:help MCMC/processChain">MCMC/processChain</a>         - PROCESSCHAIN: Get the statisticts of the MCMC Chain
%   <a href="matlab:help MCMC/setInputs">MCMC/setInputs</a>            - (No help available)
%   <a href="matlab:help MCMC/setModel">MCMC/setModel</a>             -  Set the model of the investigation.
%   <a href="matlab:help MCMC/setNoise">MCMC/setNoise</a>             -  Set the measured noise of the experiment.
%   <a href="matlab:help MCMC/simplex">MCMC/simplex</a>              -  Multidimensional unconstrained nonlinear minimization (Nelder-Mead)
%   <a href="matlab:help MCMC/updateFIM">MCMC/updateFIM</a>            - --------------------------------------------------------------------------
%
%
%%%%%%%%%%%%%%%%%%%%   class: MCMC/tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help MCMC/tests/test_MCMC_calculateCovariance">MCMC/tests/test_MCMC_calculateCovariance</a> - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_convergence">MCMC/tests/test_MCMC_convergence</a>         - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_default_plist">MCMC/tests/test_MCMC_default_plist</a>       - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_getInfo">MCMC/tests/test_MCMC_getInfo</a>             - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_input_types">MCMC/tests/test_MCMC_input_types</a>         - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_loglikelihoods">MCMC/tests/test_MCMC_loglikelihoods</a>      - (No help available)
%   <a href="matlab:help MCMC/tests/test_MCMC_simplex">MCMC/tests/test_MCMC_simplex</a>             - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   class: ao   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ao/abs">ao/abs</a>                      -  overloads the Absolute value method for analysis objects.
%   <a href="matlab:help ao/acos">ao/acos</a>                     -  overloads the acos method for analysis objects.
%   <a href="matlab:help ao/all">ao/all</a>                      -  overloads the all operator for analysis objects. True if all elements 
%   <a href="matlab:help ao/and">ao/and</a>                      -  (&) overloads the and (&) method for analysis objects.
%   <a href="matlab:help ao/angle">ao/angle</a>                    -  overloads the angle operator for analysis objects.
%   <a href="matlab:help ao/any">ao/any</a>                      -  overloads the any operator for analysis objects. True if any element 
%   <a href="matlab:help ao/ao">ao/ao</a>                       -  analysis object class constructor.
%   <a href="matlab:help ao/ao2numMatrices">ao/ao2numMatrices</a>           -  transforms AO objects to numerical matrices.
%   <a href="matlab:help ao/applymethod">ao/applymethod</a>              -  to the analysis object
%   <a href="matlab:help ao/applyoperator">ao/applyoperator</a>            -  to the analysis object
%   <a href="matlab:help ao/asin">ao/asin</a>                     -  overloads the asin method for analysis objects.
%   <a href="matlab:help ao/atan">ao/atan</a>                     -  overloads the atan method for analysis objects.
%   <a href="matlab:help ao/atan2">ao/atan2</a>                    -  overloads the atan2 operator for analysis objects. Four quadrant inverse tangent.
%   <a href="matlab:help ao/attachToDom">ao/attachToDom</a>              - % Create empty ao node with the attribute 'shape'
%   <a href="matlab:help ao/average">ao/average</a>                  -  averages aos point-by-point
%   <a href="matlab:help ao/bandpass">ao/bandpass</a>                 -  AOs containing time-series data.
%   <a href="matlab:help ao/bandreject">ao/bandreject</a>               -  AOs containing time-series data.
%   <a href="matlab:help ao/bicohere">ao/bicohere</a>                 -  computes the bicoherence of two input time-series
%   <a href="matlab:help ao/bilinfit">ao/bilinfit</a>                 -  is a linear fitting tool
%   <a href="matlab:help ao/bin_data">ao/bin_data</a>                 -  rebins aos data, on logarithmic scale, linear scale, or arbitrarly chosen.
%   <a href="matlab:help ao/blrms">ao/blrms</a>                    -  computes band-limited RMS trends of the input time-series.
%   <a href="matlab:help ao/buildWhitener1D">ao/buildWhitener1D</a>          -  builds a whitening filter based on the input frequency-series.
%   <a href="matlab:help ao/cast">ao/cast</a>                     -  - converts the numeric values in an AO to the data type specified by type.
%   <a href="matlab:help ao/cat">ao/cat</a>                      -  concatenate AOs into a row vector.
%   <a href="matlab:help ao/cdfplot">ao/cdfplot</a>                  -  makes cumulative distribution plot
%   <a href="matlab:help ao/cgfill">ao/cgfill</a>                   -  fills specified gaps in the data given an inital guess for the spectrum.
%   <a href="matlab:help ao/char">ao/char</a>                     -  overloads char() function for analysis objects.
%   <a href="matlab:help ao/checkDataType">ao/checkDataType</a>            -  Throws an error for AOs with a specified data-type.
%   <a href="matlab:help ao/checkNumericDataTypes">ao/checkNumericDataTypes</a>    -  Throws an error for AOs if the numeric data types doesn't match to an AO method.
%   <a href="matlab:help ao/checkTimestamps">ao/checkTimestamps</a>          -  performs a check on the timestamps of the input AOs.
%   <a href="matlab:help ao/clearErrors">ao/clearErrors</a>              - % Set units
%   <a href="matlab:help ao/cohere">ao/cohere</a>                   -  estimates the coherence between time-series objects
%   <a href="matlab:help ao/complex">ao/complex</a>                  -  overloads the complex operator for Analysis objects.
%   <a href="matlab:help ao/compute">ao/compute</a>                  -  performs the given operations on the input AOs.
%   <a href="matlab:help ao/computeDFT">ao/computeDFT</a>               -  Computes DFT using FFT or Goertzel
%   <a href="matlab:help ao/computeperiodogram">ao/computeperiodogram</a>       -    Periodogram spectral estimation.
%   <a href="matlab:help ao/confint">ao/confint</a>                  -  Calculates confidence levels and variance for psd, lpsd, cohere, lcohere and curvefit parameters
%   <a href="matlab:help ao/conj">ao/conj</a>                     -  overloads the conjugate operator for analysis objects.
%   <a href="matlab:help ao/consolidate">ao/consolidate</a>              -  resamples all input AOs onto the same time grid.
%   <a href="matlab:help ao/conv">ao/conv</a>                     -  vector convolution.
%   <a href="matlab:help ao/conv_noisegen">ao/conv_noisegen</a>            -  calls the matlab function conv.m to convolute poles and zeros from a given pzmodel
%   <a href="matlab:help ao/convert">ao/convert</a>                  -  perform various conversions on the ao.
%   <a href="matlab:help ao/copy">ao/copy</a>                     -  makes a (deep) copy of the input AOs.
%   <a href="matlab:help ao/corr">ao/corr</a>                     -  estimate linear correlation coefficients.
%   <a href="matlab:help ao/cos">ao/cos</a>                      -  overloads the cos method for analysis objects.
%   <a href="matlab:help ao/cov">ao/cov</a>                      -  estimate covariance of data streams.
%   <a href="matlab:help ao/cpsd">ao/cpsd</a>                     -  estimates the cross-spectral density between time-series objects
%   <a href="matlab:help ao/crb">ao/crb</a>                      -  computes the inverse of the Fisher Matrix
%   <a href="matlab:help ao/crbound">ao/crbound</a>                  -  computes the inverse of the Fisher Matrix
%   <a href="matlab:help ao/csvGenerateData">ao/csvGenerateData</a>          -  Default method to convert a analysis object into csv data.
%   <a href="matlab:help ao/ctranspose">ao/ctranspose</a>               -  overloads the ' operator for Analysis Objects.
%   <a href="matlab:help ao/cumsum">ao/cumsum</a>                   -  overloads the cumsum operator for analysis objects.
%   <a href="matlab:help ao/delay">ao/delay</a>                    -  delays a time-series using various methods.
%   <a href="matlab:help ao/delayEstimate">ao/delayEstimate</a>            -  estimates the delay between two AOs
%   <a href="matlab:help ao/delay_fractional_core">ao/delay_fractional_core</a>    -  core method to implement fractional delay
%   <a href="matlab:help ao/demux">ao/demux</a>                    -  splits the input vector of AOs into a number of output AOs.
%   <a href="matlab:help ao/det">ao/det</a>                      -  overloads the determinant function for analysis objects.
%   <a href="matlab:help ao/detectOutliers">ao/detectOutliers</a>           -  locates outliers in data.
%   <a href="matlab:help ao/detrend">ao/detrend</a>                  -  detrends the input analysis object using a polynomial of degree N.
%   <a href="matlab:help ao/dft">ao/dft</a>                      -  computes the DFT of the input time-series at the requested frequencies.
%   <a href="matlab:help ao/diag">ao/diag</a>                     -  overloads the diagonal operator for analysis objects.
%   <a href="matlab:help ao/diff">ao/diff</a>                     -  differentiates the data in AO.
%   <a href="matlab:help ao/diff2p_core">ao/diff2p_core</a>              - (No help available)
%   <a href="matlab:help ao/diff3p_core">ao/diff3p_core</a>              - (No help available)
%   <a href="matlab:help ao/diff5p_core">ao/diff5p_core</a>              - (No help available)
%   <a href="matlab:help ao/disp">ao/disp</a>                     -  implement terminal display for analysis object.
%   <a href="matlab:help ao/dispersionLoop">ao/dispersionLoop</a>           - dipersionLoop computes the dispersion function in loop
%   <a href="matlab:help ao/double">ao/double</a>                   -  overloads double() function for analysis objects.
%   <a href="matlab:help ao/downsample">ao/downsample</a>               -  decimate AOs by an integer factor.
%   <a href="matlab:help ao/dropduplicates">ao/dropduplicates</a>           -  drops all duplicate samples in time-series AOs.
%   <a href="matlab:help ao/dsmean">ao/dsmean</a>                   -  performs a simple downsampling by taking the mean of every N samples.
%   <a href="matlab:help ao/dtfe">ao/dtfe</a>                     -  estimates transfer function between time-series objects.
%   <a href="matlab:help ao/dx">ao/dx</a>                       -  Get the data property 'dx'.
%   <a href="matlab:help ao/dy">ao/dy</a>                       -  Get the data property 'dy'.
%   <a href="matlab:help ao/dz">ao/dz</a>                       - DX Get the data property 'dz'.
%   <a href="matlab:help ao/ecdf">ao/ecdf</a>                     -  calculate empirical cumulative distribution function
%   <a href="matlab:help ao/edgedetect">ao/edgedetect</a>               -  detects edges in a binary pulse-train.
%   <a href="matlab:help ao/eig">ao/eig</a>                      -  overloads the eigenvalues/eigenvectors function for analysis objects.
%   <a href="matlab:help ao/elementOp">ao/elementOp</a>                -  applies the given operator to the data.
%   <a href="matlab:help ao/eq">ao/eq</a>                       -  overloads == operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/eqmotion">ao/eqmotion</a>                 -  solves numerically a given linear equation of motion
%   <a href="matlab:help ao/evaluateModel">ao/evaluateModel</a>            -  evaluate a curvefit model.
%   <a href="matlab:help ao/exp">ao/exp</a>                      -  overloads the exp operator for analysis objects. Exponential.
%   <a href="matlab:help ao/export">ao/export</a>                   -  export the data of an analysis object to a text file.
%   <a href="matlab:help ao/fft">ao/fft</a>                      -  overloads the fft method for Analysis objects.
%   <a href="matlab:help ao/fft_1sided_core">ao/fft_1sided_core</a>          - (No help available)
%   <a href="matlab:help ao/fft_2sided_core">ao/fft_2sided_core</a>          - (No help available)
%   <a href="matlab:help ao/fft_core">ao/fft_core</a>                 -  Simple core method which computes the fft.
%   <a href="matlab:help ao/fftfilt">ao/fftfilt</a>                  -  overrides the fft filter function for analysis objects.
%   <a href="matlab:help ao/fftfilt_core">ao/fftfilt_core</a>             -  Simple core method which computes the fft filter.
%   <a href="matlab:help ao/filtSubtract">ao/filtSubtract</a>             -  subtracts a frequency dependent noise contribution from an input ao.
%   <a href="matlab:help ao/filter">ao/filter</a>                   -  overrides the filter function for analysis objects.
%   <a href="matlab:help ao/filtfilt">ao/filtfilt</a>                 -  overrides the filtfilt function for analysis objects.
%   <a href="matlab:help ao/find">ao/find</a>                     -  particular samples that satisfy the input query and return a new AO.
%   <a href="matlab:help ao/findFsMax">ao/findFsMax</a>                -  Returns the max Fs of a set of AOs
%   <a href="matlab:help ao/findFsMin">ao/findFsMin</a>                -  Returns the min Fs of a set of AOs
%   <a href="matlab:help ao/findShortestVector">ao/findShortestVector</a>       -  Returns the length of the shortest vector in samples
%   <a href="matlab:help ao/firwhiten">ao/firwhiten</a>                -  whitens the input time-series by building an FIR whitening filter.
%   <a href="matlab:help ao/fixAxisData">ao/fixAxisData</a>              -  up the data type according to the users chosen axis
%   <a href="matlab:help ao/fixfs">ao/fixfs</a>                    -  resamples the input time-series to have a fixed sample rate.
%   <a href="matlab:help ao/flscov">ao/flscov</a>                   -  - Tool to perform a least square fit in frequency domain.
%   <a href="matlab:help ao/fngen">ao/fngen</a>                    -  creates an arbitrarily long time-series based on the input PSD.
%   <a href="matlab:help ao/fq2fac">ao/fq2fac</a>                   -  is a private function and is called by ngconv.m which can be found in the
%   <a href="matlab:help ao/fromComplexDatafile">ao/fromComplexDatafile</a>      -  Construct an AO from filename AND parameter list
%   <a href="matlab:help ao/fromDataInMAT">ao/fromDataInMAT</a>            -  Convert a saved data-array into an AO with a tsdata-object
%   <a href="matlab:help ao/fromDatafile">ao/fromDatafile</a>             -  Construct an ao from filename AND parameter list
%   <a href="matlab:help ao/fromDom">ao/fromDom</a>                  - % Get shape
%   <a href="matlab:help ao/fromFSfcn">ao/fromFSfcn</a>                -  Construct an ao from a fs-function string
%   <a href="matlab:help ao/fromFcn">ao/fromFcn</a>                  -  Construct an ao from a function string
%   <a href="matlab:help ao/fromParameter">ao/fromParameter</a>            -  Construct an ao from a param object
%   <a href="matlab:help ao/fromPest">ao/fromPest</a>                 -  Construct a AO from a pest.
%   <a href="matlab:help ao/fromPolyval">ao/fromPolyval</a>              -  Construct an ao from polynomial coefficients
%   <a href="matlab:help ao/fromProcinfo">ao/fromProcinfo</a>             -  returns for a given key-name the value of the procinfo-plist
%   <a href="matlab:help ao/fromPzmodel">ao/fromPzmodel</a>              -  Construct a time-series ao from polynomial coefficients
%   <a href="matlab:help ao/fromSModel">ao/fromSModel</a>               -  Construct a AO from an smodel.
%   <a href="matlab:help ao/fromSpecWin">ao/fromSpecWin</a>              -  Construct an ao from a Spectral window
%   <a href="matlab:help ao/fromStruct">ao/fromStruct</a>               -  creates from a structure an analysis object.
%   <a href="matlab:help ao/fromTSfcn">ao/fromTSfcn</a>                -  Construct an ao from a ts-function string
%   <a href="matlab:help ao/fromVals">ao/fromVals</a>                 -  Construct an ao from a value set
%   <a href="matlab:help ao/fromWaveform">ao/fromWaveform</a>             -  Construct an ao from a waveform
%   <a href="matlab:help ao/fromXYFcn">ao/fromXYFcn</a>                -  Construct an ao from a function f(x) string
%   <a href="matlab:help ao/fromXYVals">ao/fromXYVals</a>               -  Construct an ao from a value set
%   <a href="matlab:help ao/fromXYZVals">ao/fromXYZVals</a>              -  Construct an ao from a value set
%   <a href="matlab:help ao/fs">ao/fs</a>                       -  Get the data property 'fs'.
%   <a href="matlab:help ao/gapfilling">ao/gapfilling</a>               -  fills possible gaps in data.
%   <a href="matlab:help ao/gapfillingoptim">ao/gapfillingoptim</a>          -  fills possible gaps in data.
%   <a href="matlab:help ao/ge">ao/ge</a>                       -  overloads >= operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/generateConstructorPlist">ao/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help ao/getAbsTimeRange">ao/getAbsTimeRange</a>          -  returns a timespan object which span the absolute time range of an AO
%   <a href="matlab:help ao/getCommonInterval">ao/getCommonInterval</a>        -  Estimates the common interval spun by a group of Analysis Objects
%   <a href="matlab:help ao/getGeneralInterval">ao/getGeneralInterval</a>       -  Estimates the maximum interval spun by a group of Analysis Objects
%   <a href="matlab:help ao/getKSCValPSD">ao/getKSCValPSD</a>             -  provides critical value for KStest on the PSD
%   <a href="matlab:help ao/getdof">ao/getdof</a>                   -  Calculates degrees of freedom for psd, lpsd, cohere and lcohere
%   <a href="matlab:help ao/gnuplot">ao/gnuplot</a>                  -  a gnuplot interface for AOs.
%   <a href="matlab:help ao/gt">ao/gt</a>                       -  overloads > operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/heterodyne">ao/heterodyne</a>               -  heterodynes time-series.
%   <a href="matlab:help ao/highpass">ao/highpass</a>                 -  highpass AOs containing time-series data.
%   <a href="matlab:help ao/hist">ao/hist</a>                     -  overloads the histogram function (hist) of MATLAB for Analysis Objects.
%   <a href="matlab:help ao/hypot">ao/hypot</a>                    -  overloads robust computation of the square root of the sum of squares for AOs.
%   <a href="matlab:help ao/iacf">ao/iacf</a>                     -  computes the inverse auto-correlation function from a spectrum.
%   <a href="matlab:help ao/ifft">ao/ifft</a>                     -  overloads the ifft operator for Analysis objects.
%   <a href="matlab:help ao/ifft_1sided_even_core">ao/ifft_1sided_even_core</a>    - (No help available)
%   <a href="matlab:help ao/ifft_1sided_odd_core">ao/ifft_1sided_odd_core</a>     - (No help available)
%   <a href="matlab:help ao/ifft_2sided_core">ao/ifft_2sided_core</a>         - (No help available)
%   <a href="matlab:help ao/ifft_core">ao/ifft_core</a>                -  Simple core method which computes the ifft.
%   <a href="matlab:help ao/ifft_plain_core">ao/ifft_plain_core</a>          - (No help available)
%   <a href="matlab:help ao/imag">ao/imag</a>                     -  overloads the imaginary operator for analysis objects.
%   <a href="matlab:help ao/integrate">ao/integrate</a>                -  integrates the data in AO.
%   <a href="matlab:help ao/interp">ao/interp</a>                   -  interpolate the values in the input AO(s) at new values.
%   <a href="matlab:help ao/interpmissing">ao/interpmissing</a>            -  interpolate missing samples in a time-series.
%   <a href="matlab:help ao/intersect">ao/intersect</a>                -  overloads the intersect operator for Analysis objects.
%   <a href="matlab:help ao/inv">ao/inv</a>                      -  overloads the inverse function for analysis objects.
%   <a href="matlab:help ao/iplot">ao/iplot</a>                    -  provides an intelligent plotting tool for LTPDA.
%   <a href="matlab:help ao/iplotyy">ao/iplotyy</a>                  -  provides an intelligent plotting tool for LTPDA.
%   <a href="matlab:help ao/join">ao/join</a>                     -  multiple AOs into a single AO.
%   <a href="matlab:help ao/kstest">ao/kstest</a>                   -  perform KS test on input AOs
%   <a href="matlab:help ao/lcohere">ao/lcohere</a>                  -  implement magnitude-squadred coherence estimation on a log frequency axis.
%   <a href="matlab:help ao/lcpsd">ao/lcpsd</a>                    -  implement cross-power-spectral density estimation on a log frequency axis.
%   <a href="matlab:help ao/le">ao/le</a>                       -  overloads <= operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/len">ao/len</a>                      -  overloads the length operator for Analysis objects. Length of the data samples.
%   <a href="matlab:help ao/linSubtract">ao/linSubtract</a>              -  subtracts a linear contribution from an input ao.
%   <a href="matlab:help ao/lincom">ao/lincom</a>                   -  make a linear combination of analysis objects
%   <a href="matlab:help ao/linedetect">ao/linedetect</a>               -  find spectral lines in the ao/fsdata objects.
%   <a href="matlab:help ao/linfit">ao/linfit</a>                   -  is a linear fitting tool
%   <a href="matlab:help ao/linlsqsvd">ao/linlsqsvd</a>                -  Linear least squares with singular value decomposition
%   <a href="matlab:help ao/lisovfit">ao/lisovfit</a>                 -  uses LISO to fit a pole/zero model to the input frequency-series.
%   <a href="matlab:help ao/ln">ao/ln</a>                       -  overloads the log operator for analysis objects. Natural logarithm.
%   <a href="matlab:help ao/loadobj">ao/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help ao/log">ao/log</a>                      -  overloads the log operator for analysis objects. Natural logarithm.
%   <a href="matlab:help ao/log10">ao/log10</a>                    -  overloads the log10 operator for analysis objects. Common (base 10) logarithm.
%   <a href="matlab:help ao/logical">ao/logical</a>                  -  overloads logical() function for analysis objects.
%   <a href="matlab:help ao/lowpass">ao/lowpass</a>                  -  lowpass AOs containing time-series data.
%   <a href="matlab:help ao/lpsd">ao/lpsd</a>                     -  implements the LPSD algorithm for analysis objects.
%   <a href="matlab:help ao/lscov">ao/lscov</a>                    -  is a wrapper for MATLAB's lscov function.
%   <a href="matlab:help ao/lsf">ao/lsf</a>                      - --------------------------------------------------------------------------
%   <a href="matlab:help ao/lt">ao/lt</a>                       -  overloads < operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/ltf_plan">ao/ltf_plan</a>                 -  computes all input values needed for the LPSD and LTFE algorithms.
%   <a href="matlab:help ao/ltfe">ao/ltfe</a>                     -  implements transfer function estimation computed on a log frequency axis.
%   <a href="matlab:help ao/lxspec">ao/lxspec</a>                   -  performs log-scale cross-spectral analysis of various forms.
%   <a href="matlab:help ao/map3D">ao/map3D</a>                    -  maps the input 1 or 2D AOs on to a 3D AO
%   <a href="matlab:help ao/max">ao/max</a>                      -  computes the maximum value of the data in the AO
%   <a href="matlab:help ao/mchol">ao/mchol</a>                    - (No help available)
%   <a href="matlab:help ao/mcmc">ao/mcmc</a>                     -  estimates paramters using a Monte Carlo Markov Chain.
%   <a href="matlab:help ao/md5">ao/md5</a>                      -  computes an MD5 checksum from an analysis objects.
%   <a href="matlab:help ao/mean">ao/mean</a>                     -  computes the mean value of the data in the AO.
%   <a href="matlab:help ao/median">ao/median</a>                   -  computes the median value of the data in the AO.
%   <a href="matlab:help ao/melementOp">ao/melementOp</a>               -  applies the given matrix operator to the data.
%   <a href="matlab:help ao/min">ao/min</a>                      -  computes the minimum value of the data in the AO
%   <a href="matlab:help ao/minus">ao/minus</a>                    -  implements subtraction operator for analysis objects.
%   <a href="matlab:help ao/mlpsd_m">ao/mlpsd_m</a>                  -  m-file only version of the LPSD algorithm
%   <a href="matlab:help ao/mlpsd_mex">ao/mlpsd_mex</a>                -  calls the ltpda_dft.mex to compute the DFT part of the LPSD algorithm
%   <a href="matlab:help ao/mltfe">ao/mltfe</a>                    -  compute log-frequency space TF
%   <a href="matlab:help ao/mod">ao/mod</a>                      -  overloads the modulus function for analysis objects.
%   <a href="matlab:help ao/mode">ao/mode</a>                     -  computes the modal value of the data in the AO.
%   <a href="matlab:help ao/modelSelect">ao/modelSelect</a>              -  method to compute the Bayes Factor using RJMCMC, LF, LM, BIC methods
%   <a href="matlab:help ao/mpower">ao/mpower</a>                   -  implements mpower operator for analysis objects.
%   <a href="matlab:help ao/mrdivide">ao/mrdivide</a>                 -  implements mrdivide operator for analysis objects.
%   <a href="matlab:help ao/mtimes">ao/mtimes</a>                   -  implements mtimes operator for analysis objects.
%   <a href="matlab:help ao/mve">ao/mve</a>                      - MVE: Minimum Volume Ellipsoid estimator
%   <a href="matlab:help ao/ne">ao/ne</a>                       -  overloads ~= operator for analysis objects. Compare the y-axis values.
%   <a href="matlab:help ao/ngconv">ao/ngconv</a>                   -  is called by the function fromPzmodel
%   <a href="matlab:help ao/nginit">ao/nginit</a>                   -  is called by the function fromPzmodel
%   <a href="matlab:help ao/ngprop">ao/ngprop</a>                   -  is called by the function fromPzmodel
%   <a href="matlab:help ao/ngsetup">ao/ngsetup</a>                  -  is called by the function fromPzmodel
%   <a href="matlab:help ao/ngsetup_vpa">ao/ngsetup_vpa</a>              - % ALGONAME = mfilename;
%   <a href="matlab:help ao/noisePower">ao/noisePower</a>               -  computes the noise power spectral density in a time-series as a function of time.
%   <a href="matlab:help ao/noisegen1D">ao/noisegen1D</a>               -  generates colored noise from white noise.
%   <a href="matlab:help ao/noisegen2D">ao/noisegen2D</a>               -  generates cross correleted colored noise from white noise.
%   <a href="matlab:help ao/norm">ao/norm</a>                     -  overloads the norm operator for analysis objects.
%   <a href="matlab:help ao/normdist">ao/normdist</a>                 -  computes the equivalent normal distribution for the data.
%   <a href="matlab:help ao/not">ao/not</a>                      -  overloads the logical not operator for analysis objects.
%   <a href="matlab:help ao/nsecs">ao/nsecs</a>                    -  Get the data property 'nsecs'.
%   <a href="matlab:help ao/nyquistplot">ao/nyquistplot</a>              -  fits a piecewise powerlaw to the given data.
%   <a href="matlab:help ao/offset">ao/offset</a>                   -  adds an offset to the data in the AO.
%   <a href="matlab:help ao/or">ao/or</a>                       -  (|) overloads the or (|) method for Analysis objects.
%   <a href="matlab:help ao/overlap">ao/overlap</a>                  -  This method cuts out the the overlapping data of the input AOs.
%   <a href="matlab:help ao/pad">ao/pad</a>                      -  pads the input data series to a given value.
%   <a href="matlab:help ao/performFFTcore">ao/performFFTcore</a>           -  performs fft for flscov and flscovSegments
%   <a href="matlab:help ao/phase">ao/phase</a>                    -  is the phase operator for analysis objects.
%   <a href="matlab:help ao/play">ao/play</a>                     -  plays a time-series using MATLAB's audioplay function.
%   <a href="matlab:help ao/plot">ao/plot</a>                     -  the analysis objects on the given axes.
%   <a href="matlab:help ao/plus">ao/plus</a>                     -  implements addition operator for analysis objects.
%   <a href="matlab:help ao/polyfit">ao/polyfit</a>                  -  overloads polyfit() function of MATLAB for Analysis Objects.
%   <a href="matlab:help ao/polyfitSpectrum">ao/polyfitSpectrum</a>          -  does a polynomial fit to the log of the input spectrum.
%   <a href="matlab:help ao/polynomfit">ao/polynomfit</a>               -  is a polynomial fitting tool
%   <a href="matlab:help ao/power">ao/power</a>                    -  implements power operator for analysis objects.
%   <a href="matlab:help ao/powerFit">ao/powerFit</a>                 -  fits a piecewise powerlaw to the given data.
%   <a href="matlab:help ao/ppsd">ao/ppsd</a>                     -  makes power spectral density estimates of the time-series objects in the input analysis objects by estimating ARMA models coefficients.
%   <a href="matlab:help ao/preprocessDataForMCMC">ao/preprocessDataForMCMC</a>    -  Split, resample and apply FFT to time series for MCMC analysis.
%   <a href="matlab:help ao/processSetterValues">ao/processSetterValues</a>      - (No help available)
%   <a href="matlab:help ao/psd">ao/psd</a>                      -  makes power spectral density estimates of the time-series objects
%   <a href="matlab:help ao/psdconf">ao/psdconf</a>                  -  Calculates confidence levels and variance for psd
%   <a href="matlab:help ao/psdvfit">ao/psdvfit</a>                  -  performs a fitting loop to identify model for a psd.
%   <a href="matlab:help ao/qqplot">ao/qqplot</a>                   -  makes quantile-quantile plot
%   <a href="matlab:help ao/quasiSweptSine">ao/quasiSweptSine</a>           -  computes a transfer function from swept-sine measurements
%   <a href="matlab:help ao/rdivide">ao/rdivide</a>                  -  implements division operator for analysis objects.
%   <a href="matlab:help ao/real">ao/real</a>                     -  overloads the real operator for analysis objects.
%   <a href="matlab:help ao/removeVal">ao/removeVal</a>                -  removes values from the input AO(s).
%   <a href="matlab:help ao/resample">ao/resample</a>                 -  overloads resample function for AOs.
%   <a href="matlab:help ao/resampleToCommonGrid">ao/resampleToCommonGrid</a>     -  Resamples Analysis Objects to a common grid
%   <a href="matlab:help ao/rjsample">ao/rjsample</a>                 -  Reverse Jump MCMC sampling using the "Metropolized Carlin And Chib" Method.
%   <a href="matlab:help ao/rms">ao/rms</a>                      -  Calculate RMS deviation from spectrum
%   <a href="matlab:help ao/rotate">ao/rotate</a>                   -  applies rotation factor to AOs
%   <a href="matlab:help ao/round">ao/round</a>                    -  overloads the Round method for analysis objects.
%   <a href="matlab:help ao/sDomainFit">ao/sDomainFit</a>               -  performs a fitting loop to identify model order and
%   <a href="matlab:help ao/scale">ao/scale</a>                    -  scales the data in the AO by the specified factor.
%   <a href="matlab:help ao/scatter3D">ao/scatter3D</a>                -  Creates from the y-values of the input AOs a new AO with a xyz-data object
%   <a href="matlab:help ao/scatterData">ao/scatterData</a>              -  Creates from the y-values of two input AOs an new AO(xydata)
%   <a href="matlab:help ao/select">ao/select</a>                   -  select particular samples from the input AOs and return new AOs with only those samples.
%   <a href="matlab:help ao/setData">ao/setData</a>                  -  sets the 'data' property of the ao.
%   <a href="matlab:help ao/setDx">ao/setDx</a>                    -  sets the 'dx' property of the ao.
%   <a href="matlab:help ao/setDy">ao/setDy</a>                    -  sets the 'dy' property of the ao.
%   <a href="matlab:help ao/setDz">ao/setDz</a>                    -  sets the 'dz' property of the ao.
%   <a href="matlab:help ao/setEnbw">ao/setEnbw</a>                  -  sets the 'enbw' property of the ao/fsdata.
%   <a href="matlab:help ao/setFs">ao/setFs</a>                    -  sets the 'fs' property of the ao.
%   <a href="matlab:help ao/setNavs">ao/setNavs</a>                  -  sets the 'navs' property of the ao/fsdata.
%   <a href="matlab:help ao/setReferenceTime">ao/setReferenceTime</a>         -  sets the t0 to the new value but doesn't move the data in time
%   <a href="matlab:help ao/setT0">ao/setT0</a>                    -  sets the 't0' property of the ao.
%   <a href="matlab:help ao/setToffset">ao/setToffset</a>               -  sets the 'toffset' property of the ao with tsdata
%   <a href="matlab:help ao/setUnitsForAxis">ao/setUnitsForAxis</a>          - % Set units
%   <a href="matlab:help ao/setX">ao/setX</a>                     -  sets the 'x' property of the ao.
%   <a href="matlab:help ao/setXY">ao/setXY</a>                    -  sets the 'x' and 'y' properties of the ao.
%   <a href="matlab:help ao/setXaxisName">ao/setXaxisName</a>             -  sets the x-axis name of the ao.
%   <a href="matlab:help ao/setXunits">ao/setXunits</a>                -  sets the 'xunits' property of the ao.
%   <a href="matlab:help ao/setY">ao/setY</a>                     -  sets the 'y' property of the ao.
%   <a href="matlab:help ao/setYaxisName">ao/setYaxisName</a>             -  sets the y-axis name of the ao.
%   <a href="matlab:help ao/setYunits">ao/setYunits</a>                -  sets the 'yunits' property of the ao.
%   <a href="matlab:help ao/setZ">ao/setZ</a>                     -  sets the 'z' property of the ao.
%   <a href="matlab:help ao/setZaxisName">ao/setZaxisName</a>             -  sets the z-axis name of the ao.
%   <a href="matlab:help ao/setZunits">ao/setZunits</a>                -  sets the 'zunits' property of the ao.
%   <a href="matlab:help ao/sign">ao/sign</a>                     -  overloads the sign operator for analysis objects.
%   <a href="matlab:help ao/simplex">ao/simplex</a>                  -  Multidimensional unconstrained nonlinear minimization (Nelder-Mead)
%   <a href="matlab:help ao/simplifyXunits">ao/simplifyXunits</a>           -  simplify the 'xunits' of the ao.
%   <a href="matlab:help ao/simplifyYunits">ao/simplifyYunits</a>           -  simplify the 'yunits' property of the ao.
%   <a href="matlab:help ao/simplifyZunits">ao/simplifyZunits</a>           -  simplify the 'zunits' of the ao.
%   <a href="matlab:help ao/sin">ao/sin</a>                      -  overloads the sin method for analysis objects.
%   <a href="matlab:help ao/sineParams">ao/sineParams</a>               -  estimates parameters of sinusoids
%   <a href="matlab:help ao/smoother">ao/smoother</a>                 -  smooths a given series of data points using the specified method.
%   <a href="matlab:help ao/sort">ao/sort</a>                     -  the values in the AO.
%   <a href="matlab:help ao/spcorr">ao/spcorr</a>                   -  calculate Spearman Rank-Order Correlation Coefficient
%   <a href="matlab:help ao/spectrogram">ao/spectrogram</a>              -  computes a spectrogram of the given ao/tsdata.
%   <a href="matlab:help ao/spikecleaning">ao/spikecleaning</a>            -  detects and corrects possible spikes in analysis objects
%   <a href="matlab:help ao/split">ao/split</a>                    -  split an analysis object into the specified segments.
%   <a href="matlab:help ao/split_samples_core">ao/split_samples_core</a>       - (No help available)
%   <a href="matlab:help ao/spsd">ao/spsd</a>                     -  implements the smoothed (binned) PSD algorithm for analysis objects.
%   <a href="matlab:help ao/spsdSubtraction">ao/spsdSubtraction</a>          -  makes a sPSD-weighted least-square iterative fit
%   <a href="matlab:help ao/sqrt">ao/sqrt</a>                     -  computes the square root of the data in the AO.
%   <a href="matlab:help ao/stack">ao/stack</a>                    -  xydata.
%   <a href="matlab:help ao/std">ao/std</a>                      -  computes the standard deviation of the data in the AO.
%   <a href="matlab:help ao/subsData">ao/subsData</a>                 -  performs actions on ao objects.
%   <a href="matlab:help ao/sum">ao/sum</a>                      -  computes the sum of the data in the AO.
%   <a href="matlab:help ao/sumjoin">ao/sumjoin</a>                  -  sums time-series signals togther
%   <a href="matlab:help ao/summaryReport">ao/summaryReport</a>            -  generates an HTML report about the input objects.
%   <a href="matlab:help ao/svd">ao/svd</a>                      -  overloads the svd (singular value decomposition) function for analysis objects.
%   <a href="matlab:help ao/svd_fit">ao/svd_fit</a>                  -  estimates parameters for a linear model using SVD
%   <a href="matlab:help ao/t0">ao/t0</a>                       -  Get the data property 't0'.
%   <a href="matlab:help ao/table">ao/table</a>                    -  display the data from the AO in a table.
%   <a href="matlab:help ao/tan">ao/tan</a>                      -  overloads the tan method for analysis objects.
%   <a href="matlab:help ao/tdfit">ao/tdfit</a>                    -  fit a set of smodels to a set of input and output signals..
%   <a href="matlab:help ao/tfe">ao/tfe</a>                      -  estimates transfer function between time-series objects.
%   <a href="matlab:help ao/timeaverage">ao/timeaverage</a>              -  Averages time series intervals
%   <a href="matlab:help ao/times">ao/times</a>                    -  implements multiplication operator for analysis objects.
%   <a href="matlab:help ao/timeshift">ao/timeshift</a>                -  for AO/tsdata objects, shifts data in time by the specified value in seconds.
%   <a href="matlab:help ao/toSI">ao/toSI</a>                     -  converts the units of the x, y and z axes into SI units.
%   <a href="matlab:help ao/toffset">ao/toffset</a>                  -  Get the data property 'toffset'.
%   <a href="matlab:help ao/transpose">ao/transpose</a>                -  overloads the .' operator for Analysis Objects.
%   <a href="matlab:help ao/trends">ao/trends</a>                   -  computes the trend statistics of the input time-series.
%   <a href="matlab:help ao/truncate">ao/truncate</a>                 -  Splits Analysis Objects over a common timespan
%   <a href="matlab:help ao/uminus">ao/uminus</a>                   -  overloads the uminus operator for analysis objects.
%   <a href="matlab:help ao/union">ao/union</a>                    -  overloads the union operator for Analysis Objects.
%   <a href="matlab:help ao/unwrap">ao/unwrap</a>                   -  overloads the unwrap operator for analysis objects.
%   <a href="matlab:help ao/update_struct">ao/update_struct</a>            -  update the input structure to the current ltpda version
%   <a href="matlab:help ao/upsample">ao/upsample</a>                 -  overloads upsample function for AOs.
%   <a href="matlab:help ao/validate">ao/validate</a>                 -  checks that the input Analysis Object is reproducible and valid.
%   <a href="matlab:help ao/validateSpectrumMod">ao/validateSpectrumMod</a>      -  statistically validate a model for a psd.
%   <a href="matlab:help ao/var">ao/var</a>                      -  computes the variance of the data in the AO.
%   <a href="matlab:help ao/whiten1D">ao/whiten1D</a>                 -  whitens the input time-series.
%   <a href="matlab:help ao/whiten2D">ao/whiten2D</a>                 -  whiten the noise for two cross correlated time series.
%   <a href="matlab:help ao/window">ao/window</a>                   -  applies the specified window to the input time-series objects
%   <a href="matlab:help ao/wosa">ao/wosa</a>                     -  implements Welch's overlaped segmented averaging algorithm with
%   <a href="matlab:help ao/x">ao/x</a>                        -  Get the data property 'x'.
%   <a href="matlab:help ao/xaxisname">ao/xaxisname</a>                -  Get the x axis name of the underlying data object.
%   <a href="matlab:help ao/xcorr">ao/xcorr</a>                    -  makes cross-correlation estimates of the time-series
%   <a href="matlab:help ao/xfit">ao/xfit</a>                     -  fit a function of x to data.
%   <a href="matlab:help ao/xor">ao/xor</a>                      -  overloads the xor (exclusive or) method for Analysis objects.
%   <a href="matlab:help ao/xspec">ao/xspec</a>                    -  performs cross-spectral analysis of various forms.
%   <a href="matlab:help ao/xunits">ao/xunits</a>                   -  Get the data property 'xunits'.
%   <a href="matlab:help ao/y">ao/y</a>                        -  Get the data property 'y'.
%   <a href="matlab:help ao/yaxisname">ao/yaxisname</a>                -  Get the y axis name of the underlying data object.
%   <a href="matlab:help ao/yunits">ao/yunits</a>                   -  Get the data property 'yunits'.
%   <a href="matlab:help ao/z">ao/z</a>                        -  Get the data property 'z'.
%   <a href="matlab:help ao/zDomainFit">ao/zDomainFit</a>               -  performs a fitting loop to identify model order and
%   <a href="matlab:help ao/zaxisname">ao/zaxisname</a>                -  Get the z axis name of the underlying data object.
%   <a href="matlab:help ao/zeropad">ao/zeropad</a>                  -  zero pads the input data series.
%   <a href="matlab:help ao/zeropad_post_core">ao/zeropad_post_core</a>        - (No help available)
%   <a href="matlab:help ao/zunits">ao/zunits</a>                   -  Get the data property 'zunits'.
%
%
%%%%%%%%%%%%%%%%%%%%   class: cdata   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help cdata/applymethod">cdata/applymethod</a>   -  applys the given method to the input cdata.
%   <a href="matlab:help cdata/applyoperator">cdata/applyoperator</a> -  applys the given operator to the two input data objects.
%   <a href="matlab:help cdata/attachToDom">cdata/attachToDom</a>   - % Create empty cdata node with the attribute 'shape'
%   <a href="matlab:help cdata/cdata">cdata/cdata</a>         -  is the constant data class.
%   <a href="matlab:help cdata/copy">cdata/copy</a>          -  makes a (deep) copy of the input cdata objects.
%   <a href="matlab:help cdata/disp">cdata/disp</a>          -  implement terminal display for cdata object.
%   <a href="matlab:help cdata/fromDom">cdata/fromDom</a>       - % Get shape
%   <a href="matlab:help cdata/fromStruct">cdata/fromStruct</a>    -  creates from a structure a CDATA object.
%   <a href="matlab:help cdata/loadobj">cdata/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help cdata/minus">cdata/minus</a>         -  implements subtraction operator for cdata objects.
%   <a href="matlab:help cdata/plot">cdata/plot</a>          -  plots the given cdata on the given axes
%   <a href="matlab:help cdata/plus">cdata/plus</a>          -  implements addition operator for cdata objects.
%   <a href="matlab:help cdata/rdivide">cdata/rdivide</a>       -  implements element division for cdata objects.
%   <a href="matlab:help cdata/times">cdata/times</a>         -  implements element multiplication for cdata objects.
%   <a href="matlab:help cdata/update_struct">cdata/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: collection   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help collection/addObjects">collection/addObjects</a>               -  adds the given objects to the collection.
%   <a href="matlab:help collection/attachToDom">collection/attachToDom</a>              - % Create empty collection node with the attribute 'shape'
%   <a href="matlab:help collection/char">collection/char</a>                     -  convert a collection object into a string.
%   <a href="matlab:help collection/cohere">collection/cohere</a>                   -  estimates the coherence between time-series objects in a collection object.
%   <a href="matlab:help collection/collection">collection/collection</a>               -  constructor for collection class.
%   <a href="matlab:help collection/copy">collection/copy</a>                     -  makes a (deep) copy of the input collection objects.
%   <a href="matlab:help collection/cpsd">collection/cpsd</a>                     -  estimates the cross-spectral density between time-series objects in a collection object.
%   <a href="matlab:help collection/disp">collection/disp</a>                     -  overloads display functionality for collection objects.
%   <a href="matlab:help collection/filter">collection/filter</a>                   -  overrides the filter function for analysis objects in a collection object.
%   <a href="matlab:help collection/filtfilt">collection/filtfilt</a>                 -  overrides the filtfilt function for analysis objects in a collection object.
%   <a href="matlab:help collection/fromDom">collection/fromDom</a>                  - % Get shape
%   <a href="matlab:help collection/fromInput">collection/fromInput</a>                - Construct a collection object from ltpda_uoh objects.
%   <a href="matlab:help collection/fromRepository">collection/fromRepository</a>           - Retrieve a ltpda_uo from a repository
%   <a href="matlab:help collection/fromStruct">collection/fromStruct</a>               -  creates from a structure a COLLECTION object.
%   <a href="matlab:help collection/generateConstructorPlist">collection/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help collection/getObjectAtIndex">collection/getObjectAtIndex</a>         -  index into the inner objects of one collection object.
%   <a href="matlab:help collection/getObjectByName">collection/getObjectByName</a>          -  returns an inside object selected by the name.
%   <a href="matlab:help collection/getObjectsOfClass">collection/getObjectsOfClass</a>        -  returns all objects of the specified class in a collection-object.
%   <a href="matlab:help collection/identifyInsideObjs">collection/identifyInsideObjs</a>       -  Static method which identify the inside objects and configuration PLISTs.
%   <a href="matlab:help collection/iplot">collection/iplot</a>                    -  calls ao/iplot on all inner ao objects.
%   <a href="matlab:help collection/lincom">collection/lincom</a>                   -  make a linear combination of objects within the collection
%   <a href="matlab:help collection/loadobj">collection/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help collection/nobjs">collection/nobjs</a>                    -  Returns the number of objects in the inner object array.
%   <a href="matlab:help collection/objTypes">collection/objTypes</a>                 -  returns a cell array of the class types for each object in the
%   <a href="matlab:help collection/plot">collection/plot</a>                     -  the collection objects.
%   <a href="matlab:help collection/plotTrends">collection/plotTrends</a>               -  plots the trend collections produced by ao/trends.
%   <a href="matlab:help collection/removeObjectAtIndex">collection/removeObjectAtIndex</a>      -  removes the object at the specified position from the collection.
%   <a href="matlab:help collection/saveAllObjects">collection/saveAllObjects</a>           -  index into the inner objects of one collection object.
%   <a href="matlab:help collection/setNames">collection/setNames</a>                 -  Sets the property 'names' of a collection object.
%   <a href="matlab:help collection/setObjectAtIndex">collection/setObjectAtIndex</a>         -  sets an input object to the collection.
%   <a href="matlab:help collection/setObjs">collection/setObjs</a>                  -  sets the 'objs' property of a collection object.
%   <a href="matlab:help collection/subsasgn">collection/subsasgn</a>                 -  overloads the setting behaviour for collection objects.
%   <a href="matlab:help collection/subsref">collection/subsref</a>                  -  overloads the referencing behaviour for collection objects.
%   <a href="matlab:help collection/summaryReport">collection/summaryReport</a>            -  generates an HTML report about the inner objects.
%   <a href="matlab:help collection/tfe">collection/tfe</a>                      -  estimates the transfer function between time-series objects in a collection object.
%   <a href="matlab:help collection/toCell">collection/toCell</a>                   -  toCells the objects in a collection and sets them to the given output
%   <a href="matlab:help collection/unpack">collection/unpack</a>                   -  unpacks the objects in a collection and sets them to the given output
%   <a href="matlab:help collection/update_struct">collection/update_struct</a>            -  update the input structure to the current ltpda version
%   <a href="matlab:help collection/wrapperEval">collection/wrapperEval</a>              - % loop over inner objects
%
%
%%%%%%%%%%%%%%%%%%%%   class: data2D   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help data2D/applymethod">data2D/applymethod</a>        -  applys the given method to the input 2D data.
%   <a href="matlab:help data2D/applyoperator">data2D/applyoperator</a>      -  applys the given operator to the two input data objects.
%   <a href="matlab:help data2D/attachToDom">data2D/attachToDom</a>        - % Add xaxis
%   <a href="matlab:help data2D/cast">data2D/cast</a>               -  - converts the numeric values in a data2D object to a new data type.
%   <a href="matlab:help data2D/copy">data2D/copy</a>               -  copies all fields of the data2D class to the new object.
%   <a href="matlab:help data2D/data2D">data2D/data2D</a>             -  is the abstract base class for 2-dimensional data objects.
%   <a href="matlab:help data2D/disp">data2D/disp</a>               -  overloads display functionality for data2D objects.
%   <a href="matlab:help data2D/fromDom">data2D/fromDom</a>            - %%%%%%%%%% Call super-class
%   <a href="matlab:help data2D/fromStruct">data2D/fromStruct</a>         -  sets all properties which are defined in the data2D class from the structure to the input object.
%   <a href="matlab:help data2D/getDx">data2D/getDx</a>              -  Get the property 'dx'.
%   <a href="matlab:help data2D/getX">data2D/getX</a>               -  Get the property 'x'.
%   <a href="matlab:help data2D/getXunits">data2D/getXunits</a>          -  Get the property 'xunits' from the x-axis.
%   <a href="matlab:help data2D/plot">data2D/plot</a>               -  plots the given xydata on the given axes
%   <a href="matlab:help data2D/plus">data2D/plus</a>               -  implements addition operator for data2D objects.
%   <a href="matlab:help data2D/prepareForPlotting">data2D/prepareForPlotting</a> -  takes the input data object and returns a function
%   <a href="matlab:help data2D/setDx">data2D/setDx</a>              -  Set the property 'dx'.
%   <a href="matlab:help data2D/setErrorsFromPlist">data2D/setErrorsFromPlist</a> -  sets the errors from the plist based on the error
%   <a href="matlab:help data2D/setX">data2D/setX</a>               -  Set the property 'x'.
%   <a href="matlab:help data2D/setXY">data2D/setXY</a>              -  Set the property 'xy'.
%   <a href="matlab:help data2D/setXaxisName">data2D/setXaxisName</a>       -  Set the property 'x-axis name'.
%   <a href="matlab:help data2D/setXunits">data2D/setXunits</a>          -  Set the property 'xunits'.
%   <a href="matlab:help data2D/update_struct">data2D/update_struct</a>      -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: data3D   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help data3D/applymethod">data3D/applymethod</a>        -  applys the given method to the input 3D data.
%   <a href="matlab:help data3D/applyoperator">data3D/applyoperator</a>      -  applys the given operator to the two input data objects.
%   <a href="matlab:help data3D/attachToDom">data3D/attachToDom</a>        - % Add zaxis
%   <a href="matlab:help data3D/cast">data3D/cast</a>               -  - converts the numeric values in a data3D object to a new data type.
%   <a href="matlab:help data3D/char">data3D/char</a>               -  convert a ltpda_data-object into a string.
%   <a href="matlab:help data3D/copy">data3D/copy</a>               -  copies all fields of the data3D class to the new object.
%   <a href="matlab:help data3D/data3D">data3D/data3D</a>             -  is the abstract base class for 3-dimensional data objects.
%   <a href="matlab:help data3D/disp">data3D/disp</a>               -  overloads display functionality for data3D objects.
%   <a href="matlab:help data3D/fromDom">data3D/fromDom</a>            - %%%%%%%%%% Call super-class
%   <a href="matlab:help data3D/fromStruct">data3D/fromStruct</a>         -  sets all properties which are defined in the data3D class from the structure to the input object.
%   <a href="matlab:help data3D/getDz">data3D/getDz</a>              -  Get the property 'dz'.
%   <a href="matlab:help data3D/getZ">data3D/getZ</a>               -  Get the property 'z'.
%   <a href="matlab:help data3D/getZunits">data3D/getZunits</a>          -  Get the property 'zunits' from the z-axis.
%   <a href="matlab:help data3D/plus">data3D/plus</a>               -  implements addition operator for data3D objects.
%   <a href="matlab:help data3D/setDz">data3D/setDz</a>              -  Set the property 'dz'.
%   <a href="matlab:help data3D/setErrorsFromPlist">data3D/setErrorsFromPlist</a> -  sets the errors from the plist based on the error
%   <a href="matlab:help data3D/setZ">data3D/setZ</a>               -  Set the property 'z'.
%   <a href="matlab:help data3D/setZaxisName">data3D/setZaxisName</a>       -  Set the property 'z-axis name'.
%   <a href="matlab:help data3D/setZunits">data3D/setZunits</a>          -  Set the property 'zunits'.
%   <a href="matlab:help data3D/update_struct">data3D/update_struct</a>      -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: filterbank   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help filterbank/addFilters">filterbank/addFilters</a>               -  This method adds a filter to the filterbank
%   <a href="matlab:help filterbank/attachToDom">filterbank/attachToDom</a>              - % Create empty filterbank node with the attribute 'shape'
%   <a href="matlab:help filterbank/char">filterbank/char</a>                     -  convert a filterbank object into a string.
%   <a href="matlab:help filterbank/copy">filterbank/copy</a>                     -  makes a (deep) copy of the input filterbank objects.
%   <a href="matlab:help filterbank/disp">filterbank/disp</a>                     -  overloads display functionality for filterbank objects.
%   <a href="matlab:help filterbank/filterbank">filterbank/filterbank</a>               -  constructor for filterbank class.
%   <a href="matlab:help filterbank/fromDom">filterbank/fromDom</a>                  - % Get shape
%   <a href="matlab:help filterbank/fromFilters">filterbank/fromFilters</a>              - (No help available)
%   <a href="matlab:help filterbank/fromStruct">filterbank/fromStruct</a>               -  creates from a structure a FILTERBANK object.
%   <a href="matlab:help filterbank/generateConstructorPlist">filterbank/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help filterbank/loadobj">filterbank/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help filterbank/resp">filterbank/resp</a>                     -  Make a frequency response of a filterbank.
%   <a href="matlab:help filterbank/setIunits">filterbank/setIunits</a>                -  sets the 'iunits' property of each filter-object inside the filterbank-object.
%   <a href="matlab:help filterbank/setOunits">filterbank/setOunits</a>                -  sets the 'ounits' property of each filter-object inside the filterbank-object.
%   <a href="matlab:help filterbank/update_struct">filterbank/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: fsdata   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help fsdata/attachToDom">fsdata/attachToDom</a>   - % Create empty fsdata node with the attribute 'shape'
%   <a href="matlab:help fsdata/char">fsdata/char</a>          -  convert a fsdata object into a string.
%   <a href="matlab:help fsdata/copy">fsdata/copy</a>          -  makes a (deep) copy of the input fsdata objects.
%   <a href="matlab:help fsdata/disp">fsdata/disp</a>          -  implement terminal display for fsdata object.
%   <a href="matlab:help fsdata/fromDom">fsdata/fromDom</a>       - % Get shape
%   <a href="matlab:help fsdata/fromStruct">fsdata/fromStruct</a>    -  creates from a structure a FSDATA object.
%   <a href="matlab:help fsdata/fsdata">fsdata/fsdata</a>        -  frequency-series object class constructor.
%   <a href="matlab:help fsdata/getFfromYFs">fsdata/getFfromYFs</a>   - GETDSFROMYFS grows an evenly spaced frequency vector of N points for samplerate fs.
%   <a href="matlab:help fsdata/loadobj">fsdata/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help fsdata/plot">fsdata/plot</a>          -  plots the given fsdata on the given axes
%   <a href="matlab:help fsdata/setEnbw">fsdata/setEnbw</a>       -  Set the property 'enbw'.
%   <a href="matlab:help fsdata/setFs">fsdata/setFs</a>         -  Set the property 'fs'.
%   <a href="matlab:help fsdata/setNavs">fsdata/setNavs</a>       -  Set the property 'navs'.
%   <a href="matlab:help fsdata/setT0">fsdata/setT0</a>         -  Set the property 't0'.
%   <a href="matlab:help fsdata/update_struct">fsdata/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: history   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help history/attachToDom">history/attachToDom</a>           - % Attach the history always to the historyRoot node
%   <a href="matlab:help history/char">history/char</a>                  -  convert a param object into a string.
%   <a href="matlab:help history/compressHistory">history/compressHistory</a>       -  returns an array of unique histories based on the input
%   <a href="matlab:help history/copy">history/copy</a>                  -  makes a (deep) copy of the input history objects.
%   <a href="matlab:help history/disp">history/disp</a>                  -  implement terminal display for history object.
%   <a href="matlab:help history/dotview">history/dotview</a>               -  view history of an object via the DOT interpreter.
%   <a href="matlab:help history/expandHistory">history/expandHistory</a>         - % fix history tree
%   <a href="matlab:help history/fromDom">history/fromDom</a>               - %  <historyRoot>
%   <a href="matlab:help history/fromStruct">history/fromStruct</a>            -  creates from a structure a HISTORY object.
%   <a href="matlab:help history/getAllUniqueHistories">history/getAllUniqueHistories</a> - % Collect the histories from the inhists
%   <a href="matlab:help history/getNodes">history/getNodes</a>              -  converts a history object to a nodes structure suitable for plotting as a tree.
%   <a href="matlab:help history/getObjectClass">history/getObjectClass</a>        -  get the class of object that this history refers to.
%   <a href="matlab:help history/hist2dot">history/hist2dot</a>              -  converts a history object to a 'DOT' file suitable for processing with graphviz
%   <a href="matlab:help history/hist2m">history/hist2m</a>                -  writes a new m-file that reproduces the analysis described in the history object.
%   <a href="matlab:help history/history">history/history</a>               -  History object class constructor.
%   <a href="matlab:help history/isequal">history/isequal</a>               -  overloads the isequal operator for ltpda history objects.
%   <a href="matlab:help history/loadobj">history/loadobj</a>               -  is called by the load function for user objects.
%   <a href="matlab:help history/rebuild">history/rebuild</a>               -  rebuilds the orignal object using the history.
%   <a href="matlab:help history/setContext">history/setContext</a>            -  set the context of object that this history refers to.
%   <a href="matlab:help history/setObjectClass">history/setObjectClass</a>        -  set the class of object that this history refers to.
%   <a href="matlab:help history/string">history/string</a>                -  writes a command string that can be used to recreate the input history object.
%   <a href="matlab:help history/update_struct">history/update_struct</a>         -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_algorithm   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_algorithm/ltpda_algorithm">ltpda_algorithm/ltpda_algorithm</a> -  is a superclass for algorithm classes.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_algorithm/tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_algorithm/tests/test_empty_constructor">ltpda_algorithm/tests/test_empty_constructor</a> - Tests that the emtpy constructor works and returns and object of the
%   <a href="matlab:help ltpda_algorithm/tests/test_rebuild">ltpda_algorithm/tests/test_rebuild</a>           - Tests that an object can be rebuilt.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_container   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_container/abs">ltpda_container/abs</a>             -  overloads the Absolute value method for analysis objects in a ltpda_container object.
%   <a href="matlab:help ltpda_container/conj">ltpda_container/conj</a>            -  implements conj operator for ltpda_container objects.
%   <a href="matlab:help ltpda_container/consolidate">ltpda_container/consolidate</a>     -  resamples all input AOs in a ltpda_container object onto the same time grid.
%   <a href="matlab:help ltpda_container/detrend">ltpda_container/detrend</a>         -  detrends the analysis objects in a ltpda_container object using a polynomial of degree N.
%   <a href="matlab:help ltpda_container/diff">ltpda_container/diff</a>            -  differentiates the data in a ltpda_container object.
%   <a href="matlab:help ltpda_container/downsample">ltpda_container/downsample</a>      -  downsamples each time-series AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/dsmean">ltpda_container/dsmean</a>          -  resamples each time-series AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/fft">ltpda_container/fft</a>             -  implements the fft operator for ltpda_container objects.
%   <a href="matlab:help ltpda_container/fixfs">ltpda_container/fixfs</a>           -  adjusts the sample frequency of each time-series AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/heterodyne">ltpda_container/heterodyne</a>      -  heterodynes time-series in a ltpda_container object.
%   <a href="matlab:help ltpda_container/interp">ltpda_container/interp</a>          -  interpolate the values of each AO in the ltpda_container at new values.
%   <a href="matlab:help ltpda_container/interpmissing">ltpda_container/interpmissing</a>   -  interpolate missing samples of each time-series AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/iplotPSD">ltpda_container/iplotPSD</a>        -  iplotPSD plots the sqrt of PSD AOs a ltpda_container object, including error bars
%   <a href="matlab:help ltpda_container/lpsd">ltpda_container/lpsd</a>            -  computes the log-scale PSD of the time-series AOs in a ltpda_container object.
%   <a href="matlab:help ltpda_container/ltpda_container">ltpda_container/ltpda_container</a> -  is the abstract ltpda class for ltpda multiple user object classes.
%   <a href="matlab:help ltpda_container/polyfit">ltpda_container/polyfit</a>         -  overloads polyfit() function of MATLAB for ltpda_container objects.
%   <a href="matlab:help ltpda_container/psd">ltpda_container/psd</a>             -  computes the PSD of the time-series in a ltpda_container object.
%   <a href="matlab:help ltpda_container/removeVal">ltpda_container/removeVal</a>       -  removes values from each AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/resample">ltpda_container/resample</a>        -  resamples each time-series AO in the ltpda_container.
%   <a href="matlab:help ltpda_container/search">ltpda_container/search</a>          -  selects objects inside the collection/matrix object that match the given name.
%   <a href="matlab:help ltpda_container/simplifyYunits">ltpda_container/simplifyYunits</a>  -  overloads the simplifyYunits value method for analysis objects in a ltpda_container object.
%   <a href="matlab:help ltpda_container/split">ltpda_container/split</a>           -  splits a ltpda_container object into the specified segments.
%   <a href="matlab:help ltpda_container/sqrt">ltpda_container/sqrt</a>            -  computes the sqrt of each object in the ltpda_container.
%   <a href="matlab:help ltpda_container/subsData">ltpda_container/subsData</a>        -  computes the SUBSDATA of the time-series in a ltpda_container object.
%   <a href="matlab:help ltpda_container/timeaverage">ltpda_container/timeaverage</a>     -  Averages time series intervals in a ltpda_container object.
%   <a href="matlab:help ltpda_container/toSI">ltpda_container/toSI</a>            -  overloads the toSI value method for analysis objects in a ltpda_container object.
%   <a href="matlab:help ltpda_container/uminus">ltpda_container/uminus</a>          -  overloads the uminus operator for all AOs in the ltpda_container.
%   <a href="matlab:help ltpda_container/wrapper">ltpda_container/wrapper</a>         -  applies the given method to each object in the object.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_data   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_data/attachToDom">ltpda_data/attachToDom</a>        - % Add yaxis
%   <a href="matlab:help ltpda_data/cast">ltpda_data/cast</a>               -  - converts the numeric values in a ltpda_data object to a new data type.
%   <a href="matlab:help ltpda_data/char">ltpda_data/char</a>               -  convert a ltpda_data object into a string.
%   <a href="matlab:help ltpda_data/copy">ltpda_data/copy</a>               -  copies all fields of the ltpda_data class to the new object.
%   <a href="matlab:help ltpda_data/fromDom">ltpda_data/fromDom</a>            - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_data/fromStruct">ltpda_data/fromStruct</a>         -  sets all properties which are defined in the ltpda_data class from the structure to the input object.
%   <a href="matlab:help ltpda_data/getDy">ltpda_data/getDy</a>              -  Get the property 'dy'.
%   <a href="matlab:help ltpda_data/getY">ltpda_data/getY</a>               -  Get the property 'y'.
%   <a href="matlab:help ltpda_data/getYunits">ltpda_data/getYunits</a>          -  Get the property 'yunits' from the y-axis.
%   <a href="matlab:help ltpda_data/ltpda_data">ltpda_data/ltpda_data</a>         -  is the abstract base class for ltpda data objects.
%   <a href="matlab:help ltpda_data/prepareForPlotting">ltpda_data/prepareForPlotting</a> -  takes the input data object and returns quantities for
%   <a href="matlab:help ltpda_data/setDy">ltpda_data/setDy</a>              -  Set the property 'dy'.
%   <a href="matlab:help ltpda_data/setErrorsFromPlist">ltpda_data/setErrorsFromPlist</a> -  sets the errors from the plist based on the error
%   <a href="matlab:help ltpda_data/setY">ltpda_data/setY</a>               -  Set the property 'y'.
%   <a href="matlab:help ltpda_data/setYaxisName">ltpda_data/setYaxisName</a>       -  Set the property 'y-axis name'.
%   <a href="matlab:help ltpda_data/setYunits">ltpda_data/setYunits</a>          -  Set the property 'yunits'.
%   <a href="matlab:help ltpda_data/update_struct">ltpda_data/update_struct</a>      -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_filter   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_filter/attachToDom">ltpda_filter/attachToDom</a>  - % Add fs
%   <a href="matlab:help ltpda_filter/conj">ltpda_filter/conj</a>         -  overloads conjugate functionality for ltpda_filter objects.
%   <a href="matlab:help ltpda_filter/copy">ltpda_filter/copy</a>         -  copies all fields of the ltpda_filter class to the new object.
%   <a href="matlab:help ltpda_filter/fromDom">ltpda_filter/fromDom</a>      - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_filter/fromStruct">ltpda_filter/fromStruct</a>   -  sets all properties which are defined in the ltpda_filter class from the structure to the input object.
%   <a href="matlab:help ltpda_filter/impresp">ltpda_filter/impresp</a>      -  Make an impulse response of the filter.
%   <a href="matlab:help ltpda_filter/ltpda_filter">ltpda_filter/ltpda_filter</a> -  is the abstract base class for ltpda filter objects.
%   <a href="matlab:help ltpda_filter/respCore">ltpda_filter/respCore</a>     -  returns the complex response of one miir or mfir object.
%   <a href="matlab:help ltpda_filter/setA">ltpda_filter/setA</a>         -  Set the property 'a'
%   <a href="matlab:help ltpda_filter/setFs">ltpda_filter/setFs</a>        -  Set the property 'fs' to a filter object
%   <a href="matlab:help ltpda_filter/setHistout">ltpda_filter/setHistout</a>   -  sets the 'histout' property of the filter object.
%   <a href="matlab:help ltpda_filter/setInfile">ltpda_filter/setInfile</a>    -  Set the property 'infile'
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_nuo   %%%%%%%%%%%%%%%%%%%%
%
%   ltpda_nuo/attachToDom - (No help available)
%   <a href="matlab:help ltpda_nuo/copy">ltpda_nuo/copy</a>        -  copies all fields of the ltpda_nuo class to the new object.
%   <a href="matlab:help ltpda_nuo/fromDom">ltpda_nuo/fromDom</a>     - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_nuo/fromStruct">ltpda_nuo/fromStruct</a>  -  sets all properties which are defined in the ltpda_nuo class from the structure to the input object.
%   <a href="matlab:help ltpda_nuo/ltpda_nuo">ltpda_nuo/ltpda_nuo</a>   -  is the abstract ltpda base class for ltpda non user object classes.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_obj   %%%%%%%%%%%%%%%%%%%%
%
%   ltpda_obj/attachToDom - (No help available)
%   <a href="matlab:help ltpda_obj/fromDom">ltpda_obj/fromDom</a>     - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_obj/fromStruct">ltpda_obj/fromStruct</a>  -  sets all properties which are defined in the ltpda_obj class from the structure to the input object.
%   <a href="matlab:help ltpda_obj/ge">ltpda_obj/ge</a>          -  overloads >= operator for ltpda objects
%   <a href="matlab:help ltpda_obj/get">ltpda_obj/get</a>         -  get a property of a object.
%   <a href="matlab:help ltpda_obj/gt">ltpda_obj/gt</a>          -  overloads > operator for ltpda objects
%   <a href="matlab:help ltpda_obj/isequal">ltpda_obj/isequal</a>     -  overloads the isequal operator for ltpda objects.
%   <a href="matlab:help ltpda_obj/isequalMain">ltpda_obj/isequalMain</a> -  checks if the inputs objects are equal or not.
%   <a href="matlab:help ltpda_obj/isprop">ltpda_obj/isprop</a>      -  tests if the given field is one of the object properties.
%   ltpda_obj/isprop_core - (No help available)
%   <a href="matlab:help ltpda_obj/le">ltpda_obj/le</a>          -  overloads <= operator for ltpda objects
%   <a href="matlab:help ltpda_obj/lt">ltpda_obj/lt</a>          -  overloads < operator for ltpda objects
%   <a href="matlab:help ltpda_obj/ltpda_obj">ltpda_obj/ltpda_obj</a>   -  is the abstract ltpda base class.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_tf   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_tf/attachToDom">ltpda_tf/attachToDom</a>   - % Add iunits
%   <a href="matlab:help ltpda_tf/copy">ltpda_tf/copy</a>          -  copies all fields of the ltpda_tf class to the new object.
%   <a href="matlab:help ltpda_tf/fromDom">ltpda_tf/fromDom</a>       - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_tf/fromStruct">ltpda_tf/fromStruct</a>    -  sets all properties which are defined in the ltpda_tf class from the structure to the input object.
%   <a href="matlab:help ltpda_tf/ltpda_tf">ltpda_tf/ltpda_tf</a>      -  is the abstract class which defines transfer functions.
%   <a href="matlab:help ltpda_tf/plot">ltpda_tf/plot</a>          -  the transfer function objects on the given axes.
%   <a href="matlab:help ltpda_tf/resp">ltpda_tf/resp</a>          -  returns the complex response of a transfer function as an Analysis Object.
%   <a href="matlab:help ltpda_tf/setIunits">ltpda_tf/setIunits</a>     -  sets the 'iunits' property a transfer function object.
%   <a href="matlab:help ltpda_tf/setOunits">ltpda_tf/setOunits</a>     -  sets the 'ounits' property a transfer function object.
%   <a href="matlab:help ltpda_tf/simplifyUnits">ltpda_tf/simplifyUnits</a> -  simplify the input units and/or output units of the object.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_uo   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_uo/attachToDom">ltpda_uo/attachToDom</a>           - % Add name
%   <a href="matlab:help ltpda_uo/bsubmit">ltpda_uo/bsubmit</a>               -  Submits the given collection of objects in binary form to an LTPDA repository
%   <a href="matlab:help ltpda_uo/convertSinfo2Plist">ltpda_uo/convertSinfo2Plist</a>    -  Converts the 'old' sinfo structure to a PLIST-object.
%   <a href="matlab:help ltpda_uo/copy">ltpda_uo/copy</a>                  -  copies all fields of the ltpda_uo class to the new object.
%   <a href="matlab:help ltpda_uo/fromComplexDatafile">ltpda_uo/fromComplexDatafile</a>   -  Default method to convert a complex data-file into a ltpda_uoh-object
%   <a href="matlab:help ltpda_uo/fromDataInMAT">ltpda_uo/fromDataInMAT</a>         -  Default method to convert a data-array into am ltpda_uoh
%   <a href="matlab:help ltpda_uo/fromDatafile">ltpda_uo/fromDatafile</a>          -  Default method to convert a data-file into a ltpda_uoh-object
%   <a href="matlab:help ltpda_uo/fromDom">ltpda_uo/fromDom</a>               - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_uo/fromFile">ltpda_uo/fromFile</a>              - Construct a ltpda_ob from a file
%   <a href="matlab:help ltpda_uo/fromLISO">ltpda_uo/fromLISO</a>              -  Default method to read LISO files
%   <a href="matlab:help ltpda_uo/fromModel">ltpda_uo/fromModel</a>             -  Construct an a built in model
%   <a href="matlab:help ltpda_uo/fromRepository">ltpda_uo/fromRepository</a>        - Retrieve a ltpda_uo from a repository
%   <a href="matlab:help ltpda_uo/fromStruct">ltpda_uo/fromStruct</a>            -  sets all properties which are defined in the ltpda_uo class from the structure to the input object.
%   <a href="matlab:help ltpda_uo/getBuiltInModels">ltpda_uo/getBuiltInModels</a>      -  returns a list of the built-in AO models found on the
%   <a href="matlab:help ltpda_uo/legendString">ltpda_uo/legendString</a>          -  returns a string suitable for use in plot legends.
%   <a href="matlab:help ltpda_uo/load">ltpda_uo/load</a>                  -  Loads LTPDA objects from a file
%   <a href="matlab:help ltpda_uo/ltpda_uo">ltpda_uo/ltpda_uo</a>              -  is the abstract ltpda base class for ltpda user object classes.
%   <a href="matlab:help ltpda_uo/prepareSinfoForSubmit">ltpda_uo/prepareSinfoForSubmit</a> -  With this method is it possible to modify the submission structure
%   <a href="matlab:help ltpda_uo/processSetterValues">ltpda_uo/processSetterValues</a>   - (No help available)
%   <a href="matlab:help ltpda_uo/retrieve">ltpda_uo/retrieve</a>              -  retrieves a collection of objects from an LTPDA repository.
%   <a href="matlab:help ltpda_uo/save">ltpda_uo/save</a>                  -  overloads save operator for ltpda objects.
%   <a href="matlab:help ltpda_uo/search">ltpda_uo/search</a>                -  select objects that match the given name.
%   <a href="matlab:help ltpda_uo/setDescription">ltpda_uo/setDescription</a>        -  sets the 'description' property of a ltpda_uo object.
%   <a href="matlab:help ltpda_uo/setName">ltpda_uo/setName</a>               -  Sets the property 'name' of an ltpda_uoh object.
%   <a href="matlab:help ltpda_uo/setPropertyValue">ltpda_uo/setPropertyValue</a>      -  sets the value of a property of one or more objects.
%   <a href="matlab:help ltpda_uo/setPropertyValue_core">ltpda_uo/setPropertyValue_core</a> -  sets the value of a property of one or more objects.
%   <a href="matlab:help ltpda_uo/setUUID">ltpda_uo/setUUID</a>               -  Set the property 'UUID'
%   <a href="matlab:help ltpda_uo/submit">ltpda_uo/submit</a>                -  Submits the given collection of objects to an LTPDA repository
%   <a href="matlab:help ltpda_uo/submitDialog">ltpda_uo/submitDialog</a>          -  Creates a connection and the sinfo structure depending of the input variables.
%   <a href="matlab:help ltpda_uo/update">ltpda_uo/update</a>                -  Updates the given object in an LTPDA repository
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_uoh   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_uoh/addHistory">ltpda_uoh/addHistory</a>               -  Add a history-object to the ltpda_uo object.
%   <a href="matlab:help ltpda_uoh/addHistoryWoChangingUUID">ltpda_uoh/addHistoryWoChangingUUID</a> -  Add a history-object to the ltpda_uo object.
%   <a href="matlab:help ltpda_uoh/attachToDom">ltpda_uoh/attachToDom</a>              - % Add hist
%   <a href="matlab:help ltpda_uoh/clearHistory">ltpda_uoh/clearHistory</a>             -  Clears the history of an object with history.
%   <a href="matlab:help ltpda_uoh/copy">ltpda_uoh/copy</a>                     -  copies all fields of the ltpda_uoh class to the new object.
%   <a href="matlab:help ltpda_uoh/created">ltpda_uoh/created</a>                  -  Returns a time object of the last modification.
%   <a href="matlab:help ltpda_uoh/creator">ltpda_uoh/creator</a>                  -  Extract the creator(s) from the history.
%   <a href="matlab:help ltpda_uoh/csvGenerateData">ltpda_uoh/csvGenerateData</a>          -  Default method to convert a ltpda_uoh-object into csv data.
%   <a href="matlab:help ltpda_uoh/csvexport">ltpda_uoh/csvexport</a>                -  Exports the data of an object to a csv file.
%   <a href="matlab:help ltpda_uoh/fromDom">ltpda_uoh/fromDom</a>                  - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_uoh/fromModel">ltpda_uoh/fromModel</a>                -  Construct an a built in model
%   <a href="matlab:help ltpda_uoh/fromRepository">ltpda_uoh/fromRepository</a>           - Retrieve a ltpda_uo from a repository
%   <a href="matlab:help ltpda_uoh/fromStruct">ltpda_uoh/fromStruct</a>               -  sets all properties which are defined in the ltpda_uoh class from the structure to the input object.
%   <a href="matlab:help ltpda_uoh/index">ltpda_uoh/index</a>                    -  index into a 'ltpda_uoh' object array or matrix. This properly captures the history.
%   <a href="matlab:help ltpda_uoh/loadobj">ltpda_uoh/loadobj</a>                  - % This is an old-type ltpda object from disk, so we don't need to
%   <a href="matlab:help ltpda_uoh/ltpda_uoh">ltpda_uoh/ltpda_uoh</a>                -  is the abstract ltpda base class for ltpda user object classes with history
%   <a href="matlab:help ltpda_uoh/plot">ltpda_uoh/plot</a>                     -  plots the user object on a figure.
%   <a href="matlab:help ltpda_uoh/prepareSinfoForSubmit">ltpda_uoh/prepareSinfoForSubmit</a>    -  This method prepend the timespan as a XML-String to the submission structure.
%   <a href="matlab:help ltpda_uoh/rebuild">ltpda_uoh/rebuild</a>                  -  rebuilds the input objects using the history.
%   <a href="matlab:help ltpda_uoh/report">ltpda_uoh/report</a>                   -  generates an HTML report about the input objects.
%   <a href="matlab:help ltpda_uoh/requirements">ltpda_uoh/requirements</a>             -  Returns a list of LTPDA extension requirements for a given object.
%   <a href="matlab:help ltpda_uoh/saveobj">ltpda_uoh/saveobj</a>                  - % MATLAB does a double pass save, firs calculating the size, then doing
%   <a href="matlab:help ltpda_uoh/setHist">ltpda_uoh/setHist</a>                  -  Set the property 'hist'
%   <a href="matlab:help ltpda_uoh/setObjectProperties">ltpda_uoh/setObjectProperties</a>      -  sets the object properties of an ltpda_uoh object.
%   <a href="matlab:help ltpda_uoh/setPlotAxes">ltpda_uoh/setPlotAxes</a>              -  sets the 'axes' property of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotColor">ltpda_uoh/setPlotColor</a>             -  sets the color of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotFigure">ltpda_uoh/setPlotFigure</a>            -  sets the 'figure' property of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotFillmarker">ltpda_uoh/setPlotFillmarker</a>        -  defines if the plot function fill the marker or not.
%   <a href="matlab:help ltpda_uoh/setPlotLineStyle">ltpda_uoh/setPlotLineStyle</a>         -  sets the linestyle of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotLinewidth">ltpda_uoh/setPlotLinewidth</a>         -  sets the linewidth of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotMarker">ltpda_uoh/setPlotMarker</a>            -  sets the marker of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotMarkerEdgeColor">ltpda_uoh/setPlotMarkerEdgeColor</a>   -  sets the color of a the object's marker edge.
%   <a href="matlab:help ltpda_uoh/setPlotMarkerFaceColor">ltpda_uoh/setPlotMarkerFaceColor</a>   -  sets the color of a the object's marker face.
%   <a href="matlab:help ltpda_uoh/setPlotMarkersize">ltpda_uoh/setPlotMarkersize</a>        -  sets the markersize of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setPlotinfo">ltpda_uoh/setPlotinfo</a>              -  sets the 'plotinfo' property of a ltpda_uoh object.
%   <a href="matlab:help ltpda_uoh/setPlottingStyle">ltpda_uoh/setPlottingStyle</a>         -  sets the style property of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setProcinfo">ltpda_uoh/setProcinfo</a>              -  sets the 'procinfo' property of a ltpda_uoh object.
%   <a href="matlab:help ltpda_uoh/setProperties">ltpda_uoh/setProperties</a>            -  set different properties of an object.
%   <a href="matlab:help ltpda_uoh/setPropertyValue">ltpda_uoh/setPropertyValue</a>         - (No help available)
%   <a href="matlab:help ltpda_uoh/setShowsErrors">ltpda_uoh/setShowsErrors</a>           -  sets the 'showErrors' property of a the object's plotinfo.
%   <a href="matlab:help ltpda_uoh/setTimespan">ltpda_uoh/setTimespan</a>              -  sets the 'timespan' property of a ltpda_uoh object.
%   <a href="matlab:help ltpda_uoh/string">ltpda_uoh/string</a>                   -  writes a command string that can be used to recreate the input object(s).
%   <a href="matlab:help ltpda_uoh/testCallerIsMethod">ltpda_uoh/testCallerIsMethod</a>       -  hidden static method which tests the 'internal' command of a LTPDA-function.
%   <a href="matlab:help ltpda_uoh/type">ltpda_uoh/type</a>                     -  converts the input objects to MATLAB functions.
%   <a href="matlab:help ltpda_uoh/viewHistory">ltpda_uoh/viewHistory</a>              -  Displays the history of an object as a dot-view or a MATLAB figure.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ltpda_vector   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ltpda_vector/attachToDom">ltpda_vector/attachToDom</a>   - % Add name
%   <a href="matlab:help ltpda_vector/cast">ltpda_vector/cast</a>          -  - converts the numeric values in a ltpda_vector object to a new data type.
%   <a href="matlab:help ltpda_vector/char">ltpda_vector/char</a>          -  convert a ltpda_vector object into a string.
%   <a href="matlab:help ltpda_vector/copy">ltpda_vector/copy</a>          -  copies all fields of the ltpda_vector class to the new object.
%   <a href="matlab:help ltpda_vector/disp">ltpda_vector/disp</a>          -  overloads display functionality for ltpda_vector objects.
%   <a href="matlab:help ltpda_vector/fromDom">ltpda_vector/fromDom</a>       - %%%%%%%%%% Call super-class
%   <a href="matlab:help ltpda_vector/fromStruct">ltpda_vector/fromStruct</a>    -  sets all properties which are defined in the ltpda_vector class from the structure to the input object.
%   <a href="matlab:help ltpda_vector/getData">ltpda_vector/getData</a>       - GETY Get the property 'data'.
%   <a href="matlab:help ltpda_vector/getDdata">ltpda_vector/getDdata</a>      - GETDY Get the property 'ddata'.
%   <a href="matlab:help ltpda_vector/getName">ltpda_vector/getName</a>       - GETY Get the property 'name'.
%   <a href="matlab:help ltpda_vector/loadobj">ltpda_vector/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help ltpda_vector/ltpda_vector">ltpda_vector/ltpda_vector</a>  -  encapsulates the details of a data vector.
%   <a href="matlab:help ltpda_vector/setData">ltpda_vector/setData</a>       -  Set the property 'data'.
%   <a href="matlab:help ltpda_vector/setDdata">ltpda_vector/setDdata</a>      -  Set the property 'ddata'.
%   <a href="matlab:help ltpda_vector/setName">ltpda_vector/setName</a>       -  Set the property 'name'.
%   <a href="matlab:help ltpda_vector/setUnits">ltpda_vector/setUnits</a>      -  Set the property 'units'.
%   <a href="matlab:help ltpda_vector/simplifyUnits">ltpda_vector/simplifyUnits</a> -  simplify the 'units' property of the object.
%   <a href="matlab:help ltpda_vector/update_struct">ltpda_vector/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: matrix   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help matrix/attachToDom">matrix/attachToDom</a>              - % Create empty matrix node with the attribute 'shape'
%   <a href="matlab:help matrix/char">matrix/char</a>                     -  convert a matrix object into a string.
%   <a href="matlab:help matrix/clearObjHistories">matrix/clearObjHistories</a>        -  Clear the history of the inside objects.
%   <a href="matlab:help matrix/cohere">matrix/cohere</a>                   -  estimates the coherence between elements of the vector.
%   <a href="matlab:help matrix/copy">matrix/copy</a>                     -  makes a (deep) copy of the input matrix objects.
%   <a href="matlab:help matrix/cpsd">matrix/cpsd</a>                     -  estimates the cross-spectral density between elements of the vector.
%   <a href="matlab:help matrix/crb">matrix/crb</a>                      -  computes the inverse of the Fisher Matrix
%   <a href="matlab:help matrix/cross">matrix/cross</a>                    -  implements cross operator for matrix objects.
%   <a href="matlab:help matrix/ctranspose">matrix/ctranspose</a>               -  implements conjugate transpose operator for matrix objects.
%   <a href="matlab:help matrix/delay">matrix/delay</a>                    -  overloads ao/delay for matrix objects.
%   <a href="matlab:help matrix/det">matrix/det</a>                      -  evaluates the determinant for matrix object.
%   <a href="matlab:help matrix/disp">matrix/disp</a>                     -  overloads display functionality for matrix objects.
%   <a href="matlab:help matrix/dispersion">matrix/dispersion</a>               -  computes the dispersion function
%   <a href="matlab:help matrix/dispersionLoop">matrix/dispersionLoop</a>           -  computes the dispersion function
%   <a href="matlab:help matrix/double">matrix/double</a>                   -  - converts a matrix of objects into matrix of numbers
%   <a href="matlab:help matrix/elementOp">matrix/elementOp</a>                -  applies the given operator to the input matrices.
%   <a href="matlab:help matrix/fftfilt">matrix/fftfilt</a>                  -  fft filter for matrix objects
%   <a href="matlab:help matrix/filter">matrix/filter</a>                   -  implements N-dim filter operator for matrix objects.
%   <a href="matlab:help matrix/filtfilt">matrix/filtfilt</a>                 -  overrides the filtfilt function for matrices of analysis objects.
%   <a href="matlab:help matrix/fisher">matrix/fisher</a>                   -  Fisher matrix calculation for MATRIX models.
%   <a href="matlab:help matrix/flscovSegments">matrix/flscovSegments</a>           -  - Tool to perform a least square fit in frequency domain
%   <a href="matlab:help matrix/fromDom">matrix/fromDom</a>                  - % Get shape
%   <a href="matlab:help matrix/fromInput">matrix/fromInput</a>                - Construct a matrix object from ltpda_uoh objects.
%   <a href="matlab:help matrix/fromStruct">matrix/fromStruct</a>               -  creates from a structure a MATRIX object.
%   <a href="matlab:help matrix/fromValues">matrix/fromValues</a>               - Construct a matrix object with multiple AOs built from input values.
%   <a href="matlab:help matrix/generateConstructorPlist">matrix/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help matrix/getObjectAtIndex">matrix/getObjectAtIndex</a>         -  index into the inner objects of one matrix object.
%   <a href="matlab:help matrix/inv">matrix/inv</a>                      -  evaluates the inverse for matrix object.
%   <a href="matlab:help matrix/iplot">matrix/iplot</a>                    -  calls ao/iplot on all inner ao objects.
%   <a href="matlab:help matrix/lcohere">matrix/lcohere</a>                  -  estimates the coherence between elements of the vector using
%   <a href="matlab:help matrix/lcpsd">matrix/lcpsd</a>                    -  estimates the coherence between elements of the vector using a
%   <a href="matlab:help matrix/lincom">matrix/lincom</a>                   -  make a linear combination of analysis objects
%   <a href="matlab:help matrix/linearize">matrix/linearize</a>                -  output the derivatives of the model relative to the parameters.
%   <a href="matlab:help matrix/linfitsvd">matrix/linfitsvd</a>                -  Linear fit with singular value decomposition
%   <a href="matlab:help matrix/linlsqsvd">matrix/linlsqsvd</a>                -  Linear least squares with singular value decomposition
%   <a href="matlab:help matrix/loadobj">matrix/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help matrix/loglikelihood">matrix/loglikelihood</a>            - LOGLIKELIHOOD: Compute log-likelihood for MATRIX objects
%   <a href="matlab:help matrix/loglikelihood_core">matrix/loglikelihood_core</a>       - loglikelihood: Compute log-likelihood for MATRIX objects
%   <a href="matlab:help matrix/lscov">matrix/lscov</a>                    -  is a wrapper for MATLAB's lscov function.
%   <a href="matlab:help matrix/ltfe">matrix/ltfe</a>                     -  estimates the transfer function between elements of the vector using
%   <a href="matlab:help matrix/matrix">matrix/matrix</a>                   -  constructor for matrix class.
%   <a href="matlab:help matrix/mchNoisegen">matrix/mchNoisegen</a>              -  Generates multichannel noise data series given a model
%   <a href="matlab:help matrix/mchNoisegenFilter">matrix/mchNoisegenFilter</a>        -  Construct a matrix filter from cross-spectral density matrix
%   <a href="matlab:help matrix/mcmc">matrix/mcmc</a>                     -  estimates paramters using a Monte Carlo Markov Chain.
%   <a href="matlab:help matrix/mean">matrix/mean</a>                     -  evaluates the meanerse for matrix object.
%   <a href="matlab:help matrix/minus">matrix/minus</a>                    -  implements subtraction operator for ltpda model objects.
%   <a href="matlab:help matrix/modelSelect">matrix/modelSelect</a>              -  - method to compute the Bayes Factor using RJMCMC, LF, LM, SBIC methods
%   <a href="matlab:help matrix/mtimes">matrix/mtimes</a>                   -  implements mtimes operator for matrix objects.
%   <a href="matlab:help matrix/osize">matrix/osize</a>                    -  Returns the size of the inner object array.
%   <a href="matlab:help matrix/plot">matrix/plot</a>                     -  the matrix objects on the given axes.
%   <a href="matlab:help matrix/plus">matrix/plus</a>                     -  implements addition operator for matrix objects.
%   <a href="matlab:help matrix/power">matrix/power</a>                    - TIMES implements multiplication operator for matrix objects.
%   <a href="matlab:help matrix/rdivide">matrix/rdivide</a>                  -  implements division operator for matrix objects.
%   <a href="matlab:help matrix/rotate">matrix/rotate</a>                   -  applies rotation factor to matrix objects
%   <a href="matlab:help matrix/setObjs">matrix/setObjs</a>                  -  sets the 'objs' property of a matrix object.
%   <a href="matlab:help matrix/simplify">matrix/simplify</a>                 -  each model in the matrix.
%   <a href="matlab:help matrix/spsdSubtraction">matrix/spsdSubtraction</a>          -  makes a sPSD-weighted least-square iterative fit
%   <a href="matlab:help matrix/tdfit">matrix/tdfit</a>                    -  fit a MATRIX of transfer function SMODELs to a matrix of input and output signals.
%   <a href="matlab:help matrix/tfe">matrix/tfe</a>                      -  estimates the transfer functions between elements of the vector.
%   <a href="matlab:help matrix/times">matrix/times</a>                    -  implements multiplication operator for matrix objects.
%   <a href="matlab:help matrix/toArray">matrix/toArray</a>                  -  unpacks the objects in a matrix and places them into a MATLAB
%   <a href="matlab:help matrix/transpose">matrix/transpose</a>                -  implements transpose operator for matrix objects.
%   <a href="matlab:help matrix/unpack">matrix/unpack</a>                   -  unpacks the objects in a matrix and sets them to the given output
%   <a href="matlab:help matrix/update_struct">matrix/update_struct</a>            -  update the input structure to the current ltpda version
%   <a href="matlab:help matrix/wrapperEval">matrix/wrapperEval</a>              - % loop over inner objects
%   <a href="matlab:help matrix/xspec">matrix/xspec</a>                    - MATRIX/XSPEC applies the given cross-spectral density method to the vecor
%
%
%%%%%%%%%%%%%%%%%%%%   class: mfh   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help mfh/attachToDom">mfh/attachToDom</a>                    - % create empty mfir node with the attribute 'shape'
%   <a href="matlab:help mfh/char">mfh/char</a>                           -  convert a mfh object into a string.
%   <a href="matlab:help mfh/copy">mfh/copy</a>                           -  makes a (deep) copy of the input mfh objects.
%   <a href="matlab:help mfh/declare_objects">mfh/declare_objects</a>                -  declares all constants and sub-functions in the workspace
%   <a href="matlab:help mfh/disp">mfh/disp</a>                           -  overloads display functionality for mfh objects.
%   <a href="matlab:help mfh/elementOp">mfh/elementOp</a>                      -  applies the given operator to the models.
%   <a href="matlab:help mfh/eval">mfh/eval</a>                           - % Check inputs
%   <a href="matlab:help mfh/fisher">mfh/fisher</a>                         -  Calculation of the Fisher Information Matrix/Covariance
%   <a href="matlab:help mfh/flscov">mfh/flscov</a>                         -  - Tool to perform a least square fit in frequency domain.
%   <a href="matlab:help mfh/fminsearch">mfh/fminsearch</a>                     -  uses a simplex search to minimise the given function handle.
%   <a href="matlab:help mfh/fminsearchbnd">mfh/fminsearchbnd</a>                  -  uses a simplex search to minimise the given function handle
%   <a href="matlab:help mfh/fromDom">mfh/fromDom</a>                        - % Get shape
%   <a href="matlab:help mfh/fromStruct">mfh/fromStruct</a>                     -  creates from a structure a COLLECTION object.
%   <a href="matlab:help mfh/function_handle">mfh/function_handle</a>                -  returns a MATLAB function handle version of the function.
%   <a href="matlab:help mfh/generateConstructorPlist">mfh/generateConstructorPlist</a>       -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help mfh/getFitErrors">mfh/getFitErrors</a>                   -  calculates fisher matrix approximation of fit parameters
%   <a href="matlab:help mfh/getHessian">mfh/getHessian</a>                     -  calculate Hessian matrix for a given function.
%   <a href="matlab:help mfh/getJacobian">mfh/getJacobian</a>                    -  calculate Jacobian matrix for a given function.
%   <a href="matlab:help mfh/lincom">mfh/lincom</a>                         -  make a linear combination of supplied models objects
%   <a href="matlab:help mfh/loadobj">mfh/loadobj</a>                        -  is called by the load function for user objects.
%   <a href="matlab:help mfh/loglikelihood">mfh/loglikelihood</a>                  - LOGLIKELIHOOD: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_ao_td">mfh/loglikelihood_ao_td</a>            - loglikelihood_core_td: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core">mfh/loglikelihood_core</a>             - loglikelihood_core: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core_log">mfh/loglikelihood_core_log</a>         - loglikelihood_core_log: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core_noiseFit_v1">mfh/loglikelihood_core_noiseFit_v1</a> - loglikelihood_core_noiseFit_v1: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core_student">mfh/loglikelihood_core_student</a>     - loglikelihood_core_student: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core_td">mfh/loglikelihood_core_td</a>          - loglikelihood_core_td: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_core_whittle">mfh/loglikelihood_core_whittle</a>     - loglikelihood_core_whittle: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/loglikelihood_hyper">mfh/loglikelihood_hyper</a>            - loglikelihood_core: Compute log-likelihood for MFH objects
%   <a href="matlab:help mfh/mfh">mfh/mfh</a>                            -  function handle class constructor.
%   <a href="matlab:help mfh/minus">mfh/minus</a>                          -  implements subtraction operator for mfh objects.
%   <a href="matlab:help mfh/multinest">mfh/multinest</a>                      - (No help available)
%   <a href="matlab:help mfh/num2cell">mfh/num2cell</a>                       -  Convert numeric array into cell array.
%   <a href="matlab:help mfh/paramCovMat">mfh/paramCovMat</a>                    -  calculate the covariace matrix for the parameters.
%   <a href="matlab:help mfh/plus">mfh/plus</a>                           -  implements addition operator for mfh objects.
%   <a href="matlab:help mfh/rdivide">mfh/rdivide</a>                        -  implements division operator for mfh objects.
%   <a href="matlab:help mfh/setConstObjects">mfh/setConstObjects</a>                -  sets the 'constObjects' property of a mfh object.
%   <a href="matlab:help mfh/setInputObjects">mfh/setInputObjects</a>                -  sets the 'inputObjects' property of a mfh object.
%   <a href="matlab:help mfh/setNumeric">mfh/setNumeric</a>                     -  sets the 'numeric' property of a mfh object.
%   <a href="matlab:help mfh/setParamsToConst">mfh/setParamsToConst</a>               -  set the given parameters to be constant in the model.
%   <a href="matlab:help mfh/setSubfuncs">mfh/setSubfuncs</a>                    -  sets the 'subfuncs' property of a mfh object.
%   <a href="matlab:help mfh/subsref">mfh/subsref</a>                        - % if we didn't return already, call the built-in MATLAB subsref
%   <a href="matlab:help mfh/testHessianMatrix">mfh/testHessianMatrix</a>              -  Performs a random study of the n-dimensional error ellipsoide for a given confidence level.
%   <a href="matlab:help mfh/times">mfh/times</a>                          -  implements multiplication operator for mfh objects.
%   <a href="matlab:help mfh/update_struct">mfh/update_struct</a>                  -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: mfir   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help mfir/attachToDom">mfir/attachToDom</a>              - % create empty mfir node with the attribute 'shape'
%   <a href="matlab:help mfir/char">mfir/char</a>                     -  convert a mfir object into a string.
%   <a href="matlab:help mfir/copy">mfir/copy</a>                     -  makes a (deep) copy of the input mfir objects.
%   <a href="matlab:help mfir/disp">mfir/disp</a>                     -  overloads display functionality for mfir objects.
%   <a href="matlab:help mfir/fromA">mfir/fromA</a>                    - Construct an mfir from coefficients
%   <a href="matlab:help mfir/fromAO">mfir/fromAO</a>                   - create FIR filter from magnitude of input AO/fsdata
%   <a href="matlab:help mfir/fromDom">mfir/fromDom</a>                  - % Get shape
%   <a href="matlab:help mfir/fromPzmodel">mfir/fromPzmodel</a>              - Construct an mfir from a pzmodel
%   <a href="matlab:help mfir/fromStandard">mfir/fromStandard</a>             - Construct an mfir from a standard types
%   <a href="matlab:help mfir/fromStruct">mfir/fromStruct</a>               -  creates from a structure a MIIR object.
%   <a href="matlab:help mfir/generateConstructorPlist">mfir/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help mfir/loadobj">mfir/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help mfir/mfir">mfir/mfir</a>                     -  FIR filter object class constructor.
%   <a href="matlab:help mfir/mkbandpass">mfir/mkbandpass</a>               -  return a bandpass filter mfir(). A Cheby filter is used.
%   <a href="matlab:help mfir/mkbandreject">mfir/mkbandreject</a>             -  return a low pass filter mfir(). A Butterworth filter is used.
%   <a href="matlab:help mfir/mkhighpass">mfir/mkhighpass</a>               -  return a high pass filter mfir(). A Butterworth filter is used.
%   <a href="matlab:help mfir/mklowpass">mfir/mklowpass</a>                -  return a low pass filter mfir().
%   <a href="matlab:help mfir/parseFilterParams">mfir/parseFilterParams</a>        -  parses the input plist and returns a full plist for designing a standard FIR filter.
%   <a href="matlab:help mfir/redesign">mfir/redesign</a>                 -  redesign the input filter to work for the given sample rate.
%   <a href="matlab:help mfir/setGd">mfir/setGd</a>                    -  Set the property 'gd'
%   <a href="matlab:help mfir/update_struct">mfir/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: miir   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help miir/attachToDom">miir/attachToDom</a>              - % Create empty miir node with the attribute 'shape'
%   <a href="matlab:help miir/char">miir/char</a>                     -  convert a miir object into a string.
%   <a href="matlab:help miir/copy">miir/copy</a>                     -  makes a (deep) copy of the input miir objects.
%   <a href="matlab:help miir/disp">miir/disp</a>                     -  overloads display functionality for miir objects.
%   <a href="matlab:help miir/filload">miir/filload</a>                  - % Load a LISO *_iir.fil file to get the filter taps and return a
%   <a href="matlab:help miir/fromAB">miir/fromAB</a>                   - Construct an miir from coefficients
%   <a href="matlab:help miir/fromAllpass">miir/fromAllpass</a>              - Construct an miir allpass filter
%   <a href="matlab:help miir/fromDom">miir/fromDom</a>                  - % Get shape
%   <a href="matlab:help miir/fromLISO">miir/fromLISO</a>                 -  Construct a miir filter from a LISO file
%   <a href="matlab:help miir/fromParfrac">miir/fromParfrac</a>              - Construct an miir from a parfrac
%   <a href="matlab:help miir/fromPzmodel">miir/fromPzmodel</a>              - Construct an miir from a pzmodel
%   <a href="matlab:help miir/fromStandard">miir/fromStandard</a>             - Construct an miir from a standard types
%   <a href="matlab:help miir/fromStruct">miir/fromStruct</a>               -  creates from a structure a MIIR object.
%   <a href="matlab:help miir/generateConstructorPlist">miir/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help miir/loadobj">miir/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help miir/miir">miir/miir</a>                     -  IIR filter object class constructor.
%   <a href="matlab:help miir/mkallpass">miir/mkallpass</a>                -  returns an allpass filter miir(). 
%   <a href="matlab:help miir/mkbandpass">miir/mkbandpass</a>               -  return a bandpass filter miir(). A Cheby filter is used.
%   <a href="matlab:help miir/mkbandreject">miir/mkbandreject</a>             -  return a low pass filter miir(). A Butterworth filter is used.
%   <a href="matlab:help miir/mkhighpass">miir/mkhighpass</a>               -  return a high pass filter miir(). A Butterworth filter is used.
%   <a href="matlab:help miir/mklowpass">miir/mklowpass</a>                -  return a low pass filter miir(). A Butterworth filter is used.
%   <a href="matlab:help miir/parseFilterParams">miir/parseFilterParams</a>        -  parses the input plist and returns a full plist for designing a standard IIR filter.
%   <a href="matlab:help miir/redesign">miir/redesign</a>                 -  redesign the input filter to work for the given sample rate.
%   <a href="matlab:help miir/setB">miir/setB</a>                     -  Set the property 'b'
%   <a href="matlab:help miir/setHistin">miir/setHistin</a>                -  Set the property 'histin'
%   <a href="matlab:help miir/update_struct">miir/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: minfo   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help minfo/addChildren">minfo/addChildren</a>          -  Add children to this minfo.
%   <a href="matlab:help minfo/addSupportedNumTypes">minfo/addSupportedNumTypes</a> -  Add a value to the property 'supportedNumTypes'.
%   <a href="matlab:help minfo/attachToDom">minfo/attachToDom</a>          - % Create empty minfo node with the attribute 'shape'
%   <a href="matlab:help minfo/char">minfo/char</a>                 -  convert an minfo object into a string.
%   <a href="matlab:help minfo/clearSets">minfo/clearSets</a>            -  Clear the sets and plists of the input minfo objects.
%   <a href="matlab:help minfo/copy">minfo/copy</a>                 -  makes a (deep) copy of the input minfo objects.
%   <a href="matlab:help minfo/disp">minfo/disp</a>                 -  display an minfo object.
%   <a href="matlab:help minfo/fromDom">minfo/fromDom</a>              - % there exist some possibilities.
%   <a href="matlab:help minfo/fromStruct">minfo/fromStruct</a>           -  creates from a structure a MINFO object.
%   <a href="matlab:help minfo/getEncodedString">minfo/getEncodedString</a>     - % Make some plausibility checks
%   <a href="matlab:help minfo/getInfoAxis">minfo/getInfoAxis</a>          - % Build info object
%   <a href="matlab:help minfo/isequal">minfo/isequal</a>              -  overloads the isequal operator for ltpda minfo objects.
%   <a href="matlab:help minfo/loadobj">minfo/loadobj</a>              -  is called by the load function for user objects.
%   <a href="matlab:help minfo/minfo">minfo/minfo</a>                -  a helper class for LTPDA methods.
%   <a href="matlab:help minfo/modelOverview">minfo/modelOverview</a>        -  prepares an html overview of a built-in model
%   <a href="matlab:help minfo/setArgsmax">minfo/setArgsmax</a>           -  Set the property 'argsmax'.
%   <a href="matlab:help minfo/setArgsmin">minfo/setArgsmin</a>           -  Set the property 'argsmin'.
%   <a href="matlab:help minfo/setDescription">minfo/setDescription</a>       -  Set the property 'description'.
%   <a href="matlab:help minfo/setFromEncodedInfo">minfo/setFromEncodedInfo</a>   - % info{1} is empty
%   <a href="matlab:help minfo/setMclass">minfo/setMclass</a>            -  Set the property 'mclass'.
%   <a href="matlab:help minfo/setModifier">minfo/setModifier</a>          -  Set the property 'modifier'.
%   <a href="matlab:help minfo/setMpackage">minfo/setMpackage</a>          -  Set the property 'mpackage'.
%   <a href="matlab:help minfo/setMversion">minfo/setMversion</a>          -  Set the property 'mversion'.
%   <a href="matlab:help minfo/setOutmax">minfo/setOutmax</a>            -  Set the property 'outmax'.
%   <a href="matlab:help minfo/setOutmin">minfo/setOutmin</a>            -  Set the property 'outmin'.
%   <a href="matlab:help minfo/setPlists">minfo/setPlists</a>            -  Sets the property 'plists'.
%   <a href="matlab:help minfo/setSets">minfo/setSets</a>              -  Sets the property 'sets'.
%   <a href="matlab:help minfo/setSupportedNumTypes">minfo/setSupportedNumTypes</a> -  Set the property 'supportedNumTypes'.
%   <a href="matlab:help minfo/string">minfo/string</a>               -  writes a command string that can be used to recreate the input minfo object.
%   <a href="matlab:help minfo/tohtml">minfo/tohtml</a>               -  convert an minfo object to an html document
%   <a href="matlab:help minfo/tohtmlTable">minfo/tohtmlTable</a>          -  convert an minfo object to a html table without <HTML>, <BODY>, ... tags
%   <a href="matlab:help minfo/update_struct">minfo/update_struct</a>        -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: msym   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help msym/char">msym/char</a>    -  converts a msym object to a denotable string.
%   <a href="matlab:help msym/copy">msym/copy</a>    -  makes a (deep) copy of the input msym objects.
%   <a href="matlab:help msym/disp">msym/disp</a>    -  display an msym object.
%   <a href="matlab:help msym/double">msym/double</a>  -  tries to evaluate a msym to a double.
%   <a href="matlab:help msym/loadobj">msym/loadobj</a> -  is called by the load function for user objects.
%   <a href="matlab:help msym/msym">msym/msym</a>    -  LTPDA symbolic class class constructor.
%   <a href="matlab:help msym/subs">msym/subs</a>    -  Symbolic substitution.
%
%
%%%%%%%%%%%%%%%%%%%%   class: param   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help param/addAlternativeKey">param/addAlternativeKey</a> -  adds a key to the list of keys
%   <a href="matlab:help param/attachToDom">param/attachToDom</a>       - % Create empty param node with the attribute 'shape'
%   <a href="matlab:help param/char">param/char</a>              -  convert a param object into a string.
%   <a href="matlab:help param/copy">param/copy</a>              -  makes a (deep) copy of the input param objects.
%   <a href="matlab:help param/copyWithDefault">param/copyWithDefault</a>   -  makes a (deep) copy of the input param objects.
%   <a href="matlab:help param/disp">param/disp</a>              -  display a parameter
%   <a href="matlab:help param/fromDom">param/fromDom</a>           - % Get shape
%   <a href="matlab:help param/fromStruct">param/fromStruct</a>        -  creates from a structure a PARAM object.
%   <a href="matlab:help param/getDefaultVal">param/getDefaultVal</a>     -  retrurns the default value for this parameter
%   <a href="matlab:help param/getOptions">param/getOptions</a>        -  returns the array of options for the param
%   <a href="matlab:help param/getProperties">param/getProperties</a>     -  return all properties from a parameter.
%   <a href="matlab:help param/getProperty">param/getProperty</a>       -  get a property from a parameter.
%   <a href="matlab:help param/getVal">param/getVal</a>            -  returns the default value of a param.
%   <a href="matlab:help param/isequal">param/isequal</a>           -  overloads the isequal operator for ltpda param objects.
%   <a href="matlab:help param/loadobj">param/loadobj</a>           -  is called by the load function for user objects.
%   <a href="matlab:help param/param">param/param</a>             -  Parameter object class constructor.
%   <a href="matlab:help param/setDefaultIndex">param/setDefaultIndex</a>   -  Sets the index which points to the default value to the input.
%   <a href="matlab:help param/setDefaultOption">param/setDefaultOption</a>  -  Sets the default option of the a param object.
%   <a href="matlab:help param/setDesc">param/setDesc</a>           -  Set the property 'desc'.
%   <a href="matlab:help param/setKey">param/setKey</a>            -  Set the property 'key'.
%   <a href="matlab:help param/setKeyVal">param/setKeyVal</a>         -  Set the properties 'key' and 'val'
%   <a href="matlab:help param/setOrigin">param/setOrigin</a>         -  Set the property 'origin'.
%   <a href="matlab:help param/setProperty">param/setProperty</a>       -  set a property to a parameter.
%   <a href="matlab:help param/setReadonly">param/setReadonly</a>       -  sets the readonly flag of the param object and (if existing)
%   <a href="matlab:help param/setVal">param/setVal</a>            -  Set the property 'val'.
%   <a href="matlab:help param/string">param/string</a>            -  writes a command string that can be used to recreate the input param object.
%   <a href="matlab:help param/update_struct">param/update_struct</a>     -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: paramValue   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help paramValue/char">paramValue/char</a>                  -  convert a paramValue object into a string.
%   <a href="matlab:help paramValue/copy">paramValue/copy</a>                  -  makes a (deep) copy of the input paramValue objects.
%   <a href="matlab:help paramValue/disp">paramValue/disp</a>                  -  display a parameter value
%   <a href="matlab:help paramValue/fromStruct">paramValue/fromStruct</a>            -  creates from a structure a PARAMVALUE object.
%   <a href="matlab:help paramValue/getOptions">paramValue/getOptions</a>            -  returns the options array for this param value.
%   <a href="matlab:help paramValue/getProperty">paramValue/getProperty</a>           -  get a property to a paramValue
%   <a href="matlab:help paramValue/getVal">paramValue/getVal</a>                -  returns the default value for this param value
%   <a href="matlab:help paramValue/loadobj">paramValue/loadobj</a>               -  is called by the load function for user objects.
%   <a href="matlab:help paramValue/paramValue">paramValue/paramValue</a>            -  object class constructor.
%   <a href="matlab:help paramValue/setOptions">paramValue/setOptions</a>            -  Sets the property 'options'.
%   <a href="matlab:help paramValue/setProperty">paramValue/setProperty</a>           -  set a property to a paramValue
%   <a href="matlab:help paramValue/setReadonly">paramValue/setReadonly</a>           -  sets the readonly flag of the paramValue object.
%   <a href="matlab:help paramValue/setSelection">paramValue/setSelection</a>          -  Sets the property 'selection'.
%   <a href="matlab:help paramValue/setValIndex">paramValue/setValIndex</a>           -  Sets the property 'valIndex'.
%   <a href="matlab:help paramValue/setValIndexAndOptions">paramValue/setValIndexAndOptions</a> -  Sets the property 'valIndex' and 'options'.
%   <a href="matlab:help paramValue/update_struct">paramValue/update_struct</a>         -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: parfrac   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help parfrac/attachToDom">parfrac/attachToDom</a>              - % Create empty parfrac node with the attribute 'shape'
%   <a href="matlab:help parfrac/char">parfrac/char</a>                     -  convert a parfrac object into a string.
%   <a href="matlab:help parfrac/copy">parfrac/copy</a>                     -  makes a (deep) copy of the input parfrac objects.
%   <a href="matlab:help parfrac/disp">parfrac/disp</a>                     -  overloads display functionality for parfrac objects.
%   <a href="matlab:help parfrac/fromDom">parfrac/fromDom</a>                  - % Get shape
%   <a href="matlab:help parfrac/fromPzmodel">parfrac/fromPzmodel</a>              - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help parfrac/fromRational">parfrac/fromRational</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help parfrac/fromResidualsPolesDirect">parfrac/fromResidualsPolesDirect</a> - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help parfrac/fromStruct">parfrac/fromStruct</a>               -  creates from a structure a PARFRAC object.
%   <a href="matlab:help parfrac/generateConstructorPlist">parfrac/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help parfrac/getlowerFreq">parfrac/getlowerFreq</a>             -  gets the frequency of the lowest pole in the model.
%   <a href="matlab:help parfrac/getupperFreq">parfrac/getupperFreq</a>             -  gets the frequency of the highest pole in the model.
%   <a href="matlab:help parfrac/loadobj">parfrac/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help parfrac/parfrac">parfrac/parfrac</a>                  -  partial fraction representation of a transfer function.
%   <a href="matlab:help parfrac/respCore">parfrac/respCore</a>                 -  returns the complex response of one parfrac object.
%   <a href="matlab:help parfrac/update_struct">parfrac/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: pest   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help pest/attachToDom">pest/attachToDom</a>              - % Create empty pest node with the attribute 'shape'
%   <a href="matlab:help pest/char">pest/char</a>                     -  convert a pest object into a string.
%   <a href="matlab:help pest/combine">pest/combine</a>                  -  combines multiple pest objects.
%   <a href="matlab:help pest/combineExps">pest/combineExps</a>              -  combine the results of different parameter estimation
%   <a href="matlab:help pest/computePdf">pest/computePdf</a>               - computes Probability Density Function from a pest object
%   <a href="matlab:help pest/copy">pest/copy</a>                     -  makes a (deep) copy of the input pest objects.
%   <a href="matlab:help pest/disp">pest/disp</a>                     -  overloads display functionality for pest objects.
%   <a href="matlab:help pest/double">pest/double</a>                   -  overloads double() function for pest objects.
%   <a href="matlab:help pest/eval">pest/eval</a>                     -  evaluate a pest object
%   <a href="matlab:help pest/find">pest/find</a>                     -  Creates analysis objects from the selected parameter(s).
%   <a href="matlab:help pest/fromAOs">pest/fromAOs</a>                  -  construct a pest object from different values.
%   <a href="matlab:help pest/fromDom">pest/fromDom</a>                  - % Get shape
%   <a href="matlab:help pest/fromStruct">pest/fromStruct</a>               -  creates from a structure a PEST object.
%   <a href="matlab:help pest/fromValues">pest/fromValues</a>               -  construct a pest object from different values.
%   <a href="matlab:help pest/generateConstructorPlist">pest/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help pest/genericSet">pest/genericSet</a>               -  sets values to a pest property.
%   <a href="matlab:help pest/getY">pest/getY</a>                     -  Get the data property 'y'.
%   <a href="matlab:help pest/jtable">pest/jtable</a>                   -  display the parameters from PEST objects in a java table.
%   <a href="matlab:help pest/loadobj">pest/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help pest/mcmcPlot">pest/mcmcPlot</a>                 -  - Tool to visualise results of a MCMC sampling.
%   <a href="matlab:help pest/mve">pest/mve</a>                      - MVE: Minimum Volume Ellipsoid estimator
%   <a href="matlab:help pest/pest">pest/pest</a>                     -  constructor for parameter estimates (pest) class.
%   <a href="matlab:help pest/plot">pest/plot</a>                     -  the pest objects on the given axes.
%   <a href="matlab:help pest/removeParameters">pest/removeParameters</a>         -  removes the named parameters from the pests.
%   <a href="matlab:help pest/setChain">pest/setChain</a>                 - SETCHI2 Set the property 'chain'
%   <a href="matlab:help pest/setChi2">pest/setChi2</a>                  -  Set the property 'chi2'
%   <a href="matlab:help pest/setCorr">pest/setCorr</a>                  -  Set the property 'corr'
%   <a href="matlab:help pest/setCov">pest/setCov</a>                   -  Set the property 'cov'
%   <a href="matlab:help pest/setDof">pest/setDof</a>                   -  Set the property 'dof'
%   <a href="matlab:help pest/setDy">pest/setDy</a>                    -  Set the property 'dy'
%   <a href="matlab:help pest/setDyForParameter">pest/setDyForParameter</a>        -  Sets the according dy-error for the specified parameter.
%   <a href="matlab:help pest/setModels">pest/setModels</a>                -  Set the property 'models'
%   <a href="matlab:help pest/setNames">pest/setNames</a>                 -  Set the property 'names'
%   <a href="matlab:help pest/setPdf">pest/setPdf</a>                   -  Set the property 'pdf'
%   <a href="matlab:help pest/setXvals">pest/setXvals</a>                 -  sets the 'xvals' property of the underlying smodel object.
%   <a href="matlab:help pest/setY">pest/setY</a>                     -  Set the property 'y'
%   <a href="matlab:help pest/setYforParameter">pest/setYforParameter</a>         -  Sets the according y-value for the specified parameter.
%   <a href="matlab:help pest/setYunits">pest/setYunits</a>                -  Set the property 'yunits'
%   <a href="matlab:help pest/setYunitsForParameter">pest/setYunitsForParameter</a>    -  Sets the according y-unit for the specified parameter.
%   <a href="matlab:help pest/simplifyYunits">pest/simplifyYunits</a>           -  simplifies the units of parameters in a pest
%   <a href="matlab:help pest/subset">pest/subset</a>                   -  Extract a subset of parameters from a pest.
%   <a href="matlab:help pest/table">pest/table</a>                    -  display the parameters from PEST objects in a java table.
%   <a href="matlab:help pest/tdChi2">pest/tdChi2</a>                   -  computes the chi-square for a parameter estimate.
%   <a href="matlab:help pest/toLaTeX">pest/toLaTeX</a>                  -  display the parameters from PEST objects in a LaTeX table.
%   <a href="matlab:help pest/update_struct">pest/update_struct</a>            -  update the input structure to the current ltpda version
%   <a href="matlab:help pest/viewResults">pest/viewResults</a>              -  displays the content of the pest object as an html report.
%
%
%%%%%%%%%%%%%%%%%%%%   class: plist   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help plist/addAlternativeKeys">plist/addAlternativeKeys</a>      -  adds some alternative key names to an existing key.
%   <a href="matlab:help plist/append">plist/append</a>                  -  append a param-object, plist-object or a key/value pair to the parameter list.
%   <a href="matlab:help plist/applyDefaults">plist/applyDefaults</a>           -  apply the default plist to the input plists
%   <a href="matlab:help plist/attachToDom">plist/attachToDom</a>             - % Create empty plist node with the attribute 'shape'
%   <a href="matlab:help plist/char">plist/char</a>                    -  convert a parameter list into a string.
%   <a href="matlab:help plist/combine">plist/combine</a>                 -  multiple parameter lists (plist objects) into a single plist.
%   plist/compressPlist           - (No help available)
%   <a href="matlab:help plist/copy">plist/copy</a>                    -  makes a (deep) copy of the input plist objects.
%   <a href="matlab:help plist/copyWithDefault">plist/copyWithDefault</a>         -  makes a (deep) copy of the input plist objects.
%   <a href="matlab:help plist/disp">plist/disp</a>                    -  display plist object.
%   <a href="matlab:help plist/find">plist/find</a>                    -  overloads find routine for a parameter list.
%   plist/find_core               - (No help available)
%   <a href="matlab:help plist/fromDom">plist/fromDom</a>                 - % There exist two possibilities.
%   <a href="matlab:help plist/fromStruct">plist/fromStruct</a>              -  creates from a structure a PLIST object.
%   <a href="matlab:help plist/getAllKeys">plist/getAllKeys</a>              -  Return all keys (even the alternative key names) of the parameter list.
%   <a href="matlab:help plist/getDefaultAxisPlist">plist/getDefaultAxisPlist</a>     -  returns the default plist for the axis key based on
%   <a href="matlab:help plist/getDescriptionForParam">plist/getDescriptionForParam</a>  -  Returns the description for the specified parameter key.
%   <a href="matlab:help plist/getIndexForKey">plist/getIndexForKey</a>          -  returns the index of a parameter with the given key.
%   <a href="matlab:help plist/getKeys">plist/getKeys</a>                 -  Return all the default keys of the parameter list.
%   <a href="matlab:help plist/getOptionsForParam">plist/getOptionsForParam</a>      -  Returns the options for the specified parameter key.
%   <a href="matlab:help plist/getParamValueForParam">plist/getParamValueForParam</a>   -  Returns the paramValue for the specified parameter key.
%   <a href="matlab:help plist/getPropertyForKey">plist/getPropertyForKey</a>       -  get a property from a specified parameter.
%   <a href="matlab:help plist/getSelectionForParam">plist/getSelectionForParam</a>    -  Returns the selection mode for the specified parameter key.
%   <a href="matlab:help plist/getSetRandState">plist/getSetRandState</a>         -  gets or sets the random state of the MATLAB functions 'rand' and 'randn'
%   <a href="matlab:help plist/isparam">plist/isparam</a>                 -  look for a given key in the parameter lists.
%   plist/isparam_core            - (No help available)
%   <a href="matlab:help plist/loadobj">plist/loadobj</a>                 -  is called by the load function for user objects.
%   <a href="matlab:help plist/ltp_parameters">plist/ltp_parameters</a>          - LTP/LPF Parameter plist
%   <a href="matlab:help plist/matchKey">plist/matchKey</a>                -  returns a logical array with the same size of the parametes with a 1 if the input key matches to the key name(s) and a 0 if not.
%   <a href="matlab:help plist/matchKeyWithRegexp">plist/matchKeyWithRegexp</a>      -  returns a logical array with the same size of the parametes with a 1 if the input string matches to the key name(s) and a 0 if not.
%   <a href="matlab:help plist/matchKey_core">plist/matchKey_core</a>           - % Get value we want
%   <a href="matlab:help plist/matchKeys">plist/matchKeys</a>               -  returns a logical array with the same size of the parametes with a 1 if one of the input key(s) matches to the key name(s) and a 0 if not.
%   <a href="matlab:help plist/matchKeys_core">plist/matchKeys_core</a>          - % The command cellstr doesn't work here because it is possible that the
%   <a href="matlab:help plist/merge">plist/merge</a>                   -  the values for the same key of multiple parameter lists together.
%   <a href="matlab:help plist/mfind">plist/mfind</a>                   -  multiple-arguments find routine for a parameter list.
%   <a href="matlab:help plist/nparams">plist/nparams</a>                 -  returns the number of param objects in the list.
%   <a href="matlab:help plist/parse">plist/parse</a>                   -  a plist for strings which can be converted into numbers
%   <a href="matlab:help plist/plist">plist/plist</a>                   -  Plist class object constructor.
%   <a href="matlab:help plist/plist2cmds">plist/plist2cmds</a>              -  convert a plist to a set of commands.
%   <a href="matlab:help plist/processForHistory">plist/processForHistory</a>       -  process the plist ready for adding to the history tree.
%   <a href="matlab:help plist/processSetterValues">plist/processSetterValues</a>     - (No help available)
%   <a href="matlab:help plist/propertiesForParam">plist/propertiesForParam</a>      -  returns the properties structure for a given parameter.
%   <a href="matlab:help plist/propertyForParam">plist/propertyForParam</a>        -  returns the value of the specified property for a given parameter.
%   <a href="matlab:help plist/psdSegments">plist/psdSegments</a>             -  returns the time-series segments from a PSD plist.
%   <a href="matlab:help plist/pset">plist/pset</a>                    -  set or add a key/value pairor a param-object into the parameter list.
%   <a href="matlab:help plist/pset_core">plist/pset_core</a>               - % does the key exist?
%   <a href="matlab:help plist/recreatePlot">plist/recreatePlot</a>            -  given a 'script' plist resulting from a call to
%   <a href="matlab:help plist/regexp">plist/regexp</a>                  -  performs a regular expression search on the input plists.
%   <a href="matlab:help plist/remove">plist/remove</a>                  -  remove a parameter from the parameter list.
%   <a href="matlab:help plist/removeKeys">plist/removeKeys</a>              -  removes keys from a PLIST.
%   <a href="matlab:help plist/search">plist/search</a>                  -  returns a subset of a parameter list.
%   <a href="matlab:help plist/setDefaultForParam">plist/setDefaultForParam</a>      -  Sets the default value of the param object in dependencies of the 'key'
%   plist/setDefaultForParam_core - (No help available)
%   <a href="matlab:help plist/setDescriptionForParam">plist/setDescriptionForParam</a>  -  Sets the property 'desc' of the param object in dependencies of the 'key'
%   <a href="matlab:help plist/setOptionsForParam">plist/setOptionsForParam</a>      -  Sets the options of the param object in dependencies of the 'key'
%   <a href="matlab:help plist/setPropertyForKey">plist/setPropertyForKey</a>       -  set a property from a specified parameter to a given value.
%   <a href="matlab:help plist/setSelectionForParam">plist/setSelectionForParam</a>    -  Sets the selection mode of the param object in dependencies of the 'key'
%   <a href="matlab:help plist/shouldIgnore">plist/shouldIgnore</a>            -  True for plists which have the key 'ignore' with the value true.
%   <a href="matlab:help plist/simplify">plist/simplify</a>                -  simplifies a plist.
%   <a href="matlab:help plist/string">plist/string</a>                  -  converts a plist object to a command string which will recreate the plist object.
%   <a href="matlab:help plist/subset">plist/subset</a>                  -  returns a subset of a parameter list.
%   <a href="matlab:help plist/tohtml">plist/tohtml</a>                  -  produces an html table from the plist.
%   <a href="matlab:help plist/type">plist/type</a>                    -  converts the input plist to MATLAB functions.
%   <a href="matlab:help plist/update_struct">plist/update_struct</a>           -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: plotinfo   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help plotinfo/attachToDom">plotinfo/attachToDom</a>   - % Create empty plotinfo node
%   <a href="matlab:help plotinfo/char">plotinfo/char</a>          -  convert a plotinfo object into a string.
%   <a href="matlab:help plotinfo/combine">plotinfo/combine</a>       -  combines multiple plotinfo objects into one.
%   <a href="matlab:help plotinfo/copy">plotinfo/copy</a>          -  makes a (deep) copy of the input plotinfo objects.
%   <a href="matlab:help plotinfo/disp">plotinfo/disp</a>          -  display a plotinfo
%   <a href="matlab:help plotinfo/fromDom">plotinfo/fromDom</a>       - % Get shape
%   <a href="matlab:help plotinfo/fromStruct">plotinfo/fromStruct</a>    -  creates from a structure a plotinfo object.
%   <a href="matlab:help plotinfo/isequal">plotinfo/isequal</a>       -  overloads the isequal operator for ltpda plotinfo objects.
%   <a href="matlab:help plotinfo/loadobj">plotinfo/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help plotinfo/plotinfo">plotinfo/plotinfo</a>      -  Encapsulates plot information.
%   <a href="matlab:help plotinfo/string">plotinfo/string</a>        -  writes a command string that can be used to recreate the input plotinfo object.
%   <a href="matlab:help plotinfo/update_struct">plotinfo/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: provenance   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help provenance/attachToDom">provenance/attachToDom</a>        - % Create empty provenance node with the attribute 'shape'
%   <a href="matlab:help provenance/char">provenance/char</a>               -  convert a provenance object into a string.
%   <a href="matlab:help provenance/copy">provenance/copy</a>               -  makes a (deep) copy of the input provenance objects.
%   <a href="matlab:help provenance/disp">provenance/disp</a>               -  overload terminal display for provenance objects.
%   <a href="matlab:help provenance/fromDom">provenance/fromDom</a>            - % Get shape
%   <a href="matlab:help provenance/fromStruct">provenance/fromStruct</a>         -  creates from a structure a PROVENANCE object.
%   <a href="matlab:help provenance/getEncodedString">provenance/getEncodedString</a>   - info = [info sep 'dummy']; % version dummy. We have to keep it for backwards compatibility.
%   <a href="matlab:help provenance/loadobj">provenance/loadobj</a>            -  is called by the load function for user objects.
%   <a href="matlab:help provenance/provenance">provenance/provenance</a>         -  constructors for provenance class.
%   <a href="matlab:help provenance/setFromEncodedInfo">provenance/setFromEncodedInfo</a> - % info{1} is empty
%   <a href="matlab:help provenance/string">provenance/string</a>             -  writes a command string that can be used to recreate the input provenance object.
%   <a href="matlab:help provenance/update_struct">provenance/update_struct</a>      -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: pz   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help pz/attachToDom">pz/attachToDom</a>         - % Create empty pz node with the attribute 'shape'
%   <a href="matlab:help pz/char">pz/char</a>                -  convert a pz object into a string.
%   <a href="matlab:help pz/copy">pz/copy</a>                -  makes a (deep) copy of the input pz objects.
%   <a href="matlab:help pz/cp2iir">pz/cp2iir</a>              -  Return a,b IIR filter coefficients for a complex pole designed using the bilinear transform.
%   <a href="matlab:help pz/cz2iir">pz/cz2iir</a>              -  return a,b IIR filter coefficients for a complex zero designed using the bilinear transform.
%   <a href="matlab:help pz/disp">pz/disp</a>                -  display a pz object.
%   <a href="matlab:help pz/fq2ri">pz/fq2ri</a>               -  Convert frequency/Q pole/zero representation
%   <a href="matlab:help pz/fromDom">pz/fromDom</a>             - % Get shape
%   <a href="matlab:help pz/fromStruct">pz/fromStruct</a>          -  creates from a structure a PZ object.
%   <a href="matlab:help pz/loadobj">pz/loadobj</a>             -  is called by the load function for user objects.
%   <a href="matlab:help pz/pz">pz/pz</a>                  -  is the ltpda class that provides a common definition of poles and zeros.
%   <a href="matlab:help pz/resp">pz/resp</a>                -  returns the complex response of the pz object.
%   <a href="matlab:help pz/resp_add_delay_core">pz/resp_add_delay_core</a> -  Simple core method to add a pure delay in frequency domain
%   <a href="matlab:help pz/resp_pz_Q_core">pz/resp_pz_Q_core</a>      -  Simple core method to compute the response of a pz model (with Q>=0.5)
%   <a href="matlab:help pz/resp_pz_noQ_core">pz/resp_pz_noQ_core</a>    - resp_pz_Q_core Simple core method to compute the response of a pz model (with Q<0.5)
%   <a href="matlab:help pz/ri2fq">pz/ri2fq</a>               -  Convert comlpex pole/zero into frequency/Q pole/zero representation.
%   <a href="matlab:help pz/rp2iir">pz/rp2iir</a>              -  Return a,b coefficients for a real pole designed using the bilinear transform.
%   <a href="matlab:help pz/rz2iir">pz/rz2iir</a>              -  Return a,b IIR filter coefficients for a real zero designed using the bilinear transform.
%   <a href="matlab:help pz/setF">pz/setF</a>                -  Set the property 'f'
%   <a href="matlab:help pz/setQ">pz/setQ</a>                -  Set the property 'q'
%   <a href="matlab:help pz/setRI">pz/setRI</a>               -  Set the property 'ri' and computes 'f' and 'q'
%   <a href="matlab:help pz/string">pz/string</a>              -  writes a command string that can be used to recreate the input pz object.
%   <a href="matlab:help pz/update_struct">pz/update_struct</a>       -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: pzmodel   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help pzmodel/abcascade">pzmodel/abcascade</a>                -  Cascade two filters together to get a new filter.
%   <a href="matlab:help pzmodel/attachToDom">pzmodel/attachToDom</a>              - % Create empty pzmodel node with the attribute 'shape'
%   <a href="matlab:help pzmodel/char">pzmodel/char</a>                     -  convert a pzmodel object into a string.
%   <a href="matlab:help pzmodel/conj">pzmodel/conj</a>                     -  overloads conjugate functionality for pzmodel objects.
%   <a href="matlab:help pzmodel/copy">pzmodel/copy</a>                     -  makes a (deep) copy of the input pzmodel objects.
%   <a href="matlab:help pzmodel/disp">pzmodel/disp</a>                     -  overloads display functionality for pzmodel objects.
%   <a href="matlab:help pzmodel/fngen">pzmodel/fngen</a>                    -  creates an arbitrarily long time-series based on the input pzmodel.
%   <a href="matlab:help pzmodel/fromDom">pzmodel/fromDom</a>                  - % Get shape
%   <a href="matlab:help pzmodel/fromLISO">pzmodel/fromLISO</a>                 -  Construct a pzmodel from a LISO file
%   <a href="matlab:help pzmodel/fromParfrac">pzmodel/fromParfrac</a>              - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help pzmodel/fromPolesAndZeros">pzmodel/fromPolesAndZeros</a>        - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help pzmodel/fromRational">pzmodel/fromRational</a>             - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help pzmodel/fromStruct">pzmodel/fromStruct</a>               -  creates from a structure a PZMODEL object.
%   <a href="matlab:help pzmodel/generateConstructorPlist">pzmodel/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help pzmodel/getlowerFreq">pzmodel/getlowerFreq</a>             -  gets the frequency of the lowest pole or zero in the model.
%   <a href="matlab:help pzmodel/getupperFreq">pzmodel/getupperFreq</a>             -  gets the frequency of the highest pole or zero in the model.
%   <a href="matlab:help pzmodel/loadobj">pzmodel/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help pzmodel/mrdivide">pzmodel/mrdivide</a>                 -  overloads the division operator for pzmodels.
%   <a href="matlab:help pzmodel/mtimes">pzmodel/mtimes</a>                   -  overloads the multiplication operator for pzmodels.
%   <a href="matlab:help pzmodel/pzm2ab">pzmodel/pzm2ab</a>                   -  convert pzmodel to IIR filter coefficients using bilinear transform.
%   <a href="matlab:help pzmodel/pzmodel">pzmodel/pzmodel</a>                  -  constructor for pzmodel class.
%   <a href="matlab:help pzmodel/rdivide">pzmodel/rdivide</a>                  -  overloads the division operator for pzmodels.
%   <a href="matlab:help pzmodel/respCore">pzmodel/respCore</a>                 -  returns the complex response of one pzmodel object.
%   <a href="matlab:help pzmodel/setDelay">pzmodel/setDelay</a>                 -  sets the 'delay' property of the pzmodel object.
%   <a href="matlab:help pzmodel/setGain">pzmodel/setGain</a>                  -  sets the 'gain' property of the pzmodel object.
%   <a href="matlab:help pzmodel/setPoles">pzmodel/setPoles</a>                 -  Set the property 'poles' of a pole/zero model.
%   <a href="matlab:help pzmodel/setZeros">pzmodel/setZeros</a>                 -  Set the property 'zeros' of a pole/zero model.
%   <a href="matlab:help pzmodel/simplify">pzmodel/simplify</a>                 -  simplifies pzmodels by cancelling like poles with like zeros.
%   <a href="matlab:help pzmodel/times">pzmodel/times</a>                    -  overloads the multiplication operator for pzmodels.
%   <a href="matlab:help pzmodel/tomfir">pzmodel/tomfir</a>                   -  approximates a pole/zero model with an FIR filter.
%   <a href="matlab:help pzmodel/tomiir">pzmodel/tomiir</a>                   -  converts a pzmodel to an IIR filter using a bilinear transform.
%   <a href="matlab:help pzmodel/update_struct">pzmodel/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: rational   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help rational/attachToDom">rational/attachToDom</a>              - % Create empty rational node with the attribute 'shape'
%   <a href="matlab:help rational/char">rational/char</a>                     -  convert a rational object into a string.
%   <a href="matlab:help rational/copy">rational/copy</a>                     -  makes a (deep) copy of the input rational objects.
%   <a href="matlab:help rational/disp">rational/disp</a>                     -  overloads display functionality for rational objects.
%   <a href="matlab:help rational/fromCoefficients">rational/fromCoefficients</a>         - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help rational/fromDom">rational/fromDom</a>                  - % Get shape
%   <a href="matlab:help rational/fromParfrac">rational/fromParfrac</a>              - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help rational/fromPzmodel">rational/fromPzmodel</a>              - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help rational/fromStruct">rational/fromStruct</a>               -  creates from a structure a RATIONAL object.
%   <a href="matlab:help rational/generateConstructorPlist">rational/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help rational/getlowerFreq">rational/getlowerFreq</a>             -  gets the frequency of the lowest pole in the model.
%   <a href="matlab:help rational/getupperFreq">rational/getupperFreq</a>             -  gets the frequency of the highest pole in the model.
%   <a href="matlab:help rational/loadobj">rational/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help rational/rational">rational/rational</a>                 -  rational representation of a transfer function.
%   <a href="matlab:help rational/respCore">rational/respCore</a>                 -  returns the complex response of one rational object.
%   <a href="matlab:help rational/update_struct">rational/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: smodel   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help smodel/addAliases">smodel/addAliases</a>               -  Add the key-value pairs to the alias-names and alias-values
%   <a href="matlab:help smodel/addParameters">smodel/addParameters</a>            -  Add some parameters to the symbolic model (smodel) object
%   <a href="matlab:help smodel/assignalias">smodel/assignalias</a>              -  assign values to smodel alias
%   <a href="matlab:help smodel/attachToDom">smodel/attachToDom</a>              - % Create empty smodel node with the attribute 'shape'
%   <a href="matlab:help smodel/char">smodel/char</a>                     -  convert a smodel object into a string.
%   <a href="matlab:help smodel/clearAliases">smodel/clearAliases</a>             -  Clear the aliases.
%   <a href="matlab:help smodel/conj">smodel/conj</a>                     -  gives the complex conjugate of the input smodels
%   <a href="matlab:help smodel/convol_integral">smodel/convol_integral</a>          -  implements the convolution integral for smodel objects.
%   <a href="matlab:help smodel/copy">smodel/copy</a>                     -  makes a (deep) copy of the input smodel objects.
%   <a href="matlab:help smodel/det">smodel/det</a>                      -  evaluates the determinant of smodel objects.
%   <a href="matlab:help smodel/diff">smodel/diff</a>                     -  implements differentiation operator for smodel objects.
%   <a href="matlab:help smodel/disp">smodel/disp</a>                     -  overloads display functionality for smodel objects.
%   <a href="matlab:help smodel/double">smodel/double</a>                   -  Returns the numeric result of the model.
%   <a href="matlab:help smodel/elementOp">smodel/elementOp</a>                -  applies the given operator to the input smodels.
%   <a href="matlab:help smodel/eval">smodel/eval</a>                     -  evaluates the symbolic model and returns an AO containing the numeric data.
%   <a href="matlab:help smodel/fitfunc">smodel/fitfunc</a>                  -  Returns a function handle which sets the 'values' and 'xvals' to a ltpda model.
%   <a href="matlab:help smodel/fourier">smodel/fourier</a>                  -  implements continuous f-domain Fourier transform for smodel objects.
%   <a href="matlab:help smodel/fromDatafile">smodel/fromDatafile</a>             -  Construct smodel object from filename AND parameter list
%   <a href="matlab:help smodel/fromDom">smodel/fromDom</a>                  - % Get shape
%   <a href="matlab:help smodel/fromExpression">smodel/fromExpression</a>           - (No help available)
%   <a href="matlab:help smodel/fromStruct">smodel/fromStruct</a>               -  creates from a structure a SMODEL object.
%   <a href="matlab:help smodel/generateConstructorPlist">smodel/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help smodel/hessian">smodel/hessian</a>                  -  compute the hessian matrix for a symbolic model.
%   <a href="matlab:help smodel/ifourier">smodel/ifourier</a>                 -  implements continuous f-domain inverse Fourier transform for smodel objects.
%   <a href="matlab:help smodel/ilaplace">smodel/ilaplace</a>                 -  implements continuous s-domain inverse Laplace transform for smodel objects.
%   <a href="matlab:help smodel/inv">smodel/inv</a>                      -  evaluates the inverse of smodel objects.
%   <a href="matlab:help smodel/iztrans">smodel/iztrans</a>                  -  implements continuous z-domain inverse Z-transform for smodel objects.
%   <a href="matlab:help smodel/laplace">smodel/laplace</a>                  -  implements continuous s-domain Laplace transform for smodel objects.
%   <a href="matlab:help smodel/linearize">smodel/linearize</a>                -  output the derivatives of the model relative to the parameters.
%   <a href="matlab:help smodel/loadobj">smodel/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help smodel/mergeFields">smodel/mergeFields</a>              -  merges properties (name/values) of smodels
%   <a href="matlab:help smodel/minus">smodel/minus</a>                    -  implements subtraction operator for smodel objects.
%   <a href="matlab:help smodel/mrdivide">smodel/mrdivide</a>                 -  implements mrdivide operator for smodel objects.
%   <a href="matlab:help smodel/mtimes">smodel/mtimes</a>                   -  implements mtimes operator for smodel objects.
%   <a href="matlab:help smodel/op">smodel/op</a>                       -  Add a operation around the model expression
%   <a href="matlab:help smodel/plus">smodel/plus</a>                     -  implements addition operator for smodel objects.
%   <a href="matlab:help smodel/rdivide">smodel/rdivide</a>                  -  implements division operator for smodel objects.
%   <a href="matlab:help smodel/setAliasNames">smodel/setAliasNames</a>            -  Set the property 'aliasNames'
%   <a href="matlab:help smodel/setAliasValues">smodel/setAliasValues</a>           -  Set the property 'aliasValues'
%   <a href="matlab:help smodel/setAliases">smodel/setAliases</a>               -  Set the key-value pairs to the alias-names and alias-values
%   <a href="matlab:help smodel/setExpr">smodel/setExpr</a>                  -  sets the 'expr' property of the smodel object.
%   <a href="matlab:help smodel/setParameters">smodel/setParameters</a>            -  Set some parameters to the symbolic model (smodel) object
%   <a href="matlab:help smodel/setParams">smodel/setParams</a>                -  Set the property 'params' AND 'values'
%   <a href="matlab:help smodel/setTrans">smodel/setTrans</a>                 -  sets the 'trans' property of the smodel object.
%   <a href="matlab:help smodel/setValues">smodel/setValues</a>                -  Set the property 'values'
%   <a href="matlab:help smodel/setXunits">smodel/setXunits</a>                -  sets the 'xunits' property of the smodel object.
%   <a href="matlab:help smodel/setXvals">smodel/setXvals</a>                 -  sets the 'xvals' property of the smodel object.
%   <a href="matlab:help smodel/setXvar">smodel/setXvar</a>                  -  sets the 'xvar' property of the smodel object.
%   <a href="matlab:help smodel/setYunits">smodel/setYunits</a>                -  sets the 'yunits' property of the smodel object.
%   <a href="matlab:help smodel/simplify">smodel/simplify</a>                 -  implements simplify operator for smodel objects.
%   <a href="matlab:help smodel/simplifyUnits">smodel/simplifyUnits</a>            -  simplify the x and/or y units of the model.
%   <a href="matlab:help smodel/smodel">smodel/smodel</a>                   -  constructor for smodel class.
%   <a href="matlab:help smodel/sop">smodel/sop</a>                      -  apply a symbolic operation to the expression.
%   <a href="matlab:help smodel/subs">smodel/subs</a>                     -  substitutes symbolic parameters with the given values.
%   <a href="matlab:help smodel/sum">smodel/sum</a>                      -  adds all the elements of smodel objects arrays.
%   <a href="matlab:help smodel/times">smodel/times</a>                    -  implements multiplication operator for smodel objects.
%   <a href="matlab:help smodel/update_struct">smodel/update_struct</a>            -  update the input structure to the current ltpda version
%   <a href="matlab:help smodel/ztrans">smodel/ztrans</a>                   -  implements continuous z-domain Z-transform for smodel objects.
%
%
%%%%%%%%%%%%%%%%%%%%   class: specwin   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help specwin/attachToDom">specwin/attachToDom</a>         - % Create empty specwin node with the attribute 'shape'
%   <a href="matlab:help specwin/char">specwin/char</a>                -  convert a specwin object into a string.
%   <a href="matlab:help specwin/copy">specwin/copy</a>                -  makes a (deep) copy of the input specwin objects.
%   <a href="matlab:help specwin/disp">specwin/disp</a>                -  overloads display functionality for specwin objects.
%   <a href="matlab:help specwin/fromDom">specwin/fromDom</a>             - % Get shape
%   <a href="matlab:help specwin/fromStruct">specwin/fromStruct</a>          -  creates from a structure a SPECWIN object.
%   <a href="matlab:help specwin/get_window">specwin/get_window</a>          -  returns the required window function as a structure.
%   <a href="matlab:help specwin/kaiser_alpha">specwin/kaiser_alpha</a>        -  returns the alpha parameter that gives the required input
%   <a href="matlab:help specwin/kaiser_flatness">specwin/kaiser_flatness</a>     -  returns the flatness in dB of the central bin of a kaiser 
%   <a href="matlab:help specwin/kaiser_nenbw">specwin/kaiser_nenbw</a>        -  returns the normalized noise-equivalent bandwidth for a
%   <a href="matlab:help specwin/kaiser_rov">specwin/kaiser_rov</a>          -  returns the recommended overlap for a Kaiser window with
%   <a href="matlab:help specwin/kaiser_w3db">specwin/kaiser_w3db</a>         -  returns the 3dB bandwidth in bins of a kaiser window with
%   <a href="matlab:help specwin/loadobj">specwin/loadobj</a>             -  is called by the load function for user objects.
%   <a href="matlab:help specwin/plot">specwin/plot</a>                -  plots a specwin object.
%   <a href="matlab:help specwin/specwin">specwin/specwin</a>             -  spectral window object class constructor.
%   <a href="matlab:help specwin/string">specwin/string</a>              -  writes a command string that can be used to recreate the input window object.
%   <a href="matlab:help specwin/toPlist">specwin/toPlist</a>             -  creates a plist representing the specwin object.
%   <a href="matlab:help specwin/update_struct">specwin/update_struct</a>       -  update the input structure to the current ltpda version
%   <a href="matlab:help specwin/win_bartlett">specwin/win_bartlett</a>        -  returns Bartlett window, with N points.
%   <a href="matlab:help specwin/win_bh92">specwin/win_bh92</a>            -  returns BH92 window, with N points.
%   <a href="matlab:help specwin/win_fthp">specwin/win_fthp</a>            -  returns FTHP window, with N points.
%   <a href="matlab:help specwin/win_ftni">specwin/win_ftni</a>            -  returns FTNI window, with N points.
%   <a href="matlab:help specwin/win_ftsrs">specwin/win_ftsrs</a>           -  returns FTSRS window, with N points.
%   <a href="matlab:help specwin/win_hamming">specwin/win_hamming</a>         -  returns Hamming window, with N points.
%   <a href="matlab:help specwin/win_hanning">specwin/win_hanning</a>         -  returns Hanning window, with N points.
%   <a href="matlab:help specwin/win_hft116d">specwin/win_hft116d</a>         -  returns HFT116D window, with N points.
%   <a href="matlab:help specwin/win_hft144d">specwin/win_hft144d</a>         -  returns HFT144D window, with N points.
%   <a href="matlab:help specwin/win_hft169d">specwin/win_hft169d</a>         -  returns HFT169D window, with N points.
%   <a href="matlab:help specwin/win_hft196d">specwin/win_hft196d</a>         -  returns HFT196D window, with N points.
%   <a href="matlab:help specwin/win_hft223d">specwin/win_hft223d</a>         -  returns HFT223D window, with N points.
%   <a href="matlab:help specwin/win_hft248d">specwin/win_hft248d</a>         -  returns HFT248D window, with N points.
%   <a href="matlab:help specwin/win_hft70">specwin/win_hft70</a>           -  returns HFT70 window, with N points.
%   <a href="matlab:help specwin/win_hft90d">specwin/win_hft90d</a>          -  returns HFT90D window, with N points.
%   <a href="matlab:help specwin/win_hft95">specwin/win_hft95</a>           -  returns HFT95 window, with N points.
%   <a href="matlab:help specwin/win_kaiser">specwin/win_kaiser</a>          -  returns Kaiser window, with N points and psll peak sidelobe level.
%   <a href="matlab:help specwin/win_levelledhanning">specwin/win_levelledhanning</a> -  returns Hanning window, with N points and levelCoef levelling order
%   <a href="matlab:help specwin/win_nuttall3">specwin/win_nuttall3</a>        -  returns Nuttall3 window, with N points.
%   <a href="matlab:help specwin/win_nuttall3a">specwin/win_nuttall3a</a>       -  returns Nuttall3a window, with N points.
%   <a href="matlab:help specwin/win_nuttall3b">specwin/win_nuttall3b</a>       -  returns Nuttall3b window, with N points.
%   <a href="matlab:help specwin/win_nuttall4">specwin/win_nuttall4</a>        -  returns Nuttall4 window, with N points.
%   <a href="matlab:help specwin/win_nuttall4a">specwin/win_nuttall4a</a>       -  returns Nuttall4a window, with N points.
%   <a href="matlab:help specwin/win_nuttall4b">specwin/win_nuttall4b</a>       -  returns Nuttall4b window, with N points.
%   <a href="matlab:help specwin/win_nuttall4c">specwin/win_nuttall4c</a>       -  returns Nuttall4c window, with N points.
%   <a href="matlab:help specwin/win_rectangular">specwin/win_rectangular</a>     -  returns rectangular window, with N points.
%   <a href="matlab:help specwin/win_sft3f">specwin/win_sft3f</a>           -  returns SFT3F window, with N points.
%   <a href="matlab:help specwin/win_sft3m">specwin/win_sft3m</a>           -  returns SFT3M window, with N points.
%   <a href="matlab:help specwin/win_sft4f">specwin/win_sft4f</a>           -  returns SFT4F window, with N points.
%   <a href="matlab:help specwin/win_sft4m">specwin/win_sft4m</a>           -  returns SFT4M window, with N points.
%   <a href="matlab:help specwin/win_sft5f">specwin/win_sft5f</a>           -  returns SFT5F window, with N points.
%   <a href="matlab:help specwin/win_sft5m">specwin/win_sft5m</a>           -  returns SFT5M window, with N points.
%   <a href="matlab:help specwin/win_welch">specwin/win_welch</a>           -  returns Welch window, with N points.
%
%
%%%%%%%%%%%%%%%%%%%%   class: specwinViewer   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help specwinViewer/buildMainfig">specwinViewer/buildMainfig</a>    -  build the main constructor window
%   <a href="matlab:help specwinViewer/cb_mainfigClose">specwinViewer/cb_mainfigClose</a> -  close callback for LTPDA Specwin Viewer.
%   specwinViewer/cb_plot         - (No help available)
%   specwinViewer/cb_plotFreq     - (No help available)
%   specwinViewer/cb_plotTime     - (No help available)
%   specwinViewer/cb_selectWindow - (No help available)
%   <a href="matlab:help specwinViewer/plotWindow">specwinViewer/plotWindow</a>      - % get window type
%   <a href="matlab:help specwinViewer/specwinViewer">specwinViewer/specwinViewer</a>   -  is a graphical user interface for viewing specwin objects.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ssm   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ssm/addParameters">ssm/addParameters</a>                 -  Adds the parameters to the model.
%   <a href="matlab:help ssm/append">ssm/append</a>                        - appends embedded subsytems, with exogenous inputs
%   <a href="matlab:help ssm/assemble">ssm/assemble</a>                      - assembles embedded subsytems, with exogenous inputs
%   <a href="matlab:help ssm/attachToDom">ssm/attachToDom</a>                   - % Create empty ssm node with the attribute 'shape'
%   <a href="matlab:help ssm/blockMatAdd">ssm/blockMatAdd</a>                   - adds corresponding matrices of same sizes or empty inside cell array
%   <a href="matlab:help ssm/blockMatFillDiag">ssm/blockMatFillDiag</a>              - adds corresponding matrices of same sizes or empty inside cell array
%   <a href="matlab:help ssm/blockMatFusion">ssm/blockMatFusion</a>                - fusions a block defined matrix stored inside cell array into one matrix
%   <a href="matlab:help ssm/blockMatIndex">ssm/blockMatIndex</a>                 - adds corresponding matrices of same sizes or empty inside cell array
%   <a href="matlab:help ssm/blockMatMult">ssm/blockMatMult</a>                  - multiplies block defined matrix stored inside cell array
%   <a href="matlab:help ssm/blockMatPrune">ssm/blockMatPrune</a>                 -  selects lines and columns of a block defined matrices stored in a cell array
%   <a href="matlab:help ssm/blockMatRecut">ssm/blockMatRecut</a>                 - cuts a matrix into blocks stored inside cell array
%   <a href="matlab:help ssm/bode">ssm/bode</a>                          -  makes a bode plot from the given inputs to outputs.
%   <a href="matlab:help ssm/bodecst">ssm/bodecst</a>                       -  makes a bodecst plot from the given inputs to outputs.
%   <a href="matlab:help ssm/buildParamPlist">ssm/buildParamPlist</a>               -  builds paramerter plists for the ssm params field.
%   <a href="matlab:help ssm/c2d">ssm/c2d</a>                           -  performs actions on ao objects.
%   <a href="matlab:help ssm/char">ssm/char</a>                          -  convert a ssm object into a string.
%   <a href="matlab:help ssm/copy">ssm/copy</a>                          -  makes a (deep) copy of the input ssm objects.
%   <a href="matlab:help ssm/cpsd">ssm/cpsd</a>                          -  computes the output theoretical CPSD shape with given inputs.
%   <a href="matlab:help ssm/cpsdForCorrelatedInputs">ssm/cpsdForCorrelatedInputs</a>       -  computes the output theoretical CPSD shape with given inputs.
%   <a href="matlab:help ssm/cpsdForIndependentInputs">ssm/cpsdForIndependentInputs</a>      -  computes the output theoretical CPSD shape with given inputs.
%   <a href="matlab:help ssm/d2c">ssm/d2c</a>                           -  performs actions on ao objects.
%   <a href="matlab:help ssm/d2d">ssm/d2d</a>                           -  performs actions on ao objects.
%   <a href="matlab:help ssm/diffStepFish">ssm/diffStepFish</a>                  -  Search for a differantiation step
%   <a href="matlab:help ssm/disp">ssm/disp</a>                          -  display ssm object.
%   <a href="matlab:help ssm/displayProperties">ssm/displayProperties</a>             - DISPAYPROPERTIES displays the ssm model porperties.
%   <a href="matlab:help ssm/doBode">ssm/doBode</a>                        -  makes a bode computation from the given inputs to outputs.
%   <a href="matlab:help ssm/doSetParameters">ssm/doSetParameters</a>               -  Sets the values of the given parameters.
%   <a href="matlab:help ssm/doSimplify">ssm/doSimplify</a>                    -  enables to do model simplification. It is a private function
%   <a href="matlab:help ssm/doSimulate">ssm/doSimulate</a>                    -  simulates a discrete ssm with given inputs
%   <a href="matlab:help ssm/doSubsParameters">ssm/doSubsParameters</a>              -  enables to substitute symbollic patameters
%   <a href="matlab:help ssm/dotview">ssm/dotview</a>                       -   view an ssm object via the DOT interpreter.
%   <a href="matlab:help ssm/double">ssm/double</a>                        - Convert a statespace model object to double arrays for given i/o
%   <a href="matlab:help ssm/duplicateInput">ssm/duplicateInput</a>                -  copies the specified input blocks.
%   <a href="matlab:help ssm/findParameters">ssm/findParameters</a>                -  returns parameter names matching the given pattern.
%   <a href="matlab:help ssm/fisher">ssm/fisher</a>                        -  Fisher matrix calculation for SSMs.
%   <a href="matlab:help ssm/fromDom">ssm/fromDom</a>                       - % Get shape
%   <a href="matlab:help ssm/fromStruct">ssm/fromStruct</a>                    -  creates from a structure an SSM object.
%   <a href="matlab:help ssm/generateConstructorPlist">ssm/generateConstructorPlist</a>      -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help ssm/getParameters">ssm/getParameters</a>                 -  returns parameter values for the given names.
%   <a href="matlab:help ssm/getParams">ssm/getParams</a>                     -  returns the parameter list for this SSM model.
%   <a href="matlab:help ssm/getPortNamesForBlocks">ssm/getPortNamesForBlocks</a>         -  returns a list of port names for the given block.
%   <a href="matlab:help ssm/isStable">ssm/isStable</a>                      -  tells if ssm is numerically stable
%   <a href="matlab:help ssm/kalman">ssm/kalman</a>                        -  applies Kalman filtering to a discrete ssm with given i/o
%   <a href="matlab:help ssm/loadobj">ssm/loadobj</a>                       -  is called by the load function for user objects.
%   <a href="matlab:help ssm/loglikelihood">ssm/loglikelihood</a>                 - LOGLIKELIHOOD: Compute log-likelihood for SSM objects
%   <a href="matlab:help ssm/loglikelihood_core">ssm/loglikelihood_core</a>            - LOGLIKELIHOOD: Compute log-likelihood for SSM objects
%   <a href="matlab:help ssm/modelHelper_checkParameters">ssm/modelHelper_checkParameters</a>   -  compare the user requested parameter names to
%   <a href="matlab:help ssm/modelHelper_declareParameters">ssm/modelHelper_declareParameters</a> -  builds parameters plists for the ssm params field.
%   <a href="matlab:help ssm/modelHelper_processInputPlist">ssm/modelHelper_processInputPlist</a> -  processes the input parameters plists for
%   <a href="matlab:help ssm/modifyTimeStep">ssm/modifyTimeStep</a>                -  modifies the timestep of a ssm object
%   <a href="matlab:help ssm/optimiseForFitting">ssm/optimiseForFitting</a>            -  reduces the system matrices to doubles and strings.
%   <a href="matlab:help ssm/parameterDiff">ssm/parameterDiff</a>                 -  Makes a ssm that produces the output and state derivatives.
%   <a href="matlab:help ssm/projectNoise">ssm/projectNoise</a>                  -  performs actions on ao objects.
%   <a href="matlab:help ssm/psd">ssm/psd</a>                           -  computes the output theoretical PSD shape with given inputs.
%   <a href="matlab:help ssm/removeEmptyBlocks">ssm/removeEmptyBlocks</a>             -  enables to do model simplification
%   <a href="matlab:help ssm/reorganize">ssm/reorganize</a>                    - REOGANIZE rearranges a ssm object for fast input to BODE, SIMULATE, PSD.
%   <a href="matlab:help ssm/reshuffle">ssm/reshuffle</a>                     -  rearragnes a ssm object using the given inputs and outputs.
%   <a href="matlab:help ssm/reshuffleSym">ssm/reshuffleSym</a>                  -  rearragnes a ssm object using the given inputs and outputs.
%   <a href="matlab:help ssm/resp">ssm/resp</a>                          -  gives the timewise impulse response of a statespace model.
%   <a href="matlab:help ssm/respcst">ssm/respcst</a>                       -  gives the timewise impulse response of a statespace model.
%   <a href="matlab:help ssm/sMinReal">ssm/sMinReal</a>                      -  gives a minimal realization of a ssm object by deleting unreached states
%   <a href="matlab:help ssm/setA">ssm/setA</a>                          -  sets the A matrices to be the given cell array.
%   <a href="matlab:help ssm/setB">ssm/setB</a>                          -  sets the B matrices to be the given cell array.
%   <a href="matlab:help ssm/setBlockProperties">ssm/setBlockProperties</a>            -  Sets the specified properties of the specified SSM blocks.
%   <a href="matlab:help ssm/setC">ssm/setC</a>                          -  sets the C matrices to be the given cell array.
%   <a href="matlab:help ssm/setD">ssm/setD</a>                          -  sets the D matrices to be the given cell array.
%   <a href="matlab:help ssm/setParameters">ssm/setParameters</a>                 -  Sets the values of the given parameters.
%   <a href="matlab:help ssm/setParams">ssm/setParams</a>                     -  Sets the parameters of the model to the given plist.
%   <a href="matlab:help ssm/setPortProperties">ssm/setPortProperties</a>             -  Sets names of the specified SSM ports.
%   <a href="matlab:help ssm/settlingTime">ssm/settlingTime</a>                  -  retunrns 1% the settling time of the system.
%   <a href="matlab:help ssm/simplify">ssm/simplify</a>                      -  enables to do model simplification
%   <a href="matlab:help ssm/simulate">ssm/simulate</a>                      -  simulates a discrete ssm with given inputs
%   <a href="matlab:help ssm/ssm">ssm/ssm</a>                           -  statespace model class constructor.
%   <a href="matlab:help ssm/ssm2dot">ssm/ssm2dot</a>                       -  converts a statespace model object a DOT file.
%   <a href="matlab:help ssm/ssm2miir">ssm/ssm2miir</a>                      -  converts a statespace model object to a miir object
%   <a href="matlab:help ssm/ssm2pzmodel">ssm/ssm2pzmodel</a>                   -  converts a time-continuous statespace model object to a pzmodel
%   <a href="matlab:help ssm/ssm2rational">ssm/ssm2rational</a>                  -  converts a statespace model object to a rational frac. object
%   <a href="matlab:help ssm/ssm2ss">ssm/ssm2ss</a>                        -  converts a statespace model object to a MATLAB statespace object.
%   <a href="matlab:help ssm/ssmFromDescription">ssm/ssmFromDescription</a>            - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/ssmFromMiir">ssm/ssmFromMiir</a>                   - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/ssmFromParfrac">ssm/ssmFromParfrac</a>                - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/ssmFromPzmodel">ssm/ssmFromPzmodel</a>                - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/ssmFromRational">ssm/ssmFromRational</a>               - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/ssmFromss">ssm/ssmFromss</a>                     - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help ssm/steadyState">ssm/steadyState</a>                   -  returns a possible value for the steady state of an ssm.
%   <a href="matlab:help ssm/subsParameters">ssm/subsParameters</a>                -  enables to substitute symbolic patameters
%   <a href="matlab:help ssm/update_struct">ssm/update_struct</a>                 -  update the input structure to the current ltpda version
%   <a href="matlab:help ssm/validate">ssm/validate</a>                      -  Completes and checks the content a ssm object
%   <a href="matlab:help ssm/viewDetails">ssm/viewDetails</a>                   -  performs actions on ssm objects.
%
%
%%%%%%%%%%%%%%%%%%%%   class: ssmblock   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ssmblock/addPorts">ssmblock/addPorts</a>          -  adds the given ssm ports to the list of ports.
%   <a href="matlab:help ssmblock/attachToDom">ssmblock/attachToDom</a>       - % Create empty ssmblock node with the attribute 'shape'
%   <a href="matlab:help ssmblock/char">ssmblock/char</a>              -  convert a ssmblock object into a string.
%   <a href="matlab:help ssmblock/containsPort">ssmblock/containsPort</a>      -  returns true if the inputs block(s) contain the given port.
%   <a href="matlab:help ssmblock/copy">ssmblock/copy</a>              -  makes a (deep) copy of the input ssmblock objects.
%   <a href="matlab:help ssmblock/disp">ssmblock/disp</a>              -  display an ssmblock object.
%   <a href="matlab:help ssmblock/findPorts">ssmblock/findPorts</a>         - MAKEPORTINDEX gives indexes of selected in a series of list in a cell array
%   <a href="matlab:help ssmblock/fromDom">ssmblock/fromDom</a>           - % Get shape
%   <a href="matlab:help ssmblock/fromStruct">ssmblock/fromStruct</a>        -  creates from a structure a SSMBLOCK object.
%   <a href="matlab:help ssmblock/getPortsAtIndices">ssmblock/getPortsAtIndices</a> -  get all ports at the given indices.
%   <a href="matlab:help ssmblock/getPortsWithName">ssmblock/getPortsWithName</a>  -  get all ports with the matching name.
%   <a href="matlab:help ssmblock/loadobj">ssmblock/loadobj</a>           -  is called by the load function for user objects.
%   <a href="matlab:help ssmblock/makePortIndex">ssmblock/makePortIndex</a>     -  gives indexes of selected in a series of list in a cell array
%   <a href="matlab:help ssmblock/ssmblock">ssmblock/ssmblock</a>          -  a helper class for the SSM class.
%   <a href="matlab:help ssmblock/string">ssmblock/string</a>            -  converts a ssmblock object to a command string which will recreate the object.
%   <a href="matlab:help ssmblock/tohtml">ssmblock/tohtml</a>            -  creates an html representation of the ssmblock
%   <a href="matlab:help ssmblock/update_struct">ssmblock/update_struct</a>     -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: ssmport   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help ssmport/attachToDom">ssmport/attachToDom</a>   - % Create empty ssmport node with the attribute 'shape'
%   <a href="matlab:help ssmport/char">ssmport/char</a>          -  convert a ssmport object into a string.
%   <a href="matlab:help ssmport/copy">ssmport/copy</a>          -  makes a (deep) copy of the input ssmport objects.
%   <a href="matlab:help ssmport/disp">ssmport/disp</a>          -  display an ssmport object.
%   <a href="matlab:help ssmport/fromDom">ssmport/fromDom</a>       - % Get shape
%   <a href="matlab:help ssmport/fromStruct">ssmport/fromStruct</a>    -  creates from a structure a SSMPORT object.
%   <a href="matlab:help ssmport/loadobj">ssmport/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help ssmport/ssmport">ssmport/ssmport</a>       -  a helper class for the SSM class.
%   <a href="matlab:help ssmport/string">ssmport/string</a>        -  converts a ssmport object to a command string which will recreate the object.
%   <a href="matlab:help ssmport/update_struct">ssmport/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: tfmap   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help tfmap/attachToDom">tfmap/attachToDom</a>   - % Create empty tfdata node with the attribute 'shape'
%   <a href="matlab:help tfmap/char">tfmap/char</a>          -  convert a tfmap into a string.
%   <a href="matlab:help tfmap/copy">tfmap/copy</a>          -  makes a (deep) copy of the input tfmap objects.
%   <a href="matlab:help tfmap/disp">tfmap/disp</a>          -  overloads display functionality for tfmap objects.
%   <a href="matlab:help tfmap/fromDom">tfmap/fromDom</a>       - % Get shape
%   <a href="matlab:help tfmap/fromStruct">tfmap/fromStruct</a>    -  creates from a structure a tfmap object.
%   <a href="matlab:help tfmap/getX">tfmap/getX</a>          -  Get the property 'x'.
%   <a href="matlab:help tfmap/loadobj">tfmap/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help tfmap/plot">tfmap/plot</a>          -  plots the given tfmap on the given axes
%   <a href="matlab:help tfmap/tfmap">tfmap/tfmap</a>         -  time-frequency data object class constructor.
%   <a href="matlab:help tfmap/update_struct">tfmap/update_struct</a> -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: time   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help time/attachToDom">time/attachToDom</a>      - % Create empty time node with the attribute 'shape'
%   <a href="matlab:help time/calendarweek">time/calendarweek</a>     -  returns the ISO week of the year for the given time.
%   <a href="matlab:help time/char">time/char</a>             -  Convert a time object into a string
%   <a href="matlab:help time/copy">time/copy</a>             -  makes a (deep) copy of the input time objects.
%   <a href="matlab:help time/datenum">time/datenum</a>          -  Converts a time object into MATLAB serial date representation
%   <a href="matlab:help time/dayofyear">time/dayofyear</a>        -  returns the day of year for the given time.
%   <a href="matlab:help time/disp">time/disp</a>             -  display functionality for time objects.
%   <a href="matlab:help time/double">time/double</a>           -  Converts a time object into a double
%   <a href="matlab:help time/format">time/format</a>           -  Formats a time object into a string
%   <a href="matlab:help time/fromDom">time/fromDom</a>          - % Get shape
%   <a href="matlab:help time/fromStruct">time/fromStruct</a>       -  creates from a structure a TIME object.
%   <a href="matlab:help time/ge">time/ge</a>               -  overloads >= operator for time objects
%   <a href="matlab:help time/getTimezones">time/getTimezones</a>     -  Get all possible timezones.
%   <a href="matlab:help time/getdateform">time/getdateform</a>      - taken verbatim from 'datestr.m' in MATLAB R2008b
%   <a href="matlab:help time/gt">time/gt</a>               -  overloads > operator for time objects
%   <a href="matlab:help time/le">time/le</a>               -  overloads <= operator for time objects
%   <a href="matlab:help time/loadobj">time/loadobj</a>          -  is called by the load function for user objects.
%   <a href="matlab:help time/lt">time/lt</a>               -  overloads < operator for time objects
%   <a href="matlab:help time/matfrmt2javafrmt">time/matfrmt2javafrmt</a> - convert MATLAB time formatting specification string into a Java one
%   <a href="matlab:help time/max">time/max</a>              -  return the latest time of an input time-object array.
%   <a href="matlab:help time/mean">time/mean</a>             -  return the mean time of an input time-object array.
%   <a href="matlab:help time/min">time/min</a>              -  return the earliest time of an input time-object array.
%   <a href="matlab:help time/minus">time/minus</a>            -  Implements subtraction operator for time objects.
%   <a href="matlab:help time/mode">time/mode</a>             -  return the mode time of an input time-object array.
%   <a href="matlab:help time/parse">time/parse</a>            - % second and third arguments are optional
%   <a href="matlab:help time/plus">time/plus</a>             -  Implements addition operator for time objects.
%   <a href="matlab:help time/strftime">time/strftime</a>         -  Formats a time expressed as msec since the epoch into a string
%   <a href="matlab:help time/string">time/string</a>           -  writes a command string that can be used to recreate the input time object.
%   <a href="matlab:help time/time">time/time</a>             -  Time object class constructor.
%   <a href="matlab:help time/toGPS">time/toGPS</a>            -  returns the gps seconds corresponding to this time object.
%   <a href="matlab:help time/update_struct">time/update_struct</a>    -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: timespan   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help timespan/attachToDom">timespan/attachToDom</a>              - % Create empty timespan node with the attribute 'shape'
%   <a href="matlab:help timespan/char">timespan/char</a>                     -  convert a timespan object into a string.
%   <a href="matlab:help timespan/computeInterval">timespan/computeInterval</a>          -  compute the interval of the time span.
%   <a href="matlab:help timespan/copy">timespan/copy</a>                     -  makes a (deep) copy of the input TIMESPAN objects.
%   <a href="matlab:help timespan/disp">timespan/disp</a>                     -  overloads display functionality for timespan objects.
%   <a href="matlab:help timespan/double">timespan/double</a>                   -  overloads double() function for timespan objects.
%   <a href="matlab:help timespan/fromAOs">timespan/fromAOs</a>                  - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help timespan/fromDom">timespan/fromDom</a>                  - % Get shape
%   <a href="matlab:help timespan/fromStruct">timespan/fromStruct</a>               -  creates from a structure a TIMESPAN object.
%   <a href="matlab:help timespan/fromTimespanDef">timespan/fromTimespanDef</a>          - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   <a href="matlab:help timespan/ge">timespan/ge</a>                       -  overloads >= operator for timespan objects
%   <a href="matlab:help timespan/generateConstructorPlist">timespan/generateConstructorPlist</a> -  generates a PLIST from the properties which can rebuild the object.
%   <a href="matlab:help timespan/getEndT">timespan/getEndT</a>                  -  Get the timespan property 'endT'.
%   <a href="matlab:help timespan/getNsecs">timespan/getNsecs</a>                 -  Get the timespan property 'nsecs'.
%   <a href="matlab:help timespan/getStartT">timespan/getStartT</a>                -  Get the timespan property 'startT'.
%   <a href="matlab:help timespan/gt">timespan/gt</a>                       -  overloads > operator for timespan objects
%   <a href="matlab:help timespan/human">timespan/human</a>                    -  returns a human readable string representing the time range.
%   <a href="matlab:help timespan/inTimespan">timespan/inTimespan</a>               -  checks if an input time is inbetween a timespan.
%   <a href="matlab:help timespan/le">timespan/le</a>                       -  overloads <= operator for timespan objects
%   <a href="matlab:help timespan/loadobj">timespan/loadobj</a>                  -  is called by the load function for user objects.
%   <a href="matlab:help timespan/lt">timespan/lt</a>                       -  overloads < operator for timespan objects
%   <a href="matlab:help timespan/merge">timespan/merge</a>                    -  the input timespan objects into one output timespan object.
%   <a href="matlab:help timespan/minus">timespan/minus</a>                    -  Implements subtraction operator for timespan objects.
%   <a href="matlab:help timespan/plot">timespan/plot</a>                     -  the timespan objects on the given axes.
%   <a href="matlab:help timespan/plus">timespan/plus</a>                     -  Implements addition operator for timespan objects.
%   <a href="matlab:help timespan/setEndT">timespan/setEndT</a>                  -  sets the 'endT' property of the timespan objects.
%   <a href="matlab:help timespan/setStartT">timespan/setStartT</a>                -  sets the 'startT' property of the timespan objects.
%   <a href="matlab:help timespan/setTimespan">timespan/setTimespan</a>              -  setting the 'timespan' property for timespan-objects is not allowed.
%   <a href="matlab:help timespan/table">timespan/table</a>                    -  display the an array of timespan objects in a table.
%   <a href="matlab:help timespan/timespan">timespan/timespan</a>                 -  timespan object class constructor.
%   <a href="matlab:help timespan/tohtml">timespan/tohtml</a>                   -  produces an html table from the input timespans.
%   <a href="matlab:help timespan/update_struct">timespan/update_struct</a>            -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: tsdata   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help tsdata/attachToDom">tsdata/attachToDom</a>      - % Create empty tsdata node with the attribute 'shape'
%   <a href="matlab:help tsdata/char">tsdata/char</a>             -  convert a tsdata object into a string.
%   <a href="matlab:help tsdata/collapseX">tsdata/collapseX</a>        -  Checks whether the x vector is evenly sampled and then removes it
%   <a href="matlab:help tsdata/copy">tsdata/copy</a>             -  makes a (deep) copy of the input tsdata objects.
%   <a href="matlab:help tsdata/createTimeVector">tsdata/createTimeVector</a> -  Creates the time-series vector from the given 'fs' and 'nsecs'
%   <a href="matlab:help tsdata/disp">tsdata/disp</a>             -  overloads display functionality for tsdata objects.
%   <a href="matlab:help tsdata/evenly">tsdata/evenly</a>           -  defines if the data is evenly sampled or not
%   <a href="matlab:help tsdata/fitfs">tsdata/fitfs</a>            -  estimates the sample rate of the input tsdata object.
%   <a href="matlab:help tsdata/fixNsecs">tsdata/fixNsecs</a>         -  fixes the numer of seconds.
%   <a href="matlab:help tsdata/fromDom">tsdata/fromDom</a>          - % Get shape
%   <a href="matlab:help tsdata/fromStruct">tsdata/fromStruct</a>       -  creates from a structure a TSDATA object.
%   <a href="matlab:help tsdata/getX">tsdata/getX</a>             -  Get the property 'x'.
%   <a href="matlab:help tsdata/growT">tsdata/growT</a>            -  grows the time (x) vector if it is empty.
%   <a href="matlab:help tsdata/loadobj">tsdata/loadobj</a>          -  is called by the load function for user objects.
%   <a href="matlab:help tsdata/plot">tsdata/plot</a>             -  plots the given cdata on the given axes
%   <a href="matlab:help tsdata/saveobj">tsdata/saveobj</a>          -  is called by MATLABs save function for user objects.
%   <a href="matlab:help tsdata/setFs">tsdata/setFs</a>            -  Set the property 'fs'.
%   <a href="matlab:help tsdata/setNsecs">tsdata/setNsecs</a>         -  Set the property 'nsecs'.
%   <a href="matlab:help tsdata/setT0">tsdata/setT0</a>            -  Set the property 't0'.
%   <a href="matlab:help tsdata/setToffset">tsdata/setToffset</a>       -  Set the property 'toffset'.
%   <a href="matlab:help tsdata/setX">tsdata/setX</a>             -  Set the property 'x'.
%   <a href="matlab:help tsdata/tsdata">tsdata/tsdata</a>           -  time-series object class constructor.
%   <a href="matlab:help tsdata/update_struct">tsdata/update_struct</a>    -  update the input structure to the current ltpda version
%
%
%%%%%%%%%%%%%%%%%%%%   class: unit   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help unit/HzToS">unit/HzToS</a>         -  convert any 'Hz' units to 's'
%   <a href="matlab:help unit/atan2">unit/atan2</a>         -  implements atan2 operator for two unit objects
%   <a href="matlab:help unit/attachToDom">unit/attachToDom</a>   - % Create empty unit node with the attribute 'shape'
%   <a href="matlab:help unit/char">unit/char</a>          -  convert a unit object into a string.
%   <a href="matlab:help unit/copy">unit/copy</a>          -  makes a (deep) copy of the input unit objects.
%   <a href="matlab:help unit/disp">unit/disp</a>          -  display an unit object.
%   <a href="matlab:help unit/factor">unit/factor</a>        -  factorises units in to numerator and denominator units.
%   <a href="matlab:help unit/fromDom">unit/fromDom</a>       - % There exist two possibilities.
%   <a href="matlab:help unit/fromStruct">unit/fromStruct</a>    -  creates from a structure a UNIT object.
%   <a href="matlab:help unit/isemptyunit">unit/isemptyunit</a>   -  overloads the isequal operator for ltpda unit objects.
%   <a href="matlab:help unit/isequal">unit/isequal</a>       -  overloads the isequal operator for ltpda unit objects.
%   <a href="matlab:help unit/loadobj">unit/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help unit/mpower">unit/mpower</a>        -  implements mpower operator for unit objects.
%   <a href="matlab:help unit/mrdivide">unit/mrdivide</a>      -  implements mrdivide operator for unit objects.
%   <a href="matlab:help unit/mtimes">unit/mtimes</a>        -  implements mtimes operator for unit objects.
%   <a href="matlab:help unit/plus">unit/plus</a>          -  implements addition operator for unit objects.
%   <a href="matlab:help unit/power">unit/power</a>         -  implements power operator for unit objects.
%   <a href="matlab:help unit/rdivide">unit/rdivide</a>       -  implements rdivide operator for unit objects.
%   <a href="matlab:help unit/sToHz">unit/sToHz</a>         -  convert any 's' units to 'Hz'
%   <a href="matlab:help unit/setVals">unit/setVals</a>       -  set the vals field of the unit
%   <a href="matlab:help unit/simplify">unit/simplify</a>      -  the units.
%   <a href="matlab:help unit/split">unit/split</a>         -  split a unit into a set of single units.
%   <a href="matlab:help unit/sqrt">unit/sqrt</a>          -  computes the square root of an unit object.
%   <a href="matlab:help unit/string">unit/string</a>        -  converts a unit object to a command string which will recreate the unit object.
%   <a href="matlab:help unit/times">unit/times</a>         -  implements times operator for unit objects.
%   <a href="matlab:help unit/toSI">unit/toSI</a>          -  converts the units to SI.
%   <a href="matlab:help unit/tolabel">unit/tolabel</a>       -  converts a unit object to LaTeX string suitable for use as axis labels.
%   <a href="matlab:help unit/unit">unit/unit</a>          -  a helper class for implementing units in LTPDA.
%   <a href="matlab:help unit/update_struct">unit/update_struct</a> -  update the input structure to the current ltpda version
%   <a href="matlab:help unit/xlabel">unit/xlabel</a>        -  place a xlabel on the given axes taking into account the units and
%   <a href="matlab:help unit/ylabel">unit/ylabel</a>        -  place a ylabel on the given axes taking into account the units and
%
%
%%%%%%%%%%%%%%%%%%%%   class: xydata   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help xydata/attachToDom">xydata/attachToDom</a>   - % Create empty xydata node with the attribute 'shape'
%   <a href="matlab:help xydata/copy">xydata/copy</a>          -  makes a (deep) copy of the input xydata objects.
%   <a href="matlab:help xydata/disp">xydata/disp</a>          -  overloads display functionality for xydata objects.
%   <a href="matlab:help xydata/fromDom">xydata/fromDom</a>       - % Get shape
%   <a href="matlab:help xydata/fromStruct">xydata/fromStruct</a>    -  creates from a structure a XYDATA object.
%   <a href="matlab:help xydata/loadobj">xydata/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help xydata/update_struct">xydata/update_struct</a> -  update the input structure to the current ltpda version
%   <a href="matlab:help xydata/xydata">xydata/xydata</a>        -  X-Y data object class constructor.
%
%
%%%%%%%%%%%%%%%%%%%%   class: xyzdata   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help xyzdata/attachToDom">xyzdata/attachToDom</a>   - % Create empty xyzdata node with the attribute 'shape'
%   <a href="matlab:help xyzdata/copy">xyzdata/copy</a>          -  makes a (deep) copy of the input xyzdata objects.
%   <a href="matlab:help xyzdata/disp">xyzdata/disp</a>          -  overloads display functionality for xyzdata objects.
%   <a href="matlab:help xyzdata/fromDom">xyzdata/fromDom</a>       - % Get shape
%   <a href="matlab:help xyzdata/fromStruct">xyzdata/fromStruct</a>    -  creates from a structure a XYZDATA object.
%   <a href="matlab:help xyzdata/loadobj">xyzdata/loadobj</a>       -  is called by the load function for user objects.
%   <a href="matlab:help xyzdata/update_struct">xyzdata/update_struct</a> -  update the input structure to the current ltpda version
%   <a href="matlab:help xyzdata/xyzdata">xyzdata/xyzdata</a>       - XZYDATA X-Y-Z data object class constructor.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@Assert   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@Assert/Assert">classes/tests/@Assert/Assert</a>                    -  A set of assert methods.
%   <a href="matlab:help classes/tests/@Assert/doubleEquals">classes/tests/@Assert/doubleEquals</a>              -  Assert that two doubles are equal.
%   <a href="matlab:help classes/tests/@Assert/doubleEqualsWithAccuracy">classes/tests/@Assert/doubleEqualsWithAccuracy</a>  -  Assert that two doubles are equal within some tolerance.
%   classes/tests/@Assert/doubleNotEquals           - (No help available)
%   classes/tests/@Assert/empty                     - (No help available)
%   <a href="matlab:help classes/tests/@Assert/fail">classes/tests/@Assert/fail</a>                      -  throws an AssertionFailed exception with the given message.
%   classes/tests/@Assert/false                     - (No help available)
%   classes/tests/@Assert/notEmpty                  - (No help available)
%   classes/tests/@Assert/notSame                   - (No help available)
%   <a href="matlab:help classes/tests/@Assert/objectEquals">classes/tests/@Assert/objectEquals</a>              -  Assert that two ltpda_obj objects are equal.
%   <a href="matlab:help classes/tests/@Assert/objectEqualsWithException">classes/tests/@Assert/objectEqualsWithException</a> -  Assert that two ltpda_obj objects are equal with an exception list.
%   classes/tests/@Assert/same                      - (No help available)
%   <a href="matlab:help classes/tests/@Assert/stringEquals">classes/tests/@Assert/stringEquals</a>              -  Assert that two strings are equal.
%   classes/tests/@Assert/stringNotEquals           - (No help available)
%   classes/tests/@Assert/throwsException           - (No help available)
%   <a href="matlab:help classes/tests/@Assert/true">classes/tests/@Assert/true</a>                      -  Assert that a condition is true.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@AssertionFailed   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@AssertionFailed/AssertionFailed">classes/tests/@AssertionFailed/AssertionFailed</a> -  sub-class of MException
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@TestDescription   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@TestDescription/TestDescription">classes/tests/@TestDescription/TestDescription</a> -  This class collects all information about a test.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_obj_tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_obj_tests/ltpda_obj_tests">classes/tests/@ltpda_obj_tests/ltpda_obj_tests</a> -  is the base class for all ltpda_obj object tests.
%   <a href="matlab:help classes/tests/@ltpda_obj_tests/test_char">classes/tests/@ltpda_obj_tests/test_char</a>       -  the char() method returns a non-empty string.
%   <a href="matlab:help classes/tests/@ltpda_obj_tests/test_copy">classes/tests/@ltpda_obj_tests/test_copy</a>       -  the copy() method works.
%   <a href="matlab:help classes/tests/@ltpda_obj_tests/test_display">classes/tests/@ltpda_obj_tests/test_display</a>    -  the display() method returns a non-empty string.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_test_runner   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_test_runner/get_builtin_model_tests">classes/tests/@ltpda_test_runner/get_builtin_model_tests</a> -  returns an array of test structures.
%   <a href="matlab:help classes/tests/@ltpda_test_runner/get_class_tests">classes/tests/@ltpda_test_runner/get_class_tests</a>         -  returns an array of test structures.
%   <a href="matlab:help classes/tests/@ltpda_test_runner/get_tests_for_class">classes/tests/@ltpda_test_runner/get_tests_for_class</a>     -  returns an array of test structures for a particular
%   <a href="matlab:help classes/tests/@ltpda_test_runner/get_tests_in_dir">classes/tests/@ltpda_test_runner/get_tests_in_dir</a>        -  returns an array of test structures for the test classes
%   <a href="matlab:help classes/tests/@ltpda_test_runner/ltpda_test_runner">classes/tests/@ltpda_test_runner/ltpda_test_runner</a>       -  can be used to run unit tests for LTPDA.
%   <a href="matlab:help classes/tests/@ltpda_test_runner/run_test_list">classes/tests/@ltpda_test_runner/run_test_list</a>           - GET_CLASS_TESTS runs all the tests specified in the array of test structures.
%   <a href="matlab:help classes/tests/@ltpda_test_runner/run_tests">classes/tests/@ltpda_test_runner/run_tests</a>               -  runs different configurations of units tests.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_uo_tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/ltpda_uo_tests">classes/tests/@ltpda_uo_tests/ltpda_uo_tests</a>      - LTPDA_OBJ_TESTS is the base class for all ltpda_obj objects.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_description">classes/tests/@ltpda_uo_tests/test_description</a>    -  the description is '' by default.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_name">classes/tests/@ltpda_uo_tests/test_name</a>           -  the name is 'None' by default.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_save_load">classes/tests/@ltpda_uo_tests/test_save_load</a>      -  the save and load methods work.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_setDescription">classes/tests/@ltpda_uo_tests/test_setDescription</a> -  the setting the description works.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_setName">classes/tests/@ltpda_uo_tests/test_setName</a>        -  the setting the name works.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_setUUID">classes/tests/@ltpda_uo_tests/test_setUUID</a>        -  the setting the UUID works.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_string">classes/tests/@ltpda_uo_tests/test_string</a>         -  the string method works.
%   <a href="matlab:help classes/tests/@ltpda_uo_tests/test_uuid">classes/tests/@ltpda_uo_tests/test_uuid</a>           -  the UUID is a non-empty string.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_uoh_method_tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/ltpda_uoh_method_tests">classes/tests/@ltpda_uoh_method_tests/ltpda_uoh_method_tests</a>  -  a series of tests for methods of ltpda_uoh
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/test_displayMethodInfo">classes/tests/@ltpda_uoh_method_tests/test_displayMethodInfo</a>  -  tests the method has a displayMethodInfo in the help.
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/test_getInfo">classes/tests/@ltpda_uoh_method_tests/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/test_history">classes/tests/@ltpda_uoh_method_tests/test_history</a>            -  tests the method correctly adds history.
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/test_preserves_plotinfo">classes/tests/@ltpda_uoh_method_tests/test_preserves_plotinfo</a> -  tests this method doesn't delete the plot info.
%   <a href="matlab:help classes/tests/@ltpda_uoh_method_tests/test_rebuild">classes/tests/@ltpda_uoh_method_tests/test_rebuild</a>            -  tests the output of the method can be rebuilt.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_uoh_tests   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/ltpda_uoh_tests">classes/tests/@ltpda_uoh_tests/ltpda_uoh_tests</a>                -  is the base class for all ltpda_uoh objects.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_history_empty_constructor">classes/tests/@ltpda_uoh_tests/test_history_empty_constructor</a> - Tests on the history field.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_history_setName">classes/tests/@ltpda_uoh_tests/test_history_setName</a>           - Tests on the history field when doing an operation like setName.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_plotinfo">classes/tests/@ltpda_uoh_tests/test_plotinfo</a>                  -  the plotinfo is [] by default.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_procinfo">classes/tests/@ltpda_uoh_tests/test_procinfo</a>                  -  the procinfo is [] by default.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_setPlotinfo">classes/tests/@ltpda_uoh_tests/test_setPlotinfo</a>               -  the setting the plotinfo works.
%   <a href="matlab:help classes/tests/@ltpda_uoh_tests/test_setProcinfo">classes/tests/@ltpda_uoh_tests/test_setProcinfo</a>               -  the setting the procinfo works.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ltpda_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ltpda_utp/char">classes/tests/@ltpda_utp/char</a>        -  convert a ltpda_utp object into a string.
%   <a href="matlab:help classes/tests/@ltpda_utp/copy">classes/tests/@ltpda_utp/copy</a>        -  makes a (deep) copy of the input ltpda_utp objects.
%   <a href="matlab:help classes/tests/@ltpda_utp/display">classes/tests/@ltpda_utp/display</a>     -  overloads display functionality for ltpda_utp objects.
%   <a href="matlab:help classes/tests/@ltpda_utp/getTestData">classes/tests/@ltpda_utp/getTestData</a> -  returns the testData array or an empty object of the correct
%   <a href="matlab:help classes/tests/@ltpda_utp/init">classes/tests/@ltpda_utp/init</a>        -  initialize the unit test class.
%   <a href="matlab:help classes/tests/@ltpda_utp/ltpda_utp">classes/tests/@ltpda_utp/ltpda_utp</a>   -  is the base class for ltpda unit test plan classes.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ut_result   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ut_result/ut_result">classes/tests/@ut_result/ut_result</a> -  encapsulates the result of running a single ltpda unit test.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/@ut_result_printer   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/@ut_result_printer/dump">classes/tests/@ut_result_printer/dump</a>                -  prints out tests results to the terminal.
%   <a href="matlab:help classes/tests/@ut_result_printer/printFailuresString">classes/tests/@ut_result_printer/printFailuresString</a> -  returns a string describing the test failures.
%   <a href="matlab:help classes/tests/@ut_result_printer/printRuntimeString">classes/tests/@ut_result_printer/printRuntimeString</a>  -  returns a string listing the run time of the tests.
%   <a href="matlab:help classes/tests/@ut_result_printer/printSummaryString">classes/tests/@ut_result_printer/printSummaryString</a>  -  returns a string summarising the tests.
%   <a href="matlab:help classes/tests/@ut_result_printer/ut_result_printer">classes/tests/@ut_result_printer/ut_result_printer</a>   -  displays results from an ltpda_test_runner.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@ltpda_vector_utp   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/ao/@ltpda_vector_utp/ltpda_vector_utp  - (No help available)
%   <a href="matlab:help classes/tests/ao/@ltpda_vector_utp/test_vector_input">classes/tests/ao/@ltpda_vector_utp/test_vector_input</a> -  a method with a vector of input objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_abs   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/ao/@test_ao_abs/test_ao_abs       - (No help available)
%   <a href="matlab:help classes/tests/ao/@test_ao_abs/test_vector_input">classes/tests/ao/@test_ao_abs/test_vector_input</a> - % set test data
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_ao   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_ao/test_ao_ao">classes/tests/ao/@test_ao_ao/test_ao_ao</a>     -  run tests on the AO constructor and associated methods.
%   <a href="matlab:help classes/tests/ao/@test_ao_ao/test_copy">classes/tests/ao/@test_ao_ao/test_copy</a>      -  the copy() method works for AOs.
%   <a href="matlab:help classes/tests/ao/@test_ao_ao/test_save_load">classes/tests/ao/@test_ao_ao/test_save_load</a> -  the save and load methods work for the AO class.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_ao_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_ao_table/test_ao_ao_table">classes/tests/ao/@test_ao_ao_table/test_ao_ao_table</a> - % cdata
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_cdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_cdata_table/test_ao_cdata_table">classes/tests/ao/@test_ao_cdata_table/test_ao_cdata_table</a> - % Only cdata objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_detectOutliers   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_detectOutliers/test_ao_detectOutliers">classes/tests/ao/@test_ao_detectOutliers/test_ao_detectOutliers</a> -  runs tests for the ao method detectOutliers.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_fsdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_fsdata_table/test_ao_fsdata_table">classes/tests/ao/@test_ao_fsdata_table/test_ao_fsdata_table</a> - % Only fsdata objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_objmeta_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_objmeta_table/test_ao_objmeta_table">classes/tests/ao/@test_ao_objmeta_table/test_ao_objmeta_table</a> - % cdata
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_powerFit   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_powerFit/test_ao_powerFit">classes/tests/ao/@test_ao_powerFit/test_ao_powerFit</a> -  runs tests for the ao method powerFit.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_subsData   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_subsData/test_ao_subsData">classes/tests/ao/@test_ao_subsData/test_ao_subsData</a> -  runs tests for the ao method subsData.
%   <a href="matlab:help classes/tests/ao/@test_ao_subsData/test_getInfo">classes/tests/ao/@test_ao_subsData/test_getInfo</a>     - Override getInfo test which is failing
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_tsdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_tsdata_table/test_ao_tsdata_table">classes/tests/ao/@test_ao_tsdata_table/test_ao_tsdata_table</a> - % Only tsdata objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ao/@test_ao_xydata_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ao/@test_ao_xydata_table/test_ao_xydata_table">classes/tests/ao/@test_ao_xydata_table/test_ao_xydata_table</a> - % Only xydata objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_ao_table   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/database/@ltpda_ao_table/ltpda_ao_table      - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_ao_table/test_ao_data_id">classes/tests/database/@ltpda_ao_table/test_ao_data_id</a>     - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_ao_table/test_ao_data_type">classes/tests/database/@ltpda_ao_table/test_ao_data_type</a>   - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_ao_table/test_ao_description">classes/tests/database/@ltpda_ao_table/test_ao_description</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_ao_table/test_ao_mfilename">classes/tests/database/@ltpda_ao_table/test_ao_mfilename</a>   - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_cdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/database/@ltpda_cdata_table/ltpda_cdata_table - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_cdata_table/test_cdata_xunits">classes/tests/database/@ltpda_cdata_table/test_cdata_xunits</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_cdata_table/test_cdata_yunits">classes/tests/database/@ltpda_cdata_table/test_cdata_yunits</a> - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_database   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/database/@ltpda_database/executeQuery">classes/tests/database/@ltpda_database/executeQuery</a>          - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_database/getTableEntry">classes/tests/database/@ltpda_database/getTableEntry</a>         - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_database/getTableIdFromTestObj">classes/tests/database/@ltpda_database/getTableIdFromTestObj</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_database/init">classes/tests/database/@ltpda_database/init</a>                  -  initialize the unit test class.
%   <a href="matlab:help classes/tests/database/@ltpda_database/ltpda_database">classes/tests/database/@ltpda_database/ltpda_database</a>        - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_fsdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/database/@ltpda_fsdata_table/ltpda_fsdata_table - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_fsdata_table/test_fsdata_fs">classes/tests/database/@ltpda_fsdata_table/test_fsdata_fs</a>     - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_fsdata_table/test_fsdata_xunits">classes/tests/database/@ltpda_fsdata_table/test_fsdata_xunits</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_fsdata_table/test_fsdata_yunits">classes/tests/database/@ltpda_fsdata_table/test_fsdata_yunits</a> - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_objmeta_table   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/init">classes/tests/database/@ltpda_objmeta_table/init</a>                             -  initialize the unit test class.
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/ltpda_objmeta_table">classes/tests/database/@ltpda_objmeta_table/ltpda_objmeta_table</a>              - s.experiment_title       = sprintf('%s with a struct - %s', experiment_title, tStr);
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_additional_authors">classes/tests/database/@ltpda_objmeta_table/test_objmeta_additional_authors</a>  - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_additional_comments">classes/tests/database/@ltpda_objmeta_table/test_objmeta_additional_comments</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_analysis_desc">classes/tests/database/@ltpda_objmeta_table/test_objmeta_analysis_desc</a>       - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_author">classes/tests/database/@ltpda_objmeta_table/test_objmeta_author</a>              - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_created">classes/tests/database/@ltpda_objmeta_table/test_objmeta_created</a>             - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_experiment_desc">classes/tests/database/@ltpda_objmeta_table/test_objmeta_experiment_desc</a>     - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_experiment_title">classes/tests/database/@ltpda_objmeta_table/test_objmeta_experiment_title</a>    - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_hostname">classes/tests/database/@ltpda_objmeta_table/test_objmeta_hostname</a>            - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_ip">classes/tests/database/@ltpda_objmeta_table/test_objmeta_ip</a>                  - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_keywords">classes/tests/database/@ltpda_objmeta_table/test_objmeta_keywords</a>            - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_name">classes/tests/database/@ltpda_objmeta_table/test_objmeta_name</a>                - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_obj_type">classes/tests/database/@ltpda_objmeta_table/test_objmeta_obj_type</a>            - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_os">classes/tests/database/@ltpda_objmeta_table/test_objmeta_os</a>                  - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_quantity">classes/tests/database/@ltpda_objmeta_table/test_objmeta_quantity</a>            - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_reference_ids">classes/tests/database/@ltpda_objmeta_table/test_objmeta_reference_ids</a>       - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_submitted">classes/tests/database/@ltpda_objmeta_table/test_objmeta_submitted</a>           - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_validated">classes/tests/database/@ltpda_objmeta_table/test_objmeta_validated</a>           - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_vdate">classes/tests/database/@ltpda_objmeta_table/test_objmeta_vdate</a>               - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_objmeta_table/test_objmeta_version">classes/tests/database/@ltpda_objmeta_table/test_objmeta_version</a>             - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_tsdata_table   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/database/@ltpda_tsdata_table/ltpda_tsdata_table - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_tsdata_table/test_tsdata_fs">classes/tests/database/@ltpda_tsdata_table/test_tsdata_fs</a>     - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_tsdata_table/test_tsdata_nsecs">classes/tests/database/@ltpda_tsdata_table/test_tsdata_nsecs</a>  - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_tsdata_table/test_tsdata_t0">classes/tests/database/@ltpda_tsdata_table/test_tsdata_t0</a>     - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_tsdata_table/test_tsdata_xunits">classes/tests/database/@ltpda_tsdata_table/test_tsdata_xunits</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_tsdata_table/test_tsdata_yunits">classes/tests/database/@ltpda_tsdata_table/test_tsdata_yunits</a> - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/database/@ltpda_xydata_table   %%%%%%%%%%%%%%%%%%%%
%
%   classes/tests/database/@ltpda_xydata_table/ltpda_xydata_table - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_xydata_table/test_xydata_xunits">classes/tests/database/@ltpda_xydata_table/test_xydata_xunits</a> - (No help available)
%   <a href="matlab:help classes/tests/database/@ltpda_xydata_table/test_xydata_yunits">classes/tests/database/@ltpda_xydata_table/test_xydata_yunits</a> - (No help available)
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ltpda_vector/@test_ltpda_vector   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ltpda_vector/@test_ltpda_vector/test_constructor">classes/tests/ltpda_vector/@test_ltpda_vector/test_constructor</a>  -  each constructor works
%   <a href="matlab:help classes/tests/ltpda_vector/@test_ltpda_vector/test_ltpda_vector">classes/tests/ltpda_vector/@test_ltpda_vector/test_ltpda_vector</a> -  run tests on the ltpda_vector constructor and associated methods.
%   <a href="matlab:help classes/tests/ltpda_vector/@test_ltpda_vector/test_xml">classes/tests/ltpda_vector/@test_ltpda_vector/test_xml</a>          -  adding to, and getting from, DOM works
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_model_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/ltpda_builtin_model_utp">classes/tests/models/@ltpda_builtin_model_utp/ltpda_builtin_model_utp</a>          -  is the base class for ltpda built-in model unit tests.
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_describe">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_describe</a>      -  that the built-in model responds to the 'describe' call
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_doc">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_doc</a>           -  that the built-in model responds to the 'doc' call
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_info">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_info</a>          -  that the built-in model responds to the 'info' call
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_modelOverview">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_modelOverview</a> -  that the built-in model works with minfo/modelOverview and that the
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_plist">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_plist</a>         -  that the built-in model responds to the 'plist' call.
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_plist_version">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_plist_version</a> -  that the built-in model has a default plist with a 'VERSION' key.
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_versions">classes/tests/models/@ltpda_builtin_model_utp/test_builtin_model_versions</a>      -  that all versions of the built-in model can be built, and re-built
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_ao_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_ao_utp/ltpda_builtin_models_ao_utp">classes/tests/models/@ltpda_builtin_models_ao_utp/ltpda_builtin_models_ao_utp</a> -  general UTP for analysis objects (AO) models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_collection_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_collection_utp/ltpda_builtin_models_collection_utp">classes/tests/models/@ltpda_builtin_models_collection_utp/ltpda_builtin_models_collection_utp</a> -  general UTP for collection models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_filterbank_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_filterbank_utp/ltpda_builtin_models_filterbank_utp">classes/tests/models/@ltpda_builtin_models_filterbank_utp/ltpda_builtin_models_filterbank_utp</a> -  general UTP for filterbank models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_matrix_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_matrix_utp/ltpda_builtin_models_matrix_utp">classes/tests/models/@ltpda_builtin_models_matrix_utp/ltpda_builtin_models_matrix_utp</a> -  general UTP for matrix models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_miir_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_miir_utp/ltpda_builtin_models_miir_utp">classes/tests/models/@ltpda_builtin_models_miir_utp/ltpda_builtin_models_miir_utp</a> -  general UTP for miir models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_smodel_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_smodel_utp/ltpda_builtin_models_smodel_utp">classes/tests/models/@ltpda_builtin_models_smodel_utp/ltpda_builtin_models_smodel_utp</a> -  general UTP for smodel models.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/models/@ltpda_builtin_models_ssm_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_ssm_utp/ltpda_builtin_models_ssm_utp">classes/tests/models/@ltpda_builtin_models_ssm_utp/ltpda_builtin_models_ssm_utp</a> -  general UTP for ssm models.
%   <a href="matlab:help classes/tests/models/@ltpda_builtin_models_ssm_utp/test_descriptions">classes/tests/models/@ltpda_builtin_models_ssm_utp/test_descriptions</a>            -  checks that the descriptions for the different fields
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_addParameters   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_addParameters/test_add_keyval">classes/tests/ssm/@test_ssm_addParameters/test_add_keyval</a>        -  tests adding a parameter by key/value pair.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_addParameters/test_add_plist">classes/tests/ssm/@test_ssm_addParameters/test_add_plist</a>         -  tests adding a parameter by plist.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_addParameters/test_getInfo">classes/tests/ssm/@test_ssm_addParameters/test_getInfo</a>           -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_addParameters/test_ssm_addParameters">classes/tests/ssm/@test_ssm_addParameters/test_ssm_addParameters</a> - % Make a test object
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_append   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_append/test_getInfo">classes/tests/ssm/@test_ssm_append/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_append/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_append/test_preserves_plotinfo</a> -  override because ssm objects don't do anything
%   <a href="matlab:help classes/tests/ssm/@test_ssm_append/test_ssm_append">classes/tests/ssm/@test_ssm_append/test_ssm_append</a>         - % Make an array of test objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_assemble   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_assemble/test_getInfo">classes/tests/ssm/@test_ssm_assemble/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_assemble/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_assemble/test_preserves_plotinfo</a> -  override because ssm objects don't do anything
%   <a href="matlab:help classes/tests/ssm/@test_ssm_assemble/test_ssm_assemble">classes/tests/ssm/@test_ssm_assemble/test_ssm_assemble</a>       - % Make an array of test objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_bode   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_bode/test_bode_all_inputs_outputs">classes/tests/ssm/@test_ssm_bode/test_bode_all_inputs_outputs</a> -  tests the bode method with all inputs and outputs.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_bode/test_getInfo">classes/tests/ssm/@test_ssm_bode/test_getInfo</a>                 -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_bode/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_bode/test_preserves_plotinfo</a>      -  override because ssm objects don't do anything
%   <a href="matlab:help classes/tests/ssm/@test_ssm_bode/test_ssm_bode">classes/tests/ssm/@test_ssm_bode/test_ssm_bode</a>                - % Make an array of test objects
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_cpsd   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_ao_input">classes/tests/ssm/@test_ssm_cpsd/test_ao_input</a>           -  tests the cpsd method with an input AOs.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_covariance_input">classes/tests/ssm/@test_ssm_cpsd/test_covariance_input</a>   -  tests the cpsd method with an input covariance
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_cpsd_input">classes/tests/ssm/@test_ssm_cpsd/test_cpsd_input</a>         -  tests the cpsd method with an input CPSD matrix.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_getInfo">classes/tests/ssm/@test_ssm_cpsd/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_cpsd/test_preserves_plotinfo</a> -  override because the output of cpsd is no longer
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_pzmodel_ao_input">classes/tests/ssm/@test_ssm_cpsd/test_pzmodel_ao_input</a>   -  tests the cpsd method with an input AOs and pzmodels.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsd/test_ssm_cpsd">classes/tests/ssm/@test_ssm_cpsd/test_ssm_cpsd</a>           - % Make a test object
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_ao_input">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_ao_input</a>                    -  tests the cpsdForCorrelatedInputs method with an input AOs.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_covariance_input">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_covariance_input</a>            -  tests the cpsdForCorrelatedInputs method with an input covariance
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_cpsd_input">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_cpsd_input</a>                  -  tests the cpsdForCorrelatedInputs method with an input CPSD matrix.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_getInfo">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_getInfo</a>                     -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_preserves_plotinfo</a>          -  override because the output of cpsdForCorrelatedInputs is no longer
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_pzmodel_ao_input">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_pzmodel_ao_input</a>            -  tests the cpsdForCorrelatedInputs method with an input AOs and pzmodels.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_ssm_cpsdForCorrelatedInputs">classes/tests/ssm/@test_ssm_cpsdForCorrelatedInputs/test_ssm_cpsdForCorrelatedInputs</a> - % Make a test object
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_psd   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_ao_input">classes/tests/ssm/@test_ssm_psd/test_ao_input</a>           -  tests the psd method with an input AOs.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_getInfo">classes/tests/ssm/@test_ssm_psd/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_psd/test_preserves_plotinfo</a> -  override because the output of psd is no longer
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_psd_input">classes/tests/ssm/@test_ssm_psd/test_psd_input</a>          -  tests the cpsd method with an input PSD matrix.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_ssm_psd">classes/tests/ssm/@test_ssm_psd/test_ssm_psd</a>            - % Make a test object
%   <a href="matlab:help classes/tests/ssm/@test_ssm_psd/test_variance_input">classes/tests/ssm/@test_ssm_psd/test_variance_input</a>     -  tests the psd method with an input variance vector.
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_reorganize   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_reorganize/test_getInfo">classes/tests/ssm/@test_ssm_reorganize/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_reorganize/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_reorganize/test_preserves_plotinfo</a> -  override because ssm objects don't do anything
%   <a href="matlab:help classes/tests/ssm/@test_ssm_reorganize/test_ssm_reorganize">classes/tests/ssm/@test_ssm_reorganize/test_ssm_reorganize</a>     - % Make a test object
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_simulate   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_ao_input">classes/tests/ssm/@test_ssm_simulate/test_ao_input</a>           -  tests the simulate method with an input AO.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_covariance_input">classes/tests/ssm/@test_ssm_simulate/test_covariance_input</a>   -  tests the simulate method with an input covariance
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_cpsd_input">classes/tests/ssm/@test_ssm_simulate/test_cpsd_input</a>         -  tests the simulate method with an input cpsd
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_getInfo">classes/tests/ssm/@test_ssm_simulate/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_simulate/test_preserves_plotinfo</a> -  override because the output of simulate is no longer
%   <a href="matlab:help classes/tests/ssm/@test_ssm_simulate/test_ssm_simulate">classes/tests/ssm/@test_ssm_simulate/test_ssm_simulate</a>       - % Make a test object
%
%
%%%%%%%%%%%%%%%%%%%%   path: classes/tests/ssm/@test_ssm_subsParameters   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help classes/tests/ssm/@test_ssm_subsParameters/test_getInfo">classes/tests/ssm/@test_ssm_subsParameters/test_getInfo</a>            -  tests getting the method info from the method.
%   <a href="matlab:help classes/tests/ssm/@test_ssm_subsParameters/test_preserves_plotinfo">classes/tests/ssm/@test_ssm_subsParameters/test_preserves_plotinfo</a> -  override because ssm objects don't do anything
%   <a href="matlab:help classes/tests/ssm/@test_ssm_subsParameters/test_ssm_subsParameters">classes/tests/ssm/@test_ssm_subsParameters/test_ssm_subsParameters</a> - % Make a test object
%   <a href="matlab:help classes/tests/ssm/@test_ssm_subsParameters/test_substitute">classes/tests/ssm/@test_ssm_subsParameters/test_substitute</a>         -  tests substituting parameters.
%
%
%%%%%%%%%%%%%%%%%%%%   path: examples   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help examples/ao_class_test">examples/ao_class_test</a>           - % AO_CLASS_TEST Test analysis object class
%   <a href="matlab:help examples/example_1">examples/example_1</a>               -  A test script for the AO implementation.
%   <a href="matlab:help examples/example_2">examples/example_2</a>               -  test script for the AO implementation.
%   <a href="matlab:help examples/make_test_ascii_file">examples/make_test_ascii_file</a>    -  a test ascii file with the name 'name.txt' containing a time-series
%   <a href="matlab:help examples/run_tests">examples/run_tests</a>               -  many tests
%   <a href="matlab:help examples/test_LTPDAprefs_cl_set">examples/test_LTPDAprefs_cl_set</a>  - Check that direct setting of LTPDA preferences is working.
%   <a href="matlab:help examples/test_abs">examples/test_abs</a>                -  abs() operator for AOs.
%   <a href="matlab:help examples/test_acos">examples/test_acos</a>               -  test acos() operator for analysis objects.
%   <a href="matlab:help examples/test_ao_1">examples/test_ao_1</a>               -  functionality of analysis objects.
%   <a href="matlab:help examples/test_ao_bilinfit">examples/test_ao_bilinfit</a>        -  ao/bilinfit for:
%   <a href="matlab:help examples/test_ao_cohere">examples/test_ao_cohere</a>          -  ao.cohere functionality.
%   <a href="matlab:help examples/test_ao_consolidate">examples/test_ao_consolidate</a>     -  tests the consolidate method of the AO class.
%   <a href="matlab:help examples/test_ao_cov">examples/test_ao_cov</a>             -  test cov() operator for analysis objects.
%   <a href="matlab:help examples/test_ao_cpsd">examples/test_ao_cpsd</a>            -  ao.cpsd functionality.
%   <a href="matlab:help examples/test_ao_detrend">examples/test_ao_detrend</a>         -  tests the detrend method of the AO class.
%   <a href="matlab:help examples/test_ao_downsample">examples/test_ao_downsample</a>      -  tests downsample method of AO class.
%   <a href="matlab:help examples/test_ao_fftfilt">examples/test_ao_fftfilt</a>         -  script for ao/fftfilt
%   <a href="matlab:help examples/test_ao_find">examples/test_ao_find</a>            -  test the find function of AO class.
%   <a href="matlab:help examples/test_ao_freq_series">examples/test_ao_freq_series</a>     - % Test script for frequency series AO constructor
%   <a href="matlab:help examples/test_ao_fromVals">examples/test_ao_fromVals</a>        -  construct AOs in different ways
%   <a href="matlab:help examples/test_ao_gapfilling">examples/test_ao_gapfilling</a>      -  test script for the ao.gapfilling method
%   <a href="matlab:help examples/test_ao_heterodyne">examples/test_ao_heterodyne</a>      - Tests for ao/heterodyne
%   <a href="matlab:help examples/test_ao_hist">examples/test_ao_hist</a>            -  tests the histogram function of the AO class.
%   <a href="matlab:help examples/test_ao_interp">examples/test_ao_interp</a>          -  tests the interp method of AO class.
%   <a href="matlab:help examples/test_ao_join_ts">examples/test_ao_join_ts</a>         -  test then join method of AO class for tsdata objects.
%   <a href="matlab:help examples/test_ao_lincom">examples/test_ao_lincom</a>          -  script for ao/lincom
%   <a href="matlab:help examples/test_ao_linedetect">examples/test_ao_linedetect</a>      - Tests for ao/linedetect
%   <a href="matlab:help examples/test_ao_linfit">examples/test_ao_linfit</a>          -  tests the linfit method of the AO class.
%   <a href="matlab:help examples/test_ao_lscov">examples/test_ao_lscov</a>           -  tests the lscov method of the AO class.
%   <a href="matlab:help examples/test_ao_plot">examples/test_ao_plot</a>            -  cases for ao/plot
%   <a href="matlab:help examples/test_ao_polyfit">examples/test_ao_polyfit</a>         -  tests the polyfit method of the AO class.
%   <a href="matlab:help examples/test_ao_pwelch">examples/test_ao_pwelch</a>          -  ao.pwelch functionality.
%   <a href="matlab:help examples/test_ao_removeVal">examples/test_ao_removeVal</a>       -  ao/removeVal for:
%   <a href="matlab:help examples/test_ao_rotate">examples/test_ao_rotate</a>          - % test the rotate method
%   <a href="matlab:help examples/test_ao_select">examples/test_ao_select</a>          -  test the select function of AO class.
%   <a href="matlab:help examples/test_ao_spikecleaning">examples/test_ao_spikecleaning</a>   -  test script for the spikecleaning method
%   <a href="matlab:help examples/test_ao_split">examples/test_ao_split</a>           -  AO split method.
%   <a href="matlab:help examples/test_ao_split_frequency">examples/test_ao_split_frequency</a> -  splitting a frequency-series AO by frequency using the split method.
%   <a href="matlab:help examples/test_ao_tfe">examples/test_ao_tfe</a>             -  ao.tfe functionality.
%   <a href="matlab:help examples/test_ao_timeaverage">examples/test_ao_timeaverage</a>     - % create a tsdata ao
%   <a href="matlab:help examples/test_ao_tsfcn">examples/test_ao_tsfcn</a>           -  AO constructor for TS function
%   <a href="matlab:help examples/test_ao_upsample">examples/test_ao_upsample</a>        -  tests upsample method of AO class.
%   <a href="matlab:help examples/test_ao_waveform">examples/test_ao_waveform</a>        -  test the waveform constructor for AO class.
%   <a href="matlab:help examples/test_ao_xfit">examples/test_ao_xfit</a>            - Tests for xfit
%   <a href="matlab:help examples/test_asin">examples/test_asin</a>               -  test asin() operator for analysis objects.
%   <a href="matlab:help examples/test_atan">examples/test_atan</a>               -  test atan() operator for analysis objects.
%   <a href="matlab:help examples/test_collection_history">examples/test_collection_history</a> - %%
%   <a href="matlab:help examples/test_collection_plot">examples/test_collection_plot</a>    - %% Plot 4 AOs
%   <a href="matlab:help examples/test_conj">examples/test_conj</a>               - Tests conj() operator for AOs.
%   <a href="matlab:help examples/test_cos">examples/test_cos</a>                -  test cos() operator for analysis objects.
%   <a href="matlab:help examples/test_ctranspose">examples/test_ctranspose</a>         -  ctranspose() operator for AOs.
%   <a href="matlab:help examples/test_det">examples/test_det</a>                -  ao.det method.
%   <a href="matlab:help examples/test_diag">examples/test_diag</a>               - Tests ao.diag method.
%   <a href="matlab:help examples/test_eig">examples/test_eig</a>                - Tests ao.eig method.
%   <a href="matlab:help examples/test_exp">examples/test_exp</a>                -  test exp() operator for analysis objects.
%   <a href="matlab:help examples/test_fft">examples/test_fft</a>                -  fft() operator for AOs.
%   <a href="matlab:help examples/test_filter_edges">examples/test_filter_edges</a>       -  tests if filter function correctly stores the state
%   <a href="matlab:help examples/test_fir_filter">examples/test_fir_filter</a>         -  test FIR filtering of AO class.
%   <a href="matlab:help examples/test_iir_filtering">examples/test_iir_filtering</a>      - A test script to test some IIR filtering commands.
%   <a href="matlab:help examples/test_inv">examples/test_inv</a>                - Tests ao.inv method.
%   <a href="matlab:help examples/test_iplot">examples/test_iplot</a>              -  test some aspects of iplot.
%   <a href="matlab:help examples/test_iplot_2">examples/test_iplot_2</a>            - %% When cdata contains a matrix
%   <a href="matlab:help examples/test_iplot_3">examples/test_iplot_3</a>            - Some iplot tests using the plotinfo
%   <a href="matlab:help examples/test_isequal">examples/test_isequal</a>            - %% This script test all parts of ltpda_obj/isequal
%   <a href="matlab:help examples/test_lincom_cdata">examples/test_lincom_cdata</a>       -  script for ao.lincom.
%   <a href="matlab:help examples/test_list">examples/test_list</a>               - A list of tests for running and installing in the toolbox as examples.
%   <a href="matlab:help examples/test_log10">examples/test_log10</a>              -  test log10() operator for analysis objects.
%   <a href="matlab:help examples/test_log_ln">examples/test_log_ln</a>             -  test log() operator for analysis objects.
%   <a href="matlab:help examples/test_lpsd">examples/test_lpsd</a>               - A test script for the AO implementation of lpsd.
%   <a href="matlab:help examples/test_ltpda_cohere">examples/test_ltpda_cohere</a>       -  ao.cohere functionality.
%   <a href="matlab:help examples/test_ltpda_cpsd">examples/test_ltpda_cpsd</a>         -  ao.cpsd functionality.
%   <a href="matlab:help examples/test_ltpda_lincom">examples/test_ltpda_lincom</a>       -  script for ao.lincom.
%   <a href="matlab:help examples/test_ltpda_linedetect">examples/test_ltpda_linedetect</a>   -  test script for ao.linedetect.
%   <a href="matlab:help examples/test_ltpda_ltfe">examples/test_ltpda_ltfe</a>         -  test the ao.ltfe method.
%   <a href="matlab:help examples/test_ltpda_nfest">examples/test_ltpda_nfest</a>        -  tests the ltpda_nfest noise-floor estimator.
%   <a href="matlab:help examples/test_ltpda_polydetrend">examples/test_ltpda_polydetrend</a>  -  script for ao.detrend
%   <a href="matlab:help examples/test_ltpda_pwelch">examples/test_ltpda_pwelch</a>       -  the LTPDA wrapping of pwelch.
%   <a href="matlab:help examples/test_ltpda_tfe">examples/test_ltpda_tfe</a>          -  ao.tfe functionality.
%   <a href="matlab:help examples/test_ltpda_xcorr">examples/test_ltpda_xcorr</a>        -  tests the cross-correlation function ltpda_xcorr.
%   <a href="matlab:help examples/test_matrix_plot">examples/test_matrix_plot</a>        - %% Plot 2x1
%   <a href="matlab:help examples/test_mean">examples/test_mean</a>               -  test mean() operator for analysis objects.
%   <a href="matlab:help examples/test_median">examples/test_median</a>             -  test median() operator for analysis objects.
%   <a href="matlab:help examples/test_mfir_class">examples/test_mfir_class</a>         -  tests run on mfir class.
%   <a href="matlab:help examples/test_miir_class">examples/test_miir_class</a>         -  the constructor for miir objects.
%   <a href="matlab:help examples/test_miir_filter">examples/test_miir_filter</a>        -  the ao/filter function for the miir class.
%   <a href="matlab:help examples/test_miir_filtfilt">examples/test_miir_filtfilt</a>      -  the filtfilt function for the miir class.
%   <a href="matlab:help examples/test_miir_redesign">examples/test_miir_redesign</a>      - When the filter command is given a standard filter designed for a
%   <a href="matlab:help examples/test_minus">examples/test_minus</a>              - A test script for the AO minus.
%   <a href="matlab:help examples/test_mpower">examples/test_mpower</a>             - A test script for the AO mpower.
%   <a href="matlab:help examples/test_norm">examples/test_norm</a>               -  ao.norm method.
%   <a href="matlab:help examples/test_plist_string">examples/test_plist_string</a>       - Tests string method of plist class.
%   <a href="matlab:help examples/test_plus">examples/test_plus</a>               - A test script for the AO plus.
%   <a href="matlab:help examples/test_pzm_to_fir">examples/test_pzm_to_fir</a>         -  tests converting pzmodel into an FIR filter
%   <a href="matlab:help examples/test_pzmodel_class">examples/test_pzmodel_class</a>      -  script for pzmodel class.
%   <a href="matlab:help examples/test_rdivide">examples/test_rdivide</a>            - A test script for the AO ./ .
%   <a href="matlab:help examples/test_recreate_1">examples/test_recreate_1</a>         - Testing features of 'recreate from history'.
%   <a href="matlab:help examples/test_resample">examples/test_resample</a>           -  resample function for AOs.
%   <a href="matlab:help examples/test_simulated_data">examples/test_simulated_data</a>     -  making simulated data AOs.
%   <a href="matlab:help examples/test_sin">examples/test_sin</a>                -  test sin() operator for analysis objects.
%   <a href="matlab:help examples/test_smodel_double">examples/test_smodel_double</a>      -  tests the double method of the SMODEL class.
%   <a href="matlab:help examples/test_smodel_eval">examples/test_smodel_eval</a>        -  tests the eval method of the SMODEL class.
%   <a href="matlab:help examples/test_sqrt">examples/test_sqrt</a>               -  test sqrt() operator for analysis objects.
%   <a href="matlab:help examples/test_std">examples/test_std</a>                -  test std() operator for analysis objects.
%   <a href="matlab:help examples/test_svd">examples/test_svd</a>                -  ao.svd method.
%   <a href="matlab:help examples/test_tan">examples/test_tan</a>                -  test tan() operator for analysis objects.
%   <a href="matlab:help examples/test_times">examples/test_times</a>              - A test script for the AO times.
%   <a href="matlab:help examples/test_transpose">examples/test_transpose</a>          -  transpose() operator for AOs.
%   <a href="matlab:help examples/test_tsdata_class">examples/test_tsdata_class</a>       -  script for tsdata class
%   <a href="matlab:help examples/test_var">examples/test_var</a>                -  test var() operator for analysis objects.
%   <a href="matlab:help examples/test_xml_complex">examples/test_xml_complex</a>        -  reading and writing complex data to XML file.
%   <a href="matlab:help examples/testing_xml">examples/testing_xml</a>             -  saving AO to xml
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/ao   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/ao/ao_model_gaussian_pulse">m/built_in_models/ao/ao_model_gaussian_pulse</a>       -  constructs a Gaussian pulse-function time-series
%   <a href="matlab:help m/built_in_models/ao/ao_model_notch">m/built_in_models/ao/ao_model_notch</a>                -  constructs a sine-wave time-series
%   <a href="matlab:help m/built_in_models/ao/ao_model_oscillator_sine">m/built_in_models/ao/ao_model_oscillator_sine</a>      -  built-in model of class ao called oscillator_sine
%   <a href="matlab:help m/built_in_models/ao/ao_model_oscillator_step">m/built_in_models/ao/ao_model_oscillator_step</a>      -  built-in model of class ao called oscillator_step
%   <a href="matlab:help m/built_in_models/ao/ao_model_padded_sine">m/built_in_models/ao/ao_model_padded_sine</a>          -  built-in model of class ao called padded_sine
%   <a href="matlab:help m/built_in_models/ao/ao_model_pulsetrain">m/built_in_models/ao/ao_model_pulsetrain</a>           -  constructs a pulse-train time-series from specified
%   <a href="matlab:help m/built_in_models/ao/ao_model_retrieve_in_timespan">m/built_in_models/ao/ao_model_retrieve_in_timespan</a> -  built-in model of class ao called retrieve_in_timespan
%   <a href="matlab:help m/built_in_models/ao/ao_model_sinewave">m/built_in_models/ao/ao_model_sinewave</a>             -  constructs a sine-wave time-series
%   <a href="matlab:help m/built_in_models/ao/ao_model_squarewave">m/built_in_models/ao/ao_model_squarewave</a>           -  constructs a square-wave time-series
%   <a href="matlab:help m/built_in_models/ao/ao_model_step">m/built_in_models/ao/ao_model_step</a>                 -  constructs a step-function time-series
%   <a href="matlab:help m/built_in_models/ao/ao_model_whitenoise">m/built_in_models/ao/ao_model_whitenoise</a>           -  constructs a known white-noise time-series
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/mfh   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_delay_ts">m/built_in_models/mfh/mfh_model_delay_ts</a>            -  constructs differentiated time-series
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_delayed_diff_ts">m/built_in_models/mfh/mfh_model_delayed_diff_ts</a>     -  constructs delayed differentiated time-series
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_delayed_filtered_ts">m/built_in_models/mfh/mfh_model_delayed_filtered_ts</a> -  constructs filtered time-series
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_diff_ts">m/built_in_models/mfh/mfh_model_diff_ts</a>             -  constructs differentiated time-series
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_fft_signals">m/built_in_models/mfh/mfh_model_fft_signals</a>         -  constructs the FFT of time-series
%   <a href="matlab:help m/built_in_models/mfh/mfh_model_loglikelihood">m/built_in_models/mfh/mfh_model_loglikelihood</a>       -  constructs a log-likelihood function
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/plist   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/plist/plist_model_physical_constants">m/built_in_models/plist/plist_model_physical_constants</a> -  constructs a PLIST with physical constants.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/smodel   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_oscillator_fd_tf">m/built_in_models/smodel/smodel_model_oscillator_fd_tf</a> -  built-in model of class ao called oscillator_fd_tf
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_oscillator_sine">m/built_in_models/smodel/smodel_model_oscillator_sine</a>  -  built-in model of class ao called oscillator_sine
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_oscillator_step">m/built_in_models/smodel/smodel_model_oscillator_step</a>  -  built-in model of class ao called oscillator_step
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_sinewave">m/built_in_models/smodel/smodel_model_sinewave</a>         -  built-in model of class ao called sinewave
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_squarewave">m/built_in_models/smodel/smodel_model_squarewave</a>       -  built-in model of class ao called squarewave
%   <a href="matlab:help m/built_in_models/smodel/smodel_model_step">m/built_in_models/smodel/smodel_model_step</a>             - A built-in model of class ao called step
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/ssm   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/ssm/ssm_model_HARMONIC_OSC_1D">m/built_in_models/ssm/ssm_model_HARMONIC_OSC_1D</a> -  A statespace model of the HARMONIC OSCILLATOR 1D
%   <a href="matlab:help m/built_in_models/ssm/ssm_model_SIMPLE_PENDULUM">m/built_in_models/ssm/ssm_model_SIMPLE_PENDULUM</a> -  A statespace model of a simple pendulum.
%   <a href="matlab:help m/built_in_models/ssm/ssm_model_SMD">m/built_in_models/ssm/ssm_model_SMD</a>             -  A statespace model of the Spring-Mass-Damper system
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/ssm/tests/@test_ssm_model_HARMONIC_OSC_1D   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/ssm/tests/@test_ssm_model_HARMONIC_OSC_1D/test_ssm_model_HARMONIC_OSC_1D">m/built_in_models/ssm/tests/@test_ssm_model_HARMONIC_OSC_1D/test_ssm_model_HARMONIC_OSC_1D</a> -  runs tests for the ssm built-in model 'HARMONIC_OSC_1D'.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/ssm/tests/@test_ssm_model_SIMPLE_PENDULUM   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/ssm/tests/@test_ssm_model_SIMPLE_PENDULUM/test_ssm_model_SIMPLE_PENDULUM">m/built_in_models/ssm/tests/@test_ssm_model_SIMPLE_PENDULUM/test_ssm_model_SIMPLE_PENDULUM</a> -  runs tests for the ssm built-in model 'SIMPLE_PENDULUM'.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/ssm/tests/@test_ssm_model_SMD   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/ssm/tests/@test_ssm_model_SMD/test_ssm_model_SMD">m/built_in_models/ssm/tests/@test_ssm_model_SMD/test_ssm_model_SMD</a> -  runs tests for the ssm built-in model 'SMD'.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@ltpda_waveform_signals_utp   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@ltpda_waveform_signals_utp/ltpda_waveform_signals_utp">m/built_in_models/test/ao/@ltpda_waveform_signals_utp/ltpda_waveform_signals_utp</a> -  extends the converted built-in
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_oscillator_sine   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_oscillator_sine/test_ao_model_oscillator_sine">m/built_in_models/test/ao/@test_ao_model_oscillator_sine/test_ao_model_oscillator_sine</a> -  runs tests for the ao built-in model oscillator_sine.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_oscillator_step   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_oscillator_step/test_ao_model_oscillator_step">m/built_in_models/test/ao/@test_ao_model_oscillator_step/test_ao_model_oscillator_step</a> -  runs tests for the ao built-in model oscillator_step.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_padded_sine   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_padded_sine/test_ao_model_padded_sine">m/built_in_models/test/ao/@test_ao_model_padded_sine/test_ao_model_padded_sine</a> -  runs tests for the ao built-in model padded_sine.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_retrieve_in_timespan   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_retrieve_in_timespan/test_ao_model_retrieve_in_timespan">m/built_in_models/test/ao/@test_ao_model_retrieve_in_timespan/test_ao_model_retrieve_in_timespan</a> -  runs tests for the ao built-in model retrieve_in_timespan.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_sinewave   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_sinewave/test_ao_model_sinewave">m/built_in_models/test/ao/@test_ao_model_sinewave/test_ao_model_sinewave</a> -  runs tests for the AO built-in model
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_squarewave   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_squarewave/test_ao_model_squarewave">m/built_in_models/test/ao/@test_ao_model_squarewave/test_ao_model_squarewave</a> -  runs tests for the AO built-in model
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_step   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_step/test_ao_model_step">m/built_in_models/test/ao/@test_ao_model_step/test_ao_model_step</a> -  runs tests for the AO built-in model
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ao/@test_ao_model_whitenoise   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ao/@test_ao_model_whitenoise/test_ao_model_whitenoise">m/built_in_models/test/ao/@test_ao_model_whitenoise/test_ao_model_whitenoise</a> -  runs tests for the AO built-in model
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_oscillator_fd_tf   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_oscillator_fd_tf/test_smodel_model_oscillator_fd_tf">m/built_in_models/test/smodel/@test_smodel_model_oscillator_fd_tf/test_smodel_model_oscillator_fd_tf</a> -  runs tests for the smodel built-in model oscillator_fd_tf.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_oscillator_sine   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_oscillator_sine/test_smodel_model_oscillator_sine">m/built_in_models/test/smodel/@test_smodel_model_oscillator_sine/test_smodel_model_oscillator_sine</a> -  runs tests for the smodel built-in model oscillator_sine.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_oscillator_step   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_oscillator_step/test_smodel_model_oscillator_step">m/built_in_models/test/smodel/@test_smodel_model_oscillator_step/test_smodel_model_oscillator_step</a> -  runs tests for the smodel built-in model oscillator_step.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_sinewave   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_sinewave/test_smodel_model_sinewave">m/built_in_models/test/smodel/@test_smodel_model_sinewave/test_smodel_model_sinewave</a> -  runs tests for the smodel built-in model sinewave.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_squarewave   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_squarewave/test_smodel_model_squarewave">m/built_in_models/test/smodel/@test_smodel_model_squarewave/test_smodel_model_squarewave</a> -  runs tests for the smodel built-in model squarewave.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/smodel/@test_smodel_model_step   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/smodel/@test_smodel_model_step/test_smodel_model_step">m/built_in_models/test/smodel/@test_smodel_model_step/test_smodel_model_step</a> -  runs tests for the smodel built-in model step.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ssm/@test_ssm_model_HARMONIC_OSC_1D   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ssm/@test_ssm_model_HARMONIC_OSC_1D/test_ssm_model_HARMONIC_OSC_1D">m/built_in_models/test/ssm/@test_ssm_model_HARMONIC_OSC_1D/test_ssm_model_HARMONIC_OSC_1D</a> -  runs tests for the ao built-in model HARMONIC_OSC_1D.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/built_in_models/test/ssm/@test_ssm_model_SMD   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/built_in_models/test/ssm/@test_ssm_model_SMD/test_ssm_model_SMD">m/built_in_models/test/ssm/@test_ssm_model_SMD/test_ssm_model_SMD</a> -  runs tests for the ao built-in model SMD.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/LTPDAprintf">m/etc/LTPDAprintf</a>      - % Process the text string
%   m/etc/LTPDAstartup     - (No help available)
%   <a href="matlab:help m/etc/gitHash">m/etc/gitHash</a>          -  reads and returns the git hash for this installation of LTPDA.
%   m/etc/ltpda_finish     - (No help available)
%   <a href="matlab:help m/etc/ltpda_mode">m/etc/ltpda_mode</a>       - Returns the current operating mode of LTPDA.
%   <a href="matlab:help m/etc/ltpda_run_method">m/etc/ltpda_run_method</a> -  runs an LTPDA method inside a script environment to
%   <a href="matlab:help m/etc/ltpda_startup">m/etc/ltpda_startup</a>    - This is the startup file for ltpda. It should be run once in the MATLAB
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc/cprintf   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/cprintf/cprintf">m/etc/cprintf/cprintf</a> -  displays styled formatted text in the Command Window
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc/matlabmultinest/Examples   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_eggbox">m/etc/matlabmultinest/Examples/example_eggbox</a>                                 - example: an eggbox function
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_line">m/etc/matlabmultinest/Examples/example_line</a>                                   - example: (from hogg et al., 1008.4686)
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_line_with_outliers">m/etc/matlabmultinest/Examples/example_line_with_outliers</a>                     - example: (from hogg et al., 1008.4686)
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_line_with_outliers_and_marginalization">m/etc/matlabmultinest/Examples/example_line_with_outliers_and_marginalization</a> - example: (from hogg et al., 1008.4686)
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_sinusoid">m/etc/matlabmultinest/Examples/example_sinusoid</a>                               - example: estimate amplitude and initial phase of a
%   <a href="matlab:help m/etc/matlabmultinest/Examples/example_triangle">m/etc/matlabmultinest/Examples/example_triangle</a>                               - example: a triangular likelihood function
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc/matlabmultinest/NSMain   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/calc_ellipsoid">m/etc/matlabmultinest/NSMain/calc_ellipsoid</a>                   - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/draw_from_ellipsoid">m/etc/matlabmultinest/NSMain/draw_from_ellipsoid</a>              - function pnts = draw_from_ellipsoid(B, mu, N )
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/draw_mcmc">m/etc/matlabmultinest/NSMain/draw_mcmc</a>                        - function [sample, logL] = draw_mcmc(livepoints, cholmat, logLmin, ...
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/draw_multinest">m/etc/matlabmultinest/NSMain/draw_multinest</a>                   - function [sample, logL] = draw_multinest(fracvol, Bs, mus, ...
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/in_ellipsoids">m/etc/matlabmultinest/NSMain/in_ellipsoids</a>                    - function N = in_ellipsoids(pnt, Bs, mus)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/logplus">m/etc/matlabmultinest/NSMain/logplus</a>                          - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/mchol">m/etc/matlabmultinest/NSMain/mchol</a>                            - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/nest2pos">m/etc/matlabmultinest/NSMain/nest2pos</a>                         - Convert a set of nested sample chains (each containing the same
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/nested_sampler">m/etc/matlabmultinest/NSMain/nested_sampler</a>                   - function [logZ, nest_samples, post_samples] = nested_sampler(data, ...
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/optimal_ellipsoids">m/etc/matlabmultinest/NSMain/optimal_ellipsoids</a>               - function [Bs, mus, VEs, ns] = optimal_ellipsoids(u, VS)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/plot_2d_livepoints_with_ellipses">m/etc/matlabmultinest/NSMain/plot_2d_livepoints_with_ellipses</a> - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/rescale_parameters">m/etc/matlabmultinest/NSMain/rescale_parameters</a>               - scaled = rescale_parameters(prior, params)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/scale_parameters">m/etc/matlabmultinest/NSMain/scale_parameters</a>                 - scaled = scale_parameters(prior, params)
%   <a href="matlab:help m/etc/matlabmultinest/NSMain/split_ellipsoid">m/etc/matlabmultinest/NSMain/split_ellipsoid</a>                  - function [u1, u2, VE1, VE2, nosplit] = split_ellipsiod(u, VS)
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc/matlabmultinest/Unsorted   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/draw_from_torus">m/etc/matlabmultinest/Unsorted/draw_from_torus</a>          - function pnts = draw_from_torus(a, b,  N )
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/eggbox_model">m/etc/matlabmultinest/Unsorted/eggbox_model</a>             - An "eggbox"-like model with N dimensions
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/ellipsoid_2d">m/etc/matlabmultinest/Unsorted/ellipsoid_2d</a>             - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/ellipsoid_3d">m/etc/matlabmultinest/Unsorted/ellipsoid_3d</a>             - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/hist2">m/etc/matlabmultinest/Unsorted/hist2</a>                    - function histmat  = hist2(x, y, xedges, yedges)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/line_model">m/etc/matlabmultinest/Unsorted/line_model</a>               - y = line_model(x, parnames, parvals)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/logL_gaussian">m/etc/matlabmultinest/Unsorted/logL_gaussian</a>            -  = logL_gaussian(data, model, parnames, parvals)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/logL_mixture_gaussian">m/etc/matlabmultinest/Unsorted/logL_mixture_gaussian</a>    -  = logL_mixture_gaussian(data, model, parnames, parvals)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/logL_model_likelihood">m/etc/matlabmultinest/Unsorted/logL_model_likelihood</a>    - check whether model is a string or function handle
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/logt">m/etc/matlabmultinest/Unsorted/logt</a>                     - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/posteriors">m/etc/matlabmultinest/Unsorted/posteriors</a>               - function posteriors(post_samples, wp)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/readdata_line">m/etc/matlabmultinest/Unsorted/readdata_line</a>            - (No help available)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/sinusoid_model">m/etc/matlabmultinest/Unsorted/sinusoid_model</a>           - function y = sinusoid_model(t, parnames, parvals)
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/test_draw_from_ellipsoid">m/etc/matlabmultinest/Unsorted/test_draw_from_ellipsoid</a> - script to test draw from ellipsoid
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/test_optimal_ellipsoids">m/etc/matlabmultinest/Unsorted/test_optimal_ellipsoids</a>  - script to test optimal_ellipsoids.m program
%   <a href="matlab:help m/etc/matlabmultinest/Unsorted/triangle_model">m/etc/matlabmultinest/Unsorted/triangle_model</a>           - check that parnames and parvals have the same length
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/etc/shadedErrorBar   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/etc/shadedErrorBar/shadedErrorBar">m/etc/shadedErrorBar/shadedErrorBar</a> - function H=shadedErrorBar(x,y,errBar,lineProps,transparent)
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/gui/@jcontrol   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/gui/@jcontrol/ancestor">m/gui/@jcontrol/ancestor</a>   -  function overloaded as JCONTROL method
%   <a href="matlab:help m/gui/@jcontrol/close">m/gui/@jcontrol/close</a>      -  methods overloaded for JCONTROL objects
%   <a href="matlab:help m/gui/@jcontrol/delete">m/gui/@jcontrol/delete</a>     -  method overloaded for the JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/get">m/gui/@jcontrol/get</a>        -  method overloaded for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/getappdata">m/gui/@jcontrol/getappdata</a> -  function overloaded for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/isappdata">m/gui/@jcontrol/isappdata</a>  -  function oveloaded for the JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/jcontrol">m/gui/@jcontrol/jcontrol</a>   -  constructor for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/rmappdata">m/gui/@jcontrol/rmappdata</a>  -  function oveloaded for the JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/set">m/gui/@jcontrol/set</a>        -  method overloaded for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/setappdata">m/gui/@jcontrol/setappdata</a> -  function overloaded for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/subsasgn">m/gui/@jcontrol/subsasgn</a>   -  method overloaded for JCONTROL class
%   <a href="matlab:help m/gui/@jcontrol/subsref">m/gui/@jcontrol/subsref</a>    -  method overloaded for jcontrol class
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/gui/@jcontrol/private   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/gui/@jcontrol/private/VisibleProperty">m/gui/@jcontrol/private/VisibleProperty</a> -  - helper function for JCONTROL methods
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/gui/pzmodel_designer   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/gui/pzmodel_designer/pzmodel_helper">m/gui/pzmodel_designer/pzmodel_helper</a> - %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/gui/quicklook   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/gui/quicklook/ltpdaquicklook">m/gui/quicklook/ltpdaquicklook</a> -  allows the user to quicklook LTPDA objects.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/gui/specwin_viewer   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/gui/specwin_viewer/ltpda_specwin_viewer_build_window">m/gui/specwin_viewer/ltpda_specwin_viewer_build_window</a> - Function to build the window and display it.
%   <a href="matlab:help m/gui/specwin_viewer/ltpda_specwin_viewer_close">m/gui/specwin_viewer/ltpda_specwin_viewer_close</a>        - Callback executed when the GUI is closed
%   <a href="matlab:help m/gui/specwin_viewer/ltpda_specwin_viewer_wintype">m/gui/specwin_viewer/ltpda_specwin_viewer_wintype</a>      - Callback executed when the user selects a window
%   <a href="matlab:help m/gui/specwin_viewer/specwin_viewer">m/gui/specwin_viewer/specwin_viewer</a>                    -  allows the user to explore spectral windows.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/helper   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/helper/addHistoryStep">m/helper/addHistoryStep</a>        -  Adds a history step of a non LTPDA method to  object with history.
%   <a href="matlab:help m/helper/generateModelTechNote">m/helper/generateModelTechNote</a> - % Header
%   <a href="matlab:help m/helper/keys">m/helper/keys</a>                  -  prints parameter list keys to the terminal.
%   <a href="matlab:help m/helper/mc">m/helper/mc</a>                    - A function to properly clear MATLAB memory for LTPDA.
%
%
%%%%%%%%%%%%%%%%%%%%   path: m/sigproc/frequency_domain   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help m/sigproc/frequency_domain/ltpda_spsd">m/sigproc/frequency_domain/ltpda_spsd</a> -  smooths a spectrum.
%   <a href="matlab:help m/sigproc/frequency_domain/phasetrack">m/sigproc/frequency_domain/phasetrack</a> - % Check if this is a call for parameters, the CVS version string
%
%
%%%%%%%%%%%%%%%%%%%%   path: src   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help src/compileAll">src/compileAll</a> -  all necessary mex files.
%
%
%%%%%%%%%%%%%%%%%%%%   path: src/ltpda_dft   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help src/ltpda_dft/compile">src/ltpda_dft/compile</a>             -  package within MATLAB
%   <a href="matlab:help src/ltpda_dft/ltpda_dft">src/ltpda_dft/ltpda_dft</a>           -  computes the DFT of a signal at one frequency.
%   src/ltpda_dft/polyregz            - (No help available)
%   <a href="matlab:help src/ltpda_dft/test_ltpda_lpsd_new">src/ltpda_dft/test_ltpda_lpsd_new</a> - function test_ltpda_lpsd_new()
%
%
%%%%%%%%%%%%%%%%%%%%   path: src/ltpda_polyreg   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help src/ltpda_polyreg/compile">src/ltpda_polyreg/compile</a>            -  package within MATLAB
%   <a href="matlab:help src/ltpda_polyreg/ltpda_polyreg">src/ltpda_polyreg/ltpda_polyreg</a>      -  detrends an input vector with a given order.
%   <a href="matlab:help src/ltpda_polyreg/test_ltpda_polyreg">src/ltpda_polyreg/test_ltpda_polyreg</a> - function test_ltpda_polydetrend()
%
%
%%%%%%%%%%%%%%%%%%%%   path: src/ltpda_smoother   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help src/ltpda_smoother/compile">src/ltpda_smoother/compile</a>        -  package within MATLAB
%   <a href="matlab:help src/ltpda_smoother/ltpda_smoother">src/ltpda_smoother/ltpda_smoother</a> -  A mex file to compute a running smoothing filter.
%   <a href="matlab:help src/ltpda_smoother/test_mnfest">src/ltpda_smoother/test_mnfest</a>    - % Create test data
%
%
%%%%%%%%%%%%%%%%%%%%   path: src/ltpda_ssmsim   %%%%%%%%%%%%%%%%%%%%
%
%   <a href="matlab:help src/ltpda_ssmsim/compile">src/ltpda_ssmsim/compile</a>           -  package within MATLAB
%   src/ltpda_ssmsim/do_a_run          - (No help available)
%   src/ltpda_ssmsim/do_a_run_mat      - (No help available)
%   <a href="matlab:help src/ltpda_ssmsim/ltpda_ssmsim">src/ltpda_ssmsim/ltpda_ssmsim</a>      -  A mex file to propagate an input signal for a given SS model.
%   src/ltpda_ssmsim/mat_ssmsim        - (No help available)
%   <a href="matlab:help src/ltpda_ssmsim/test_ltpda_ssmsim">src/ltpda_ssmsim/test_ltpda_ssmsim</a> - %
%   src/ltpda_ssmsim/validate_mex      - (No help available)
%
%
