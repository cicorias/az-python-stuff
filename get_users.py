from __future__ import print_function
import json
import sys

from azure.graphrbac import GraphRbacManagementClient, operations
from azure.common.client_factory import get_client_from_json_dict, get_client_from_cli_profile, get_client_from_auth_file

from msrest.paging import Paged

tenant = "microsoft.com"
client = get_client_from_cli_profile(   GraphRbacManagementClient )

auth_json = open('./auth.json','r')
auth_obj = json.loads(auth_json.read())
# TODO: BUG: need to file issue with tenant_id not loading: https://github.com/Azure/azure-sdk-for-python/blob/master/azure-common/azure/common/client_factory.py#L103
#client = get_client_from_json_dict( GraphRbacManagementClient, auth_obj)#, tenant_id=tenant)
# client = get_client_from_auth_file (    GraphRbacManagementClient, 
#                                         auth_path='./auth.json',
#                                         tenant_id=tenant)


f = open('./data/out.json','r')
r = json.loads(f.read())

all_users_emails = []


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
    
    
def get_name(id):
    #for d in r: # HACK:total hack
    #    if d['principalId'] == id:
    #        return d['principalId']
    # rv1 = client.objects.get_objects_by_object_ids(id)
    # print(type(rv1))
    # print(type(rv1.next()))
    #for u in rv1:
    #    print('one')

    try:
        rv = client.users.get(id)  #'scicoria@microsoft.com')
        eprint('rv:', rv)
        return rv
    except:
        eprint('could not get: ', id)
        return None
# data = json.loads('./out.json')


for d in r:
    user_email = None
    #print(d)
    if ('principalName' in d): # and ('principalName' in d['properties']):
        principal_name = d['principalName']
        if 'http' not in principal_name:
            if len(principal_name) > 0:
                #print(principal_name, ',')
                user_email = principal_name
            else:
                rbac_id = d['principalId'] #['additionalProperties']['createdBy']
                eprint('created By:', rbac_id)
                user_email = get_name(rbac_id)
                #print(user_email)


        if user_email != None:
            if user_email not in all_users_emails:
                all_users_emails.append(user_email)
    #else:
    #    print('nothingfor d')


for u in sorted(all_users_emails):
    print('{0};'.format(u))
