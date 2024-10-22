#!/bin/bash

set -eu

source "$(dirname "$0")/common.sh"

info "Deploying Helm chart to AWS EKS"

AWS_REGION=${AWS_REGION:?"AWS_REGION environment variable missing."}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID environment variable missing."}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY environment variable missing."}
TARGET_ROLE_ARN=${TARGET_ROLE_ARN:=""}
HELMFILE_ENVIRONMENT=${HELMFILE_ENVIRONMENT:?"HELMFILE_ENVIRONMENT environment variable missing."}
CHART_PATH=${CHART_PATH:?"CHART_PATH environment variable missing."}
CLUSTER_NAME=${CLUSTER_NAME:?"CLUSTER_NAME environment variable missing."}
KUBECTL_CONTEXT=${KUBECTL_CONTEXT:?"KUBECTL_CONTEXT environment variable missing."}
CHART_OVERRIDES=${CHART_OVERRIDES:=""}
DEBUG=${DEBUG:="false"}
export AWS_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
enable_debug

chart_override_parser() {
    local array_var=${1}
    local count_var=${array_var}_COUNT
    for (( i = 0; i < ${!count_var:=0}; i++ )); do
      # shellcheck disable=SC2086
      eval ${array_var}[$i]='$'${array_var}_${i}
    done
}
chart_override_parser CHART_OVERRIDES

helmfile_aws_eks_pipe() {
  if [ -n "$TARGET_ROLE_ARN" ]; then
    # shellcheck disable=SC2046
    # shellcheck disable=SC2183
    export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
      $(aws sts assume-role --role-arn "$TARGET_ROLE_ARN" \
      --role-session-name helmfile-aws-eks-pipe \
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
      --output text))
  fi
  aws eks update-kubeconfig --name "$CLUSTER_NAME" --alias "$KUBECTL_CONTEXT"
  cd "${BITBUCKET_CLONE_DIR}/${CHART_PATH}"
  # shellcheck disable=SC2068
  helmfile -e "$HELMFILE_ENVIRONMENT" sync ${CHART_OVERRIDES[@]/*/' --set '&}
}


status=1
run helmfile_aws_eks_pipe
if [ "$status" -eq 0 ]; then
  success "Success!"
else
  fail "Error!"
fi
