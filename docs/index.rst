==================
Welcome to OnlineFinder
==================

  *Search without being tracked.*

.. jinja:: searx

   OnlineFinder is a free internet metasearch engine which aggregates results from up
   to {{engines | length}} :ref:`search services <configured engines>`.  Users
   are neither tracked nor profiled.  Additionally, OnlineFinder can be used over Tor
   for online anonymity.

Get started with OnlineFinder by using one of the instances listed at searx.space_.
If you don't trust anyone, you can set up your own, see :ref:`installation`.

.. jinja:: searx

   .. sidebar::  features

      - :ref:`self hosted <installation>`
      - :ref:`no user tracking / no profiling <OnlineFinder protect privacy>`
      - script & cookies are optional
      - secure, encrypted connections
      - :ref:`{{engines | length}} search engines <configured engines>`
      - `58 translations <https://translate.codeberg.org/projects/onlinefinder/onlinefinder/>`_
      - about 70 `well maintained <https://uptime.onlinefinder.org/>`__ instances on searx.space_
      - :ref:`easy integration of search engines <demo online engine>`
      - professional development: `CI <https://github.com/onlinefinder/onlinefinder/actions>`_,
	`quality assurance <https://dev.onlinefinder.org/>`_ &
	`automated tested UI <https://dev.onlinefinder.org/screenshots.html>`_

.. sidebar:: be a part

   OnlineFinder is driven by an open community, come join us!  Don't hesitate, no
   need to be an *expert*, everyone can contribute:

   - `help to improve translations <https://translate.codeberg.org/projects/onlinefinder/onlinefinder/>`_
   - `discuss with the community <https://matrix.to/#/#onlinefinder:matrix.org>`_
   - report bugs & suggestions
   - ...

.. sidebar:: the origin

   OnlineFinder development has been started in the middle of 2021 as a fork of the
   searx project.


.. toctree::
   :maxdepth: 2

   user/index
   own-instance
   admin/index
   dev/index
   utils/index
   src/index


----------------
Acknowledgements
----------------

The following organizations have provided OnlineFinder access to their paid plans at
no cost:

.. flat-table::
   :widths: 1 1

   * - .. image:: /assets/sponsors/docker.svg
          :target: https://docker.com
          :alt: Docker
          :align: center
          :height: 100 px

     - .. image:: /assets/sponsors/tuta.svg
          :target: https://tuta.com
          :alt: Tuta
          :align: center
          :height: 100 px

   * - .. image:: /assets/sponsors/browserstack.svg
          :target: https://browserstack.com
          :alt: BrowserStack
          :align: center
          :height: 100 px


.. _searx.space: https://searx.space
