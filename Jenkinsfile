elifeLibrary {
    def isNew
    def candidateVersion
    def commit

    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    node('containers-jenkins-plugin') {
        stage 'Build images', {
            checkout scm
            dockerComposeBuild(commit)
            candidateVersion = dockerComposeRun(
                "sciencebeam-alignment",
                "./print_version.sh",
                commit
            ).trim()
            echo "Candidate version: v${candidateVersion}"
        }

        stage 'Project tests', {
            dockerComposeRun(
                "sciencebeam-alignment",
                "./project_tests.sh",
                commit
            )
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

    }

    elifeMainlineOnly {
        stage 'Merge to master', {
            elifeGitMoveToBranch commit, 'master'
            if (isNew) {
                sh "git tag v${candidateVersion} && git push origin v${candidateVersion}"
            }
        }
    }
}
