#!/usr/bin/python

import urllib2
import json
import sys
import ldap
import subprocess
import os

attrs = ['dn', 'cn', 'co', 'employeeNumber', 'employeeType', 'geBusinessGroup',\
'geBusinessGroupCode' , 'geBusinessUnit', 'geBusinessUnitAcronym', 'geJobFamily',\
'geJobFunctionCode', 'geOrganizationChart', 'gePayrollCountryCode', 'geSourceCompany',\
'geStatus', 'l', 'manager', 'ou', 'st', 'telephoneNumber', 'uid', 'ntUserDomainId', 'sn',\
'givenName', 'geSplitCompany','postalCode']

BOT_TOKEN = os.environ['HUBOT_FLOWDOCK_API_TOKEN']
FLOWUTILS_TMP_PATH = os.environ['FLOWUTILS_SERVER_PATH']
def format_row(dn, cn, co, employeeNumber, employeeType, geBusinessGroup,geBusinessGroupCode , geBusinessUnit, geBusinessUnitAcronym, geJobFamily,geJobFunctionCode, geOrganizationChart, gePayrollCountryCode, geSourceCompany,geStatus, l, manager, ou, st, telephoneNumber, uid, ntUserDomainId, sn,givenName, geSplitCompany,postalCode):
		return "1|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n" %(dn, cn, co, employeeNumber, employeeType, geBusinessGroup,geBusinessGroupCode , geBusinessUnit, geBusinessUnitAcronym, geJobFamily,geJobFunctionCode, geOrganizationChart, gePayrollCountryCode, geSourceCompany,geStatus, l, manager, ou, st, telephoneNumber, uid, ntUserDomainId, sn,givenName, geSplitCompany,postalCode)

def exec_cmd(cmd):
    try:
        r = subprocess.Popen(cmd, stderr=subprocess.STDOUT,shell=True)
        r.wait()
    except subprocess.CalledProcessError, e:
        raise ValueError(e.output)

def ldap_query(search):
	# HPE LDAP
	host = 'ldap://ldap.ge.com:389'
	base = 'ou=People,o=ge.com'
	scope = ldap.SCOPE_SUBTREE
	# Attributes requested


	l = ldap.initialize(host)
	# Try to find as "uid", if not try to search by "mail"
	r = l.search_s(base, scope, "uid="+search, attrs)
	if not r:
		r = l.search_s(base, scope, "mail="+search, attrs)
	return r



def main():
	fields = attrs
	header = "uu|dn|cn|co|employeeNumber|employeeType|geBusinessGroup|geBusinessGroupCode|geBusinessUnit|geBusinessUnitAcronym|geJobFamily|geJobFunctionCode|geOrganizationChart|gePayrollCountryCode|geSourceCompany|geStatus|l|manager|ou|st|telephoneNumber|uid|ntUserDomainId|sn|givenName|geSplitCompany|postalCode\n"
	try:
		users_file = sys.argv[1]
		thread_id = sys.argv[2]
		flow_room = sys.argv[3]
		upload_file = FLOWUTILS_TMP_PATH + "/ldap-result-%s" %(users_file)
		out = open( upload_file , 'w')
		out.write(header)

	except:
		print "Please provide the following arguments ins this order: <file_to_process.txt> <thread_id> <flow_room_name>"
		quit()

	file_name = "ldaptool-results.txt"
	with open(FLOWUTILS_TMP_PATH + "/" + users_file) as f:
		for line in f:
			user_email = line.strip()
			if "@" not in user_email:
				pass		
			else:
				start = user_email.find("@ge.com")
				if (0 < start):
					pass
				else:
					start = user_email.find("@")
					user_email = user_email.replace(str(user_email[start:]),"@ge.com")
			try:
				result = ldap_query(user_email)
			except:
				result = []
			if result:
				row = ["","","","","","","","","","","","","","","","","","","","","","","","","",""]
				i = 0
				for f in fields:
					if i == 0:
						row[i] = result[0][0]
					else:
						if fields[i] in result[0][1]:
							row[i] = result[0][1][fields[i]][0]
					i+=1

				out.write(format_row(*row) )

	out.close()
	exec_cmd("curl -v -X POST -F 'event=file' -F 'thread_id=%s' -F 'content=@%s' https://%s@api.flowdock.com/flows/ge-org/%s/messages" %(thread_id, upload_file, BOT_TOKEN, flow_room))

main()
