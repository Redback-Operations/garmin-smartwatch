# Runner FIT upload

A standalone React/Vite page for selecting a runner and validating an activity
file. FIT file contents are not read by this first-sprint UI.

## Run locally

```sh
npm install
npm run dev
```

The page accepts `.fit` files only and shows the chosen file name and size.
Submitting confirms that the file and Runner ID are ready; it does not transfer
the file because an upload service has not been connected yet.
