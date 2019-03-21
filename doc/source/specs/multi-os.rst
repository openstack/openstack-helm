..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

 http://creativecommons.org/licenses/by/3.0/legalcode

..

================
Multi-OS Support
================

Include the URL of your Storyboard RFE:

https://storyboard.openstack.org/#!/story/2005130

Problem Description
===================

Our :ref:`images documentation` documentation claims to be independent
of the image. However, some helm charts hard code paths of binaries,
executables' runtime configurations, etc. Therefore, the image agnostic
promise is broken.

We need to adapt all the helm charts to remove the hard-coded bits,
be image agnostic, to allow users to bring their own images.

Use cases
---------

Allow the usage of multiple base images in OSH.

Proposed Change
===============

Edit all helm charts to remove possible references to image specific elements,
replacing them with values overrides or conditionals.

It is important to notice that the helm charts can be split in two categories
for now:

#. Helm charts for which we use official upstream images.
   (Called further ``Category A`` helm charts)
#. Helm charts for which we are building images in osh-images.
   (Called further ``Category B`` helm charts)

For the ``Category B`` helm charts, an informal testing has been done in the
past to ensure image independence.
However, there is nothing exercising this independence in gates. Due to that,
code of the helm charts might or might not require adapting.

In all cases, we will need to provide different ``profiles``
(in other words, overrides), to test different image providers use cases in CI.

The ``profiles`` yaml files (for example ``centos_7``, ``opensuse_15``)
will be provided in each chart's ``example_values/`` directory.
This folder will be masked to helm through a helmignore file.
Its content is only for user consumption, not for inclusion in helm charts
through the File directive.
In other words, this is a user interface given for convenience merely using
the abilities of the existing helm charts.

The default ``values.yaml`` need to expose those abilities, by adding a new
series of keys/values to add the necessary features.

The existing schema for images is the following:

.. code-block:: yaml

   images:
     tags:
       imagename1: imagelocation:version-distro
       imagename2: imagelocation:version-distro
     pull_policy:
     local_registry:

For this spec, we assume ``imagename1`` and ``imagename2`` are similarly built.
This means we do not require any override per image. Instead we require a
generic kind of override, per application, usable by all charts.

I propose to extend the conf schema with generic software information.
For example, for apache2:

.. code-block:: yaml

   conf:
     software:
       apache2:
         #the apache2 binary location
         binary: apache2
         start_args: -DFOREGROUND
         stop_args: -k graceful-stop
         #directory where to drop the config files for apache vhosts
         conf_dir: /etc/apache2/conf-enabled
         sites_dir: /etc/apache2/sites-enabled


When possible, ``values_overrides/`` will refer to existing
``helm-toolkit`` functions to avoid repeating ourselves.

This approach:

* Proposes a common approach to software configuration, describing the
  distro/image specific differences for applications.
* Exposes security/configuration features of software, allowing deployers to
  configure software to their needs.
* Allows different profiles of apache, should some charts require different
  args for example for the same kind of images, by using yaml dict merges
  features.

Security Impact
---------------

No direct impact, as there is no change in the current software/configuration
location, merely a templating change.

Performance Impact
------------------

No benchmark was done to evaluate:

* the impact of exposing extra key/values in the helm chart ``values.yaml``
  file (could possibly have a deployment speed/ram usage increase).
* the impact of adding functionality in the ``helm-toolkit`` to deal with a
  common multi-distro aspect (could possibly increase helm chart rendering time)
* the impact of adding extra conditionals in the helm charts, to deal with
  multi-distro aspect (if not using the approach above, or when using an
  alternative approach)

The performance aspect of these point are restricted to deployment, and have
no performance impact on operations.

Alternatives
------------

* Not providing a support of multiple images. This leads to ease of
  maintainance and reduced gate impact, with the risk of having
  less contributors. For available overrides, users would have to provide
  many overrides themselves, while this spec proposes a common community
  approach.

* Create conditionals in the helm charts. This is problematic, as the amount
  of conditionals will increase and will be harder to maintain.
  Overrides files are easy to sync between charts.

* Only provide one way to configure software, and expect to always have the
  same versions. This is further away from the "image independent" contract,
  with extra burden: We will need to maintain a curated list of versions,
  deal with the differences of the defaults (selinux/apparmor profiles come to
  mind as path sensitive for example), and different expectations for
  operational teams ("The code is not where I expect it to be in the image").
  Embracing difference could even allow deployers to have different
  expectations for images, for example: apache+mod_wsgi vs uwsgi standalone
  or uwsgi + nginx.


Implementation
==============

Assignee(s)
-----------

Primary assignee:
  - evrardjp

Work Items
----------

This spec will be worked helm chart by helm chart, starting with keystone.

A few areas have been identified on changes required.
Each of them will be a work item.

#.  Make webserver binary path/arguments templated using ``values.yaml``.
    As expressed above, this allows us to provide different overrides per
    image/distribution to automatically wire things.
#.  Dynamically alter webserver environment conditionally in the helm chart.
    For example, for apache, ensure the necessary modules to run openstack
    are available and loaded at helm chart deploy time. This will leverage
    the binaries listed in ``values.yaml``.
    These series of commands are distribution/image dependent,
    as commands to list modules to load might differ.
    However with a few parameters, we can get a very distro independent
    process which would allow us to load all the required apache modules.
#.  Alter webserver configuration per distro. Different distros have different
    expectations in terms of path (including a different series of files
    required), and it would make the operators' life easier by using their
    expected distro paths.

Testing
=======

No change in testing is required, *per se*.
It is expected the new software configuration would be tested with the
current practices.

On top of that, the newly provided `example_values/` must
aim for being tested **as soon as possible upon delivery**. Without tests,
those examples will decrepit. The changes in CI pipelines for making use
of `example_values` is outside the scope of this spec.

Documentation Impact
====================

None more than this spec, as it should be relatively transparent for the
user. However, extra documentation to explain the usage of ``value_overrides``
would be welcomed.

References
==========

None
