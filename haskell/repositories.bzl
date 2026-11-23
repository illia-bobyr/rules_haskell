"""Workspace rules (repositories)"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":private/ghc_ci.bzl", "ghc_default_version")
load(
    ":private/versions.bzl",
    "check_bazel_version_compatible",
)

_rules_nixpkgs_version = "0.14.1"
_rules_nixpkgs_sha256 = "54025689367205b835198677e686d8208b570bfd84e6872684ae657747673b97"

# Also applied to the modules in the local registry, see `registry/modules/rules_nixpkgs_*`.
_rules_nixpkgs_patches = {
    # `py_runtime_pair` from `@bazel_tools` fails in Bazel 8, and native `py_runtime` is gone in
    # Bazel 9.  See https://github.com/tweag/rules_nixpkgs/pull/691
    "python": ["@rules_haskell//haskell:private/rules_nixpkgs_python-rules_python.diff"],
    # `rules_go` >= 0.57 requires `go_toolchain(pack = ...)`.
    # See https://github.com/tweag/rules_nixpkgs/issues/667
    "go": ["@rules_haskell//haskell:private/rules_nixpkgs_go-pack.diff"],
}

_rules_sh_version = "v0.5.0"
_rules_sh_sha256 = "48b12cb1b2536ef6d8aa6111549098794aa05d21c8cf400493b842943636c709"

def rules_haskell_dependencies_bzlmod():
    """Provide rules_haskell dependencies which are not available as bzlmod modules."""

    maybe(
        ghc_default_version,
        name = "rules_haskell_ghc_version",
    )

def rules_haskell_dependencies():
    """Provide all repositories that are necessary for `rules_haskell` to function."""
    if "bazel_version" in dir(native):
        check_bazel_version_compatible(native.bazel_version)

    maybe(
        http_archive,
        name = "package_metadata",
        strip_prefix = "supply-chain-0.0.3/metadata",
        urls = [
            "https://github.com/bazel-contrib/supply-chain/releases/download/v0.0.3/supply-chain-v0.0.3.tar.gz",
        ],
        sha256 = "0e89367f1cb6d93a5a1afea4b55b11ea6b28f63f653b47154153677ca7d4afea",
    )

    maybe(
        http_archive,
        name = "platforms",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/1.1.0/platforms-1.1.0.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/1.1.0/platforms-1.1.0.tar.gz",
        ],
        sha256 = "dbad4a23abcca6171e47b79edc53bd6a41067a3b75f9e8b104656b459ff25046",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
        ],
        sha256 = "37cdfbc6faefea94f7b37760a305c98c08981116c2bc9e821e3b423221fad8c8",
    )

    maybe(
        http_archive,
        name = "bazel_features",
        sha256 = "2ed1fdce7e51ba2149dfab73eab6e402217c8e27d17e1d4a48d4d86bdd9eaef6",
        strip_prefix = "bazel_features-1.55.0",
        url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.55.0/bazel_features-v1.55.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_cc",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.2.28/rules_cc-0.2.28.tar.gz"],
        sha256 = "0c51346fe5e7d2ee0b64a66623df0753bbb365877e6f85b8590e8de70448633e",
        strip_prefix = "rules_cc-0.2.28",
    )

    # required by rules_cc: the C++ toolchain it configures loads `@apple_support`
    maybe(
        http_archive,
        name = "apple_support",
        sha256 = "2c1990c275a451ae20c14550770638a948fd0096e1f4f9c38fe1cf9fb2352bcf",
        url = "https://github.com/bazelbuild/apple_support/releases/download/2.12.0/apple_support.2.12.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_java",
        sha256 = "0ad9898f81f8a3caf143fdbcf6229dbbff5da398b04c44c1c99c24888469a176",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/9.9.0/rules_java-9.9.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "693759df31e7cd2efa44378207a7d487c40145d32a54878005af47dee27bef72",
        strip_prefix = "rules_python-2.5.1",
        url = "https://github.com/bazel-contrib/rules_python/releases/download/2.5.1/rules_python-2.5.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_sh",
        urls = [
            "https://github.com/tweag/rules_sh/releases/download/{TAG}/rules_sh-{VERSION}.tar.gz".format(
                TAG = _rules_sh_version,
                VERSION = _rules_sh_version.lstrip("v"),
            ),
        ],
        sha256 = _rules_sh_sha256,
        strip_prefix = "rules_sh-%s" % _rules_sh_version.lstrip("v"),
    )

    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "20721f63908879c083f94869e618ea8d4ff5edb91ff9a72a2ebee357fdbc352d",
        strip_prefix = "rules_shell-0.8.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.8.0/rules_shell-v0.8.0.tar.gz",
    )

    if "io_tweag_rules_nixpkgs" not in native.existing_rules():
        # N.B. rules_nixpkgs was split into separate components, which need to be loaded separately
        #
        # See https://github.com/tweag/rules_nixpkgs/issues/182 for the rational

        strip_prefix = "rules_nixpkgs-%s" % _rules_nixpkgs_version

        rules_nixpkgs_url = \
            "https://github.com/tweag/rules_nixpkgs/releases/download/v{version}/{prefix}.tar.gz".format(
                version = _rules_nixpkgs_version,
                prefix = strip_prefix,
            )

        http_archive(
            name = "io_tweag_rules_nixpkgs",
            strip_prefix = strip_prefix,
            urls = [rules_nixpkgs_url],
            sha256 = _rules_nixpkgs_sha256,
        )

        # required by rules_nixpkgs
        http_archive(
            name = "rules_nodejs",
            strip_prefix = "rules_nodejs-6.7.7",
            sha256 = "f87453e0d6a97b4d2e6d22070a447b6d304727bf61ff8e31ce25ded0319005dd",
            urls = ["https://github.com/bazel-contrib/rules_nodejs/releases/download/v6.7.7/rules_nodejs-v6.7.7.tar.gz"],
        )

        # required by rules_nodejs
        maybe(
            http_archive,
            name = "bazel_lib",
            sha256 = "2a5ab58b8c021f10ce81d354e66ec4822b01188a2fa6c57be15c7381f8911ced",
            strip_prefix = "bazel-lib-3.8.0",
            url = "https://github.com/bazel-contrib/bazel-lib/releases/download/v3.8.0/bazel-lib-v3.8.0.tar.gz",
        )

        http_archive(
            name = "rules_nixpkgs_core",
            strip_prefix = strip_prefix + "/core",
            urls = [rules_nixpkgs_url],
            sha256 = _rules_nixpkgs_sha256,
        )

        for toolchain in ["cc", "java", "python", "go", "rust", "posix", "nodejs"]:
            http_archive(
                name = "rules_nixpkgs_" + toolchain,
                strip_prefix = strip_prefix + "/toolchains/" + toolchain,
                urls = [rules_nixpkgs_url],
                sha256 = _rules_nixpkgs_sha256,
                patches = _rules_nixpkgs_patches.get(toolchain, []),
                patch_args = ["-p1"],
            )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "ba4bbe69f788b6f6fac7938fab681f21a222998d3eeb36f01bd8c6f8e701ba90",
        strip_prefix = "protobuf-33.6",
        urls = [
            "https://github.com/protocolbuffers/protobuf/releases/download/v33.6/protobuf-33.6.bazel.tar.gz",
        ],
    )
    maybe(
        http_archive,
        name = "abseil-cpp",
        urls = [
            "https://github.com/abseil/abseil-cpp/releases/download/20250512.1/abseil-cpp-20250512.1.tar.gz",
        ],
        sha256 = "9b7a064305e9fd94d124ffa6cc358592eb42b5da588fb4e07d09254aa40086db",
        strip_prefix = "abseil-cpp-20250512.1",
    )

    maybe(
        http_archive,
        name = "aspect_rules_js",
        sha256 = "2cfb3875e1231cefd3fada6774f2c0c5a99db0070e0e48ea398acbff7c6c765b",
        strip_prefix = "rules_js-1.42.3",
        url = "https://github.com/aspect-build/rules_js/releases/download/v1.42.3/rules_js-v1.42.3.tar.gz",
    )

    rules_haskell_dependencies_bzlmod()

    # Dependency of com_google_protobuf.
    # TODO(judahjacobson): this is a bit of a hack.
    # We can't call that repository's protobuf_deps() function
    # from here, because load()ing it from this .bzl file would lead
    # to a cycle:
    # https://github.com/bazelbuild/bazel/issues/1550
    # https://github.com/bazelbuild/bazel/issues/1943
    # For now, just hard-code the subset that's needed to use `protoc`.
    # Alternately, consider adding another function from another
    # .bzl file that needs to be called from WORKSPACE, similar to:
    # https://github.com/grpc/grpc/blob/8c9dcf7c35e489c2072a9ad86635dbc4e28f88ea/bazel/grpc_extra_deps.bzl#L10
    maybe(
        http_archive,
        name = "zlib",
        build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
        sha256 = "02dd159783677a749c04adbdd02b55b8a2bcc7e054f51b76b549199a916ad584",
        strip_prefix = "zlib-1.4",
        urls = ["https://github.com/madler/zlib/releases/download/v1.4/zlib-1.4.tar.gz"],
    )
    maybe(
        http_archive,
        name = "rules_pkg",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/1.3/rules_pkg-1.3.0.tar.gz",
            "https://github.com/bazelbuild/rules_pkg/releases/download/1.3/rules_pkg-1.3.0.tar.gz",
        ],
        sha256 = "e41eca2339d1d38b824b8f7fae81ca24885f2d91011243bd1080ac85dcb9a3a3",
    )

    # For --incompatible_disable_starlark_host_transitions support (default in bazel 7)
    # Temporarily overrides the rules_licence that comes with bazel to workaround
    # https://github.com/bazelbuild/bazel/issues/17032#issuecomment-1548459728
    maybe(
        http_archive,
        name = "rules_license",
        sha256 = "26d4021f6898e23b82ef953078389dd49ac2b5618ac564ade4ef87cced147b38",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_license/releases/download/1.0.0/rules_license-1.0.0.tar.gz",
            "https://github.com/bazelbuild/rules_license/releases/download/1.0.0/rules_license-1.0.0.tar.gz",
        ],
    )

def haskell_repositories():
    """Alias for rules_haskell_dependencies

    Deprecated:
      Use rules_haskell_dependencies instead.
    """
    rules_haskell_dependencies()
