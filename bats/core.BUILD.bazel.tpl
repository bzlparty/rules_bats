load("@rules_bats//bats:toolchain.bzl", "bats_toolchain")

filegroup(
    name = "bats_files",
    srcs = ["bin/bats"] + glob(["lib/**/*.bash", "libexec/bats-core/*"]),
    visibility = ["//visibility:public"],
)

bats_toolchain(
    name = "bats_toolchain",
    bin = ":bin/bats",
    files = ":bats_files",
    libs = {libs},
)
