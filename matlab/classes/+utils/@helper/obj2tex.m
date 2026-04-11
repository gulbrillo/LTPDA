% OBJ2TEX converts the input data to TeX code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:  OBJ2TEX converts the input data to TeX code
%
%  utils.helper.obj2tex(obj)
%  txt = utils.helper.obj2tex(obj)  Returns the display text 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = obj2tex(varargin)
  if nargin~=1
    error(['utils.helper.obj2tex only takes one input object at a time and nargin is ' num2str(nargin)])
  end
  %#ok<*AGROW>
  obj = varargin{1};
  %   objClasses = {'param' 'tsdata' 'data2D' 'paramValue' 'smodel' 'unit' 'data3D' 'parfrac' 'specwin' ...
  %     'filterbank' 'pest' 'xydata' 'fsdata' 'matrix' 'plist' 'ssm' 'xyzdata' 'mfir' ...
  %     'ssmblock' 'ao' 'ltpda_data' 'miir' 'pz' 'ssmport' 'cdata' 'ltpda_filter' 'pzmodel' 'time'...
  %     'collection' 'msym' 'rational' 'timespan'}
  %   otherClasses = {'double' 'sym' 'char'}
  % if numel(obj)~=1
  %   error('only takes a single object')
  %   txt = cell(size(objs));
  %   for ii=1:numel(txt)
  %     txt{ii} = utils.helper.obj2tex(obj(ii));
  %   end
  %   varargout = txt;
  %   if nargout == 0
  %     display(txt)
  %   end
  %   return
  % elseif numel(obj)==0
  %% special cases for empty objects
  if numel(obj)==0
    switch lower(class(obj))
      case {'double' 'logical' 'cell' 'sym'}
      otherwise
        varargout = {''};
        return
    end
  end
  
  %% dealing with objects of size more than one
  if numel(obj)>1
    switch lower(class(obj))
      case {'double' 'logical' 'ao' 'ssmblock' 'sym' 'cell' 'char'}
      case {'plist' 'units' 'parfrac' 'pest' 'miir' 'rational' 'pzmodel'}
        error('multiple objects of this class are not handled yet')
      otherwise
        varargout = {''};
        return
    end
  end
  
  %% dealing with objects
  switch lower(class(obj))
    case 'ao' %% ao, does not plot content
      txt = ' \begin{tabular}{cll} NAME & DESCRIPTION & DATA \\ \hline \\  ';
      for ii=1:numel(obj)
        if ii>1
          txt = [txt ' \\ '];
        end
        txt = [ txt ' \texttt{' utils.helper.obj2tex(obj(ii).name) '} & '  utils.helper.obj2tex(obj(ii).description) ' & ' utils.helper.obj2tex(obj(ii).data) ];
      end
      txt = [txt ' \end{tabular} '];
    
    case 'plist' %% plist, does not plot all options so far. A tabular may be better... TBC...
      txt = ' \begin{tabular}{cll} KEY & VALUE & DESCRIPTION \\ \hline \\  ';
      for ii=1:obj.nparams
        if ii>1
          txt = [txt ' \\ '];
        end
        txt = [txt ' \texttt{' utils.helper.obj2tex(obj.params(ii).key) '}  & $ ' utils.helper.obj2tex( obj.params(ii).getVal ) ' $ '];
        objmin = obj.params(ii).getProperty('min');
        objmax = obj.params(ii).getProperty('max');
        objunits = obj.params(ii).getProperty('units');
        if ~isempty(objmin) &&  ~isempty(objmax )
          txt = [ txt ' $  \in \left[ ' utils.helper.obj2tex( eval(objmin) ) ';' utils.helper.obj2tex( eval(objmax) ) ' \right]  $ ' ];
        end
        if ~isempty(objunits)
          if ischar( objunits )
            objunits = strrep( objunits , '(' , '');
            objunits = strrep( objunits , ')' , '');
            objunits = strrep( objunits , ' ^' , '^');
          end
          txt = [ txt '  $ \, ' utils.helper.obj2tex( unit(objunits) ) '  $ ' ];
        elseif ischar(objunits)
          txt = [ txt ' $ \, ' utils.helper.obj2tex( unit ) ' $ ' ];
        end
        txt = [txt ' & ' utils.helper.obj2tex( obj.params(ii).desc )   ];
      end
      txt = [txt ' \end{tabular} '];
      
    case 'param' %% called by the plist function
      error('param should always be provided inside a plist object')
      
    case lower('paramValue')
      error('paramValue should always be provided inside a param object')
      
    case 'smodel'
      % { 'expr' 'params' 'values' 'trans' 'xvar' 'xvals' 'xunits' 'yunits' 'name'}
      error('smodel is not supported yet')
      
    case 'unit'
      txt = ' \left[';
      if numel(obj.strs)==0
        txt = [txt ' - '];
      else
        for ii=1:numel(obj.strs)
          if ii>1
              txt = [txt ' \,' ];
          end
          p = val2prefix(obj.vals(ii));
          if obj.exps(ii) == 0
          elseif obj.exps(ii) == 1
            txt = [txt ' \mathrm{' p ' ' obj.strs{ii} '} ' ];
          else
            txt = [txt ' \mathrm{' p ' ' obj.strs{ii} '}^{'  num2str(obj.exps(ii)) '}' ];
          end
        end
      end
      txt = [txt ' \right] '];
      
    case 'parfrac'
      %{ 'res' 'poles' 'pmul' 'dir'  'iunits' 'ounits' 'name' }
      display('warning, the parfrac was not tested so far')
      txt = [' G_{\texttt{' utils.helper.obj2tex(obj.name) '}} (s) = '];
      for ii=1:numel(obj.res)
        if ii>1
          txt = [txt ' + '];
        end
        if obj.pmul(ii)>1
          txt = [txt '\frac{ ' utils.helper.obj2tex(obj.res(ii)) ' }{ \left( s-'  utils.helper.obj2tex(obj.poles(ii)) ' \right)^{' utils.helper.obj2tex(obj.pmul(ii)) '} }' ];
        elseif obj.pmul(ii)==1
          txt = [txt '\frac{ ' utils.helper.obj2tex(obj.res(ii)) ' }{ s-('  utils.helper.obj2tex(obj.poles(ii)) ') }' ];
        end
      end
      txt = [txt ' + '  utils.helper.obj2tex(obj.dir) ];
      txt = [txt ' \, '  utils.helper.obj2tex(  simplify(obj.ounits/obj.iunits) ) ];
      
    case 'filterbank'
      %{'filters' 'type' 'name' }
      error('filterbank is not supported yet')
      
    case 'pest'
      %{ 'dy' 'y' 'names' 'yunits' 'pdf' 'cov' 'corr' 'chi2' 'dof' 'chain' 'name' }
      % plotting names
      txt = ' \left[ \begin{array}{c} ';
      for ii=1:numel(obj.y)
        if ii>1
          txt = [txt ' \\ ' ];
        end
        txt = [txt '\mathrm{' utils.helper.obj2tex(obj.names{ii}) '}' ];
      end
      txt = [ txt ' \end{array} \right]  = '];
      % plotting values
      txt = [ txt ' \left[ \begin{array}{rl} ' ];
      for ii=1:numel(obj.y)
        if ii>1
          txt = [txt ' \\ ' ];
        end
        if ~isempty(obj.dy)
          txt = [txt utils.helper.obj2tex(num2str(obj.y(ii))) ' \, \pm \, '  utils.helper.obj2tex(num2str(obj.dy(ii)))  ' & ' utils.helper.obj2tex(obj.yunits(ii)) ];
        else
          txt = [txt utils.helper.obj2tex(num2str(obj.y(ii))) '  & ' utils.helper.obj2tex(obj.yunits(ii)) ];
        end
      end
      txt = ' \end{array} \right] ';
      if ~isempty(obj.corr)
        txt = [txt '  \\  \mathrm{CORR}= \left[ '  utils.helper.obj2tex(obj.corr)  ' \right] '];
      end
      if ~isempty(obj.cov)
        txt = [txt '  \\  \mathrm{COV}= \left[ '  utils.helper.obj2tex(obj.cov)  ' \right] '];
      end
      if ~isempty(obj.cov)
        txt = [txt '  \\  \chi_2 = ' utils.helper.obj2tex(obj.chi2) ];
      end
      
    case 'matrix'
      %{ 'objs' 'name' }
      error('matrix is not supported yet')
      
    case 'ssm'
      %{ 'amats' 'bmats' 'cmats' 'dmats' 'timestep' 'inputs' 'states' 'outputs' 'numparams' 'params' ...
      %  'Ninputs' 'inputsizes' 'Noutputs' 'outputsizes' 'Nstates' 'statesizes' 'Nnumparams' 'Nparams' 'isnumerical' 'name' }
      txt = '\begin{longtable}{|rl|} \hline \textbf{FIELD} & \textbf{PROPERTY} \\ \hline \hline ';
      txt = [txt ' \textbf{NAME:} & \texttt{'    utils.helper.obj2tex(obj.name) '} '];
      txt = [ txt '  \\  \hline & \\[3pt] \textbf{DESCRIPTION:} & '  utils.helper.obj2tex(obj.description) ' ' ];
      txt = [ txt '  \\  \hline  & \\[3pt]  \textbf{REALIZATION:} &  $ \begin{array}{c|c}  A & B \\  \hline C & D \end{array} ' ];
      txt = [ txt ' \sim  \begin{array}{c|c}  ' utils.helper.obj2tex(obj.amats) ' & ' utils.helper.obj2tex(obj.bmats)  ' \\ \hline ' ];
      txt = [ txt   utils.helper.obj2tex(obj.cmats) ' & ' utils.helper.obj2tex(obj.dmats) ' \end{array} $'];
      txt = [ txt '  \\ \hline \textbf{TIMESTEP:} & '  utils.helper.obj2tex(obj.timestep) ' $'  utils.helper.obj2tex( unit('s') ) '$' ];
      txt = [ txt '  \\  \hline & \\[3pt] \textbf{INPUTS:} & '  utils.helper.obj2tex(obj.inputs)  ];
      txt = [ txt '  \\  \hline & \\[3pt] \textbf{STATES:} & '  utils.helper.obj2tex(obj.states)  ];
      txt = [ txt '  \\  \hline & \\[3pt] \textbf{OUTPUTS:} & '  utils.helper.obj2tex(obj.outputs)  ];
      txt = [ txt '  \\ \hline & \\[3pt] \textbf{PARAMS:} & '  utils.helper.obj2tex(obj.params)  ];
      txt = [ txt '  \\ \hline & \\[3pt] \textbf{NUMPARAMS:} & '  utils.helper.obj2tex(obj.numparams)  ];
      txt = [ txt '  \\  \hline \end{longtable} ' ];      
      
    case 'mfir'
      %{ 'gd' 'ntaps' 'fs' 'a' 'iunits' 'ounits' 'name' }
      error('mfir is not supported yet')
      
    case 'ssmblock'
      %{ 'name' 'ports' }
        txt = ' \begin{tabular}{r|lcl} BLOCK & PORT & UNITS & DESCRIPTION  ';
        
      for kk = 1:numel(obj)
        txt = [txt ' \\ \hline '];
        for ii=1:numel(obj(kk).ports)
          [blockName, portName] = ssmblock.splitName(obj(kk).ports(ii).name);
          if ~strcmp(blockName, obj(kk).name)
            portName = obj(kk).ports(ii).name;
          end
          if ii>1 
              txt = [txt ' \\ '];
          end
          if ii==1
            txt = [txt ' \texttt{' utils.helper.obj2tex(obj(kk).name)  '} &   &    & ' utils.helper.obj2tex(obj(kk).description)  ' \\ '];
          end
          txt = [txt ' &  \texttt{' utils.helper.obj2tex(portName)  '} & $ '  utils.helper.obj2tex(obj(kk).ports(ii).units) ' $ & ' utils.helper.obj2tex(obj(kk).ports(ii).description)  ' '];
        end
      end
      txt = [ txt ' \end{tabular} '];
      
    case 'pz'
      %{ 'f' 'q' 'ri'}
      if isnan(obj.q)
        txt = [' \left( s -  2  \pi  \left( ' num2str(obj.f) '\right) \right) ' ];
      else
        txt = [' \left( s^2 + 2  \pi \left( \frac{' utils.helper.obj2tex(obj.f) '}{' utils.helper.obj2tex(obj.q) '} \right) s + 4  \pi^2  \left(' utils.helper.obj2tex(abs(obj.f)) '\right)^2 s^2 \right) ' ];
      end
      
    case 'ssmport'
      %{'name' 'units' }
      error('ssmports should always be provided inside a ssmblock object')
      
    case 'pzmodel'
      %{ 'poles' 'zeros' 'gain' 'delay' 'iunits' 'ounits' 'name' }
      txt = [' G_{\texttt{' utils.helper.obj2tex(obj.name) '}} (s) = '  utils.helper.obj2tex(obj.gain) ' \times \frac{'];
      if numel(obj.zeros)>0
        for ii=1:numel(obj.zeros)
          txt = [txt utils.helper.obj2tex(obj.zeros(ii)) ];
        end
      else
        txt = [txt ' 1 ' ];
      end
      txt = [ txt ' }{ '];
      if numel(obj.poles)>0
        for ii=1:numel(obj.poles)
          txt = [txt utils.helper.obj2tex(obj.poles(ii)) ];
        end
      else
        txt = [txt ' 1 ' ];
      end
      txt = [txt ' } '  utils.helper.obj2tex(  simplify(obj.ounits/obj.iunits) ) ];
      
    case 'collection'
      %{ 'objs' 'name' }
      error('collection is not supported yet')
      
    case 'msym'
      %{'use fieldnames'}
      txt = obj.s;
      txt = strrep(txt, '*', '\times');
      txt = strrep(txt, '(', '{ \left(');
      txt = strrep(txt, ')', '\right) }');
      
    case 'specwin'
      %{ 'type' 'alpha' 'psll' 'rov' 'nenbw' 'w3db' 'flatness' 'ws' 'ws2' 'win'}
      error('specwin is not supported yet')
      
    case 'miir'
      %{ 'b' 'ntaps' 'fs' 'a' 'iunits' 'ounits' 'name' }
      %{ 'poles' 'zeros' 'gain' 'delay' 'iunits' 'ounits' 'name' }
      txt = [' G_{\texttt{' utils.helper.obj2tex(obj.name) '}} (z) =  \frac{'];
      for ii=1:numel(obj.a)
        if ii>1 && obj.a(ii)>=0
          txt = [txt ' + '];
        end
        txt = [txt utils.helper.obj2tex(obj.a(ii)) 'z^{-' num2str(ii) '}' ];
      end
      txt = [ txt ' }{ '];
      for ii=1:numel(obj.b)
        if ii>1 && obj.b(ii)>=0
          txt = [txt ' + '];
        end
        txt = [txt utils.helper.obj2tex(obj.b(ii)) 'z^{-' num2str(ii) '}' ];
      end
      txt = [txt ' } '  utils.helper.obj2tex(  simplify(obj.ounits/obj.iunits) ) ];
      
    case 'rational'
      %{ 'num' 'den' 'iunits' 'ounits' 'name' }
      %{ 'poles' 'zeros' 'gain' 'delay' 'iunits' 'ounits' 'name' }
      txt = [' G_{\texttt{' utils.helper.obj2tex(obj.name) '}} (s) =    \frac{'];
      for ii=1:numel(obj.num)
        if ii>1 && obj.num(ii) >=0
          txt = [txt ' + '];
        end
        txt = [txt utils.helper.obj2tex(obj.num(ii)) 's^{' num2str(ii) '}' ];
      end
      txt = [ txt ' }{ '];
      for ii=1:numel(obj.den)
        if ii>1 && obj.den(ii)>=0
          txt = [txt ' + '];
        end
        txt = [txt utils.helper.obj2tex(obj.den(ii)) 's^{' num2str(ii) '}' ];
      end
      txt = [txt ' } '  utils.helper.obj2tex(  simplify(obj.ounits/obj.iunits) ) ];
      
    case 'timespan'
      %{ 'startT' 'endT' 'interval' 'timeformat' 'timezone' 'name' }
      error('timespan is not supported yet')
      
    case 'tsdata'
      %{ 't0' 'fs' 'nsecs' 'xunits' 'yunits' 'x' 'y' 'dx' 'dy'}
      txt = [ ' $(1 \times ' utils.helper.obj2tex(numel(obj.y)) ')$ times series, units: $' utils.helper.obj2tex(obj.yunits) '$vs$' utils.helper.obj2tex(obj.xunits) ' $ at $' num2str(obj.fs) '$Hz '];
      
    case 'xydata'
      txt = [ ' $(1 \times ' utils.helper.obj2tex(numel(obj.y)) ')$ x-y data, units: $' utils.helper.obj2tex(obj.yunits) '$vs$' utils.helper.obj2tex(obj.xunits) '$ '];
      %{ 'xunits' 'yunits' 'x' 'y' 'dx' 'dy'}
      
    case 'fsdata'
      %{ 't0' 'navs' 'fs' 'enbw' 'xunits' 'yunits' 'x' 'y' 'dx' 'dy'}
      txt = [ ' $(1 \times ' utils.helper.obj2tex(numel(obj.y)) ')$ frequency series, units: $' utils.helper.obj2tex(obj.yunits) '$vs$' utils.helper.obj2tex(obj.xunits) ' $ up to $' num2str(obj.fs) '$Hz '];
      
    case 'xyzdata'
      %{ 'zunits' 'z' 'xunits' 'yunits' 'x' 'y' 'dx' 'dy'}
      display('warning, xyz data was not tested yet')
      txt = [ ' $(' utils.helper.obj2tex(numel(obj.x)) ' \times ' utils.helper.obj2tex(numel(obj.y)) ')$ table, units: $' utils.helper.obj2tex(obj.yunits) '$vs$ \left(' utils.helper.obj2tex(obj.xunits) ' \times ' utils.helper.obj2tex(obj.yunits)  '\right)$ '];
      
    case 'cdata'
      %{ 'yunits' 'y' 'dy'}
      error('cdata is not supported yet')
      
    case 'double'
      [n1, n2] = size(obj);
      if n1==0 || n2==0
        % array of size 0
        txt = [' 0_{ \left[ ' num2str(n1) ' \times  ' num2str(n2) ' \right] } '];
      elseif n1==1 && n2==1
        % array of size 1
        if isnan(obj)
          txt = '\mathrm{NaN}';
        elseif isinf(obj)
          txt = ' \pm \infty ';
        else
          if isreal(obj)
            txt1 = num2str(obj, '%10.5e');
            [txt2, txt1] = strtok(txt1, 'e');
            expo = eval(txt1(2:end));
            if expo==0
              txt = [ ' ' txt2 ' ' ];
            else
              txt = [ ' ' txt2 '.10^{'   num2str(expo) '} ' ];
            end
          else
            if imag(obj)>= 0
              txt = [ ' ' utils.helper.obj2tex( real(obj) )  '+' utils.helper.obj2tex( imag(obj) ) ' i ' ];
            else
              txt = [ ' ' utils.helper.obj2tex( real(obj) )  '' utils.helper.obj2tex( imag(obj) ) ' i ' ];
            end
          end
        end
      else
        % array of size nxm
        txt = ' \left[ \begin{array}{';
        for ii=1:size(obj,2)
          txt = [txt 'c' ];
        end
        txt = [txt '} '];
        for ii=1:size(obj,1)
          for jj=1:size(obj,2)
            if jj>1
              txt = [ txt ' & '];
            end
            val = obj(ii,jj);
            txt = [ txt ' '  utils.helper.obj2tex(val)  ]; % reccursive call with a singleton 
          end
          if ii<size(obj,1)
            txt = [ txt ' \\ ' ];
          end
        end
        txt = [ txt ' \end{array} \right] ' ];
      end
      
    case 'logical'
      txt = utils.helper.obj2tex( double(obj) );
      
    case 'sym'
      error('sym is not supported yet')
      
    case 'cell'
      [n1, n2] = size(obj);
      if n1==0 || n2==0
        % array of size 0
        txt = [' \texttt{cell}_{ \left[ ' num2str(n1) ' \times  ' num2str(n2) ' \right] } '];
      elseif n1==1 && n2==1
        % array of size 1
        txt = ['{' num2str(size(obj{1},1)) ' \times ' num2str(size(obj{1},2)) ' \texttt{ ' class(obj{1}) '} } ' ];
      else
        % array of size mxn
        txt = ' \left[ \begin{array}{';
        for ii=1:size(obj,2)
          txt = [txt 'c' ];
        end
        txt = [txt '} '];
        for ii=1:size(obj,1)
          for jj=1:size(obj,2)
            if jj>1
              txt = [ txt ' & '];
            end
            val = obj{ii,jj};
            txt = [ txt ' {' num2str(size(val,1)) ' \times ' num2str(size(val,2)) ' \texttt{ ' class(val) '} } ' ];
          end
          if ii<size(obj,1)
            txt = [ txt ' \\ ' ];
          end
        end
        txt = [ txt ' \end{array} \right] ' ];
      end
      
    case 'char'
      txt = obj;
      txt = strrep( txt, '_', '\_');
      txt = strrep( txt, '^', '\^');
      txt = strrep( txt, '->', '$\rightarrow$');
      
    otherwise
      error(['conversion to TeX is not yet implemented for class ' class(obj) '!'])
  end
  
  if nargout == 0
    display(txt);
  elseif nargout == 1
    varargout{1} = txt;
  end
end















% private function of unit class

function p = val2prefix(val)
  [pfxs, pfxvals] = unit.supportedPrefixes;
  res = val==pfxvals;
  if any(res)
    p = pfxs{val==pfxvals};
  else
    p = '';
  end
end
