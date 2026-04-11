% HELPER helper class for helpful utility functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: HELPER is a helper class for helpful utility functions.
%
% To see the available static methods, call
%
% >> methods utils.helper
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef helper

  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)


    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    
    varargout = isdeprecated(varargin)
    
    varargout = eq2eps(varargin)
    
    varargout = checkFilterOptions(varargin)
    varargout = setoutputs(varargin)
    varargout = isSubclassOf(varargin)
    
    varargout = getPublicMethods(varargin)
    varargout = getUserClasses(varargin)
    varargout = getClasses(varargin)
    
    varargout = parseMethodInfo(varargin); % Parse, params/version/category call
    varargout = collect_objects(varargin)
    [as, ao_invars] = collect_values(args, as, ao_invars)
    varargout = objdisp(varargin)

    varargout = isobject(varargin)
    varargout = ltpda_classes(varargin)
    varargout = ltpda_non_abstract_classes(varargin)
    classes   = ltpda_userclasses(varargin)
    varargout = ltpda_categories()
    pl        = class2plist(varargin)
    str       = mat2str(number)
    str       = num2str(number)
    str       = val2str(varargin)
    varargout = createUniqueNames(varargin)
    varargout = saveobj(a, pl)
    varargout = plotTraces(varargin)

    varargout = classFromStruct(varargin)
    varargout = getClassFromStruct(varargin)
    varargout = getObjectFromStruct(varargin)
    
    ver_num   = ver2num(ver_str)
    
    varargout = isinfocall(varargin)
    varargout = generic_getInfo(varargin)
    
    varargout = ismember(varargin)

    varargout = obj2tex(varargin)

    varargout = msg(varargin)
    varargout = msg_nnl(varargin)
    varargout = err(varargin)
    varargout = warn(varargin)
    varargout = warn_no_bt(varargin)
    
    varargout = dzip(varargin)
    varargout = dunzip(varargin)
    
    errorDlg(msg, title)
    warnDlg(msg, title)
    
    varargout = feval(varargin)
    
    [t, y] = time_data_worsener(t, y, miss_fraction, shift_fraction, shift_range)

    pl                    = process_spectral_options(pl, type, varargin)
    [var, n, pl]          = process_smodel_diff_options(pl, rest);
    [in_var, ret_var, pl] = process_smodel_transf_options(pl, rest);
    
    res = isSubmissionPlist(pl)
    
    varargout = jArrayList2CellArray(varargin)
    varargout = getHelpPath();
    varargout = displayMethodInfo(varargin)
    varargout = displayConstructorExamples(varargin)
    
    varargout     = callerIsMethod(varargin)
    
    [avgT,stdT]=CPUbenchmark
    
    newpath = remove_cvs_from_matlabpath(oldpath)
    newpath = remove_svn_from_matlabpath(oldpath)
    newpath = remove_git_from_matlabpath(oldpath)
    
    varargout = getDefaultValue(varargin)
    varargout = genvarname(varargin)
    varargout = truncateString(varargin)
    
    varargout = buildSearchDatabase(varargin)
    
    varargout = addLicenseToFile(varargin)
    
    varargout = extractTransitionTimes(varargin)
    
    contents = readGZip(filename)
    
    %-------------------------------------------------------------
    %-------------------------------------------------------------

    % Check MATLAB version
    checkMatlabVersion
    
    % Plot class diagram
    make_class_diagram(varargin)

  end % End static methods


end

% END
