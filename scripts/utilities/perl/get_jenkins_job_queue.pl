#!/usr/bin/perl
########################################################################
########################################################################
######### Monitor Jenkins Job Queue @admiralawkbar #####################
########################################################################

use strict;
use JSON qw( decode_json );
use JSON qw( encode_json );
use utf8;
use Data::Dumper;

# Need to set Binary Mode
binmode STDOUT, ":utf8";

$|=1;

# Example Curl strings
# http://user:token@url/queue/api/json
# http://user:token@url/computer/api/xml?tree=computer[executors[currentExecutable[url]],oneOffExecutors[currentExecutable[url]]]&xpath=//url&wrapper=builds

############
# GLOBALS: #
############
my $hubotName = undef;              # Name of the hubot
my $user = undef;                   # Jenkins User
my $token = undef;                  # Jenkins User Token
my $jenkinsUrl = undef;             # jenkins Url
my $apiQueueUrl = "queue/api/json"; # Api Ending
my $apiBuildingUrl = "computer/api/json?tree=computer[executors[currentExecutable[url]],oneOffExecutors[currentExecutable[url]]]&xpath=//url&wrapper=builds";
my $getQueueUrl = undef;      # Full URL
my $getBuildingUrl = undef;   # Full URL
my $jobIdString = undef;      # String of job ids
my $json = undef;           	# Decoded json data
my $data = undef;           	# Will be the decoded json file
my $queueCount = 0;           # Number of jobs in queue
my $buildingCount = 0;        # Number of jobs building
my $errCount = 0;           	# Count of errors found

#########
# MAIN: #
#########
GetHubotName();     # Get the name of the hubot
GetCreds();         # Get the jenkins creds info
GetQueueJson();     # Get the json object with queue data
ParseQueueData();   # Pull out the good data
GetBuildingData();  # Get the Building XML Data
PrintData();        # Send the prints
#######################################################################
#################### SUB ROUTINES BELOW ONLY ##########################
#######################################################################
#### SUB ROUTINE PrintData ############################################
sub PrintData
{
    print "Total Building Jobs:\[$buildingCount\] Total Queued jobs:\[$queueCount\]";
    exit(0);
}
#######################################################################
#### SUB ROUTINE GetHubotName #########################################
sub GetHubotName
{
   # Need to get the hubots name from the system
   my $getUserCommand = "ps -aux |grep hubot |grep -v grep | awk \'{print \$1}\' 2>&1";
   my $result = `$getUserCommand`;

   # verify the shell came back successful
   if ($?!=0)
   {
      print "ERROR! Failed to get Hubot user!\n";
      exit(1);
   }

   # Verify the name has length
   if (length($result lt 1))
   {
      print "ERROR! Retrieved running hubot name and got:\[$result\]\n";
      exit(1);
   }

   # Set the huubots name
   chomp($result);
   $hubotName = $result;
}
#######################################################################
#### SUB ROUTINE GetCreds #############################################
sub GetCreds
{
   ######################
   # Get the Hubot Name #
   ######################
   my $getNameCommand = 'ps -aux |grep hubot |grep -v grep | awk \'{print $1}\'';
   my $result = `$getNameCommand`;

   if ($?==0)
   {
      chomp($result);
      $hubotName = $result;
   }
   else
   {
      print "ERROR! Failed to get hubot name!\n";
      exit(1);
   }
   ###################################
   # Get the HUBOT_JENKINS_SHORT_URL #
   ###################################
   my $urlCommand = "grep HUBOT_JENKINS_SHORT_URL /opt/$hubotName/hubot.env 2>&1";
   my $urlResult = `$urlCommand`;

   if ($?==0)
   {
      chomp($urlResult);
      my ($varA,$varB) = split("=",$urlResult,2);
      my ($var1,$var2,$var3) = split(/\'/,$varB,3);
      $jenkinsUrl = $var2;
   }
   else
   {
      print "ERROR! Could not find Jenkins Url!\n";
      exit(1);
   }

   ###################################
   # Get the HUBOT_JENKINS_AUTH_USER #
   ###################################
   my $userCommand = "grep HUBOT_JENKINS_AUTH_USER /opt/$hubotName/hubot.env 2>&1";
   my $userResult = `$userCommand`;

   if ($?==0)
   {
      chomp($userResult);
      my ($varA,$varB) = split("=",$userResult,2);
      my ($var1,$var2,$var3) = split(/\'/,$varB,3);
      $user = $var2;
   }
   else
   {
      print "ERROR! Could not find Jenkins User!\n";
      exit(1);
   }

   #####################################
   # Get the HUBOT_JENKINS_AUTH_PASSWD #
   #####################################
   my $passwdCommand = "grep HUBOT_JENKINS_AUTH_PASSWD /opt/$hubotName/hubot.env 2>&1";
   my $passwdResult = `$passwdCommand`;

   if ($?==0)
   {
      chomp($passwdResult);
      my ($varA,$varB) = split("=",$passwdResult,2);
      my ($var1,$var2,$var3) = split(/\'/,$varB,3);
      $token = $var2;
   }
   else
   {
      print "ERROR! Could not find Jenkins Token!\n";
      exit(1);
   }

   ########################
   # Set the long strings #
   ########################
   $getQueueUrl = "http://$user:$token\@$jenkinsUrl/$apiQueueUrl";    # Full URL
   $getBuildingUrl = "http://$user:$token\@$jenkinsUrl/$apiBuildingUrl";    # Full URL

   #print "Get Queue Url:\[$getQueueUrl\]\n";
   #print "Get Building Url:\[$getBuildingUrl\]\n";
}
#######################################################################
#### SUB ROUTINE GetQueueJson #########################################
sub GetQueueJson
{
    # Grabbing the json payload from the api endpoint
    my $jsonCommand = "curl -s $getQueueUrl 2>&1";
    #print "Running Command:\[$command\]\n";
    my $jsonResult = `$jsonCommand`;

    if ($?!=0)
    {
        print "Failed to get JSON DATA";
        exit(1);
    }

    chomp($jsonResult);
    #print "Result:\[$jsonResult\]\n";

    $json = $jsonResult;
}
######################################################################
#### SUB ROUTINE GetBuildingData #####################################
sub GetBuildingData
{
    # Grabbing the json payload from the api endpoint
    my $command = "curl -g -s $getBuildingUrl 2>&1";
    #print "Running Command:\[$command\]\n";
    my $result = `$command`;

    if ($?!=0)
    {
        print "Failed to get Building DATA";
        exit(1);
    }

    chomp($result);
    #print "Result:\[$result\]\n";
    $buildingCount = $result =~ s/$jenkinsUrl/$jenkinsUrl/g;
    if (length($buildingCount) lt 1)
    {
      $buildingCount = 0;
    }
}
#######################################################################
#### SUB ROUTINE ParseQueueData #######################################
sub ParseQueueData
{
    # Decode the data
    $data = decode_json($json);

    # Print out function of json
    #print "Function: " . $data->{'function'} . "\n";

    #print "-----------------------------------\n";
    #print "Grabbing all watched repos...\n";
    # Need to itterate through the list to get all repos
    my @items = @{ $data->{'items'} };
    foreach my $single (@items)
    {
        # Push the repo name into var
        my $id = $single->{"id"};
        $jobIdString .= ", $id";
        #print "JobId:\[$id\]\n";
		$queueCount++;
    }
}
