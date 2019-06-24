#!/usr/bin/perl

die "Must run as root\n" if $< != 0; #this check weather EUSER returns greater than 0 for root, less than or = for non root user.

use Schedule::Cron::Events;
use warnings;
use strict;

&checkDeps();

my($option);
until ($option =~ /exit/ || $option =~ "4")
{
	&getMainMenu();

	SWITCH:
	{
		($option =~ /about/ || $option =~ "1") and do
		{
			&aboutMenu();
			last;
		};

		($option =~ /backup/ || $option =~ "2") and do
		{
			&backupMenu();
			last;
		};

		($option =~ /restore/ || $option =~ "3") and do
		{
			&restoreMenu();
			last;
		};

		($option =~ /help/) and do
		{
			&helpMenu();
			last;
		};

		($option =~ /exit/ || $option =~ "4") and do
		{
			system("clear");
			print "Exiting, goodbye...\n";
			sleep(2);
			last;
		};

		{
			system("clear");
			print "Invalid selection, returning to main menu...\n";
			sleep(1);
			last;
		};
	}
}

sub getMainMenu
{
	my($systemdate);
	system("clear");
	$systemdate = &fileDate();
	print "The date is $systemdate\n";

	&stars();

	print "\nWelcome to Time Capsule!\n\n";
	print "If this is your first time using this program, please type ‘help’ to get more info.\nIf you have questions about how each option works and extra information, select ‘About’.\n\n";

	&stars();


	print "\nThis program is to be used to backup / restore files.\nPlease select one of the following options:\n\n";

	print "1. About\n";
	print "2. Backup\n";
	print "3. Restore\n";
	print "4. Exit\n";

	print "\nSelect an option: ";
	$option = <STDIN>;
	$option =~tr/A-Z/a-z/;
}

#**********************************************************EXTRAS******************************************************************

#Advanced information menu: Credits, disclaimers, detailed explanations
sub aboutMenu
{
	my($about);
	system("clear");
	print "Showing about...\n";
	sleep(1);

	print "This program was created by Jordan Galloway and Ethan Poitras.\n\n";
	print "Disclaim blurp.\n\n";

	&stars();

	print "\nManual backup: Specify the directory or file you would like to save. Time Capsule will then zip the file and place it into the backup folder that you can copy onto a usb or drive. When dealing with directories, Time Capsule will zip the folder and all of it contains.\n\n";
	print "Automated backup: Specify the directory of file you would like to be saved, then specify how often you would like Time Capsule to backup that file or folder. The frequency will be saved into a Crontab scheduler. To disable this option, select back into the automated backup and select 'Disable automated backup'.\n\n";
	print "Advanced automated backup: This option is the same as automated backup, but only backs up folders or files that have been modified since last backup. This is faster than regular backup.\n\n";

	print "Restore: Select the time you would like to restore to, and Time Capsule will restore missing or modified files.\n ***BE CAREFUL*** Restoring will overwrite already existing files. Please make sure any files you would like to be saved have been backed up or moved. You will be prompted which files you would like to overwrite.\n\n";

	&stars();

	print "\nHit enter to exit";
	$about = <STDIN>; #Acts as a pause with interactive quit.
	#$about =~tr/A-Z/a-z/;
}

#Information menu that can be accessed anywhere in the program
sub helpMenu
{
	my($help);
	system("clear");
	print "Showing help...\n";
	sleep(1);

	&stars();

	print "\nTo use this program, select backup. In the backup menu, select either a manual backup or automated backup.\n\n";

	print "Manual backups allow you to backup a specific file or folder(s) and store into a backup folder. The backup folder is located at in the system root directory.\n\n";

	print "Automated backups allow you to backup a specific file or folder(s) and specify the time and frequency of these backups. You can enable and disable this feature in the automated backup menu\n\n";

	print "Advanced backups only backs up any files or folders that have been changed.\n\n";

	print "Restore any files or folders you have backed up by going into the restore menu. This menu will display all instances of when your files have been backed up. Manual and automated backups are stored in their respective folders.\n\n";

	print "For more indepth explanations, visit the about menu\n\n";

	&stars();
	print "\nHit enter to exit";
	$help = <STDIN>; #Acts as a pause
	#$help =~tr/A-Z/a-z/;
}

