_final: prev: {
  qutebrowser = prev.qutebrowser.override {
    # Native UI (completion, prompts, statusbar) via Qt Quick's Vulkan RHI
    # backend instead of GL; doesn't affect QtWebEngine's own rendering.
    enableVulkan = true;
    # Don't build pdf.js in; PDFs fall through to the download prompt instead.
    withPdfReader = false;
  };
}
