

**TestingCadence**  
Garmin Connect IQ Smartwatch Application

**CI/CD Pipeline Documentation**

Deployment Sub-Team  
Deakin University — SIT764 Capstone Project

SDK: Garmin Connect IQ 8.3.0  |  API Level: 3.2.0 / 3.3.0  |  Target: Forerunner 245 / 245M

# **1\. Introduction**

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for the TestingCadence project. TestingCadence is a Garmin Connect IQ smartwatch application built in MonkeyC that provides real-time running cadence monitoring and calculates a Cadence Quality (CQ) score for Forerunner 245 and 245M devices.

The CI/CD pipeline automates the build, validation, and release processes, ensuring that every change merged to the main branch produces a verified, deployable artefact without manual intervention. The pipeline is owned and maintained by the Deployment Sub-Team.

## **1.1 Objectives**

* Automate compilation of MonkeyC source code for all target devices on every push to main  
* Enforce code quality gates through branch protection rules before any merge  
* Produce signed, versioned .prg build artefacts for Forerunner 245 and 245M  
* Automate release note generation for each tagged release  
* Provide a reproducible, containerised build environment via Docker

## **1.2 Scope**

This document covers:

* Pipeline architecture and tool stack  
* GitHub Actions workflow definitions  
* Branch strategy and protection rules  
* Build, test, and release stages  
* Secret and credential management  
* Artefact handling and versioning  
* Pipeline monitoring and failure response

# **2\. Pipeline Architecture Overview**

The TestingCadence CI/CD pipeline is hosted entirely on GitHub Actions and follows a linear stage model: Code → Build → Validate → Artefact → Release. All stages execute inside a Docker container that encapsulates the Garmin Connect IQ SDK 8.3.0, eliminating environment inconsistencies across runners.

  Developer Push / PR

        │

        ▼

 ┌────────────────────────────────┐

 │       GitHub Actions Runner          │

 │                                    │

 │  \[1\] Checkout source code           │

 │        │                           │

 │        ▼                           │

 │  \[2\] Build Docker image (SDK 8.3.0) │

 │        │                           │

 │        ▼                           │

 │  \[3\] Compile MonkeyC (.prg output)  │

 │        │                           │

 │        ▼                           │

 │  \[4\] Upload build artefact          │

 │        │                           │

 │        ▼  (on git tag push only)    │

 │  \[5\] Generate release notes         │

 │  \[6\] Create GitHub Release          │

 └────────────────────────────────┘

# **3\. Tool Stack**

| Tool / Service | Version / Plan | Role in Pipeline |
| :---- | :---- | :---- |
| GitHub | Free / Team | Source control, Actions runner, Releases |
| GitHub Actions | Latest | CI/CD workflow automation |
| Docker | 24.x | Containerised SDK build environment |
| Garmin Connect IQ SDK | 8.3.0 | MonkeyC compiler and device definitions |
| OpenJDK | 11 | SDK runtime dependency inside container |
| MonkeyC Compiler (monkeyc) | SDK-bundled | Compiles source to .prg device binary |
| GitHub Secrets | N/A | Secure storage for developer key |
| actions/checkout | v4 | Repository checkout in workflow |
| actions/upload-artifact | v4 | Artefact storage between jobs |
| docker/setup-buildx-action | v3 | Docker Buildx setup for CI runner |

# **4\. Branch Strategy and Protection Rules**

The TestingCadence repository follows a structured branching model enforced through GitHub branch protection rules configured by the Deployment Sub-Team.

## **4.1 Branch Model**

| Branch | Purpose | Pipeline Trigger |
| :---- | :---- | :---- |
| main | Production-ready, deployable code. Protected branch. | Build \+ Artefact \+ Release (on tag) |
| develop | Integration branch for completed features. | Build only |
| feature/\* | Individual feature or fix branches. | None (local only) |
| hotfix/\* | Urgent fixes applied directly off main. | Build on PR to main |
| release/\* | Release preparation branches. | Build \+ Artefact on PR to main |

## **4.2 Branch Protection Rules (main)**

The following protection rules are active on the main branch:

