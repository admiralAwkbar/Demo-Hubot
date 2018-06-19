#!/usr/bin/env python
import sys,subprocess,os

#GitHub Instance and Hubot Token information needed.
HOST = os.environ['GHE_REPLICA_SSH']
PORT=os.environ['GHE_REPLICA_PORT']
HOST_P = os.environ['GHE_PRIMARY_SSH']
PORT_P=os.environ['GHE_PRIMARY_PORT']
BOT_TOKEN = os.environ['HUBOT_FLOWDOCK_API_TOKEN']

# List of commands that script runs in GHE appliance
CONFIG_FILE="/home/admin/config.txt"
DIAGNOSIS_FILE="/home/admin/diag.txt"
DISK_LOG_FILE="/home/admin/disk_usage_log.txt"
SYSTEM_INFO_FILE="/home/admin/sys_info.txt"
GHE_UPLOAD_DISK_LOG="curl -v -X POST -F 'event=file' -F 'content=@%s' https://%s@api.flowdock.com/flows/hp-org/austincorerndit/messages" %(DISK_LOG_FILE,BOT_TOKEN)
GHE_UPLOAD_CONFIG="curl -v -X POST -F 'event=file' -F 'content=@%s' https://%s@api.flowdock.com/flows/hp-org/austincorerndit/messages" %(CONFIG_FILE,BOT_TOKEN)
GHE_UPLOAD_SYSTEM_INFO="curl -v -X POST -F 'event=file' -F 'content=@%s' https://%s@api.flowdock.com/flows/hp-org/austincorerndit/messages" %(SYSTEM_INFO_FILE,BOT_TOKEN)
GHE_CONFIG_LIST="ghe-config -l > /home/admin/config.txt"
GHE_ANNOUNCE_S= "ghe-announce -s "
GHE_ANNOUNCE_U= "ghe-announce -u"
GHE_CLEAN_CACHES= "ghe-cleanup-caches"
GHE_CSV_USERS="ghe-user-csv -o -u | wc -l"
GHE_CSV_ADMINS="ghe-user-csv -o -a | wc -l"
GHE_CSV_SUSPENDED="ghe-user-csv -o -s | wc -l"
GHE_DIAGNOSTICS="ghe-diagnostics > /home/admin/diag.txt"
GHE_UPLOAD_DIAG="curl -v -X POST -F 'event=file' -F 'content=@%s' https://%s@api.flowdock.com/flows/hp-org/austincorerndit/messages" %(DIAGNOSIS_FILE,BOT_TOKEN)
GHE_CHECK_DISK= "ghe-check-disk-usage > /home/admin/disk_usage_log.txt"
GHE_LS_LOGS = "ls -al /var/log/github/*.log"
GHE_LS_ALL = "ls -al /var/log/github"
GHE_DU_VLG = "du -sh /var/log/github"
GHE_DU_VLGALL = "du -sh /var/log/github/*"
GHE_MAINTENANCE_S = "ghe-maintenance -s"
GHE_MAINTENANCE_U = "ghe-maintenance -u"
GHE_MAINTENANCE_Q = "ghe-maintenance -q"
GHE_PROMOTE="ghe-user-promote "
GHE_DEMOTE="ghe-user-demote "
GHE_REPL_STATUS= "ghe-repl-status"
GHE_SERVICE_LIST= "ghe-service-list"
GHE_SUPPORT_BUNDLE="ghe-support-bundle -u -t "
GHE_SUSPEND="ghe-user-suspend "
GHE_UNSUSPEND="ghe-user-unsuspend "
GHE_SYSTEM_INFO= "ghe-system-info > /home/admin/sys_info.txt"

