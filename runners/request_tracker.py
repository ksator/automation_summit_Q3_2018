import rt
import salt.runner

def get_rt_pillars():
    opts = salt.config.master_config('/etc/salt/master')
    runner = salt.runner.RunnerClient(opts)
    pillar = runner.cmd('pillar.show_pillar')
    return(pillar)

def connect_to_rt():
   rt_pillars=get_rt_pillars()
   uri = rt_pillars['rt']['uri']
   username = rt_pillars['rt']['username']
   password = rt_pillars['rt']['password']
   tracker = rt.Rt(uri, username, password)
   tracker.login()
   return tracker

def check_if_a_ticket_already_exist(subject, tracker):
   id=0
   for item in tracker.search(Queue='General'):
       if (item['Subject'] == subject) and (item['Status'] in ['open', 'new']):
           id=str(item['id']).split('/')[-1]
   return id

def create_ticket(subject, text):
    tracker=connect_to_rt()
    if check_if_a_ticket_already_exist(subject, tracker) == 0:
        ticket_id = tracker.create_ticket(Queue='General', Subject=subject, Text=text)
    else:
        ticket_id = check_if_a_ticket_already_exist(subject, tracker)
        update_ticket(ticket_id, text, tracker)
    tracker.logout()
    return ticket_id

def update_ticket(ticket_id, text, tracker):
    tracker.reply(ticket_id, text=text)
    return ticket_id

def change_ticket_status_to_resolved(ticket_id):
    tracker=connect_to_rt()
    tracker.edit_ticket(ticket_id, Status="Resolved")
    tracker.logout()
    return ticket_id

def attach_files_to_ticket(subject, device_directory):
    rt_pillars=get_rt_pillars()
    junos_commands = rt_pillars['collect_show_commands']
    tracker=connect_to_rt()
    ticket_id = check_if_a_ticket_already_exist(subject, tracker)
    for item in junos_commands:
        file_to_attach='/var/cache/salt/master/minions/' +  device_directory + '/files/tmp/' +  device_directory + '/' +  item['command'] + '.txt'
        tracker.comment(ticket_id, text='file "' + item['command'] + '.txt" attached to RT using SaltStack', files=[(file_to_attach, open(file_to_attach, 'rb'))])
    tracker.logout()
    return ticket_id

    
    

    
