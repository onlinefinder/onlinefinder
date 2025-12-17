.. template evaluated by: ./utils/onlinefinder.sh onlinefinder.doc.rst
.. hint: all dollar-names are variables, dollar sign itself is quoted by: \\$

.. START distro-packages

.. tabs::

  .. group-tab:: Ubuntu / debian

    .. code-block:: sh

      $ sudo -H apt-get install -y \\
${debian}

  .. group-tab:: Arch Linux

    .. code-block:: sh

      $ sudo -H pacman -S --noconfirm \\
${arch}

  .. group-tab::  Fedora / RHEL

    .. code-block:: sh

      $ sudo -H dnf install -y \\
${fedora}

.. END distro-packages

.. START build-packages

.. tabs::

  .. group-tab:: Ubuntu / debian

    .. code-block:: sh

      $ sudo -H apt-get install -y \\
${debian_build}

  .. group-tab:: Arch Linux

    .. code-block:: sh

      $ sudo -H pacman -S --noconfirm \\
${arch_build}

  .. group-tab::  Fedora / RHEL

    .. code-block:: sh

      $ sudo -H dnf install -y \\
${fedora_build}

.. END build-packages

.. START create user

.. tabs::

  .. group-tab:: bash

    .. code-block:: sh

      $ sudo -H useradd --shell /bin/bash --system \\
          --home-dir \"$SERVICE_HOME\" \\
          --comment 'Privacy-respecting metasearch engine' \\
          $SERVICE_USER

      $ sudo -H mkdir \"$SERVICE_HOME\"
      $ sudo -H chown -R \"$SERVICE_GROUP:$SERVICE_GROUP\" \"$SERVICE_HOME\"

.. END create user

.. START clone onlinefinder

.. tabs::

  .. group-tab:: bash

    .. code-block:: sh

       $ sudo -H -u ${SERVICE_USER} -i
       (${SERVICE_USER})$ git clone \"$GIT_URL\" \\
                          \"$ONLINEFINDER_SRC\"

.. END clone onlinefinder

.. START create virtualenv

.. tabs::

  .. group-tab:: bash

    .. code-block:: sh

       (${SERVICE_USER})$ python3 -m venv \"${ONLINEFINDER_PYENV}\"
       (${SERVICE_USER})$ echo \". ${ONLINEFINDER_PYENV}/bin/activate\" \\
                          >>  \"$SERVICE_HOME/.profile\"

.. END create virtualenv

.. START manage.sh update_packages

.. tabs::

  .. group-tab:: bash

    .. code-block:: sh

       $ sudo -H -u ${SERVICE_USER} -i

       (${SERVICE_USER})$ command -v python && python --version
       $ONLINEFINDER_PYENV/bin/python
       Python 3.11.10

       # update pip's boilerplate ..
       pip install -U pip
       pip install -U setuptools
       pip install -U wheel
       pip install -U pyyaml
       pip install -U msgspec

       # jump to OnlineFinder's working tree and install OnlineFinder into virtualenv
       (${SERVICE_USER})$ cd \"$ONLINEFINDER_SRC\"
       (${SERVICE_USER})$ pip install --use-pep517 --no-build-isolation -e .


.. END manage.sh update_packages

.. START onlinefinder config

.. tabs::

  .. group-tab:: Use default settings

    .. code-block:: sh

       $ sudo -H mkdir -p \"$(dirname ${ONLINEFINDER_SETTINGS_PATH})\"
       $ sudo -H cp \"$ONLINEFINDER_SRC/utils/templates/etc/onlinefinder/settings.yml\" \\
                    \"${ONLINEFINDER_SETTINGS_PATH}\"

  .. group-tab:: minimal setup

    .. code-block:: sh

       $ sudo -H sed -i -e \"s/ultrasecretkey/\$(openssl rand -hex 16)/g\" \\
                     \"$ONLINEFINDER_SETTINGS_PATH\"

.. END onlinefinder config

.. START check onlinefinder installation

.. tabs::

  .. group-tab:: bash

    .. code-block:: sh

       # enable debug ..
       $ sudo -H sed -i -e \"s/debug : False/debug : True/g\" \"$ONLINEFINDER_SETTINGS_PATH\"

       # start webapp
       $ sudo -H -u ${SERVICE_USER} -i
       (${SERVICE_USER})$ cd ${ONLINEFINDER_SRC}
       (${SERVICE_USER})$ export ONLINEFINDER_SETTINGS_PATH=\"${ONLINEFINDER_SETTINGS_PATH}\"
       (${SERVICE_USER})$ python searx/webapp.py

       # disable debug
       $ sudo -H sed -i -e \"s/debug : True/debug : False/g\" \"$ONLINEFINDER_SETTINGS_PATH\"

Open WEB browser and visit http://$ONLINEFINDER_INTERNAL_HTTP .  If you are inside a
container or in a script, test with curl:

.. tabs::

  .. group-tab:: WEB browser

    .. code-block:: sh

       $ xdg-open http://$ONLINEFINDER_INTERNAL_HTTP

  .. group-tab:: curl

    .. code-block:: none

       $ curl --location --verbose --head --insecure $ONLINEFINDER_INTERNAL_HTTP

       *   Trying 127.0.0.1:8888...
       * TCP_NODELAY set
       * Connected to 127.0.0.1 (127.0.0.1) port 8888 (#0)
       > HEAD / HTTP/1.1
       > Host: 127.0.0.1:8888
       > User-Agent: curl/7.68.0
       > Accept: */*
       >
       * Mark bundle as not supporting multiuse
       * HTTP 1.0, assume close after body
       < HTTP/1.0 200 OK
       HTTP/1.0 200 OK
       ...

.. END check onlinefinder installation
