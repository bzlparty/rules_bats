"""This module implements the language-specific toolchain rule.
"""

BatsInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "target_tool_path": "Path to the tool executable for the target platform.",
        "tool_files": """Files required in runfiles to make the tool executable available.

May be empty if the target_tool_path points to a locally installed tool binary.""",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _bats_toolchain_impl(ctx):
    if ctx.attr.target_tool and ctx.attr.target_tool_path:
        fail("Can only set one of target_tool or target_tool_path but both were set.")

    tool_files = []
    target_tool_path = ctx.attr.target_tool_path

    if ctx.attr.target_tool:
        tool_files = ctx.attr.target_tool.files.to_list()
        target_tool_path = _to_manifest_path(ctx, tool_files[0])

    if ctx.attr.target_tool_files:
        tool_files = tool_files + ctx.attr.target_tool_files.files.to_list()

    template_variables = platform_common.TemplateVariableInfo({
        "BATS_BIN": target_tool_path,
    })

    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )

    batsinfo = BatsInfo(
        target_tool_path = target_tool_path,
        tool_files = tool_files,
    )

    toolchain_info = platform_common.ToolchainInfo(
        batsinfo = batsinfo,
        template_variables = template_variables,
        default = default,
    )

    return [
        default,
        toolchain_info,
        template_variables,
    ]

bats_toolchain = rule(
    implementation = _bats_toolchain_impl,
    attrs = {
        "target_tool": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_single_file = True,
        ),
        "target_tool_files": attr.label(
            doc = "Files required in runfiles to make the tool executable available.",
            mandatory = False,
            allow_files = True,
        ),
        "target_tool_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
    },
    doc = """Defines a bats compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
