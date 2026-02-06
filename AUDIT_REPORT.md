# NixOS System-Flake Audit Report

Repo: `/home/titan/.openclaw/workspace/system-flake/`

Date: 2026-02-06

## Executive Summary

This flake is small, modular, and generally well-structured (flake-parts, host directories, reusable NixOS + Home Manager modules). There are **no obvious hardcoded secrets** in the repo. Several security- and DX-oriented recommendations from `RECOMMENDATIONS.md` have been implemented (PipeWire/Bluetooth/utils module, enhancements including firewall/ZRAM/earlyoom, basic docs).

Main risks / gaps:

- **Reproducibility & supply-chain**: the `claude` wrapper uses `npx -y …` which downloads and executes code at runtime (non-reproducible; higher supply-chain risk). The alternative `buildNpmPackage` block contains placeholder hashes and would fail if enabled.
- **Lock-screen hardening**: `ignore-empty-password = true` can allow unlocking if the user account has an empty password (or if misconfigured).
- **Network hardening defaults**: firewall is enabled, but some settings trade security for convenience (e.g., `checkReversePath = "loose"`; DNSSEC `allow-downgrade`; fallback DNS to public resolvers). These may be fine, but should be explicit per-host.
- **Maintainability**: host files duplicate core settings (nix settings, user, bootloader, packages). You’ll benefit from a small “base” module/profile to reduce repetition.

---

## Findings (by severity)

### Critical

No critical issues found.

### High

#### H-1: Non-reproducible / higher-risk `npx` execution for Claude Code
**Where**: `modules/home/programs/claude-code.nix`

- Default behavior runs:
  ```sh
  npx -y @anthropic-ai/claude-code
  ```
  which downloads and executes remote JS at runtime.
- This bypasses Nix’s normal reproducibility guarantees and increases exposure to upstream compromise, registry attacks, or MITM of npm ecosystem.

**Recommendation** (prefer one):

1) **Package it reproducibly** (recommended): use `buildNpmPackage` with correct hashes and set the module default to that package.

   Example (sketch):
   ```nix
   claudeCodePkg = pkgs.buildNpmPackage {
     pname = "claude-code";
     version = "2.1.29";
     src = pkgs.fetchFromGitHub {
       owner = "anthropics";
       repo = "claude-code";
       rev = "v2.1.29";
       hash = "sha256-…";
     };
     npmDepsHash = "sha256-…";
     dontNpmBuild = true;
   };

   # then default = claudeCodePkg
   ```

2) If you keep `npx`, **make it explicit and opt-in**, and document the tradeoff:
   - Rename option to `homeModules.claudeCode.installMethod = "npx";` but set default to packaged method.
   - Add a warning in README.

3) At minimum, **pin a version** with npx:
   ```sh
   npx -y @anthropic-ai/claude-code@2.1.29
   ```
   (Still non-reproducible, but reduces surprise upgrades.)

---

### Medium

#### M-1: Lock screen allows empty-password unlock
**Where**: `modules/home/programs/swaylock.nix`

- Setting:
  ```nix
  ignore-empty-password = true;
  ```
  If the account password is accidentally empty, the lock screen becomes ineffective.

**Recommendation**:
- Set this to `false` (or remove entirely):
  ```nix
  ignore-empty-password = false;
  ```
- If you truly need empty-password behavior for a special case, gate it behind an option and default it off.

#### M-2: `swayidle` DPMS commands reference Hyprland
**Where**: `modules/home/programs/swaylock.nix`

- Uses `${pkgs.hyprland}/bin/hyprctl dispatch dpms …` while the system is configured around **niri**.
- Likely doesn’t work under niri and may pull in **Hyprland** (bigger closure) depending on evaluation.

**Recommendation**:
- Use compositor-agnostic tooling (e.g., `wlr-randr`, `swaymsg` for wlroots compositors where appropriate, or niri’s tooling if available), or make DPMS commands configurable.

#### M-3: DNS and reverse-path filtering settings trade security for convenience
**Where**: `modules/nixos/system/essentials.nix`, `modules/nixos/system/enhancements.nix`

- `services.resolved.dnssec = "allow-downgrade"` permits downgrade attacks.
- `services.resolved.fallbackDns = [ "1.1.1.1" "8.8.8.8" ]` is fine but should be an explicit policy decision.
- `networking.firewall.checkReversePath = "loose"` reduces spoofing protection (often needed for VPNs, but not always).

**Recommendation**:
- Consider per-host tuning:
  - Workstation on trusted networks: may keep current.
  - Laptop/public networks: tighten.

Example:
```nix
services.resolved.dnssec = "true"; # or "false" explicitly
networking.firewall.checkReversePath = "strict";
```

#### M-4: `inetutils` (telnet/ftp) installed system-wide
**Where**: `modules/nixos/system/essentials.nix`

