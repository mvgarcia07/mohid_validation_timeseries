function values = getnc(varargin);
% function values = getnc(file, varid, bl_corner, tr_corner, stride, order, ...
%      change_miss, new_miss, squeeze_it, rescale_opts, err_opt)
%
%  GETNC retrieves data from a NetCDF file or a DODS/OPEnDAP dataset.
%
%  function values = getnc(file, varid, bl_corner, tr_corner, stride, order, ...
%        change_miss, new_miss, squeeze_it, rescale_opts, err_opt)
%
% DESCRIPTION:
%  getnc retrieves data either from a local NetCDF file or a DODS/OPEnDAP
%  dataset. The way getnc behaves depends on how many of the input arguments are
%  passed to it. If no arguments are passed then it returns this help
%  message. If one argument (the name of a netcdf file) is passed then the user
%  is asked questions to determine information necessary for the data
%  retrieval. (DODS/OPEnDAP data cannot be retrieved this way.) Other usage
%  (described below) is for the non-interactive behaviour. If more than one
%  argument is passed then getnc returns the data without needing to ask any
%  questions. The input arguments are listed below.
%
% USAGE:
% getnc retrieves data in two ways. It can be used used interactively to
% retrieve data from a netCDF file by simply typing:
%
% >> values = getnc(file);
%
% getnc is more commonly used as a function call - it can then retrieve data
% from both netCDF and OPeNDAP files. Because many options are available
% getnc can take up to 11 input arguments (although most have default
% values). To make things easier for the user there are various ways of
% specifying these arguments.  Specifying up to 11 arguments to getnc can be
% complicated and confusing. To make the process easier getnc will accept a
% variety of types of input. These are given as follows:
%
%    1) Specify all 11 arguments. Thus we could make a call like:
%
% >> values = getnc(file, varid, bl_corner, tr_corner, stride, order, ...
%             change_miss, new_miss, squeeze_it, rescale_opts, err_opt);
%
%    2) Use default arguments. Only the first 2 arguments are strictly
%    necessary as the other arguments all have defaults. The following call
%    would retrieve the entire contents of the named variable:
%
% >> values = getnc(file, varid);
%
% If you want non-default behaviour for one or more of the later arguments
% then you can do something like:
%
% >> values = getnc(file, varid, -1, -1, -1, -1, change_miss, new_miss);
%
% In this case there are 4 arguments specified and 7 with default values used.
%
%    3) Use a structure as an argument. From version 3.3 onwards it is
%    possible to pass a structure to getnc. This is illustrated below: 
% 
% >> x.file = 'fred.nc';
% >> x.varid = 'foo';
% >> x.change_miss = 1;
% >> values = getnc(x);
% 
% This specifies 3 arguments and causes defaults to be used for the other 8.
% Note that it is possible to mix the usual arguments with the passing of a
% structure - it is only necessary that the structure be the last argument
% passed. We could achieve the same effect as above by doing:
% 
% >> x.change_miss = 1;
% >> values = getnc('fred.nc', 'foo', x);
%
% INPUT ARGUMENTS:
%  1. file: This is a string containing the name of the netCDF file or the
%   URL to the OpenDAP dataset. It does not have a default. If describing a
%   netCDF file it is permissible to drop the ".nc" prefix but this is not
%   recommended.
%
%  2. varid:  This may be a string or an integer. If it is a string then it
%   should be the name of the variable in the netCDF file or OPEnDAP
%   dataset. The use of an integer is a deprecated way of accessing netCDF
%   file data; if used the integer then must be the menu number of the n
%   dimensional variable as shown by a call to inqnc.
%
%  3. bl_corner: This is a vector of length n specifying the hyperslab
%   corner with the lowest index values (the bottom left-hand corner in a
%   2-space).  The corners refer to the dimensions in the same order that
%   these dimensions are listed in the inqnc description of the variable. For
%   a netCDF file this is the same order that they are returned in a call to
%   "ncdump". With an OPEnDAP dataset it is the same order as in the
%   DDS. Note also that the indexing starts with 1 - as in matlab and
%   fortran, NOT 0 as in C. A negative element means that all values in that
%   direction will be returned.  If a negative scalar (or an empty array) is
%   used this means that all of the elements in the array will be
%   returned. This is the default, i.e., all of the elements of varid will be
%   returned.
%
%  4. tr_corner: This is a vector of length n specifying the hyperslab
%   corner with the highest index values (the top right-hand corner in a
%   2-space). A negative element means that the returned hyperslab should run
%   to the highest possible index (this is the default). Note, however, that
%   the value of an element in the end_point vector will be ignored if the
%   corresponding element in the corner vector is negative.
%
%  5. stride: This is a vector of length n specifying the interval between
%   accessed values of the hyperslab (sub-sampling) in each of the n
%   dimensions.  A value of 1 accesses adjacent values in the given
%   dimension; a value of 2 accesses every other value; and so on. If no
%   sub-sampling is required in any direction then it is allowable to just
%   pass the scalar 1 (or -1 to be consistent with the corner and end_point
%   notation). Note, however, that the value of an element in the stride
%   vector will be ignored if the corresponding element in the corner vector
%   is negative.
%
%  6. order: 
%     * order == -1 then the n dimensions of the array will be returned in
%     the same order as described by a call to inqnc(file) or "ncdump". It
%     therefore corresponds to the order in which the indices are specified
%     in corner, end_point and stride. This is the default.
%     * order == -2 will reverse the above order. Because matlab's array
%     storage is row-dominant this is actually a little quicker but the
%     difference is rarely significant.
%
%  7. change_miss: Missing data are indicated by the attributes _FillValue,
%   missing_value, valid_range, valid_min and valid_max. The action to be
%   taken with these data are determined by change_miss.
%     * change_miss == 1 causes missing values to be returned unchanged.
%     * change_miss == 2 causes missing values to be changed to NaN (the
%     default).
%     * change_miss == 3 causes missing values to be changed to new_miss
%     (after rescaling if that is necessary).
%     * change_miss < 0 produces the default (missing values to be changed to
%     NaN).
%
%  8. new_miss: This is the value given to missing data if change_miss == 3.
%
%  9. squeeze_it: This specifies whether the matlab function "squeeze"
%   should be applied to the returned array. This will eliminate any
%   singleton array dimensions and possibly cause the returned array to have
%   less dimensions than the full array.
%     * squeeze_it ~= 0 causes the squeeze function to be applied.  This is
%     the default. Note also that a 1-d array is returned as a column
%     vector.
%     * squeeze_it == 0 so that squeeze will not be applied.
%
% 10. rescale_opts: This is a 2 element vector specifying whether or not
%  rescaling is carried out on retrieved variables and certain
%  attributes. The relevant attributes are _FillValue', 'missing_value',
%  'valid_range', 'valid_min' and 'valid_max'; they are used to find missing
%  values of the relevant variable. The option was put in to deal with files
%  that do not follow the netCDF conventions (usually because the creator of
%  the file has misunderstood the convention). For further discussion of the
%  problem see here. Only use this option if you are sure that you know what
%  you are doing.
%     * rescale_opts(1) == 1 causes a variable read in by getnc.m to be
%     rescaled by 'scale_factor' and  'add_offset' if these are attributes of
%     the variable; this is the default.
%     * rescale_opts(1) == 0 disables rescaling of the retrieved variable.
%     * rescale_opts(2) == 1 causes the attributes '_FillValue', etc to be
%     rescaled by 'scale_factor' and 'add_offset'; this is the default.
%     * rescale_opts(2) == 0 disables the rescaling of the attributes
%     '_FillValue', etc.
%
% 11. err_opt: This is an integer that controls the error handling in a call
%  to getnc.
%     * err_opt == 0 on error this prints an error message and aborts.
%     * err_opt == 1 prints a warning message and then returns an empty
%     array. This is the default.
%     * err_opt == 2 returns an empty array. This is a dangerous option and
%     should only be used with caution. It might be used when getnc is called
%     in a loop and you want to do your own error handling without being
%     bothered by warning messages.
%
% OUTPUT:
%  values is a scalar, vector or array of values that is read in
%     from the NetCDF file or DODS/OPEnDAP dataset
%
% NOTES:
%   1) In order for getnc to work non-interactively it is only strictly
% necessary to pass the first 2 input arguments to getnc - sensible
% defaults are available for the rest.
% The defaults are:
% bl_corner, tr_corner == [-1 ... -1], => all elements retrieved
% stride == 1, => all elements retrieved
% order == -1
% change_miss == 2, => missing values replaced by NaNs
% new_miss == 0;
% squeeze_it == 1; => singleton dimensions will be removed
% rescale_opts == [1 1]; => the obvious rescaling
% error_opt == 1 prints a warning message and then returns an empty array.
%
%   2) It is not acceptable to pass only 3 input arguments since there is
% no default in the case of the corner points being specified but the
% end points not.
%
%   3) By default the order of the dimensions of a returned array will be the
% same as they appear in the relevant call to 'inqnc' (from matlab) or
% 'ncdump -h' (from the command line).  (This is the opposite to what
% happened in an earlier version of getnc.)  For a netcdf file this actually
% involves getnc re-arranging the returned array because the netCDF utilities
% follow the C convention for data storage and matlab follows the fortran
% convention. For a DODS/OPEnDAP dataset it is even weirder.
%
%   4) If the values are returned in a one-dimensional array then this will
% always be a column vector.
%
%   5) A strange 'feature' of matlab 5 is that it will not tolerate a singleton
% dimension as the final dimension of a multidimensional array.  Thus, if
% you chose to have only one element in the final dimension this dimension
% will be 'squeezed' whether you want it to be or not - this seems to be
% unavoidable.
%
%   6) Some earlier versions of this function the argument "order" to be an
% array. This option has been removed because it was so confusing - the
% matlab function "permute" can be used to do the same thing.
%
% EXAMPLES:
% 1) Get all the elements of the variable, note the order of the dimensions:
% >> airtemp = getnc('oberhuber.nc', 'airtemp');
% >> size(airtemp)
% ans =
%     12    90   180
%
% 2) Get a subsample of the variable, note the stride:
% >> airtemp = getnc('oberhuber.nc', 'airtemp', [-1 1 3], [-1 46 6], [1 5 1]);
% >> size(airtemp)
% ans =
%     12    10     4
%
% 3) Get all the elements of the variable, but with missing values
%    replaced with 1000.  Note that the bl_corner, tr_corner, stride and
%    order vectors have been replaced by -1 to choose the defaults:
% >> airtemp = getnc('oberhuber.nc', 'airtemp', -1, -1, -1, -1, 3, 1000); 
% >> size(airtemp)
% ans =
%     12    90   180
%
% 4) Get a subsample of the variable, a singleton dimension is squeezed:
% >> airtemp = getnc('oberhuber.nc', 'airtemp', [-1 7 -1], [-1 7 -1]);   
% >> size(airtemp)                                                         
% ans =
%     12   180
% 
% 5) Get a subsample of the variable, a singleton dimension is not squeezed:
% >> airtemp = getnc('oberhuber.nc','airtemp',[-1 7 -1],[-1 7 -1],-1,-1,-1,-1,0);
% >> size(airtemp)                                                            
% ans =
%     12     1   180
%
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

