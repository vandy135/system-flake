# NixOS Configuration

Modular NixOS configuration using [flake-parts](https://flake.parts/).

## Structure

```
.
├── flake.nix              # Entry point
├── parts/
│   ├── nixos.nix          # NixOS configurations
│   └── dev.nix            # Dev shells, formatter
├── modules/
│   ├── nixos/             # Shared NixOS modules
│   └── home/              # Shared home-manager modules
├── hosts/
│   ├── launchpad/         # Host: launchpad
│   └── control-tower/     # Host: control-tower
└── scripts/
    └── generate-hardware-conf
```

## Hosts

| Host | Description |
|------|-------------|
| `launchpad` | Primary workstation |
| `control-tower` | Secondary machine |

## Usage

### Generate hardware configuration

```bash
./scripts/generate-hardware-conf launchpad
```

### Build and switch

```bash
sudo nixos-rebuild switch --flake .#launchpad
```

### Update inputs

```bash
nix flake update
```

### Format code

```bash
nix fmt
```

### Enter dev shell

```bash
nix develop
```

## Adding a new host

1. Create `hosts/<hostname>/default.nix` and `hosts/<hostname>/home.nix`
2. Add to `parts/nixos.nix`:
   ```nix
   flake.nixosConfigurations = {
     # ...
     new-host = mkHost "new-host";
   };
   ```
3. Generate hardware config: `./scripts/generate-hardware-conf <hostname>`

## Adding home-manager modules

1. Create module in `modules/home/programs/<name>.nix`
2. Import in `modules/home/default.nix`
3. Enable in host's `home.nix`