#********************************************************BACKUPMENU**************************************************************

#Backups menu that gives the users the ability to choose manual or set up an automated backup schedule
sub backupMenu
{
	my($backup);
	until ($backup =~/exit/ || $backup =~ "3")
	{
		system("clear");
		print "Showing backup menu...\n";
		sleep(1);
		system("clear");
		&stars();
		print "\nThis is the backup menu, type 'help' for more info.\n";
		print "Please select one of the following backup options:\n\n";
		print "1. Manual\n";
		if (-e "/backups/automated/ENABLEDBAS" || -e "/backups/automated/ENABLEDADV")
		{
			print "2. Automated (Enabled: [X])\n";
		}
		else
		{
			print "2. Automated (Enabled: [])\n"
		}
		print "3. Exit\n\n";
		&stars();
		print "\nSelect an option: ";
		$backup = <STDIN>;
		$backup =~tr/A-Z/a-z/;

		SWITCH:
		{
			($backup =~ /help/) and do
			{
				&helpMenu();
				last;
			};

			($backup =~ /manual/|| $backup =~ "1") and do
			{
				&manualBackup();
				last;
			};

			($backup =~ /automated/ || $backup =~ "2") and do
			{
				&automatedMenu();
				last;
			};

			($backup =~ /exit/ || $backup =~ "3") and do
			{
				last;
			};

			{
				print "Invalid Selection\n";
				sleep(1);
				last;
			};
		}
	}
	
	$backup = undef; #Always sets the $backup scalar to NULL so that the menu does not think it has aready received input. Very important!
}

#User will enter a path that will be backed up into the /backup/manual folder as the date backed upeded
sub manualBackup
{
		my($path, $filename);
		system("clear");
		print "Showing Manual backup menu...\n\n";
		sleep(1);

		&stars();

		print "\nThis is the manual backup menu.\n\n";
		print "Please specify the path to the folder or file you would like to backup.\nHit Enter to exit.\n";

		&stars();

		print "\n>> ";
		chomp($path=<STDIN>);
		if (-d $path)
        {
			print "Exists\n";
      			$filename = &fileDate();
			system("zip -r /backups/manual/$filename.zip $path");
			print "\nBackup of $path complete!\n";
			sleep(3);
		}

		else
		{
			system("clear");
			print "File or folder does not exist...\n";
			sleep(2);
		}
}

#Automated backup menu that the user will choose to enable automated or advanced automated backups. Once enabled, the program will show the option has been enabled.
sub automatedMenu
{
	my($automated);
	until ($automated =~ /exit/ || $automated =~"5")
	{
		system("clear");
		print "Showing Automated backup menu...\n";
		sleep(1);
		&stars();
		print "\nRegular is a normal automated backup, advanced allows you to only files with changes since last zip.\n Type 'help' if you seek further clarification.\n";
		print "Select one of the options:\n\n";
                if (-e "/backups/automated/ENABLEDBAS")
                {
                        print("1. Basic/Regular: Enabled\n");
                }
		else
		{
			print "1. Basic\n";
		}

               	if (-e "/backups/automated/ENABLEDADV")
                {
                        print("2. Advanced: Enabled\n");
                }
                else
                {
                        print("2. Advanced\n");
                } 
		print "3. Delete Regular Automated(delreg or number)\n";
		print "4. Delete Advanced Automated(deladv or number)\n";
		print "5. Exit\n";
		&stars();
		print "\nSelection: ";
		chomp ($automated = <STDIN>);
		$automated =~tr/A-Z/a-z/;

		SWITCH:
		{
			($automated =~ /help/) and do
			{
				&helpMenu();
				last;
			};

			($automated =~ /basic/ || $automated =~ "1") and do
			{
				&automated();
				last;
			};

			($automated =~ /advanced/ || $automated =~ "2") and do
			{
				&advancedAuto();
				last;
			};
			($automated =~ /delreg/i || $automated =~ "3") and do
			{
				system("rm -r /backups/automated/ENABLEDBAS && rm -r /backups/auto.sh");
				print "Automated backup disabled!\n";
				sleep(2);
				last;
			};

			($automated =~ /delreg/i || $automated =~ "4") and do
			{
				system("rm -r /backups/automated/ENABLEDADV && rm -r /backups/auto.sh");
				print "Automated backup disabled!\n";
				sleep(2);
				last;
			};

			($automated =~ /exit/ || $automated =~ "5") and do
			{
				last;
			};

			{
				print "Invalid Selection\n";
				sleep(1);
				last;
			};
		}
	}
	
	$automated = undef; #Keep menu from breaking. very important.
}

