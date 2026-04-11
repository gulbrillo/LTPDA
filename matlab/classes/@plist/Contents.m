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
