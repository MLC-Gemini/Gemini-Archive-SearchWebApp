<!-- vim: set ft=markdown: -->
<!-- DO NOT EDIT. Update using make docs -->
# Gemini Archive Web Application
This repo contains the Gemini archive web application and automation source code.

#### Table of contents

1. [Overview](#overview)
2. [Usage](#usage)
    * [bake.sh](#bake-sh)
    * [deploy_stack.sh](#deploy-stack-sh)
    * [delete_stack.sh](#delete-stack-sh)
3. [ASP.NET Code Overview](#Asp.NET-Code-Overview)
4. [Testing](#testing)

## Overview

The solution contains a set of Cloudformation templates, Shell scrpirts, ASP.NET published code and Jenkinsfiles. The code is written in the ASP.NET, Bash shell using the AWS CLI.

## Usage

Command line usage. Generally, these scripts are intended to be run from Jenkins jobs, whereas this section documents how they are run from the CLI.

### bake.sh

To use the bake.sh script:

```text
$ bash bake.sh -h
Usage: SOURCE_AMI={latest|ami-xxx} choice(name: 'Environment', choices: 'nonprod\nprod', description: 'Choose the envgroup to bake for') bake.sh [-h]
Bakes AMIs for stacks that require them
```

### deploy_stack.sh

To use the deploy_stack.sh script:

```text
$ bash deploy_stack.sh -h
Usage: STACK= choice(name: 'Environment', choices: 'nonprod\nprod', description: 'Choose the envgroup to bake for') deploy.sh [-h]
Deploys a Cloudformation stack
```

### delete_stack.sh

To use the delete_stack.sh script:

```text
$ bash delete_stack.sh -h
Usage: STACK= choice(name: 'Environment', choices: 'nonprod\nprod', description: 'Choose the envgroup to bake for') delete_stack.sh [-h] [--force, -f]
Deletes a Cloudformation stack
```

## Asp.NET-Code-Overview

Gemini Archive web application ASP.NET code overview.

## Testing

The tests can be run on Linux or Mac OS X.

Before running the tests, it is necessary to install these dependencies:

- Git (to clone this repo)
- AWS CLI (optional, for the validate-template command)
- Shellcheck
- jq
- yamllint (only for whitespace tests)



