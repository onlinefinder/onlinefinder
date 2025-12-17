.. _architecture:

============
Architecture
============

.. sidebar:: Further reading

   - Reverse Proxy: :ref:`Apache <apache onlinefinder site>` & :ref:`nginx <nginx
     onlinefinder site>`
   - uWSGI: :ref:`onlinefinder uwsgi`
   - OnlineFinder: :ref:`installation basic`

Herein you will find some hints and suggestions about typical architectures of
OnlineFinder infrastructures.

.. _architecture uWSGI:

uWSGI Setup
===========

We start with a *reference* setup for public OnlineFinder instances which can be build
up and maintained by the scripts from our :ref:`toolboxing`.

.. _arch public:

.. kernel-figure:: arch_public.dot
   :alt: arch_public.dot

   Reference architecture of a public OnlineFinder setup.

The reference installation activates ``server.limiter`` and
``server.image_proxy`` (:origin:`/etc/onlinefinder/settings.yml
<utils/templates/etc/onlinefinder/settings.yml>`)

.. literalinclude:: ../../utils/templates/etc/onlinefinder/settings.yml
   :language: yaml
   :end-before: # preferences:
