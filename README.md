# NixOS on WSL Development Environment

A modern, reproducible development environment using NixOS on WSL, featuring seamless Windows SSH agent integration, comprehensive development tools, and intelligent shell configuration.

## Features

- 🚀 Full NixOS environment running on WSL
- 🔒 Windows SSH agent integration
- 🏠 Home Manager configuration
- 🛠️ Development-ready with common tools
- ⚡ Fast package management with `nh`
- 🐚 Modern shell experience with Zsh, Starship, and more
- 🔍 Smart command-not-found suggestions
- 📦 Ephemeral package execution with `comma`

## Prerequisites

1. Windows Subsystem for Linux (WSL2)
2. NixOS-WSL installed ([Installation Guide](https://nix-community.github.io/NixOS-WSL/print.html))
3. `npiperelay.exe` installed on Windows (via WinGet or Chocolatey)
   ```powershell
   # Using WinGet
   winget install npiperelay

   # Or using Chocolatey
   choco install npiperelay
   ```

## Initial Setup

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. Update Git configuration in `home.nix`:
   ```nix
   programs.git = {
     userName = "Your Name";
     userEmail = "your.email@example.com";
   };
   ```

3. Apply the configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

## Daily Usage

### System Management

- **Update system and home configuration**:
  ```bash
  nosa  # Alias for "nh os switch . && nh home switch ."
  ```

- **Preview changes before applying**:
  ```bash
  nos   # Dry-run of system and home-manager changes
  ```

- **View system differences**:
  ```bash
  ndiff  # Compare current and new system configurations
  ```

### Package Management

1. **Install a package temporarily (ephemeral)**:
   ```bash
   , hello  # Run 'hello' without installing
   , python  # Start a Python REPL
   ```

2. **Install a package permanently**:
   - Add to `home.packages` in `home.nix` for user packages
   - Add to `environment.systemPackages` in `configuration.nix` for system-wide packages

3. **Search for packages**:
   ```bash
   nsc package-name  # Search NixOS packages
   ```

### Development Environments

1. **Create a new development environment**:
   ```bash
   mkdir my-project && cd my-project
   devenv init
   ```

2. **Enter the environment**:
   ```bash
   devenv shell
   ```

### System Maintenance

- **Garbage collection**:
  ```bash
  ngc   # Clean old generations
  ngcd  # Dry-run of garbage collection
  ```

- **Update Flake inputs**:
  ```bash
  nix flake update  # Update all inputs
  ```

## Shell Features

### Enhanced Commands

- Modern alternatives to traditional commands:
  - `ls` → `eza` (with icons and git integration)
  - `cat` → `bat` (with syntax highlighting)
  - `cd` → `z` (smart directory jumping)
  - `find` → `fd` (user-friendly find)
  - `grep` → `rg` (ripgrep)

### Git Aliases

- `git st` - status
- `git co` - checkout
- `git br` - branch
- `git ci` - commit
- `git unstage` - reset HEAD
- `git last` - show last commit

## SSH Agent Integration

The system automatically connects to the Windows SSH agent. Your SSH keys managed in Windows will be available in NixOS-WSL.

To verify:
```bash
ssh-add -L  # Should list your Windows SSH keys
```
## Customization

1. **Add new packages**:
   Edit `home.nix` and add to `home.packages`:
   ```nix
   home.packages = with pkgs; [
     your-package
   ];
   ```

2. **Add system packages**:
   Edit `configuration.nix` and add to `environment.systemPackages`:
   ```nix
   environment.systemPackages = with pkgs; [
     your-system-package
   ];
   ```

3. **Add shell aliases**:
   Edit `home.nix` and add to `programs.zsh.shellAliases`:
   ```nix
   programs.zsh.shellAliases = {
     your-alias = "your-command";
   };
   ```

## Troubleshooting

1. **SSH agent issues**:
   - Verify npiperelay.exe installation
   - Check the systemd service: `systemctl --user status ssh-agent-proxy`
   - Verify SSH_AUTH_SOCK: `echo $SSH_AUTH_SOCK`

2. **Rebuild fails**:
   ```bash
   sudo rm /run/current-system
   sudo nixos-rebuild switch --flake .#nixos
   ```

3. **Clear nix store**:
   ```bash
   nix-collect-garbage -d
   ```

## Contributing

Feel free to submit issues and enhancement requests!

## License

[MIT](LICENSE)
