import React, { useRef, useState } from "react";

function UploadIcon() {
  return (
    <svg
      aria-hidden="true"
      className="upload-icon"
      viewBox="0 0 48 48"
      fill="none"
    >
      <path
        d="M24 31V10m0 0-8 8m8-8 8 8M11 29v8a2 2 0 0 0 2 2h22a2 2 0 0 0 2-2v-8"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function FileIcon() {
  return (
    <svg
      aria-hidden="true"
      className="file-icon"
      viewBox="0 0 24 24"
      fill="none"
    >
      <path
        d="M13 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V10l-7-7Z"
        stroke="currentColor"
        strokeWidth="1.7"
        strokeLinejoin="round"
      />
      <path
        d="M13 3v7h7M8 15h8M8 18h5"
        stroke="currentColor"
        strokeWidth="1.7"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function formatFileSize(size) {
  if (size < 1024) return `${size} B`;
  if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`;
  return `${(size / (1024 * 1024)).toFixed(1)} MB`;
}

export default function App() {
  const fileInputRef = useRef(null);
  const [file, setFile] = useState(null);
  const [runnerId, setRunnerId] = useState("");
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [isDragging, setIsDragging] = useState(false);

  function selectFile(selectedFile) {
    setNotice("");
    if (!selectedFile) return;

    if (!selectedFile.name.toLowerCase().endsWith(".fit")) {
      setFile(null);
      setError("That file type isn’t supported. Choose a .fit file to continue.");
      if (fileInputRef.current) fileInputRef.current.value = "";
      return;
    }

    setFile(selectedFile);
    setError("");
  }

  function handleDrop(event) {
    event.preventDefault();
    setIsDragging(false);
    selectFile(event.dataTransfer.files?.[0]);
  }

  function handleSubmit(event) {
    event.preventDefault();
    setNotice(
      "Your FIT file and runner are ready. File transfer will be available when the upload service is connected.",
    );
  }

  return (
    <div className="app-shell">
      <header className="topbar">
        <a className="brand" href="#" aria-label="Stride Coach home">
          <span className="brand-mark" aria-hidden="true">
            <svg viewBox="0 0 32 32" fill="none">
              <path
                d="M4 20h6l4-11 5 16 4-10h5"
                stroke="currentColor"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </span>
          <span>stride<span className="brand-light">coach</span></span>
        </a>
        <div className="topbar-note">
          <span className="status-dot" />
          Coach workspace
        </div>
      </header>

      <main className="page-content">
        <div className="breadcrumb" aria-label="Breadcrumb">
          <span>Activities</span>
          <span className="breadcrumb-separator" aria-hidden="true">/</span>
          <span className="breadcrumb-current">New run review</span>
        </div>

        <section className="upload-card" aria-labelledby="page-title">
          <div className="card-heading">
            <span className="eyebrow">RUN ANALYSIS</span>
            <h1 id="page-title">Start a run review</h1>
            <p className="intro">
              Add your runner’s activity file and we’ll get things ready for a
              closer look.
            </p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="field-group">
              <label className="field-label" htmlFor="runner-id">
                Runner ID <span className="required-mark" aria-hidden="true">*</span>
              </label>
              <input
                id="runner-id"
                name="runnerId"
                type="text"
                autoComplete="off"
                placeholder="e.g. RUN-2048"
                value={runnerId}
                onChange={(event) => {
                  setRunnerId(event.target.value);
                  setNotice("");
                }}
                required
              />
            </div>

            <div className="field-group file-field">
              <span className="field-label" id="file-label">
                Activity file <span className="required-mark" aria-hidden="true">*</span>
              </span>
              <input
                ref={fileInputRef}
                className="visually-hidden"
                id="fit-file"
                name="fitFile"
                type="file"
                accept=".fit"
                aria-labelledby="file-label"
                aria-describedby={error ? "file-error" : file ? undefined : "file-hint"}
                onChange={(event) => selectFile(event.target.files?.[0])}
              />
              <div
                className={`drop-zone${isDragging ? " is-dragging" : ""}${error ? " has-error" : ""}${file ? " has-file" : ""}`}
                onDragEnter={(event) => {
                  event.preventDefault();
                  setIsDragging(true);
                }}
                onDragOver={(event) => event.preventDefault()}
                onDragLeave={(event) => {
                  if (!event.currentTarget.contains(event.relatedTarget)) {
                    setIsDragging(false);
                  }
                }}
                onDrop={handleDrop}
              >
                {file ? (
                  <div className="selected-file">
                    <span className="file-icon-wrap"><FileIcon /></span>
                    <span className="file-details">
                      <span className="file-name">{file.name}</span>
                      <span className="file-size">{formatFileSize(file.size)}</span>
                    </span>
                    <button
                      type="button"
                      className="remove-file"
                      aria-label={`Remove ${file.name}`}
                      onClick={() => {
                        setFile(null);
                        setNotice("");
                        if (fileInputRef.current) fileInputRef.current.value = "";
                      }}
                    >
                      Remove
                    </button>
                  </div>
                ) : (
                  <>
                    <span className="upload-icon-wrap"><UploadIcon /></span>
                    <div className="drop-copy">
                      <p className="drop-title">Drop your FIT file here</p>
                      <p className="drop-subtitle">or choose one from your device</p>
                    </div>
                    <button
                      type="button"
                      className="choose-button"
                      onClick={() => fileInputRef.current?.click()}
                    >
                      Choose file
                    </button>
                    <p className="file-hint" id="file-hint">FIT files only · .fit</p>
                  </>
                )}
              </div>
              {error && <p className="error-message" id="file-error" role="alert">{error}</p>}
            </div>

            <div className="form-footer">
              <p className="privacy-note">
                <svg aria-hidden="true" viewBox="0 0 16 16" fill="none">
                  <path
                    d="M4.5 7V5a3.5 3.5 0 0 1 7 0v2m-8 0h9v7h-9V7Z"
                    stroke="currentColor"
                    strokeWidth="1.4"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
                Your activity file stays private.
              </p>
              <button
                type="submit"
                className="upload-button"
                disabled={!file || !runnerId.trim()}
              >
                Upload
                <svg aria-hidden="true" viewBox="0 0 20 20" fill="none">
                  <path
                    d="M4 10h12m-5-5 5 5-5 5"
                    stroke="currentColor"
                    strokeWidth="1.7"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </button>
            </div>
            {notice && <p className="notice-message" role="status">{notice}</p>}
          </form>
        </section>

        <p className="help-note">
          Need help finding an activity file? Export the run from Garmin Connect
          as an original FIT file.
        </p>
      </main>
      <footer className="page-footer">
        <span>STRIDE COACH</span>
        <span>Built for better runs.</span>
      </footer>
    </div>
  );
}
