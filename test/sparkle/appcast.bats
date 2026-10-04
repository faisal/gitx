#!/usr/bin/env bats
# Spec: the appcast feed offers a signed download for each stable release.

setup() {
  ROOT="$BATS_TEST_DIRNAME/../.."
  FIXTURES="$BATS_TEST_DIRNAME/fixtures"
  run ruby "$BATS_TEST_DIRNAME/render_appcast.rb" \
    "$ROOT/docs/appcast.xml" "$FIXTURES/releases.json"
  [ "$status" -eq 0 ]
  FEED="$output"
}

@test "each stable release has an enclosure pointing at its GitX.dmg" {
  echo "$FEED" | grep -q '<enclosure'
  echo "$FEED" | grep -q 'url="https://github.com/gitx/gitx/releases/download/1.5.9/GitX.dmg"'
}

@test "the enclosure length is the dmg asset size" {
  echo "$FEED" | grep -q 'length="4242"'
}

@test "the enclosure carries the EdDSA signature from the release body" {
  echo "$FEED" | grep -q 'sparkle:edSignature="FIXTURE_SIGNATURE_BASE64=="'
}

@test "prerelease versions are not offered" {
  ! echo "$FEED" | grep -q '1.6.0-beta1'
}

@test "the feed no longer says automatic updates are broken" {
  ! echo "$FEED" | grep -qi 'automatic updates are not working'
}

@test "the feed no longer marks releases as informational-only" {
  ! echo "$FEED" | grep -q 'informationalUpdate'
}
