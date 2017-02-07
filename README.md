# B2DROP deployment recipes for puppet

[![Build Status](https://travis-ci.org/EUDAT-B2DROP/b2drop-puppet.svg?branch=master)](https://travis-ci.org/EUDAT-B2DROP/b2drop-puppet)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with b2drop](#setup)
    * [What puppet-b2drop affects](#what-puppet-b2drop-affects)
    * [Beginning with b2drop](#beginning-with-b2drop)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
5. [Testing - Instructions to test the code](#testing)


## Module Description

This module interfaces with the owncloud module by shoekstra (shoekstra-owncloud) and
adds the repositories for b2drop to the apps and themes folder.

## Setup

On your puppet master, go to the environment that the actual b2drop server belongs to.
Inside of the module directory of that environment simply clone this repository
```
git clone https://github.com/EUDAT-B2DROP/b2drop-puppet.git b2drop 
```


### What puppet-b2drop affects

* mysql, owncloud, php7, cron, tmp

### Beginning with b2drop

The following snippet will enable a all in one machine (LAMP stack + owncloud) on one server.
```puppet
    class { 'b2drop': }
```
## Usage

The `b2drop` class configures mysql, owncloud and the repositories for the b2drop extensions.

To deploy B2DROP on a host, just add 
```
include ::b2drop
```
to the node and add missing variables

## Limitations

We are focussing on CentOS, other operating systems should work as well.

## Development

There are no formal requirements to participate. If there are questions, feel free to contact the authors mentioned in AUTHORS.md

## Testing

For testing the code with puppet utils, make sure you have ruby and bundler installed  and then execute:

```
mkdir vendor
export GEM_HOME=vendor
bundle install
bundle exec rake test
```