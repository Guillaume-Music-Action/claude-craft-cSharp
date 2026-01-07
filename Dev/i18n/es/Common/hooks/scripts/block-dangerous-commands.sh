#!/bin/bash
# PreToolUse hook: Block dangerous shell commands
# Exit code 2 = block the command
set -e

# Read JSON input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Dangerous patterns to block
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf /*"
    "rm -rf ~"
    ":(){:|:&};:"          # Fork bomb
    "dd if=/dev/zero"
    "mkfs"
    "chmod -R 777 /"
    "chown -R"
    "> /dev/sda"
    "mv /* /dev/null"
)

# Check for dangerous patterns
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qF "$pattern"; then
        echo "BLOCKED: Dangerous command detected: $pattern" >&2
        exit 2
    fi
done

# Check for commands that modify system files
if echo "$COMMAND" | grep -qE "^(sudo|su)\s"; then
    echo "BLOCKED: Elevated privilege commands not allowed" >&2
    exit 2
fi

# Check for commands that could expose secrets
if echo "$COMMAND" | grep -qE "cat.*\.env|cat.*credentials|cat.*secret"; then
    echo "BLOCKED: Command might expose secrets" >&2
    exit 2
fi

# All checks passed
exit 0
