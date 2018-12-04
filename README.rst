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
_____________
*See* `pillar.example <pillar.example>`_. Be sure to override the appropriate
secrets, especially. You don't want to use the default values that are stored
openly in this github repo!

dewey.docker
------------
This state is a WIP.

This state will only spin up a postgres instance, and then allow you to
spin up the rest of the services via docker-compose.

The docker-compose.yml defines 5 services which comprise of:

- redis
- dewey
- dewey-celery-worker
- dewey-celery-scheduler
- dewey-celery-flower

In the example override file we also include postgres to ease development.

Configuration
_____________
In order to launch dewey we need to do a couple of things. First we need to
fill in some missing env vars with an override file. We've included an example
called `docker-compose.override.example.yml <docker-compose.override.example.yml>`_
so copy that to dewey/docker-compose.override.yml and edit the env vars there. 
You can also feel free to override any other docker Configuration values 
here as well.

You will need to manually create the super user, this step is faily simple.

.. code-block:: bash

  docker-compose run --rm --entrypoint /bin/sh dewey
  . /venvs/dewey/bin/activate
  dewey-manager createsuperuser
  exit

Now you can run dewey with docker-compose up. With this setup you should
be able to get to dewey via localhost:8080 and login with the super user
you setup earlier
