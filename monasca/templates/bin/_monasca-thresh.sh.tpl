#!/bin/bash
# shellcheck shell=dash

if [ -n "$DEBUG" ]; then
  set -x
fi

function parse_db_url {
  # extract the protocol
  DATABASE_URL=$1
  proto="`echo $DATABASE_URL | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
  url=`echo $DATABASE_URL | sed -e s,$proto,,g`
  userpass="`echo $url | grep @ | cut -d@ -f1`"
  pass=`echo $userpass | grep : | cut -d: -f2`
  if [ -n "$pass" ]; then
      user=`echo $userpass | grep : | cut -d: -f1`
  else
      user=$userpass
  fi
  hostport=`echo $url | sed -e s,$userpass@,,g | cut -d/ -f1`
  port=`echo $hostport | grep : | cut -d: -f2`
  if [ -n "$port" ]; then
      host=`echo $hostport | grep : | cut -d: -f1`
  else
      host=$hostport
  fi
  path="`echo $url | grep / | cut -d/ -f2-`"

  echo $host $port $user $pass $path
}

CONFIG_TEMPLATES="/templates"
CONFIG_DEST="/etc/monasca"
LOG_TEMPLATES="/logging"
LOG_DEST="/storm/log4j2"
APACHE_STORM_DIR="/apache-storm-1.2.3"

ZOOKEEPER_WAIT=${ZOOKEEPER_WAIT:-"true"}
ZOOKEEPER_WAIT_TIMEOUT=${ZOOKEEPER_WAIT_TIMEOUT:-"3"}
ZOOKEEPER_WAIT_DELAY=${ZOOKEEPER_WAIT_DELAY:-"10"}
ZOOKEEPER_WAIT_RETRIES=${ZOOKEEPER_WAIT_RETRIES:-"20"}

SUPERVISOR_STACK_SIZE=${SUPERVISOR_STACK_SIZE:-"1024k"}
WORKER_STACK_SIZE=${WORKER_STACK_SIZE:-"1024k"}
NIMBUS_STACK_SIZE=${NIMBUS_STACK_SIZE:-"1024k"}
UI_STACK_SIZE=${UI_STACK_SIZE:-"1024k"}

TOPOLOGY_NAME="thresh-cluster"

MYSQL_WAIT_RETRIES=${MYSQL_WAIT_RETRIES:-"24"}
MYSQL_WAIT_DELAY=${MYSQL_WAIT_DELAY:-"5"}

KAFKA_WAIT_RETRIES=${KAFKA_WAIT_RETRIES:-"24"}
KAFKA_WAIT_DELAY=${KAFKA_WAIT_DELAY:-"5"}

THRESH_STACK_SIZE=${THRESH_STACK_SIZE:-"1024k"}

first_zk={{ first (index .Values.conf.storm "storm.zookeeper.servers") }}
STORM_ZOOKEEPER_PORT={{ index .Values.conf.storm "storm.zookeeper.port" }}

# render the config
db_connection={{ tuple "oslo_db" "internal" "monasca" "mysql" . | include "helm-toolkit.endpoints.authenticated_endpoint_uri_lookup" }}

read MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD MYSQL_DB < <(parse_db_url $db_connection)
export MYSQL_HOST
export MYSQL_PORT
export MYSQL_USER
export MYSQL_PASSWORD
export MYSQL_DB

cp /tmp/thresh-config.yml /etc/monasca/thresh-config.yml
sed -i "s/%THRESH_DB_USER%/$MYSQL_USER/g" /etc/monasca/thresh-config.yml
sed -i "s/%THRESH_DB_PASSWORD%/$MYSQL_PASSWORD/g" /etc/monasca/thresh-config.yml
sed -i "s/%THRESH_DB_URL%/$MYSQL_HOST:$MYSQL_PORT\/$MYSQL_DB/g" /etc/monasca/thresh-config.yml

# wait for zookeeper to become available
if [ "$ZOOKEEPER_WAIT" = "true" ]; then
  success="false"
  for i in $(seq "$ZOOKEEPER_WAIT_RETRIES"); do
    if ok=$(echo ruok | nc "$first_zk" "$STORM_ZOOKEEPER_PORT" -w "$ZOOKEEPER_WAIT_TIMEOUT") && [ "$ok" = "imok" ]; then
      success="true"
      break
    else
      echo "Connect attempt $i of $ZOOKEEPER_WAIT_RETRIES failed, retrying..."
      sleep "$ZOOKEEPER_WAIT_DELAY"
    fi
  done

  if [ "$success" != "true" ]; then
    echo "Could not connect to $first_zk after $i attempts, exiting..."
    sleep 1
    exit 1
  fi
