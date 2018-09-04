#!/usr/bin/perl
########################################################################
########################################################################
######### Hubot Backup from @Lucas.G ###################################
########################################################################

use strict;

$|=1;

############
# GLOBALS: #
############
my $botName = $ARGV[0];			# Name of the bot being installed
my $hubotMachine = undef;		# Name of the EC resource
my $user = undef;               # User step runs as
my $hubotIP= undef;				# IP  address of the machine
my $backupDir = '/opt/backup';	# Dir for storing backups
my $backupFileName = undef;		# Will be name of backup file created EX: BotName.Datestring.tgz
my $dateString = undef;			# Will be a date signature
my $deleteCount = 0; 			# Counter of how many backups have been deleted
my $backupThreshold = 5;		# Amount of backup files to keep in the system
my $account = undef;			# account owner of the bot
my $hubotLog = undef;			# Home directory of account running hubot
my $hubotDir = undef;			# Directory that is expanded for hubot
my $job = ();			        # Setting the jobId
my $errCount = 0;		        # cumulative error errCount


################
# SET RECORDS: #
################

#########
# MAIN: #
#########
CheckInput();
GetMachineInfo();
Header();
BackupHubot();
Footer();

#######################################################################
#################### SUB ROUTINES BELOW ONLY ##########################
#######################################################################
#### SUB ROUTINE CheckInput ###########################################
sub CheckInput
{
    my $argslen= @ARGV; # Read input from commandline
    if($argslen<=0)
    {
        print "ERROR! Need the botname as an argument to this script\n";
        exit 1;
    }
}
#######################################################################
#### SUB ROUTINE GetMachineInfo #######################################
sub GetMachineInfo
{
	# Need to get Machine HostName and IP address
	my $command = "hostname";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
		$hubotMachine = $result;
	}

	# Need to get Machine HostName and IP address
	my $command = "whoami";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
	    $user = $result;
	}

    # Getting machine IP address
	my $command = "hostname -i";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
		$hubotIP = $result;
	}

    # Getting current machine time
	my $command = "date +\%Y-\%m-\%d 2>&1";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
		$dateString = $result;
	}

	$hubotDir = "/opt/hubot";
	$hubotLog = $hubotDir . "/logs/$botName" . ".log";
	$account = $botName;
	$backupFileName = $botName . "." . $dateString . ".tgz";
}
#######################################################################
#### SUB ROUTINE Header ###############################################
sub Header
{
	print "-------------------------------------------------------------------\n";
	print "This automation will backup the Hubot:\[$botName\]\n";
	print "Machine IP Address:\[$hubotIP\]\n";
   print "Running as user:\[$user\]\n";
	print "Hubot running directory:\[$hubotDir\]\n";
	print "Hubot backup location:\[$backupDir\]\n";
	print "Hubot backup file to be created:\[$backupFileName\]\n";
	print "-------------------------------------------------------------------\n";
}
#######################################################################
#### SUB ROUTINE Footer ###############################################
sub Footer
{
	print "\n";
	print "-------------------------------------------------------------------\n";
	print "The procedure has completed Successfully. Your Hubot should be backed up...\n";
	print "-------------------------------------------------------------------\n";
}
#######################################################################
#### SUB ROUTINE BackupHubot ##########################################
sub BackupHubot
{
	print "-------------------------------------------------------------------\n";
	# Need to validate the directory exists
	if (-d $hubotDir)
	{
		print "Base directory:\[$hubotDir\] exists, this is good...\n";
		# Need to validate if backup dir exsists
		if (-d "$backupDir")
		{
			print "backup directory:\[$backupDir\] exists, this is good...\n";
			print "-------------------------------------------------------------------\n";
			# Need to see if there is already a backup file created today
			if (-f "$backupDir/$backupFileName")
			{
				print "backup file:\[$backupDir/$backupFileName\] ALREADY exists, we need to remove and recreate it.\n";
				DeleteBackup();
				CreateBackup();
				CleanBackups();
			}
			else
			{
				print "backup file:\[$backupDir/$backupFileName\] does NOT exists, we can create it.\n";
				CreateBackup();
				CleanBackups();
			}
		}
		else # No backup folder location was found
		{
			print "No backup location! this is usually a bad thing! Bailing out!\n";
			exit(1);
		}
	}
	else # No bot directory on machine
	{
		print "There is no hubot directory.. this is usually bad\n";
		exit(1);
	}

	# Need to check if any errors occured
	if ($errCount != 0)
	{
		print "-------------------------------------------------------------------\n";
		print "Errors were encountered\n";
		exit(1);
	}
}
#######################################################################
#### SUB ROUTINE DeleteBackup #########################################
sub DeleteBackup
{
	print "-------------------------------------------------------------------\n";
	print "Need to delete the backup file:\[$backupDir/$backupFileName\]\n";

	my $command = "sudo rm -f $backupDir/$backupFileName 2>&1";
	my @results = `$command`;
	if (@results)
	{
		for my $result (@results)
		{
			chomp($result); # Remove trailing newline if any
			print "Result:\[$result\]\n";
		}
	}

	if (-f "$backupDir/$backupFileName")
	{
		print "ERROR: this file should have been deleted and it didnt! bailing out!\n";
		exit(1);
	}
	else
	{
		print "Backup file was successfully removed from system\n";
	}
}
#######################################################################
#### SUB ROUTINE CreateBackup #########################################
sub CreateBackup
{
	print "-------------------------------------------------------------------\n";
	print "Creating the backup file:\[$backupDir/$backupFileName\]\n";

	my $command = "cd $hubotDir ; sudo tar cvfz $backupDir/$backupFileName $hubotDir 2>&1";
    #print " command for back is $command\n" ;
	my @results = `$command`;
	if ($?!=0)
	{
        print "Error envountered in Backup!\n";
		for my $result (@results)
		{
			chomp($result); # Remove trailing newline if any
			print "Result:\[$result\]\n";
		}
	}

    # Check if backup exists
	if (-f "$backupDir/$backupFileName")
	{
		print "Backup file was successfully created in the system\n";
		print "Setting The file perms to 777 and owner to:\[$account:$account\]\n";

		my $command = "cd $backupDir ; sudo chmod 777 $backupFileName ; sudo chown hubot:hubot $backupFileName 2>&1";
		my @results = `$command`;
		if (@results)
		{
			for my $result (@results)
			{
				chomp($result); # Remove trailing newline if any
				print "Result:\[$result\]\n";
			}
		}
	}
	else
	{
		print "ERROR: this file should have been deleted and it didnt! bailing out!\n";
		exit(1);
	}
}
#######################################################################
#### SUB ROUTINE CleanBackups #########################################
sub CleanBackups
{
	print "-------------------------------------------------------------------\n";
	print "Need to clean up the backup directory:\[$backupDir\]\n";

	# Need to find how many backup files are stored
	my $command = "cd $backupDir ; ls $botName.* |wc -l 2>&1";
	my @results = `$command`;
	if (@results)
	{
		for my $result (@results)
		{
			chomp($result); # Remove trailing newline if any
			print "Backups found:\[$result\]\n";
			# Need to see if we have too many files
			if ($result gt $backupThreshold)
			{
				my $prune = ($result - $backupThreshold); # number of files to delete
				print "Removing:\[$prune\] backup(s) from the system...\n";
				# Getting list of files in order of oldest to newest
				my $command = "cd $backupDir ; ls $botName.* 2>&1";
				my @results = `$command`;
				if (@results)
				{
					for my $result (@results)
					{
						chomp($result); # Remove trailing newline if any
						my $deadBackup = $result; # Setting the file name to be deleted
						# Check to see if we have deleted enough
						if ($deleteCount lt $prune)
						{
							#print "DEBUG --- dc:\[$deleteCount\] , prune:\[$prune\]\n";
							# Delete the backup file
							# We assume the deletion is always successful
							# No real need to check the whole proccess through
							$deleteCount++;
							print "removing file:\[$deadBackup\]\n";
							my $command = "cd $backupDir ; sudo rm -f $deadBackup 2>&1";
							my @results = `$command`;
							if (@results)
							{
								for my $result (@results)
								{
									chomp($result); # Remove trailing newline if any
									print "Result:\[$result\]\n";
								}
							}
						}
					}
				}
			}
			else
			{
				print "No need to prune backups, only \[$result\] backups present\n";
			}
		}
	}
}
