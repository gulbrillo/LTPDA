% Tests that the emtpy constructor works and returns and object of the
% correct instance.
function test_empty_constructor(algo)
  
  obj = eval(class(algo));
  
  assert(strcmp(class(obj), class(algo)))

  
end