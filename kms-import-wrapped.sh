#!/usr/bin/env bash
# kms-import-wrapped.sh
# Imports already-wrapped key material into an existing KMS key. Safe: contains no private key bits.
# Usage: export KEY_ID=<key-id> REGION=us-east-1; ./kms-import-wrapped.sh

set -euo pipefail

KEY_ID="${KEY_ID:?Please set KEY_ID environment variable}"
REGION="${REGION:-us-east-1}"
ENCRYPTED_FILE="${ENCRYPTED_FILE:-EncryptedKeyMaterial.bin}"
IMPORT_TOKEN_FILE="${IMPORT_TOKEN_FILE:-ImportToken.bin}"

echo "Importing wrapped key material to KMS KeyId: $KEY_ID in $REGION ..."
aws kms import-key-material \
  --key-id "$KEY_ID" \
  --encrypted-key-material fileb://"${ENCRYPTED_FILE}" \
  --import-token fileb://"${IMPORT_TOKEN_FILE}" \
  --expiration-model KEY_MATERIAL_DOES_NOT_EXPIRE \
  --region "$REGION"

echo "ImportKeyMaterial request submitted. Describe key to confirm:"
aws kms describe-key --key-id "$KEY_ID" --region "$REGION" | jq '.KeyMetadata.KeyState'
echo "If KeyState is Enabled, import succeeded."