#Creates the frequency of backups for automated
sub automated()
{
	my($abfolder, $inp, @cronv, @mon, $cronstring, $cron, $sec, $min, $hour, $day, $month, $year);
	print "\nPlease specify the path to the folder or file you would like to backup.\nHit Enter to exit.\n";

	&stars();

	print "\n>> ";
	chomp($abfolder=<STDIN>);


	if (-d $abfolder) #Check if entered folder exists
	{
		print "Path exists\n";
		sleep(1);

		&stars();
		
		
		do
		{
			print("\nNeed help learning cron? Try visiting this link to learn more: https://opensource.com/article/17/11/how-use-cron-linux");
			print ("\nPlease enter the frequency in the following order: Min(0-59), Hour:(0-23), DayofMonth(1-31), Month(1-12),DoW(0-7)\n");
			print("Enter values in one line split by space (Ex: 1 2 3 4 5): ");
			chomp($inp=<STDIN>);
			@cronv = split(/ /,$inp);
			print "\n\nCRON WILL TRIGGER:";
			system("curl -s 'https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=$cronv[0]+$cronv[1]+$cronv[2]+$cronv[3]+$cronv[4]&locale=en-US' | cut -d '\"' -f4 ");
			my @mon = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
			$cronstring = "$cronv[0] $cronv[1] $cronv[2] $cronv[3] $cronv[4] /backups/manual.sh" ; 
			my $cron = new Schedule::Cron::Events($cronstring,  Date => [ ( localtime(time()) )[0..5] ] );
			# find the next execution time
			my ($sec, $min, $hour, $day, $month, $year) = $cron->nextEvent;
			printf("Event will start next at %2d:%02d:%02d on %d %s, %d\n", $hour, $min, $sec, $day, $mon[$month], ($year+1900));
			sleep(5);
		}
		until ($cronv[0] >= 0 and $cronv[0] < 60 and $cronv[1] >=0 and $cronv[1] <=24 and $cronv[2] >=0 and $cronv[2] < 32 and $cronv[3] >=0 and $cronv[3] < 13 and $cronv[4] >= 0 and $cronv[4] < 8);
		{
			#ask again if they messed up
			push(@cronv, $abfolder);		
			#return @cronv;
			buildNewCronManual(@cronv);
			#Go to new sub to build Bash script to be used by cron.
			print "Automated backup created!\n";
			sleep(2);
		}
	}
	
	else
	{
		system("clear");
		print "File or folder does not exist...\n";
		sleep(2);
		#Leaves loop V and exits sub returning to were it was called.
	}
}

