function f = filload(filename)

  % Load a LISO *_iir.fil file to get the filter taps and return a
  % miir type object.
  %
  % M Hewitson 11-02-07
  %

  delims = ' \n';
  in = fopen(filename, 'rt');

  name = filename(1:end-4);

  if(in < 0)
    error(['can not open file ' filename]);
  end
  lbuffer = fgets(in);
  n = 1;
  nacoeffs = 0;
  nbcoeffs = 0;
  filt.a = [];
  filt.b = [];
  norminst = '';

  while (lbuffer > 0)
    if(length(lbuffer) > 1)
      % read the first token on this line
      [token, r] = strtok (lbuffer, delims);

      % Get fs
      if(strcmp(token, 'iir'))
        [token, r] = strtok (r, delims); % value
        fs = str2double(token);
      end

      % Get a coeffs
      if(token(1) == 'a')
        [token, r] = strtok (r, delims); % value
        nacoeffs = nacoeffs+1;
        filt.a(nacoeffs) = str2double(token);
      end
      % Get b coeffs
      if(token(1) == 'b')
        [token, r] = strtok (r, delims); % value
        nbcoeffs = nbcoeffs+1;
        filt.b(nbcoeffs) = str2double(token);
      end
    end

    n = n + 1;
    lbuffer = fgets(in);
  end
  fclose(in);

  if(nacoeffs > nbcoeffs)
    error('## unstable filter: nacoeffs > nbcoeffs');
  end

  if(nacoeffs < nbcoeffs)
    filt.a = [filt.a zeros(1,(nbcoeffs-nacoeffs))];
  end

  ncoeffs = nbcoeffs;

  f.name    = name;
  f.fs      = fs;
  f.a       = filt.a;
  f.b       = filt.b;
  f.ntaps   = ncoeffs;
  f.gain    = 1;
  f.histin  = zeros(1, f.ntaps-1);
  f.histout = zeros(1, f.ntaps-1);
end


