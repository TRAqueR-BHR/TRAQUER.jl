#!/bin/bash
set -euo pipefail

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  echo "Usage: $0 <parent-key-hex> <salt-hex> <info> [base64|hex]" >&2
  exit 1
fi

MASTER_KEY_HEX="$1"
SALT_HEX="$2"
INFO="$3"
CHILD_KEY_FORMAT="${4:-base64}"

# Generate the derived key using HKDF (outputs hex with colons)
HEX_OUTPUT=$(openssl kdf \
  -keylen 32 \
  -kdfopt digest:SHA256 \
  -kdfopt hexkey:$MASTER_KEY_HEX \
  -kdfopt hexsalt:$SALT_HEX \
  -kdfopt info:"$INFO" \
  HKDF)

# Remove colons from the hex output
CLEAN_HEX=$(echo "$HEX_OUTPUT" | tr -d ':' | tr '[:upper:]' '[:lower:]')

# Convert the clean hex to base64
BASE64_OUTPUT=$(echo "$CLEAN_HEX" | python3 -c "import sys, binascii; print(binascii.b2a_base64(binascii.unhexlify(sys.stdin.read().strip())).decode().strip())")

# Verify by converting base64 back to hex
VERIFIED_HEX=$(echo "$BASE64_OUTPUT" | python3 -c "import sys, binascii; print(binascii.hexlify(binascii.a2b_base64(sys.stdin.read().strip())).decode())")

# Output the encoded child password
echo "original hex: $HEX_OUTPUT"
echo "Hex: $CLEAN_HEX"
echo "Base64: $BASE64_OUTPUT"
# echo "Verified Hex: $VERIFIED_HEX"

case "${CHILD_KEY_FORMAT,,}" in
  base64)
    echo "Child key: $BASE64_OUTPUT"
    ;;
  hex)
    echo "Child key: $CLEAN_HEX"
    ;;
  *)
    echo "Unsupported child key format: $CHILD_KEY_FORMAT. Expected 'base64' or 'hex'." >&2
    exit 1
    ;;
esac