% This function calls: check_nc.m, check_st.m, fill_att.m, fill_var.m,
%                      getnc_s.m, inqnc.m, menu_old.m, mexnc, pos_cds.m,
%                      return_v.m, uncmp_nc.m, y_rescal.m

%     Copyright (C), J.V. Mansbridge, 1992
%     Commonwealth Scientific and Industrial Research Organisation
%     $Id: getnc.m Mon, 03 Jul 2006 17:16:40 $
% 
%--------------------------------------------------------------------

% In November 1998 some code was added to deal better with byte type data in a
% netcdf file. Note that any values greater than 127 will have 256 subtracted
% from them. This is because on some machines (an SGI running irix6.2 is an
% example) values are returned in the range 0 to 255. Note that in the fix the
% values less than 128 are unaltered and so we do not have to know whether the
% particular problem has occurred or not; for machines where there is no problem
% no values will be altered. This is applied to byte type attributes (like
% _FillValue) as well as the variable values.

% Check the number of arguments.  If there are no arguments then return
% the help message.  If there is more than one argument then call
% getnc_s which reads the netcdf file in a non-interactive way.
% If there is only one argument then drop through and find the values
% interactively.

num_args = length(varargin);
if num_args == 0
  % No input argument
  help getnc
  disp('You must pass an input argument to getnc')
  return
