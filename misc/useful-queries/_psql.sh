#!/usr/bin/env bash
set -euo pipefail

# Connect to the TRAQUER PostgreSQL database using the same configuration file
# as the Julia application.
#
# The script discovers the configuration file path from Julia's startup file by
# reading the uncommented ENV["TRAQUER_CONFIGURATION_FILE"] assignment.
#
# Usage:
#   misc/useful-queries/connect-to-database.sh
#   misc/useful-queries/connect-to-database.sh -c "select now();"

# Allow overriding the Julia startup file for tests or non-standard setups.
startup_file="${JULIA_STARTUP_FILE:-$HOME/.julia/config/startup.jl}"

if [[ ! -f "$startup_file" ]]; then
    echo "Julia startup file not found: $startup_file" >&2
    exit 1
fi

# Extract the last uncommented ENV["TRAQUER_CONFIGURATION_FILE"] value.
config_file="$(
    awk '
        /^[[:space:]]*#/ { next }
        /ENV[[:space:]]*\[[[:space:]]*"TRAQUER_CONFIGURATION_FILE"[[:space:]]*\][[:space:]]*=/ {
            line = $0
            sub(/^[^=]*=[[:space:]]*"/, "", line)
            sub(/".*$/, "", line)
            print line
        }
    ' "$startup_file" | tail -n 1
)"

if [[ -z "$config_file" ]]; then
    echo "Could not find uncommented ENV[\"TRAQUER_CONFIGURATION_FILE\"] in $startup_file" >&2
    exit 1
fi

# Expand a leading '~' manually because it is stored in a variable.
config_file="${config_file/#\~/$HOME}"

if [[ ! -f "$config_file" ]]; then
    echo "TRAQUER configuration file not found: $config_file" >&2
    exit 1
fi

# Read one key from the [database] section of the TRAQUER configuration file.
# Commented lines starting with '#' or ';' are ignored.
get_database_conf() {
    local key="$1"

    awk -v section="database" -v key="$key" '
        /^[[:space:]]*[#;]/ { next }
        {
            trimmed = $0
            gsub(/^[ \t]+|[ \t]+$/, "", trimmed)
        }
        trimmed ~ /^\[/ {
            in_section = (trimmed == "[" section "]")
            next
        }
        in_section && index($0, "=") > 0 {
            line = $0
            k = line
            sub(/=.*/, "", k)
            gsub(/^[ \t]+|[ \t]+$/, "", k)

            if (k == key) {
                sub(/^[^=]*=/, "", line)
                gsub(/^[ \t]+|[ \t]+$/, "", line)
                print line
                exit
            }
        }
    ' "$config_file"
}

# Database connection settings.
host="$(get_database_conf host)"
port="$(get_database_conf port)"
database="$(get_database_conf database)"
user="$(get_database_conf user)"
password="$(get_database_conf password)"

# Fail early with an explicit message if one expected setting is missing.
missing=()
[[ -z "$host" ]] && missing+=(host)
[[ -z "$port" ]] && missing+=(port)
[[ -z "$database" ]] && missing+=(database)
[[ -z "$user" ]] && missing+=(user)
[[ -z "$password" ]] && missing+=(password)

if (( ${#missing[@]} > 0 )); then
    echo "Missing database setting(s) in $config_file: ${missing[*]}" >&2
    exit 1
fi

# Display non-sensitive connection details before connecting.
echo "Connecting to PostgreSQL database"
echo "  startup file: $startup_file"
echo "  config file:  $config_file"
echo "  host:         $host"
echo "  port:         $port"
echo "  database:     $database"
echo "  user:         $user"
echo

# Use PGPASSWORD instead of passing the password as a psql command-line argument.
exec env PGPASSWORD="$password" psql \
    --host="$host" \
    --port="$port" \
    --dbname="$database" \
    --username="$user" \
    "$@"
