# meta.description = "llama-swap: on-demand model swapping in front of llama.cpp (Vulkan)"
{
  pkgs,
  lib,
  config,
  ...
}: let
  # Vulkan backend drives the RX 6700 XT without the ROCm gfx-override dance.
  llama-cpp = pkgs.llama-cpp.override {vulkanSupport = true;};
  llama-server = lib.getExe' llama-cpp "llama-server";
in {
  services = {
    llama-swap = {
      enable = true;
      listenAddress = "0.0.0.0";
      # 8080 is atticd on this host.
      port = 8091;
      settings = {
        # First load of an uncached model downloads several GB; allow for it.
        healthCheckTimeout = 1800;
        # llama-swap keeps a single model resident, so requesting one model
        # unloads the other — the two never have to co-exist in the 12 GB card.
        models = {
          # Agentic coding model (Qwen 3.5 based), Q5_K_M (~6.5 GB). q8_0 KV
          # cache + flash attention -> 64K ctx fits the card (~9 GB used).
          # (cmd is whitespace/newline-tokenised by llama-swap; no shell.)
          "ornith-1.0-9b".cmd = ''
            ${llama-server}
            --port ''${PORT}
            --hf-repo ornith-ai/Ornith-1.0-9B-GGUF
            --hf-file ornith-1.0-9b-Q5_K_M.gguf
            -ngl 99 -fa on
            --cache-type-k q8_0 --cache-type-v q8_0
            -c 65536 --no-webui
          '';

          # Small summariser for the phone (Gemma 4 E4B, QAT Q4_K_XL, ~4.2 GB).
          # Gemma 4 has no dense 4B; E4B is the ~4B-effective edge variant.
          # ttl unloads it after 5 min idle so it hands VRAM back to Ornith.
          "gemma-4-e4b" = {
            cmd = ''
              ${llama-server}
              --port ''${PORT}
              --hf-repo unsloth/gemma-4-E4B-it-qat-GGUF
              --hf-file gemma-4-E4B-it-qat-UD-Q4_K_XL.gguf
              -ngl 99 -fa on
              -c 16384 --no-webui
            '';
            ttl = 300;
          };
        };
      };
    };

    localProxy.subDomains.llama = {
      inherit (config.services.llama-swap) port;
    };
  };

  systemd.services.llama-swap.serviceConfig = {
    # Vulkan needs the render node (/dev/dri/renderD*) and video devices; the
    # spawned llama-server children inherit these.
    SupplementaryGroups = ["render" "video"];
    # Persist downloaded weights on the encrypted ZFS dataset (mounted at
    # /var/lib/private/llama-swap via disko) instead of a throwaway dir.
    StateDirectory = "llama-swap";
    Environment = ["LLAMA_CACHE=/var/lib/llama-swap"];
  };
}
