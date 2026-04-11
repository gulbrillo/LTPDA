% Tests that an object can be rebuilt.
function test_rebuild(algo)
  
  r = algo.rebuild();
  [result, message] = isequal(r, algo, 'proctime', 'UUID');
  assert(result, 'Failed to rebuild object: %s', message)
  
end