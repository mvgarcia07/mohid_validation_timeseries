function [modeldata, time_values,model_index] = getmodelprop(file,inidate,enddate,column);
    
    
	mfid = fopen(file);
	model_index=0;
	if (exist (file) == 0)
	 
	 disp(['no file ', file])
	 mfidi = fopen('error_timeseries.dat','a');
     fprintf (mfidi,'%s\n',['no file ', file]);
     fclose(mfidi)
	 modeldata=[];
	 time_values=[];
	 model_index=1;
	 return
	end
	
    %get file size
    filesize = 0;  
    while ~feof(mfid);
      line = fgets(mfid);
      filesize = filesize+1;
    end
    %rewind file
    frewind(mfid);
    
    %read header and find block begin
    i = 1;
    while ~feof(mfid);
        header = line;
        line = fgets(mfid);
        block = strfind(line,'<BeginTimeSerie>');
        found_ini_date = strfind(line,'SERIE_INITIAL_DATA');
        i = i+1;
        if block;
            break
        end
      
        if found_ini_date;
            delim = strfind(line,':');
            ini_date = line(delim+1:end);
            [date_vec, n_values] = strsplit(ini_date);
            year = str2num(char(date_vec(1)));
            month = str2num(char(date_vec(2)));
            day = str2num(char(date_vec(3)));
            hour = str2num(char(date_vec(4)));
            minute = str2num(char(date_vec(5)));
            second = str2num(char(date_vec(6)));
            initialdate = datenum(year, month, day, hour, minute, second);
            found_ini_date = 0;
        end
    end
    %put header into an array
    [names, n] = strsplit(header);

    %read data columns
    [data] = textscan(mfid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
    
    %close file
    fclose(mfid);
    %construcy time axis
    
    time = data{1,1}(1:end,1);
    modeldata = data{1,column}(1:end,1);
    n_instants = size(time,1);
    time = time/86400.;
    for i=1:n_instants
        time_values(i) = initialdate + time(i);
    end
    a=datenum(datestr(inidate,2));
    b=datenum(datestr(enddate,2));
    [trash, array_pos] = min(abs(time_values - a));
    [trash, array_pos1] = min(abs(time_values - b));
    time_values=time_values(array_pos:array_pos1);
    modeldata=modeldata(array_pos:array_pos1);
  end