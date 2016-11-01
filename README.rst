=============
dewey formula
=============

Installs dewey by debian package with salt.

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

dewey
-----
Installs all of Dewey's dependencies, and then installs Dewey itself. This
formula additionally relies on the following states:

- common.repos
- nginx
- postgres
- redis.master

Configuration
=============
*See* `pillar.example <pillar.example>`_. Be sure to override the appropriate
secrets, especially. You don't want to use the default values that are stored
openly in this github repo!
