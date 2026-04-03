# AGENTS.md

This file is the canonical guide for AI agents working in this repository. If a tool also reads `CLAUDE.md`, treat that file as a pointer back here and keep the two consistent.

## Project Summary

This repository contains Jeff Shelton's personal dotfiles and system configuration.

- Nix is the source of truth for machine configuration.
- GNU Stow compatibility for home-directory dotfiles must be preserved.
- Dotfiles under the repository root and `.config/` are managed directly rather than being broadly rewritten into Home Manager.
- Home Manager is used selectively where programmatic configuration is necessary, not as a replacement for direct dotfiles.
- The `nix/` directory is organized into reusable modules and per-host machine definitions.

Current hosts are named after Roman mythology figures and live under `nix/hosts/<system>/`.

## Repository Layout

- `nix/flake.nix`: flake entry point; outputs are delegated to `nix/hosts/default.nix`.
- `nix/hosts/`: host definitions grouped by target platform such as `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin`.
- `nix/modules/`: reusable modules. Modules are expected to be self-contained and import their own dependencies.
- `nix/users/`: user definitions, including direct mapping of repository dotfiles into the home directory.
- `nix/secrets/`: `agenix`-managed secret metadata and encrypted payloads.
- `.config/`, `.zshrc`, and similar top-level dotfiles: directly managed user configuration that must remain Stow-friendly.
- `bootstrap.sh`: bootstrap/install script. It is currently marked in-source as not working correctly; do not assume it is authoritative without re-validating it.

## Ground Rules

- Preserve the current architecture: Nix-based configuration plus direct dotfiles with GNU Stow compatibility.
- Do not migrate the repository to a Home Manager-only layout.
- Do not move files out of their Stow-friendly locations just to satisfy an AI tool.
- Prefer small, local edits that match existing module boundaries.
- When changing a Nix module, keep it self-contained. If it depends on another module, import that module explicitly rather than relying on incidental ordering.
- Never commit decrypted secrets, generated secret material, or machine-specific private data.
- Treat `nix/secrets/` and any `*.age` payloads as sensitive. Modify only the metadata or encrypted files that are required for the task.
- Avoid editing vendored plugin contents under `.config/tmux/plugins/` unless the task is explicitly about those plugins.

## Development Workflow

Common commands:

```sh
# Evaluate or inspect the flake from the Nix subdirectory.
cd nix
nix flake show

# Rebuild the current machine from the repo root via the shell alias.
rebuild

# Or rebuild explicitly.
sudo nixos-rebuild switch --flake ~/dotfiles/nix
sudo darwin-rebuild switch --flake ~/dotfiles/nix

# Apply direct dotfiles into $HOME.
stow .
```

Host-specific rebuilds can also target `~/dotfiles/nix#<hostname>`.

When making changes:

1. Prefer editing the relevant file directly in `.config/`, top-level dotfiles, or the narrowest applicable Nix module.
2. Validate the smallest useful surface area first.
3. If a change affects activation, rebuild only the relevant host when possible.
4. If a change affects Stow-managed files, ensure the repository layout still maps cleanly into `$HOME`.

## Validation Expectations

Use the lightest validation that proves the change:

- For Nix changes, prefer evaluation or targeted builds before full system activation.
- For host-specific changes, validate against the affected host configuration.
- For dotfile-only changes, verify syntax where practical, then ensure `stow .` would still make sense.
- For shell changes, keep POSIX shell in `bootstrap.sh` and existing shell style in `.zshrc`.

Useful checks:

```sh
cd nix
nix flake check
nix flake show

# Example host evaluations/builds
nix build .#nixosConfigurations.jupiter.config.system.build.toplevel
nix build .#darwinConfigurations.mercury.system
```

Do not run destructive cleanup or machine-wide activation unless the user asked for it.

## Style Guide

- Use two-space indentation in Nix, shell, JSON, and similar config files already following that style.
- Keep Nix expressions formatted in the existing multi-line style with trailing semicolons and concise comments.
- Prefer descriptive comments that explain intent, especially around platform differences or module responsibilities.
- Keep modules readable and compartmentalized rather than overly abstract.
- Match existing naming: lowercase file names, concise module names, host names matching machine names.
- Preserve straightforward shell style in scripts and `.zshrc`; avoid introducing Bash-only features into `#!/bin/sh` scripts.
- Prefer explicit platform branching when macOS and NixOS differ.

## AI Agent Guidance

- Read the surrounding module or dotfile before editing; this repo relies on local consistency more than framework conventions.
- Favor edits that keep behavior obvious to a human maintainer.
- If a request conflicts with Nix-first plus Stow-compatible design, preserve that design and say so in the final summary.
- When introducing new files in the home-directory layout, place them where Stow can manage them cleanly.
- When adding new machine-specific configuration, prefer a host file under `nix/hosts/` and reuse modules from `nix/modules/`.
- When adding new user-facing dotfiles, wire them through the existing `nix/users/jeff.nix` pattern only if needed for deployment onto managed machines.
- Check for dirty worktree state before broad edits and avoid overwriting unrelated user changes.

## Files To Treat Carefully

- `nix/flake.lock`: dependency updates can have wide effects; do not churn it unnecessarily.
- `nix/secrets/**`: sensitive and often host-specific.
- `.config/tmux/plugins/**`: mostly vendored plugin content.
- `nix/firmware/**`: large binary assets; do not rewrite or reformat.

## Preferred Change Patterns

- New application/system capability: add or update a focused module in `nix/modules/`, then include it from the relevant host.
- Host-only adjustment: edit the corresponding file in `nix/hosts/<system>/<host>.nix`.
- User dotfile change: edit the tracked file directly under `.config/` or the repository root.
- Secret addition/rotation: update `nix/secrets/secrets.nix`, key metadata, and encrypted payloads together, without committing decrypted outputs.

## Final Checklist

Before finishing, an agent should confirm:

- The change still respects Nix as the primary configuration mechanism.
- Stow compatibility for home-directory dotfiles is preserved.
- No secrets or generated private artifacts were introduced.
- Validation appropriate to the change was run, or the lack of validation was stated clearly.
