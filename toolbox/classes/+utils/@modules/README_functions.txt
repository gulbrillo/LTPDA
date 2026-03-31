Here you can place any MATLAB function. It will be added to the MATLAB path when
the extension module is installed. Typically it is better to use MATLAB packages 
to avoid namespace collisions. For example,

my_module/functions/+packageA/@plotting/plotting.m
my_module/functions/+packageB/@math/math.m

