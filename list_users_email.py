
from azure.mgmt.authorization import AuthorizationManagementClient
from azure.common.client_factory import get_client_from_cli_profile

client = get_client_from_cli_profile(AuthorizationManagementClient)

subscription_id = '<get it...>'
client.config.subscription_id = subscription_id


#rv = client.permissions.li.provider_operations_metadata.list()



for ra in client.role_assignments.list():
    print('name: ', ra.name, '\tid: ', ra.id)
    print(ra.additional_properties['principalName'])


