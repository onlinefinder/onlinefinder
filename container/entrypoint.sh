#!/bin/sh
# shellcheck shell=dash
set -u

# Check if it's a valid file
check_file() {
    local target="$1"

    if [ ! -f "$target" ]; then
        cat <<EOF
!!!
!!! ERROR
!!! "$target" is not a valid file, exiting...
!!!
EOF
        exit 127
    fi
}

# Check if it's a valid directory
check_directory() {
    local target="$1"

    if [ ! -d "$target" ]; then
        cat <<EOF
!!!
!!! ERROR
!!! "$target" is not a valid directory, exiting...
!!!
EOF
        exit 127
    fi
}

setup_ownership() {
    local target="$1"
    local type="$2"

    case "$type" in
        file | directory) ;;
        *)
            cat <<EOF
!!!
!!! ERROR
!!! "$type" is not a valid type, exiting...
!!!
EOF
            exit 1
            ;;
    esac

    # Try to get ownership, but handle cases where stat fails or returns UNKNOWN
    target_ownership=$(stat -c %U:%G "$target" 2>/dev/null || echo "UNKNOWN:UNKNOWN")

    # If we got UNKNOWN, check if we can at least access the file/directory
    if [ "$target_ownership" = "UNKNOWN:UNKNOWN" ]; then
        # Check if we can read/write to the target
        if [ "$type" = "directory" ]; then
            if [ ! -w "$target" ] 2>/dev/null; then
                cat <<EOF
!!!
!!! WARNING
!!! "$target" directory is not writable
!!! This may cause issues when running OnlineFinder
!!!
EOF
            fi
        else
            if [ ! -r "$target" ] 2>/dev/null; then
                cat <<EOF
!!!
!!! WARNING
!!! "$target" file is not readable
!!! This may cause issues when running OnlineFinder
!!!
EOF
            fi
        fi
        # Don't fail on UNKNOWN ownership - just continue
        return 0
    fi

    if [ "$target_ownership" != "onlinefinder:onlinefinder" ]; then
        if [ "${FORCE_OWNERSHIP:-true}" = true ] && [ "$(id -u)" -eq 0 ]; then
            chown -R onlinefinder:onlinefinder "$target" 2>/dev/null || true
        else
            # Only warn if ownership is different, but don't fail
            # Check if we can still access it
            if [ "$type" = "directory" ]; then
                if [ -w "$target" ] 2>/dev/null; then
                    # Can write, so ownership warning is non-critical
                    cat <<EOF
...
... INFORMATION
... "$target" $type ownership is "$target_ownership" (expected "onlinefinder:onlinefinder")
... Directory is writable, continuing...
...
EOF
                else
                    cat <<EOF
!!!
!!! WARNING
!!! "$target" $type is not owned by "onlinefinder:onlinefinder" and may not be writable
!!! Expected "onlinefinder:onlinefinder"
!!! Got "$target_ownership"
!!!
EOF
                fi
            else
                if [ -r "$target" ] 2>/dev/null; then
                    # Can read, so ownership warning is non-critical
                    cat <<EOF
...
... INFORMATION
... "$target" $type ownership is "$target_ownership" (expected "onlinefinder:onlinefinder")
... File is readable, continuing...
...
EOF
                else
                    cat <<EOF
!!!
!!! WARNING
!!! "$target" $type is not owned by "onlinefinder:onlinefinder" and may not be readable
!!! Expected "onlinefinder:onlinefinder"
!!! Got "$target_ownership"
!!!
EOF
                fi
            fi
        fi
    fi
}

# Handle volume mounts
volume_handler() {
    local target="$1"

    # Ensure directory exists, create if it doesn't (if we have permission)
    if [ ! -d "$target" ]; then
        mkdir -p "$target" 2>/dev/null || {
            cat <<EOF
!!!
!!! ERROR
!!! Cannot create directory "$target"
!!! Please ensure the parent directory exists and is writable
!!!
EOF
            exit 1
        }
    fi

    check_directory "$target"
    setup_ownership "$target" "directory"
    
    # Ensure directory is writable
    if [ ! -w "$target" ]; then
        cat <<EOF
!!!
!!! WARNING
!!! Directory "$target" is not writable
!!! OnlineFinder may not function correctly
!!!
EOF
    fi
}

# Handle configuration file updates
config_handler() {
    local target="$1"
    local template="$2"
    local new_template_target="$target.new"
    local target_dir

    # Ensure the directory containing the target exists
    target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir" 2>/dev/null || {
            cat <<EOF
!!!
!!! ERROR
!!! Cannot create directory "$target_dir" for configuration file
!!! Please ensure the parent directory exists and is writable
!!!
EOF
            exit 1
        }
    fi

    # Create/Update the configuration file
    if [ -f "$target" ]; then
        setup_ownership "$target" "file"

        if [ "$template" -nt "$target" ]; then
            cp -pfT "$template" "$new_template_target" 2>/dev/null || {
                cat <<EOF
!!!
!!! WARNING
!!! Cannot create updated configuration file "$new_template_target"
!!! Continuing with existing configuration...
!!!
EOF
            }

            cat <<EOF
...
... INFORMATION
... Update available for "$target"
... It is recommended to update the configuration file to ensure proper functionality
...
... New version placed at "$new_template_target"
... Please review and merge changes
...
EOF
        fi
    else
        cat <<EOF
...
... INFORMATION
... "$target" does not exist, creating from template...
...
EOF
        cp -pfT "$template" "$target" 2>/dev/null || {
            cat <<EOF
!!!
!!! ERROR
!!! Cannot create configuration file "$target" from template "$template"
!!! Please check permissions
!!!
EOF
            exit 1
        }

        # Try to update secret key, but don't fail if sed fails
        sed -i "s/ultrasecretkey/$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')/g" "$target" 2>/dev/null || true
    fi

    check_file "$target"
}

cat <<EOF
OnlineFinder $ONLINEFINDER_VERSION
EOF

# Check for volume mounts
volume_handler "$CONFIG_PATH"
volume_handler "$DATA_PATH"

# Check for files
config_handler "$ONLINEFINDER_SETTINGS_PATH" "/usr/local/onlinefinder/olf/settings.yml"

# Update CA certificates (may require root, but try anyway)
update-ca-certificates 2>/dev/null || true

exec python -m olf.webapp
