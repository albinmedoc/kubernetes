#!/bin/bash
# Convert StatefulSet to Deployment
# Usage: ./convert-sts-to-deployment.sh <statefulset-file-path>

STS_FILE_PATH=$1

if [ -z "$STS_FILE_PATH" ]; then
    echo "Usage: $0 <statefulset-file-path>"
    echo "Example: $0 ./adminer/adminer-statefulset.yaml"
    exit 1
fi

# Check if the file exists
if [ ! -f "$STS_FILE_PATH" ]; then
    echo "Error: File '$STS_FILE_PATH' not found!"
    exit 1
fi

# Get the directory and filename
STS_DIR=$(dirname "$STS_FILE_PATH")
STS_FILENAME=$(basename "$STS_FILE_PATH")
STS_NAME=$(basename "$STS_FILENAME" .yaml)

# Extract StatefulSet name and namespace from the file
ACTUAL_STS_NAME=$(grep -E "^\s*name:" "$STS_FILE_PATH" | head -1 | sed 's/.*name: *//')
NAMESPACE=$(grep -E "^\s*namespace:" "$STS_FILE_PATH" | head -1 | sed 's/.*namespace: *//')

if [ -z "$ACTUAL_STS_NAME" ]; then
    echo "Error: Could not extract StatefulSet name from '$STS_FILE_PATH'"
    exit 1
fi

echo "Converting StatefulSet $ACTUAL_STS_NAME in namespace ${NAMESPACE:-default} to Deployment..."

# Generate deployment filename
DEPLOYMENT_FILE="$STS_DIR/${STS_NAME/statefulset/deployment}.yaml"

# Extract and convert
cat "$STS_FILE_PATH" | \
  sed 's/kind: StatefulSet/kind: Deployment/' | \
  sed '/serviceName:/d' | \
  sed '/volumeClaimTemplates:/,$d' | \
  sed '/creationTimestamp:/d' | \
  sed '/resourceVersion:/d' | \
  sed '/uid:/d' | \
  sed '/generation:/d' > "$DEPLOYMENT_FILE"

echo "Generated $DEPLOYMENT_FILE"

# Ask if user wants to delete the original StatefulSet file
echo ""
read -p "Do you want to delete the original StatefulSet file '$STS_FILE_PATH'? (y/N): " DELETE_FILE
if [[ "$DELETE_FILE" =~ ^[Yy]$ ]]; then
    rm "$STS_FILE_PATH"
    echo "Deleted original StatefulSet file: $STS_FILE_PATH"
else
    echo "Keeping original StatefulSet file: $STS_FILE_PATH"
fi

echo ""
echo "Review the generated deployment file, then run:"
if [ -n "$NAMESPACE" ]; then
    echo "kubectl delete statefulset $ACTUAL_STS_NAME -n $NAMESPACE"
else
    echo "kubectl delete statefulset $ACTUAL_STS_NAME"
fi
echo "kubectl apply -f $DEPLOYMENT_FILE"