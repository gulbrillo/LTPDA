% FROMLISO Construct a pzmodel from a LISO file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromLISO
%
% DESCRIPTION: Construct a pzmodel from a LISO file
%
% CALL:        pzm = fromLISO(pzm, pli)
%
% PARAMETER:   pzm: Empty pole/zero model
%              pli: input plist (must contain the filename)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pzm = fromLISO(pzm, pli)
  
  import utils.const.*
  
  ii = pzm.getInfo(class(pzm), 'From LISO File');
  
  upl = applyDefaults(ii.plists, pli);
  
  filename = find_core(upl, 'filename');
  
  poles = [];
  zeros = [];
  gain  = [];
  plow  = [];
  pup   = [];
  zlow  = [];
  zup   = [];
  delay = 0;
  
  % Open the file for reading
  [fd,ms] = fopen(filename, 'r');
  if (fd < 0)
    error ('### can not open file: %s \n### error msg: %s',filename, ms);
  end
  
  utils.helper.msg(msg.OPROC2, ['reading ' filename]);
  while ~feof(fd)
    line = fgetl(fd);
    % get current pointer position
    pos = ftell(fd);
    % get first token
    [s,r] = strtok(line);
    if strcmp(s, 'pole')
      % get next token as frequency
      [s,r] = strtok(r);
      pf    = lisoStr2Num(s);
      % does this pole have a Q?
      pq = NaN;
      if ~isempty(r)
        [s,r] = strtok(r);
        if isnumeric(lisoStr2Num(s))
          pq = lisoStr2Num(s);
        end
      end
      % make pole
      if isnan(pq)
        p = pz(pf);
        utils.helper.msg(msg.OPROC2, 'found pole: %g', pf);
        % are there errors for this value?
        line = fgetl(fd);
        [s,r] = strtok(line);
        if strcmp(s, 'param')
          pscan = sscanf(r,'%*s %f %f');
          pl = pz(pscan(1));
          pu = pz(pscan(2));
          plow = [plow pl];
          pup = [pup pu];
        else
          % we did not read an error, rewind
          fseek(fd,pos,'bof');
        end
      else
        p = pz(pf, pq);
        utils.helper.msg(msg.OPROC2, 'found pole: %g, %g', pf, pq);
        % are there errors for this value?
        line = fgetl(fd);
        [s,r] = strtok(line);
        if strcmp(s, 'param')
          % we need to get a new line for the errors of q
          line2 = fgetl(fd);
          [s2,r2] = strtok(line2);
          pf = sscanf(r,'%*s %f %f');
          pq = sscanf(r2,'%*s %f %f');
          pl = pz(pf(1),pq(1));
          pu = pz(pf(2),pq(2));
          plow = [plow pl];
          pup = [pup pu];
        else
          % we did not read an error, rewind
          fseek(fd,pos,'bof');
        end
      end
      poles = [poles p];
    elseif strcmp(s, 'zero')
      % get next token as frequency
      [s,r] = strtok(r);
      zf    = lisoStr2Num(s);
      % does this zero have a Q?
      zq = NaN;
      if ~isempty(r)
        [s,r] = strtok(r);
        if isnumeric(lisoStr2Num(s))
          zq = lisoStr2Num(s);
        end
      end
      % make zero
      if isnan(zq)
        z = pz(zf);
        utils.helper.msg(msg.OPROC2, 'found zero: %g', zf);
        % are there errors for this value?
        line = fgetl(fd);
        [s,r] = strtok(line);
        if strcmp(s, 'param')
          zscan = sscanf(r,'%*s %f %f');
          zl = pz(zscan(1));
          zu = pz(zscan(2));
          zlow = [zlow zl];
          zup = [zup zu];
        else
          % we did not read an error, rewind
          fseek(fd,pos,'bof');
        end
      else
        z = pz(zf, zq);
        utils.helper.msg(msg.OPROC2, 'found zero: %g, %g', zf, zq);
        % are there errors for this value?
        line = fgetl(fd);
        [s,r] = strtok(line);
        if strcmp(s, 'param')
          % we need to get a new line for the errors of q
          line2 = fgetl(fd);
          [s2,r2] = strtok(line2);
          zf = sscanf(r,'%*s %f %f');
          zq = sscanf(r2,'%*s %f %f');
          zl = pz(zf(1),zq(1));
          zu = pz(zf(2),zq(2));
          zlow = [zlow zl];
          zup = [zup zu];
        else
          % we did not read an error, rewind
          fseek(fd,pos,'bof');
        end
      end
      zeros = [zeros z];
    elseif strcmp(s, 'factor')
      % get next token as gain
      [s, r] = strtok(r);
      gain   = lisoStr2Num(s);
      utils.helper.msg(msg.OPROC2, 'found factor: %g', gain);
      % are there errors for this value?
      line = fgetl(fd);
      [s,r] = strtok(line);
      if strcmp(s, 'param')
        p = sscanf(r,'%*s %f %f');
        gl = p(1);
        gu = p(2);
      else
        % we did not read an error, rewind
        fseek(fd,pos,'bof');
      end
    elseif strcmp(s, 'delay')
      % get next token as delay
      [s, r] = strtok(r);
      delay   = lisoStr2Num(s);
      utils.helper.msg(msg.OPROC2, 'found delay: %g', delay);
      % are there errors for this value?
      line = fgetl(fd);
      [s,r] = strtok(line);
      if strcmp(s, 'param')
        p = sscanf(r,'%*s %f %f');
        dl = p(1);
        du = p(2);
      end
    end
  end
  % Close file
  fclose(fd);
  % get model name
  [path, name, ext] = fileparts(filename);
  % set object
  
  
  if exist('gl')
    pl1 = copy(upl, 1);
    pzm(1).gain  = gain;
    pzm(1).poles = poles;
    pzm(1).zeros = zeros;
    pzm(1).delay = delay;
    pzm(1).name  = name;
    if ~isempty(pl1.find_core('name'))
      pl1.pset('name', name);
    end
    % Set properties from the plist
    pzm(1).setObjectProperties(pl1);
    pzm(1).addHistory(ii, pl1, [], []);
    
    pl2 = copy(upl, 1);
    pzm(2).gain  = gl;
    pzm(2).poles = plow;
    pzm(2).zeros = zlow;
    pzm(2).delay = dl;
    if isempty(pl2.find_core('name'))
      pl2.pset('name', strcat(name,'_lower'));
    end
    % Set properties from the plist
    pzm(2).setObjectProperties(pl2);
    pzm(2).addHistory(ii, pl2, [], []);
    
    pl3 = copy(upl, 1);
    pzm(3).gain  = gu;
    pzm(3).poles = pup;
    pzm(3).zeros = zup;
    pzm(3).delay = du;
    if isempty(pl3.find_core('name'))
      pl3.pset('name', strcat(name,'_upper'));
    end
    % Set properties from the plist
    pzm(3).setObjectProperties(pl3);
    pzm(3).addHistory(ii, pl3, [], []);
    
  else
    pzm.gain  = gain;
    pzm.poles = poles;
    pzm.zeros = zeros;
    pzm.delay = delay;
    if isempty(upl.find_core('name'))
      upl.pset('name', name);
    end
    % Set properties from the plist
    pzm.setObjectProperties(upl);
    pzm.addHistory(ii, upl, [], []);
  end
  
  
  
end

%%%%%%%%%%% A function to convert LISO number strings to doubles %%%%%%%%%%

function d = lisoStr2Num(s)
  
  s = strrep(s, 'm', 'e-3');
  s = strrep(s, 'u', 'e-6');
  s = strrep(s, 'n', 'e-9');
  s = strrep(s, 'p', 'e-12');
  s = strrep(s, 'f', 'e-15');
  s = strrep(s, 'k', 'e3');
  s = strrep(s, 'M', 'e6');
  s = strrep(s, 'G', 'e9');
  
  d = str2double(s);
  
end % function d = lisoStr2Num(s)
