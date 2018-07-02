from azure.graphrbac import GraphRbacManagementClient
from azure.common.client_factory import get_client_from_cli_profile



tenant = "microsoft.com"
client = get_client_from_cli_profile(   GraphRbacManagementClient,
                                        tenant_id=tenant, 
                                        base_url='https://graph.microsoft.com')

import json
f = open('./out.json','r')
r = json.loads(f.read())


def get_name(id):
    for d in r: # HACK:total hack
        if d['properties']['principalId'] == id:
            return d['properties']['principalName']
    # # rv1 = client.objects.get_objects_by_object_ids('20872be3-a702-4a51-a25e-8cac5da4e9f5')
    # # for u in rv1:
    # #     print('one')

    # rv = client.users.get('scicoria@microsoft.com')
    # return rv
# data = json.loads('./out.json')

for d in r:
    if ('properties' in d) and ('principalName' in d['properties']):
        principal_name = d['properties']['principalName']
        if 'http' not in principal_name:
            if len(principal_name) > 0:
                print(principal_name, ',')
            else:
                rbac_id = d['properties']['additionalProperties']['createdBy']
                # print('created By:', rbac_id)
                print(get_name(rbac_id),',')