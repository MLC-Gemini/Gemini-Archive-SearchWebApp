<!-- vim: set ft=markdown: -->
<!-- DO NOT EDIT. Update using make docs -->
# Gemini Archive Web Application
This repo contains the Gemini archive web application and  automation source code.

#### Table of contents

1. [Overview](#overview)
2. [Usage](#usage)
    * [bake.sh](#bake-sh)
    * [deploy_stack.sh](#deploy-stack-sh)
    * [delete_stack.sh](#delete-stack-sh)
3. [ASP.NET Code Overview](#Asp.NET-Code-Overview)
4. [Testing](#testing)

## Overview

The solution contains a set of Cloudformation templates, Packer templates and Jenkinsfiles. The code is written in the Bash shell using the AWS CLI. There is also one small Python script, and a few lines of Ruby used in generating the docs.

## Usage

Command line usage. Generally, these scripts are intended to be run from Jenkins jobs, whereas this section documents how they are run from the CLI.

### bake.sh

To use the bake.sh script:

```text
$ bash bake.sh -h
Usage: SOURCE_AMI={latest|ami-xxx} ENVGROUP={nonprod} STACK={monitor|process|sleeper} bake.sh [-h] [-debug]
Bakes AMIs for stacks that require them
```

### deploy_stack.sh

To use the deploy_stack.sh script:

```text
$ bash deploy_stack.sh -h
Usage: STACK={monitor|process|sleeper|fileserver|cw|kms|s3} ENVGROUP={nonprod} [ENVIRONMENT={dev}] deploy_stack.sh [-h]
Deploys a Cloudformation stack
```

### delete_stack.sh

To use the delete_stack.sh script:

```text
$ bash delete_stack.sh -h
Usage: STACK={monitor|process|sleeper|fileserver|cw|kms|s3} ENVGROUP={nonprod} [ENVIRONMENT={dev}] delete_stack.sh [-h] [--force, -f]
Deletes a Cloudformation stack
```

## Asp.NET-Code-Overview

Gemini Archive web application ASP.NET code overview.

## Testing

The tests can be run on Linux or Mac OS X.

To run the tests, use make. To see the help message:

```text
$ make help
Usage:
  make <target>

Targets:
  help        Display this help
  include     Include the framework in ./include
  pull        Pull in updates in ./include
  check       Run the shellcheck tests
  unit        Run the shunit2 tests
  all         Run all the tests
  docs        Regenerate the README
```

Before running the tests, it is necessary to install these dependencies:

- Git (to clone this repo)
- AWS CLI (optional, for the validate-template command)
- shunit2
- Shellcheck
- jq
- yamllint (only for whitespace tests)
- Ruby (any system Ruby version, needed only to re-generate the README).

Note that shunit2 itself is expected to be an unreleased, patched version. Get it using:

```text
$ curl \
  https://github.com/kward/shunit2/blob/c47d32d6af2998e94bbb96d58a77e519b2369d76/shunit2 \
  /usr/local/bin/shunit2
```

For more information about the shunit2 testing methodology, see [this](https://alexharv074.github.io/2018/09/07/testing-aws-cli-scripts-in-shunit2.html) blog post.


