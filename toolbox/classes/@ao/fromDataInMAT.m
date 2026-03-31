% FROMDATAINMAT Convert a saved data-array into an AO with a tsdata-object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% FUNCTION:    fromDataInMAT
%
% DESCRIPTION: Convert a saved data-array into an AO with a tsdata-object
%
% CALL:        obj = fromLISO(obj, data-array, plist)
%
% PARAMETER:   data-array: data-array
%              plist:      plist-object (must contain the filename)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function objs = fromDataInMAT(obj, loadData, pli)
  
  ii = obj.getInfo(class(obj), 'From MAT Data File');
  
  %%%%%%%%%%   Get default parameter list   %%%%%%%%%%
  dpl = ii.plists();
  pl  = applyDefaults(dpl, pli);
  
  % Get filename
  filename = find_core(pli, 'filename');
  [pathstr, f_name, ext] = fileparts(filename);
  
  pl = pset(pl, 'filename', [f_name ext]);
  pl = pset(pl, 'filepath', pathstr);
  
  data_type = find_core (pl, 'type');
  columns   = find_core (pl, 'columns');
  fs        = find_core (pl, 'fs');
  
  objs = [];
  
  %%%   Give a warning if the user haven't specified the data type   %%%
  if ~pli.isparam_core('type')
    if pli.isparam_core('fs')
      data_type = 'tsdata';
      warning('ao:fromDatafile', '!!! You haven''t define a data type but a frequency.\nThe output will be an AO with time-series data.');
    else
      warning('ao:fromDatafile', '!!! You haven''t define a data type.\nThe output will be an AO with constant data.');
    end
  end
  
  %%%%
  if strcmpi(data_type, 'cdata')
    fs = 1;
  end
  
  % Then we try for a numerical data set in
  % the first numerical field we come to
  fnames = fieldnames(loadData);
  for jj=1:length(fnames)
    if isnumeric(loadData.(fnames{jj}))
      % get the data from here
      data = loadData.(fnames{jj});
      
      if isempty(columns)
        columns = 1:size(data,2);
      end
      
      if max(columns) > size(data,2)
        error('### The stored variable [%s] doesn''t contain %d columns. It only contains %d columns.', fnames{jj}, max(columns), size(data,2));
      end
      
      if isempty(fs)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%                       Create from x and y                       %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for kk=1:2:numel(columns)
          
          % Create an empty object.
          obj = obj.initObjectWithSize(1,1);
          
          x = data(:, columns(kk));
          y = data(:, columns(kk+1));
          
          switch lower(data_type)
            case 'tsdata'
              dataObj = tsdata(x, y);
            case 'fsdata'
              dataObj = fsdata(x, y);
            case 'xydata'
              dataObj = xydata(x, y);
            case 'cdata'
              error('### Should not happen');
            otherwise
              error('### unknown data type ''%s''', data_type);
          end
          
          obj.data = dataObj;
          
          plh = pl.pset('columns', [columns(kk) columns(kk+1)]);
          if isempty(pl.find_core('Name'))
            plh.pset('Name', sprintf('%s_%d_%d', find_core(pl, 'filename'), columns(kk), columns(kk+1)));
          end
          
          obj.addHistory(ii, plh, [], []);
          
          objs = [objs obj];
          
        end
        
      else
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%                       Create from y and fs                      %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for kk=1:numel(columns)
          
          % Create an empty object.
          obj = obj.initObjectWithSize(1,1);
          
          y = data(:, columns(kk));
          
          switch lower(data_type)
            case 'tsdata'
              dataObj = tsdata(y, fs);
            case 'fsdata'
              dataObj = fsdata(y, fs);
            case 'xydata'
              dataObj = xydata(y);
            case 'cdata'
              % Special case for cdata objects.
              % If the user doesn't specify any columns then return only
              % one AO with all the data. But if the user defines any
              % columns then return for each column an AO
              pl.removeKeys({'fs', 'xunits'});
              if isempty(pl.find_core('columns'))
                obj = obj.initObjectWithSize(1,1);
                obj.data = cdata(data);
                obj.name = pl.find_core('filename');
                obj.addHistory(ii, pl, [], []);
                objs = [objs obj];
                break;
              else
                dataObj = cdata(data(:,columns(kk)));
              end
            otherwise
              error('### unknown data type ''%s''', data_type);
          end
          
          obj.data = dataObj;
          
          plh = pl.pset('columns', columns(kk));
          if isempty(pl.find_core('Name'))
            plh.pset('Name', sprintf('%s_%d', find_core(pl, 'filename'), columns(kk)));
          end
          
          % add history
          obj.addHistory(ii, plh, [], []);
          
          objs = [objs obj];
        end
        
      end
      
      % set xunits if we don't have a cdata
      if ~strcmpi(data_type, 'cdata')
        xunits = pl.find_core('xunits');
        if isempty(xunits)
          if strcmpi(data_type, 'tsdata')
            xunits = 's';
          elseif strcmpi(data_type, 'fsdata')
            xunits = 'Hz';
          else
            % do nothing
          end
        end
        objs.setXunits(xunits);
      end
      
      % set yunits
      objs.setYunits(pl.find_core('yunits'));
  
      % set any object properties
      objs.setObjectProperties(pl);
      
    end % End if the mat file contains numeric data
  end % End loop over filenames
  
  
end



