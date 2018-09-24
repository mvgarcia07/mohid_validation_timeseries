function k = menu_old(s0, varargin);
%MENU_OLD	Generate a menu of choices for user input.
%	K = MENU_OLD('Choose a color','Red','Blue','Green') displays on
%	the screen:
%
%	----- Choose a color -----
%
%		1) Red
%		2) Blue
%		3) Green
%
%		Select a menu number: 
%
%	The number entered by the user in response to the prompt is
%	returned.

% $Id: menu_old.m Mon, 03 Jul 2006 17:16:40 $

% This was written to duplicate the old, command-line version of menu.
%
% This function is called by: getnc.m

disp(' ')
disp(['----- ', s0 ,' -----'])
disp(' ')
for ii = 1:(nargin - 1)
  disp(['      ', int2str(ii), ') ', varargin{ii}])
end
disp(' ')
k = input('Select a menu number: ');
