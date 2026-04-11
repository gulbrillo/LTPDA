% Test adding to, and getting from, DOM works
function res = test_xml(varargin)
  
  utp = varargin{1};
  
  dom = com.mathworks.xml.XMLUtils.createDocument('ltpda_object');
  parent = dom.getDocumentElement;

  % make vector
  v = ltpda_vector(1:10, 1:10, 'm', 'myVector');
  
  % attach to DOM
  collectedHist = attachToDom(v, dom, parent, []);
  
  % read back from DOM
  vo = ltpda_vector();
  fromDom(vo, parent, history);
  
  assert(isequal(vo, v), 'vectors are not equal');
  
  
  res = 'reading and writing to XML DOM works';
  
end