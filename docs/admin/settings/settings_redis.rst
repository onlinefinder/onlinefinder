.. _settings redis:

==========
``redis:``
==========

.. _Valkey: https://valkey.io

.. attention::

   OnlineFinder is switching from the Redis DB to Valkey_. The configuration
   description of Valkey_ in OnlineFinder can be found here: :ref:`settings
   <settings valkey>`.

If you have built and installed a local Redis DB for OnlineFinder, it is recommended
to uninstall it now and replace it with the installation of a Valkey_ DB.

.. _Redis Developer Notes:

Redis Developer Notes
=====================

To uninstall OnlineFinder's local Redis DB you can use:

.. code:: sh

   # stop your OnlineFinder instance
   $ ./utils/onlinefinder.sh remove.redis

Remove the Redis DB in your YAML setting:

.. code:: yaml

   redis:
     url: unix:///usr/local/onlinefinder-redis/run/redis.sock?db=0

To install Valkey_ read: :ref:`Valkey Developer Notes`
