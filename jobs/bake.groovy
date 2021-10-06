#!/usr/bin/env groovy

jobDsl scriptText:
"""
    pipelineJob("Gemini-Archive/packer-bake") {
        concurrentBuild(false)

        displayName("Bake an AMI")

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
                        extensions {
                            cleanBeforeCheckout()
                        }
                    }
                }
                scriptPath("Jenkinsfile/bake")
            }
        }
    }
"""
