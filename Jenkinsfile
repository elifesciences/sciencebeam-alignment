elifePipeline {
    def isNew
    def candidateVersion
    def commit

    node('containers-jenkins-plugin') {
        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }

        stage 'Build and run tests', {
            try {
                sh "make IMAGE_TAG=${commit} REVISION=${commit} ci-build-and-test"
            } finally {
                sh "make ci-clean"
            }
        }

        stage 'Get candidate version', {
            candidateVersion = dockerComposeRunAndCaptureOutput(
                "sciencebeam-alignment",
                "./print_version.sh",
                commit
            ).trim()
            echo "Candidate version: v${candidateVersion}"
        }

        elifeMainlineOnly {
            stage 'Push release', {
                isNew = sh(script: "git tag | grep v${candidateVersion}", returnStatus: true) != 0
                if (isNew) {
                    dockerComposeRun(
                        "sciencebeam-alignment",
                        "twine upload dist/*",
                        commit
                    )
                }
            }
        }

        elifeMainlineOnly {
            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
                if (isNew) {
                    sh "git tag v${candidateVersion} && git push origin v${candidateVersion}"
                }
            }
        }

        elifePullRequestOnly { prNumber ->
            stage 'Push package to test.pypi.org', {
                withPypiCredentials 'staging', 'testpypi', {
                    sh "make IMAGE_TAG=${commit} COMMIT=${commit} NO_BUILD=y ci-push-testpypi"
                }
            }
        }
    }
}
