#!/usr/bin/env groovy

jobDsl scriptText:
"""
    pipelineJob("Gemini/cloudformation-deploy") { // Asset name in upper case
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
                            url("git@github.aus.thenational.com:Gemini/gemini-data-nonprod.git")
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
