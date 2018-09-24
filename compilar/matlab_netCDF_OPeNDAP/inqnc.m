function inqnc(file)
% INQNC interactively returns info about a netcdf file or DODS/OPEnDAP dataset
%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, january 24 1992
%     Revision $Revision: 1.20 $
%
%  function inqnc(file)
%
% DESCRIPTION:
%  inqnc('file') is an interactive function that returns information
%  about a netcdf file or DODS dataset. 
% INPUT:
%  file may be the name of a netCDF file with or it may be the URL of a
%  DODS/OPEnDAP dataset. 
%
% OUTPUT:
%  information is written to the user's terminal.
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     $Id: inqnc.m Mon, 03 Jul 2006 17:16:40 $
% 
% Note that the netcdf functions are accessed by reference to the mex
% function mexnc. The DODS/OPEnDAP use the Matlab Structs tool.
%--------------------------------------------------------------------

% This function calls: check_nc.m, get_dods_dds.m, loaddap or loaddods,
%                      mexnc, pos_cds.m, uncmp_nc.m, 
% This function is called by:

% In November 1998 some code was added to deal better with byte type data. Note
% that any values greater than 127 will have 256 subtracted from them. This is
% because on some machines (an SGI running irix6.2 is an example) values are
% returned in the range 0 to 255. Note that in the fix the values less than 128
% are unaltered and so we do not have to know whether the particular problem has
% occurred or not; for machines where there is no problem no values will be
% altered. This is applied to byte type attributes (like _FillValue) as well as
% the variable values.

% Check the number of arguments.

if nargin < 1
   help inqnc
   return
end

% Do some initialisation.

blank = abs(' ');
[mex_name, full_name, desc_das, file_status, exe_name] = ...
    choose_mexnc_opendap(file);

