# infra-template

A template to get you started with OpenTofu (and AWS / EKS).

- `./.github/workflows`: Set of basic workflows from [tofu-actions](https://github.com/gmo-media/tofu-actions).
    - `./.github/tofu-actions-config.js`: Configuration for tofu-actions.
- `./.github/renovate.json5`, `./.github/renovate/*`: Renovate configurations.
- `./dev`: Contains basic setup for dual-stack VPC, OIDC definitions, and an EKS cluster.
    - `main.tf`: Metadata (backend, providers, and variables)
    - `oidc_actions.tf`: OIDC provider and roles for GitHub Actions in this repository.
    - `vpc*.tf`: A dual-stack (IPv4 and IPv6) VPC setup.
    - `eks*.tf`: A basic EKS cluster setup.

## Setup

Create a repository from this template, and rewrite wherever needed.

- `./.github/workflows`: After applying `oidc_actions.tf`, replace `123456789012` with your AWS account ID.

### Renovate configuration

This repository uses Renovate to keep dependencies up to date.

While you can definitely use Mend Renovate, eks-addon datasource requires AWS API access.
There are renovate regex tags like `renovate:eksAddonsFilter={"region":"ap-northeast-1","addonName":"kube-proxy"}`
in `./dev/eks.tf` to mark eks-addon version definitions, and renovate will use regex manager to update them.
For more, see [Renovate EKS Addon documentation](https://docs.renovatebot.com/modules/datasource/aws-eks-addon/).

EKS Addon datasource requires self-hosting Renovate using GitHub App, since you cannot configure `allowedEnv`
in Mend Renovate to pass in `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

There are several ways to self-host and run Renovate processes:

- (probably the easiest) GitHub Actions using [renovatebot/github-action](https://github.com/renovatebot/github-action).
    - You might want to check out [motoki317/manifest](https://github.com/motoki317/manifest/tree/master/.github) for workflow examples.
- K8s CronJob: See [manifest-template/dev/renovate](https://github.com/gmo-media/manifest-template/tree/main/dev/renovate).
