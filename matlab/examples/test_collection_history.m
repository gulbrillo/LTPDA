function test_collection_history()
  
  
  c = collection();
  
  a = ao(1) + ao(2);
  
  c.addObjects(a);
  
  c.addObjects(pzmodel(1,10,100), mfir)
  
  type(c)
  
  
  cr = c.rebuild;
  
  assert(isequal(c, cr, 'context', 'proctime', 'UUID', 'methodInvars', 'name'), 'The rebuilding failed')
  
  
  %%
  c = collection();
  
  a = ao(1) + ao(2);
  
  c.addObjects(plist('objs', a));
  
  c.addObjects(plist('objs', {pzmodel(1,10,100), mfir}))
  
  c.addObjects(plist('objs', {mfir, [ao(1); ao(2)]}))
  
  type(c)
  
  
  cr = c.rebuild();
  
  assert(isequal(c, cr, 'context', 'proctime', 'UUID', 'methodInvars', 'name'), 'The rebuilding failed')
  
end