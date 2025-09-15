#!/usr/bin/env bash
# kms-create-and-get-params.sh
# Creates a placeholder CMK (EXTERNAL) for ECC_SECG_P256K1 and fetches import params.
# Usage: export REGION=us-east-1; export KEY_ALIAS=alias/my-key; ./kms-create-and-get-params.sh

set -euo pipefail

REGION="${REGION:-us-east-1}"
KEY_ALIAS="${KEY_ALIAS:-alias/kms-import-secp256k1}"

echo "Creating KMS CMK (Origin=EXTERNAL) in region $REGION ..."
create_json=$(aws kms create-key \
  --origin EXTERNAL \
  --key-usage SIGN_VERIFY \
  --key-spec ECC_SECG_P256K1 \
  --description "Imported secp256k1 key (placeholder)" \
  --region "$REGION")
KEY_ID=$(jq -r .KeyMetadata.KeyId <<<"$create_json")
echo "Placeholder KeyId: $KEY_ID"

# Tag or create alias
aws kms create-alias --alias-name "$KEY_ALIAS" --target-key-id "$KEY_ID" --region "$REGION"
echo "Alias $KEY_ALIAS set to $KEY_ID"

echo "Requesting wrapping public key and import token (RSA_4096 + OAEP_SHA_256) ..."
aws kms get-parameters-for-import \
  --key-id "$KEY_ID" \
  --wrapping-algorithm RSAES_OAEP_SHA_256 \
  --wrapping-key-spec RSA_4096 \
  --region "$REGION" > /tmp/kms_import_params.json

# write out the base64-decoded files
jq -r '.PublicKey' /tmp/kms_import_params.json | base64 --decode > /tmp/WrappingPublicKey.der
jq -r '.ImportToken' /tmp/kms_import_params.json | base64 --decode > /tmp/ImportToken.bin
jq -r '.ParametersValidTo' /tmp/kms_import_params.json > /tmp/ParametersValidTo.txt

echo "Saved:"
echo " - /tmp/WrappingPublicKey.der"
echo " - /tmp/ImportToken.bin"
echo " - /tmp/ParametersValidTo.txt (expiry: $(cat /tmp/ParametersValidTo.txt))"
echo "COPY /tmp/WrappingPublicKey.der and /tmp/ImportToken.bin to your offline machine immediately (they expire in 24 hours)."

# Security note
echo "Do NOT place WrappingPublicKey.der or ImportToken.bin in insecure storage. Remove when done:"
echo "shred -u /tmp/WrappingPublicKey.der /tmp/ImportToken.bin /tmp/kms_import_params.json || true"
