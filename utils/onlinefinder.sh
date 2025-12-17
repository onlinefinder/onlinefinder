#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# shellcheck disable=SC2001

# Script options from the environment:
ONLINEFINDER_UWSGI_USE_SOCKET="${ONLINEFINDER_UWSGI_USE_SOCKET:-true}"

# shellcheck source=utils/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# shellcheck source=utils/lib_redis.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib_redis.sh"
# shellcheck source=utils/lib_valkey.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib_valkey.sh"
# shellcheck source=utils/brand.sh
source "${REPO_ROOT}/utils/brand.sh"

SERVICE_NAME="onlinefinder"
SERVICE_USER="onlinefinder"
SERVICE_HOME="/usr/local/onlinefinder"
SERVICE_GROUP="onlinefinder"

ONLINEFINDER_SRC="${SERVICE_HOME}/onlinefinder-src"
# shellcheck disable=SC2034
ONLINEFINDER_STATIC="${ONLINEFINDER_SRC}/olf/static"

ONLINEFINDER_PYENV="${SERVICE_HOME}/searx-pyenv"
ONLINEFINDER_SETTINGS_PATH="/etc/onlinefinder/settings.yml"
ONLINEFINDER_UWSGI_APP="onlinefinder.ini"

ONLINEFINDER_INTERNAL_HTTP="${ONLINEFINDER_BIND_ADDRESS}:${ONLINEFINDER_PORT}"
if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
    ONLINEFINDER_UWSGI_SOCKET="${SERVICE_HOME}/run/socket"
else
    ONLINEFINDER_UWSGI_SOCKET=
fi

# ONLINEFINDER_URL: the public URL of the instance (https://example.org/onlinefinder).  The
# value is taken from environment ${ONLINEFINDER_URL} in ./utils/brand.env.  This
# variable is an empty string if server.base_url in the settings.yml is set to
# 'false'.

ONLINEFINDER_URL="${ONLINEFINDER_URL:-http://$(uname -n)/onlinefinder}"
ONLINEFINDER_URL="${ONLINEFINDER_URL%/}" # if exists, remove trailing slash
ONLINEFINDER_URL_PATH="$(echo "${ONLINEFINDER_URL}" | sed -e 's,^.*://[^/]*\(/.*\),\1,g')"
[[ "${ONLINEFINDER_URL_PATH}" == "${ONLINEFINDER_URL}" ]] && ONLINEFINDER_URL_PATH=/

# Apache settings

APACHE_ONLINEFINDER_SITE="onlinefinder.conf"

# nginx settings

NGINX_ONLINEFINDER_SITE="onlinefinder.conf"

# apt packages

ONLINEFINDER_PACKAGES_debian="\
python3-dev python3-babel python3-venv python-is-python3
uwsgi uwsgi-plugin-python3
git build-essential libxslt-dev zlib1g-dev libffi-dev libssl-dev"

ONLINEFINDER_BUILD_PACKAGES_debian="\
graphviz imagemagick texlive-xetex librsvg2-bin
texlive-latex-recommended texlive-extra-utils fonts-dejavu
latexmk shellcheck"

# pacman packages

ONLINEFINDER_PACKAGES_arch="\
python python-pip python-lxml python-babel
uwsgi uwsgi-plugin-python
git base-devel libxml2"

ONLINEFINDER_BUILD_PACKAGES_arch="\
graphviz imagemagick texlive-bin extra/librsvg
texlive-core texlive-latexextra ttf-dejavu shellcheck"

# dnf packages

ONLINEFINDER_PACKAGES_fedora="\
python python-pip python-lxml python-babel python3-devel
uwsgi uwsgi-plugin-python3
git @development-tools libxml2 openssl"

ONLINEFINDER_BUILD_PACKAGES_fedora="\
graphviz graphviz-gd ImageMagick librsvg2-tools
texlive-xetex-bin texlive-collection-fontsrecommended
texlive-collection-latex dejavu-sans-fonts dejavu-serif-fonts
dejavu-sans-mono-fonts ShellCheck"

case $DIST_ID-$DIST_VERS in
    ubuntu-18.04)
        ONLINEFINDER_PACKAGES="${ONLINEFINDER_PACKAGES_debian}"
        ONLINEFINDER_BUILD_PACKAGES="${ONLINEFINDER_BUILD_PACKAGES_debian}"
        APACHE_PACKAGES="$APACHE_PACKAGES libapache2-mod-proxy-uwsgi"
        ;;
    ubuntu-* | debian-*)
        ONLINEFINDER_PACKAGES="${ONLINEFINDER_PACKAGES_debian} python-is-python3"
        ONLINEFINDER_BUILD_PACKAGES="${ONLINEFINDER_BUILD_PACKAGES_debian}"
        ;;
    arch-*)
        ONLINEFINDER_PACKAGES="${ONLINEFINDER_PACKAGES_arch}"
        ONLINEFINDER_BUILD_PACKAGES="${ONLINEFINDER_BUILD_PACKAGES_arch}"
        ;;
    fedora-*)
        ONLINEFINDER_PACKAGES="${ONLINEFINDER_PACKAGES_fedora}"
        ONLINEFINDER_BUILD_PACKAGES="${ONLINEFINDER_BUILD_PACKAGES_fedora}"
        ;;
