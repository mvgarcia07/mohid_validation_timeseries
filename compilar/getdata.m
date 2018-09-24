function [nodata]=getdata(initialdate,days_before,enddate)

global property plot_data down_data stareg flag_srw station

if strcmp(property,'level')
    mfid2 = fopen('Tide_station_id.dat');
	if (mfid2 < 0)
	     mfidi = fopen('error_timeseries.dat','a');
         fprintf (mfidi,'%s\n','Tide_station_id.dat is missing');
         fclose(mfidi);
         error('Tide_station_id.dat is missing')
    end		 
elseif strcmp(property,'temperature') | strcmp(property,'salinity') | strcmp(property,'velocity')
    mfid2 = fopen('station_id.dat');
	disp('read file station')
	if (mfid2 < 0)
	     mfidi = fopen('error_timeseries.dat','a');
         fprintf (mfidi,'%s\n','station_id.dat is missing');
         fclose(mfidi);
         error('station_id.dat is missing')
    end
end
count=0;
stareg_id='0';
  
	
    while ~feof(mfid2);
             
 
	   line = fgets(mfid2);
       stationname= strfind(line,'STATION_NAME');
       stationorigin = strfind(line,'ORIGIN');
       stationregion = strfind(line,'REGION');
       downstaname = strfind(line,'DOWNSTA_NAME');
       block = strfind(line,'<EndStation>');
       if stationname
                   delim = strfind(line,':');
		           %station_name= line(delim+1:end);
	               station_na= line(delim+1:end);
		           [station, n_values] = strsplit(station_na);
				   if (n_values == 2) 
				       station=strcat(station(1),{' '},station(2));
                   elseif (n_values == 3)
                       station=strcat(station(1),{' '},station(2),{' '},station(3));
				   elseif (n_values == 4)
				       station=strcat(station(1),{' '},station(2),{' '},station(3),{' '},station(4));
				   elseif (n_values > 4) 
				       station=strcat(station(1),{' '},station(2),{' '},station(3),{' '},station(4));
                       mfidi = fopen('error_timeseries.dat','a');
                       fprintf (mfidi,'%s\n','STATION_NAME to big max 4 words ');
                   	   fclose(mfidi);
                       error('STATION_NAME to big max 4 words')					   
                   end
				   station=char(station);
       end
       if stationorigin
                   delim = strfind(line,':');
		           station_origin= line(delim+1:end);
		           [staorigin, n_values] = strsplit(station_origin);
                   staorigin=char(staorigin);
				   
				   if ((strcmp(staorigin,'Puertos') || strcmp(staorigin,'IH') || strcmp(staorigin,'MyOcean'))==0)
				       mfidi = fopen('error_timeseries.dat','a');
					   fprintf (mfidi,'%s\n',staorigin);
                       fprintf (mfidi,'%s\n','Wrong ORIGIN choose Puertos, MyOcean or IH');
					   fclose(mfidi);
					   error('Wrong ORIGIN choose Puertos, MyOcean or IH')
				   end
       end

       if stationregion
                   delim = strfind(line,':');
		           station_reg= line(delim+1:end);
		           [stareg, n_values] = strsplit(station_reg);
				   stareg_id = '1';
                 
				   if (n_values > 3)
				       mfidi = fopen('error_timeseries.dat','a');
					   fprintf (mfidi,'%s\n',stareg);
                       fprintf (mfidi,'%s\n','Wrong REGION need 3 items region stationtype datatype');
					   fclose(mfidi);
					   error('Wrong REGION need 3 items region stationtype datatype')
                   end      
       end
	   
       if downstaname
                   delim = strfind(line,':');
		           down_sta= line(delim+1:end);
		           [downsta, n_values] = strsplit(down_sta);
                   downsta=char(downsta);
				   if (n_values > 1)
                       mfidi = fopen('error_timeseries.dat','a');
					   fprintf (mfidi,'%s\n',downsta);
                       fprintf (mfidi,'%s\n','DOWNSTA_NAME too big max 1 word');
					   fclose(mfidi);
					   DOWNSTA_NAME=downsta;
					   error('DOWNSTA_NAME too big max 1 word')
                   end					   
       end
      
       if block

          if strcmp(staorigin,'MyOcean')
              if strcmp(property,'level')
                 prop='SLEV';
              elseif strcmp(property,'temperature')
                 prop='TEMP';
              elseif strcmp(property,'salinity')
                 prop='PSAL'
				
              elseif strcmp(property,'velocity')
                 prop='HCSP'; %velocity intensity
                 prop1='HCDT'; %velocity direction
              elseif strcmp(property,'wind')
                 prop='WSPD'; %wind modulo
                 prop1='WDIR'; %wind direction
              elseif strcmp(property,'air_temperature')
                 prop='AIRT'; %air temperature
              elseif strcmp(property,'atmospheric')
                 prop='ATMP'; %atmospheric pressure
              elseif strcmp(property,'wave')
                 prop='VTDH'; %wave amplitude
                 prop1='VTZA'; %wave period
                 prop2='VDIR'; %wave direction
              end   
              stan=downsta;
		  elseif strcmp(staorigin,'IH')
		  
		  
          end
          if strcmp(staorigin,'MyOcean')   
              if datenum(initialdate-days_before) > datenum(enddate)
                 mfidi = fopen('error_timeseries.dat','a');
                 fprintf (mfidi,'%s\n','Initial date greater than end date ')
	             fclose(mfidi);
				 error('Initial date greater than end date')
              end
			  
			  %if stationregion not define default IR TS MO 
			  if strcmp (stareg_id,'0') 
			      stareg={'IR';'TS';'MO'};
              end
			  count=count+1;
              day_dif=now-initialdate;
%			  if (enddate > now)
%			      enddate=now; 
%			  end
			  if (day_dif<=30)
			  
                 [gfile,nodata1]=getftp_myocean_buoys_new(stan,datestr(initialdate-days_before,'yyyymmdd'),datestr(enddate-1,'yyyymmdd'),'latest');
                 nodata(count)=nodata1;
				 %if (nodata(count)==0)
        		 % buoy_folder=[buoy_path1,station];
                 % delete('*LATEST*.nc')
				 % copyfile('*.nc',buoy_folder,'f');
			 	 % delete('*.nc');
				 % if (flag_srw==1)
				 %   copyfile('*.srw',buoy_folder,'f');
			     %   delete('*.srw');
				 % end
				% end
				
			  else 
			     [gfile,nodata1]=getftp_myocean_buoys_new(stan,datestr(initialdate-days_before,'yyyymmdd'),datestr(enddate-1,'yyyymmdd'));
				 nodata(count)=nodata1;
				 %if (nodata(count)==0)
				 %  [file_out,Mstr]=convertMyOceanBuoysToMOHIDTimeSerie_all(gfile);
				   %buoy_folder=[buoy_path1,station];
				   %copyfile('*.nc',buoy_folder,'f');
				   %delete('*.nc');
				   % if (flag_srw==1) 
				   %    copyfile('*.srw',buoy_folder,'f');
			       %    delete('*.srw');
					%end
				 %end
			  end
              
              stareg_id='0';
         end
		 end
    end  
    fclose (mfid2);