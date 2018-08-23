#!/usr/bin/perl
#############################
# Run Hubot Upgrade/Install
#
# Owner: AdmiralAwkbar@github.com
#############################

use strict;

$|=1;

######################
# NOTES:
# Need to have the botname as argument to this script
# Need to Modify env var for BotName
# Chmod downloaded file
# Execute file
######################

###########
# GLOBALS #
###########
my $deployFileFullPath = undef;             # Full path to file
my $buildDir = undef;                       # Current Build dir
my $botName = $ARGV[0];                     # Name of the bot tot install/upgrade
my $buildPath = "Automation";               # Folder to find files
my $deployFileName = "deploy-hubot.sh";     # Name of the file
my $personalDeployFileName = "deploy-$botName.sh";  # personal file to run update
my $personalDeployFileFullPath = undef;             # Path to the personal file
my @debugResults = ();                              # Array of debug results
my $startSuccess = 0;                               # Flag for starting the bot

########
# MAIN #
########
CheckInput();
GetDir();
Header();
#SetPerms();
RunDeploy();
Footer();

#######################################################################
##################### SUB ROUTINES BELOW ##############################
#######################################################################
#### SUB ROUTINE Header ###############################################
sub Header
{
    print "-------------------------------------------------------------------\n";
    print "------------------------- Hubot Install ---------------------------\n";
    print "-------------------------------------------------------------------\n";
}
######################################################################
#### SUB ROUTINE Footer ###############################################
sub Footer
{
    # Need to validate if successful build
    if ($startSuccess == 1)
    {
        print "###################################\n";
        print "# Hubot was Successfully started! #\n";
        print "###################################\n";
        exit(0);
    }
    else
    {
        print "####################################\n";
        print "# Hubot was not started correctly! #\n";
        print "####################################\n";
        exit(1);
    }
}
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
    my $user = `whoami`;
    print "Running as:\[$user\]\n";
}
#######################################################################
#### SUB ROUTINE SetPerms #############################################
sub SetPerms
{
    # Setting the perms in case some ass clown messed it up...
    my $command = "sudo chown -R $botName:$botName /opt/hubot/.git 2>&1";
  	print "Running command:\[$command\]\n";
  	my $result = `$command`;

    if ($?!=0)
    {
        print "ERROR! Failed to set permissions for:\[/opt/hubot/.git\]\n";
        DebugErrors();
    }
}
#######################################################################
#### SUB ROUTINE GetDir ###############################################
sub GetDir
{
    # Need to get the current build dir for pathing
    my $command = "pwd 2>&1";
  	print "Running command:\[$command\]\n";
  	my $result = `$command`;

    if ($?==0)
    {
        chomp($result);
        #print "$result\n";
        $buildDir = $result;
    }

    # validate the file is there
    if (-f "$buildDir/$buildPath/$deployFileName")
    {
        $deployFileFullPath = "$buildDir/$buildPath/$deployFileName";
        $personalDeployFileFullPath = "$buildDir/$buildPath/$personalDeployFileName";
    }
    else
    {
        print "ERROR! could not find:\[$buildDir/$buildPath/$deployFileName\]\n";
        exit(1);
    }
}
#######################################################################
#### SUB ROUTINE RunDeploy ############################################
sub RunDeploy
{
    print "-------------------------------------------------------------------\n";

    # Need to create its own file
    print "Creating install File:\[$personalDeployFileName\] with correct parameters...\n";
    my $createInsttallCommand = "sudo cp $deployFileFullPath $personalDeployFileFullPath 2>&1";
    system($createInsttallCommand);

    if ($?!=0)
    {
        print "Failed to create custom upgrade file!\n";
        DebugErrors();
    }


    # Need to change hubot to the bots name
    print "Setting Hubot Name to:\[hubot\]\n";
    my $hubotNameCommand = "sed -i \'s/BOTNAMEVALUE/hubot/g\' $personalDeployFileFullPath 2>&1";
    my @results = `$hubotNameCommand`;
    if (@results)
    {
        for my $result (@results)
        {
            chomp($result); # Remove trailing newline if any
            push(@debugResults,$result);
            print "DEBUG --- Result:\[$result\]\n";
        }
    }

    # Make the file executable
    print "Need to make file executable...\n";
    my $executableCommand = "chmod +x $personalDeployFileFullPath 2>&1";
    my @results = `$executableCommand`;
    if (@results)
    {
        for my $result (@results)
        {
            chomp($result); # Remove trailing newline if any
            push(@debugResults,$result);
            print "DEBUG --- Result:\[$result\]\n";
        }
    }

    # Ruin the upgrade script
    print "Running Master Install / Upgrade script...\n";
    print "-------------------------------------------------------------------\n";
    print "-------------------------------------------------------------------\n";
    print "-------------------------------------------------------------------\n";
    print "-------------------------------------------------------------------\n";
    my $masterCommand = "sudo bash -c \"$personalDeployFileFullPath\" 2>&1";
    system($masterCommand);

    if ($?==0)
    {
        $startSuccess = 1;
    }
}
#######################################################################
#### SUB ROUTINE DebugErrors ##########################################
sub DebugErrors
{
    print "###########################\n";
    print "#### DEBUG ERRORS LOOP ####\n";
    print "###########################\n";
	foreach my $result (@debugResults)
    {
      print "DEBUG-ERRORS:\[$result\]\n";
    }
	print "##########################\n";
    print "#### END TRANSMISSION ####\n";
  	print "####    EXITING NOW   ####\n";
    print "##########################\n";

    exit(1);
}
