#!/usr/bin/perl
########################################################################
########################################################################
######### Hubot Validation and rebuild from @Lucas.G ###################
########################################################################

use strict;

$|=1;

############
# GLOBALS: #
############
my $botName = $ARGV[0];		# Name of the bot being installed
my $hubotMachine = undef;		# Name of the EC resource
my $backupDir = '/opt/backup';	# Dir for storing backups
my $hubotIP= undef;				# IP  address of the machine
my $found = 0; 					# Flag for a found backup file
my $botAlive = 0;			 	# 0=Not Alive | xxxx= pid of bot process
my $account = undef;			# account owner of the bot
my $hubotLog = undef;			# Home directory of account running hubot
my $hubotDir = undef;			# Directory that is expanded for hubot
my $backupFileName = undef;
my $dateString = undef;			# Will be a date signature
my $job = ();			# Setting the jobId
my $errCount = 0;		# cumulative error errCount


################
# SET RECORDS: #
################

#########
# MAIN: #
#########
CheckInput();
GetMachineInfo();
Header();
ValidateBot();
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

	my $command = "hostname -i";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
		$hubotIP = $result;
	}

	my $command = "date +\%Y-\%m-\%d 2>&1";
	my @results = `$command`;
	for my $result (@results)
	{
		chomp($result); # Remove trailing newline if any
		$dateString = $result;
	}

	$hubotDir = "/opt/hubot";
	$hubotLog = $hubotDir . "/logs/$botName" . ".log";
	$backupFileName = $botName . "." . $dateString . ".tgz";
	$account = $botName;
}
#######################################################################
#### SUB ROUTINE Header ###############################################
sub Header
{
	print "-------------------------------------------------------------------\n";
	print "This automation will validate if the bot:\[$botName\] is alive\n";
	print "Machine IP Address:\[$hubotIP\]\n";
	print "Hubot running directory:\[$hubotDir\]\n";
	print "Hubot log:\[$hubotLog\]\n";
	print "-------------------------------------------------------------------\n";
	print "\n";
}
#######################################################################
#### SUB ROUTINE Footer ###############################################
sub Footer
{
	print "\n";
	print "-------------------------------------------------------------------\n";
	print "The procedure has completed Successfully. Your bot should be alive...\n";
	print "-------------------------------------------------------------------\n";
}
#######################################################################
#### SUB ROUTINE ValidateBot ##########################################
sub ValidateBot
{
	print "-------------------------------------------------------------------\n";
	# Need to validate the directory exists
	if (-d $hubotDir)
	{
		print "Base directory:\[$hubotDir\] exists, this is good...\n";
		# Need to validate if there is a log
		if (-f "$hubotLog")
		{
			print "Log file:\[$hubotLog\] exists, this is good...\n";
			print "-------------------------------------------------------------------\n";
			# Need to see if Hubot is running, getting user and pid
			my $command = "ps -aef |grep hubot |grep $botName |grep -v grep| awk \'\{print \$1,\$2\}\'";
			my @results = `$command`;
			if (@results)
			{
				for my $result (@results)
				{
					chomp($result); # Remove trailing newline if any
					my ($owner,$pid) = split(" ",$result);
					#print "debug --- owner:\[$owner\] , pid:\[$pid\]\n";
					if ($owner eq $account)
					{
						# We found an alive process!
						$botAlive = $pid;
						print "Active pid for bot:\[$botAlive\]\n";
						ValidateLog();
					}
				}
			}
			else # No process for bot was found
			{
				$botAlive = 0;
				print "Issue: could not find an active pid on machine!\n";

				FindBackup();
			}
		}
		else # No log file for bot was found
		{
			print "No log found! this is usually a bad thing! Bailing out!\n";
			# Set IssueFound flag
 			FindBackup();
		}
	}
	else # No bot directory on machine
	{
		print "There is no hubot directory.. this is usually bad\n";
		# Set IssueFound flag
 		FindBackup();
	}

	# Need to check if any errors occured
	if ($errCount != 0 or $botAlive == 0)
	{
		print "-------------------------------------------------------------------\n";
		print "Errors were encountered or the bot was not found alive\n";
		# Set IssueFound flag
 		FindBackup();
	}
}
#######################################################################
#### SUB ROUTINE ValidateLog ##########################################
sub ValidateLog
{
	print "-------------------------------------------------------------------\n";
	print "Need to grep Hubot Log for connectivity\n";
	print "NOTE: multiple responses below indicate the bot lost connectivity but is alive.\n\n";
	# Grep to see if connection string is found
	my $command = "grep -a \"INFO Flowdock: listening to flows\" $hubotLog";
	my @results = `$command`;
	if (@results)
	{
		for my $result (@results)
		{
			chomp($result); # Remove trailing newline if any
			if ($result =~ "INFO Flowdock: listening to flows")
			{
				print "Bot seems to have connected and is listening for commands\n";
				print "Result:\[$result\]\n";
			}
			else # No success string found
			{
				print "ERROR --- It appears the bot failed on startup!\n";
				# Getting the last 20 lines of log
				my $command = "tail -20 $hubotLog";
				my @results = `$command`;
				if (@results)
				{
					for my $result (@results)
					{
						chomp($result); # Remove trailing newline if any
						print "Result:\[$result\]\n";
					}
				}
				# Bot is dead, we need to fail
				print "Bailing out!\n";
				# Set IssueFound flag
 				my $xPath  = $::gCommander->setProperty("/myJob/IssueFound", "1",{jobId => $ENV{COMMANDER_JOBID}});
				ErrorMessage($xPath,1);
				exit(1);
			}
		}
	}
}
#######################################################################
#### SUB ROUTINE FindBackup ###########################################
sub FindBackup
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
				print "backup file:\[$backupDir/$backupFileName\] for today ALREADY exists.\n";
				print "We will use this to rebuid the bot\n";
				my $fullBackupPath = "$backupDir/$backupFileName";
				RebuildBot($fullBackupPath,$backupFileName);
			}
			else
			{
				print "Checking to see if a recent backup of this bot exists...\n";
				# looking for a file with name like BotName.date.tgz
				my $command = "cd $backupDir ; ls -r |grep $botName |grep .tgz";
				my @results = `$command`;
				if (@results)
				{
					for my $result (@results)
					{
						chomp($result); # Remove trailing newline if any
						if ($found == 0)
						{
							print "Result:\[$result\]\n";
							my $fullBackupPath = $backupDir . '/' . $result;
							print "Using file:\[$fullBackupPath\] for restore\n";
							RebuildBot($fullBackupPath,$result);
							$found = 1; # Setting flag so we dont do this again
						}
					}
				}
				else
				{
					print "ERROR: No suitable backup found! Bailing out!\n";
					exit(1);
				}
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
#### SUB ROUTINE RebuildBot ###########################################
sub RebuildBot
{
	my $fullBackupPath = $_[0];
	my $backupFileName = $_[1];

	print "-------------------------------------------------------------------\n";
	print "Rebuilding Bot:\[$botName\] with file:\[$fullBackupPath\]\n";

	# Really good idea to make sure this exists before blowing it away
	if (-d $hubotDir)
	{
		# Clean dir, Pull file to location, extract tarball
		my $command = "cd $hubotDir ; rm -rf * ; cp $fullBackupPath / ; cd / ; tar xvfz $backupFileName";
		my @results = `$command`;
		if (@results)
		{
			for my $result (@results)
			{
				chomp($result); # Remove trailing newline if any
				print "Result:\[$result\]\n";
			}
		}

		# Remove the used up tar ball
		my $command = "cd / ; rm -f $backupFileName";
		my @results = `$command`;
		if (@results)
		{
			for my $result (@results)
			{
				chomp($result); # Remove trailing newline if any
				print "Result:\[$result\]\n";
			}
		}

		# Start The application
		my $command = "cd $hubotDir ; chown -R $account:$account * ; su - $account -c ./start.sh";
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
