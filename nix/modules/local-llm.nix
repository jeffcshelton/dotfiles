# A local language model on Jupiter's RTX 5070 Ti, for the personas on Apollo:
# Google's Gemma 4 26B-A4B, 4-bit, kept loaded and served by llama.cpp's
# OpenAI-compatible server over the VPN. Sam uses it, and falls back to GPT-6
# Luna whenever Jupiter is off (see the personas in apollo.nix).
{ lib, pkgs, ... }:
let
  port = 8080;

  # llama.cpp with CUDA, newer than nixpkgs' for Gemma 4's speculative
  # decoding (MTP), which needs build b10505 or later.
  llama-cpp = (pkgs.llama-cpp.override { cudaSupport = true; }).overrideAttrs {
    version = "12121";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      tag = "b12121";
      hash = "sha256-CdjdUOe5yGSOumLJp6Cjjt2ct1NgU1P/X2RYvYLgu8o=";
    };
    postPatch = "";
    npmDepsHash = "sha256-XLtEZsSFdk+2SyfXzBp8HQ2e27PQPpDCn1YjePU1/9w=";
  };

  # Unsloth's 4-bit Gemma (13.6 GB, fits the card with room for its context)
  # and the small model it drafts with (MTP), at a fixed revision.
  unsloth = file: hash: pkgs.fetchurl {
    url = "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/c099eb48e663fd284577b04978a94ffccb261841/${file}";
    inherit hash;
  };
  model = unsloth "gemma-4-26B-A4B-it-UD-IQ4_XS.gguf" "sha256-ur0eOJ04Y1L3FgB2XTc5D33Jk/v61nJcrM+Zb/40rs8=";
  draft = unsloth "mtp-gemma-4-26B-A4B-it.gguf" "sha256-Yyb7n15Ieqjc3TE6CR48Z3JMsqZm7Dt9KJW1sm2T7Rs=";
in
{
  # Only the 5070 Ti's architecture, which keeps the CUDA build short.
  nixpkgs.config.cudaCapabilities = [ "12.0" ];

  systemd.services.llama-server = {
    description = "Gemma 4 for the personas";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      # Settings from NVIDIA's llama.cpp recipe for Gemma 4 26B-A4B on GeForce
      # RTX, with a smaller context: a persona's conversations are short.
      ExecStart = lib.escapeShellArgs [
        "${llama-cpp}/bin/llama-server"
        "--model" model
        "--alias" "gemma-4-26b-a4b"
        "--spec-type" "draft-mtp"
        "--spec-draft-model" draft
        "--spec-draft-n-max" "3"
        "--ctx-size" "16384"
        "--parallel" "1"
        "--jinja"
        "--temp" "1.0"
        "--top-p" "0.95"
        "--top-k" "64"
        "--host" "0.0.0.0"
        "--port" (toString port)
      ];
      DynamicUser = true;
      SupplementaryGroups = [ "video" "render" ];
      Restart = "always";
      RestartSec = 5;
    };
  };

  # Reachable over the VPN only, where Apollo calls it.
  networking.firewall.interfaces.wg0.allowedTCPPorts = [ port ];
}
