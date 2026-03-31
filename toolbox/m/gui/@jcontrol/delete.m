function delete(obj)
% DELETE method overloaded for the JCONTROL class
%
% DELETE acts on the hgcontainer of the target object. Call this on the
% parent JCONTROL to delete all its contents.
%
% Example:
% delete(obj)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

delete(obj.hgcontainer);
return
end
