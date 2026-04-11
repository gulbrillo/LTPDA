% IFFT_CORE Simple core method which computes the ifft.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method which computes the ifft.
%
% CALL:        ao = ifft_core(ao, type)
%
% INPUTS:      ao:   Single input analysis object
%              type: The ifft type
%                    'symmetric'
%                    'nonsymmetric'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bs = ifft_core(bs, type)
  
  switch class(bs.data)
    case {'fsdata'}
      fs = bs.data.fs;
      y  = bs.data.y;
      % check fft type
      if any((bs.data.x)<0) % two sided fft
        utils.helper.msg(utils.const.msg.PROC1, 'two sided fft');
        y = ao.ifft_2sided_core(y, type);
      else
        % get minimum frequency step
        df = bs.data.x(end)-bs.data.x(end-1);
        if abs(((fs-df)-bs.data.x(end)))<eps % plain fft
          utils.helper.msg(utils.const.msg.PROC1, 'plain fft');
          
          y = ao.ifft_plain_core(y, type);
  
        elseif abs((bs.data.x(end)-fs/2))<eps % onesided fft even nfft
          utils.helper.msg(utils.const.msg.PROC1, 'one sided fft even nfft');
          
          y = ao.ifft_1sided_even_core(y, type);
          
        else % onesided fft odd nfft
          utils.helper.msg(utils.const.msg.PROC1, 'one sided fft odd nfft');
          
          y = ao.ifft_1sided_odd_core(y, type);
          
        end
      end

      % make a new tsdata object
      fsd = tsdata(y, fs);
      fsd.setXunits(unit.seconds);
      fsd.setYunits(bs.data.yunits);
      
      % Set data
      bs.data = fsd;
      
      % clear errors
      if ~isempty(bs.data.dy) || ~isempty(bs.data.dx)
        bs.clearErrors;
      end
      
    case {'tsdata', 'cdata', 'xydata'}
      error('### I don''t work for time-series, constant or x/y data.');
    otherwise
      error('### unknown data type.')
  end
  
  
end




