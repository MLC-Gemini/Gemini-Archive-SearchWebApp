#!/usr/bin/env groovy

jobDsl scriptText:
"""
    pipelineJob("Gemini-Archive/cloudformation-deploy") { // Asset name in upper case
        properties {
            disableConcurrentBuilds()
        }

        displayName("Deploy a Cloudformation Stack")

        description('''
            This pipeline builds or updates a Cloudformation stack.
        ''')

        logRotator {
            numToKeep(10)
        }

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url("git@github.aus.thenational.com:Gemini/Gemini-Archive-SearchWebApp.git")
                            credentials('svc-account')
                        }
                        branches("master")
                    }
                }
                scriptPath("Jenkinsfile/deploy")
            }
        }
    }
"""