sub advancedAuto
{
	my($abfolder, $inp, @cronv, @mon, $cronstring, $cron, $sec, $min, $hour, $day, $month, $year);
	print "\nPlease specify the path to the folder or file you would like to backup.\nHit Enter to exit.\n";

	&stars();

	print "\n>> ";
	chomp($abfolder=<STDIN>);
	
	if (-d $abfolder) #Check if entered folder exists
	{
		print "Path exists\n";
		sleep(1);
		&stars();		
		do
		{
			print("\nNeed help learning cron? Try visiting this link to learn more:https://opensource.com/article/17/11/how-use-cron-linux");
			print ("\nPlease enter the frequency in the following order: Min(0-59), Hour:(0-23), DayofMonth(1-31), Month(1-12),DoW(0-7)\n");
			print("Enter values in one line split by space (Ex: 1 2 3 4 5): ");
			chomp($inp=<STDIN>);
			@cronv = split(/ /,$inp);
			print "\n\nCRON WILL TRIGGER: ";
			system("curl -s 'https://cronexpressiondescriptor.azurewebsites.net/api/descriptor/?expression=@cronv[0]+@cronv[1]+@cronv[2]+@cronv[3]+@cronv[4]&locale=en-US' | cut -d '\"' -f4 ");

			my @mon = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
			$cronstring = "@cronv[0] @cronv[1] @cronv[2] @cronv[3] @cronv[4] /backups/auto.sh" ; 
			my $cron = new Schedule::Cron::Events($cronstring,  Date => [ ( localtime(time()) )[0..5] ] );
			# find the next execution time
			my ($sec, $min, $hour, $day, $month, $year) = $cron->nextEvent;
			printf("Event will start next at %2d:%02d:%02d on %d %s, %d\n", $hour, $min, $sec, $day, $mon[$month], ($year+1900));
			sleep(5);
		} 
		until (@cronv[0] >= 0 and @cronv[0] < 60 and @cronv[1] >=0 and @cronv[1] <=24 and @cronv[2] >=0 and @cronv[2] < 32 and @cronv[3] >=0 and @cronv[3] < 13 and @cronv[4] >= 0 and @cronv[4] < 8);
		{
			push(@cronv, $abfolder);
			buildNewCronDiff(@cronv);
			print "Automated backup created!\n";
			sleep(2);
		}

		}
		else
		{
			system("clear");
			print "File or folder does not exist...\n";
			sleep(2);
			#Leaves loop V and exits sub returning to were it was called.
		}
	
}

sub buildNewCronManual()
{
	my (@cmvals);
	@cmvals = @_; #grab the values that the user entered into cron.
	#print @cmvals; #debug
	system("touch /backups/custcronbasic");
	open (CRONTAB, ">/backups/custcronbasic"); #open crontab
	print CRONTAB ("@cmvals[0] @cmvals[1] @cmvals[2] @cmvals[3] @cmvals[4] sh /backups/manual.sh\n"); #print the new cronline into crontab 
	close(CRONTAB); #close /etc/crontab

  	open(MAN, ">/backups/manual.sh"); #open the file that is to be created
  	print MAN ("TIME=\"date | sed \'s/ //g;s/://g\'\"\neval \$TIME\nzip -r /backups/automated/basic/\$(eval \$TIME).zip @cmvals[5]"); # create a bash script to perform the backup
	close(MAN);
	system("crontab /backups/custcronbasic");
  	system("touch /backups/automated/ENABLEDBAS"); #Create a file to be useda s a flag for if automated is enabled or not.
	system("rm /backups/automated/ENBALEDADV 2> /dev/null && rm /backups/manual.sh 2> /dev/null && rm /backups/custcrondiff 2> /dev/null");

}

