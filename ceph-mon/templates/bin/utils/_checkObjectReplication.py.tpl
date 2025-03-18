#!/usr/bin/python3

import subprocess  # nosec
import json
import sys
import collections

if (int(len(sys.argv)) == 1):
    print("Please provide pool name to test , example: checkObjectReplication.py  <pool name>")
    sys.exit(1)
else:
    poolName = sys.argv[1]
    cmdRep = 'ceph osd map' + ' ' + str(poolName) + ' ' +  'testreplication -f json-pretty'
    objectRep  = subprocess.check_output(cmdRep, shell=True)  # nosec
    repOut = json.loads(objectRep)
    osdNumbers = repOut['up']
    print("Test object got replicated on these osds: %s" % str(osdNumbers))

    osdHosts= []
    for osd in osdNumbers:
        cmdFind = 'ceph osd find' +  ' ' + str(osd)
        osdFind = subprocess.check_output(cmdFind , shell=True)  # nosec
        osdHost = json.loads(osdFind)
        osdHostLocation = osdHost['crush_location']
        osdHosts.append(osdHostLocation['host'])

    print("Test object got replicated on these hosts: %s" % str(osdHosts))

    print("Hosts hosting multiple copies of a placement groups are: %s" %
          str([item for item, count in collections.Counter(osdHosts).items() if count > 1]))
    sys.exit(0)
