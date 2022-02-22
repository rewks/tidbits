#!/usr/bin/env python3
import subprocess
import argparse

##
# Colour codes for printing
##
class color:
   PURPLE = '\033[0;35;48m'
   CYAN = '\033[0;36;48m'
   BOLD = '\033[1;37;48m'
   BLUE = '\033[0;34;48m'
   GREEN = '\033[0;32;48m'
   YELLOW = '\033[0;33;48m'
   RED = '\033[0;31;48m'
   BLACK = '\033[0;30;48m'
   UNDERLINE = '\033[4;37;48m'
   END = '\033[0;37;0m'

##
# User objects
##
class User:
    def __init__(self, raw_user_data):
        raw_user_data = raw_user_data.decode('utf-8')

        self.username = self.getValue(raw_user_data, '\tUser Name')
        self.rid = self.getValue(raw_user_data, '\n\tuser_rid')
        self.name = self.getValue(raw_user_data, '\n\tFull Name')
        self.home_drive = self.getValue(raw_user_data, '\n\tHome Drive')
        self.dir_drive = self.getValue(raw_user_data, '\n\tDir Drive')
        self.profile_path = self.getValue(raw_user_data, '\n\tProfile Path')
        self.logon_script = self.getValue(raw_user_data, '\n\tLogon Script')
        self.description = self.getValue(raw_user_data, '\n\tDescription')
        self.workstations = self.getValue(raw_user_data, '\n\tWorkstations')
        self.comment = self.getValue(raw_user_data, '\n\tComment')
        self.remote_dial = self.getValue(raw_user_data, '\n\tRemote Dial')
        self.logon_time = self.getValue(raw_user_data, '\n\tLogon Time')
        self.logoff_time = self.getValue(raw_user_data, '\n\tLogoff Time')
        self.kickoff_time = self.getValue(raw_user_data, '\n\tKickoff Time')
        self.password_last_set = self.getValue(raw_user_data, '\n\tPassword last set Time')
        self.password_can_change = self.getValue(raw_user_data, '\n\tPassword can change Time')
        self.password_must_change = self.getValue(raw_user_data, '\n\tPassword must change Time')
        self.group_rid = self.getValue(raw_user_data, '\n\tgroup_rid')
        self.acb_info = self.getValue(raw_user_data, '\n\tacb_info')
        self.fields_present = self.getValue(raw_user_data, '\n\tfields_present')
        self.logon_divs = self.getValue(raw_user_data, '\n\tlogon_divs')
        self.bad_password_count = self.getValue(raw_user_data, '\n\tbad_password_count')
        self.logon_count = self.getValue(raw_user_data, '\n\tlogon_count')

        self.groups = []

    # Pulls the requested value out of the chunk of user data
    def getValue(self, data, attribute):
        try:
            i = data.index(attribute) + 2 # Start of attribute label (accounting for \t\n special chars)
            sov = data.index(':', i) + 1 # Start of value
            eov = data.index('\n', i) # End of value
            value = data[sov:eov].strip()
        except:
            return '' # Some kind of error parsing data for given value, return empty string
        return value

    # Adds the given group name to the list of groups the user is part of
    def addGroup(self, group_name):
        self.groups.append(group_name)

##
# Group objects consist of the group RID, Name, Description and a list of User objects who belong to that group
##
class Group:
    def __init__(self, raw_group_data, rid):
        raw_group_data = raw_group_data.decode('utf-8')

        self.group_name = self.getValue(raw_group_data, '\tGroup Name')
        self.rid = rid
        self.description = self.getValue(raw_group_data, '\n\tDescription')
        self.number_of_members = self.getValue(raw_group_data, '\n\tNum Members')

        self.members = []

    # Pulls the requested value out of the chunk of group data
    def getValue(self, data, attribute):
        try:
            i = data.index(attribute) + 2 # Start of attribute label (accounting for \t\n special chars)
            sov = data.index(':', i) + 1 # Start of value
            eov = data.index('\n', i) # End of value
            value = data[sov:eov].strip()
        except:
            return '' # Some kind of error parsing data for given value, return empty string
        return value

    # Adds the given username to the list of group members
    def addMember(self, username):
        self.members.append(username)


