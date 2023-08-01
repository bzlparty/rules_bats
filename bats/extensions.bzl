"""Extensions for bzlmod.

Installs a bats toolchain.
Every module can define a toolchain version under the default name, "bats".
The latest of those versions will be selected (the rest discarded),
and will always be registered by rules_bats.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load(":repositories.bzl", "DEFAULT_LIBS", "bats_register_toolchain")

_DEFAULT_NAME = "bats"

bats_toolchain = tag_class(attrs = {
    "name": attr.string(doc = """\
Base name for generated repositories, allowing more than one bats toolchain to be registered.
Overriding the default is only permitted in the root module.
""", default = _DEFAULT_NAME),
    "version": attr.string(doc = "Explicit version of bats-core.", mandatory = True),
    "libs": attr.string_dict(doc = "Helper libraries for BATS", mandatory = False),
})

def _already_registered(registrations, item):
    for i in registrations:
        if i[0] == item[0] and i[1] == item[1]:
            return True
    return False

def _toolchain_extension(module_ctx):
    registrations = []
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            current = (toolchain.name, toolchain.version)
            if not _already_registered(registrations, current):
                bats_register_toolchain(
                    name = toolchain.name,
                    libs = toolchain.libs if len(toolchain.libs) > 0 else DEFAULT_LIBS,
                    version = toolchain.version,
                    register = False,
                )
                registrations.append(current)

bats = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": bats_toolchain},
)
