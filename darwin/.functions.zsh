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
