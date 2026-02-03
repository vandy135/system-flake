{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Format with: nix fmt
    formatter = pkgs.alejandra;

    # Enter with: nix develop
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        nil
      ];
    };
  };
}
