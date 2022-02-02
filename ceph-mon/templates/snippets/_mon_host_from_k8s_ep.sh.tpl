{{- define "ceph-mon.snippets.mon_host_from_k8s_ep" -}}
{{/*

Inserts a bash function definition mon_host_from_k8s_ep() which can be used
to construct a mon_hosts value from the given namespaced endpoint.

Usage (e.g. in _script.sh.tpl):
    #!/bin/bash

    : "${NS:=ceph}"
    : "${EP:=ceph-mon-discovery}"

    {{ include "ceph-mon.snippets.mon_host_from_k8s_ep" . }}

    MON_HOST=$(mon_host_from_k8s_ep "$NS" "$EP")

    if [ -z "$MON_HOST" ]; then
        # deal with failure
    else
        sed -i -e "s/^mon_host = /mon_host = $MON_HOST/" /etc/ceph/ceph.conf
    fi
*/}}
{{`
# Construct a mon_hosts value from the given namespaced endpoint
# IP x.x.x.x with port p named "mon-msgr2" will appear as [v2:x.x.x.x/p/0]
# IP x.x.x.x with port q named "mon" will appear as [v1:x.x.x.x/q/0]
# IP x.x.x.x with ports p and q will appear as [v2:x.x.x.x/p/0,v1:x.x.x.x/q/0]
# The entries for all IPs will be joined with commas
mon_host_from_k8s_ep() {
  local ns=$1
  local ep=$2

  if [ -z "$ns" ] || [ -z "$ep" ]; then
    return 1
  fi

  # We don't want shell expansion for the go-template expression
  # shellcheck disable=SC2016
  kubectl get endpoints -n "$ns" "$ep" -o go-template='
    {{- $sep := "" }}
    {{- range $_,$s := .subsets }}
      {{- $v2port := 0 }}
      {{- $v1port := 0 }}
      {{- range $_,$port := index $s "ports" }}
        {{- if (eq $port.name "mon-msgr2") }}
          {{- $v2port = $port.port }}
        {{- else if (eq $port.name "mon") }}
          {{- $v1port = $port.port }}
        {{- end }}
      {{- end }}
      {{- range $_,$address := index $s "addresses" }}
        {{- $v2endpoint := printf "v2:%s:%d/0" $address.ip $v2port }}
        {{- $v1endpoint := printf "v1:%s:%d/0" $address.ip $v1port }}
        {{- if (and $v2port $v1port) }}
          {{- printf "%s[%s,%s]" $sep $v2endpoint $v1endpoint }}
          {{- $sep = "," }}
        {{- else if $v2port }}
          {{- printf "%s[%s]" $sep $v2endpoint }}
          {{- $sep = "," }}
        {{- else if $v1port }}
          {{- printf "%s[%s]" $sep $v1endpoint }}
          {{- $sep = "," }}
        {{- end }}
      {{- end }}
    {{- end }}'
}
`}}
{{- end -}}
