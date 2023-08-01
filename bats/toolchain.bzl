"""This module implements the BATS toolchain rule.
"""

_bats_info_fields = {
    "bin": "BATS binary",
    "files": "Files to use the package",
    "libs": "Helper files to include",
}

BatsInfo = provider(
    doc = "Information about the BATS setup.",
    fields = _bats_info_fields,
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _find_load_file(files):
    for file in files:
        if file.path.endswith("load.bash"):
            return file.path
    fail("Can't find `load.bash` file")

def _target_tool_short_path(path):
    return ("../" + path[len("external/"):]) if path.startswith("external/") else path

def _bats_toolchain_impl(ctx):
    bin_files = ctx.attr.bin.files.to_list()
    bin_path = _to_manifest_path(ctx, bin_files[0])
    files = ctx.attr.files.files.to_list()
    variables = {}

    for (f, n) in ctx.attr.libs.items():
        lib_files = f.files.to_list()
        load_file_path = _find_load_file(lib_files)
        files += lib_files
        variables[n.upper().replace("-", "_")] = _target_tool_short_path(load_file_path)

    default = DefaultInfo(
        files = depset(files),
        runfiles = ctx.runfiles(files = files),
    )

    batsinfo = BatsInfo(
        bin = bin_path,
        files = files,
    )

    template_variables = platform_common.TemplateVariableInfo(variables)

    toolchain_info = platform_common.ToolchainInfo(
        batsinfo = batsinfo,
        default = default,
        template_variables = template_variables,
    )

    return [
        default,
        toolchain_info,
        template_variables,
    ]

bats_toolchain = rule(
    implementation = _bats_toolchain_impl,
    attrs = {
        "bin": attr.label(
            doc = "BATS binary file",
            mandatory = True,
            allow_single_file = True,
        ),
        "files": attr.label(
            doc = "BATS files needed to execute the tests",
            mandatory = True,
            allow_files = True,
        ),
        "libs": attr.label_keyed_string_dict(
            doc = "BATS helper libraries",
        ),
    },
    doc = """BATS toolchain
See: https://github.com/bats-core""",
)
