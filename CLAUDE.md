# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository using Nix for system configuration across NixOS and macOS (via nix-darwin). Configurations are shared through symlinks using GNU Stow, with Nix managing packages and system-level settings.

## System Architecture

### Flake Structure

The repository is organized as a Nix flake with host-based configurations:

- **`nix/flake.nix`** - Main flake entry point defining inputs and outputs
- **`nix/hosts/`** - Host configurations organized by architecture:
  - `x86_64-linux/` - Intel/AMD Linux hosts (Jupiter)
  - `aarch64-linux/` - ARM Linux hosts (Ceres, Mars, Venus)
  - `aarch64-darwin/` - Apple Silicon macOS (Mercury)
- **`nix/hosts/default.nix`** - Automatically discovers and builds configurations for all hosts

### Module System

Software components are organized into independent modules in `nix/modules/`. Each module:
- Must be fully self-contained and import its own dependencies
- Can be selectively included in host configurations
- Handles both NixOS and macOS differences using `isLinux`/`isDarwin` conditionals

Key modules include:
- `neovim.nix` - Neovim with language servers (LSPs for C, Java, Lua, Markdown, Nix, Python, Swift, TypeScript, etc.)
- `hyprland.nix` - Wayland desktop environment (Linux-only)
- `dev.nix` - General development tools (git, direnv, gcc, clang, nodejs, etc.)
- `rust.nix` - Rust toolchain
- `shell.nix` - Shell configuration

### Bundles

`nix/bundles/full.nix` imports a comprehensive set of modules for full-featured workstations.

### User Configuration

`nix/users/jeff.nix` manages:
- Home-manager integration for dotfile symlinking from `.config/` to `~/.config/`
- User-specific settings and SSH keys
- Platform-specific user groups (Linux only)

### Dotfiles

Dotfiles in `.config/` are symlinked via home-manager, NOT GNU Stow (contrary to the README). Key configurations:
- `.config/nvim/` - Neovim configuration with lazy.nvim plugin manager
- `.config/hypr/` - Hyprland compositor settings
- `.config/ghostty/` - Ghostty terminal configuration
- `.config/git/` - Git configuration
- `.zshrc` - Zsh shell configuration

## Common Commands

### Building and Switching Configurations

**NixOS:**
```bash
sudo nixos-rebuild switch --flake ~/dotfiles/nix#<hostname>
```

**macOS (nix-darwin):**
```bash
darwin-rebuild switch --flake ~/dotfiles/nix#<hostname>
```

Replace `<hostname>` with: `jupiter`, `mercury`, `ceres`, `mars`, or `venus`.

### Testing Configuration Changes

**NixOS (test without switching boot):**
```bash
sudo nixos-rebuild test --flake ~/dotfiles/nix#<hostname>
```

**Build without activating:**
```bash
nix build ~/dotfiles/nix#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Flake Operations

**Update all flake inputs:**
```bash
cd ~/dotfiles/nix && nix flake update
```

**Update specific input:**
```bash
cd ~/dotfiles/nix && nix flake lock --update-input <input-name>
```

**Check flake:**
```bash
cd ~/dotfiles/nix && nix flake check
```

### Building Disk Images

For ARM Linux hosts using disko:
```bash
nix build ~/dotfiles/nix#image.<hostname>
```

### Neovim

Neovim uses lazy.nvim for plugin management. Plugins auto-install on first launch.

**Update plugins:**
Open Neovim and run `:Lazy update`

**Claude Code integration:**
- `<leader>ca` - Start Claude Code session
- `<leader>cc` - Continue Claude Code session
- `<leader>cr` - Resume Claude Code session

## Development Workflow

When modifying this repository:

1. **Module changes:** Edit the relevant file in `nix/modules/`
2. **Host configuration:** Edit `nix/hosts/<arch>/<hostname>.nix`
3. **Dotfile changes:** Edit files directly in `.config/` or root-level dotfiles
4. **Test:** Use `nixos-rebuild test` or `darwin-rebuild switch` to test changes
5. **Commit:** Changes to both Nix files and dotfiles should be committed together

### Adding New Modules

1. Create `nix/modules/<module-name>.nix`
2. Ensure the module imports its own dependencies
3. Use `lib.optionalAttrs` for platform-specific configuration
4. Add to host configurations or bundles as needed

### Adding New Hosts

1. Create `nix/hosts/<architecture>/<hostname>.nix`
2. For NixOS: Include hardware configuration (from `/etc/nixos/hardware-configuration.nix`)
3. Import desired bundles or modules
4. Import user configuration from `nix/users/`
5. The host will be automatically discovered by `nix/hosts/default.nix`

## Important Considerations

- The bootstrap script (`bootstrap.sh`) is currently non-functional and needs fixes
- Hardware configurations for NixOS hosts must be updated when hardware changes
- Hyprland module only works on physical Linux machines, not VMs
- Dotfiles are managed via home-manager file source linking, not GNU Stow
- All dotfiles in `.config/` are automatically symlinked by the user configuration
