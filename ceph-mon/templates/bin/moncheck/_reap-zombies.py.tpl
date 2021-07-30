#!/usr/bin/python
import re
import os
import subprocess  # nosec
import json

MON_REGEX = r"^\d: \[((v\d+:([0-9\.]*):\d+\/\d+,*)+)] mon.([^ ]*)$"
# kubctl_command = 'kubectl get pods --namespace=${NAMESPACE} -l component=mon,application=ceph -o template --template="{ {{"}}"}}range .items{{"}}"}} \\"{{"}}"}}.metadata.name{{"}}"}}\\": \\"{{"}}"}}.status.podIP{{"}}"}}\\" ,   {{"}}"}}end{{"}}"}} }"'
if int(os.getenv('K8S_HOST_NETWORK', 0)) > 0:
    kubectl_command = 'kubectl get pods --namespace=${NAMESPACE} -l component=mon,application=ceph -o template --template="{ {{"{{"}}range  \$i, \$v  := .items{{"}}"}} {{"{{"}} if \$i{{"}}"}} , {{"{{"}} end {{"}}"}} \\"{{"{{"}}\$v.spec.nodeName{{"}}"}}\\": \\"{{"{{"}}\$v.status.podIP{{"}}"}}\\" {{"{{"}}end{{"}}"}} }"'
else:
    kubectl_command = 'kubectl get pods --namespace=${NAMESPACE} -l component=mon,application=ceph -o template --template="{ {{"{{"}}range  \$i, \$v  := .items{{"}}"}} {{"{{"}} if \$i{{"}}"}} , {{"{{"}} end {{"}}"}} \\"{{"{{"}}\$v.metadata.name{{"}}"}}\\": \\"{{"{{"}}\$v.status.podIP{{"}}"}}\\" {{"{{"}}end{{"}}"}} }"'

monmap_command = "ceph --cluster=${CLUSTER} mon getmap > /tmp/monmap && monmaptool -f /tmp/monmap --print"


def extract_mons_from_monmap():
    monmap = subprocess.check_output(monmap_command, shell=True).decode('utf-8')  # nosec
    mons = {}
    for line in monmap.split("\n"):
        m = re.match(MON_REGEX, line)
        if m is not None:
            mons[m.group(4)] = m.group(3)
    return mons

def extract_mons_from_kubeapi():
    kubemap = subprocess.check_output(kubectl_command, shell=True).decode('utf-8')  # nosec
    return json.loads(kubemap)

current_mons = extract_mons_from_monmap()
expected_mons = extract_mons_from_kubeapi()

print("current mons: %s" % current_mons)
print("expected mons: %s" % expected_mons)

removed_mon = False
for mon in current_mons:
    if not mon in expected_mons:
        print("removing zombie mon %s" % mon)
        subprocess.call(["ceph", "--cluster", os.environ["NAMESPACE"], "mon", "remove", mon])  # nosec
        removed_mon = True
    elif current_mons[mon] != expected_mons[mon]: # check if for some reason the ip of the mon changed
        print("ip change detected for pod %s" % mon)
        subprocess.call(["kubectl", "--namespace", os.environ["NAMESPACE"], "delete", "pod", mon])  # nosec
        removed_mon = True
        print("deleted mon %s via the kubernetes api" % mon)


if not removed_mon:
    print("no zombie mons found ...")
