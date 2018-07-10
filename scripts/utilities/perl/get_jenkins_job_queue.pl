#!/usr/bin/perl
########################################################################
########################################################################
######### Monitor Jenkins Job Queue @Lucas.G ###########################
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
#### SUB ROUTINE GetCreds #############################################
sub GetCreds
{
   ###################################
   # Get the HUBOT_JENKINS_SHORT_URL #
   ###################################
   my $urlCommand = "grep HUBOT_JENKINS_SHORT_URL /opt/hubot/hubot.env 2>&1";
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
   my $userCommand = "grep HUBOT_JENKINS_AUTH_USER /opt/hubot/hubot.env 2>&1";
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
   my $passwdCommand = "grep HUBOT_JENKINS_AUTH_PASSWD /opt/hubot/hubot.env 2>&1";
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
    my $command = "curl -s $getQueueUrl 2>&1";
    #print "Running Command:\[$command\]\n";
    my $result = `$command`;

    if ($?!=0)
    {
        print "Failed to get JSON DATA";
        exit(1);
    }

    chomp($result);
    #print "Result:\[$result\]\n";

    $json = $result;
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
