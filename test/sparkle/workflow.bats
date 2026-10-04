#!/usr/bin/env bats
# Spec: the release pipeline passes the Sparkle signature from the universal
# build job to the release job, where it is written into the release body.

setup() {
  WORKFLOW="$BATS_TEST_DIRNAME/../../.github/workflows/BuildPR.yml"
}

@test "build-gitx-universal exposes sparkle_signature as a job output" {
  run ruby -ryaml -e '
    job = YAML.load_file(ARGV[0])["jobs"]["build-gitx-universal"]
    puts job.fetch("outputs", {}).fetch("sparkle_signature", "MISSING")
  ' "$WORKFLOW"
  [ "$status" -eq 0 ]
  [ "$output" != "MISSING" ]
}

@test "release job receives the signature from build-gitx-universal" {
  run ruby -ryaml -e '
    release = YAML.load_file(ARGV[0])["jobs"]["release"]
    puts Array(release["needs"]).include?("build-gitx-universal")
  ' "$WORKFLOW"
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}

@test "release job writes the signature into the release body as a marker" {
  run ruby -ryaml -e '
    release = YAML.load_file(ARGV[0])["jobs"]["release"]
    text = release["steps"].map { |s| s["run"].to_s + s["with"].to_s }.join("\n")
    puts text.include?("sparkle-edSignature:")
  ' "$WORKFLOW"
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
