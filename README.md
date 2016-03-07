# B2DROP deployment recipes for puppet

[![Build Status](https://travis-ci.org/EUDAT-B2DROP/b2drop-puppet.svg?branch=master)](https://travis-ci.org/EUDAT-B2DROP/b2drop-puppet)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with b2drop](#setup)
    * [What b2drop affects](#what-b2drop-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with b2drop](#beginning-with-b2drop)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

## Module Description

This module interfaces with the owncloud module by shoekstra (shoekstra-owncloud) and
adds the repositories for b2drop to the apps and themes folder.

## Setup

### What b2drop affects

* apache, mysql, owncloud, php

### Beginning with b2drop

The following snippet will enable a all in one machine (LAMP stack + owncloud) on one server.
```puppet
    class { 'b2drop': }
```

## Usage

The `b2drop` class configures apache, mysql, owncloud and the repositories for the b2drop extensions.

## Example

To deploy B2DROP on a host, just add 
```
include ::b2drop
```
to the node and to hiera:
```
mysql::server::remove_default_accounts: true
owncloud::db_pass: 'somesecretpass'
owncloud::datadirectory: '/owncloud/data'
```

## Limitations

We are focussing on CentOS, other operating systems should work as well.

## Development

There are no formal requirements to participate.

## Testing

For testing, just execute 

mkdir vendor
export GEM_HOME=vendor
bundle install
bundle exec rake test