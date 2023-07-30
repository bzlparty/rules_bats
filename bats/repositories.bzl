"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//bats/private:toolchains_repo.bzl", "toolchains_repo")
load("//bats/private:versions.bzl", "TOOL_VERSIONS")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def rules_bats_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz",
        ],
    )

_DOC = "Fetch external tools needed for bats toolchain"
_ATTRS = {
    "version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
}

def _bats_repo_impl(repository_ctx):
    url = "https://github.com/bats-core/bats-core/archive/refs/tags/v{0}.tar.gz".format(
        repository_ctx.attr.version,
    )
    repository_ctx.download_and_extract(
        url = url,
        integrity = TOOL_VERSIONS[repository_ctx.attr.version],
        stripPrefix = "bats-core-%s" % repository_ctx.attr.version,
    )
    repository_ctx.template("BUILD.bazel", Label("//bats:core.BUILD.bazel"))

bats_repositories = repository_rule(
    _bats_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def bats_register_toolchains(name, register = True, **kwargs):
    bats_repositories(
        name = name,
        version = kwargs["bats_version"],
    )

    if register:
        native.register_toolchains("@%s_toolchains//:toolchain" % name)

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
