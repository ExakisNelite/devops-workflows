# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.208.0/containers/ubuntu/.devcontainer/base.Dockerfile
# Documentation on docker image to use here: https://github.com/microsoft/vscode-dev-containers/tree/main/containers/ubuntu

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG TERRAFORM_VERSION="1.2.4"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends python3-pip
RUN pip3 install pre-commit
RUN pip3 install Commitizen
RUN pip3 install checkov

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
RUN curl -sS https://webinstall.dev/k9s | bash
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv && \
    echo ‘export PATH=”$HOME/.tfenv/bin:$PATH”‘ >> ~/.bash_profile && \
    sudo ln -s ~/.tfenv/bin/* /usr/local/bin

RUN curl -fsSL -o terrafy.zip https://github.com/Azure/aztfy/releases/download/v0.5.0/aztfy_v0.5.0_linux_amd64.zip && \
    unzip terrafy.zip && \
    chmod +x aztfy && \
    mv aztfy /usr/local/bin/aztfy && \
    rm -f terrafy.zip

# terraform, terragrunt, terraform-docs
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/terraform \
    && rm -f terraform.zip

# RUN curl -sSL https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 -o terragrunt \
#     && chmod +x terragrunt \
#     && mv terragrunt /usr/local/bin/terragrunt

RUN curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz \
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/local/bin/terraform-docs \
    && rm -f terraform-docs.tar.gz

#AWS CLI
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws awscliv2.zip

