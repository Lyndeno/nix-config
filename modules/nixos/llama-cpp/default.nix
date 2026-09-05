# meta.description = "llama.cpp local LLM inference server (Vulkan)"
{
  pkgs,
  lib,
  config,
  ...
}: {
  services = {
    llama-cpp = {
      enable = true;
      # Vulkan backend drives the RX 6700 XT without the ROCm gfx-override
      # dance the old ollama setup needed.
      package = pkgs.llama-cpp.override {vulkanSupport = true;};
      host = "0.0.0.0";
      # 8080 is taken by atticd on this host.
      port = 8091;
      extraFlags = [
        # Ornith-1.0-9B (Qwen 3.5 based agentic coding model), Q5_K_M (~6.5 GB).
        # Auto-downloaded to LLAMA_CACHE (see below) on first start.
        "--hf-repo"
        "ornith-ai/Ornith-1.0-9B-GGUF"
        "--hf-file"
        "ornith-1.0-9b-Q5_K_M.gguf"
        # OpenAI-API model id.
        "--alias"
        "ornith-1.0-9b"
        # Offload all layers to the GPU.
        "-ngl"
        "99"
        # Flash attention is required for a quantised KV cache.
        "-fa"
        "on"
        # q8_0 KV cache is ~64 KiB/token (half of fp16, near-lossless), so 64K
        # ctx ≈ 4 GB — about all the 12 GB card has left after the ~6.5 GB weights.
        "--cache-type-k"
        "q8_0"
        "--cache-type-v"
        "q8_0"
        "-c"
        "65536"
      ];
    };

    localProxy.subDomains.llama = {
      inherit (config.services.llama-cpp) port;
    };
  };

  systemd.services.llama-cpp.serviceConfig = {
    # Vulkan needs the render node (/dev/dri/renderD*) and video devices.
    SupplementaryGroups = ["render" "video"];
    # Persist downloaded weights on the encrypted ZFS dataset (mounted at
    # /var/lib/private/llama-cpp via disko) instead of the default /var/cache.
    Environment = lib.mkForce ["LLAMA_CACHE=/var/lib/llama-cpp"];
  };
}
