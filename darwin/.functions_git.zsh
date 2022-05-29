# .functions_go.zsh
# Functions related to Git and Git repositories


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

setup_github_workflows::python() {
  if [ -f .github/dependabot.yml ]; then
    grep -Fq "pip" .github/dependabot.yml
    if [ $? -ne 0 ]; then
        cat << EOT >> .github/dependabot.yml
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "daily"
EOT
    fi
  fi

  if [ ! -f .github/workflows/python.yml ]; then
    cat >> .github/workflows/python.yml << EOT
name: Python Tests

on: [push, pull_request]

jobs:
  build:

    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10"]

    steps:
      - uses: actions/checkout@v3
      - name: Set up Python \${{ matrix.python-version }}
        uses: actions/setup-python@v3
        with:
          python-version: \${{ matrix.python-version }}
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install flake8 pytest
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
      - name: Lint with flake8
        run: |
          # stop the build if there are Python syntax errors or undefined names
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          # exit-zero treats all errors as warnings. The GitHub editor is 127 chars wide
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
      - name: Test with pytest
        run: |
          pytest
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

  if [ -f go.mod ]; then
    setup_github_workflows::go
  fi

  if [ -f requirements.txt ]; then
    setup_github_workflows::python
  fi

}
