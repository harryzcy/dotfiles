# .functions.zsh
# A list of helper functions

update_time () {
  sudo sntp -sS time.apple.com
}

function set_proxy() {
  export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7891
}

function unset_proxy() {
  export https_proxy= http_proxy= all_proxy=
}

install_go() {
  version=$1
  if [ -z "$version" ]; then
    echo "Usage: install_go <version>"
    return 1
  fi

  sudo -v

  echo "Updating go to version $version"

  archstr=$(uname -m)
  if [[ "$archstr" == "x86_64" ]]; then
    arch="amd64"
  elif [[ "$archstr" == "arm64" || "$archstr" == "arm" ]]; then
    arch="arm64"
  else
    echo "Unsupported architecture: $archstr"
    return 1
  fi

  url="https://go.dev/dl/go${version}.darwin-${arch}.tar.gz"
  echo "Downloading $url"

  file="$HOME/Downloads/go${version}.darwin-${arch}.tar.gz"
  curl -L "$url" -o "$file"

  echo "Extracting $file"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$file"
  rm "$file"

  echo "Done"
}

setup_github_workflows::go() {
  if [ -f .github/dependabot.yml ]; then
    grep -Fq "gomod" .github/dependabot.yml
    if [ $? -ne 0 ]; then
        cat << EOT >> .github/dependabot.yml
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "daily"
EOT
    fi
  fi

  if [ ! -f .github/workflows/go.yml ]; then
    cat << EOT >> .github/workflows/go.yml
name: Go Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        go-version: [1.18, 1.17]
    runs-on: \${{ matrix.os }}
    steps:
    - uses: actions/checkout@v3

    - name: Set up Go
      uses: actions/setup-go@v3
      with:
        go-version: \${{ matrix.go-version }}

    - name: Build
      run: go build -v ./...

    - name: Test with coverage
      run: go test -race -coverprofile=coverage.txt -covermode=atomic ./...
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.txt
EOT
  fi

  if [ ! -f .github/workflows/release.yml ]; then
    cat >> .github/workflows/release.yml << EOT
name: Releases

on:
  push:
    tags:
      - "v*"

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v3
      - uses: ncipollo/release-action@v1
        with:
          name: Release \${{ github.ref_name }}
          token: \${{ secrets.GITHUB_TOKEN }}
EOT
  fi

  if [ ! -f .github/workflows/golangci-lint.yml ]; then
    cat >> .github/workflows/golangci-lint.yml << EOT
name: Go Lint

on:
  push:
    tags:
      - v*
    branches:
      - main
  pull_request:

permissions:
  contents: read
  pull-requests: read

jobs:
  golangci:
    name: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-go@v3
        with:
          go-version: 1.18

      - uses: actions/checkout@v3

      - name: golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          only-new-issues: true
EOT
  fi

  if [ ! -f .jscpd.json ]; then
    cat >> .jscpd.json << EOT
{
  "ignore": [
    "**/*_test.go"
  ]
}
EOT
  fi
}

setup_github_workflows() {
  if [ ! -d .git ]; then
    echo "Not a git repository"
    return 1
  fi

  if [ ! -d .github ]; then
    mkdir .github
  fi

  if [ ! -d .github/workflows ]; then
    mkdir .github/workflows
  fi

  if [ ! -f .github/dependabot.yml ]; then
    cat >> .github/dependabot.yml << EOT
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
EOT
  fi

  if [ -f go.mod ]; then
    setup_github_workflows::go
  fi

}
