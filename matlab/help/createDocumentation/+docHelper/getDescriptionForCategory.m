
function desc = getDescriptionForCategory(cat)
  
  switch lower(cat)
    case 'constructor'
      desc = 'Summary of all constructor methods';
    case 'internal';
      desc = 'Summary of all internal methods only for internal usage';
    case 'statespace';
      desc = 'Summary of all statespace methods';
    case 'signal_processing';
      desc = 'Summary of all signal processing methods';
    case 'arithmetic_operator';
      desc = 'Summary of all arithmetic operator methods';
    case 'helper';
      desc = 'Summary of all helper methods';
    case 'operator';
      desc = 'Summary of all operator methods';
    case 'output';
      desc = 'Summary of all output methods';
    case 'relational_operator';
      desc = 'Summary of all relational operator methods';
    case 'trigonometry';
      desc = 'Summary of all trigonometry methods';
    case 'mdc01';
      desc = 'Summary of all mock data challenge 01 methods';
    case 'gui_function';
      desc = 'Summary of all graphical user interface methods';
    case 'converter';
      desc = 'Summary of all converter methods';
    case 'user_defined';
      desc = 'Summary of all user defined methods';
    case 'static'
      desc = 'Summary of all static methods';
    otherwise
      desc = sprintf('### Please define a description for the [%s] category in docHelper.getDescriptionForCategory', cat);
  end
  
end