switch mex_name
 case 'mexnc'

  % I make mexnc calls to find the integers that specify the attribute
  % types

  nc_byte = mexnc('parameter', 'nc_byte'); %1
  nc_char = mexnc('parameter', 'nc_char'); %2
  nc_short = mexnc('parameter', 'nc_short'); %3
  nc_long = mexnc('parameter', 'nc_long'); %4
  nc_float = mexnc('parameter', 'nc_float'); %5
  nc_double = mexnc('parameter', 'nc_double'); %6

  % Open the netcdf file.
  
  [cdfid, rcode] = mexnc('ncopen', full_name, 'nowrite');
  if rcode < 0
    error(['mexnc: ncopen: rcode = ' int2str(rcode)])
  end

  % don't print out netcdf warning messages

  mexnc('setopts',0);

  % Collect information about the cdf file.

  [ndims, nvars, ngatts, recdim, rcode] =  mexnc('ncinquire', cdfid);
  if rcode < 0
    error([ 'mexnc: ncinquire: rcode = ' int2str(rcode) ])
  end

  % Find and print out the global attributes of the cdf file.

  if ngatts > 0
    disp('                ---  Global attributes  ---')
    for i = 0:ngatts-1
      [attnam, rcode] = mexnc('attname', cdfid, 'global', i);
      [attype, attlen, rcode] = mexnc('ncattinq', cdfid, 'global', attnam);
      [values, rcode] = mexnc('ncattget', cdfid, 'global', attnam);
      %keyboard   

      % Write each attribute into the string s.  Note that if
      % the attribute is already a string then we replace any
      % control characters with a # to avoid messing up the
      % display - null characters make a major mess. There may
      % also be a correction for faulty handling of byte type.
      
      if attype == nc_byte
	ff = find(values > 127);
	if ~isempty(ff)
	  values(ff) = values(ff) - 256;
	end
	s = int2str(values);
      elseif attype == nc_char
	s = abs(values);
	fff = find(s < 32);
	s(fff) = 35;
	s = char(s);
      elseif attype == nc_short | attype == nc_long
	s = [];
	for i = 1:length(values)
	  s = [ s int2str(values(i)) '  ' ];
	end
      elseif attype == nc_float | attype == nc_double
	s = [];
	for i = 1:length(values)
	  s = [ s num2str(values(i)) '  ' ];
	end
      end
      s = [ attnam ': ' s ];
      disp(s)
    end
  else
    disp('   ---  There are no Global attributes  ---')
  end

  % Get and print out information about the dimensions.

  disp(' ')
  s = [ 'The ' int2str(ndims) ' dimensions are' ];
  for i = 0:ndims-1
    [dimnam, dimsiz, rcode] = mexnc('ncdiminq', cdfid, i);
    s = [ s '  ' int2str(i+1) ') ' dimnam ' = ' int2str(dimsiz) ];
  end
  s = [ s '.'];
  disp(s)
  if isempty(recdim)
    disp('It is not possible to access an unlimited dimension')
  else
    if recdim == -1
      disp('None of the dimensions is unlimited')
    else
      [dimnam, dimsiz, rcode] = mexnc('ncdiminq', cdfid, recdim);
      s = [ dimnam ' is unlimited in length'];
      disp(s)
    end
  end

  % Print out the names of all of the variables so that the user may
  % choose to 1) finish the inquiry, 2) print out information about all
  % variables or 3) print out information about only one of them.

  infinite = 1;
  while infinite
    k = -2;
    while k <-1 | k > nvars
      disp(' ')
      s = [ '----- Get further information about the following variables -----'];
      disp(s)
      disp(' ')
      s = [ '  -1) None of them (no further information)' ];
      disp(s)
      s = [ '   0) All of the variables' ];
      disp(s)
      for i = 0:3:nvars-1
	stri = int2str(i+1);
	if length(stri) == 1
	  stri = [ ' ' stri];
	end
	[varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	    mexnc('ncvarinq', cdfid, i);
	s = [ '  ' stri ') ' varnam ];
	addit = 26 - length(s);
	for j =1:addit
	  s = [ s ' '];
	end
	
	if i < nvars-1
	  stri = int2str(i+2);
	  if length(stri) == 1
	    stri = [ ' ' stri];
	  end
	  [varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	      mexnc('ncvarinq', cdfid, i+1);
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
	  s = [ s '  ' stri ') ' varnam ];
	end 
	disp(s)
      end
      disp(' ')
      s = [ 'Select a menu number: '];
      k = input(s);
    end
    
    % Get and print out information about as many variables as necessary.
    % If k == - 1 close the netcdf file and return.
    
    if k == -1
      [rcode] = mexnc('ncclose', cdfid);
      if rcode < 0
	error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
      end
      return
    elseif k == 0
      klow = 0;
      kup = nvars - 1;
    else
      klow = k - 1;
      kup = k - 1;
    end
    
    if nvars > 0
      for k = klow:kup
	[varnam, vartyp, nvdims, vdims, nvatts, rcode] = ...
	    mexnc('ncvarinq', cdfid, k); 
	
	% Write out a message containing the dimensions of the variable.

	s = [ '   ---  Information about ' varnam '(' ];
	for j = 1:nvdims
	  [dimnam, dimsiz, rcode] = mexnc('ncdiminq', cdfid, vdims(j));
	  s = [ s dimnam ' ' ];
	end
	s = [ s ')  ---' ];
	disp(' ')
	disp(s)
	
	% Find and print out the attributes of the variable.
	
	if nvatts > 0
	  disp(' ')
	  s = [ '   ---  ' varnam ' attributes  ---' ];
	  left_side = 1;
	  for j = 0:nvatts-1
	    [attnam, rcode] = mexnc('ncattname', cdfid, k, j); 
	    [attype, attlen, rcode] = mexnc('ncattinq', cdfid, ...
					    k, attnam); 
	    [values, rcode] = mexnc('ncattget', cdfid, k, attnam);

	    % Write each attribute into the string s.  Note that if
	    % the attribute is already a string then we replace any
	    % control characters with a # to avoid messing up the
	    % display - null characters make a major mess. There may
	    % also be a correction for faulty handling of byte type.
	    if attype == nc_byte
	      ff = find(values > 127);
	      if ~isempty(ff)
		values(ff) = values(ff) - 256;
	      end
	      s = int2str(values);
	    elseif attype == nc_char
	      s = abs(values);
	      fff = find(s < 32);
	      s(fff) = 35;
	      s = char(s);
	    elseif attype == nc_short | attype == nc_long
	      s = [];
	      for ii = 1:length(values)
		s = [ s int2str(values(ii)) '  ' ];
	      end
	    elseif attype == nc_float | attype == nc_double
	      s = [];
	      for ii = 1:length(values)
		s = [ s num2str(values(ii)) '  ' ]; 
	      end
	    end
	    
	    % Go through convolutions to try to fit information about two
            % attributes onto one line.
	    
	    le_att = length(attnam);
	    le_s = length(s);
	    le_sum = le_att + le_s;
	    st = [ '*' attnam ': ' s ];
	    if left_side == 1
	      if le_sum > 37
		disp(st)
	      else
		n_blanks = 37 - le_sum;
		if n_blanks > 1
		  for ii = 1:n_blanks
		    st = [ st ' ' ];
		  end
		end
		temp = st;
		left_side = 0;
	      end
	    else
	      if le_sum > 37
		disp(temp)
	      else
		st = [ temp st ];
	      end
	      disp(st)
	      left_side = 1;
	    end
	  end
	  if left_side == 0
	    disp(temp)
	  end
	else
	  s = [ '*  ' varnam ' has no attributes' ];
	  disp(s)
	end
      end
    else
      disp(' ')
      disp('   ---  There are no variables  ---')
    end
  end

 case {'loaddap', 'loaddods'}
  
  % Dealing with a dods file

  % Find and print out the global attributes of the dods file. We use the
  % information about the DAS that was previously obtained by a call to
  % loaddap or loaddods.

  try
    % desc_das_down_1 = desc_das.('Global_Attributes');
    desc_das_down_1 = getfield(desc_das, 'Global_Attributes');
  catch
    error('desc_das does not have a field Global_Attributes')
  end
  
  fnames_1 = fieldnames(desc_das_down_1);
  found_global = 0;
  for ii = 1:length(fnames_1)
    if length(fnames_1{ii}) > 7
      if strcmp(lower(fnames_1{ii}(end-6:end)), '_global')
	ii_1 = ii;
	found_global = 1;
	break
      end
    end
  end
  
  ngatts = 0;
  if found_global
    %desc_das_down_2 = desc_das_down_1.(fnames_1{ii_1});  
    desc_das_down_2 = getfield(desc_das_down_1, fnames_1{ii_1});  
    if isstruct(desc_das_down_2)
      list_gatts = fieldnames(desc_das_down_2);
      for ii = 1:length(list_gatts)
	if ((strcmp(list_gatts(ii), 'DODS_ML_Real_Name') == 0) & ...
	    (strcmp(list_gatts(ii), 'DODS_ML_Type') == 0))
	  ngatts = ngatts + 1;
	  att_name{ngatts} = list_gatts{ii};
	end
      end
    end
  end
  
  if ngatts > 0
    disp('                ---  Global attributes  ---')
    for ii = 1:ngatts
      %values = desc_das_down_2.(att_name{ii});
      values = getfield(desc_das_down_2, att_name{ii});

      % Write each attribute into the string s.  Note that if
      % the attribute is already a string then we replace any
      % control characters with a # to avoid messing up the
      % display - null characters make a major mess. We also strip off
      % extraneous quote marks.
      
      if ischar(values)
	s = abs(values);
	s = s(2:(end - 1));
	ff = find(s < 32);
	s(ff) = 35;
	s = char(s);
      else
	s = [];
	for jj = 1:length(values)
	  s = [s num2str(values(jj)) '  ' ];
	end
      end
      disp([att_name{ii} ': ' s ])
    end
  else
    disp('   ---  There are no Global attributes  ---')
  end
  
  % Get and print out information about the dimensions. This information is
  % obtained from the DDS. The DAS is also searched to look for the name of
  % any unlimited dimension.

  [dds_text, desc_dds] = get_dods_dds(full_name, exe_name);
  ndims = length(desc_dds.dimension);
  
  disp(' ')
  s = [ 'The ' int2str(ndims) ' dimensions are' ];
  for ii = 1:ndims
    s = [ s '  ' num2str(ii) ') ' desc_dds.dimension(ii).name ' = ' ...
	  num2str(desc_dds.dimension(ii).length) ];
  end
  s = [ s '.'];
  disp(s)

  found_unlim_dim = 0;
  if isfield(desc_das, 'Global_Attributes')
    %dd1 = desc_das.('Global_Attributes');
    dd1 = getfield(desc_das, 'Global_Attributes');
    if isfield(dd1, 'DODS_EXTRA');
      %dd2 = dd1.('DODS_EXTRA');
      dd2 = getfield(dd1, 'DODS_EXTRA');
      if isfield(dd2, 'Unlimited_Dimension')
	%dd3 = dd2.('Unlimited_Dimension');
	dd3 = getfield(dd2, 'Unlimited_Dimension');
	name_unlim_dim = dd3(2:(end - 1));
	found_unlim_dim = 1;
      end
    end
  end
  if found_unlim_dim
    disp([name_unlim_dim ' is unlimited in length'])
  else
    disp('No unlimited dimensions were found')
  end
  
  % Print out the names of all of the variables so that the user may
  % choose to 1) finish the inquiry, 2) print out information about all
  % variables or 3) print out information about only one of them.

  nvars = length(desc_dds.variable);
  infinite = 1;
  while infinite
    k = -2;
    while k <-1 | k > nvars
      disp(' ')
      s = [ '----- Get further information about the following variables -----'];
      disp(s)
      disp(' ')
      s = [ '  -1) None of them (no further information)' ];
      disp(s)
      s = [ '   0) All of the variables' ];
      disp(s)
      for ii = 1:3:nvars
	stri = int2str(ii);
	if length(stri) == 1
	  stri = [ ' ' stri];
	end
	s = [ '  ' stri ') ' desc_dds.variable(ii).name ];
	addit = 26 - length(s);
	for j =1:addit
	  s = [ s ' '];
	end
	
	if ii < nvars
	  stri = int2str(ii + 1);
	  if length(stri) == 1
	    stri = [ ' ' stri];
	  end
	  s = [ s '  ' stri ') ' desc_dds.variable(ii + 1).name ];
	  addit = 52 - length(s);
	  for j =1:addit
	    s = [ s ' '];
	  end
	end 
	
	if ii < nvars - 1
	  stri = int2str(ii + 2);
	  if length(stri) == 1
	    stri = [ ' ' stri];
	  end
	  s = [ s '  ' stri ') ' desc_dds.variable(ii + 2).name ];
	end 
	disp(s)
      end
      disp(' ')
      s = [ 'Select a menu number: '];
      k = input(s);
    end
    
    % Get and print out information about as many variables as necessary.
    % If k == - 1 close the netcdf file and return.
    
    if k == -1
      return
    elseif k == 0
      klow = 1;
      kup = nvars;
    else
      klow = k;
      kup = k;
    end
    
    if nvars > 0
      for k = klow:kup
	
	% Write out a message containing the dimensions of the variable.

	varnam = desc_dds.variable(k).name;
	s = [ '   ---  Information about ' varnam '(' ];	
	index_list = desc_dds.variable(k).dim_idents;
	nvdims = length(index_list);
	for j = 1:nvdims
	  s = [ s  desc_dds.dimension(index_list(j)).name ' ' ];
	end
	s = [ s ')  ---' ];
	disp(' ')
	disp(s)
	
	% Find all of the attributes of the variable. Note that
        % desc_das contains more attributes than in the original file. We
        % assume that there are no more 'genuine' attributes after the first
        % appearance of an attribute name starting with 'DODS_ML_' (this may
        % in fact be 'DODS_ML_Size', 'DODS_ML_Real_Name' or 'DODS_ML_Type').
	
	%att_list = desc_das.(varnam);
	att_list = getfield(desc_das, varnam);
	att_names = fieldnames(att_list);
	nvatts = 1;
	while 1
	  if isempty(findstr(att_names{nvatts}, 'DODS_ML_'))
	    nvatts = nvatts + 1;
	  else
	    nvatts = nvatts - 1;
	    break
	  end
	end
	
	% Print the attributes; do it one at a time.
	
	if nvatts > 0
	  disp(' ')
	  s = [ '   ---  ' varnam ' attributes  ---' ];
	  left_side = 1;
	  for j = 1:nvatts
	    attnam = att_names{j};
	    %values = att_list.(att_names{j});
	    values = getfield(att_list, att_names{j});
	    
	    % Write each attribute into the string s.  Note that if
	    % the attribute is already a string then we replace any
	    % control characters with a # to avoid messing up the
	    % display - null characters make a major mess. We also strip off
	    % extraneous quote marks.
      
	    if ischar(values)
	      s = abs(values);
	      s = s(2:(end - 1));
	      ff = find(s < 32);
	      s(ff) = 35;
	      s = char(s);
	    else
	      s = [];
	      for jj = 1:length(values)
		s = [s num2str(values(jj)) '  ' ];
	      end
	    end
	    
	    % Go through convolutions to try to fit information about two
            % attributes onto one line.
	    
	    le_att = length(attnam);
	    le_s = length(s);
	    le_sum = le_att + le_s;
	    st = [ '*' attnam ': ' s ];
	    if left_side == 1
	      if le_sum > 37
		disp(st)
	      else
		n_blanks = 37 - le_sum;
		if n_blanks > 1
		  for ii = 1:n_blanks
		    st = [ st ' ' ];
		  end
		end
		temp = st;
		left_side = 0;
	      end
	    else
	      if le_sum > 37
		disp(temp)
	      else
		st = [ temp st ];
	      end
	      disp(st)
	      left_side = 1;
	    end
	  end
	  if left_side == 0
	    disp(temp)
	  end
	else
	  s = [ '*  ' varnam ' has no attributes' ];
	  disp(s)
	end
      end
    else
      disp(' ')
      disp('   ---  There are no variables  ---')
    end
  end
 case 'none'
  error(['Couldn''t find a suitable mex-file for reading ' file])
end