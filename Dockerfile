FROM debian:bookworm-20241016-slim

ARG KUBECTL_VERSION="1.31.1"
ARG HELM_VERSION="3.16.2"
ARG HELMFILE_VERSION="0.169.1"
ARG TARGETPLATFORM

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update -y && apt-get upgrade -y && \
  apt-get install -y --no-install-recommends bash curl unzip ca-certificates less

RUN arch="${TARGETPLATFORM##*/}" && \
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${arch}/kubectl" && \
  curl -L -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${arch}.tar.gz" && \
  tar -zx -C /tmp -f /tmp/helm.tar.gz && mv /tmp/linux-${arch}/helm /usr/local/bin/helm && \
  curl -L -o /tmp/helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${arch}.tar.gz" && \
  tar -zx -C /tmp -f /tmp/helmfile.tar.gz && mv /tmp/helmfile /usr/local/bin/helmfile && \
  chmod 550 /usr/local/bin/kubectl /usr/local/bin/helm /usr/local/bin/helmfile && \
  rm -rf /var/lib/apt/lists/* /tmp/*

RUN machine=$(uname -m) && curl -L -o "/tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-${machine}.zip" && \
  unzip -d /tmp /tmp/awscliv2.zip && \
  /tmp/aws/install && \
  rm -rf /tmp/*

# Bitbucket Toolkit for Bash expects to find `pipe.yml` in the root. See https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/src/master/common.sh
COPY pipe/pipe.sh pipe.yml /

RUN curl -sL -o /common.sh https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.6.0/common.sh && \
  chmod 0500 /*.sh

ENTRYPOINT ["/pipe.sh"]