elseif num_args == 1
  if isstruct(varargin{1})
    % Send on to getnc_s
    values = getnc_s(varargin);
    return
  else
    % Carry on with the interactive version of getnc
    file = varargin{1};
  end
else
  % Send on to getnc_s
  values = getnc_s(varargin);
  return
end

% Check that the file is accessible. It may be a dods accessible file or a
% locally held netcdf file. If it is a netcdf file then its full name will
% be stored in the variable cdf.  The file may have the extent .cdf or
% .nc and be in the current directory or the common data set (whose
% path can be found by a call to pos_cds.m.  If a compressed form
% of the file is in the current directory then the user is prompted to
% uncompress it.  If, after all this, the netcdf file is not accessible
% then the m file is exited with an error message.

cdf_list = { '' '.nc' '.cdf'};
ilim = length(cdf_list);
for i = 1:ilim 
  cdf = [file cdf_list{i} ];
  err = check_nc(cdf);

  if (err == 0) | (err == 4)
    break;
  elseif err == 1
    if i == ilim
      error([ file ' could not be found' ])
    end
  elseif err == 2
    path_name = pos_cds;
    cdf = [path_name cdf];
    break;
  elseif err == 3
    err1 = uncmp_nc(cdf);
    if err1 == 0
      break;
    elseif err1 == 1
      error(['exiting because you chose not to uncompress ' cdf])
    elseif err1 == 2
      error(['exiting because ' cdf ' could not be uncompressed'])
    end
  end
end

if err == 4
  disp('!! getnc cannot deal with DODS/OPEnDAP data interactively')
  disp('!! You can use a combination of inqnc and the batch version of getnc')
  disp('!! or the OPeNDAP Matlab Graphical User Interface')
  return
end

% I make mexnc calls to find the integers that specify the attribute
% types

nc_byte = mexnc('parameter', 'nc_byte'); %1
nc_char = mexnc('parameter', 'nc_char'); %2
nc_short = mexnc('parameter', 'nc_short'); %3
nc_long = mexnc('parameter', 'nc_long'); %4
nc_float = mexnc('parameter', 'nc_float'); %5
nc_double = mexnc('parameter', 'nc_double'); %6

% Find out whether values should be automatically rescaled or not.

[rescale_var, rescale_att] = y_rescal;

% Set the value of imap.  Note that this is used simply as a
% placeholder in calls to vargetg - its value is never used.

imap = 0;

% Set some constants.

blank = abs(' ');

% Open the netcdf file.

[cdfid, rcode] = mexnc('OPEN', cdf, 'NC_NOWRITE');
if rcode == -1
  error(['** ERROR ** ncopen: rcode = ' num2str(rcode)])
end

% Suppress all error messages from netCDF 

[rcode] = mexnc('setopts', 0);

% Collect information about the cdf file.

[ndims_tot, nvars, ngatts, recdim, rcode] =  mexnc('ncinquire', cdfid);
if rcode == -1
  error(['** ERROR ** ncinquire: rcode = ' num2str(rcode)])
end

varstring = fill_var(cdfid, nvars);

% Prompt the user for the name of the variable containing the hyperslab.

k = -1;
while k <1 | k > nvars
   disp(' ')
   s = [ '----- Choose the variable -----'];
   disp(s)
   disp(' ')
   for i = 0:3:nvars-1
      stri = int2str(i+1);
      if length(stri) == 1
         stri = [ ' ' stri];
      end
      [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	  mexnc('ncvarinq', cdfid, i);
      if rcode == -1
	error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
      end
      s = [ '  ' stri ') ' varnam ];
      addit = 26 - length(s);
      for j =1:addit
         s = [ s ' '];
      end

      if i < nvars - 1
         stri = int2str(i+2);
         if length(stri) == 1
            stri = [ ' ' stri];
         end
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	     mexnc('ncvarinq', cdfid, i+1);
	 if rcode == -1
	   error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
	 end

	 s = [ s '  ' stri ') ' varnam ];
         addit = 52 - length(s);
         for j =1:addit
            s = [ s ' '];
         end
      end 

      if i < nvars - 2
         stri = int2str(i+3);
         if length(stri) == 1
            stri = [ ' ' stri];
         end
         [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	     mexnc('ncvarinq', cdfid, i+2);
	 if rcode == -1
	   error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
	 end
         s = [ s '  ' stri ') ' varnam ];
      end 
      disp(s)
   end
   disp(' ')
   s = [ 'Select a menu number: '];
   k = return_v(s, -1);
end

% try to get information about the variable

varid = k - 1;
[varnam, vartypv, nvdims, vdims, nvatts, rcode] = ...
    mexnc('ncvarinq', cdfid, varid);
if rcode == -1
  error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
end
attstring = fill_att(cdfid, varid, nvatts);

% Turn off the rescaling of the byte type data because mexnc does not do this
% for variables anyway. The rescaling of the VALUES array will be done
% explicitly.

if vartypv == nc_byte
  rescale_var = 0;
  rescale_att = 0;
end

if nvdims > 0
  message = cell(nvdims, 1);
  name_dim = cell(nvdims, 1);
end

for i = 1:nvdims
    dimid = vdims(i);
    [name, sizem, rcode] = mexnc('ncdiminq', cdfid, dimid);
    if rcode == -1
      error(['** ERROR ** ncdiminq: rcode = ' num2str(rcode)])
    end
    if sizem == 0
      error([varnam ' has dimension ' name ' which has zero length']);
    end

   name_dim{i, 1} = name;
   ledim(i) = sizem - 1;

   % Test that the dimension name is also a variable name.  If it is then
   % store information about its initial and final values in the string s.

    rhid = check_st(name, varstring, nvars) - 1;

   if rhid >= 0
      [namejunk, dvartyp, dnvdims, vdimsjunk, nvattsjunk, rcode] = ...
	  mexnc('ncvarinq', cdfid, rhid);
      if rcode == -1
	error(['** ERROR ** ncvarinq: rcode = ' num2str(rcode)])
      end
      if sizem <= 6
         [temp, rcode] = mexnc('ncvarget', cdfid, rhid, [0], [sizem], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:sizem
            s = [ s ' ' num2str(temp(j)) ];
         end
      else
         [temp1, rcode] = mexnc('ncvarget', cdfid, rhid, [0], [3], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
         s = ' : Elements';
         for j = 1:3
            s = [ s ' ' num2str(temp1(j)) ];
         end
         [temp2, rcode] = mexnc('ncvarget', cdfid, rhid, [sizem-3], [3], rescale_var);
	 if rcode == -1
	   error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
	 end
	 s= [ s ' ...' ];
         for j = 1:3
            s = [ s ' ' num2str(temp2(j)) ];
         end
      end
   else
      s = [ ' '];
   end
   s = [ '   ' int2str(i) ')  ' name ' : Length ' int2str(sizem) s ];
   message{i, 1} = s;
   disp(s)
end

% initialise the bl_corner, edge and stride vectors.

if nvdims > 0
  bl_corner = -10*ones(1, nvdims);
  edge = ones(1, nvdims);
  stride = ones(1, nvdims);
else
  bl_corner = 0;
  edge = 1;
  stride = 1;
end

% ask for the index at a point or the bl_corners, edges and strides in
% order to retrieve a (possibly generalised) hyperslab.

take_stride = 0;
for i = 1:nvdims

  % first get the starting point

  name = name_dim{i, 1};
  bl_corner(i) = -1;
  while bl_corner(i) < 0 | bl_corner(i) > ledim(i)
    s = message{i, 1};
    disp(' ')
    disp(s)
    s = [ '    ' name ' : Starting index (between 1 and '];
    s = [ s int2str(ledim(i)+1) ')  (cr for all indices)  ' ];
    clear xtemp;
    xtemp = input(s);
    if isempty(xtemp)
      bl_corner(i) = 0;
      edge(i) = ledim(i) + 1;
      notdone = 0;
    else
      bl_corner(i) = xtemp - 1;
      notdone = 1;
    end
  end

  % next, get the finishing and stride point if these are required.

  if notdone == 1
    tr_corner = -1;
    ste = [];
    for ii = 1:length(name)
      ste = [ ste ' ' ];
    end
    while tr_corner < bl_corner(i) | tr_corner > ledim(i)
      s = [ ste '      finishing index (between ' int2str(bl_corner(i)+1) ];
      s = [ s ' and ' int2str(ledim(i)+1) ')  '];
      ret_val = return_v(s, tr_corner+1);
      tr_corner = ret_val - 1;
    end

    stride(i) = -1;
    s=[ ste '      stride length (cr for 1)  ' ];
    while stride(i) < 0 | stride(i) > ledim(i)
      clear xtemp;
      stride(i) = return_v(s, 1);
    end
    
    % Decide whether any non-unit strides are to be taken.

    if stride(i) > 1
      take_stride = 1;
    end

    % Calculate the edge length

    edge(i) = fix( ( tr_corner - bl_corner(i) )/stride(i) ) + 1;
  end
end

% Retrieve the array.

lenstr = prod(edge);
if take_stride
  [values, rcode] = mexnc('ncvargetg', cdfid, varid, bl_corner, ...
      edge, stride, imap, rescale_var);
  if rcode == -1
    error(['** ERROR ** ncvargetg: rcode = ' num2str(rcode)])
  end
else
  if nvdims == 0
    [values, rcode] = mexnc('ncvarget1', cdfid, varid, bl_corner, rescale_var);
  else 
    [values, rcode] = mexnc('ncvarget', cdfid, varid, bl_corner, ...
			    edge, rescale_var);
    if rcode == -1
      error(['** ERROR ** ncvarget: rcode = ' num2str(rcode)])
    end
  end
end
  
% Do possible byte correction.
  
if vartypv == nc_byte
  ff = find(values > 127);
  if ~isempty(ff)
    values(ff) = values(ff) - 256;
  end
end

% Handle singleton dimensions.

si = size(values);
len_si = length(si);
squeeze_it = 0;
if (len_si > 2) & (min(si) == 1)
  s = 'Do you want singleton dimensions removed?';
  repeat_it = 1;
  while repeat_it
    sq_tmp = menu_old(s, 'yes', 'no');
    if isnumeric(sq_tmp) & (length(sq_tmp) == 1)
      if ismember(sq_tmp, [1 2])
	repeat_it = 0;
      end
    end
    if repeat_it
      disp(' ')
      disp('!!! You must choose a number fron the menu - try again')
    end
  end
  squeeze_it = 2 - sq_tmp;
end

% If required do the squeeze.  As well, a new cell array, name_dim_rev, is
% defined to contain the names of the dimensions (whether there has been a
% squeezing or not).

for ii = 1:nvdims
  name_dim_rev{ii} = name_dim{nvdims - ii + 1};
end

if squeeze_it == 1
  ff = find(si ~= 1); % Only non-singleton dimensions are interesting
  for ii = 1:length(ff)
    name_dim_rev{ii} = name_dim_rev{ff(ii)};
  end
  values = squeeze(values);
  si = size(values);
  len_si = length(si);
end

% Calculate num_mults which describes the type of array.

if (len_si > 2)
  num_mults = len_si; % multi-dimensional array.
else
  if max(si) == 1
    num_mults = 0; % number
  elseif min(si) == 1
    num_mults = 1; % vector
  else
    num_mults = 2; % matrix
  end
end

% Manipulate the array according to whether it is a vector, matrix or
% multi-dimensional array.  This may involve permuting arrays.

if num_mults == 0
  
  % getting back a constant
  
elseif num_mults == 1
  
  % ask whether the user wants a row or column vector.

  s = 'Do you want a row vector or a column vector returned?';
  s1 = [ 'row vector' ];
  s2 = [ 'column vector' ];
  repeat_it = 1;
  while repeat_it
    order = menu_old(s, s1, s2);
    if isnumeric(order) & (length(order) == 1)
      if ismember(order, [1 2])
	repeat_it = 0;
      end
    end
    if repeat_it
      disp(' ')
      disp('!!! You must choose a number fron the menu - try again')
    end
  end
  num_rows = size(values, 1);
  if num_rows == 1
    if order == 2
      values = values';
    end
  else
    if order == 1
      values = values';
    end
  end
    
elseif num_mults == 2
  
  % Ask about transposing the matrix. Note that mexnc has returned the
  % elements in the most efficient way, i.e., it has not done any
  % permutation.
  
  order = 0;
  s = 'In which order do you want the indices?';
  s1 = [ varnam '(' name_dim_rev{2} ',' name_dim_rev{1} ')' ];
  s2 = [ varnam '(' name_dim_rev{1} ',' name_dim_rev{2} ')' ];
  repeat_it = 1;
  while repeat_it
    order = menu_old(s, s1, s2);
    if isnumeric(order) & (length(order) == 1)
      if ismember(order, [1 2])
	repeat_it = 0;
      end
    end
    if repeat_it
      disp(' ')
      disp('!!! You must choose a number fron the menu - try again')
    end
  end
  if order == 1
    values = values';
  end

else
  
  % A multi-dimensional array. Permute the indices so that they will be
  % consistent with the ncdump output and print out information about
  % multi-dimensional array.
  
  values = permute(values, (num_mults:-1:1));
  
  str = ['The array is ' varnam '('];
  for ii = num_mults:-1:2
    str = [str name_dim_rev{ii} ', '];
  end
  str = [str name_dim_rev{1} ')'];
  disp(str)
end

% Find any scale factors or offsets.

pos = check_st('scale_factor', attstring, nvatts);
if pos > 0
   [scalef, rcode] = mexnc('attget', cdfid, varid, 'scale_factor');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end
else
   scalef = [];
end
pos = check_st('add_offset', attstring, nvatts);
if pos > 0
   [addoff, rcode] = mexnc('attget', cdfid, varid, 'add_offset');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end
else
   addoff = [];
end

% check for missing values.  Note that a
% missing value is taken to be one less than valid_min, greater than
% valid_max or 'close to' _FillValue or missing_value.
% Note 1: valid_min and valid_max may be specified by the attribute
%   valid_range and if valid_range exists than the existence of
%   valid_min and valid_max is not checked.
% Note 2: a missing value must be OUTSIDE the valid range to be
%   recognised.
% Note 3: a range does not make sense for character arrays.
% Note 4: By 'close to' _FillValue I mean that an integer or character
%   must equal _FillValue and a real must be in the range
%   0.99999*_FillValue tp 1.00001*_FillValue.  This allows real*8 
%   rounding errors in moving the data from the netcdf file to matlab;
%   these errors do occur although I don't know why given that matlab
%   works in double precision.
% Note 5: An earlier version of this software checked for an attribute
%   named missing_value.  This check was taken out because,
%   although in common use, missing_value was not given in the netCDF
%   manual list of attribute conventions.  Since it has now appeared in
%   the netCDF manual I have put the check back in.

% The indices of the data points containing missing value indicators
% will be stored separately in index_miss_low, index_miss_up, 
% index_missing_value and index__FillValue.

index_miss_low = [];
index_miss_up = [];
index__FillValue = [];
index_missing_value = [];

% First find the indices of the data points that are outside the valid
% range.

pos_vr = check_st('valid_range', attstring, nvatts);
if pos_vr > 0
   [attype, attlen, rcode] = mexnc('ncattinq', cdfid, varid, 'valid_range');
   if rcode == -1
     error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
   end
   [ miss, rcode] = mexnc('ncattget', cdfid, varid, 'valid_range');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end
      
   % Check that valid_range is a 2 element vector.
    
   if length(miss) ~= 2
     error(['The valid_range attribute must be a vector'])
   end
    
   % Correct for possible faulty handling of byte type
    
   if attype == nc_byte
     if miss(1) > 127; miss(1) = miss(1) - 256; end
     if miss(2) > 127; miss(2) = miss(2) - 256; end
   end

   miss_low = miss(1);
   miss_up = miss(2);
   
   % Rescale & add offsets if required.
   
   if rescale_att == 1
     if isempty(scalef) == 0
       miss_low = miss_low*scalef;
       miss_up = miss_up*scalef;
     end
     if isempty(addoff) == 0
       miss_low = miss_low + addoff;
       miss_up = miss_up + addoff;
     end
   end
   
   index_miss_low = find ( values < miss_low );
   index_miss_up = find ( values > miss_up );
 
else
  pos_min = check_st('valid_min', attstring, nvatts);
  if pos_min > 0
    [attype, attlen, rcode] = mexnc('ncattinq', cdfid, varid, 'valid_min');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_low, rcode] = mexnc('ncattget', cdfid, varid, 'valid_min');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that valid_min is a scalar
    
    if length(miss_low) ~= 1
      error(['The valid_min attribute must be a scalar'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_low > 127; miss_low = miss_low - 256; end
    end
    miss_low_orig = miss_low;
    
    % Rescale & add offsets if required.
   
    if rescale_att == 1
      if isempty(scalef) == 0
	miss_low = miss_low*scalef;
      end
      if isempty(addoff) == 0
	miss_low = miss_low + addoff;
      end
    end
      
    index_miss_low = find ( values < miss_low );
  end

  pos_max = check_st('valid_max', attstring, nvatts);
  if pos_max > 0
    [attype, attlen, rcode] = mexnc('ncattinq', cdfid, varid, 'valid_max');
    if rcode == -1
      error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
    end
    [miss_up, rcode] = mexnc('ncattget', cdfid, varid, 'valid_max');
    if rcode == -1
      error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
    end

    % Check that valid_max is a scalar
    
    if length(miss_up) ~= 1
      error(['The valid_max attribute must be a scalar'])
    end
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_up > 127; miss_up = miss_up - 256; end
    end
    miss_up_orig = miss_up;

    % Rescale & add offsets if required.
   
    if rescale_att == 1
      if isempty(scalef) == 0
	miss_up = miss_up*scalef;
      end
      if isempty(addoff) == 0
	miss_up = miss_up + addoff;
      end
    end
    
    index_miss_up = find ( values > miss_up );
  end
end

% Now find the indices of the data points that are 'close to'
% _FillValue.  Note that 'close to' is different according to the
% data type.

pos_missv = check_st('_FillValue', attstring, nvatts);
if pos_missv > 0
   [attype, attlen, rcode] = mexnc('ncattinq', cdfid, varid, '_FillValue');
   if rcode == -1
     error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
   end
   [miss_val, rcode] = mexnc('ncattget', cdfid, varid, '_FillValue');
   if rcode == -1
     error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
   end

    % Check that _FillValue_orig is a scalar
    
    if length(miss_val) ~= 1
      error(['The _FillValue attribute must be a scalar'])
    end
    
    % Correct for possible faulty handling of byte type
    
    if attype == nc_byte
      if miss_val > 127; miss_val = miss_val - 256; end
    end
    fill_value_orig = miss_val;
   
   % Rescale & add offsets if required.
   
   if rescale_att == 1
     if isempty(scalef) == 0
       miss_val = miss_val*scalef;
     end
     if isempty(addoff) == 0
       miss_val = miss_val + addoff;
     end
   end
   
   if attype == nc_byte | attype == nc_char
     index__FillValue = find ( values == miss_val );
   elseif attype == nc_short | attype == nc_long
     need_index_m = 1;
     if pos_vr > 0 | pos_min > 0
       if miss_val < miss_low
	 need_index_m = 0;
       end
     end
     if pos_vr > 0 | pos_max > 0
       if miss_val > miss_up
	 need_index_m = 0;
       end
     end
     if need_index_m
       index__FillValue = find ( values == miss_val );
     end
   elseif attype == nc_float | attype == nc_double
     need_index_m = 1;
     if miss_val < 0
       miss_val_low = 1.00001*miss_val;
       miss_val_up = 0.99999*miss_val;
     else
       miss_val_low = 0.99999*miss_val;
       miss_val_up = 1.00001*miss_val;
     end
     
     if pos_vr > 0 | pos_min > 0
       if miss_val_up < miss_low
	 need_index_m = 0;
       end
     end
     if pos_vr > 0 | pos_max > 0
       if miss_val_low > miss_up
	 need_index_m = 0;
       end
     end
     if need_index_m
       index__FillValue = find ( miss_val_low <= values & ...
	   values <= miss_val_up );
     end
   end
 end

% Now find the indices of the data points that are 'close to'
% missing_value.  Note that 'close to' is different according to the
% data type.

pos_missv = check_st('missing_value', attstring, nvatts);
if pos_missv > 0
  [attype, attlen, rcode] = mexnc('ncattinq', cdfid, varid, 'missing_value');
  if rcode == -1
    error(['** ERROR ** ncattinq: rcode = ' num2str(rcode)])
  end
  [miss_val, rcode] = mexnc('ncattget', cdfid, varid, 'missing_value');
  if rcode == -1
    error(['** ERROR ** ncattget: rcode = ' num2str(rcode)])
  end
   
  % Check that missing_value is a scalar
    
  if length(miss_val) ~= 1
    error(['The missing_value attribute must be a scalar'])
  end
    
  % Correct for possible faulty handling of byte type
    
  if attype == nc_byte
    if miss_val > 127; miss_val = miss_val - 256; end
  end
    
  % Rescale & add offsets if required.
   
  if rescale_att == 1
    if isempty(scalef) == 0
      miss_val = miss_val*scalef;
    end
    if isempty(addoff) == 0
      miss_val = miss_val + addoff;
    end
  end
   
  if attype == nc_byte | attype == nc_char
    index_missing_value = find ( values == miss_val );
  elseif attype == nc_short | attype == nc_long
    need_index_m = 1;
    if pos_vr > 0 | pos_min > 0
      if miss_val < miss_low
	need_index_m = 0;
      end
    end
    if pos_vr > 0 | pos_max > 0
      if miss_val > miss_up
	need_index_m = 0;
      end
    end
    if need_index_m
      index_missing_value = find ( values == miss_val );
    end
  elseif attype == nc_float | attype == nc_double
    need_index_m = 1;
    if miss_val < 0
      miss_val_low = 1.00001*miss_val;
      miss_val_up = 0.99999*miss_val;
    else
      miss_val_low = 0.99999*miss_val;
      miss_val_up = 1.00001*miss_val;
    end

    if pos_vr > 0 | pos_min > 0
      if miss_val_up < miss_low
	need_index_m = 0;
      end
    end
    if pos_vr > 0 | pos_max > 0
      if miss_val_low > miss_up
	need_index_m = 0;
      end
    end
    if need_index_m
      index_missing_value = find ( miss_val_low <= values & ...
	  values <= miss_val_up );
    end
  end
end

%Combine the arrays of missing value indices into one unordered array.
%Note that for real numbers the range of the _FillValue and
%missing_value may intersect both the valid and invalid range and so
%some indices may appear twice; this does not cause any inaccuracy,
%although it will result in some inefficiency.  In particular, rescaling
%is done on the set of indices NOT in index_miss and so is not
%affected.

index_miss = [ index_miss_low(:); index__FillValue(:); ...
    index_missing_value(:); index_miss_up(:) ];
%index_miss = sort(index_miss);
len_index_miss = length(index_miss);

% If there are any missing values then offer to change them to a
% more convenient value.

if len_index_miss > 0
   s = [ varnam ' contains missing values:  Choose an action' ];
   s1 = 'Leave the missing value unchanged';
   s2 = 'Replace the missing value with NaN';
   s3 = 'Replace the missing value with a new value';
   repeat_it = 1;
   while repeat_it
     k = menu_old(s, s1, s2, s3);
     if isnumeric(k) & (length(k) == 1)
       if ismember(k, [1 2 3])
	 repeat_it = 0;
       end
     end
     if repeat_it
       disp(' ')
       disp('!!! You must choose a number fron the menu - try again')
     end
   end
   switch k
    case 2
     if vartypv == nc_char
       values(index_miss) = '#';
       values = char(values);
     else
       values(index_miss) = NaN;
     end
    case 3
     if vartypv == nc_char
       s = '   Type in your new missing value marker [*]  ';
       new_miss = return_v(s, '*');
       values(index_miss) = new_miss;
       values = char(values);
     else
       s = '   Type in your new missing value marker [0]  ';
       new_miss = return_v(s, 0);
       values(index_miss) = new_miss;
     end     
   end
end

% Rescale the byte type data which was not done automatically. If the otion
% to not rescale has been selected then scalef and addoff will be empty and
% ther will be no rescaling.

if vartypv == nc_byte
  if ~isempty(scalef)
    values = values*scalef;
  end
  if ~isempty(addoff)
    values = values + addoff;
  end
end
    
% Close the netcdf file.

[rcode] = mexnc('ncclose', cdfid);
if rcode == -1
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end
