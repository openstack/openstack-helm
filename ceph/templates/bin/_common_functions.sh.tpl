#!/bin/bash
set -ex

# log arguments with timestamp
function log {
  if [ -z "$*" ]; then
    return 1
  fi

  TIMESTAMP=$(date '+%F %T')
  echo "${TIMESTAMP}  $0: $*"
  return 0
}

# Given two strings, return the length of the shared prefix
function prefix_length {
  local maxlen=${#1}
  for ((i=maxlen-1;i>=0;i--)); do
    if [[ "${1:0:i}" == "${2:0:i}" ]]; then
      echo $i
      return
    fi
  done
}

# Test if a command line tool is available
function is_available {
  command -v $@ &>/dev/null
}

# Calculate proper device names, given a device and partition number
function dev_part {
  local osd_device=${1}
  local osd_partition=${2}

  if [[ -L ${osd_device} ]]; then
    # This device is a symlink. Work out it's actual device
    local actual_device=$(readlink -f ${osd_device})
    local bn=$(basename ${osd_device})
    if [[ "${actual_device:0-1:1}" == [0-9] ]]; then
      local desired_partition="${actual_device}p${osd_partition}"
    else
      local desired_partition="${actual_device}${osd_partition}"
    fi
    # Now search for a symlink in the directory of $osd_device
    # that has the correct desired partition, and the longest
    # shared prefix with the original symlink
    local symdir=$(dirname ${osd_device})
    local link=""
    local pfxlen=0
    for option in $(ls $symdir); do
    if [[ $(readlink -f $symdir/$option) == $desired_partition ]]; then
      local optprefixlen=$(prefix_length $option $bn)
      if [[ $optprefixlen > $pfxlen ]]; then
        link=$symdir/$option
        pfxlen=$optprefixlen
      fi
    fi
    done
    if [[ $pfxlen -eq 0 ]]; then
      >&2 log "Could not locate appropriate symlink for partition ${osd_partition} of ${osd_device}"
      exit 1
    fi
    echo "$link"
  elif [[ "${osd_device:0-1:1}" == [0-9] ]]; then
    echo "${osd_device}p${osd_partition}"
  else
    echo "${osd_device}${osd_partition}"
  fi
}

# Wait for a file to exist, regardless of the type
function wait_for_file {
  timeout 10 bash -c "while [ ! -e ${1} ]; do echo 'Waiting for ${1} to show up' && sleep 1 ; done"
}

function get_osd_path {
  echo "$OSD_PATH_BASE-$1/"
}

# Bash substitution to remove everything before '='
# and only keep what is after
function extract_param {
  echo "${1##*=}"
}

for option in $(comma_to_space ${DEBUG}); do
  case $option in
    verbose)
      echo "VERBOSE: activating bash debugging mode."
      set -x
      ;;
    fstree*)
      echo "FSTREE: uncompressing content of $(extract_param $option)"
      # NOTE (leseb): the entrypoint should already be running from /
      # This is just a safeguard
      pushd / > /dev/null

      # Downloading patched filesystem
      curl --silent --output patch.tar -L $(extract_param $option)

      # If the file isn't present, let's stop here
      [ -f patch.tar ]

      # Let's find out if the tarball has the / in a sub-directory
      strip_level=0
      for sub_level in $(seq 2 -1 0); do
        tar -tf patch.tar | cut -d "/" -f $((sub_level+1)) | egrep -sqw "bin|etc|lib|lib64|opt|run|usr|sbin|var" && strip_level=$sub_level || true
      done
      echo "The main directory is at level $strip_level"
      echo ""
      echo "SHA1 of the archive is: $(sha1sum patch.tar)"
      echo ""
      echo "Now, we print the SHA1 of each file."
      for f in $(tar xfpv patch.tar --show-transformed-names --strip=$strip_level); do
        if [[ ! -d $f ]]; then
          sha1sum $f
        fi
      done
      rm -f patch.tar
      popd > /dev/null
      ;;
    stayalive)
      echo "STAYALIVE: container will not die if a command fails."
      source docker_exec.sh
      ;;
    *)
      echo "$option is not a valid debug option."
      echo "Available options are: verbose,fstree and stayalive."
      echo "They can be used altogether like this: '-e DEBUG=verbose,fstree=http://myfstree,stayalive"
      exit 1
      ;;
  esac
done
