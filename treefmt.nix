# Formatters only. Linters stay in tests/check.sh so `nix fmt` never fails
# on something it cannot fix.
{
  projectRootFile = "flake.nix";

  programs = {
    nixpkgs-fmt.enable = true;
    shfmt = {
      enable = true;
      indent_size = 4;
      simplify = false; # keep `-s` off: it rewrites code, not just whitespace
    };
    stylua.enable = true; # reads ./stylua.toml
    taplo.enable = true;
    # Sorts any block fenced by `keep-sorted` start/end marker comments.
    keep-sorted.enable = true;
  };

  settings.formatter = {
    # -ci: indent `case` bodies (matches the old tests/format.sh flags).
    shfmt.options = [ "-ci" ];
    # Prose that merely *mentions* the markers would otherwise be parsed as one.
    keep-sorted.excludes = [ "*.md" ];
  };
}
