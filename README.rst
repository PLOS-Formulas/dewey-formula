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
*See* `pillar.example <pillar.exaple>`_
