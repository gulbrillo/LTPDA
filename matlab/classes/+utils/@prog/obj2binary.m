% OBJ2BINARY Converts an object to binary representation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION: Converts an object to binary representation.
%
% CALL:        bin = utils.prog.obj2binary(obj)
%
% INPUTS:      obj - the object to be converted
%
% OUTPUTS:     bin - the converted object
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function bin = obj2binary(objs)
  
  % get tmp filename
  fname = [tempname '.mat'];
  
  % Convert the objects into a struct if the MATLAB version is less than
  % R2008b because MATLAB have a internal bug with saving user defined
  % objects.
  v = ver('MATLAB');
  if utils.helper.ver2num(v.Version) < utils.helper.ver2num('7.7')
    warning('off', 'all')
    objs  = utils.prog.rstruct(objs);
    warning('on', 'all')
  end
  save(fname, 'objs');
  
  fd = fopen(fname, 'r');
  bin = fread(fd, inf, 'int8=>int8');
  fclose(fd);
  delete(fname);  
end
