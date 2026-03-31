Here you can place methods which need to be added to existing LTPDA User Classes. To
do that, create a directory with the name of the user class, then place new methods
in that directory.

For example:

my_module/classes/ao/myNewMethod.m

You can also add new LTPDA user classes here. To do that, create a new MATLAB class that
subclasses ltpda_uoh and implements the necessary abstract methods. For example,

my_module/classes/@MyNewUserClass/




