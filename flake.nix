{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.crane.url = "github:ipetkov/crane";

  outputs = {
    crane,
    flake-utils,
    nixpkgs,
    rust-overlay,
    self,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {inherit system overlays;};
      rust = pkgs.rust-bin.beta.latest.default.override {
        targets = ["wasm32-wasi"];
      };
      craneLib = (crane.mkLib pkgs).overrideToolchain rust;
      test = craneLib.buildPackage {
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        cargoExtraArgs = "--target wasm32-wasi";
        doCheck = false;
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [rust-bin.beta.latest.default];
      };
      packages.default = test;
    });
}
