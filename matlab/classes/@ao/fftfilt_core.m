% FFTFILT_CORE Simple core method which computes the fft filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Simple core method which computes the fft filter.
%
% CALL:        ao = fftfilt_core(ao, filt, Npad)
%
% INPUTS:      ao:   Single input analysis object
%              Npad: Number of bins for zero padding
%              filt: The filter to apply to the data
%                      smodel - a model to filter with.
%                      mfir   - an FIR filter
%                      miir   - an IIR filter
%                      tf     - an ltpda_tf object. Including:
%                                - pzmodel
%                                - rational
%                                - parfrac
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bs = fftfilt_core(varargin)
  
  bs    =   varargin{1};
  filt  =   varargin{2};
  Npad  =   varargin{3};
  
  inCondsMdl = [];
  
  if nargin == 4
    inCondsMdl = varargin{4};
  elseif nargin > 4
    fc = varargin{5};
    gain = varargin{6};
    iunits = varargin{7};
    ounits = varargin{8};
  end
  
  [m, n] = size(bs.data.y);
  % FFT time-series data
  fs   = bs.data.fs;
  % zero padding data before fft
  if isempty(Npad)
    Npad = length(bs.data.y) - 1;
  end
  if n == 1
    tdat = ao(tsdata([bs.data.y;zeros(Npad,1)], fs));
  else
    tdat = ao(tsdata([bs.data.y zeros(1,Npad)], fs));
  end
  % get onesided fft
  ft = fft_core(tdat, 'one');
  
  switch class(filt)
    case 'smodel'
      % Evaluate model at the given frequencies
      
      amdly = filt.setXvals(ft.data.x).double;
      amdly = reshape(amdly, size(ft.data.y));
      
      amdl = ao(fsdata(ft.data.x, amdly, fs));
      
      % set units
      bs.setYunits(simplify(bs.data.yunits .* filt.yunits));
      
    case {'miir', 'mfir', 'pzmodel', 'parfrac', 'rational'}
      
      % Check if the frequency of the filter is the same as the frequency
      % of the AO.
      if isa (filt, 'ltpda_filter') && fs ~= filt.fs
        error('### Please use a filter with the same frequency as the AO [%dHz]', fs);
      end
      
      % get filter response on given frequencies
      amdl = resp(filt, plist('f', ft.data.x));
      
      % set units
      bs.data.setYunits(simplify(bs.data.yunits .* filt.ounits ./ filt.iunits));
      
    case 'filterbank'
      % get filter response on given frequencies
      amdly = utils.math.mtxiirresp(filt.filters,ft.data.x,fs,filt.type);
      amdl = ao(fsdata(ft.data.x, amdly, fs));
      % handle units
      switch lower(filt.type)
        case 'parallel'
          % set units of the output object
          bs.setYunits(simplify(bs.data.yunits .* filt.filters(1).ounits ./ filt.filters(1).iunits));
        case 'series'
          % get units from the series
          sunits = filt.filters(1).ounits ./ filt.filters(1).iunits;
          for jj = 2:numel(filt.filters)
            sunits = sunits.*filt.filters(jj).ounits ./ filt.filters(jj).iunits;
          end
          % set units of the output object
          bs.setYunits(simplify(bs.data.yunits .* sunits));
      end
      
    case 'ao'
      
      % check if filter and data have the same shape
      if size(ft.data.y)~=size(filt.data.y)
        % reshape
        amdl = copy(filt,1);
        amdl.setX(ft.data.x);
        amdl.setY(reshape(filt.data.y,size(ft.data.x)));
        amdl.setName(filt.name);
      else
        amdl = copy(filt,1);
        amdl.setName(filt.name);
      end
      
      % set units
      bs.setYunits(simplify(bs.data.yunits .* amdl.data.yunits));
      
    case 'char'
      
      amdl = copy(ft,1);
      amdl.setX(ft.data.x);
      
      msk = getMask(ft.data.x,filt,fc,gain);
      
      amdl.setY(reshape(msk,size(ft.data.x)));
      amdl.setName(filt);
      
      % set units
      bs.setYunits(simplify(bs.data.yunits .* unit(ounits) ./ unit(iunits)));
      
      
    case 'collection'
      
      % run over collection elements
      amdl = ao(fsdata(ft.data.x, ones(size(ft.data.x)), fs));
      for ii=1:numel(filt.objs)
        switch class(filt.objs{ii})
          case 'smodel'
            % Evaluate model at the given frequencies
            amdly = filt.objs{ii}.setXvals(ft.data.x).double;
            amdly = reshape(amdly, size(ft.data.y));
            amdl_temp = ao(fsdata(ft.data.x, amdly, fs));
            % set units
            bs.setYunits(simplify(bs.data.yunits .* filt.objs{ii}.yunits));

          case {'miir'}
            % get filter response on given frequencies
            amdly = utils.math.mtxiirresp(filt.objs{ii},ft.data.x,fs,[]);
            amdl_temp = ao(fsdata(ft.data.x, amdly, fs));
            % set units
            bs.setYunits(simplify(bs.data.yunits .* filt.objs{ii}.ounits ./ filt.objs{ii}.iunits));
            
          case 'ao'
            % check if filter and data have the same shape
            if size(ft.data.y)~=size(filt.objs{ii}.data.y)
              % reshape
              amdl_temp = copy(filt.objs{ii},1);
              amdl_temp.setX(ft.data.x);
              amdl_temp.setY(reshape(filt.objs{ii}.data.y,size(ft.data.x)));
              amdl_temp.setName(filt.objs{ii}.name);
            else
              amdl_temp = copy(filt.objs{ii},1);
              amdl_temp.setName(filt.objs{ii}.name);
            end
            % set units
            bs.setYunits(simplify(bs.data.yunits .* amdl_temp.data.yunits));
            
          case 'filterbank'
            % get filter response on given frequencies
            amdly = utils.math.mtxiirresp(filt.objs{ii}.filters,ft.data.x,fs,filt.objs{ii}.type);
            amdl_temp = ao(fsdata(ft.data.x, amdly, fs));
            % handle units
            switch lower(filt.objs{ii}.type)
              case 'parallel'
                % set units of the output object
                bs.setYunits(simplify(bs.data.yunits .* filt.objs{ii}.filters(1).ounits ./ filt.objs{ii}.filters(1).iunits));
              case 'series'
                % get units from the series
                sunits = filt.objs{ii}.filters(1).ounits ./ filt.objs{ii}.filters(1).iunits;
                for jj = 2:numel(filt.objs{ii}.filters)
                  sunits = sunits.*filt.objs{ii}.filters(jj).ounits ./ filt.objs{ii}.filters(jj).iunits;
                end
                % set units of the output object
                bs.setYunits(simplify(bs.data.yunits .* sunits));
            end
        end
        % update response
        amdl = amdl .* amdl_temp;
      end
      
    otherwise
      
      error('### Unknown filter mode.');
      
  end
  
  % Add initial conditions
  if isa(filt, 'smodel') && ~isempty(inCondsMdl) && ~isempty(inCondsMdl.expr.s)
    inCondsMdl.setXvals(amdl.x);
    inCondsMdl.setXunits(amdl.xunits);
    inCondsMdl.setYunits(amdl.yunits*ft.yunits);
    inCondsEval = inCondsMdl.eval;
    % Multiply by model and take inverse FFT
    y = ifft_core(ft.*amdl+inCondsEval, 'symmetric');
  else
    % Multiply by model and take inverse FFT
    y = ifft_core(ft.*amdl, 'symmetric');
  end
  
  % split and reshape the data
  if m == 1
    bs.data.setY(y.data.getY(1:n));
  else
    bs.data.setY(y.data.getY(1:m));
  end
  
  % clear errors
  bs.clearErrors;
  
end
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Loacal functions
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  function msk = getMask(x,filt,fc,gain)
    
    msk = zeros(size(x));
    
    switch lower(filt)
      case 'highpass'
        if numel(fc)>1
          fc = fc(end);
        end
        idx = x > fc;
        msk(idx) = 1.*gain;
      case 'lowpass'
        if numel(fc)>1
          fc = fc(1);
        end
        idx = x < fc;
        msk(idx) = 1.*gain;
      case 'bandpass'
        if numel(fc)>2
          fc = fc(1:2);
        end
        idx = (x > fc(1)) & (x < fc(2));
        msk(idx) = 1.*gain;
      case 'bandreject'
        if numel(fc)>2
          fc = fc(1:2);
        end
        idx = x < fc(1);
        msk(idx) = 1.*gain;
        idx = x > fc(2);
        msk(idx) = 1.*gain;
      otherwise
          
    end
    
  end
