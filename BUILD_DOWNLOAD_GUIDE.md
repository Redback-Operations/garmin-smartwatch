# How to Download a Build for Your Garmin Watch

This guide explains how to get the latest app file (`.prg`) for your specific Garmin device from our automated build system — no technical knowledge required.

---

## What is a "build" and where does it come from?

Every time code is pushed to this repository, GitHub automatically compiles a separate app file for each of the 16 supported Garmin devices. These files are called **artifacts**. Think of it like a factory that runs automatically and produces a finished product for each watch model.

There are two ways to get a build:

| Where to look | Best for | How long it stays available |
|---|---|---|
| **GitHub Actions** (artifacts) | Testing a specific code change or branch | 7–30 days |
| **GitHub Releases** | Stable, approved versions | Permanently |

---

## Supported Devices

Find your device model in the table below to know which file to download.

| Your Watch | File to Download |
|---|---|
| Garmin Fenix 7 | `garminsmartwatch_fenix7.prg` |
| Garmin Fenix 7 Pro | `garminsmartwatch_fenix7pro.prg` |
| Garmin Fenix 7S | `garminsmartwatch_fenix7s.prg` |
| Garmin Fenix 7X | `garminsmartwatch_fenix7x.prg` |
| Garmin Forerunner 165 | `garminsmartwatch_fr165.prg` |
| Garmin Forerunner 165 Music | `garminsmartwatch_fr165m.prg` |
| Garmin Forerunner 245 | `garminsmartwatch_fr245.prg` |
| Garmin Forerunner 245 Music | `garminsmartwatch_fr245m.prg` |
| Garmin Forerunner 255 | `garminsmartwatch_fr255.prg` |
| Garmin Forerunner 255 Music | `garminsmartwatch_fr255m.prg` |
| Garmin Forerunner 255S | `garminsmartwatch_fr255s.prg` |
| Garmin Forerunner 255S Music | `garminsmartwatch_fr255sm.prg` |
| Garmin Forerunner 265 | `garminsmartwatch_fr265.prg` |
| Garmin Forerunner 265S | `garminsmartwatch_fr265s.prg` |
| Garmin Forerunner 955 | `garminsmartwatch_fr955.prg` |
| Garmin Vivo Active 5 | `garminsmartwatch_vivoactive5.prg` |

---

## Option A — Download from a GitHub Release (Recommended for stable builds)

Releases are official versions that have been tested and approved. Files here are available permanently.

**Step 1** — Go to the repository on GitHub.

**Step 2** — On the right-hand side of the page, look for the **"Releases"** section. Click on it.

> If you don't see it on the right side, look for a **"Releases"** link near the top of the page or scroll down.

**Step 3** — You will see a list of releases, each labelled with a version number (e.g. `v1.2.0`). Click on the latest one at the top (or whichever version you need).

**Step 4** — Scroll down to the **"Assets"** section at the bottom of that release page.

**Step 5** — You will see a list of `.prg` files — one for each device. Find your device in the table above and click the matching file name to download it.

---

## Option B — Download from GitHub Actions (For testing in-progress code)

Use this when you need a build from a specific branch or code change that has not been released yet. These files have an expiry: **7 days** for `develop` branch builds and **30 days** for `main` branch builds.

**Step 1** — Go to the repository on GitHub.

**Step 2** — Click on the **"Actions"** tab near the top of the page.

![Actions tab is in the top navigation bar of the repository]

**Step 3** — On the left side, you will see a list of workflows. Choose the one that matches what you need:

- **"CI — Develop"** — builds from the `develop` branch (in-progress work, expires in 7 days)
- **"CI — Main"** — builds from the `main` branch (the latest approved code, expires in 30 days)

**Step 4** — You will see a list of runs, each showing when it ran and whether it passed (green checkmark) or failed (red X). Click on the most recent run with a **green checkmark**.

> Only successful runs (green checkmark) will have downloadable files.

**Step 5** — Scroll down to the bottom of the run page until you see a section called **"Artifacts"**.

**Step 6** — You will see entries named like `fenix7-abc1234`, `fr265-abc1234`, etc. The first part is the device name. Find the one that matches your watch (refer to the device table above) and click it to download a `.zip` file.

**Step 7** — Unzip the downloaded file. Inside you will find the `.prg` file for your device (e.g. `garminsmartwatch_fenix7.prg`).

---

## How to Install the App on Your Watch

Once you have the `.prg` file, you can install it onto your Garmin watch using one of these two methods:

### Method 1 — Garmin Express (PC or Mac)

1. Connect your watch to your computer with its USB cable.
2. Open **Garmin Express**.
3. In Garmin Express, go to your device's page and look for an option to manually add or sideload a Connect IQ app.
4. Browse to and select the `.prg` file you downloaded.
5. Sync your device. The app will appear on your watch.

### Method 2 — Garmin Connect IQ Mobile App

1. Enable **Developer Mode** in the Connect IQ app on your phone:
   - Open the **Connect IQ** app.
   - Tap the menu (three lines) → **Settings** → enable **Developer Mode**.
2. Tap **Load Device App**.
3. Choose the `.prg` file from your phone's storage.
4. Follow the prompts to send it to your paired watch.

---

## Frequently Asked Questions

**Q: I cannot find the Artifacts section — where is it?**
Artifacts only appear on runs that completed successfully (green checkmark). If the run failed, there are no files to download. Try selecting a different run that shows a green checkmark.

**Q: The artifact for my device is missing.**
If one device's build failed while others succeeded, that device's artifact will not appear. Check the run logs by clicking on the failed job for details, or notify the development team.

**Q: The build I downloaded is more than 7 / 30 days old and is gone.**
Artifacts are automatically deleted after their retention period. For the `develop` branch this is 7 days; for `main` it is 30 days. Ask the development team to trigger a new build, or use an official Release instead (Option A), which never expires.

**Q: Which branch should I use for QA testing?**
- Use **"CI — Develop"** builds when you are testing features that are still being worked on.
- Use **"CI — Main"** builds when you want the latest code that has passed code review.
- Use a **Release** build when you need a stable, versioned snapshot for sign-off.

**Q: I have a Fenix 7 Pro Sapphire Solar. Which file do I use?**
The `fenix7pro` build covers all Fenix 7 Pro variants (including Sapphire Solar). Download `garminsmartwatch_fenix7pro.prg`.

---

*For any issues or questions, please contact the development team.*
