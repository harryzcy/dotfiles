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
