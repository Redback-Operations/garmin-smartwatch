

**TestingCadence**  
Garmin Connect IQ Smartwatch Application

**Dockerisation Documentation**

Deployment Sub-Team  
Deakin University — SIT764 Capstone Project

Version 1.0  |  SDK: Garmin Connect IQ 8.3.0  |  Target: Forerunner 245/245M

# **1\. Purpose and Scope**

This document describes the Dockerisation strategy for the TestingCadence build and CI/CD pipeline. It covers the rationale for containerising the Garmin Connect IQ SDK build environment, the Docker image structure, configuration details, and how containers integrate with the GitHub Actions automation used by the Deployment Sub-Team.

TestingCadence is a MonkeyC application built for Garmin wearable devices (Forerunner 245 and 245M). Because the Garmin Connect IQ SDK is an environment-specific toolchain, containerisation ensures consistent, reproducible builds across all developer machines and CI runners without manual SDK installation.

# **2\. Why Dockerise the Build Environment?**

The Garmin Connect IQ SDK requires a specific set of dependencies and environment variables that differ across operating systems. Without containerisation, developers on Windows, macOS, and Linux may experience build inconsistencies. Docker eliminates these discrepancies by packaging the complete SDK toolchain into a portable image.

## **2.1 Key Benefits**

* Consistent SDK version (8.3.0) across all builds regardless of host machine  
* No manual SDK installation required for contributors  
* Isolated build environment prevents dependency conflicts  
* Enables automated CI/CD via GitHub Actions without runner setup overhead  
* Faster onboarding for new sub-team members  
* Reproducible release artifacts for v1.0.2 and subsequent versions

# **3\. Container Architecture Overview**

The Docker setup consists of a single build container that encapsulates the Garmin Connect IQ SDK, MonkeyC compiler, and project source. The container does not run as a service — it is invoked as a build step and exits after producing the compiled .prg output artifact.

┌─────────────────────────────────────────────────┐

│               Docker Build Container            │

│                                                 │

│   Base Image : Ubuntu 22.04 LTS                │

│   SDK         : Garmin Connect IQ SDK 8.3.0     │

│   JDK         : OpenJDK 11                      │

│   Lang        : MonkeyC (compiled via monkeyc)  │

│                                                 │

│   Input  : /workspace (project source mount)    │

│   Output : /workspace/bin/\*.prg (artifact)      │

└─────────────────────────────────────────────────┘

# **4\. Prerequisites**

Before using the Docker build environment, ensure the following are installed on the host machine:

| Dependency | Version | Purpose |
| :---- | :---- | :---- |
| Docker Engine | 24.x or later | Container runtime |
| Docker Compose (optional) | v2.x | Multi-step build orchestration |
| Git | 2.x | Source code checkout |
| GitHub Actions Runner | Latest | CI/CD automation (server-side only) |

No Garmin Connect IQ SDK installation is required on the host — this is handled entirely inside the container.

# **5\. Dockerfile**

The Dockerfile is located at the root of the TestingCadence repository. It defines the multi-stage build process to keep the final image lean.

## **5.1 Dockerfile Contents**

\# ── Stage 1: Base SDK image ──────────────────────────

FROM ubuntu:22.04 AS sdk-base

ENV DEBIAN\_FRONTEND=noninteractive

ENV SDK\_VERSION=8.3.0

ENV SDK\_DIR=/opt/connectiq-sdk

\# Install runtime dependencies

RUN apt-get update && apt-get install \-y \\

    openjdk-11-jdk \\

    wget \\

    unzip \\

    curl \\

    && rm \-rf /var/lib/apt/lists/\*

\# Download and install Garmin Connect IQ SDK

RUN mkdir \-p ${SDK\_DIR} && \\

    wget \-q https://developer.garmin.com/downloads/connect-iq/sdks/\\

