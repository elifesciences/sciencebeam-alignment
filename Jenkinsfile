import groovy.json.JsonSlurper

@NonCPS
def jsonToPypirc(String jsonText, String sectionName) {
    def credentials = new JsonSlurper().parseText(jsonText)
    echo "Username: ${credentials.username}"
    return "[${sectionName}]\nusername: ${credentials.username}\npassword: ${credentials.password}"
}

def withPypiCredentials(String env, String sectionName, doSomething) {
    try {
        writeFile(file: '.pypirc', text: jsonToPypirc(sh(
            script: "vault.sh kv get -format=json secret/containers/pypi/${env} | jq .data.data",
            returnStdout: true
        ).trim(), sectionName))
        doSomething()
    } finally {
        sh 'echo > .pypirc'
    }
}

elifePipeline {
    node('containers-jenkins-plugin') {
        def commit
        def version

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }

        stage 'Build and run tests', {
            if (env.TAG_NAME) {
                version = env.TAG_NAME - 'v'
            } else {
                version = 'develop'
            }
            try {
                sh "make IMAGE_TAG=${commit} REVISION=${commit} VERSION=${version} ci-build-and-test ci-verify-version"
            } finally {
                sh "make ci-clean"
            }
        }

        elifeMainlineOnly {
            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
            }
        }

        elifePullRequestOnly { prNumber ->
            stage 'Push package to test.pypi.org', {
                withPypiCredentials 'staging', 'testpypi', {
                    sh "make IMAGE_TAG=${commit} COMMIT=${commit} NO_BUILD=y ci-push-testpypi"
                }
            }
        }

        elifeTagOnly { tag ->
            stage 'Push release', {
                withPypiCredentials 'prod', 'pypi', {
                    sh "make IMAGE_TAG=${commit} VERSION=${version} NO_BUILD=y ci-push-pypi"
                }
            }
        }
    }
}
