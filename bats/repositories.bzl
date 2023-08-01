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

def _download_and_extract(ctx, package, version):
    url = "https://github.com/bats-core/{package}/archive/refs/tags/v{version}.tar.gz".format(
        package = package,
        version = version,
    )
    ctx.download_and_extract(
        url = url,
        integrity = TOOL_VERSIONS[package][version],
        stripPrefix = "%s-%s" % (package, version),
    )

_BATS_CORE_ATTRS = {
    "version": attr.string(mandatory = True),
    "libs": attr.string_dict(mandatory = False),
}

def _bats_pkg_repo_impl(repository_ctx, package, template, substitutions = {}):
    _download_and_extract(
        repository_ctx,
        package = package,
        version = repository_ctx.attr.version,
    )

    repository_ctx.template(
        "BUILD.bazel",
        template,
        substitutions = substitutions,
    )

def _bats_core_repo_impl(repository_ctx):
    _bats_pkg_repo_impl(
        repository_ctx,
        package = "bats-core",
        substitutions = {
            "{libs}": json.encode(repository_ctx.attr.libs),
        },
        template = Label("//bats:core.BUILD.bazel.tpl"),
    )

bats_core_repository = repository_rule(
    _bats_core_repo_impl,
    doc = "Fetach bats-core repository",
    attrs = _BATS_CORE_ATTRS,
)

_BATS_HELPER_ATTRS = {
    "version": attr.string(mandatory = True),
    "lib": attr.string(mandatory = True),
}

def _bats_lib_repo_impl(repository_ctx):
    _bats_pkg_repo_impl(
        repository_ctx,
        package = repository_ctx.attr.lib,
        template = Label("//bats:helper.BUILD.bazel"),
    )

bats_lib_repository = repository_rule(
    _bats_lib_repo_impl,
    doc = "Fetch BATS helper library",
    attrs = _BATS_HELPER_ATTRS,
)

_LATEST_BATS_CORE_VERSION = "1.10.0"
_LATEST_BATS_ASSERT_VERSION = "2.1.0"
_LATEST_BATS_SUPPORT_VERSION = "0.3.0"
_DEFAULT_NAME = "bats"
DEFAULT_LIBS = {
    "bats-support": _LATEST_BATS_SUPPORT_VERSION,
    "bats-assert": _LATEST_BATS_ASSERT_VERSION,
}

def bats_register_toolchain(name = _DEFAULT_NAME, version = _LATEST_BATS_CORE_VERSION, libs = DEFAULT_LIBS, register = True):
    """Basic toolchain wrapper

    Args:
      name: Name of the toolchain
      libs: dict of helper libs and their version
      version: version of bats-core
      register: Register the toolchain
     """

    lib_repo_map = {}
    for (lib, lib_version) in libs.items():
        lib_repo_name = "%s_%s" % (name, lib)
        bats_lib_repository(
            name = lib_repo_name,
            lib = lib,
            version = lib_version,
        )
        lib_repo_map["@%s//:files" % lib_repo_name] = lib

    bats_core_repository(
        name = name,
        libs = lib_repo_map,
        version = version,
    )

    if register:
        native.register_toolchains("@%s_toolchain//:toolchain" % name)

    toolchains_repo(
        name = name + "_toolchain",
        user_repository_name = name,
    )
