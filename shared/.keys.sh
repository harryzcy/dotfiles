#!/usr/bin/env bash
# Public keys trusted to verify downloaded releases
# shellcheck disable=SC2034

# Google's Linux package signing key, from https://dl.google.com/linux/linux_signing_key.pub
# Compute the primary key fingerprint with:
#   curl -fsSL https://dl.google.com/linux/linux_signing_key.pub |
#     gpg --show-keys --with-colons | awk -F: '$1 == "fpr" { print $10; exit }'
GOOGLE_LINUX_SIGNING_KEY_FINGERPRINT="EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796"

# Zig releases, from https://ziglang.org/download/
ZIG_MINISIGN_PUBLIC_KEY="RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U"
