function [gfile]=cat_myocean_buoys(varargin)

global data_path stareg

    %reference time is today
    today = datestr(date,'yyyymmdd');

    %default input values    
    fstartdate = today;
    fenddate = today;
    optargin = size(varargin,2)

    if optargin >= 1
        buoy = varargin{1};
        myoProduct(1).code = buoy;
    end

    if optargin >= 2
        fstartdate = varargin{2};
        fenddate = varargin{2}; 
    end

    if optargin >= 3
        fenddate = varargin{3}
    end
    
   % myoProduct = struct( ...
   %                     'region', { 'IR'}, ...
   %                     'ts', { 'TS'}, ...
   %                     'datatype', { 'MO'}, ...
   %                     'code', {buoy}...
   %                 );
    myoProduct = struct( ...
                        'region', { char(stareg(1))}, ...
                        'ts', { char(stareg(2))}, ...
                        'datatype', { char(stareg(3))}, ...
                        'code', {buoy}...
                    );
    
    %correct input values
    if str2double(today(1:6)) - str2double(fstartdate(1:6)) < 0 
        fstartdate = today;
    end    

    if str2double(today(1:6)) - str2double(fenddate(1:6)) < 0 
        fenddate = today;
    end
    
    %Filename
    if str2double(fenddate(1:6)) - str2double(fstartdate(1:6)) ~= 0
        gfile = constructMonthlyFile( myoProduct(1), ...
                        [fstartdate(1:6),'_',fenddate(1:6)] ...
                    );
    end

    if optargin <= 3
    %Initialize while cycle
    fdate = fstartdate(1:6);
	gfile=[buoy,'_all.nc']
    nodata=0;
	nodataf=0;
	i=1;
    %Get one file per month between start and end date
   
    while str2double(fenddate(1:6)) - str2double(fdate) >= 0        
    
        %Are we in the latest month?
        if str2double(fdate) - str2double(today(1:6)) == 0
           [file] = getFtpMyOceanLatestMonth(myoProduct(1), today);
		   allfile=[data_path,'\',file];
        else
           [file] = getFtpMyOceanMonth(myoProduct(1), fdate);
		   allfile=[data_path,'\',file];
        end


        %Do we have several months to glue?
        if str2double(fenddate(1:6)) - str2double(fstartdate(1:6)) ~= 0
          if str2double(fdate) == str2double(fstartdate(1:6))
		      if exist(allfile,'file')
			     copyfile(allfile,gfile,'f');
			  else 
			     disp(['No data for ', file])
		         mfidi = fopen('error_timeseries.dat','a');
		         fprintf (mfidi,'%s\n',['No data for ', file]);
		         fclose(mfidi);
			  end
		  else
              try
				 nc_cat(gfile,allfile,'f');
			  catch
	    		 disp('an error occoured in the nc file')
				 mfidi = fopen('error_timeseries.dat','a');
                 fprintf (mfidi,'%s\n','an error occoured in the file cat');
              	 fclose(mfidi);
              end
		  end
        else
            if exist(allfile,'file')		
			   copyfile(allfile,gfile,'f');
			else 
			     disp(['No data for ', file])
		         mfidi = fopen('error_timeseries.dat','a');
		         fprintf (mfidi,'%s\n',['No data for ', file]);
		         fclose(mfidi);
			end
        end
          fdate = nextmonth(fdate);
    end
	
	else %optargin>=4 latest
      fdate=fstartdate
	  i=1;
	  gfile=[buoy,'_all.nc']
      nodata=0;
      nodataf=0;
      while str2double(fenddate) - str2double(fdate) >= 0        
        %Are we in the latest day?
        if str2double(fenddate) - str2double(fdate) == 0
            today = datestr(date,'yyyymmdd');
            file = constructLatestFile(myoProduct(1),fenddate);
			allfile=[data_path,'\',file];
        else
            today = datestr(date,'yyyymmdd');
            file = constructLatestFile(myoProduct(1),fdate);
			allfile=[data_path,'\',file];
        end

        if exist(allfile,'file')
		     
            if (i==1 | (nodataf==1) & (nodata == 0))
			
                copyfile(allfile,gfile,'f');
				nodataf=0;
		    else
			    if (nodata == 1) 
                   return
                end
                try
				  nc_cat(gfile,allfile,'f');
				catch
				  disp('an error occoured in the nc file')
				  mfidi = fopen('error_timeseries.dat','a');
                  fprintf (mfidi,'%s\n','an error occoured in files cat');
              	  fclose(mfidi);
                end
		    end
			
        end
			
		i=i+1;
		
        if str2double(fdate(7:8))+1 > eomday(str2double(fdate(1:4)),str2double(fdate(5:6)))
        
            ndate = nextmonth(fdate);
            fdate=[ndate,'01'];
        else
            fdate =num2str(str2double(fdate)+1);
        end
         
        
      end
      try  	   
	   copyfile('*all.nc',data_path,'f')
	  catch
	    disp('no nc file')
		mfidi = fopen('error_timeseries.dat','a');
        fprintf (mfidi,'%s\n','no nc files for the period selected');
        fclose(mfidi);
	  end
    end
    
    disp('Cat nc file done.')


function [file] = getFtpMyOceanLatestMonth(myo, today)


    days = struct('day',{'01','02','03','04','05','06','07','08','09', ...
                '10','11','12','13','14','15','16','17','18','19', ...
                '20','21','22','23','24','25','26','27','28','29', ...
                '30','31'});

    fdate = today(1:6);

    file = constructMonthlyFile(myo, fdate);

    lastday = str2double(today(7:8));

    for i = 1:lastday

        fdatet = [fdate,days(i).day];
        filet = constructLatestFile(myo, fdatet);

        if exist(filet,'file')
           if i == 1
            copyfile(filet,file,'f');
           else         
             nc_cat(file,filet);
           end
        end
    end

function [file] = getFtpMyOceanMonth(myo, fdate)

    file = constructMonthlyFile(myo,fdate)	
      
%This function is required because the netcdf in the latest
%format contain one extra variable SLEV_DM that is absent
%from the monthly format. This difference doesn't allow
%the concatenation of monthly files with latest.
%This function adds the missing variable to all the monthly formatted
%netcdf files.
function adaptMonthToLatestFormat(file)

    v.Name = 'SLEV_DM';
    v.Datatype = 'char';
    v.Dimension = { 'DEPTH', 'TIME'};

    v.Attribute.Name = 'long_name';
    v.Attribute.Value = 'method of data processing';

    v.Attribute.Name = 'conventions';
    v.Attribute.Value = 'OceanSITES reference table 5';

    v.Attribute.Name = 'flag_values';
    v.Attribute.Value = 'R, P, D, M';

    v.Attribute.Name = 'flag_meanings';
    v.Attribute.Value = 'realtime post-recovery delayed-mode mixed';

    v.Attribute.Name = '_FillValue';
    v.Attribute.Value = ' ';

    nc_addvar(file,v);

function ndate = nextmonth(fdate)

    months = struct('month',{'01','02','03','04','05','06','07','08', ...
        '09','10','11','12'});

    fdate = fdate(1:6);

    fyear = str2double(fdate(1:4));

    fmonth = str2double(fdate(5:6));

    %increment month
    fmonth = fmonth + 1;

    if fmonth == 13

        fyear = fyear + 1;

        fmonth = 1;

    end

    ndate = [num2str(fyear),months(fmonth).month];

function file = constructLatestFile(myo, fdate)
    file = [myo.code,'_',fdate,'.nc'];
        
function file = constructMonthlyFile(myo, fdate)
    	 
    file = [myo.region,'_',fdate,'_',myo.ts,'_', ...
            myo.datatype,'_',myo.code,'.nc'];

function fpath = constructLatestPath(myoFtp, fdate)
    fpath = [myoFtp.path,'/latest/',fdate];
        
function fpath = constructMonthlyPath(myoFtp, myo, fdate)
    switch myo.datatype
        case 'MO'
            fpath = [myoFtp.path,'/monthly/mooring/',fdate];
            if strcmp(myoFtp.ftp, 'ftp.bsh.de')
                fpath = [myoFtp.path,'/monthly/moorings/',fdate];
            end    
        otherwise
            fpath = [myoFtp.path,'/monthly/mooring/',fdate];
    end
        