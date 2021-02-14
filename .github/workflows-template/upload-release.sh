#!/bin/bash

GITHUB_REPO_OWNER=${GITHUB_REPOSITORY%/*}
GITHUB_REPO_NAME=${GITHUB_REPOSITORY#*/}

MAVEN_UPLOAD_URL=${MAVEN_UPLOAD_URL//%%GITHUB_ACTOR%%/$GITHUB_ACTOR}
MAVEN_UPLOAD_URL=${MAVEN_UPLOAD_URL//%%GITHUB_REPO_OWNER%%/$GITHUB_REPO_OWNER}
MAVEN_UPLOAD_URL=${MAVEN_UPLOAD_URL//%%GITHUB_REPO_NAME%%/$GITHUB_REPO_NAME}

cd target/checkout
mvn ${MVN_CLI_ARGS} --settings "${MAVEN_SETTINGS_FILE}" verify source:jar javadoc:jar deploy:deploy \
		-Duploading \
		-DskipTests \
		-DaltDeploymentRepository="${MAVEN_UPLOAD_ID}::${MAVEN_UPLOAD_URL}"
