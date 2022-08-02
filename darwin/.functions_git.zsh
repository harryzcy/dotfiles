# .functions_go.zsh
# Functions related to Git and Git repositories


setup_github_workflows::go() {
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
  pull_request:
    branches: [ main ]

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

  if [ ! -f .github/renovate.json ]; then
    cat >> .github/renovate.json << EOT
{
  "extends": [
    "config:base"
  ],
  "labels": ["dependencies"],
  "packageRules": [
    {
      "matchPackagePatterns": [
        "*"
      ],
      "matchUpdateTypes": ["minor", "patch", "pin", "digest"],
      "automerge": true,
      "groupName": "all non-major dependencies",
      "groupSlug": "all-non-major"
    }
  ]
}
EOT
  fi

  if [ ! -f .github/release-drafter.yml ]; then
    cat >> .github/release-drafter.yml << EOT
name-template: 'v\$RESOLVED_VERSION'
tag-template: 'v\$RESOLVED_VERSION'
categories:
  - title: '🚀 Features'
    labels:
      - 'feature'
      - 'enhancement'
  - title: '🐛 Bug Fixes'
    labels:
      - 'fix'
      - 'bugfix'
      - 'bug'
  - title: '🧰 Maintenance'
    label: 'chore'
  - title: '⬆️ Dependencies'
    collapse-after: 3
    labels:
      - 'dependencies'
change-title-escapes: '\<*_&'
version-resolver:
  major:
    labels:
      - 'major'
  minor:
    labels:
      - 'minor'
  patch:
    labels:
      - 'patch'
  default: patch
template: |
  ## Changes

  \$CHANGES
EOT
  fi

  if [ ! -f .github/workflows/release-drafter.yml ]; then
    cat >> .github/workflows/release-drafter.yml << EOT
name: Release Drafter

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, reopened, synchronize]
  pull_request_target:
    types: [opened, reopened, synchronize]

permissions:
  contents: read

jobs:
  update_release_draft:
    permissions:
      contents: write  # for release-drafter/release-drafter to create a github release
      pull-requests: write  # for release-drafter/release-drafter to add label to PR
    runs-on: ubuntu-latest
    steps:
      # Drafts your next Release notes as Pull Requests are merged into "main"
      - uses: release-drafter/release-drafter@v5
        with:
          commitish: main
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
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
  release:
    name: Release on GitHub
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v3
      - uses: release-drafter/release-drafter@v5
        id: release_drafter
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      - name: Publish Release
        uses: actions/github-script@v6
        with:
          script: |
            await github.rest.repos.updateRelease({
              owner: context.repo.owner,
              repo: context.repo.repo,
              release_id: \${{ steps.release_drafter.outputs.id }},
              tag_name: '\${{ github.ref_name }}',
              name: 'Release \${{ github.ref_name }}',
              draft: context.eventName != 'push'
            });

EOT
  fi

  if [ -f go.mod ]; then
    setup_github_workflows::go
  fi

  if [ -f requirements.txt ]; then
    setup_github_workflows::python
  fi

}
