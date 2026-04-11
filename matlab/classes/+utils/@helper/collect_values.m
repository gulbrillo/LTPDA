% COLLECT_VALUES convert numeric values in to AOs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: COLLECT_VALUES convert numeric values in to AOs.
%
% This provides additional functionality to the collect_objects method.
% This method collects any single valued numerical data from the input
% arguments (args), and converts them to cdata AOs.
%
% Typicall usage in a class method would be:
%
% args = utils.helper.collect_values(varargin(:));
% [as, ao_invars] = utils.helper.collect_objects(args, 'ao', in_names);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function args = collect_values(args)
  
  % We need to check what kind of object to promote numeric values to.
  const = 'ao'; % as default we promote to an AO
  for jj=1:numel(args)
    if isa(args{jj}, 'ltpda_uoh')
      const = class(args{jj});
    end
  end
  
  for jj=1:numel(args)
    if isnumeric(args{jj})
      if ~(isvector(args{jj}))
        name = mat2str(args{jj});
      else
        name = num2str(args{jj});
      end
      args{jj} = feval(const, args{jj});
      args{jj}.setName(name);
    end
  end

end
