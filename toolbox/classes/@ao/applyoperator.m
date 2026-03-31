% APPLYOPERATOR to the analysis object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: APPLYOPERATOR to the analysis object
%              Private AO function that applies the given operator to
%              the given AOs. This is called by all the simple methods like
%              plus, minus, mtimes etc.
%
% CALL:        as = applyoperator(callerIsMethod, as, ao_invars, op, opsym, pl, info)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function res = applyoperator(as, callerIsMethod, ao_invars, op, opsym, pl, info)

  %% Initialise the result to the first input object
  res = as(1);

  %% go through the remaining analysis objects
  for jj = 2:numel(as)

    % Message
    utils.helper.msg(2, 'applying %s to %s and %s', op, res.name, as(jj).name);

    % Compute operator of data
    yu1 = res.data.yunits;
    yu2 = as(jj).data.yunits;
    res.data = applyoperator(res.data, as(jj).data, op);

    if callerIsMethod
      % do nothing
    else
      % append history
      res.addHistory(info, pl, [{res.name} ao_invars(jj)], [res.hist as(jj).hist]);
      
      % Set new AO name
      if  (length(opsym) == 2 && opsym(1) == '.') || ...
          (length(opsym) == 1)
        res.name = ['(' ao_invars{1} ')' opsym '(' ao_invars{jj} ')'];
      else
        res.name = [opsym '(' ao_invars{1} ',' ao_invars{jj} ')'];
      end
    end

    if any(strcmp(op, {'plus', 'minus'}))
      % Do nothing
    elseif ismethod('unit', op)
      % Set units
      if any(strcmp(op, {'mpower', 'power'})) 
        if numel(as(jj).data.getY) == 1
          res.data.setYunits(feval(op, yu1, as(jj).data.getY));
        else
        end
      else
        res.data.setYunits(feval(op, yu1, yu2));
      end
    else
      warning('LTPDA:INFO', '### This method doesn''t exist in the units class. Please set the units yourself.');
    end

  end

end

