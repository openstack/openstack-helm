#!/var/lib/openstack/bin/python3

from keystone.server.wsgi import initialize_public_application

application = initialize_public_application()
