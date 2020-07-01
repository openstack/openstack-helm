#!/bin/bash

{{/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

# This script will attempt to migrate your nova-api placement data to
# a new placement database. Run it with --help for usage, and --mkconfig
# to write a template config file to use.

# Defaults we can guess
DEFAULT_MIGRATE_TABLES="allocations placement_aggregates consumers inventories projects "
DEFAULT_MIGRATE_TABLES+="resource_classes resource_provider_aggregates resource_provider_traits "
DEFAULT_MIGRATE_TABLES+="resource_providers traits users "
MIGRATE_TABLES=${MIGRATE_TABLES:-$DEFAULT_MIGRATE_TABLES}
PLACEMENT_DB_HOST=${PLACEMENT_DB_HOST:-localhost}
PLACEMENT_DB=${PLACEMENT_DB:-placement}
NOVA_API_DB_HOST=${NOVA_API_DB_HOST:-localhost}
NOVA_API_DB=${NOVA_API_DB:-nova_api}
TMPDIR=${TMPDIR:-/tmp}
LAST_MYSQL_ERR=${TMPDIR}/migrate-mysql-db.err
INITIAL_PLACEMENT_DB_VERSION=${INITIAL_DB_VERSION:-b4ed3a175331}
ME=$(basename "$0")

declare -a ARGS
declare -a OPTS

function getflag() {
    # Return true if --$flag is present on the command line
    # Usage: getflag help -> 0
    local flag="$1"
    for opt in ${OPTS[*]}; do
        if [ "$opt" == "--${flag}" ]; then
            return 0
        fi
    done
    return 1
}

function parse_argv() {
    # Parse command line arguments into positional arguments and
    # option flags. Store each in $ARGS, $OPTS.
    # Usage: parse_argv $*
    for item in $*; do
        if echo $item | grep -q -- '^--'; then
            OPTS+=($item)
        else
            ARGS+=($item)
        fi
    done
}

function db_var() {
    # Return an attribute of database config based on the symbolic
    # name
    # Usage: db_var PLACEMENT USER -> $PLACEMENT_USER
    local db="$1"
    local var="$2"

    eval echo "\$${db}_${var}"
}

function mysql_command() {
    # Run a mysql command with the usual connection information taken
    # from a symbolic configuration name
    # Usage: mysql_command PLACEMENT [command] [args..] -> stdout
    local whichdb="$1"
    shift
    local command=mysql
    if [ "$2" ]; then
        command=${1:-mysql}
        shift
    fi
    local db=$(db_var $whichdb DB)
    local host=$(db_var $whichdb DB_HOST)
    local user=$(db_var $whichdb USER)
    local pass=$(db_var $whichdb PASS)

    if [ "$command" = "mysql" ]; then
        command="mysql --skip-column-names"
    fi

    if [ ! -z "$MARIADB_X509" ]; then
        local ca=/etc/mysql/certs/ca.crt
        local cert=/etc/mysql/certs/tls.crt
        local key=/etc/mysql/certs/tls.key
        $command -h$host -u$user -p$pass $db --ssl-ca=$ca --ssl-cert=$cert --ssl-key=$key $* 2>$LAST_MYSQL_ERR
    else
        $command -h$host -u$user -p$pass $db $* 2>$LAST_MYSQL_ERR
    fi
}

function show_error() {
    # Prints the last error (if present) and removes the temporary
    # file
    if [ -f $LAST_MYSQL_ERR ]; then
        cat $LAST_MYSQL_ERR
        rm -f $LAST_MYSQL_ERR
    fi
}

function check_db() {
    # Check a DB to see if it's missing, present, filled with data
    # Returns 0 if it is present with data, 1 if present but no data
    # or 2 if not present (or unable to connect)
    # Usage: check_db PLACEMENT -> 0
    local whichdb="$1"

    local inv
    local inv_count

    if ! echo "SELECT DATABASE()" | mysql_command $whichdb >/dev/null 2>&1; then
        echo "Failed to connect to $whichdb database"
        show_error
        return 2
    fi

    inv=$(echo "SELECT COUNT(id) FROM inventories" |
              mysql_command $whichdb)
    if [ $? -ne 0 ]; then
        # No schema
        return 1
    fi

    inv_count=$(echo $inv | tail -n1)
    if [ $inv_count -gt 0 ]; then
        # Data found
        return 0
    else
        # No data found, but schema intact
        return 1
    fi
}

function check_cli() {
    # Returns 0 if placement cli is installed and configured,
    # 1 if it is not installed, or 2 if the access to the
    # placement database fails
    # Usage: check_cli -> 0
    placement-manage --version > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        # placement not installed
        return 1
    fi

    placement-manage db version > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        # DB connection fails
        return 2
    fi
}

function migrate_data() {
    # Actually migrate data from a source to destination symbolic
    # database. Returns 1 if failure, 0 otherwise.
    # Usage: migrate_data NOVA_API PLACEMENT -> 0
    local source="$1"
    local dest="$2"
    local dump_flags="$3"
    local tmpdir=$(mktemp -d migrate-db.XXXXXXXX)
    local tmpfile="${tmpdir}/from-nova.sql"

    echo "Dumping from $source to $tmpfile"
    mysql_command $source mysqldump $dump_flags $MIGRATE_TABLES > $tmpfile || {
        echo 'Failed to dump source database:'
        show_error
        return 1
    }
    echo "Loading to $dest from $tmpfile"
    mysql_command $dest < $tmpfile || {
        echo 'Failed to load destination database:'
        show_error
        return 1
    }
}

function sanity_check_env() {
    # Check that we have everything we need to examine the situation
    # and potentially do the migration. Loads values from the rcfile,
    # if present. Returns 1 if a config was not found, 2 if that
    # config is incomplete or 0 if everything is good.
    # Usage: sanity_check_env $rcfile -> 0

    RCFILE="${1:-migrate-db.rc}"
    if [ "$RCFILE" = '-' ]; then
        # Don't require a file and assume everything is already
        # set in the environment
        true
    elif [ ! -f "$RCFILE" ]; then
        echo -n 'ERROR: Specify an RC file on the command line or create '
        echo 'migrate-db.rc in the current directory'
        echo
        show_help
    else
        source $RCFILE
    fi

    required="NOVA_API_DB NOVA_API_USER NOVA_API_PASS PLACEMENT_DB PLACEMENT_USER PLACEMENT_PASS"
    for var in $required; do
        value=$(eval echo "\$$var")
        if [ -z "$value" ]; then
            echo "A value for $var was not provided but is required"
            return 2
        fi
    done
}

function make_config() {
    # Create or update a config file with defaults we know. Either use
    # the default migrate-db.rc or the file specified on the command
    # line.
    RCFILE="${1:-migrate-db.rc}"
    if [ -f "$RCFILE" ]; then
        source $RCFILE
    fi

    vars="NOVA_API_DB NOVA_API_USER NOVA_API_PASS NOVA_API_DB_HOST "
    vars+="PLACEMENT_DB PLACEMENT_USER PLACEMENT_PASS PLACEMENT_DB_HOST "
    vars+="MIGRATE_TABLES"

    (for var in $vars; do
         val=$(eval echo "\$$var")
         echo "${var}=\"$val\""
     done) > $RCFILE

    echo Wrote $(readlink -f $RCFILE)
}

function show_help() {
    echo "Usage: $ME [flags] [rcfile]"
    echo
    echo "Flags:"
    echo "    --help: this text"
    echo "    --migrate: actually do data migration"
    echo "    --mkconfig: write/update config to \$rcfile"
    echo "    --skip-locks: don't use table locks for data migration"
    echo
    echo "Pass '-' as \$rcfile if all config values are set in"
    echo "the environment."
    echo
    echo "Exit codes:"
    echo "    0: Success"
    echo "    1: Usage error"
    echo "    2: Configuration missing or incomplete"
    echo "    3: Migration already completed"
    echo "    4: No data to migrate from nova (new deployment)"
    echo "    5: Unable to connect to one or both databases"
    echo "    6: Unable to execute placement's CLI commands"
    exit 0
}

parse_argv $*

if getflag help; then
    show_help
fi

if getflag mkconfig; then
    make_config $ARGS
    exit 0
fi

#
# Actual migration logic starts here
#

# Sanity check that we have what we need or bail
sanity_check_env $ARGS || exit $?

# Check the state of each database we care about
check_db NOVA_API
nova_present=$?
check_db PLACEMENT
placement_present=$?
check_cli
placement_cli=$?

# Try to come up with a good reason to refuse to migrate
if [ $nova_present -eq 0 -a $placement_present -eq 0 ]; then
    echo "Migration has already completed. The placement database appears to have data."
    exit 3
elif [ $nova_present -eq 1 ]; then
    echo "No data present in nova database - nothing to migrate (new deployment?)"
    exit 4
elif [ $nova_present -eq 2 ]; then
    echo "Unable to proceed without connection to nova database"
    exit 5
elif [ $placement_present -eq 2 ]; then
    echo "Unable to proceed without connection to placement database"
    exit 5
elif [ $placement_cli -eq 1 ]; then
    echo "Unable to proceed without placement installed"
    exit 6
elif [ $placement_cli -eq 2 ]; then
    echo "The 'placement-manage db version' command fails"
    echo "Is placement.conf configured to access the new database?"
    exit 6
fi

# If we get here, we expect to be able to migrate. Require them to opt into
# actual migration before we do anything.

echo Nova database contains data, placement database does not. Okay to proceed with migration

if getflag migrate $*; then
    if getflag skip-locks $*; then
        migrate_data NOVA_API PLACEMENT "--skip-lock-tables --skip-add-locks"
    else
        migrate_data NOVA_API PLACEMENT
    fi
    placement-manage db stamp $INITIAL_PLACEMENT_DB_VERSION
else
    echo "To actually migrate, run me with --migrate"
fi

rm -f $LAST_MYSQL_ERR