esac

_service_prefix="  ${_Yellow}|${SERVICE_USER}|${_creset} "

usage() {

    # shellcheck disable=SC1117
    cat <<EOF
usage:
  $(basename "$0") install    [all|user|pyenv|settings|uwsgi|valkey|nginx|apache|onlinefinder-src|packages|buildhost]
  $(basename "$0") remove     [all|user|pyenv|settings|uwsgi|valkey|nginx|apache]
  $(basename "$0") instance   [cmd|update|check|localtest|inspect]
install|remove:
  all           : complete (de-) installation of the OnlineFinder service
  user          : service user '${SERVICE_USER}' (${SERVICE_HOME})
  pyenv         : virtualenv (python) in ${ONLINEFINDER_PYENV}
  settings      : settings from ${ONLINEFINDER_SETTINGS_PATH}
  uwsgi         : OnlineFinder's uWSGI app ${ONLINEFINDER_UWSGI_APP}
  nginx         : HTTP site ${NGINX_APPS_AVAILABLE}/${NGINX_ONLINEFINDER_SITE}
  apache        : HTTP site ${APACHE_SITES_AVAILABLE}/${APACHE_ONLINEFINDER_SITE}
install:
  valkey        : install a local valkey server
remove:
  redis         : remove a local redis server ${REDIS_HOME}/run/redis.sock
install:
  onlinefinder-src   : clone ${GIT_URL} into ${ONLINEFINDER_SRC}
  packages      : installs packages from OS package manager required by OnlineFinder
  buildhost     : installs packages from OS package manager required by a OnlineFinder buildhost
instance:
  update        : update OnlineFinder instance (git fetch + reset & update settings.yml)
  check         : run checks from utils/onlinefinder_check.py in the active installation
  inspect       : run some small tests and inspect OnlineFinder's server status and log
  get_setting   : get settings value from running OnlineFinder instance
  cmd           : run command in OnlineFinder instance's environment (e.g. bash)
EOF
    onlinefinder.instance.env
    [[ -n ${1} ]] && err_msg "$1"
}

onlinefinder.instance.env() {
    echo "uWSGI:"
    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        echo "  ONLINEFINDER_UWSGI_SOCKET : ${ONLINEFINDER_UWSGI_SOCKET}"
    else
        echo "  ONLINEFINDER_INTERNAL_HTTP: ${ONLINEFINDER_INTERNAL_HTTP}"
    fi
    cat <<EOF
environment:
  GIT_URL              : ${GIT_URL}
  GIT_BRANCH           : ${GIT_BRANCH}
  ONLINEFINDER_URL          : ${ONLINEFINDER_URL}
  ONLINEFINDER_PORT         : ${ONLINEFINDER_PORT}
  ONLINEFINDER_BIND_ADDRESS : ${ONLINEFINDER_BIND_ADDRESS}
EOF
}

main() {
    case $1 in
        install | remove | instance)
            nginx_distro_setup
            apache_distro_setup
            uWSGI_distro_setup
            required_commands \
                sudo systemctl install git wget curl ||
                exit
            ;;
    esac

    local _usage="unknown or missing $1 command $2"

    case $1 in
        --getenv)
            var="$2"
            echo "${!var}"
            exit 0
            ;;
        --cmd)
            shift
            "$@"
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        install)
            sudo_or_exit
            case $2 in
                all) onlinefinder.install.all ;;
                user) onlinefinder.install.user ;;
                pyenv) onlinefinder.install.pyenv ;;
                onlinefinder-src) onlinefinder.install.clone ;;
                settings) onlinefinder.install.settings ;;
                uwsgi) onlinefinder.install.uwsgi ;;
                packages) onlinefinder.install.packages ;;
                buildhost) onlinefinder.install.buildhost ;;
                nginx) onlinefinder.nginx.install ;;
                apache) onlinefinder.apache.install ;;
                valkey) onlinefinder.install.valkey ;;
                *)
                    usage "$_usage"
                    exit 42
                    ;;
            esac
            ;;
        remove)
            sudo_or_exit
            case $2 in
                all) onlinefinder.remove.all ;;
                user) drop_service_account "${SERVICE_USER}" ;;
                pyenv) onlinefinder.remove.pyenv ;;
                settings) onlinefinder.remove.settings ;;
                uwsgi) onlinefinder.remove.uwsgi ;;
                apache) onlinefinder.apache.remove ;;
                remove) onlinefinder.nginx.remove ;;
                valkey) onlinefinder.remove.valkey ;;
                redis) onlinefinder.remove.redis ;;
                *)
                    usage "$_usage"
                    exit 42
                    ;;
            esac
            ;;
        instance)
            case $2 in
                update)
                    sudo_or_exit
                    onlinefinder.instance.update
                    ;;
                check)
                    sudo_or_exit
                    onlinefinder.instance.self.call onlinefinder.check
                    ;;
                inspect)
                    sudo_or_exit
                    onlinefinder.instance.inspect
                    ;;
                cmd)
                    sudo_or_exit
                    shift
                    shift
                    onlinefinder.instance.exec "$@"
                    ;;
                get_setting)
                    shift
                    shift
                    onlinefinder.instance.get_setting "$@"
                    ;;
                call)
                    # call a function in instance's environment
                    shift
                    shift
                    onlinefinder.instance.self.call "$@"
                    ;;
                _call)
                    shift
                    shift
                    "$@"
                    ;;
                *)
                    usage "$_usage"
                    exit 42
                    ;;
            esac
            ;;
        *)
            local cmd="$1"
            _type="$(type -t "$cmd")"
            if [ "$_type" != 'function' ]; then
                usage "unknown or missing command $1"
                exit 42
            else
                "$cmd" "$@"
            fi
            ;;
    esac
}

