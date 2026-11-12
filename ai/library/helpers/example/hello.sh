#!/usr/bin/env bash
# @language: bash
# @created: 2026-11-12
#
# Example helper showing the expected format. Real helpers hold reusable code
# (not project-specific business logic). Register each in helpers-index.json.
#
# USAGE: hello.sh [name]
# OUTPUT: A greeting line.
#
# EXAMPLES:
#   $ hello.sh world
#   hello, world

set -euo pipefail
echo "hello, ${1:-world}"