connectiq-sdk-lin-${SDK\_VERSION}-2024-01-01-00000000.zip \-O /tmp/sdk.zip && \\

    unzip \-q /tmp/sdk.zip \-d ${SDK\_DIR} && \\

    rm /tmp/sdk.zip

\# Add SDK binaries to PATH

ENV PATH="${SDK\_DIR}/bin:${PATH}"

\# ── Stage 2: Build stage ──────────────────────────────

FROM sdk-base AS builder

WORKDIR /workspace

\# Copy project source

COPY . .

\# Accept developer key (passed as build arg)

ARG DEVELOPER\_KEY

ENV DEVELOPER\_KEY=${DEVELOPER\_KEY}

\# Compile the MonkeyC application

RUN monkeyc \\

    \-f monkey.jungle \\

    \-o bin/TestingCadence.prg \\

    \-y ${DEVELOPER\_KEY} \\

    \-d fr245

\# Output artifact is at /workspace/bin/TestingCadence.prg

## **5.2 Build Arguments**

| DEVELOPER\_KEY | Path or value of the Garmin developer key (.der file). Must be passed at build time. Never commit to source control. |
| :---- | :---- |
| **SDK\_VERSION** | Garmin Connect IQ SDK version to install (default: 8.3.0). |

# **6\. Building the Docker Image**

## **6.1 Local Build**

To build the Docker image locally from the project root:

\# Build the image (replace \<key-path\> with your developer key path)

docker build \\

  \--build-arg DEVELOPER\_KEY=/path/to/developer\_key.der \\

  \-t testingcadence-build:latest .

## **6.2 Running the Build Container**

To compile the project and extract the .prg artifact to the host:

\# Run build and copy output to host ./bin directory

docker run \--rm \\

  \-v $(pwd)/bin:/workspace/bin \\

  testingcadence-build:latest

After the container exits, the compiled TestingCadence.prg will be available in the ./bin directory on the host machine.

# **7\. Docker Compose Configuration**

A docker-compose.yml is provided to simplify build invocation, particularly for developers running local builds without needing to remember the full Docker CLI syntax.

version: '3.8'

services:

  build:

    build:

      context: .

      args:

        DEVELOPER\_KEY: ${DEVELOPER\_KEY}

    volumes:

      \- ./bin:/workspace/bin

    environment:

      \- SDK\_VERSION=8.3.0

To run with Compose:

\# Export your developer key path first

export DEVELOPER\_KEY=/path/to/developer\_key.der

\# Run the build service

docker compose run \--rm build

# **8\. GitHub Actions CI/CD Integration**

The Docker build environment integrates with the GitHub Actions workflow defined in .github/workflows/build.yml. Automated builds are triggered on every push to the main branch and on pull requests targeting main.

## **8.1 Workflow Overview**

name: TestingCadence Build

on:

  push:

    branches: \[ main \]

  pull\_request:

    branches: \[ main \]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:

      \- name: Checkout source

        uses: actions/checkout@v4

      \- name: Set up Docker Buildx

        uses: docker/setup-buildx-action@v3

      \- name: Build Docker image

        run: |

          docker build \\

            \--build-arg DEVELOPER\_KEY=${{ secrets.GARMIN\_DEVELOPER\_KEY }} \\

            \-t testingcadence-build:${{ github.sha }} .

      \- name: Run build and extract artifact

        run: |

          mkdir \-p bin

          docker run \--rm \\

            \-v ${{ github.workspace }}/bin:/workspace/bin \\

            testingcadence-build:${{ github.sha }}

      \- name: Upload build artifact

        uses: actions/upload-artifact@v4

        with:

          name: TestingCadence-prg-${{ github.sha }}

          path: bin/TestingCadence.prg

## **8.2 GitHub Secrets Required**

| Secret Name | Description |
| :---- | :---- |
| GARMIN\_DEVELOPER\_KEY | Base64-encoded or path-referenced Garmin developer key (.der). Configured under repository Settings \> Secrets and variables \> Actions. |

