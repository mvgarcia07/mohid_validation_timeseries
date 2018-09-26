
function [file_out,Mstr,Nstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(ncfile)
% this function converts one file only

extension='.ets';
%get file information
finfo=ncinfo(ncfile);



ncid = netcdf.open(ncfile,'NOWRITE');

% get the time vector 
varid = netcdf.inqVarID(ncid,'TIME');
time_value = netcdf.getVar(ncid,varid,'double');
actual_time=time_value+datenum('1-Jan-1950');
time_value_str = datestr(actual_time);
ddate = datestr(time_value_str,'yyyymmddHHMMSS');
dyear = ddate(:,1:4);
dmonth = ddate(:,5:6);
dday = ddate(:,7:8);
dhour = ddate(:,9:10);
dmin = ddate(:,11:12);
dsec = ddate(:,13:14);

%AG2018 - get depth vector
varidd = netcdf.inqVarID(ncid,'DEPH');
depth_value = netcdf.getVar(ncid,varidd,'double');
depth_vvalue=depth_value(:,1);


% initial date to be written in the output file
initial_date=cat(2,num2str(str2num(dyear(1,:))),'. ',num2str(str2num(dmonth(1,:))),...
    '. ',num2str(str2num(dday(1,:))),'. ',num2str(str2num(dhour(1,:))),...
    '. ',num2str(str2num(dmin(1,:))),'. ',num2str(str2num(dsec(1,:))),'.');

% time array:
dseconds=(time_value-time_value(1))*86400;

% output file name
output_filename=netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'id');
                                     



%variables in the file
Varnum=length(finfo.Variables);

% coordinates of the location
% warning: I see that geospatial_lon_min is the same as geospatial_lon_max
% in the files so I use only one of them, but please check that this is always true

longitude = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lon_min');
latitude = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'geospatial_lat_min');

%%Loop to get the names of the variables 
iprop=1;
disp(['getting names of the variables in ',ncfile])
for ii=1:Varnum
    %% Nuevo algorithm that guarantee we are reading all variables
    value = isavariable(finfo,ii);
    if value==1    
        props{iprop}=finfo.Variables(ii).Name;
 	    varid = netcdf.inqVarID(ncid,props{iprop});
              
              
              
              
                                               
                    
                    
                    
                      
                      
                      
                      
                                                  
              
        
        str=finfo.Variables(ii).Attributes(1).Value   ;    
        disp([str])
    %clean names from spaces, commas, slashes, and dots 
          str=strrep(str,' ','_');
          str=strrep(str,'/','_');
          str=strrep(str,'.','_');
          str=strrep(str,',','_');
          names{iprop}=str;
         iprop=iprop+1;
    end
  
end

                                   
mfidi = fopen('error_timeseries.dat','a');


for j=1:length(depth_vvalue)
% number of columns to be written, it increments if more variables are
% found in the file
col_num=1;
%MG:2018: Initializing matrix to store all time series in ascii
data=zeros(finfo.Variables(1).Dimensions.Length,length(props));
%MG:2018: find depth
        
for i=1:length(props) % start for loop over properties
  prop=char(props(i));
  
  str1 = 'good';

  % AG2018: removing this check to be able to read a file with diferent depths
  % if strcmp(prop,'DEPH') | strcmp(prop,'TIME')
%    str1='bad';
%  end	 
   try
	  ID =netcdf.inqVarID(ncid,prop);
    catch exception
      if strcmp(exception.identifier,'MATLAB:imagesci:netcdf:libraryFailure') ||...
              strcmp(exception.identifier,'MATLAB:netcdf:inqVarID:enotvar:variableNotFound') ||...
              strcmp(exception.identifier,'MATLAB:netcdf:inqVarID:variableNotFound')
         str1 = 'bad';
		 disp(['no data for ', prop,' ',ncfile])
         fprintf (mfidi,'%s\n',['No data for ', prop,' ',ncfile])
      end
              
    end  % end try
   
      if strcmp(str1,'good')   
        
		 varid = netcdf.inqVarID(ncid,prop);
		 var_value = netcdf.getVar(ncid,varid,'double');
         %AG2018:Get the variable at diferent depths
         var_value1= var_value(j,:);        
         [Mstr,Nstr]=size(var_value1);
                           
         data(:,col_num)=var_value1;
         col_num=col_num+1;	
                                
                       
                  
          
     
      end
              
           
end  % end for loop over properties


% filter values with no data
% find rows with no data and avoids that 
% they are written in the final file
indices=filtermatrix(data,9e36);
data     =data(indices==1,:);
dseconds =dseconds(indices==1,:);
dyear    =dyear(indices==1,:); 
dmonth=dmonth(indices==1,:);
dmonth=dmonth(indices==1,:);
dday=dday(indices==1,:);
dhour=dhour(indices==1,:);
dmin=dmin(indices==1,:);
dsec=dsec(indices==1,:);


names_string=char(names{1});
format_string='%12.4f %8d %4d %4d %4d %4d %11.4f %28.16e';
 for i=2:length(names)
      names_string=cat(2,names_string,'   ',char(names{i}));
      format_string=cat(2,format_string,' ','%28.16e');
 end
 format_string=cat(2,format_string,'\r\n');
 
 %AG2018 - get filename with depth
file_out=[output_filename,'_',num2str(depth_vvalue(j)),'id',extension];

 % WRITE
  
  fid = fopen( file_out, 'w');
  fprintf(fid, 'Time Serie Results File coming from MyOcean Netcdf files\r\n');
  fprintf(fid,  cat(2,'NAME          :  ',ncfile,'\r\n'));
  fprintf(fid, 'LOCALIZATION_I          :  -9999\r\n');
  fprintf(fid, 'LOCALIZATION_J          :  -9999\r\n');
  fprintf(fid, 'LOCALIZATION_K          :  -9999\r\n');
  fprintf(fid, cat(2,'SERIE_INITIAL_DATA  : ',dyear(1,:),'. ',dmonth(1,:),'. ',dday(1,:),'. ',dhour(1,:),'. ',dmin(1,:),'. ',dsec(1,:),'. ','\r\n'));
  fprintf(fid, cat(2, 'COORD_X          : ',longitude,'\r\n'));
  fprintf(fid, cat(2, 'COORD_Y          : ',latitude,'\r\n'));
  fprintf(fid, 'TIME_UNITS              : SECONDS \r\n');
  fprintf(fid, ...
        ['      Seconds   YY  MM  DD  hh  mm       ss', ...
        '                            ', names_string,'\r\n']); 
        
  
  fprintf(fid, '<BeginTimeSerie>\r\n'); 
    
for i=1:length(dsec)    
fprintf(fid, format_string, ...
                    dseconds(i), ...
                    str2double(dyear(i,:)), ...
                    str2double(dmonth(i,:)), ...
                    str2double(dday(i,:)), ...
                    str2double(dhour(i,:)), ...
                    str2double(dmin(i,:)), ...
                    str2double(dsec(i,:)), ...
                    data(i,:));
end
    



fprintf(fid, '<EndTimeSerie>\r\n');



  fclose(fid);
       
  fclose(mfidi);

        
  netcdf.close(ncid);

end
  
       
  
                                         
                                       

                                                                                                 
                                                                                                  
                                                                             
                                                                                                   
                                                                                     
                                                                                                  
                                                                                                                  
                                                                                      
                   
              
                   
             
          
  function row_indices=filtermatrix(matrix,treshold)
              
   [r,c]=size(matrix);
              for i=1:r
                  
                      if all(matrix(i,:))>treshold
                      row_indices(i)=0;
                      else
                      row_indices(i)=1;
                      end
                 
              end
   
      