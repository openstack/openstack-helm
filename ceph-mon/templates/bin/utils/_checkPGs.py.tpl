#!/usr/bin/python

import subprocess  # nosec
import json
import sys
from argparse import *

class cephCRUSH():
    """
    Currently, this script is coded to work with the ceph clusters that have
    these type-ids -- osd, host, rack, root.  To add other type_ids to the
    CRUSH map, this script needs enhancements to include the new type_ids.

    type_id name
    ------- ----
          0 osd
          1 host
          2 chassis
          3 rack
          4 row
          5 pdu
          6 pod
          7 room
          8 datacenter
          9 region
         10 root

    Ceph organizes the CRUSH map in hierarchical topology.  At the top, it is
    the root.  The next levels are racks, hosts, and OSDs, respectively.  The
    OSDs are at the leaf level.  This script looks at OSDs in each placement
    group of a ceph pool.  For each OSD, starting from the OSD leaf level, this
    script traverses up to the root.  Along the way, the host and rack are
    recorded and then verified to make sure the paths to the root are in
    separate failure domains.  This script reports the offending PGs to stdout.
    """

    """
    This list stores the ceph crush hierarchy retrieved from the
    ceph osd crush tree -f json-pretty
    """
    crushHierarchy = []

    """
    Failure Domains - currently our crush map uses these type IDs - osd,
    host, rack, root
    If we need to add chassis type (or other types) later on, add the
    type to the if statement in the crushFD construction section.

    crushFD[0] = {'id': -2, 'name': 'host1', 'type': 'host'}
    crushFD[23] = {'id': -5, 'name': 'host2', 'type': 'host'}
    crushFD[68] = {'id': -7, 'name': 'host3', 'type': 'host'}
    rack_FD[-2] = {'id': -9, 'name': 'rack1', 'type': 'rack' }
    rack_FD[-15] = {'id': -17, 'name': 'rack2', 'type': 'rack' }
    root_FD[-17] = {'id': -1, 'name': 'default', 'type': 'root' }}
    root_FD[-9] = {'id': -1, 'name': 'default', 'type': 'root' }}
    """
    crushFD = {}

    def __init__(self, poolName):
        if 'all' in poolName or 'All' in poolName:
            try:
                poolLs = 'ceph osd pool ls -f json-pretty'
                poolstr = subprocess.check_output(poolLs, shell=True)  # nosec
                self.listPoolName = json.loads(poolstr)
            except subprocess.CalledProcessError as e:
                print('{}'.format(e))
                """Unable to get all pools - cannot proceed"""
                sys.exit(2)
        else:
            self.listPoolName = poolName

        try:
            """Retrieve the crush hierarchies"""
            crushTree = "ceph osd crush tree -f json-pretty | jq .nodes"
            chstr = subprocess.check_output(crushTree, shell=True)  # nosec
            self.crushHierarchy = json.loads(chstr)
        except subprocess.CalledProcessError as e:
            print('{}'.format(e))
            """Unable to get crush hierarchy - cannot proceed"""
            sys.exit(2)

        """
        Number of racks configured in the ceph cluster.  The racks that are
        present in the crush hierarchy may not be used.  The un-used rack
        would not show up in the crushFD.
        """
        self.count_racks = 0

        """depth level - 3 is OSD, 2 is host, 1 is rack, 0 is root"""
        self.osd_depth = 0
        """Construct the Failure Domains - OSD -> Host -> Rack -> Root"""
        for chitem in self.crushHierarchy:
            if chitem['type'] == 'host' or \
               chitem['type'] == 'rack' or \
               chitem['type'] == 'root':
                for child in chitem['children']:
                    self.crushFD[child] = {'id': chitem['id'], 'name': chitem['name'], 'type': chitem['type']}
                if chitem['type'] == 'rack' and len(chitem['children']) > 0:
                    self.count_racks += 1
            elif chitem['type'] == 'osd':
                if self.osd_depth == 0:
                    self.osd_depth = chitem['depth']

        """[ { 'pg-name' : [osd.1, osd.2, osd.3] } ... ]"""
        self.poolPGs = []
        """Replica of the pool.  Initialize to 0."""
        self.poolSize = 0

    def isSupportedRelease(self):
        cephMajorVer = int(subprocess.check_output("ceph mon versions | awk '/version/{print $3}' | cut -d. -f1", shell=True))  # nosec
        return cephMajorVer >= 14

    def getPoolSize(self, poolName):
        """
        size (number of replica) is an attribute of a pool
        { "pool": "rbd", "pool_id": 1, "size": 3 }
        """
        pSize = {}
        """Get the size attribute of the poolName"""
        try:
            poolGet = 'ceph osd pool get ' + poolName + ' size -f json-pretty'
            szstr = subprocess.check_output(poolGet, shell=True)  # nosec
            pSize = json.loads(szstr)
            self.poolSize = pSize['size']
        except subprocess.CalledProcessError as e:
            print('{}'.format(e))
            self.poolSize = 0
            """Continue on"""
        return

    def checkPGs(self, poolName):
        poolPGs = self.poolPGs['pg_stats'] if self.isSupportedRelease() else self.poolPGs
        if not poolPGs:
            return
        print('Checking PGs in pool {} ...'.format(poolName)),
        badPGs = False
        for pg in poolPGs:
            osdUp = pg['up']
            """
            Construct the OSD path from the leaf to the root.  If the
            replica is set to 3 and there are 3 racks.  Each OSD has its
            own rack (failure domain).   If more than one OSD has the
            same rack, this is a violation.  If the number of rack is
            one, then we need to make sure the hosts for the three OSDs
            are different.
            """
            check_FD = {}
            checkFailed = False
            for osd in osdUp:
                traverseID = osd
                """Start the level with 1 to include the OSD leaf"""
                traverseLevel = 1
                while (self.crushFD[traverseID]['type'] != 'root'):
                    crushType = self.crushFD[traverseID]['type']
                    crushName = self.crushFD[traverseID]['name']
                    if crushType in check_FD:
                        check_FD[crushType].append(crushName)
                    else:
                        check_FD[crushType] = [crushName]
                    """traverse up (to the root) one level"""
                    traverseID = self.crushFD[traverseID]['id']
                    traverseLevel += 1
                if not (traverseLevel == self.osd_depth):
                    raise Exception("OSD depth mismatch")
            """
            check_FD should have
            {
             'host': ['host1', 'host2', 'host3', 'host4'],
             'rack': ['rack1', 'rack2', 'rack3']
            }
            Not checking for the 'root' as there is only one root.
            """
            for ktype in check_FD:
                kvalue = check_FD[ktype]
                if ktype == 'host':
                    """
                    At the host level, every OSD should come from different
                    host.  It is a violation if duplicate hosts are found.
                    """
                    if len(kvalue) != len(set(kvalue)):
                        if not badPGs:
                            print('Failed')
                        badPGs = True
                        print('OSDs {} in PG {} failed check in host {}'.format(pg['up'], pg['pgid'], kvalue))
                elif ktype == 'rack':
                    if len(kvalue) == len(set(kvalue)):
                        continue
                    else:
                        """
                        There are duplicate racks.  This could be due to
                        situation like pool's size is 3 and there are only
                        two racks (or one rack).  OSDs should come from
                        different hosts as verified in the 'host' section.
                        """
                        if self.count_racks == len(set(kvalue)):
                            continue
                        elif self.count_racks > len(set(kvalue)):
                            """Not all the racks were used to allocate OSDs"""
                            if not badPGs:
                                print('Failed')
                            badPGs = True
                            print('OSDs {} in PG {} failed check in rack {}'.format(pg['up'], pg['pgid'], kvalue))
            check_FD.clear()
        if not badPGs:
            print('Passed')
        return

    def checkPoolPGs(self):
        for pool in self.listPoolName:
            self.getPoolSize(pool)
            if self.poolSize == 1:
                """No need to check pool with the size set to 1 copy"""
                print('Checking PGs in pool {} ... {}'.format(pool, 'Skipped'))
                continue
            elif self.poolSize == 0:
                print('Pool {} was not found.'.format(pool))
                continue
            if not self.poolSize > 1:
                raise Exception("Pool size was incorrectly set")

            try:
                """Get the list of PGs in the pool"""
                lsByPool = 'ceph pg ls-by-pool ' + pool + ' -f json-pretty'
                pgstr = subprocess.check_output(lsByPool, shell=True)  # nosec
                self.poolPGs = json.loads(pgstr)
                """Check that OSDs in the PG are in separate failure domains"""
                self.checkPGs(pool)
            except subprocess.CalledProcessError as e:
                print('{}'.format(e))
                """Continue to the next pool (if any)"""
        return

def Main():
    parser = ArgumentParser(description='''
Cross-check the OSDs assigned to the Placement Groups (PGs) of a ceph pool
with the CRUSH topology.  The cross-check compares the OSDs in a PG and
verifies the OSDs reside in separate failure domains.  PGs with OSDs in
the same failure domain are flagged as violation.  The offending PGs are
printed to stdout.

This CLI is executed on-demand on a ceph-mon pod.  To invoke the CLI, you
can specify one pool or list of pools to check.  The special pool name
All (or all) checks all the pools in the ceph cluster.
''',
    formatter_class=RawTextHelpFormatter)
    parser.add_argument('PoolName', type=str, nargs='+',
      help='List of pools (or All) to validate the PGs and OSDs mapping')
    args = parser.parse_args()

    if ('all' in args.PoolName or
        'All' in args.PoolName) and len(args.PoolName) > 1:
        print('You only need to give one pool with special pool All')
        sys.exit(1)

    """
    Retrieve the crush hierarchies and store it.  Cross-check the OSDs
    in each PG searching for failure domain violation.
    """
    ccm = cephCRUSH(args.PoolName)
    ccm.checkPoolPGs()

if __name__ == '__main__':
    Main()