- `inetutils` includes legacy tools (telnet/ftp) that are rarely needed and can increase attack surface/footguns.

**Recommendation**:
- Replace with more focused packages (e.g., `inetutils` → `iputils` + `traceroute` + `bind` tools already present) or move to an optional “debug tools” toggle.

---

### Low

#### L-1: Duplication across hosts (base settings)
**Where**: `hosts/control-tower/default.nix`, `hosts/launchpad/default.nix`

Duplicated blocks:
- `nix.settings.experimental-features`, `auto-optimise-store`
- Bootloader config
- NetworkManager enablement
- `users.users.titan` definition
- Common packages (`git`, `vim`)

**Recommendation**:
Create a shared host base module, e.g. `modules/nixos/profiles/base.nix`:
```nix
{ lib, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  networking.networkmanager.enable = true;

  users.users.titan = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
```
Then import it from each host.

#### L-2: `nixos-hardware` input is unused
**Where**: `flake.nix`

You include `nixos-hardware` but do not import any of its modules.

**Recommendation**:
- Either remove it until needed, or use it explicitly per-host (improves correctness on laptops/known hardware).

#### L-3: Consider making user management fully declarative
**Where**: hosts

You define the user, but do not set `users.mutableUsers = false;` or a password source.

**Recommendation**:
- Once you add secrets management (sops-nix), consider:
  ```nix
  users.mutableUsers = false;
  users.users.titan.hashedPasswordFile = config.sops.secrets."user/password".path;
  ```

#### L-4: Host disk device paths are hardcoded
**Where**: `hosts/*/default.nix` via `hardwareModules.disko.device`

This is expected for disko, but it is easy to accidentally format the wrong disk if copied.

**Recommendation**:
- Keep as-is, but consider documenting each host’s disk identifier (by-id) and prefer stable `/dev/disk/by-id/...` paths.

---

## Best Practices Review

### Flake structure & organization
**Good**:
- Uses `flake-parts` with `parts/nixos.nix` and `parts/dev.nix`.
- Clear host separation: `hosts/<name>/default.nix` and `home.nix`.
- Shared modules split into `modules/nixos/*` and `modules/home/*`.

**Opportunities**:
- Add `perSystem` checks (e.g., `nix flake check`) and CI if desired.
- Add a `lib/` folder for helper functions (also suggested in `RECOMMENDATIONS.md`).

### Reproducibility
**Good**:
- Inputs are pinned via `flake.lock`.
- `pkgs-unstable` is imported in a controlled way via `specialArgs` (still pinned).

**Concern**:
- Runtime `npx` usage breaks the reproducibility story (see H-1).

### Home-manager integration
**Good**:
- `home-manager.useGlobalPkgs = true; useUserPackages = true;`
- `extraSpecialArgs` passes `pkgs-unstable` and `inputs` for advanced modules.

---

## Performance / Optimization

**Good**:
- Btrfs with `compress=zstd` and `noatime`.
- ZRAM enabled (50% default) and `earlyoom` enabled.
- `nix.settings.auto-optimise-store = true`.

**Potential improvements**:
- Avoid pulling in large packages unintentionally (e.g., Hyprland via swayidle DPMS commands).
- Consider optionalizing heavy utilities into toggles (debug tools, GUI utilities, etc.).

---

## `RECOMMENDATIONS.md` status (notable items)

Addressed (✅ in current repo):
- PipeWire audio module implemented and enabled on both hosts (`systemModules.essentials.enable = true`).
- Bluetooth + Blueman enabled through essentials.
- Common utilities added.
- Enhancements module added and enabled on `launchpad` (`systemModules.enhancements.enable = true`), including:
  - Plymouth (enabled by default)
  - Firewall enabled with logging
  - ZRAM
  - earlyoom
  - polkit agent and nm-applet via systemd user services
  - XDG portals (enhancements module provides more portals)
- Obsidian module exists and is enabled on `launchpad`.
- Claude Code module exists and is enabled on `launchpad`.

Not yet addressed / partial:
- **Secrets management with sops-nix**: input is present, but no `sops` config or encrypted secrets are in-tree.
- Additional hardening module (AppArmor/auditd/sysctl suggestions) not implemented.
- Printing/Flatpak/GPG recommendations not implemented.

---

## Quick Win Patch List

1) Disable empty-password unlock in swaylock:
```nix
programs.swaylock.settings.ignore-empty-password = false;
```

2) Remove/replace Hyprland DPMS calls in swayidle; make them configurable.

3) Make Claude Code reproducible (package it) or pin the npx version and document the risk.

4) Add a shared base module to reduce host duplication.

5) If desired, introduce sops-nix with `.sops.yaml` + `secrets/` and migrate passwords/API keys out of configs.