* Require pull request before merging — direct pushes to main are blocked  
* Require at least 1 approving review before merge  
* Dismiss stale pull request approvals when new commits are pushed  
* Require status checks to pass before merging (CI build workflow must succeed)  
* Require branches to be up to date before merging  
* Restrict who can push to main — Deployment Sub-Team Lead only  
* Do not allow bypassing the above settings

**NOTE:** *These rules were configured by the Deployment Sub-Team Lead in coordination with Tharun Chakrapani Venkatesh (Deployment Team Member).*

# **5\. GitHub Actions Workflow Definitions**

All workflows are stored under .github/workflows/ in the repository root. Two primary workflows are defined:

* **build.yml — triggered on push/PR to main and develop**  
* **release.yml — triggered on version tag push (v\*.\*.\*)**

## **5.1 Build Workflow (build.yml)**

Runs on every push to main or develop, and on all pull requests targeting main. Compiles the MonkeyC source for both target devices inside the Docker container.

name: TestingCadence CI Build

on:

  push:

    branches:

      \- main

      \- develop

  pull\_request:

    branches:

      \- main

jobs:

  build:

    name: Build MonkeyC Application

    runs-on: ubuntu-latest

    steps:

      \- name: Checkout source code

        uses: actions/checkout@v4

      \- name: Set up Docker Buildx

        uses: docker/setup-buildx-action@v3

      \- name: Build Docker image with SDK

        run: |

          docker build \\

            \--build-arg DEVELOPER\_KEY=${{ secrets.GARMIN\_DEVELOPER\_KEY }} \\

            \-t testingcadence-build:${{ github.sha }} .

      \- name: Compile for Forerunner 245

        run: |

          mkdir \-p bin

          docker run \--rm \\

            \-v ${{ github.workspace }}/bin:/workspace/bin \\

            \-e TARGET=fr245 \\

            testingcadence-build:${{ github.sha }}

      \- name: Compile for Forerunner 245M

        run: |

          docker run \--rm \\

            \-v ${{ github.workspace }}/bin:/workspace/bin \\

            \-e TARGET=fr245m \\

            testingcadence-build:${{ github.sha }}

      \- name: Upload build artefacts

        uses: actions/upload-artifact@v4

        with:

          name: testingcadence-prg-${{ github.sha }}

          path: bin/\*.prg

          retention-days: 30

## **5.2 Release Workflow (release.yml)**

Triggered when a version tag (e.g. v1.0.2) is pushed to the repository. Builds the application, generates release notes from the commit log, and creates a GitHub Release with the .prg artefacts attached.

name: TestingCadence Release

on:

  push:

    tags:

      \- 'v\*.\*.\*'

jobs:

  release:

    name: Build and Publish Release

    runs-on: ubuntu-latest

    permissions:

      contents: write

    steps:

      \- name: Checkout source code

        uses: actions/checkout@v4

        with:

          fetch-depth: 0   \# Required for full git log (release notes)

      \- name: Set up Docker Buildx

        uses: docker/setup-buildx-action@v3

      \- name: Build Docker image

        run: |

          docker build \\

            \--build-arg DEVELOPER\_KEY=${{ secrets.GARMIN\_DEVELOPER\_KEY }} \\

            \-t testingcadence-build:${{ github.ref\_name }} .

      \- name: Compile for all targets

        run: |

          mkdir \-p bin

          for TARGET in fr245 fr245m; do

            docker run \--rm \\

              \-v ${{ github.workspace }}/bin:/workspace/bin \\

              \-e TARGET=$TARGET \\

              testingcadence-build:${{ github.ref\_name }}

          done

      \- name: Generate release notes

        id: release\_notes

        run: |

          PREV\_TAG=$(git describe \--tags \--abbrev=0 HEAD^ 2\>/dev/null || echo '')

          if \[ \-z "$PREV\_TAG" \]; then

            NOTES=$(git log \--pretty=format:'- %s' HEAD)

          else

            NOTES=$(git log \--pretty=format:'- %s' ${PREV\_TAG}..HEAD)

          fi

          echo "notes\<\<EOF" \>\> $GITHUB\_OUTPUT

          echo "$NOTES" \>\> $GITHUB\_OUTPUT

          echo "EOF" \>\> $GITHUB\_OUTPUT

      \- name: Create GitHub Release

        uses: softprops/action-gh-release@v2

        with:

          tag\_name: ${{ github.ref\_name }}

          name: TestingCadence ${{ github.ref\_name }}

          body: |

            \#\# Changes in ${{ github.ref\_name }}

            ${{ steps.release\_notes.outputs.notes }}

          files: bin/\*.prg

          draft: false

          prerelease: false