# ghe_run_command: takes arguments cmd, args, verbose. Command to be ran, any possible arguments for that command, and verbose (have output printed to chat).
def ghe_run_command(cmd, args, verbose, instance):
	GHE_CMD=cmd
	if(instance == "primary"):
		if(args != ""):
			GHE_CMD= GHE_CMD + args
                ssh = subprocess.Popen(["ssh","-p",PORT_P, "admin@%s" % HOST_P, GHE_CMD],shell=False,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
                ssh.wait()
                result = ssh.stdout.readlines()
                error = ssh.stderr.readlines()
                if(verbose):
                        if result == []:
                                print_output(error)
                        else:
                                print_output(result)
	else:
		if(args != ""):
			GHE_CMD= GHE_CMD + args
		ssh = subprocess.Popen(["ssh","-p",PORT, "admin@%s" % HOST, GHE_CMD],shell=False,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
		ssh.wait()
		result = ssh.stdout.readlines()
		error = ssh.stderr.readlines()
		if(verbose):
			if result == []:
				print_output(error)
			else:
				print_output(result)

#print_output: takes argument result. Prints result to the chat
def print_output(content):
	output = ""
	if content == []:
		pass
	else:
		for m in content:
			output = output + m
		print (output)

def main():
        #GHE commands that have one or more arguments
        if(2 < len(sys.argv)):
		if (sys.argv[1] == 'ghe-user-demote'):
			for i in range(len(sys.argv)):
				if 1 < i:
					ghe_run_command(GHE_DEMOTE, sys.argv[i], True,"primary")
		elif (sys.argv[1] == 'ghe-user-promote'):
		        for i in range(len(sys.argv)):
		                if 1 < i:
		                        ghe_run_command(GHE_PROMOTE, sys.argv[i], True,"primary")
		elif (sys.argv[1] == 'ghe-suspend'):
			for i in range(len(sys.argv)):
		                if 1 < i:
					ghe_run_command(GHE_SUSPEND, sys.argv[i], True,"primary")
		elif (sys.argv[1] == 'ghe-unsuspend'):
		        for i in range(len(sys.argv)):
		                if 1 < i:
		                        ghe_run_command(GHE_UNSUSPEND, sys.argv[i], True,"primary")
                elif(sys.argv[1] == "ghe-announce"):
                        ghe_run_command(GHE_ANNOUNCE_S, sys.argv[2], True,"primary")
                elif(sys.argv[1] == "ghe-support"):
                        ghe_run_command(GHE_SUPPORT_BUNDLE, sys.argv[2], True,"")
		else:
		        print ("ERROR: Invalid arguments. Please see 'help ghe' on how to use this command.")
	#GHE commands that take no arguments
        elif(sys.argv[1] == "ghe-announce-rm"):
		ghe_run_command(GHE_ANNOUNCE_U, "", True,"primary")
        elif (sys.argv[1] == 'ghe-config'):
                ghe_run_command(GHE_CONFIG_LIST, "", False,"")
                ghe_run_command(GHE_UPLOAD_CONFIG, "", False,"")
        elif(sys.argv[1] == "ghe-cleanup-caches"):
                ghe_run_command(GHE_CLEAN_CACHES, "", True,"")
        elif (sys.argv[1] == 'ghe-csv-users'):
                ghe_run_command(GHE_CSV_USERS, "", True,"")
        elif (sys.argv[1] == 'ghe-csv-admins'):
                ghe_run_command(GHE_CSV_ADMINS, "", True,"")
        elif (sys.argv[1] == 'ghe-csv-suspended'):
                ghe_run_command(GHE_CSV_SUSPENDED, "", True,"")
        elif (sys.argv[1] == 'ghe-diagnostics'):
                ghe_run_command(GHE_DIAGNOSTICS, "", False,"")
                ghe_run_command(GHE_UPLOAD_DIAG, "", False,"")
        elif(sys.argv[1] == "ghe-check-disk-usage"):
                ghe_run_command(GHE_CHECK_DISK, "", False,"")
		ghe_run_command(GHE_UPLOAD_DISK_LOG, "", False,"")
        elif(sys.argv[1] == "ghe-ls-logs"):
                ghe_run_command(GHE_LS_LOGS, "", True,"")
        elif(sys.argv[1] == "ghe-ls-all"):
                ghe_run_command(GHE_LS_ALL, "", True,"")
        elif(sys.argv[1] == "ghe-du-vlg"):
                ghe_run_command(GHE_DU_VLG, "", True,"")
        elif(sys.argv[1] == "ghe-du-vlgAll"):
                ghe_run_command(GHE_DU_VLGALL, "", True,"")
        elif(sys.argv[1] == "ghe-maintenance-s"):
                ghe_run_command(GHE_MAINTENANCE_S, "", True,"")
        elif(sys.argv[1] == "ghe-maintenance-u"):
                ghe_run_command(GHE_MAINTENANCE_U, "", True,"")
        elif(sys.argv[1] == "ghe-maintenance-q"):
                ghe_run_command(GHE_MAINTENANCE_Q, "", True,"")
        elif(sys.argv[1] == "ghe-repl-status"):
                ghe_run_command(GHE_REPL_STATUS, "", True,"")
        elif(sys.argv[1] == "ghe-service-list"):
                ghe_run_command(GHE_SERVICE_LIST, "", True,"")
        elif(sys.argv[1] == "ghe-system-info"):
                ghe_run_command(GHE_SYSTEM_INFO, "", False,"")
		ghe_run_command(GHE_UPLOAD_SYSTEM_INFO, "", False,"")
		
        else:
                print ("ERROR: Invalid arguments.")


main()
