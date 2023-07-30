"Public API re-exports"

def _target_tool_short_path(path):
    return ("../" + path[len("external/"):]) if path.startswith("external/") else path

def _bats_test_impl(ctx):
  bats_bin = _target_tool_short_path(ctx.toolchains["@rules_bats//bats:toolchain_type"].batsinfo.target_tool_path)
  bats_files = ctx.toolchains["@rules_bats//bats:toolchain_type"].batsinfo.tool_files
  launcher = ctx.actions.declare_file("%s_bats_test.sh" % ctx.attr.name)

  files = ctx.files.data + bats_files + [ctx.file.spec]

  ctx.actions.expand_template(
    template = ctx.file._template,
    output = launcher,
    substitutions = {
      "{bats_bin}": bats_bin,
      "{bats_args}": " ".join(ctx.attr.args),
      "{bats_spec}": ctx.file.spec.short_path,
    },
    is_executable = True,
  )

  runfiles = ctx.runfiles(files = files)

  return [
    DefaultInfo(
      executable = launcher,
      runfiles = runfiles,
    )
  ]

bats_test = rule(
  _bats_test_impl,
  attrs = {
    "spec": attr.label(
      mandatory = True,
      allow_single_file = True,
    ),
    "data": attr.label_list(
        mandatory = False,
        allow_files = True,
        default = [],
    ),
    "_template": attr.label(
        allow_single_file = True,
        default = Label("//bats:bats.sh.tpl"),
    ),
  },
  test = True,
  toolchains = ["@rules_bats//bats:toolchain_type"],
)

def example():
    """This is an example"""
    pass
