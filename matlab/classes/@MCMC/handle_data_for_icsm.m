%
% Utility function to handle the noise data.
% 
% It trims samples from the data time-series and
% creates AO time-series according to the type of
% the MFH models.
%
% NK 2014
%
function v = handle_data_for_icsm(n, x, Nout, trim, fs, yun, type)
  
  % check the type of the MFH
  if ~strcmpi(type, 'ao')
    x = double(x);
  end

  % evaluate if it is a MFH and trim
  if strcmpi(class(n), 'mfh')
    v = ao.initObjectWithSize(1, Nout);
    for ii = 1:Nout
      nts = n.index(ii).eval(x);
      un  = nts.yunits;
      if ~isempty(un.strs) % in case 'numeric' is set to false/version is 'ao'
        % split plist
        spl   = plist('offsets', trim./nts.fs);
        v(ii) = split(nts,spl);
      else
        % split plist
        spl = plist('offsets', trim./fs);
        % Build correct aos
        nn = n.index(ii);
        v(ii) = split(ao(plist('yvals', double(nts), 'fs', fs, 'xunits', 's', 'yunits', yun, 'type', 'tsdata', 'name', nn.name)), spl);
      end
    end
  elseif strcmpi(class(n), 'ao') && isa(n(1).data, 'tsdata')
    v = ao.initObjectWithSize(1, Nout);
    for ii = 1:Nout
      % split plist
      spl = plist('offsets', trim./n(ii).fs);
      % just copy it
      v(ii) = split(copy(n(ii)), spl);
    end
  elseif strcmpi(class(n), 'ao') && isa(n(1).data, 'fsdata')
    % do nothing, assume the model is correct.
    v = copy(n);
  elseif strcmpi(class(n), 'smodel') 
    % do nothing, assume the model is correct
    v = copy(n);
  else
    error('### The noise data must be either an AO-tsdata, AO-fsdata, SMODEL, or a MFH object...')
  end
  
end
% END