##
# Queries rpc for a full list of users on the domain
##
def getUserList():
    try:
        full_text = subprocess.check_output(f'rpcclient -U {USERNAME}%{PASSWORD} -c enumdomusers {TARGET_IP}'.split())
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')
    
    raw_user_list = full_text.decode('utf-8').split('\n')
    raw_user_list.pop(len(raw_user_list) - 1)

    processed_list = []

    for entry in raw_user_list:
        username_start = entry.index('[') + 1
        username_end = entry.index(']')
        rid_start = entry.index('[', username_end) + 1
        rid_end = entry.index(']', rid_start)

        user = {
                'username': entry[username_start:username_end],
                'rid': entry[rid_start:rid_end]
                }
        processed_list.append(user)

    return processed_list

##
# Takes full list of users on the domain and queries each RID. Passes the returned user object to be printed
##
def getUserDetails():
    user_list = getUserList()
    
    for user in user_list:
        rid = user['rid']
        
        try:
            raw_user_details = subprocess.check_output(['rpcclient', '-U', f'{USERNAME}%{PASSWORD}', '-c', f'queryuser {rid}', TARGET_IP])
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')

        u = User(raw_user_details)
        USER_LIST.append(u)
        printUser(u)

##
# Prints a given user object. Only prints attributes that contain data. Prints descriptions in green for awareness.
##
def printUser(user):
    user_dict = user.__dict__
    for item in user_dict:
        if user_dict[item] == '' or (item == 'groups' and not args.g):
            continue

        if item == 'username':
            print(f'{color.BOLD}{item.title()} : {user_dict[item]}{color.END}')
        elif item == 'description':
            print(f'{color.GREEN}{item.title()} : {user_dict[item]}{color.END}')
        else:
            print(f'{item.replace("_", " ").title()} : {user_dict[item]}')
    print()


##
# Queries rpc for a full list of groups on the domain
##
def getGroupList():
    try:
        full_text = subprocess.check_output(f'rpcclient -U {USERNAME}%{PASSWORD} -c enumdomgroups {TARGET_IP}'.split())
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')
    raw_group_list = full_text.decode('utf-8').split('\n')
    raw_group_list.pop(len(raw_group_list) - 1)

    processed_list = []

    for entry in raw_group_list:
        groupname_start = entry.index('[') + 1
        groupname_end = entry.index(']')
        rid_start = entry.index('[', groupname_end) + 1
        rid_end = entry.index(']', rid_start)

        group = {
                'groupname': entry[groupname_start:groupname_end],
                'rid': entry[rid_start:rid_end]
                }
        processed_list.append(group)

    return processed_list

def getGroupDetails(): 
    group_list = getGroupList()
    
    for group in group_list:
        rid = group['rid']
        
        try:
            raw_group_details = subprocess.check_output(['rpcclient', '-U', f'{USERNAME}%{PASSWORD}', '-c', f'querygroup {rid}', TARGET_IP])
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')

        g = Group(raw_group_details, rid)
        GROUP_LIST.append(g)
        if int(g.number_of_members) > 0:
            if int(g.number_of_members) <= GROUP_MEM_LIMIT:
                populateGroupMembers(g)
            printGroup(g)

##
# Takes a group object and queries the members that belong to it
##
def populateGroupMembers(group):
    try:
        full_text = subprocess.check_output(['rpcclient', '-U', f'{USERNAME}%{PASSWORD}', '-c', f'querygroupmem {group.rid}', TARGET_IP])
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')
    
    full_text = full_text.decode('utf-8').split('\n')
    if len(full_text) > 0:
        full_text.pop()
    rid_list = []

    for item in full_text:
        rid_start = item.index('[') + 1
        rid_end = item.index(']')
        rid_list.append(item[rid_start:rid_end])

    for rid in rid_list:
        u = ''
        if len(USER_LIST) > 0:
            for user in USER_LIST:
                if user.rid == rid:
                    u = user.username
                    break

        if u == '':
            usertext = subprocess.check_output(['rpcclient', '-U', f'{USERNAME}%{PASSWORD}', '-c', f'queryuser {rid}', TARGET_IP])
            usertext = usertext.decode('utf-8')
            username_start = usertext.index('\tUser Name')
            sov = usertext.index(':', username_start) + 1
            eov = usertext.index('\n', username_start)
            u = usertext[sov:eov]

        group.addMember(u.strip())



