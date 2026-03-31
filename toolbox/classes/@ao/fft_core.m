% FFT_CORE Simple core method which computes the fft.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method which computes the fft.
%
% CALL:        ao = fft_core(ao, fft_type)
%
% INPUTS:      ao:   Single input analysis object
%              fft_type: The fft type
%                    'plain' - complete non-symmetric
%                    'one'   - from zero to Nyquist
%                    'two'   - complete symmetric
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bs = fft_core(bs, fft_type)
  
  % make FFT of data
  y = bs.data.y;
  
  % Decide based on input data type
  switch class(bs.data)
    case 'tsdata'
      % Collect info
      fs = bs.data.fs;
      t0 = bs.data.t0 + bs.data.getX(1);
      xunits = unit.Hz;
      yunits = bs.data.yunits;
      
      % Check for complex data
      if isequal(lower(fft_type), 'one') && ~isreal(y)
        % In this case we need to output the true matlab fft
        warning('Complex data detected. Cannot provide fft of type ''%s''. Giving ''%s'' instead.', fft_type, 'plain');
        fft_type = 'plain';
      end
     
      nfft   = length(y);
      f      = utils.math.getfftfreq(nfft, fs, fft_type);
      
      switch lower(fft_type)
        case 'plain' % get true matlab fft
          ft = fft(y);
          f  = reshape(f, size(ft));
        case 'one'
          ft = ao.fft_1sided_core(y);
          f  = reshape(f, size(ft));
        case 'two'
          ft = ao.fft_2sided_core(y);
          if size(ft, 1) ~= 1
            f = f.';
          end
        otherwise
          error('### unsupported fft type ''%s''.', fft_type);
      end
      % Make new fsdata object
      fsd = fsdata(f, ft, fs);
      % Set units
      fsd.setXunits(xunits);
      fsd.setYunits(yunits);
      % Set t0
      fsd.setT0(t0);
      
    case {'cdata', 'xydata'}
      % Copy the object so we inherit most of the properties
      fsd = copy(bs.data, 1);
      
      % Check for complex data
      if isequal(lower(fft_type), 'one')
        % In this case we need to output the true matlab fft
        warning('Cannot provide fft of type ''%s'' with AOs containing ''%s'' data objects. Giving ''%s'' instead.', fft_type, class(bs.data), 'plain');
        fft_type = 'plain';
      end
      
      switch lower(fft_type)
        case 'plain' % get true matlab fft
          ft = fft(y);
        case 'two'
          ft = fft(y);
          ft = fftshift(ft);
        otherwise
          error('### unsupported fft type ''%s''.', fft_type);
      end
      fsd.setY(ft);
      
    otherwise
      error('### You can only fft tsdata, cdata, or xydata AOs.');
  end
  
  % make output data object
  bs.data = fsd;
  
  % clear errors
  bs.clearErrors;
  
end


