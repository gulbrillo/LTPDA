% LTPDAModelBrowser is a graphical user interface for browsing the
% available built-in models.
%
% CALL: LTPDAModelBrowser
%

classdef LTPDAModelBrowser < handle
  
  properties
    gui = [];
  end
  
  
  methods
    function mainfig = LTPDAModelBrowser(varargin)
            
      % generate model data
      modelClasses = LTPDAModelBrowser.generateModelData();
      
      % make a gui
      mainfig.gui = javaObjectEDT('mpipeline.ltpdamodelbrowser.JModelBrowser', [], false, modelClasses);
            
      %--- called when window is closed
      h = handle(mainfig.gui, 'callbackproperties');
      set(h, 'WindowClosedCallback', {@mainfig.cb_guiClosed});
            
      %--- Run button
      h = handle(mainfig.gui.getDocBtn, 'callbackproperties');
      set(h, 'ActionPerformedCallback', {@mainfig.cb_getDoc});

      % Make gui visible
      mainfig.gui.setVisible(true);
      
      
    end % End constructor
    
    function display(varargin)
    end
    
  end % End public methods
  
  methods (Access = private)
   
    function cb_getDoc(varargin)
      browser = varargin{1};
      jbrowser = browser.gui;
      model = jbrowser.getSelectedModel();
      if ~isempty(model)
        mdl = char(model.fullname());
        utils.models.displayModelOverview(mdl)
      end
    end
    
  end
  
  methods (Access = private, Static=true)
    
    function modelClasses = generateModelData()
      
      classes = utils.helper.ltpda_userclasses;
      modelClasses = java.util.ArrayList();
      for kk=1:numel(classes)
        cl = classes{kk};
        
        % get models for this class
        if ~strcmp(cl, 'time')
          models = eval([cl '.getBuiltInModels()']);
          models = [{models{:,1}}];
          modelClass = mpipeline.ltpdamodelbrowser.JModelClass(cl);
          
          for jj=1:numel(models)
            model = models{jj};
            model_name = [cl '_model_' model];
            try
              cmd = [model_name '(''describe'')'];
              info = eval(cmd);
              cmd = [model_name '(''doc'')'];
              doc = eval(cmd);
              html = ['<html><body>' info sprintf('\n\n') doc '</body></html>'];
              jmodel = mpipeline.ltpdamodelbrowser.JModel(modelClass, model, html);
              modelClass.addModel(jmodel);
            catch
              warning('Model %s of class %s does not respond to the <info> call', model, cl)
            end
          end
          
          if modelClass.getModels.size>0
            modelClasses.add(modelClass);
          end
        end
      end
    end
    
  end
  
  methods (Access = public)
    
    function cb_guiClosed(varargin)
      disp('*** Goodbye from LTPDAModelBrowser');
      browser = varargin{1};
      
      %--- called when window is closed
      h = handle(browser.gui, 'callbackproperties');
      set(h, 'WindowClosedCallback', []);
      
      h = handle(browser.gui.getDocBtn, 'callbackproperties');
      set(h, 'ActionPerformedCallback', []);
      
    end
    
  end
  
end

% END
