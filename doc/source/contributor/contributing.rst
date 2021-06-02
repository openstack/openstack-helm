============================
So You Want to Contribute...
============================

For general information on contributing to OpenStack, please check out the
`contributor guide <https://docs.openstack.org/contributors/>`_ to get started.
It covers all the basics that are common to all OpenStack projects: the accounts
you need, the basics of interacting with our Gerrit review system, how we
communicate as a community, etc.

Additional information could be found in
`OpenDev Developer's Guide
<https://docs.opendev.org/opendev/infra-manual/latest/developers.html>`_.

Below will cover the more project specific information you need to get started
with OpenStack-Helm infra.

Communication
~~~~~~~~~~~~~
.. This would be a good place to put the channel you chat in as a project; when/
   where your meeting is, the tags you prepend to your ML threads, etc.

* Join us on `IRC <irc://chat.oftc.net/openstack-helm>`_:
  #openstack-helm on oftc
* Community `IRC Meetings
  <http://eavesdrop.openstack.org/#OpenStack-Helm_Team_Meeting>`_:
  [Every Tuesday @ 3PM UTC], #openstack-meeting-alt on oftc
* Meeting Agenda Items: `Agenda
  <https://etherpad.openstack.org/p/openstack-helm-meeting-agenda>`_
* Join us on `Slack <https://kubernetes.slack.com/messages/C3WERB7DE/>`_
  - #openstack-helm

Contacting the Core Team
~~~~~~~~~~~~~~~~~~~~~~~~
.. This section should list the core team, their irc nicks, emails, timezones
   etc. If all this info is maintained elsewhere (i.e. a wiki), you can link to
   that instead of enumerating everyone here.

Project's Core Team could be contacted via IRC or Slack, usually during weekly
meetings. List of current Cores could be found on a Members tab of
`openstack-helm-infra-core <https://review.opendev.org/#/admin/groups/1795,info>`_
Gerrit group.

New Feature Planning
~~~~~~~~~~~~~~~~~~~~
.. This section is for talking about the process to get a new feature in. Some
   projects use blueprints, some want specs, some want both! Some projects
   stick to a strict schedule when selecting what new features will be reviewed
   for a release.

New features are planned and implemented trough the process described in
`Project Specifications <https://docs.openstack.org/openstack-helm/latest/specs/index.html>`_
section of OpenStack-Helm documents.

Task Tracking
~~~~~~~~~~~~~
.. This section is about where you track tasks- launchpad? storyboard? is there
   more than one launchpad project? what's the name of the project group in
   storyboard?

We track our tasks on our StoryBoard_.

If you're looking for some smaller, easier work item to pick up and get started
on, search for the 'low-hanging-fruit' tag.

.. NOTE: If your tag is not 'low-hanging-fruit' please change the text above.

Other OpenStack-Helm component's tasks could be found on the `group Storyboard`_.

Reporting a Bug
~~~~~~~~~~~~~~~
.. Pretty self explanatory section, link directly to where people should report
   bugs for your project.

You found an issue and want to make sure we are aware of it? You can do so on our
Storyboard_.

If issue is on one of other OpenStack-Helm components, report it to the
appropriate `group Storyboard`_.

Bugs should be filed as stories in Storyboard, not GitHub.

Getting Your Patch Merged
~~~~~~~~~~~~~~~~~~~~~~~~~
.. This section should have info about what it takes to get something merged. Do
   you require one or two +2's before +W? Do some of your repos require unit
   test changes with all patches? etc.

We require two Code-Review +2's from reviewers, before getting your patch merged
with giving Workforce +1. Trivial patches (e.g. typos) could be merged with one
Code-Review +2.

Changes affecting code base often require CI tests and documentation to be added
in the same patch set.

Pull requests submitted through GitHub will be ignored.

Project Team Lead Duties
~~~~~~~~~~~~~~~~~~~~~~~~
.. this section is where you can put PTL specific duties not already listed in
   the common PTL guide (linked below), or if you already have them written
   up elsewhere you can link to that doc here.

All common PTL duties are enumerated in the `PTL guide
<https://docs.openstack.org/project-team-guide/ptl.html>`_.

.. _Storyboard: https://storyboard.openstack.org/#!/project/openstack/openstack-helm-infra
.. _group Storyboard: https://storyboard.openstack.org/#!/project_group/64
