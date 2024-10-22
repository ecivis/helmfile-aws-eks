# Bitbucket Pipelines Pipe: Helmfile AWS EKS

Deploy a Helm chart to AWS EKS using Helmfile. The pipe brings `aws-cli`, `kubectl`, `helm`, and `helmfile` in a custom Bitbucket Pipelines Pipe to deploy from a self-hosted Bitbucket Pipelines Runner.

## Example usage in Bitbucket Pipeline

```yaml
...
    - pipe: docker://ecivis/helmfile-aws-eks:0.0.8
      variables:
        AWS_REGION: "<string>"
        AWS_ACCESS_KEY_ID: "<string>"
        AWS_SECRET_ACCESS_KEY: "<string>"
        TARGET_ROLE_ARN: "<string>"
        HELMFILE_ENVIRONMENT: "<string>"
        CHART_PATH: "<string>"
        CLUSTER_NAME: "<string>"
        KUBECTL_CONTEXT: "<string>"
        CHART_OVERRIDES:
          - "<string>"
          - "<string>"
        DEBUG: "<string>"
```