sub buildNewCronDiff() #NOT DONE YET. NEED TO FIGURE PROPER WAY TO KEEP NAME SIMILAR
{
	my (@cdvals, $OLDZIPNAME); #same just uses Differential zip commands
	@cdvals = @_;	
	system("touch /backups/custcrondiff");
	open (CRONTAB, ">/backups/custcrondiff");
	print CRONTAB ("@cdvals[0] @cdvals[1] @cdvals[2] @cdvals[3] @cdvals[4] sh /backups/auto.sh\n");
	close(CRONTAB);
	open(AUTO,">/backups/auto.sh");	
	system("touch /backups/automated/ENABLEDADV");
	open(ORIG, ">/backups/orig.sh");
	print ORIG ("TIME=\"date | sed \'s/ //g;s/://g\'\"\neval \$TIME\nzip -r /backups/automated/diff/\$(eval \$TIME).zip @cdvals[5]\n eval \$TIME > /backups/automated/ENABLEDADV"); #create a file to create an initial backup of the folder
	system("sh /backups/orig.sh"); # run the file to create initial zip and save time to ENABLEDADV for reference by differential
	open(OLDZIP, "/backups/automated/ENABLEDADV");
	chomp($OLDZIPNAME=<OLDZIP>);
	print AUTO ("PREFIX=\"MODIFIED-$OLDZIPNAME\"\nzip -r /backups/automated/diff/$OLDZIPNAME @cdvals[5] -DF --out /backups/automated/diff/\$PREFIX \n echo \$PREFIX > /backups/automated/ENABLEDADV"); #print out shell code to a 
	system("crontab /backups/custcrondiff");
	close(AUTO);
	close(ORIG);
	close(OLDZIP);
	system("rm /backups/automated/ENABLEDBAS 2> /dev/null && rm /backups/auto.sh 2> /dev/null && rm /backups/custcronbasic 2> /dev/null");
}

#*****************************************************RESTOREMENU*******************************************************************

sub restoreMenu
{
	my($restore,$zipFile, $RCHOICE);
	until ($restore =~ /exit/ || $restore =~ "4")
	{
		system("clear");
		print "Showing Restore menu...\n";
		sleep(1);

		&stars();
		print "\nThis is the restore menu, type 'help' for more info.\n";
		print "Select which folder to display:\n\n";
		print "1. Manual\n";
		print "2. Automated\n";
		print "3. Remove a folder (rm)\n";
		print "4. Exit\n";
		&stars();
		print "\nSelection: ";
		$restore = <STDIN>;
		$restore =~tr/A-Z/a-z/;

		SWITCH:
		{
			($restore =~ /manual/ || $restore =~ "1") and do
			{
				system("clear");
				print "Showing manual backups...\n";
				&stars();
				print "\n";
				system("ls /backups/manual/");
				&stars();
				print "\nEnter to exit\n\nType complete folder name: ";
				$zipFile = <STDIN>;
				system("unzip /backups/manual/$zipFile");
				system("clear");
				print "Restore Complete";
				sleep (2);
				last;
			};

			($restore =~ /automated/ || $restore =~ "2") and do
			{
				system("clear");
				&stars();
				print "\nDifferential(1) or Automated Basic(2) Backups?\n";
				print ("> ");
				chomp($RCHOICE=<STDIN>);
				if ($RCHOICE =~ "1")
				{
					&stars();
					print "\n";
					system("ls /backups/automated/diff/");
					&stars();
					print "\nEnter to exit\n\nType complete ZIP name with .zip: ";
					chomp($zipFile=<STDIN>);
					chdir "/";
					system("unzip /backups/automated/diff/$zipFile");
					#system("clear");
					print "Restore Complete";
					sleep(2);
				}
				elsif ($RCHOICE =~ "2")
				{
					&stars();
					print "\n";

					system("ls /backups/automated/basic");
					&stars();
					print "\nEnter to exit\n\nType complete ZIP name with .zip: ";
					chomp($zipFile=<STDIN>);
					chdir "/";
					system("unzip /backups/automated/basic/$zipFile");
					#system("clear");
					print "Restore Complete";
					sleep(2);
				}
				else
				{
					print "\n";
					print ("Invalid Choice Type");
					sleep(2);
					last;
				}
				last;
			};

			($restore =~ /help/) and do
			{
				&help();
				last;
			};
			
			($restore =~ /rm/ || $restore =~ "3") and do
			{
				&removeBackup();
				last;
			};
	
			($restore =~ /exit/ || $restore =~ "4") and do
			{
				last;
			};

			{
				print "Invalid selection\n";
				sleep(1);
				last;
			};
		}
	}
	
	$restore = undef; #fixes menu
}

