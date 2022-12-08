#!/bin/bash 
declare -a default_hosts=("HOST1 HOST2 HOST3")

RSYNC_OPTS=("-avzhu")

opt_remote=""
opt_local=""
declare -a opt_hosts=()
opt_del=false
opt_sync=false
opt_quiet=false
opt_file=""
print_to_file=false

sigtrap() {
	print_warn "SIGINT"
	exit 1
}

trap 'sigtrap' SIGINT

print_help() {
        if [[ -t 1 ]]
        then
                echo -en "\033[0;35m"
                echo "+------------------------------------+"
                echo "| sync_all_the_things           v0.1 |"
                echo "+-------------+----------------------+"
                echo "| options     |          description |"
                echo "+-------------+----------------------+"
                echo "| -h          |      print this help |"
                echo "| -r <path>   |   path on the remote |"
                echo "| -l <path>   |    path to local dir |"
                echo "| -a <host>   |     additional hosts |"
                echo "| -d          |     delete on server |"
                echo "| -s          |   sync (push & pull) |"
                echo "| -q          |    quiet (no output) |"
                echo "| -f <path>   |          log to file |"
                echo "+-------------+----------------------+"
                echo -en "\033[0m"
        fi
}

print_ok() {
        if [[ -t 1 ]]
        then
                echo -en "\033[0;32m"
                echo "[+] $1"
                echo -en "\033[0m"
        else
                echo "[+] $1"
        fi
}

print_warn() {
        if [[ -t 1 ]]
        then
                echo -en "\033[0;33m"
                echo "[!] $1"
                echo -en "\033[0m"
        else
                echo "[!] $1"
        fi
}

print_err() {
        if [[ -t 1 ]]
        then
                echo -en "\033[0;31m"
                echo "[x] $1"
                echo -en "\033[0m"
        else
                echo "[x] $1"
        fi
        exit 1
}

print_info() {
        if [[ -t 1 ]]
        then
                echo -en "\033[0;34m"
                echo "[*] $1"
                echo -en "\033[0m"
        else
                echo "[*] $1"
        fi
}

print_usage() {
        print_info "Usage: ./sync.sh -l <local_dir> -r <remote_dir> <options>"
        exit 0
}

while getopts 'hr:l:a:dsqf:' OPTION; do
  case "$OPTION" in
    h)
      print_help
      exit 0
      ;;
    r)
      opt_remote=$OPTARG
      ;;
    l)
      opt_local=$OPTARG
      ;;
    a)
      opt_hosts+=("$OPTARG")
      ;;
    d)
      opt_del=true
      ;;
    s)
      opt_sync=true
      ;;
    q)
      opt_quiet=true
      ;;
    f) 
      opt_file="$OPTARG"
      ;;
    ?)
      print_usage
      exit 1
  esac
done
shift "$(($OPTIND -1))"

confirm_opt_del() {
        print_warn "+-----------------------------------------------+"
        print_warn "| using the '-d' option will delete data on the |"
        print_warn "| server, if it is NOT present on the client    |"
        print_warn "|                                               |"
        print_warn "|      ! THIS MAY RESULT IN LOSS OF DATA !      |"
        print_warn "+-----------------------------------------------+"
        print_warn "are you SURE about this ?"
        print_info "enter [ y ] to accept"
        print_info "press any other key to deny"

        read -n 1 -r
        if [[ ! $REPLY =~ ^[y]$ ]]
        then
                echo 
                print_err "aborting ..."
        fi
        echo
        print_ok "proceeding ..."
}

verify_args() {
        if [[ -n $opt_file && $opt_quiet = true ]]
        then
                print_err "cannot use '-f' and '-q' at the same time"
        fi

        if  [[ $opt_del = true && ( $opt_quiet = true || -n $opt_file) ]]
        then
                print_err "cannot use '-d' option in non-interactiv mode"
        fi

        if [[ -z $opt_remote || -z $opt_local ]]
        then
                print_err "missing arguments"
        fi

        if [[ $opt_del = true ]]
        then
                confirm_opt_del
        fi
}

fin() {
        print_info "$(date +"[%d.%m.%y - %H:%M:%S]") stopping script"
        exit 0
}

ping_server() {
        if ping -c1 -W1 $1 > /dev/null 2>&1; then
                print_ok "host '$1' is online, proceeding to sync"
                true
        else
                print_warn "host '$1' is offline, skipping"
                false
        fi
}

terminate_path() {
        arg=$1
        length=${#arg}
        last_char=${arg:length-1:1}

        if [[ $last_char != "/" ]] 
        then 
                arg="$arg/"; :
        fi

        echo $arg
}

main_func() {
        print_info "$(date +"[%d.%m.%y - %H:%M:%S]") starting script"
        verify_args

        print_info "local path  : '$opt_local'"
        print_info "remote path : '$opt_remote'"
        print_info "terminating paths if neccessary"

        local_path="$(terminate_path "$opt_local")"
        remote_path="$(terminate_path "$opt_remote")"

        hosts+=("${default_hosts[@]}" "${opt_hosts[@]}")

        for host in "${hosts[@]}"
        do
                if ! ping_server $host
                then
                        break
                fi

                if [[ $opt_del = true ]] 
                then
                        RSYNC_OPTS+=" --delete"
                fi

                if [[ -t 1 ]]
                then
                        RSYNC_OPTS+=" --progress"
                fi

                rsync $RSYNC_OPTS $local_path $host:$remote_path

                if [[ $opt_sync = true ]]
                then
                        print_info "sync mode enabled, updating client"
                        rsync $RSYNC_OPTS $host:$remote_path $local_path
                fi
        done

        fin
}

if [[ $opt_del = true ]]
then
        main_func
fi

if [[ $opt_quiet = true ]]
then
        main_func 2>&1 >> /dev/null
fi

if [[ -n $opt_file ]]
then
        main_func 2>&1 >> $opt_file
fi

main_func
