% XML helper class for helpful xml functions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: XML is a helper class for helpful xml functions.
%
% To see the available static methods, call
%
% >> methods utils.xml
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef xml
  
  properties (Constant = true)
    WILDCARD_CVS = '(ID)';
    WILDCARD_NEWLINE = '(NL)';
    
    MAX_DOUBLE_IN_ROW = 50000;
    MAX_IMAG_IN_ROW   = 1000;
    MAX_NUM_IN_MATRIX = 2500;
    
%     FACTORY = javax.xml.xpath.XPathFactory.newInstance();
%     XPATH   = utils.xml.FACTORY.newXPath();
  end
  
  %------------------------------------------------
  %--------- Declaration of Static methods --------
  %------------------------------------------------
  methods (Static)
    
    %-------------------------------------------------------------
    % List other methods
    %-------------------------------------------------------------
    
    % sinfo methods
    varargout = read_sinfo_xml(varargin)
    varargout = save_sinfo_xml(varargin)
    
    % xml methods
    varargout = getCell(varargin)
    varargout = getCellstr(varargin)
    varargout = getFromType(varargin)
    varargout = getMatrix(varargin)
    varargout = getNumber(varargin)
    varargout = getObject(varargin)
    varargout = getShape(varargin)
    varargout = getString(varargin)
    varargout = getStruct(varargin)
    varargout = getSym(varargin)
    varargout = getType(varargin)
    varargout = getVector(varargin)
    
    % attach methods
    varargout = attachCellToDom(varargin)
    varargout = attachCellstrToDom(varargin)
    varargout = attachCharToDom(varargin)
    varargout = attachEmptyObjectNode(varargin)
    varargout = attachMatrixToDom(varargin)
    varargout = attachNumberToDom(varargin)
    varargout = attachStructToDom(varargin)
    varargout = attachSymToDom(varargin)
    varargout = attachVectorToDom(varargin)
    
    % get Nodes with xpath
    varargout = getChildByName(varargin)
    varargout = getChildrenByName(varargin)
    
    % misc methods
    varargout = mchar(varargin) % Convert java String to MATLAB char
    varargout = num2str(varargin) % Convert numbers to a string.
    varargout = mat2str(varargin) % Convert a matrix or vector into a string
    varargout = cellstr2str(varargin) % Convert a cell with strings into a string
    
    varargout = prepareVersionString(varargin)
    varargout = prepareString(varargin)
    varargout = recoverVersionString(varargin)
    varargout = recoverString(varargin)
    
    varargout = getHistoryFromUUID(varargin)
    
    % old xml methods
    values    = xmlread(node, obj_name)
    varargout = xmlwrite(objs, xml, parent, property_name)
    
  end % End static methods
  
  
end