#Checks and creates the backup folders recursively, and checks if all the necessary files have been installed.
sub checkDeps()
{
        system("clear");
        if (-d "/backups/manual/" && -d "/backups/automated/") #-d, if directory exists
        {
                print "Backup folder exists. Continuing.\n";
                sleep(1);
        }
        else
        {
                print "Backup folder does not exist. Creating...\n";
                sleep(2);
                system("mkdir -p /backups/manual/"); #create recursively
                system("mkdir -p /backups/automated/"); #create recursively
		system("mkdir -p /backups/automated/diff/");
		system("mkdir -p /backups/automated/basic/");
        }
        #system(clear);
	#if (-e "/usr/bin/cpanm") #-e, if file exists
	#{
      	#	print "Dependencies Met\n";
        #	sleep(1);
	#}
	#else
	#{
        	#print "Missing dependancies... Installing.";
		#system("apt-get install cpanminus make curl --allow");
          	#system("cpanm Schedule::Cron::Events --installdeps --force");
        	#system("apt-get update | apt-get install -yqq zip unzip --reinstall --force-yes"); #apt-get with auto YES and supress output that is not errors
	#}

}

#Gets the current date and makes it the zipfile name
sub fileDate
{
	my (@timeArray) = localtime(time); #Assigns local time to an array
	my ($timeArray,$year,$month,$day,$hour,$minute,$zipName); #Splits the times into respective scalars

	$year = $timeArray[5] + 1900; #Add 1900 because year is printed -1900
	$month = $timeArray[4] + 1; #Months are 0-11 so add 1 to give human format
	$day = $timeArray[3];
	$hour = $timeArray[2];
	$minute = $timeArray[1];

	$zipName = sprintf ("%4d-%02d-%02d-%02d:%02d", $year,$month,$day,$hour,$minute); #sprintf is the same as printf but keeps format for the scalar
	#$systemdate = sprintf("%02d-%02d-%4d", $day, $month, $year);
	return $zipName;
}

#Prints stars
sub stars
{
	my($stars);
	for ($stars = 0; $stars < 60; $stars++)
	{
		print "*";
		system ("sleep 0.0015");
	}
}

#After cron input, checks next cron event
#sub predictCronEvent()
#{
#	$cronE1 = new Schedule::Cron::Events(" $cm $ch $cdm $md $cdw ", Seconds => time() );
#	#my ($sec, $min, $hour, $day, $month, $year) = $cron1->nextEvent;
#	printf("\nEvent will start next at %2d:%02d:%02d on %d %s, %d\n", $hour, $min, $sec, $day, $mon[$month], ($year+1900));
#}


sub removeBackup()
{
	my($zipFile);
	print "Remove a manual (man) folder or automated (autobas or autoadv) folder?\n";
	print ">> ";
	chomp($zipFile=<STDIN>);
	$zipFile =~tr/A-Z/a-z/;
	if ($zipFile =~ /manual.sh/i || $zipFile =~ /auto.sh/ || $zipFile =~ /ENABLEDADV/ || $zipFile =~ /ENABLEDBAS/)
	{
		print "\nPlease do not remove important function files\n";
		#break;
	}
	
	if ($zipFile =~ /man/)
	{
		system("ls /backups/manual/");
		print "\nEnter complete zip name\n";
		chomp($zipFile = <STDIN>);
		system("rm /backups/manual/$zipFile");
		print "\nFolder removed!\n";
		sleep(2);
	}
				
	elsif ($zipFile =~ /auto/)
	{
		system("ls /backups/automated/");
		print "\nEnter complete zip name\n";
		chomp($zipFile = <STDIN>);
		system("rm /backups/automated/$zipFile");
		print "\nFolder removed!\n";
		sleep(2);
	}
				
	else
	{
		print "Error, zip does not exist!\n";
		sleep(1);
	}
}
