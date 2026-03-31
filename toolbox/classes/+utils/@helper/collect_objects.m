% COLLECT_OBJECTS Collect objects of the required class.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COLLECT_OBJECTS Collect objects of the required class.
%
% CALL:        [objs, invars, rest] = collect_objects(varargin, class_type, in_names);
%              [objs, invars]       = collect_objects(varargin, class_type, in_names);
%              [objs]               = collect_objects(varargin, class_type, in_names);
%              [objs]               = collect_objects(varargin, class_type);
%              [objs]               = collect_objects(varargin, '');
%
% INPUTS:      varargin:   Cell array of objects
%              class_name: Class name of the collected objects
%                          If the class_name is empty then this function
%                          collects all objects of the same class as
%                          the first ltpda_object.
%              in_names:   Cell array of corresponding variable names of
%                          the contents in varargin
%
% OUTPUTS:     objs:   Collection of all required class objects.
%              invars: Collection of the object names of the corresponding object.
%              rest:   Rest of all other objects collected in a cell array.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = collect_objects(varargin, class_type, in_names)
  
  %%% collect input objects and corresponding variable names
  
  %%% If the class_type is empty then collect all objects of the first ltpda object
  if isempty(class_type)
    for ii = 1:length(varargin)
      if isa(varargin{ii}, 'ltpda_obj')
        class_type = class(varargin{ii});
        break;
      end
    end
  end
  
  % Count the number of arguments that contain this class type
  Narg = length(varargin);
  classmatch = zeros(Narg,1);
  Nclass = 0;
  for ii=1:Narg
    if isa(varargin{ii}, class_type)
      classmatch(ii) = 1;
      Nclass = Nclass + 1;
    end
  end
  
  invars = {};
  objs   = [];
  other  = {};
  
  for ii=1:Narg
    vii  = varargin{ii};
    if classmatch(ii)
      if Nclass == 1
        objs = vii;
      else
        if numel(vii) == 1
          objs = [objs vii];
        else
          objs = [objs reshape(vii, 1, [])];
        end
      end
      
      %%% Define the variable name only if the input names are specified.
      if nargin == 3 && nargout > 1
        
        % It is possible for a internal-call that in_names is empty
        % Create forthis an empty cell-array wit the size of varargin
        if isempty(in_names)
          in_names = cell(size(varargin));
        end
        
        def_name = in_names{ii};
        if isempty(def_name)
          def_name = 'unknown';
        end
        
        % Memorise the variable name of the corresponding object.
        % If the object is an array or vector add the index to the variable name
        %
        % we choose the object name if it is not set to the default
        % and it's not empty.
        if (numel(vii) == 1) || (numel(vii) == 0)
          if classmatch(ii)
            try
              if ~strncmpi(vii.name, 'None', 4)
                if ~isempty(vii.name)
                  def_name = vii.name;
                end
              end
            end
          end
          invars{end+1} = def_name;
        elseif classmatch(ii)
          if isa(vii, 'ltpda_uo')
            % Check the elements have all the same names
            sameNames = true;
            name = vii(1).name;
            for jj=2:numel(vii)
              if ~strcmp(name, vii(jj).name)
                sameNames = false;
                break;
              end
            end
            
            if sameNames
              if ~strcmpi(vii(1).name, 'None') && ~isempty(vii(1).name)
                def_name = vii(1).name;
              end
              Nargii = size(vii,1);
              for jj=1:numel(vii)
                invars{end+1} = mind2subStr(def_name, Nargii,jj);
              end
            else
              for jj=1:numel(vii)
                invars{end+1} = vii(jj).name;
              end
            end
          else
            % The objects don't have a 'name'
            Nargii = size(vii,1);
            for jj=1:numel(vii)
              invars{end+1} = mind2subStr(def_name, Nargii,jj);
            end
          end
        else
          invars{end+1} = def_name;
        end
      end
      
    else
      if nargout > 2
        other{end+1} = vii;
      end
    end
    
  end
  
  % Collect outputs
  if nargout >= 1
    varargout{1} = objs;
  end
  if nargout >= 2
    varargout{2} = invars;
  end
  if nargout >= 3
    varargout{3} = other;
  end
end

%--------------------------------------------------------
% A much simplified special case of ind2sub to collect just
% the names.
%
function s = mind2subStr(name, siz, ndx)
  
  % Get J
  vi = rem(ndx-1, siz) + 1;
  J  = (ndx-vi)/siz + 1;
  
  % Get I
  ndx = vi;
  vi  = rem(ndx-1, 1) + 1;
  s = sprintf('%s(%d,%d)', name, (ndx - vi) + 1,J);
end
