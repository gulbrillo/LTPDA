% TEST_AO_FROMVALS construct AOs in different ways
%
% Diepholz 19.09.2008
%
% $Id$
%
function test_ao_fromVals()
  
  
  % Make test AOs
  
  a1 = ao([1 2 3 4]);
  if ~isa(a1.data, 'cdata')
    error('The data object must de a cdata-object');
  end
  
  a2 = ao(1:12, randn(12,1));
  if ~isa(a2.data, 'xydata')
    error('The data object must be a xydata-object');
  end
  
  a3 = ao(1:12, randn(12,1) + randn(12,1)*1i);
  if ~isa(a3.data, 'xydata')
    error('The data obejct must be a xydata-object');
  end
  
  a4 = ao(1:12, randn(12,1));
  if ~isa(a4.data, 'xydata')
    error('The data object must be a xydata-object');
  end
  
  a5 = ao(1:12, randn(12,1) + randn(12,1)*1i);
  if ~isa(a5.data, 'xydata')
    error('The data object must be a xydata-object');
  end
  
  a6 = ao(randn(12,1), 32.47);
  if ~isa(a6.data, 'tsdata')
    error('The data object must be a tsdata-object');
  end
  
  a7 = ao([1:12], randn(12,1), plist);
  if ~isa(a7.data, 'xydata')
    error('The data object must be a xydata-object');
  end
  
  a8 = ao([1:12], randn(12,1), plist('type', 'xydata'));
  if ~isa(a8.data, 'xydata')
    error('The data object must be a xydata-object');
  end
  
  a9 = ao([1:12], randn(12,1), plist('type', 'tsdata'));
  if ~isa(a9.data, 'tsdata')
    error('The data object must be a tsdata-object');
  end
  
  a0 = ao([1:12], randn(12,1), plist('type', 'fsdata'));
  if ~isa(a0.data, 'fsdata')
    error('The data object must be a fsdata-object');
  end
  
  aa = ao(randn(12,1));
  if ~isa(aa.data, 'cdata')
    error('The data object must be a cdata-object');
  end
  
  
  
end