onlinefinder.install.all() {
    rst_title "OnlineFinder installation" part

    local valkey_url

    rst_title "OnlineFinder"
    onlinefinder.install.packages
    wait_key 10
    onlinefinder.install.user
    wait_key 10
    onlinefinder.install.clone
    wait_key
    onlinefinder.install.pyenv
    wait_key
    onlinefinder.install.settings
    wait_key
    onlinefinder.instance.localtest
    wait_key
    onlinefinder.install.uwsgi
    wait_key

    rst_title "Valkey DB"
    onlinefinder.install.valkey.db

    rst_title "HTTP Server"
    onlinefinder.install.http.site

    rst_title "Finalize installation"
    if ask_yn "Do you want to run some checks?" Yn; then
        onlinefinder.instance.self.call onlinefinder.check
    fi
}

onlinefinder.install.valkey.db() {
    local valkey_url

    valkey_url=$(onlinefinder.instance.get_setting valkey.url)

    if [ "${valkey_url}" = "False" ]; then
        rst_para "valkey DB connector is not configured in your instance"
    else
        rst_para "\
In your instance, valkey DB connector is configured at:

    ${valkey_url}
"
        if onlinefinder.instance.exec python -c "from searx import valkeydb; valkeydb.initialize() or exit(42)"; then
            info_msg "OnlineFinder instance is able to connect valkey DB."
            return
        fi
    fi

    if ! [[ ${valkey_url} = valkey://localhost:6379/* ]]; then
        err_msg "OnlineFinder instance can't connect valkey DB / check valkey & your settings"
        return
    fi
    rst_para ".. but this valkey DB is not installed yet."

    if ask_yn "Do you want to install the valkey DB now?" Yn; then
        onlinefinder.install.valkey
        uWSGI_restart "$ONLINEFINDER_UWSGI_APP"
    fi
}

onlinefinder.install.http.site() {

    if apache_is_installed; then
        info_msg "Apache is installed on this host."
        if ask_yn "Do you want to install a reverse proxy" Yn; then
            onlinefinder.apache.install
        fi
    elif nginx_is_installed; then
        info_msg "Nginx is installed on this host."
        if ask_yn "Do you want to install a reverse proxy" Yn; then
            onlinefinder.nginx.install
        fi
    else
        info_msg "Don't forget to install HTTP site."
    fi
}

onlinefinder.remove.all() {
    local valkey_url

    rst_title "De-Install OnlineFinder (service)"
    if ! ask_yn "Do you really want to deinstall OnlineFinder?"; then
        return
    fi

    valkey_url=$(onlinefinder.instance.get_setting valkey.url)
    if ! [[ ${valkey_url} = unix://${VALKEY_HOME}/run/valkey.sock* ]]; then
        onlinefinder.remove.valkey
    fi

    onlinefinder.remove.uwsgi
    drop_service_account "${SERVICE_USER}"
    onlinefinder.remove.settings
    wait_key

    if service_is_available "${ONLINEFINDER_URL}"; then
        MSG="** Don't forget to remove your public site! (${ONLINEFINDER_URL}) **" wait_key 10
    fi
}

onlinefinder.install.user() {
    rst_title "OnlineFinder -- install user" section
    echo
    if getent passwd "${SERVICE_USER}" >/dev/null; then
        echo "user already exists"
        return 0
    fi

    tee_stderr 1 <<EOF | bash | prefix_stdout
useradd --shell /bin/bash --system \
 --home-dir "${SERVICE_HOME}" \
 --comment 'Privacy-respecting metasearch engine' ${SERVICE_USER}
mkdir "${SERVICE_HOME}"
chown -R "${SERVICE_GROUP}:${SERVICE_GROUP}" "${SERVICE_HOME}"
groups ${SERVICE_USER}
EOF
}

onlinefinder.install.packages() {
    TITLE="OnlineFinder -- install packages" pkg_install "${ONLINEFINDER_PACKAGES}"
}

onlinefinder.install.buildhost() {
    TITLE="OnlineFinder -- install buildhost packages" pkg_install \
        "${ONLINEFINDER_PACKAGES} ${ONLINEFINDER_BUILD_PACKAGES}"
}

onlinefinder.install.clone() {
    rst_title "Clone OnlineFinder sources" section
    if ! service_account_is_available "${SERVICE_USER}"; then
        die 42 "To clone OnlineFinder, first install user ${SERVICE_USER}."
    fi
    echo
    if ! sudo -i -u "${SERVICE_USER}" ls -d "$REPO_ROOT" >/dev/null; then
        die 42 "user '${SERVICE_USER}' missed read permission: $REPO_ROOT"
    fi
    # SERVICE_HOME="$(sudo -i -u "${SERVICE_USER}" echo \$HOME 2>/dev/null)"
    if [[ ! "${SERVICE_HOME}" ]]; then
        err_msg "to clone OnlineFinder sources, user ${SERVICE_USER} hast to be created first"
        return 42
    fi
    if [[ ! $(git show-ref "refs/heads/${GIT_BRANCH}") ]]; then
        warn_msg "missing local branch ${GIT_BRANCH}"
        info_msg "create local branch ${GIT_BRANCH} from start point: origin/${GIT_BRANCH}"
        git branch "${GIT_BRANCH}" "origin/${GIT_BRANCH}"
    fi
    if [[ ! $(git rev-parse --abbrev-ref HEAD) == "${GIT_BRANCH}" ]]; then
        warn_msg "take into account, installing branch $GIT_BRANCH while current branch is $(git rev-parse --abbrev-ref HEAD)"
    fi
    # export SERVICE_HOME

    # clone repo and add a safe.directory entry to git's system config / see
    # https://github.com/onlinefinder/onlinefinder/issues/1251
    git config --system --add safe.directory "${REPO_ROOT}/.git"
    git_clone "$REPO_ROOT" "${ONLINEFINDER_SRC}" \
        "$GIT_BRANCH" "${SERVICE_USER}"
    git config --system --add safe.directory "${ONLINEFINDER_SRC}"

    pushd "${ONLINEFINDER_SRC}" >/dev/null
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
cd "${ONLINEFINDER_SRC}"
git remote set-url origin ${GIT_URL}
git config user.email "${ADMIN_EMAIL}"
git config user.name "${ADMIN_NAME}"
git config --list
EOF
    popd >/dev/null
}

onlinefinder.install.link_src() {
    rst_title "link OnlineFinder's sources to: $2" chapter
    echo
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
mv -f "${ONLINEFINDER_SRC}" "${ONLINEFINDER_SRC}.backup"
ln -s "${2}" "${ONLINEFINDER_SRC}"
ls -ld /usr/local/onlinefinder/onlinefinder-src
EOF
    echo
    uWSGI_restart "$ONLINEFINDER_UWSGI_APP"
}

onlinefinder.install.pyenv() {
    rst_title "Create virtualenv (python)" section
    echo
    if [[ ! -f "${ONLINEFINDER_SRC}/manage" ]]; then
        die 42 "To create pyenv for OnlineFinder, first install onlinefinder-src."
    fi
    info_msg "create pyenv in ${ONLINEFINDER_PYENV}"
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
rm -rf "${ONLINEFINDER_PYENV}"
python -m venv "${ONLINEFINDER_PYENV}"
grep -qFs -- 'source ${ONLINEFINDER_PYENV}/bin/activate' ~/.profile \
  || echo 'source ${ONLINEFINDER_PYENV}/bin/activate' >> ~/.profile
EOF
    info_msg "inspect python's virtual environment"
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
command -v python && python --version
EOF
    wait_key
    info_msg "install needed python packages"
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
pip install -U pip
pip install -U setuptools
pip install -U wheel
pip install -U pyyaml
pip install -U msgspec
cd ${ONLINEFINDER_SRC}
pip install --use-pep517 --no-build-isolation -e .
EOF
}

onlinefinder.remove.pyenv() {
    rst_title "Remove virtualenv (python)" section
    if ! ask_yn "Do you really want to drop ${ONLINEFINDER_PYENV} ?"; then
        return
    fi
    info_msg "remove pyenv activation from ~/.profile"
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
grep -v 'source ${ONLINEFINDER_PYENV}/bin/activate' ~/.profile > ~/.profile.##
mv ~/.profile.## ~/.profile
EOF
    rm -rf "${ONLINEFINDER_PYENV}"
}

onlinefinder.install.settings() {
    rst_title "install ${ONLINEFINDER_SETTINGS_PATH}" section

    if ! [[ -f "${ONLINEFINDER_SRC}/.git/config" ]]; then
        die "Before install settings, first install OnlineFinder."
    fi

    mkdir -p "$(dirname "${ONLINEFINDER_SETTINGS_PATH}")"

    DEFAULT_SELECT=1 \
        install_template --no-eval \
        "${ONLINEFINDER_SETTINGS_PATH}" \
        "${SERVICE_USER}" "${SERVICE_GROUP}"

    tee_stderr 0.1 <<EOF | sudo -H -i 2>&1 | prefix_stdout "root"
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" "${ONLINEFINDER_SETTINGS_PATH}"
EOF
}

onlinefinder.remove.settings() {
    rst_title "remove ${ONLINEFINDER_SETTINGS_PATH}" section
    if ask_yn "Do you want to delete the OnlineFinder settings?" Yn; then
        rm -f "${ONLINEFINDER_SETTINGS_PATH}"
    fi
}

onlinefinder.check() {
    rst_title "OnlineFinder checks" section
    "${ONLINEFINDER_PYENV}/bin/python" "${ONLINEFINDER_SRC}/utils/onlinefinder_check.py"
}

onlinefinder.instance.update() {
    rst_title "Update OnlineFinder instance"
    rst_para "fetch from $GIT_URL and reset to origin/$GIT_BRANCH"
    tee_stderr 0.3 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
cd ${ONLINEFINDER_SRC}
git fetch origin "$GIT_BRANCH"
git reset --hard "origin/$GIT_BRANCH"
pip install -U pip
pip install -U setuptools
pip install -U wheel
pip install -U pyyaml
pip install -U msgspec
pip install -U --use-pep517 --no-build-isolation -e .
EOF
    rst_para "update instance's settings.yml from ${ONLINEFINDER_SETTINGS_PATH}"
    DEFAULT_SELECT=2 \
        install_template --no-eval \
        "${ONLINEFINDER_SETTINGS_PATH}" \
        "${SERVICE_USER}" "${SERVICE_GROUP}"

    sudo -H -i <<EOF
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" "${ONLINEFINDER_SETTINGS_PATH}"
EOF
    uWSGI_restart "${ONLINEFINDER_UWSGI_APP}"
}

onlinefinder.install.uwsgi() {
    rst_title "OnlineFinder (install uwsgi)"
    install_uwsgi
    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        onlinefinder.install.uwsgi.socket
    else
        onlinefinder.install.uwsgi.http
    fi
}

onlinefinder.install.uwsgi.http() {
    rst_para "Install ${ONLINEFINDER_UWSGI_APP} at: http://${ONLINEFINDER_INTERNAL_HTTP}"
    uWSGI_install_app "${ONLINEFINDER_UWSGI_APP}"
    if ! onlinefinder.uwsgi.available; then
        err_msg "URL http://${ONLINEFINDER_INTERNAL_HTTP} not available, check OnlineFinder & uwsgi setup!"
    fi
}

onlinefinder.install.uwsgi.socket() {
    rst_para "Install ${ONLINEFINDER_UWSGI_APP} using socket at: ${ONLINEFINDER_UWSGI_SOCKET}"
    mkdir -p "$(dirname "${ONLINEFINDER_UWSGI_SOCKET}")"
    chown -R "${SERVICE_USER}:${SERVICE_GROUP}" "$(dirname "${ONLINEFINDER_UWSGI_SOCKET}")"

    case $DIST_ID-$DIST_VERS in
        fedora-*)
            # Fedora runs uWSGI in emperor-tyrant mode: in Tyrant mode the
            # Emperor will run the vassal using the UID/GID of the vassal
            # configuration file [1] (user and group of the app .ini file).
            # [1] https://uwsgi-docs.readthedocs.io/en/latest/Emperor.html#tyrant-mode-secure-multi-user-hosting
            uWSGI_install_app --variant=socket "${ONLINEFINDER_UWSGI_APP}" "${SERVICE_USER}" "${SERVICE_GROUP}"
            ;;
        *)
            uWSGI_install_app --variant=socket "${ONLINEFINDER_UWSGI_APP}"
            ;;
    esac
    sleep 5
    if ! onlinefinder.uwsgi.available; then
        err_msg "uWSGI socket not available at: ${ONLINEFINDER_UWSGI_SOCKET}"
    fi
}

onlinefinder.uwsgi.available() {
    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        [[ -S "${ONLINEFINDER_UWSGI_SOCKET}" ]]
        exit_val=$?
        if [[ $exit_val = 0 ]]; then
            info_msg "uWSGI socket is located at: ${ONLINEFINDER_UWSGI_SOCKET}"
        fi
    else
        service_is_available "http://${ONLINEFINDER_INTERNAL_HTTP}"
        exit_val=$?
    fi
    return "$exit_val"
}

onlinefinder.remove.uwsgi() {
    rst_title "Remove OnlineFinder's uWSGI app (${ONLINEFINDER_UWSGI_APP})" section
    echo
    uWSGI_remove_app "${ONLINEFINDER_UWSGI_APP}"
}

onlinefinder.remove.redis() {
    rst_title "OnlineFinder (remove redis)"
    redis.rmgrp "${SERVICE_USER}"
    redis.remove
}

onlinefinder.install.valkey() {
    rst_title "OnlineFinder (install valkey)"
    valkey.install
}

onlinefinder.instance.localtest() {
    rst_title "Test OnlineFinder instance locally" section
    rst_para "Activate debug mode, start a minimal OnlineFinder " \
        "service and debug a HTTP request/response cycle."

    if service_is_available "http://${ONLINEFINDER_INTERNAL_HTTP}" &>/dev/null; then
        err_msg "URL/port http://${ONLINEFINDER_INTERNAL_HTTP} is already in use, you"
        err_msg "should stop that service before starting local tests!"
        if ! ask_yn "Continue with local tests?"; then
            return
        fi
    fi
    echo
    onlinefinder.instance.debug.on
    tee_stderr 0.1 <<EOF | sudo -H -u "${SERVICE_USER}" -i 2>&1 | prefix_stdout "$_service_prefix"
export ONLINEFINDER_SETTINGS_PATH="${ONLINEFINDER_SETTINGS_PATH}"
cd ${ONLINEFINDER_SRC}
timeout 10 python searx/webapp.py &
sleep 3
curl --location --verbose --head --insecure ${ONLINEFINDER_INTERNAL_HTTP}
EOF
    echo
    onlinefinder.instance.debug.off
}

onlinefinder.install.http.pre() {
    if ! onlinefinder.uwsgi.available; then
        rst_para "\
To install uWSGI use::

    $(basename "$0") install uwsgi
"
        die 42 "OnlineFinder's uWSGI app not available"
    fi

    if ! onlinefinder.instance.exec python -c "from searx import valkeydb; valkeydb.initialize() or exit(42)"; then
        rst_para "\
The configured valkey DB is not available: If your server is public to the
internet, you should setup a bot protection to block excessively bot queries.
Bot protection requires a valkey DB.  About bot protection visit the official
OnlineFinder documentation and query for the word 'limiter'.
"
    fi
}

onlinefinder.apache.install() {
    rst_title "Install Apache site ${APACHE_ONLINEFINDER_SITE}"
    rst_para "\
This installs OnlineFinder's uWSGI app as apache site.  The apache site is located at:
${APACHE_SITES_AVAILABLE}/${APACHE_ONLINEFINDER_SITE}."
    onlinefinder.install.http.pre

    if ! apache_is_installed; then
        err_msg "Apache packages are not installed"
        if ! ask_yn "Do you really want to continue and install apache packages?" Yn; then
            return
        else
            FORCE_SELECTION=Y install_apache
        fi
    else
        info_msg "Apache packages are installed [OK]"
    fi

    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        apache_install_site --variant=socket "${APACHE_ONLINEFINDER_SITE}"
    else
        apache_install_site "${APACHE_ONLINEFINDER_SITE}"
    fi

    if ! service_is_available "${ONLINEFINDER_URL}"; then
        err_msg "Public service at ${ONLINEFINDER_URL} is not available!"
    fi
}

onlinefinder.apache.remove() {
    rst_title "Remove Apache site ${APACHE_ONLINEFINDER_SITE}"
    rst_para "\
This removes apache site ${APACHE_ONLINEFINDER_SITE}::

  ${APACHE_SITES_AVAILABLE}/${APACHE_ONLINEFINDER_SITE}"

    ! apache_is_installed && err_msg "Apache is not installed."
    if ! ask_yn "Do you really want to continue?" Yn; then
        return
    fi
    apache_remove_site "${APACHE_ONLINEFINDER_SITE}"
}

onlinefinder.nginx.install() {

    rst_title "Install nginx site ${NGINX_ONLINEFINDER_SITE}"
    rst_para "\
This installs OnlineFinder's uWSGI app as Nginx site.  The Nginx site is located at:
${NGINX_APPS_AVAILABLE}/${NGINX_ONLINEFINDER_SITE} and requires a uWSGI."
    onlinefinder.install.http.pre

    if ! nginx_is_installed; then
        err_msg "Nginx packages are not installed"
        if ! ask_yn "Do you really want to continue and install Nginx packages?" Yn; then
            return
        else
            FORCE_SELECTION=Y install_nginx
        fi
    else
        info_msg "Nginx packages are installed [OK]"
    fi

    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        nginx_install_app --variant=socket "${NGINX_ONLINEFINDER_SITE}"
    else
        nginx_install_app "${NGINX_ONLINEFINDER_SITE}"
    fi

    if ! service_is_available "${ONLINEFINDER_URL}"; then
        err_msg "Public service at ${ONLINEFINDER_URL} is not available!"
    fi
}

onlinefinder.nginx.remove() {
    rst_title "Remove Nginx site ${NGINX_ONLINEFINDER_SITE}"
    rst_para "\
This removes Nginx site ${NGINX_ONLINEFINDER_SITE}::

  ${NGINX_APPS_AVAILABLE}/${NGINX_ONLINEFINDER_SITE}"

    ! nginx_is_installed && err_msg "Nginx is not installed."
    if ! ask_yn "Do you really want to continue?" Yn; then
        return
    fi
    nginx_remove_app "${NGINX_ONLINEFINDER_SITE}"
}

onlinefinder.instance.exec() {
    if ! service_account_is_available "${SERVICE_USER}"; then
        die 42 "can't execute: instance does not exist (missed account ${SERVICE_USER})"
    fi
    sudo -H -i -u "${SERVICE_USER}" \
        ONLINEFINDER_UWSGI_USE_SOCKET="${ONLINEFINDER_UWSGI_USE_SOCKET}" \
        "$@"
}

onlinefinder.instance.self.call() {
    # wrapper to call a function in instance's environment
    info_msg "wrapper:  utils/onlinefinder.sh instance _call $*"
    onlinefinder.instance.exec "${ONLINEFINDER_SRC}/utils/onlinefinder.sh" instance _call "$@"
}

onlinefinder.instance.get_setting() {
    onlinefinder.instance.exec python <<EOF
from searx import get_setting
print(get_setting('$1'))
EOF
}

onlinefinder.instance.debug.on() {
    warn_msg "Do not enable debug in a production environment!"
    info_msg "try to enable debug mode ..."
    tee_stderr 0.1 <<EOF | sudo -H -i 2>&1 | prefix_stdout "$_service_prefix"
cd ${ONLINEFINDER_SRC}
sed -i -e "s/debug: false/debug: true/g" "$ONLINEFINDER_SETTINGS_PATH"
EOF
    uWSGI_restart "$ONLINEFINDER_UWSGI_APP"
}

onlinefinder.instance.debug.off() {
    info_msg "try to disable debug mode ..."
    tee_stderr 0.1 <<EOF | sudo -H -i 2>&1 | prefix_stdout "$_service_prefix"
cd ${ONLINEFINDER_SRC}
sed -i -e "s/debug: true/debug: false/g" "$ONLINEFINDER_SETTINGS_PATH"
EOF
    uWSGI_restart "$ONLINEFINDER_UWSGI_APP"
}

onlinefinder.instance.inspect() {
    rst_title "Inspect OnlineFinder instance"
    echo

    onlinefinder.instance.self.call _onlinefinder.instance.inspect

    local _debug_on
    if ask_yn "Enable OnlineFinder debug mode?"; then
        onlinefinder.instance.debug.on
        _debug_on=1
    fi
    echo

    case $DIST_ID-$DIST_VERS in
        ubuntu-* | debian-*)
            # For uWSGI debian uses the LSB init process; for each configuration
            # file new uWSGI daemon instance is started with additional option.
            service uwsgi status "${SERVICE_NAME}"
            ;;
        arch-*)
            systemctl --no-pager -l status "uwsgi@${SERVICE_NAME%.*}"
            ;;
        fedora-*)
            systemctl --no-pager -l status uwsgi
            ;;
    esac

    echo -e "// use ${_BCyan}CTRL-C${_creset} to stop monitoring the log"
    read -r -s -n1 -t 5
    echo

    while true; do
        trap break 2
        case $DIST_ID-$DIST_VERS in
            ubuntu-* | debian-*) tail -f "/var/log/uwsgi/app/${SERVICE_NAME%.*}.log" ;;
            arch-*) journalctl -f -u "uwsgi@${SERVICE_NAME%.*}" ;;
            fedora-*) journalctl -f -u uwsgi ;;
        esac
    done

    if [[ $_debug_on == 1 ]]; then
        onlinefinder.instance.debug.off
    fi
    return 0
}

