# Template for a simple Maven project

This is a template repository for simple Maven projects (POM projects, libraries, or simply standalone applications). It consists of the usual Maven directory structure, a template POM file, and some workflow files for GitHub Actions that define how to build, verify, distribute, and release the project.

This readme file describes the underlying concepts and the first necessary steps after creating a new repository based on this template.

## Branching model

The workflows assume a branching model that is somewhat inspired by the [git-flow branching model](https://nvie.com/posts/a-successful-git-branching-model/), but much less complicated.

The `develop` branch is the default development branch. It should always contain a potentially releasable version of the software. Each actual development should take place in a feature or bugfix branch (e.g. `feature/...` or `bugfix/...` or whatever). Finished work should then simply be merged into the `develop` branch, usually via a pull request. For releasing, a release branch should be used. This can be done by the corresponding workflows (see below).

## Versioning concept

Some of the workflows depend on a correct versioning in the POM of the project. In the `develop` branch this version should always have a major and a minor version, but no patch version; i.e. `1.0-SNAPSHOT`. The same holds true for any feature or bugfix branch. For the release branches, the below mentioned workflows will take care of the versioning.

## Workflow concepts

The workflow `Build and verify` (see file `build-and-verify.yaml`) simply runs a `mvn verify` command after a push to any branch that is not `develop` or `release/*` , i.e. for feature or bugfix branches.

The workflow `Build and distribute`  (see file `build-and-distribute.yaml`) simply runs a `mvn deploy` command after a push to the `develop` branch or to any `release/*` branch. The generated snapshot artifacts are deployed to GitHub Packages by default (see below).

The workflow `Prepare release` (see file `prepare-release.yaml`) can only be triggered manually for the `develop` branch. It first creates a new branch `release/x.y`, based on the POM's current snapshot version number (`x.y-SNAPSHOT`). Then it increments the POM's minor version in the `develop` branch, so it ends up with `x.(y++)-SNAPSHOT`.

The workflow `Perform release` (see file `perform-release.yaml`) can only be triggered manually for a `release/...` branch. It first uses the [Maven release plugin](https://maven.apache.org/maven-release/maven-release-plugin/) to actually do the release (incl. tagging). The generated release artifacts are deployed to GitHub Packages by default (see below). The patch version in the POM is also incremented, so it ends up with `x.y.(z++)-SNAPSHOT`. This all takes place in the current `release/...` branch. Additionally, this workflow can generate site documentation and deploy it to GitHub Pages (see below).

## First steps

After creating a new repository based on this template, you need to do some initializing steps.

### Setup in GitHub

Besides doing some basic settings (like "Wikis", "Projects", "Issues", "Merge buttons", etc.), you need to add the following repository secret:

	GH_WORKFLOW_TOKEN

This must be a personal access token with the scopes `repo` and `write:packages`. It is used in some workflows instead of `GITHUB_TOKEN` (which is provided by GitHub) because the latter does not trigger new workflows after pushing code changes with it.

### Source code adjustments

Replace the following placeholders with their actual values in the files `pom.xml` and `LICENSE`:

	%%PROJECT_GROUP_ID%%
	%%PROJECT_ARTIFACT_ID%%
	%%PROJECT_VERSION%%
	%%PROJECT_NAME%%
	%%PROJECT_DESCRIPTION%%
	%%REPO_OWNER%%
	%%REPO_NAME%%
	%%YEAR%%
	%%NAME%%

Then rename the directory `.github/workflows-template` to `.github/workflows`.

Additionally, you can/should do the following steps:

- The POM contains some out-commented sections. You should add the needed information there or consider removing those sections.
- For POM projects the `src` folder might not be needed. Consider to delete it.
- Because this file (`README.md`) is also copied, you should consider to delete this file or at least change its content.
- Check whether the license fits your needs or should be replaced with a more appropriate one. The license is mentioned in two places: in the `LICENSE` file and in the `<licenses>` section in the POM.

### Upload to a custom Maven repository manager

The Maven goals in the workflows upload the generated artifacts to GitHub Packages by default. If you want to upload them to a custom Maven repository manager, you need to add the following repository secrets:

	USE_CUSTOM_MAVEN_DISTRIBUTION
	MAVEN_DISTRIBUTION_SNAPSHOTS_URL
	MAVEN_DISTRIBUTION_RELEASES_URL
	MAVEN_DISTRIBUTION_USERNAME
	MAVEN_DISTRIBUTION_PASSWORD

The `USE_CUSTOM_MAVEN_DISTRIBUTION` must be a boolean value, so simply set it to `true`. The username and password are used for both URLs.

See the workflows `Build and distribute` and `Perform release` for more details.

### Site deployment

The generation and deployment of the site documentation is disabled by default in the `Perform release` workflow. If you need site documentation, you should consider setting the default value of the action input `doSiteDeployment` to `true`.

If enabled, you also must enable the `gh-pages` branch, because this is where the generated site documentation will be deployed to. Note that this only works for public GitHub repositories. You can activate this branch by simply choosing a site theme in the repository settings.
