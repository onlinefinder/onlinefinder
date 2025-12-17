.. _onlinefinder maintenance:

===================
OnlineFinder maintenance
===================

.. sidebar:: further read

   - :ref:`toolboxing`
   - :ref:`uWSGI maintenance`

.. contents::
   :depth: 2
   :local:
   :backlinks: entry

.. _update onlinefinder:

How to update
=============

How to update depends on the :ref:`installation` method.  If you have used the
:ref:`installation scripts`, use the ``update`` command from the :ref:`onlinefinder.sh`
script.

.. code:: sh

    sudo -H ./utils/onlinefinder.sh instance update

.. _inspect onlinefinder:

How to inspect & debug
======================

How to debug depends on the :ref:`installation` method.  If you have used the
:ref:`installation scripts`, use the ``inspect`` command from the :ref:`onlinefinder.sh`
script.

.. code:: sh

    sudo -H ./utils/onlinefinder.sh instance inspect

.. _migrate and stay tuned:

Migrate and stay tuned!
=======================

.. sidebar:: info

   - :pull:`1332`
   - :pull:`456`
   - :pull:`A comment about rolling release <446#issuecomment-954730358>`

OnlineFinder is a *rolling release*; each commit to the master branch is a release.
OnlineFinder is growing rapidly, the services and opportunities are change every now
and then, to name just a few:

- Bot protection has been switched from filtron to OnlineFinder's :ref:`limiter
  <limiter>`, this requires a :ref:`Valkey <settings valkey>` database.

To stay tuned and get in use of the new features, instance maintainers have to
update the OnlineFinder code regularly (see :ref:`update onlinefinder`).  As the above
examples show, this is not always enough, sometimes services have to be set up
or reconfigured and sometimes services that are no longer needed should be
uninstalled.

Here you will find a list of changes that affect the infrastructure.  Please
check to what extent it is necessary to update your installations:

:pull:`1595`: ``[fix] uWSGI: increase buffer-size``
  Re-install uWSGI (:ref:`onlinefinder.sh`) or fix your uWSGI ``onlinefinder.ini``
  file manually.


Check after Installation
------------------------

Once you have done your installation, you can run a OnlineFinder *check* procedure,
to see if there are some left overs.  In this example there exists a *old*
``/etc/olf/settings.yml``::

   $ sudo -H ./utils/onlinefinder.sh instance check

   OnlineFinder checks
   --------------
   ERROR: settings.yml in /etc/olf/ is deprecated, move file to folder /etc/onlinefinder/
   ...
   INFO    searx.valkeydb                 : connecting to Valkey db=0 path='/usr/local/onlinefinder-valkey/run/valkey.sock'
   INFO    searx.valkeydb                 : connected to Valkey
