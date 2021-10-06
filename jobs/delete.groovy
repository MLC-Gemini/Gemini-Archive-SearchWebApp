#!/usr/bin/env groovy

jobDsl scriptText:
"""
    pipelineJob("Gemini-Archive/cloudformation-delete") {
        concurrentBuild(false)

        displayName("Delete a Cloudformation Stack")

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
                scriptPath("Jenkinsfile/delete")
            }
        }
    }
"""
