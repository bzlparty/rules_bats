load("@rules_bats//bats:defs.bzl", "bats_test")

bats_test(
    name = "run",
    data = ["script.sh"],
    test = "run.bats",
)

bats_test(
    name = "bc",
    test = "bc.bats",
)

bats_test(
    name = "assert",
    test = "assert.bats",
)

bats_test(
    name = "fail",
    tags = ["manual"],
    test = "fail.bats",
)
