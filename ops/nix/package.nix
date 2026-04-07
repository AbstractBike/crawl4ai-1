# Build derivation for crawl4ai.
# Receives `src` as argument — does not fetch internally.
{ lib, python3Packages, src }:
python3Packages.buildPythonApplication {
  pname = "crawl4ai";
  version = "0.1.0";
  inherit src;
  # dependencies will be added later
}