# **6\. Secret and Credential Management**

The pipeline uses GitHub Actions Secrets to securely inject sensitive values at runtime. No credentials are stored in the repository or workflow YAML files.

| Secret Name | Used In | Description |
| :---- | :---- | :---- |
| GARMIN\_DEVELOPER\_KEY | build.yml, release.yml | Garmin developer key (.der) used to sign the MonkeyC build. Must be base64-encoded before storing as a secret. |
| GITHUB\_TOKEN | release.yml (auto-provided) | Auto-injected by GitHub Actions. Used by softprops/action-gh-release to create releases. No manual setup required. |

## **6.1 Adding the Developer Key as a Secret**

1. Locate your Garmin developer key file (developer\_key.der)  
2. Base64-encode the key: run  openssl base64 \-in developer\_key.der \-out key.b64  in a terminal  
3. Copy the contents of key.b64  
4. Navigate to the repository on GitHub: Settings → Secrets and variables → Actions  
5. Click New repository secret  
6. Name: GARMIN\_DEVELOPER\_KEY, Value: paste the base64-encoded key  
7. Click Add secret

**NOTE:** *The raw .der file must never be committed to the repository or included in Docker images pushed to public registries.*

# **7\. Build Artefacts and Versioning**

## **7.1 Artefact Naming Convention**

| Artefact | Target Device | Naming Pattern |
| :---- | :---- | :---- |
| TestingCadence-fr245.prg | Forerunner 245 | testingcadence-{version}-fr245.prg |
| TestingCadence-fr245m.prg | Forerunner 245M | testingcadence-{version}-fr245m.prg |

## **7.2 Versioning Scheme**

TestingCadence follows Semantic Versioning (SemVer):  MAJOR.MINOR.PATCH

* MAJOR — breaking changes to cadence monitoring behaviour or API level  
* MINOR — new features (e.g. new alert modes, new CQ scoring logic)  
* PATCH — bug fixes, SDK updates, dependency changes

The current release target is v1.0.2. Tags must be pushed to the repository to trigger the release workflow:

\# Tag and push to trigger release workflow

git tag \-a v1.0.2 \-m "Release v1.0.2 \- Forerunner 245/245M build"

git push origin v1.0.2

## **7.3 Artefact Retention**

* CI build artefacts (non-release): retained for 30 days on GitHub Actions  
* Release artefacts: attached to GitHub Releases and retained indefinitely  
* Local artefacts: stored in ./bin directory (excluded from source control via .gitignore)

# **8\. Pipeline Stage Detail**

| Stage | Trigger | Steps | Output |
| :---- | :---- | :---- | :---- |
| Checkout | All triggers | Clone repository at commit SHA; full depth for release | Source on runner |
| Docker Build | All triggers | Build image with SDK 8.3.0 and developer key build arg | Docker image |
| Compile (fr245) | All triggers | Run container; monkeyc \-d fr245; mount bin/ volume | .prg binary |
| Compile (fr245m) | All triggers | Run container; monkeyc \-d fr245m; mount bin/ volume | .prg binary |
| Upload Artefact | All triggers | Upload bin/\*.prg to Actions artefact storage | Downloadable .prg |
| Release Notes | Tag push only | Git log between previous and current tag | Markdown changelog |
| GitHub Release | Tag push only | Create release with notes and .prg files attached | Published release |

# **9\. Pipeline Failure Handling**

## **9.1 Build Failures**

If the MonkeyC compilation step fails, the workflow exits with a non-zero code and the entire job is marked as failed. The following actions apply:

* GitHub marks the PR check as failed — merge to main is blocked by branch protection rules  
* GitHub notifies the commit author and PR reviewer by email  
* No artefact is uploaded for a failed build  
* The Deployment Sub-Team Lead reviews the Actions log to identify the error

## **9.2 Common Failure Causes and Resolutions**

| Failure | Likely Cause | Resolution |
| :---- | :---- | :---- |
| monkeyc: command not found | SDK not installed in Docker image; PATH misconfigured | Rebuild Docker image; verify SDK\_DIR/bin on PATH |
| Invalid or missing developer key | GARMIN\_DEVELOPER\_KEY secret not set or corrupted | Re-add secret; re-encode .der file in base64 |
| monkey.jungle not found | .dockerignore excluding project files | Review .dockerignore; ensure monkey.jungle is copied |
| API level mismatch | Source uses API \> 3.3.0 features on SDK 8.3.0 | Review manifest.xml; pin API level to 3.2.0/3.3.0 |
| Release workflow: permission denied | contents: write not set in workflow permissions | Add permissions: contents: write to release job |
| No previous tag for release notes | First release; git describe fails on no prior tag | Workflow handles gracefully — logs full history |

## **9.3 Escalation**

If a pipeline failure cannot be resolved within one working day, the Deployment Sub-Team Lead escalates to the senior lead meeting (Wednesday / Sunday) for cross-team support.

# **10\. Running the Pipeline Locally**

Developers can replicate the CI build locally before pushing to validate their changes. This requires Docker installed on the host machine.

\# Step 1: Clone the repository

git clone https://github.com/\<org\>/TestingCadence.git

cd TestingCadence

\# Step 2: Build the Docker image

docker build \\

  \--build-arg DEVELOPER\_KEY=/path/to/developer\_key.der \\

  \-t testingcadence-build:local .

\# Step 3: Create output directory

mkdir \-p bin

\# Step 4: Compile for Forerunner 245

docker run \--rm \\

  \-v $(pwd)/bin:/workspace/bin \\

  \-e TARGET=fr245 \\

  testingcadence-build:local

\# Step 5: Compile for Forerunner 245M

docker run \--rm \\

  \-v $(pwd)/bin:/workspace/bin \\

  \-e TARGET=fr245m \\

  testingcadence-build:local

\# Artefacts will be in ./bin/

ls bin/

# **11\. Pipeline Monitoring**

## **11.1 Viewing Workflow Runs**

All workflow runs are visible under the Actions tab of the GitHub repository. Each run shows:

* Trigger event (push, PR, tag)  
* Commit SHA and branch/tag name  
* Individual step logs with timestamps  
* Artefact download links (for successful builds)  
* Total run duration

## **11.2 Build Status Badge**

A build status badge can be added to the repository README to surface pipeline health at a glance:

\!\[CI Build\](https://github.com/\<org\>/TestingCadence/actions/workflows/build.yml/badge.svg)

## **11.3 Notification Settings**

GitHub sends email notifications to the commit author when a workflow they triggered fails. Team-wide notifications can be configured under repository Settings → Notifications.

# **12\. Future Pipeline Improvements**

* Automated unit testing stage using Garmin Connect IQ simulator once simulator CI support is confirmed  
* Hardware-in-the-loop validation step triggered on physical Forerunner 245/245M availability  
* Docker image caching to reduce build times on repeated workflow runs  
* Connect IQ Store automated submission via Garmin Publish API on release tag  
* Slack or Teams notification integration for build status alerts to the sub-team  
* Dependency vulnerability scanning on SDK and container base image

# **13\. Related Documentation**

* Dockerisation Documentation — Deployment Sub-Team, May 2026  
* Git Quick Reference Guide — Tharun Chakrapani Venkatesh, Deployment Sub-Team  
* Branch Protection Configuration — GitHub Repository Settings  
* TestingCadence v1.0.2 Build Notes — Forerunner 245 / 245M  
* Garmin Connect IQ SDK 8.3.0 Developer Documentation — developer.garmin.com

# **14\. Document Version History**

| Version | Date | Author | Summary |
| :---- | :---- | :---- | :---- |
| 1.0 | May 2026 | Deployment Sub-Team Lead | Initial release |

