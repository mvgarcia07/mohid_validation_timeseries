function [mex_name, file_full, desc_das, file_status, exe_name] = choose_mexnc_opendap(file)
% CHOOSE_MEXNC_OPENDAP decides if a file should be read using mexnc or loaddap
%
% [mex_name, file_full, desc_das, file_status, exe_name] = ...
%      choose_mexnc_opendap(file)
%
% INPUT:
% file is the may be a url to an opendap file or it may be the name of a
%  netCDF file, with or without the .cdf or .nc extent. The file may also be
%  in a compressed form, in which the user is offered the choice of having
%  the file uncompressed; this is included for backwards compatibility and
%  its use is deprecated.
%
% OUTPUT:
% mex_name:
%   the name of the mexfile relevant to the given file and it depends on what
%   is available. It may be 'mexnc', 'loaddap', 'loaddods' or 'none'. Of
%   course 'none' means that we can't deal with the file.
% file_full:
%   the same as file but .nc or .cdf may be added to it if that was left off
%   in the original version. If the file is found in the common data set then
%   the path will be prepended.
% desc_das:
%   if we have an opendap dataset then this contains the dds of the file as
%   returned by a call to loaddap or loaddods. Otherwise this will be empty. 
% file_status: a status flag; 
%   = 0 if the netCDF file is in the current directory.
%   = 1 if the file cannot be found anywhere.
%   = 2 if the file is in the directory specified by a call to the
%       m-function pos_cds.
%   = 3 if a compressed version of the file is in the current directory.
%   = 4 if this is a url.
% exe_name:
%   the name of the executable file associated with the mexfile. It contains
%   the full path name so that it can be called from other functions (notably
%   get_dods_dds). It may be writedap, writeval, writedap.exe or
%   writeval.exe. If the mexfile is mexnc then there is no associated
%   executable and so exe_name is 'none'.
%
% NOTES:
% 1) If file is a url then the function will attempt to get the dds first by
%    a call to loaddap. If this works then mex_name is set to 'loaddap'. If
%    this fails it tries loaddods next. If this fails also however then it
%    will be assumed that mexnc is capable of reading the dataset. Although
%    the existence of mexnc will be checked only an elementary test will be
%    done and so the whole thing may fail later on.

% $Id: choose_mexnc_opendap.m Mon, 03 Jul 2006 17:16:40 $
% Copyright J. V. Mansbridge, CSIRO, Fri Oct 28 17:37:44 EST 2005

% Check that the file is accessible.  If it is then its full name will
% be stored in the variable full_nam.  The file may have the extent .cdf or
% .nc and be in the current directory or the common data set (whose
% path can be found by a call to pos_cds.m.  If a compressed form
% of the file is in the current directory then the user is prompted to
% uncompress it.  If, after all this, the netcdf file is not accessible
% then the m file is exited with an error message.
  
desc_das = [];
file_full_list = { '', '.nc', '.cdf'};
ilim = length(file_full_list);
for ii = 1:ilim 
  file_full = [file file_full_list{ii}];
  file_status = check_nc(file_full);

  switch file_status
   case {0, 4}
    break;
   case 1
    if ii == ilim
      error([ file ' could not be found' ])
    end
   case 2
    path_name = pos_cds;
    file_full = [ path_name file_full ];
    break;
   case 3
    err1 = uncmp_nc(file_full);
    if err1 == 0
      break;
    elseif err1 == 1
      disp([ 'exiting because you chose not to uncompress ' file_full ])
      return;
    elseif err1 == 2
      error([ 'exiting because ' file_full ' could not be uncompressed' ])
    end
  end
end

% Set mex_name which determines whether we use mexnc, loaddap or loaddods to
% read the dataset.

switch file_status
 case 4
  % Try to use loaddap to get a description of the opendap dataset. On
  % failure try loaddods. On failure again assume that you can use mexnc.
  
  mex_name = 'none';
  try
    desc_das = loaddap('-A +v', file);
    if exist('desc_das')
      mex_name = 'loaddap';
    end
  catch
    try
      desc_das = loaddods('-A +v', file);
      if exist('desc_das')
	mex_name = 'loaddods';
      end
    catch
      try
	[version_num, release_name, release_date] = mexnc('get_mexnc_info');
	mex_name = 'mexnc';
      catch
	mex_name = 'none';
      end
    end
  end
 otherwise
  
  % Do an elementary check for mexnc.
  
  if exist('mexnc')
    mex_name = 'mexnc';
  else
    mex_name = 'none';
  end
  exe_name = 'none';
end

% Now find the name and path for the executable called by loaddap or
% loaddods.

switch mex_name
 case {'loaddap', 'loaddods'}
  
  % First find the name of the executable.
  
  if isunix
    switch mex_name
     case 'loaddap'
      exe_name_short = 'writedap';
     case 'loaddods'
      exe_name_short = 'writeval';
    end
  else
    switch mex_name
     case 'loaddap'
      exe_name_short = 'writedap.exe';
     case 'loaddods'
      exe_name_short = 'writeval.exe';
    end
  end

  % Now look for the location of the executable. Look first in the same
  % directory as the mex file. If that fails try to find a parallel 'bin'
  % directory as happens in the windows version of the command line tools.

  dir_mex = which(mex_name);
  ff = findstr(dir_mex, mex_name);
  dir_mex = dir_mex(1:(ff(end) - 1));
  exe_name = [dir_mex exe_name_short];
  if exist(exe_name)
    return
  else
    cd(dir_mex)
    cd('..')
    if exist('bin') == 7
      cd('bin')
      if exist(exe_name)
	if isunix
	  exe_name = [pwd '/' exe_name_short];
	else
	  exe_name = [pwd '\' exe_name_short];
	end
      else
	error(['Couldn''t find ' exe_name_short])
      end
    else
      error(['Couldn''t find ' exe_name_short])
    end
  end
 otherwise
  exe_name = 'none';
end