Note: The developer key must never be committed to the repository. It is injected at build time via GitHub Secrets only.

# **9\. Environment Variables Reference**

| Variable | Default | Description |
| :---- | :---- | :---- |
| SDK\_VERSION | 8.3.0 | Garmin Connect IQ SDK version installed in container |
| SDK\_DIR | /opt/connectiq-sdk | SDK installation directory inside container |
| DEVELOPER\_KEY | (required) | Path to Garmin developer key for signing the build |
| DEBIAN\_FRONTEND | noninteractive | Suppresses interactive prompts during apt-get |

# **10\. Device Build Targets**

TestingCadence v1.0.2 targets the following Garmin devices. The Docker build compiles a separate .prg for each target device identifier.

| Device | SDK Identifier | Notes |
| :---- | :---- | :---- |
| Forerunner 245 | fr245 | Primary target device |
| Forerunner 245M | fr245m | Music variant — identical build pipeline |

To compile for both targets, the monkeyc command is run twice within the container (or parameterised via a build script):

\# Compile for Forerunner 245

monkeyc \-f monkey.jungle \-o bin/TestingCadence-fr245.prg \-y ${DEVELOPER\_KEY} \-d fr245

\# Compile for Forerunner 245M

monkeyc \-f monkey.jungle \-o bin/TestingCadence-fr245m.prg \-y ${DEVELOPER\_KEY} \-d fr245m

# **11\. Troubleshooting**

## **11.1 Common Issues**

| Issue | Resolution |
| :---- | :---- |
| Build fails: 'monkeyc: not found' | Ensure SDK\_DIR/bin is on PATH. Rebuild the image from scratch to confirm SDK installed correctly. |
| Build fails: 'invalid developer key' | Confirm DEVELOPER\_KEY points to a valid .der file. Check the key is not corrupted during base64 encoding for CI. |
| 'monkey.jungle: not found' | Ensure the COPY . . step in the Dockerfile includes monkey.jungle. Verify .dockerignore does not exclude it. |
| No .prg in ./bin after container run | Confirm the volume mount path matches: \-v $(pwd)/bin:/workspace/bin. The bin/ directory must exist on the host before running. |
| GitHub Actions: Secret not injected | Check secret name matches exactly: GARMIN\_DEVELOPER\_KEY. Confirm secret is set at repository level, not environment level. |

## **11.2 Checking the Container Interactively**

To debug inside the container without running the full build:

\# Open a shell inside the build image

docker run \--rm \-it testingcadence-build:latest /bin/bash

\# Check SDK is accessible

monkeyc \--version

\# Verify device definitions are present

ls ${SDK\_DIR}/devices/

# **12\. Security Considerations**

* The Garmin developer key (.der file) must never be committed to the repository under any circumstances.  
* In CI/CD, the key is passed via GitHub Secrets only — never hardcoded in workflow YAML files.  
* The Docker image should not be pushed to a public registry as it may contain the compiled binary derived from a proprietary SDK.  
* The .dockerignore file should exclude sensitive files such as .env, \*.der, and any local key files.

## **12.1 Recommended .dockerignore Entries**

\# .dockerignore

.git

.github

\*.der

\*.key

.env

bin/

\*.prg

# **13\. Related Documentation**

* Git Quick Reference Guide (authored by Tharun Chakrapani Venkatesh, Deployment Sub-Team)  
* Branch Protection Configuration — GitHub repository settings  
* GitHub Actions Release Notes Automation — Deployment Sub-Team  
* TestingCadence v1.0.2 Build Notes — Forerunner 245/245M  
* Garmin Connect IQ SDK 8.3.0 Developer Documentation — developer.garmin.com

# **14\. Document Version History**

| Version | Date | Author | Change |
| :---- | :---- | :---- | :---- |
| 1.0 | May 2026 | Deployment Sub-Team Lead | Initial release |

