load "$BATS_SUPPORT"
load "$BATS_ASSERT"

@test "assert" {
  assert [ 0 -lt 1 ]
}