fi

if [ -z "$STORM_LOCAL_HOSTNAME" ]; then
  # see also: http://stackoverflow.com/a/21336679
  ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
  echo "Using autodetected IP as advertised hostname: $ip"
  export STORM_LOCAL_HOSTNAME=$ip
fi

if [ -z "$SUPERVISOR_CHILDOPTS" ]; then
  SUPERVISOR_CHILDOPTS="-XX:MaxRAM=$(python /memory.py "$SUPERVISOR_MAX_MB") -XX:+UseSerialGC -Xss$SUPERVISOR_STACK_SIZE"
  export SUPERVISOR_CHILDOPTS
fi

if [ -z "$WORKER_CHILDOPTS" ]; then
  WORKER_CHILDOPTS="-XX:MaxRAM=$(python /memory.py "$WORKER_MAX_MB") -Xss$WORKER_STACK_SIZE"
  WORKER_CHILDOPTS="$WORKER_CHILDOPTS -XX:+UseConcMarkSweepGC"
  if [ "$WORKER_REMOTE_JMX" = "true" ]; then
    WORKER_CHILDOPTS="$WORKER_CHILDOPTS -Dcom.sun.management.jmxremote"
  fi

  export WORKER_CHILDOPTS
fi

if [ -z "$NIMBUS_CHILDOPTS" ]; then
  NIMBUS_CHILDOPTS="-XX:MaxRAM=$(python /memory.py "$NIMBUS_MAX_MB") -XX:+UseSerialGC -Xss$NIMBUS_STACK_SIZE"
  export NIMBUS_CHILDOPTS
fi

if [ -z "$UI_CHILDOPTS" ]; then
  UI_CHILDOPTS="-XX:MaxRAM=$(python /memory.py "$UI_MAX_MB") -XX:+UseSerialGC -Xss$UI_STACK_SIZE"
  export UI_CHILDOPTS
fi

if [ "$WORKER_LOGS_TO_STDOUT" = "true" ]; then
  for PORT in $(echo "$SUPERVISOR_SLOTS_PORTS" | sed -e "s/,/ /"); do
    LOGDIR="/storm/logs/workers-artifacts/thresh/$PORT"
    mkdir -p "$LOGDIR"
    WORKER_LOG="$LOGDIR/worker.log"
    RECREATE="true"
    if [ -e "$WORKER_LOG" ]; then
      if [ -L "$WORKER_LOG" ]; then
        RECREATE="false"
      else
        rm -f "$WORKER_LOG"
      fi
    fi
    if [ $RECREATE = "true" ]; then
      ln -s /proc/1/fd/1 "$WORKER_LOG"
    fi
  done
fi

export KAFKA_URI={{ .Values.conf.thresh_config.kafkaProducerConfig.metadataBrokerList }}

# Test services we need before starting our service.
echo "Start script: waiting for needed services"
python3 /kafka_wait_for_topics.py
python3 /mysql_check.py


echo "Waiting for storm to become available..."
success="false"
for i in $(seq "$STORM_WAIT_RETRIES"); do
  if timeout "$STORM_WAIT_TIMEOUT" storm list; then
    echo "Storm is available, continuing..."
    success="true"
    break
  else
    echo "Connection attempt $i of $STORM_WAIT_RETRIES failed"
    sleep "$STORM_WAIT_DELAY"
  fi
done

if [ "$success" != "true" ]; then
  echo "Unable to connect to Storm! Exiting..."
  sleep 1
  exit 1
fi

topologies=$(storm list | awk '/-----/,0{if (!/-----/)print $1}')
found="false"
for topology in $topologies; do
  if [ "$topology" = "$TOPOLOGY_NAME" ]; then
    found="true"
    echo "Found existing storm topology with name: $topology"
    break
  fi
done

if [ "$found" = "true" ]; then
  echo "Storm topology already exists, will not submit again"
  # TODO handle upgrades
else
  echo "Using Thresh Config file /etc/monasca/thresh-config.yml. Contents:"
  grep -vi password /etc/monasca/thresh-config.yml
  echo "Submitting storm topology..."
  storm jar /monasca-thresh.jar \
    monasca.thresh.ThresholdingEngine \
    /etc/monasca/thresh-config.yml \
    "$TOPOLOGY_NAME"
fi
