"""Detection of whether bzlmod is enabled."""

def is_bzlmod_enabled():
    """Whether bzlmod is enabled, as opposed to WORKSPACE mode.

    Canonical repository names start with `@@` only when bzlmod is enabled.

    Returns:
      True if bzlmod is enabled.
    """
    return str(Label("@rules_haskell//:BUILD.bazel")).startswith("@@")
