#!/usr/bin/env groovy

jobDsl scriptText:
"""
    pipelineJob("Gemini-Web/cloudformation-deploy") { // Asset name in upper case
        concurrentBuild(false)

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
                        branches("Gemini_Dev")
                    }
                }
                scriptPath("Jenkinsfile/deploy")
            }
        }
    }
"""