_onlinefinder.instance.inspect() {
    onlinefinder.instance.env

    MSG="${_Green}[${_BCyan}CTRL-C${_Green}] to stop or [${_BCyan}KEY${_Green}] to continue${_creset}"

    if ! onlinefinder.uwsgi.available; then
        err_msg "OnlineFinder's uWSGI app not available"
        wait_key
    fi
    if ! service_is_available "${ONLINEFINDER_URL}"; then
        err_msg "Public service at ${ONLINEFINDER_URL} is not available!"
        wait_key
    fi
}

onlinefinder.doc.rst() {

    local APACHE_SITES_AVAILABLE="/etc/apache2/sites-available"
    local NGINX_APPS_AVAILABLE="/etc/nginx/default.apps-available"

    local debian="${ONLINEFINDER_PACKAGES_debian}"
    local arch="${ONLINEFINDER_PACKAGES_arch}"
    local fedora="${ONLINEFINDER_PACKAGES_fedora}"
    local debian_build="${ONLINEFINDER_BUILD_PACKAGES_debian}"
    local arch_build="${ONLINEFINDER_BUILD_PACKAGES_arch}"
    local fedora_build="${ONLINEFINDER_BUILD_PACKAGES_fedora}"
    debian="$(echo "${debian}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"
    arch="$(echo "${arch}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"
    fedora="$(echo "${fedora}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"
    debian_build="$(echo "${debian_build}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"
    arch_build="$(echo "${arch_build}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"
    fedora_build="$(echo "${fedora_build}" | sed 's/.*/          & \\/' | sed '$ s/.$//')"

    if [[ ${ONLINEFINDER_UWSGI_USE_SOCKET} == true ]]; then
        uwsgi_variant=':socket'
    else
        uwsgi_variant=':socket'
    fi

    eval "echo \"$(<"${REPO_ROOT}/docs/build-templates/onlinefinder.rst")\""

    # I use ubuntu-20.04 here to demonstrate that versions are also supported,
    # normally debian-* and ubuntu-* are most the same.

    for DIST_NAME in ubuntu-20.04 arch fedora; do
        (
            DIST_ID=${DIST_NAME%-*}
            DIST_VERS=${DIST_NAME#*-}
            [[ $DIST_VERS =~ $DIST_ID ]] && DIST_VERS=
            uWSGI_distro_setup

            echo -e "\n.. START onlinefinder uwsgi-description $DIST_NAME"

            case $DIST_ID-$DIST_VERS in
                ubuntu-* | debian-*)
                    cat <<EOF

.. code:: bash

   # init.d --> /usr/share/doc/uwsgi/README.Debian.gz
   # For uWSGI debian uses the LSB init process, this might be changed
   # one day, see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=833067

   create     ${uWSGI_APPS_AVAILABLE}/${ONLINEFINDER_UWSGI_APP}
   enable:    sudo -H ln -s ${uWSGI_APPS_AVAILABLE}/${ONLINEFINDER_UWSGI_APP} ${uWSGI_APPS_ENABLED}/
   start:     sudo -H service uwsgi start   ${ONLINEFINDER_UWSGI_APP%.*}
   restart:   sudo -H service uwsgi restart ${ONLINEFINDER_UWSGI_APP%.*}
   stop:      sudo -H service uwsgi stop    ${ONLINEFINDER_UWSGI_APP%.*}
   disable:   sudo -H rm ${uWSGI_APPS_ENABLED}/${ONLINEFINDER_UWSGI_APP}

EOF
                    ;;
                arch-*)
                    cat <<EOF

.. code:: bash

   # systemd --> /usr/lib/systemd/system/uwsgi@.service
   # For uWSGI archlinux uses systemd template units, see
   # - http://0pointer.de/blog/projects/instances.html
   # - https://uwsgi-docs.readthedocs.io/en/latest/Systemd.html#one-service-per-app-in-systemd

   create:    ${uWSGI_APPS_ENABLED}/${ONLINEFINDER_UWSGI_APP}
   enable:    sudo -H systemctl enable   uwsgi@${ONLINEFINDER_UWSGI_APP%.*}
   start:     sudo -H systemctl start    uwsgi@${ONLINEFINDER_UWSGI_APP%.*}
   restart:   sudo -H systemctl restart  uwsgi@${ONLINEFINDER_UWSGI_APP%.*}
   stop:      sudo -H systemctl stop     uwsgi@${ONLINEFINDER_UWSGI_APP%.*}
   disable:   sudo -H systemctl disable  uwsgi@${ONLINEFINDER_UWSGI_APP%.*}

EOF
                    ;;
                fedora-* | centos-7)
                    cat <<EOF