##
# Prints a given group object.
##
def printGroup(group):
    group_dict = group.__dict__
    for item in group_dict:
        if group_dict[item] == '':
            continue

        if item == 'group_name':
            print(f'{color.BOLD}{item.replace("_", " ").title()} : {group_dict[item]}{color.END}')
        elif item == 'members':
            print(f'{color.GREEN}{item.title()} : {group_dict[item]}{color.END}')
        else:
            print(f'{item.replace("_", " ").title()} : {group_dict[item]}')
    print()

##
# Gets listing of printers and prints names, descriptions and comments
##
def getPrinters():
    try:
        full_text = subprocess.check_output(f'rpcclient -U {USERNAME}%{PASSWORD} -c enumprinters {TARGET_IP}'.split())
    except subprocess.CalledProcessError as e:
        #raise RuntimeError(f'Command {e.cmd} returned with error (code {e.returncode}): {e.output}')
        print(f'{color.RED}[!]{color.END} Error occured when enumerating printers. Possibly no printers on the network')
        return
    
    raw_printer_list = full_text.decode('utf-8').replace('\t', ' ')
    raw_printer_list = raw_printer_list.replace('[', ' ')
    raw_printer_list = raw_printer_list.replace(']', '')
    raw_printer_list = raw_printer_list.split('\n')
    for item in raw_printer_list:
        try:
            if len(item) > item.index(':') + 2:
                if 'name:' in item:
                    print(color.BOLD + item.strip() + color.END)
                elif 'description:' in item:
                    print(color.GREEN + item.strip() + color.END)
                elif 'comment:' in item:
                    print(item.strip())
        except:
            continue

##
# Prints a banner informing user of what is currently being enumerated
##
def printHeader(msg):
    extra = ''
    if len(msg) % 2 > 0:
        extra = ' '
    padding = ' ' * int((60 - len(msg)) / 2)

    print(f'\n{color.BLUE}┌────────────────────────────────────────────────────────────┐{color.END}')
    print(f'{color.BLUE}│{padding}{msg}{padding}{extra}│{color.END}')
    print(f'{color.BLUE}└────────────────────────────────────────────────────────────┘{color.END}')



##
# Cmdline arg parsing
##
parser = argparse.ArgumentParser()
parser.add_argument('TARGET', help='The RPC server to connect to')
parser.add_argument('USERNAME', help='The username to authenticate as')
parser.add_argument('PASSWORD', help='The password to authenticate with')

parser.add_argument('-u', action='store_true', help='Enumerate users')
parser.add_argument('-g', action='store_true', help='Enumerate groups')
parser.add_argument('--glimit', help='Do not enumerate members for groups above this size. Default:10')
parser.add_argument('-p', action='store_true', help='Enumerate printers')
parser.add_argument('-d', action='store_true', help='Enumerate the domain')

parser.add_argument('-o', help='Output file')

args = parser.parse_args()

TARGET_IP = args.TARGET
USERNAME = args.USERNAME
PASSWORD = args.PASSWORD

USER_LIST = []
GROUP_LIST = []

if args.glimit:
    GROUP_MEM_LIMIT = int(args.glimit)
else:
    GROUP_MEM_LIMIT = 10

if args.u:
    printHeader('Enumerating user accounts')
    getUserDetails()
if args.g:
    printHeader('Enumerating groups and memberships')
    getGroupDetails()
if args.p:
    printHeader('Enumerating network printers')
    getPrinters()
