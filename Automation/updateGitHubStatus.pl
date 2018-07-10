#!/usr/bin/perl
########################################################################
########################################################################
######### Report GitHub Status @admiralAwkbar ##########################
########################################################################

#############
# Load Libs #
#############
use strict;

$|=1;

##################
#### GLOBALS: ####
##################
my $preflightStatus = $ARGV[0];        # Status of the preflight checks
my $orgRepo = $ENV{'OrgRepo'};         # Org/Repo/Branch
my ($org,$repo)=split(/\//,$orgRepo);  # Split out the variables
my $branch = $ENV{'Branch'};           # Org/Repo/Branch
my $targetUrl = $ENV{'BUILD_URL'};     # Url to build job
my $gitHubUrl = "https://api.github.com";  # GHE Url
my $sha = $ENV{'SHA'};                 # SHA sum for the branch
my $state = undef;                     # State to return to GHE
my $exitCode = undef;                  # Code to exit with
my $description = undef;               # Description of the build
my $context = "Hubot Preflight";       # Context of the build
my $githubToken = $ENV{'GITHUB_TOKEN'};      # API Read Token
my $statusUrlBase = "$gitHubUrl/repos/$org/$repo/statuses";# Url for Status

###############
#### MAIN: ####
###############
Header();               # Basic print statements
ValidateInput();        # Validate the input
ReportStatus();         # Send Message back to GHE
Footer();               # Basic footer prints

#######################################################################
#################### SUB ROUTINES BELOW ONLY ##########################
#######################################################################
#######################################################################
#### SUB ROUTINE Header ###############################################
sub Header
{
  	print "-------------------------------------------------------------------\n";
  	print "This step will send status back to GitHub\n";
   print "-------------------------------------------------------------------\n";
   print "The Org:\[$org\]\n";
   print "The Repo:\[$repo\]\n";
   print "The Branch:\[$branch\]\n";
   print "The Sha:\[$sha\]\n";
   print "The Status:\[$preflightStatus\]\n";
   print "The TargetUrl:\[$targetUrl\]\n";
  	print "-------------------------------------------------------------------\n";
}
#######################################################################
#### SUB ROUTINE Footer ###############################################
sub Footer
{
  	print "-------------------------------------------------------------------\n";
    print "Step has completed with $state\n";
    exit($exitCode);
}
#######################################################################
#### SUB ROUTINE ValidateInput ########################################
sub ValidateInput
{
    # need to have a SHA to update GHE
    if ($sha =~ m/none/i)
    {
        print "We never recieved a SHA!\n";
        print "Cannot send update\n";
        exit(1);
    }

    if (length($githubToken) < 1)
    {
      # Failed to get key from env, need to pull it
      my $command = "grep GITHUB_TOKEN /opt/hubot/hubot.env 2>&1";
      my $result = `$command`;

      if ($?!=0)
      {
         print "ERROR! failed to get Github Token!\n";
         exit(1);
      }
      else
      {
         chomp($result);
         my ($var1,$var2)=split(" ",$result,2);
         my ($trash1,$token,$trash2)=split("'",$var2,3);
         $githubToken = $token;
      }
    }
}
#######################################################################
#### SUB ROUTINE ReportStatus ########################################
sub ReportStatus
{
    #############################
    # Convert string to boolean #
    #############################
    if ($preflightStatus =~ m/success/i)
    {
        $exitCode = 0;
        $state = "success";
    }
    else
    {
        $exitCode = 1;
        $state = "failure";
    }

    #######################
    # Set the Description #
    #######################
    $description = "The build was a $state";

    print "-------------------------------------------------------------------\n";

    if (length($branch) or length($sha))
    {
        #################
        # Set StatusUrl #
        #################
        # need to append the commit hash
        my $statusUrl .= "$statusUrlBase/$sha";
        #print "DEBUG --- Status URL:\[$statusUrl\]\n";

        # Need to end api call to GHE for Success or failure
        my $command = "curl -s -X POST -H \'Authorization: token $githubToken\' -H \'Accept: application/vnd.github.v3+json\' -d \'{\"state\":\"$state\", \"target_url\":\"$targetUrl\", \"description\":\"$description\", \"context\":\"$context\"}\' $statusUrl 2>&1";
        my $cleanCommand = "curl -s -X POST -H \'Authorization: token XXXXXXXX\' -H \'Accept: application/vnd.github.v3+json\' -d \'{\"state\":\"$state\", \"target_url\":\"$targetUrl\", \"description\":\"$description\", \"context\":\"$context\"}\' $statusUrl 2>&1";

        print "Sending curl to GHE:\[$cleanCommand\]\n";
        my @results = `$command`;

        # Check the return from GHE
        if ($?!=0)
        {
            foreach my $result (@results)
            {
                print "ERROR! FAILED TO SEND DATA\n";
                chomp($result);
                print "Result:\[$result\]\n";
            }

            DebugErrors();
        }
        else
        {
            print "Successfully sent status:\[$state\] for branch:\[$branch\]\n";
        }
    }
}
#######################################################################
#### SUB ROUTINE DebugErrors ##########################################
sub DebugErrors
{
    print "###########################\n";
    print "#### DEBUG ERRORS LOOP ####\n";
    print "##### STEP HAS FAILED #####\n";
    print "#### END TRANSMISSION ####\n";
    print "###### EXITING NOW #######\n";
    print "##########################\n";

    exit(1);
}