.. code:: bash

   # systemd --> /usr/lib/systemd/system/uwsgi.service
   # The unit file starts uWSGI in emperor mode (/etc/uwsgi.ini), see
   # - https://uwsgi-docs.readthedocs.io/en/latest/Emperor.html

   create:    ${uWSGI_APPS_ENABLED}/${ONLINEFINDER_UWSGI_APP}
   restart:   sudo -H touch ${uWSGI_APPS_ENABLED}/${ONLINEFINDER_UWSGI_APP}
   disable:   sudo -H rm ${uWSGI_APPS_ENABLED}/${ONLINEFINDER_UWSGI_APP}

EOF
                    ;;
            esac
            echo -e ".. END onlinefinder uwsgi-description $DIST_NAME"

            local _show_cursor="" # prevent from prefix_stdout's trailing show-cursor

            echo -e "\n.. START onlinefinder uwsgi-appini $DIST_NAME"
            echo ".. code:: bash"
            echo
            eval "echo \"$(<"${TEMPLATES}/${uWSGI_APPS_AVAILABLE}/${ONLINEFINDER_UWSGI_APP}${uwsgi_variant}")\"" | prefix_stdout "  "
            echo -e "\n.. END onlinefinder uwsgi-appini $DIST_NAME"

            echo -e "\n.. START nginx socket"
            echo ".. code:: nginx"
            echo
            eval "echo \"$(<"${TEMPLATES}/${NGINX_APPS_AVAILABLE}/${NGINX_ONLINEFINDER_SITE}:socket")\"" | prefix_stdout "  "
            echo -e "\n.. END nginx socket"

            echo -e "\n.. START nginx http"
            echo ".. code:: nginx"
            echo
            eval "echo \"$(<"${TEMPLATES}/${NGINX_APPS_AVAILABLE}/${NGINX_ONLINEFINDER_SITE}")\"" | prefix_stdout "  "
            echo -e "\n.. END nginx http"

            echo -e "\n.. START apache socket"
            echo ".. code:: apache"
            echo
            eval "echo \"$(<"${TEMPLATES}/${APACHE_SITES_AVAILABLE}/${APACHE_ONLINEFINDER_SITE}:socket")\"" | prefix_stdout "  "
            echo -e "\n.. END apache socket"

            echo -e "\n.. START apache http"
            echo ".. code:: apache"
            echo
            eval "echo \"$(<"${TEMPLATES}/${APACHE_SITES_AVAILABLE}/${APACHE_ONLINEFINDER_SITE}")\"" | prefix_stdout "  "
            echo -e "\n.. END apache http"
        )
    done

}

# ----------------------------------------------------------------------------
main "$@"
# ----------------------------------------------------------------------------
