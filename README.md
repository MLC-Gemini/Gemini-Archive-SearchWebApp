<!-- vim: set ft=markdown: -->
<!-- DO NOT EDIT. Update using make docs -->
# Gemini Archive Web Application
This repo contains the Gemini archive web application and  Jenkins deployment automation source code.

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
Usage:ENVGROUP={nonprod} bake.sh [-h] [-debug]
Bakes AMIs for stacks that require them
```

### deploy_stack.sh

To use the deploy_stack.sh script:

```text
$ bash deploy_stack.sh -h
Usage: STACK= ENVGROUP={nonprod} deploy_stack.sh [-h]
Deploys a Cloudformation stack
```

### delete_stack.sh

To use the delete_stack.sh script:

```text
$ bash delete_stack.sh -h
Usage: STACK=ENVGROUP={nonprod} elete_stack.sh [-h] [--force, -f]
Deletes a Cloudformation stack
```

## Asp.NET-Code-Overview

Gemini Archive web application ASP.NET code overview.
- appsettings.json: This file stores custom application configuration information that includes RDS database connection strings, AD groups, Tibco ImageEBF service account details, validation messages, logging information and security settings.
- launchsettings.json: The launchSettings.json file is used to store the configuration information, which describes how to start the ASP.NET Core application, using visual studio. The file is used only during the development of the application using visual studio. It contains only those settings that are required to run the application.
- Tower API (TowerAPIClass.cs): Tower API class is used to consume the service i.e. to get the data from the server requested by the client on the application. The service request is first authenticated and then a response is returned which contains the data to be displayed.
- LDAP (LdapConnect.cs): This file is used for authorization and authentication. When the user enters credential to log into the WebApp, it is first validated for its authentication that whether it is valid or invalid.
- Controllers(HomeController.cs): This file is used to direct the flow of data between the backend (i.e. database) and the front end.
- Scripts: This folder contains all the necessary plugins to run the application.
- Views: This folder contains all the .cshtml pages, i.e. webpages, that are viewed by the user on the WebApp. For example- Login page, Home page etc.

## Testing

The test can be done on any web browser for example- chrome, IE, edge.

-	The test can be done on any web browser for example- chrome, IE, edge.

- To open the gemini archival web application in web browser, click on the application url link as per environment -
NonProd - https://geminiarchive-app-tst.gemini.awsnp.national.com.au

Prod - https://geminiarchive-app-prod.gemini.awsnp.national.com.au 

It will redirect you to the login page.

- Enter the correct credentials (AURDEV for Nnonprod and AUR for prod) and click on sign in.
- If the credentials are correct, it will redirect you to the gemini search page. You can begin your search by entering the mandatory fields i.e. select any of the account level or advisor level or customer level. Enter the corresponding account id or advisor id or customer id. Choose either case creation date or case close date(by default case creation date is selected) and click on search to fetch the data.
- Along with the mandatory fields, you can also select from date and to date which are optional fields and click on search to fetch the data.
- The two tables will be displayed cases and documents respectively. By default, documents of the first case id will be displayed in the documents table. To see documents of any other case id , single click on that row of the cases table. To see the case activities of a particular case id, double click on that row of the cases table.
- To see the documents of a particular document id, single click on that row of the documents table.

For more information visit knowledge document confluence page - https://confluence.mlc.lz182.aws.national.com.au/display/WWF/BAU+Support+Handover


