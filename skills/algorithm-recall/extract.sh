#!/usr/bin/env bash
# algorithm-recall cite-and-fork helper
# Takes a file path, strips test/scaffolding, returns clean implementation
# with MIT citation comment ready to paste into Filip's projects.
#
# Usage: extract.sh <path-from-mirror-root>
# Example: extract.sh Python/strings/levenshtein_distance.py

set -euo pipefail

ROOT="$HOME/Documents/research-cache/algorithms-the-algorithms"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <path-from-mirror-root>"
  echo "Example: $0 Python/strings/levenshtein_distance.py"
  exit 1
fi

REL="$1"
# Strip leading mirror root if user pasted full path
REL="${REL#$ROOT/}"
REL="${REL#/}"

FULL="$ROOT/$REL"

if [ ! -f "$FULL" ]; then
  echo "ERROR: $FULL not found" >&2
  echo "Mirror root: $ROOT" >&2
  exit 1
fi

# Detect language from extension
EXT="${REL##*.}"
case "$EXT" in
  py) COMMENT="#" ;;
  js|ts) COMMENT="//" ;;
  rs) COMMENT="//" ;;
  go) COMMENT="//" ;;
  sol) COMMENT="//" ;;
  *) COMMENT="#" ;;
esac

# Get upstream URL
LANG_DIR="${REL%%/*}"
SUBPATH="${REL#$LANG_DIR/}"
UPSTREAM_URL="https://github.com/TheAlgorithms/$LANG_DIR/blob/master/$SUBPATH"

# Print citation header
echo "$COMMENT === Adapted from TheAlgorithms/$LANG_DIR (MIT License) ==="
echo "$COMMENT Source: $UPSTREAM_URL"
echo "$COMMENT Local:  $REL"
echo "$COMMENT"
echo "$COMMENT Stripped: doctests, __main__ test blocks, verbose docstrings."
echo "$COMMENT Adapt: rename, add type hints if missing, integrate error handling per project conventions."
echo ""

# Strip strategy by language
if [ "$EXT" = "py" ]; then
  # Python: remove doctests, __main__ blocks, multi-line docstrings between def and first code line
  python3 <<PYEOF
import ast, sys

with open("$FULL") as f:
    src = f.read()

try:
    tree = ast.parse(src)
except SyntaxError:
    # Fallback: just print raw if AST fails
    print(src)
    sys.exit(0)

# Remove if __name__ == '__main__': blocks and doctest imports
new_body = []
for node in tree.body:
    if isinstance(node, ast.If):
        test = node.test
        if (isinstance(test, ast.Compare) and
            isinstance(test.left, ast.Name) and test.left.id == "__name__"):
            continue  # skip __main__ block
    if isinstance(node, ast.Import):
        if any(alias.name == "doctest" for alias in node.names):
            continue
    if isinstance(node, ast.ImportFrom):
        if node.module == "doctest":
            continue
    new_body.append(node)

tree.body = new_body

# Remove docstrings inside functions/classes that contain >>> (doctests)
class DoctestStripper(ast.NodeTransformer):
    def visit_FunctionDef(self, node):
        return self._strip_docstring(node)
    def visit_AsyncFunctionDef(self, node):
        return self._strip_docstring(node)
    def visit_ClassDef(self, node):
        return self._strip_docstring(node)
    def _strip_docstring(self, node):
        if (node.body and
            isinstance(node.body[0], ast.Expr) and
            isinstance(node.body[0].value, ast.Constant)):
            doc = node.body[0].value.value
            if isinstance(doc, str) and ">>>" in doc:
                # Replace with terse 1-line docstring (first non-empty line of original)
                lines = [l.strip() for l in doc.split("\n") if l.strip() and ">>>" not in l]
                terse = lines[0] if lines else ""
                if terse:
                    node.body[0] = ast.Expr(value=ast.Constant(value=terse))
                else:
                    node.body.pop(0)
        self.generic_visit(node)
        return node

tree = DoctestStripper().visit(tree)
ast.fix_missing_locations(tree)
print(ast.unparse(tree))
PYEOF
elif [ "$EXT" = "rs" ]; then
  # Rust: skip #[cfg(test)] blocks (rough)
  awk '
    /^#\[cfg\(test\)\]/ { skip=1 }
    skip && /^\}/ { skip=0; next }
    !skip { print }
  ' "$FULL"
elif [ "$EXT" = "go" ]; then
  # Go: skip _test.go content (this script targets impl files anyway)
  cat "$FULL"
elif [ "$EXT" = "js" ] || [ "$EXT" = "ts" ]; then
  # JS/TS: skip describe/test/it blocks (very rough)
  cat "$FULL"
else
  cat "$FULL"
fi

echo ""
echo "$COMMENT === End of TheAlgorithms snippet ==="
