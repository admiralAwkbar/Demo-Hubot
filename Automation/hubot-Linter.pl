#!/usr/bin/perl
########################################################################
########################################################################
######### Linter for Hubot @admiralAwkbar ##############################
########################################################################

#############
# Load Libs #
#############
use strict;

$|=1;

##################
#### GLOBALS: ####
##################
my $hubotName = $ARGV[0];        # Status of the preflight checks
my $rulesFile = "/opt/$hubotName/coffeelint.json"; # Rules for coffeelint
my $buildDir = undef;     # Current build directory
my $foundErrorCoffee = 0; # Flag for error found
my $foundErrorPython = 0; # Flag for error found
my $foundErrorPerl = 0; # Flag for error found
###############
#### MAIN: ####
###############
GetBuildDir();    # Get the current build dir
Header();         # Basic print statements
ValidateRules();  # Find the rules file
CoffeeLinter();   # Validate the coffeescript
PythonLinter();   # Validate the python scripts
PerlLinter();     # Validate the perl scripts
Footer();         # Basic footer prints

#######################################################################
#################### SUB ROUTINES BELOW ONLY ##########################
#######################################################################
#######################################################################
#### SUB ROUTINE Header ###############################################
sub Header
{
  	print "-------------------------------------------------------------------\n";
  	print "This step will lint the Hubot instance:\[$hubotName\]\n";
   print "-------------------------------------------------------------------\n";
}
#######################################################################
#### SUB ROUTINE Footer ###############################################
sub Footer
{
   my $state = 0;
   print "$foundErrorCoffee,$foundErrorPython,$foundErrorPerl\n";
   if ($foundErrorCoffee == 1)
   {
      $state = 1;
   }
   
   if($foundErrorPython == 1)
   {
      $state = 1;
   }
   
   if($foundErrorPerl == 1)
   {
      $state = 1;
   }
   
   print "-------------------------------------------------------------------\n";
   print "Step has completed with exit code: $state\n";
   exit($state);
}
#######################################################################
#### SUB ROUTINE GetBuildDir ##########################################
sub GetBuildDir
{
   my $command = "pwd 2>&1";
   my $result = `$command`;
   if ($?==0)
   {
      chomp($result);
      $buildDir = $result;
   }
   else
   {
      print "ERROR! Failed to get Build Dir!\n";
      DebugErrors();
   }
}
#######################################################################
#### SUB ROUTINE ValidateRules ########################################
sub ValidateRules
{
   if (! -f $rulesFile)
   {
      print "ERROR! No rules file found at:\[$rulesFile\]\n";
      DebugErrors();
   }
}
#######################################################################
#### SUB ROUTINE CoffeeLinter #########################################
sub CoffeeLinter
{
    print "-------------------------------------------------------------------\n";
    print "Running Coffee linter now...\n";
    # Need to find all files that end with .coffee
    my $command = "find . -type f -name \"*.coffee\" 2>&1";
    my @results = `$command`;

    if ($?==0)
    {
      foreach my $filePath (@results)
      {
         chomp($filePath);
         print "Checking file:\[$filePath\]\n";
         my $command = "coffeelint -f $rulesFile $filePath 2>&1";
         my @results = `$command`;

         if ($?!=0)
         {
            print "Found error!\n";
            $foundErrorCoffee = 1;
            foreach my $result (@results)
            {
               chomp($result);
               print "ERROR: $result\n";
            }
         }
      } 
   }
   else
   {
      # No files found in the Coffeelint
   }
}
#######################################################################
#### SUB ROUTINE PythonLinter #########################################
sub PythonLinter
{
    print "-------------------------------------------------------------------\n";
    print "Running Python linter now...\n";
    # Need to find all files that end with .coffee
    my $command = "find . -type f -name \"*.py\" 2>&1";
    my @results = `$command`;

    if ($?==0)
    {
      foreach my $filePath (@results)
      {
         chomp($filePath);
         print "Checking file:\[$filePath\]\n";
         my $command = "pylint -E $filePath 2>&1";
         my @results = `$command`;

         if ($?!=0)
         {
            $foundErrorPython = 1;
            foreach my $result (@results)
            {
               chomp($result);
               print "ERROR: $result\n";
            }
         }
      } 
   }
   else
   {
      # No files found in the Pylint
   }
}
#######################################################################
#### SUB ROUTINE PerlLinter ###########################################
sub PerlLinter
{
    print "-------------------------------------------------------------------\n";
    print "Running Perl linter now...\n";
    # Need to find all files that end with .coffee
    my $command = "find . -type f -name \"*.pl\" 2>&1";
    my @results = `$command`;

    if ($?==0)
    {
      foreach my $filePath (@results)
      {
         chomp($filePath);
         print "Checking file:\[$filePath\]\n";
         my $command = "perl -Mstrict -cw $filePath 2>&1";
         my @results = `$command`;

         if ($?!=0)
         {
            $foundErrorPerl = 1;
            foreach my $result (@results)
            {
               chomp($result);
               print "ERROR: $result\n";
            }
         }
      } 
   }
   else
   {
      # No file found in the perl linter
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
