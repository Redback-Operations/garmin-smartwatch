# GitHub CI/CD Pipeline Setup

Automated build pipeline for the Garmin Connect IQ watch app.

---

## Overview

| Trigger | What happens |
|---|---|
| Push to `main` | Builds `.prg` for all 16 devices → uploaded as workflow artifacts (30 days) |
| Push tag `v*.*.*` | Builds `.prg` for all 16 devices → creates a GitHub Release with all files attached |

---

## Prerequisites

### 1. Garmin Developer Key

You need a `.der` signing key to compile `.prg` files. If you don't have one:

```bash
# Generate a developer key (run once locally)
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

Encode it to Base64 for the GitHub Secret:

```bash
# Linux / macOS
base64 -i developer_key.der

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("developer_key.der"))
```

### 2. Garmin Connect IQ SDK Download URL

Download the Linux SDK from:
> https://developer.garmin.com/connect-iq/sdk/

Copy the direct download URL for the Linux `.zip` (e.g. `connectiq-sdk-lin-7.3.1-2024-xx-xx.zip`).

---

## GitHub Secrets & Variables Setup

Go to your repo → **Settings → Secrets and variables → Actions**

### Secrets (sensitive — never shown after saving)

| Name | Value |
|---|---|
| `DEVELOPER_KEY_B64` | Base64 string of your `developer_key.der` |
| `CIQ_SDK_URL` | Full download URL of the Linux SDK `.zip` |

### Variables (non-sensitive)

| Name | Value example |
|---|---|
| `CIQ_SDK_VERSION` | `7.3.1` (used for caching the SDK between runs) |

---

## Workflow Files

Create the directory `.github/workflows/` in your repo root, then add these two files.

---

### `.github/workflows/build.yml` — Build on push to `main`

```yaml
name: Build

on:
  push:
    branches: [main]

jobs:
  build:
    name: Build (${{ matrix.device }})
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        device:
          - fenix7
          - fenix7pro
          - fenix7s
          - fenix7x
          - fr165
          - fr165m
          - fr235
          - fr245
          - fr255
          - fr255m
          - fr255s
          - fr255sm
          - fr265
          - fr265s
          - fr955
          - vivoactive5

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Cache Connect IQ SDK
        id: sdk-cache
        uses: actions/cache@v4
        with:
          path: ~/connectiq-sdk
          key: connectiq-sdk-${{ vars.CIQ_SDK_VERSION }}

      - name: Install Connect IQ SDK
        if: steps.sdk-cache.outputs.cache-hit != 'true'
        run: |
          wget -q "${{ secrets.CIQ_SDK_URL }}" -O /tmp/ciq-sdk.zip
          mkdir -p ~/connectiq-sdk
          unzip -q /tmp/ciq-sdk.zip -d ~/connectiq-sdk

      - name: Add SDK to PATH
        run: |
          MONKEYC_BIN=$(find ~/connectiq-sdk -name "monkeyc" | head -1 | xargs dirname)
          echo "$MONKEYC_BIN" >> $GITHUB_PATH

      - name: Write developer key
        run: echo "${{ secrets.DEVELOPER_KEY_B64 }}" | base64 --decode > developer_key.der

      - name: Build
        run: |
          mkdir -p bin
          monkeyc \
            -o bin/garminsmartwatch_${{ matrix.device }}.prg \
            -f monkey.jungle \
            -y developer_key.der \
            -d ${{ matrix.device }} \
            --release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.device }}
          path: bin/garminsmartwatch_${{ matrix.device }}.prg
          retention-days: 30
```

---

### `.github/workflows/release.yml` — GitHub Release on version tag

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build:
    name: Build (${{ matrix.device }})
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        device:
          - fenix7
          - fenix7pro
          - fenix7s
          - fenix7x
          - fr165
          - fr165m
          - fr235
          - fr245
          - fr255
          - fr255m
          - fr255s
          - fr255sm
          - fr265
          - fr265s
          - fr955
          - vivoactive5

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Cache Connect IQ SDK
        id: sdk-cache
        uses: actions/cache@v4
        with:
          path: ~/connectiq-sdk
          key: connectiq-sdk-${{ vars.CIQ_SDK_VERSION }}

      - name: Install Connect IQ SDK
        if: steps.sdk-cache.outputs.cache-hit != 'true'
        run: |
          wget -q "${{ secrets.CIQ_SDK_URL }}" -O /tmp/ciq-sdk.zip
          mkdir -p ~/connectiq-sdk
          unzip -q /tmp/ciq-sdk.zip -d ~/connectiq-sdk

      - name: Add SDK to PATH
        run: |
          MONKEYC_BIN=$(find ~/connectiq-sdk -name "monkeyc" | head -1 | xargs dirname)
          echo "$MONKEYC_BIN" >> $GITHUB_PATH

      - name: Write developer key
        run: echo "${{ secrets.DEVELOPER_KEY_B64 }}" | base64 --decode > developer_key.der

      - name: Build
        run: |
          mkdir -p bin
          monkeyc \
            -o bin/garminsmartwatch_${{ matrix.device }}.prg \
            -f monkey.jungle \
            -y developer_key.der \
            -d ${{ matrix.device }} \
            --release

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ matrix.device }}
          path: bin/garminsmartwatch_${{ matrix.device }}.prg
          retention-days: 1

  release:
    name: Create GitHub Release
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - name: Download all build artifacts
        uses: actions/download-artifact@v4
        with:
          path: artifacts/
          merge-multiple: true

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          name: Release ${{ github.ref_name }}
          files: artifacts/*.prg
          generate_release_notes: true
```

---

## How to trigger a release

```bash
# 1. Merge your feature branch into main
git checkout main
git merge feature/prod_Build_v1.0.2

# 2. Push main (triggers the build workflow)
git push origin main

# 3. Tag the release (triggers the release workflow)
git tag -a v1.0.2 -m "Release v1.0.2"
git push origin v1.0.2
```

GitHub will automatically create a Release page with all 16 `.prg` files attached.

---

## Build artifact naming

Each `.prg` file is named by device:

```
garminsmartwatch_fenix7.prg
garminsmartwatch_fr265.prg
garminsmartwatch_vivoactive5.prg
... (16 total)
```

---

## How to download the `.prg` file

### After a push to `main` (workflow artifact)

1. Go to your repo on GitHub
2. Click the **Actions** tab
3. Click the latest **Build** workflow run
4. Scroll down to the **Artifacts** section
5. Download the zip for your target device, unzip it to get the `.prg`

> Artifacts are available for **30 days** then auto-deleted.

---

### After pushing a version tag (GitHub Release)

1. Go to your repo on GitHub
2. Click **Releases** in the right sidebar
3. Click the release (e.g. `v1.0.2`)
4. All 16 `.prg` files are listed — click any to download directly, no unzipping needed

> Release files are **permanent** and publicly accessible.

---

### Which `.prg` to use

| Who needs it | Where to get it |
|---|---|
| You (testing after merge to main) | Actions → latest Build run → Artifacts |
| You (distributing / store upload) | Releases → v1.0.2 → download `.prg` |
| End users (via Garmin Connect IQ Store) | Upload the `.prg` from the Release to the store manually |

The `.prg` from a **Release** is what you upload to the [Garmin Connect IQ Store](https://apps.garmin.com/developer) for publishing.

---

## Notes

- The 16 devices run in **parallel** (matrix strategy), so the full build completes in roughly the time it takes to build one device.
- The SDK is **cached** between runs using `actions/cache`. The cache key is the SDK version — update `CIQ_SDK_VERSION` when you upgrade the SDK.
- The developer key is written to disk only during the job and never persisted to artifacts or logs.
