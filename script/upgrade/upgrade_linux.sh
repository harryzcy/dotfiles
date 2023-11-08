#!/usr/bin/env zsh

# if awscli is installed, upgrade it
if command -v aws &>/dev/null; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$HOME/awscliv2.zip"
  unzip -o "$HOME/awscliv2.zip" -d "$HOME"
  sudo "$HOME/aws/install" --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  rm -rf "$HOME/awscliv2.zip" "$HOME/aws"
fi

if type "pipx" >/dev/null; then
  echo "upgrading pipx packages"
  pipx upgrade-all
fi

if command -v golangci-lint &>/dev/null; then
  echo "upgrading golangci-lint"
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin
fi

if [[ $(hostname -s) = gpu-* ]]; then
  kubectl krew update
  kubectl krew upgrade
fi
