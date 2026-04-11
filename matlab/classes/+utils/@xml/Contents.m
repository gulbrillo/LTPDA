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
