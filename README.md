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

The solution contains a set of Cloudformation templates, Shell scrpirts, ASP.NET published code and Jenkinsfiles. The code is written in the ASP.NET, Bash shell using the AWS CLI.

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
- AppSettings.json(file name-appsettings.json): This file stores custom application configuration information that includes RDS database connection strings, validation messages, logging information and security settings.
- LaunchSettings.json(file name-launchsettings.json): The launchSettings.json file is used to store the configuration information, which describes how to start the ASP.NET Core application, using visual studio. The file is used only during the development of the application using visual studio. It contains only those settings that are required to run the application.
- Tower API (file name-TowerAPIClass.cs): Tower API class is used to consume the service i.e. to get the data from the server requested by the client on the application. The service request is first authenticated and then a response is returned which contains the data to be displayed.
- LDAP (file name-LdapConnect.cs): This file is used for authorization and authentication. When the user enters credential to log into the WebApp, it is first validated for its authentication that whether it is valid or invalid.
- Controllers(file name-HomeController.cs): This file is used to direct the flow of data between the backend (i.e. database) and the front end.
- Scripts: This folder contains all the necessary plugins to run the application.
- Views: This folder contains all the .cshtml pages, i.e. webpages, that are viewed by the user on the WebApp. For example- Login page, Home page etc.

## Testing

The tests can be run on Linux or Mac OS X.

We can test the application on any browser. For example- chrome, IE, edge.
-	Step:1- Click on the link - https://geminiarchive-app-tst.gemini.awsnp.national.com.au/ to open the gemini archival web application. It will redirect you to the login page.
-	Step:2- Enter the correct credentials and click on sign in.
-	Step:3- If the credentials are correct, it will redirect you to the gemini search page. You can begin your search by entering the mandatory fields i.e. select any of the account level or advisor level or customer level. Enter the corresponding account id or advisor id or customer id. Choose either case creation date or case close date(by default case creation date is selected) and click on search to fetch the data.
-	Step:4- Along with the mandatory fields, you can also select from date and to date which are optional fields and click on search to fetch the data.
-	Step:5- The two tables will be displayed cases and documents respectively. By default, documents of the first case id will be displayed in the documents table. To see documents of any other case id , single click on that row of the cases table. To see the case activities of a particular case id, double click on that row of the cases table.
-	Step:6- To see the documents of a particular document id, single click on that row of the documents table.


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


