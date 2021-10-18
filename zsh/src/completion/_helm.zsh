#compdef helm

__helm_bash_source() {
	alias shopt=':'
	alias _expand=_bash_expand
	alias _complete=_bash_comp
	emulate -L sh
	setopt kshglob noshglob braceexpand
	source "$@"
}
__helm_type() {
	# -t is not supported by zsh
	if [ "$1" == "-t" ]; then
		shift
		# fake Bash 4 to disable "complete -o nospace". Instead
		# "compopt +-o nospace" is used in the code to toggle trailing
		# spaces. We don't support that, but leave trailing spaces on
		# all the time
		if [ "$1" = "__helm_compopt" ]; then
			echo builtin
			return 0
		fi
	fi
	type "$@"
}
__helm_compgen() {
	local completions w
	completions=( $(compgen "$@") ) || return $?
	# filter by given word as prefix
	while [[ "$1" = -* && "$1" != -- ]]; do
		shift
		shift
	done
	if [[ "$1" == -- ]]; then
		shift
	fi
	for w in "${completions[@]}"; do
		if [[ "${w}" = "$1"* ]]; then
			echo "${w}"
		fi
	done
}
__helm_compopt() {
	true # don't do anything. Not supported by bashcompinit in zsh
}
__helm_ltrim_colon_completions()
{
	if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
		# Remove colon-word prefix from COMPREPLY items
		local colon_word=${1%${1##*:}}
		local i=${#COMPREPLY[*]}
		while [[ $((--i)) -ge 0 ]]; do
			COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
		done
	fi
}
__helm_get_comp_words_by_ref() {
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[${COMP_CWORD}-1]}"
	words=("${COMP_WORDS[@]}")
	cword=("${COMP_CWORD[@]}")
}
__helm_filedir() {
	local RET OLD_IFS w qw
	__debug "_filedir $@ cur=$cur"
	if [[ "$1" = \~* ]]; then
		# somehow does not work. Maybe, zsh does not call this at all
		eval echo "$1"
		return 0
	fi
	OLD_IFS="$IFS"
	IFS=$'\n'
	if [ "$1" = "-d" ]; then
		shift
		RET=( $(compgen -d) )
	else
		RET=( $(compgen -f) )
	fi
	IFS="$OLD_IFS"
	IFS="," __debug "RET=${RET[@]} len=${#RET[@]}"
	for w in ${RET[@]}; do
		if [[ ! "${w}" = "${cur}"* ]]; then
			continue
		fi
		if eval "[[ \"\${w}\" = *.$1 || -d \"\${w}\" ]]"; then
			qw="$(__helm_quote "${w}")"
			if [ -d "${w}" ]; then
				COMPREPLY+=("${qw}/")
			else
				COMPREPLY+=("${qw}")
			fi
		fi
	done
}
__helm_quote() {
	if [[ $1 == \'* || $1 == \"* ]]; then
		# Leave out first character
		printf %q "${1:1}"
	else
		printf %q "$1"
	fi
}
autoload -U +X bashcompinit && bashcompinit
# use word boundary patterns for BSD or GNU sed
LWORD='[[:<:]]'
RWORD='[[:>:]]'
if sed --help 2>&1 | grep -q 'GNU\|BusyBox'; then
	LWORD='\<'
	RWORD='\>'
fi
__helm_convert_bash_to_zsh() {
	sed \
	-e 's/declare -F/whence -w/' \
	-e 's/_get_comp_words_by_ref "\$@"/_get_comp_words_by_ref "\$*"/' \
	-e 's/local \([a-zA-Z0-9_]*\)=/local \1; \1=/' \
	-e 's/flags+=("\(--.*\)=")/flags+=("\1"); two_word_flags+=("\1")/' \
	-e 's/must_have_one_flag+=("\(--.*\)=")/must_have_one_flag+=("\1")/' \
	-e "s/${LWORD}_filedir${RWORD}/__helm_filedir/g" \
	-e "s/${LWORD}_get_comp_words_by_ref${RWORD}/__helm_get_comp_words_by_ref/g" \
	-e "s/${LWORD}__ltrim_colon_completions${RWORD}/__helm_ltrim_colon_completions/g" \
	-e "s/${LWORD}compgen${RWORD}/__helm_compgen/g" \
	-e "s/${LWORD}compopt${RWORD}/__helm_compopt/g" \
	-e "s/${LWORD}declare${RWORD}/builtin declare/g" \
	-e "s/\\\$(type${RWORD}/\$(__helm_type/g" \
	-e 's/aliashash\["\(.\{1,\}\)"\]/aliashash[\1]/g' \
	-e 's/FUNCNAME/funcstack/g' \
	<<'BASH_COMPLETION_EOF'
# bash completion for helm                                 -*- shell-script -*-

__helm_debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__helm_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__helm_index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__helm_contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__helm_handle_reply()
{
    __helm_debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%=*}"
                __helm_index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zsh completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __helm_index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
		if declare -F __helm_custom_func >/dev/null; then
			# try command name qualified custom func
			__helm_custom_func
		else
			# otherwise fall back to unqualified for compatibility
			declare -F __custom_func >/dev/null && __custom_func
		fi
    fi

    # available in bash-completion >= 2, not always present on macOS
    if declare -F __ltrim_colon_completions >/dev/null; then
        __ltrim_colon_completions "$cur"
    fi

    # If there is only 1 completion and it is a flag with an = it will be completed
    # but we don't want a space after the =
    if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
       compopt -o nospace
    fi
}

# The arguments should be in the form "ext1|ext2|extn"
__helm_handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__helm_handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__helm_handle_flag()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __helm_debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __helm_contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __helm_contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    # flaghash variable is an associative array which is only supported in bash > 3.
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        if [ -n "${flagvalue}" ] ; then
            flaghash[${flagname}]=${flagvalue}
        elif [ -n "${words[ $((c+1)) ]}" ] ; then
            flaghash[${flagname}]=${words[ $((c+1)) ]}
        else
            flaghash[${flagname}]="true" # pad "true" for bool flag
        fi
    fi

    # skip the argument to a two word flag
    if [[ ${words[c]} != *"="* ]] && __helm_contains_word "${words[c]}" "${two_word_flags[@]}"; then
			  __helm_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__helm_handle_noun()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __helm_contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __helm_contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__helm_handle_command()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_helm_root_command"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __helm_debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__helm_handle_word()
{
    if [[ $c -ge $cword ]]; then
        __helm_handle_reply
        return
    fi
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __helm_handle_flag
    elif __helm_contains_word "${words[c]}" "${commands[@]}"; then
        __helm_handle_command
    elif [[ $c -eq 0 ]]; then
        __helm_handle_command
    elif __helm_contains_word "${words[c]}" "${command_aliases[@]}"; then
        # aliashash variable is an associative array which is only supported in bash > 3.
        if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
            words[c]=${aliashash[${words[c]}]}
            __helm_handle_command
        else
            __helm_handle_noun
        fi
    else
        __helm_handle_noun
    fi
    __helm_handle_word
}


__helm_override_flag_list=(--kubeconfig --kube-context --host --tiller-namespace --home)
__helm_override_flags()
{
    local ${__helm_override_flag_list[*]##*-} two_word_of of var
    for w in "${words[@]}"; do
        if [ -n "${two_word_of}" ]; then
            eval "${two_word_of##*-}=\"${two_word_of}=\${w}\""
            two_word_of=
            continue
        fi
        for of in "${__helm_override_flag_list[@]}"; do
            case "${w}" in
                ${of}=*)
                    eval "${of##*-}=\"${w}\""
                    ;;
                ${of})
                    two_word_of="${of}"
                    ;;
            esac
        done
    done
    for var in "${__helm_override_flag_list[@]##*-}"; do
        if eval "test -n \"\$${var}\""; then
            eval "echo \${${var}}"
        fi
    done
}

__helm_binary_name()
{
    local helm_binary
    helm_binary="${words[0]}"
    __helm_debug "${FUNCNAME[0]}: helm_binary is ${helm_binary}"
    echo ${helm_binary}
}

__helm_list_releases()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out filter
    # Use ^ to map from the start of the release name
    filter="^${words[c]}"
    # Use eval in case helm_binary_name or __helm_override_flags contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) list $(__helm_override_flags) -a -q -m 1000 ${filter} 2>/dev/null); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_list_repos()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out oflags
    oflags=$(__helm_override_flags)
    __helm_debug "${FUNCNAME[0]}: __helm_override_flags are ${oflags}"
    # Use eval in case helm_binary_name contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) repo list ${oflags} 2>/dev/null | tail +2 | cut -f1); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_list_plugins()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    local out oflags
    oflags=$(__helm_override_flags)
    __helm_debug "${FUNCNAME[0]}: __helm_override_flags are ${oflags}"
    # Use eval in case helm_binary_name contains a variable (e.g., $HOME/bin/h2)
    if out=$(eval $(__helm_binary_name) plugin list ${oflags} 2>/dev/null | tail +2 | cut -f1); then
        COMPREPLY=( $( compgen -W "${out[*]}" -- "$cur" ) )
    fi
}

__helm_custom_func()
{
    __helm_debug "${FUNCNAME[0]}: c is $c words[@] is ${words[@]}"
    case ${last_command} in
        helm_delete | helm_history | helm_status | helm_test |\
        helm_upgrade | helm_rollback | helm_get_*)
            __helm_list_releases
            return
            ;;
        helm_repo_remove | helm_repo_update)
            __helm_list_repos
            return
            ;;
        helm_plugin_remove | helm_plugin_update)
            __helm_list_plugins
            return
            ;;
        *)
            ;;
    esac
}

_helm_completion()
{
    last_command="helm_completion"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    must_have_one_noun+=("bash")
    must_have_one_noun+=("zsh")
    noun_aliases=()
}

_helm_create()
{
    last_command="helm_create"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--starter=")
    two_word_flags+=("--starter")
    two_word_flags+=("-p")
    local_nonpersistent_flags+=("--starter=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_delete()
{
    last_command="helm_delete"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--purge")
    local_nonpersistent_flags+=("--purge")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_build()
{
    last_command="helm_dependency_build"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_list()
{
    last_command="helm_dependency_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency_update()
{
    last_command="helm_dependency_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--skip-refresh")
    local_nonpersistent_flags+=("--skip-refresh")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_dependency()
{
    last_command="helm_dependency"

    command_aliases=()

    commands=()
    commands+=("build")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("update")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("up")
        aliashash["up"]="update"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_fetch()
{
    last_command="helm_fetch"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--destination=")
    two_word_flags+=("--destination")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--destination=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--prov")
    local_nonpersistent_flags+=("--prov")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--untar")
    local_nonpersistent_flags+=("--untar")
    flags+=("--untardir=")
    two_word_flags+=("--untardir")
    local_nonpersistent_flags+=("--untardir=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_hooks()
{
    last_command="helm_get_hooks"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_manifest()
{
    last_command="helm_get_manifest"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_notes()
{
    last_command="helm_get_notes"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get_values()
{
    last_command="helm_get_values"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--output=")
    two_word_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_get()
{
    last_command="helm_get"

    command_aliases=()

    commands=()
    commands+=("hooks")
    commands+=("manifest")
    commands+=("notes")
    commands+=("values")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_history()
{
    last_command="helm_history"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--max=")
    two_word_flags+=("--max")
    local_nonpersistent_flags+=("--max=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_home()
{
    last_command="helm_home"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_init()
{
    last_command="helm_init"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--automount-service-account-token")
    local_nonpersistent_flags+=("--automount-service-account-token")
    flags+=("--canary-image")
    local_nonpersistent_flags+=("--canary-image")
    flags+=("--client-only")
    flags+=("-c")
    local_nonpersistent_flags+=("--client-only")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force-upgrade")
    local_nonpersistent_flags+=("--force-upgrade")
    flags+=("--history-max=")
    two_word_flags+=("--history-max")
    local_nonpersistent_flags+=("--history-max=")
    flags+=("--local-repo-url=")
    two_word_flags+=("--local-repo-url")
    local_nonpersistent_flags+=("--local-repo-url=")
    flags+=("--net-host")
    local_nonpersistent_flags+=("--net-host")
    flags+=("--node-selectors=")
    two_word_flags+=("--node-selectors")
    local_nonpersistent_flags+=("--node-selectors=")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--override=")
    two_word_flags+=("--override")
    local_nonpersistent_flags+=("--override=")
    flags+=("--replicas=")
    two_word_flags+=("--replicas")
    local_nonpersistent_flags+=("--replicas=")
    flags+=("--service-account=")
    two_word_flags+=("--service-account")
    local_nonpersistent_flags+=("--service-account=")
    flags+=("--skip-refresh")
    local_nonpersistent_flags+=("--skip-refresh")
    flags+=("--stable-repo-url=")
    two_word_flags+=("--stable-repo-url")
    local_nonpersistent_flags+=("--stable-repo-url=")
    flags+=("--tiller-image=")
    two_word_flags+=("--tiller-image")
    two_word_flags+=("-i")
    local_nonpersistent_flags+=("--tiller-image=")
    flags+=("--tiller-tls")
    local_nonpersistent_flags+=("--tiller-tls")
    flags+=("--tiller-tls-cert=")
    two_word_flags+=("--tiller-tls-cert")
    local_nonpersistent_flags+=("--tiller-tls-cert=")
    flags+=("--tiller-tls-hostname=")
    two_word_flags+=("--tiller-tls-hostname")
    local_nonpersistent_flags+=("--tiller-tls-hostname=")
    flags+=("--tiller-tls-key=")
    two_word_flags+=("--tiller-tls-key")
    local_nonpersistent_flags+=("--tiller-tls-key=")
    flags+=("--tiller-tls-verify")
    local_nonpersistent_flags+=("--tiller-tls-verify")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--upgrade")
    local_nonpersistent_flags+=("--upgrade")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_chart()
{
    last_command="helm_inspect_chart"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_readme()
{
    last_command="helm_inspect_readme"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect_values()
{
    last_command="helm_inspect_values"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_inspect()
{
    last_command="helm_inspect"

    command_aliases=()

    commands=()
    commands+=("chart")
    commands+=("readme")
    commands+=("values")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_install()
{
    last_command="helm_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--atomic")
    local_nonpersistent_flags+=("--atomic")
    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--dep-up")
    local_nonpersistent_flags+=("--dep-up")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--name-template=")
    two_word_flags+=("--name-template")
    local_nonpersistent_flags+=("--name-template=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--no-crd-hook")
    local_nonpersistent_flags+=("--no-crd-hook")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--render-subchart-notes")
    local_nonpersistent_flags+=("--render-subchart-notes")
    flags+=("--replace")
    local_nonpersistent_flags+=("--replace")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_lint()
{
    last_command="helm_lint"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--strict")
    local_nonpersistent_flags+=("--strict")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_list()
{
    last_command="helm_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--chart-name")
    flags+=("-c")
    local_nonpersistent_flags+=("--chart-name")
    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--date")
    flags+=("-d")
    local_nonpersistent_flags+=("--date")
    flags+=("--deleted")
    local_nonpersistent_flags+=("--deleted")
    flags+=("--deleting")
    local_nonpersistent_flags+=("--deleting")
    flags+=("--deployed")
    local_nonpersistent_flags+=("--deployed")
    flags+=("--failed")
    local_nonpersistent_flags+=("--failed")
    flags+=("--max=")
    two_word_flags+=("--max")
    two_word_flags+=("-m")
    local_nonpersistent_flags+=("--max=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--offset=")
    two_word_flags+=("--offset")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--offset=")
    flags+=("--output=")
    two_word_flags+=("--output")
    local_nonpersistent_flags+=("--output=")
    flags+=("--pending")
    local_nonpersistent_flags+=("--pending")
    flags+=("--reverse")
    flags+=("-r")
    local_nonpersistent_flags+=("--reverse")
    flags+=("--short")
    flags+=("-q")
    local_nonpersistent_flags+=("--short")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_package()
{
    last_command="helm_package"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--app-version=")
    two_word_flags+=("--app-version")
    local_nonpersistent_flags+=("--app-version=")
    flags+=("--dependency-update")
    flags+=("-u")
    local_nonpersistent_flags+=("--dependency-update")
    flags+=("--destination=")
    two_word_flags+=("--destination")
    two_word_flags+=("-d")
    local_nonpersistent_flags+=("--destination=")
    flags+=("--key=")
    two_word_flags+=("--key")
    local_nonpersistent_flags+=("--key=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--save")
    local_nonpersistent_flags+=("--save")
    flags+=("--sign")
    local_nonpersistent_flags+=("--sign")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_install()
{
    last_command="helm_plugin_install"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_list()
{
    last_command="helm_plugin_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_remove()
{
    last_command="helm_plugin_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin_update()
{
    last_command="helm_plugin_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_plugin()
{
    last_command="helm_plugin"

    command_aliases=()

    commands=()
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    commands+=("update")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_add()
{
    last_command="helm_repo_add"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--no-update")
    local_nonpersistent_flags+=("--no-update")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_index()
{
    last_command="helm_repo_index"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--merge=")
    two_word_flags+=("--merge")
    local_nonpersistent_flags+=("--merge=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_list()
{
    last_command="helm_repo_list"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_remove()
{
    last_command="helm_repo_remove"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo_update()
{
    last_command="helm_repo_update"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--strict")
    local_nonpersistent_flags+=("--strict")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_repo()
{
    last_command="helm_repo"

    command_aliases=()

    commands=()
    commands+=("add")
    commands+=("index")
    commands+=("list")
    commands+=("remove")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("rm")
        aliashash["rm"]="remove"
    fi
    commands+=("update")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("up")
        aliashash["up"]="update"
    fi

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_reset()
{
    last_command="helm_reset"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--remove-helm-home")
    local_nonpersistent_flags+=("--remove-helm-home")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_rollback()
{
    last_command="helm_rollback"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cleanup-on-fail")
    local_nonpersistent_flags+=("--cleanup-on-fail")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--recreate-pods")
    local_nonpersistent_flags+=("--recreate-pods")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_search()
{
    last_command="helm_search"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--col-width=")
    two_word_flags+=("--col-width")
    local_nonpersistent_flags+=("--col-width=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--regexp")
    flags+=("-r")
    local_nonpersistent_flags+=("--regexp")
    flags+=("--version=")
    two_word_flags+=("--version")
    two_word_flags+=("-v")
    local_nonpersistent_flags+=("--version=")
    flags+=("--versions")
    flags+=("-l")
    local_nonpersistent_flags+=("--versions")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_serve()
{
    last_command="helm_serve"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--address=")
    two_word_flags+=("--address")
    local_nonpersistent_flags+=("--address=")
    flags+=("--repo-path=")
    two_word_flags+=("--repo-path")
    local_nonpersistent_flags+=("--repo-path=")
    flags+=("--url=")
    two_word_flags+=("--url")
    local_nonpersistent_flags+=("--url=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_status()
{
    last_command="helm_status"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--revision=")
    two_word_flags+=("--revision")
    local_nonpersistent_flags+=("--revision=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_template()
{
    last_command="helm_template"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--api-versions=")
    two_word_flags+=("--api-versions")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--api-versions=")
    flags+=("--execute=")
    two_word_flags+=("--execute")
    two_word_flags+=("-x")
    local_nonpersistent_flags+=("--execute=")
    flags+=("--is-upgrade")
    local_nonpersistent_flags+=("--is-upgrade")
    flags+=("--kube-version=")
    two_word_flags+=("--kube-version")
    local_nonpersistent_flags+=("--kube-version=")
    flags+=("--name=")
    two_word_flags+=("--name")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--name=")
    flags+=("--name-template=")
    two_word_flags+=("--name-template")
    local_nonpersistent_flags+=("--name-template=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--notes")
    local_nonpersistent_flags+=("--notes")
    flags+=("--output-dir=")
    two_word_flags+=("--output-dir")
    local_nonpersistent_flags+=("--output-dir=")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_test()
{
    last_command="helm_test"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--cleanup")
    local_nonpersistent_flags+=("--cleanup")
    flags+=("--logs")
    local_nonpersistent_flags+=("--logs")
    flags+=("--max=")
    two_word_flags+=("--max")
    local_nonpersistent_flags+=("--max=")
    flags+=("--parallel")
    local_nonpersistent_flags+=("--parallel")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_upgrade()
{
    last_command="helm_upgrade"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--atomic")
    local_nonpersistent_flags+=("--atomic")
    flags+=("--ca-file=")
    two_word_flags+=("--ca-file")
    local_nonpersistent_flags+=("--ca-file=")
    flags+=("--cert-file=")
    two_word_flags+=("--cert-file")
    local_nonpersistent_flags+=("--cert-file=")
    flags+=("--cleanup-on-fail")
    local_nonpersistent_flags+=("--cleanup-on-fail")
    flags+=("--description=")
    two_word_flags+=("--description")
    local_nonpersistent_flags+=("--description=")
    flags+=("--devel")
    local_nonpersistent_flags+=("--devel")
    flags+=("--dry-run")
    local_nonpersistent_flags+=("--dry-run")
    flags+=("--force")
    local_nonpersistent_flags+=("--force")
    flags+=("--install")
    flags+=("-i")
    local_nonpersistent_flags+=("--install")
    flags+=("--key-file=")
    two_word_flags+=("--key-file")
    local_nonpersistent_flags+=("--key-file=")
    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--namespace=")
    two_word_flags+=("--namespace")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--no-hooks")
    local_nonpersistent_flags+=("--no-hooks")
    flags+=("--output=")
    two_word_flags+=("--output")
    two_word_flags+=("-o")
    local_nonpersistent_flags+=("--output=")
    flags+=("--password=")
    two_word_flags+=("--password")
    local_nonpersistent_flags+=("--password=")
    flags+=("--recreate-pods")
    local_nonpersistent_flags+=("--recreate-pods")
    flags+=("--render-subchart-notes")
    local_nonpersistent_flags+=("--render-subchart-notes")
    flags+=("--repo=")
    two_word_flags+=("--repo")
    local_nonpersistent_flags+=("--repo=")
    flags+=("--reset-values")
    local_nonpersistent_flags+=("--reset-values")
    flags+=("--reuse-values")
    local_nonpersistent_flags+=("--reuse-values")
    flags+=("--set=")
    two_word_flags+=("--set")
    local_nonpersistent_flags+=("--set=")
    flags+=("--set-file=")
    two_word_flags+=("--set-file")
    local_nonpersistent_flags+=("--set-file=")
    flags+=("--set-string=")
    two_word_flags+=("--set-string")
    local_nonpersistent_flags+=("--set-string=")
    flags+=("--timeout=")
    two_word_flags+=("--timeout")
    local_nonpersistent_flags+=("--timeout=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--username=")
    two_word_flags+=("--username")
    local_nonpersistent_flags+=("--username=")
    flags+=("--values=")
    two_word_flags+=("--values")
    two_word_flags+=("-f")
    local_nonpersistent_flags+=("--values=")
    flags+=("--verify")
    local_nonpersistent_flags+=("--verify")
    flags+=("--version=")
    two_word_flags+=("--version")
    local_nonpersistent_flags+=("--version=")
    flags+=("--wait")
    local_nonpersistent_flags+=("--wait")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_verify()
{
    last_command="helm_verify"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--keyring=")
    two_word_flags+=("--keyring")
    local_nonpersistent_flags+=("--keyring=")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_version()
{
    last_command="helm_version"

    command_aliases=()

    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--client")
    flags+=("-c")
    local_nonpersistent_flags+=("--client")
    flags+=("--server")
    flags+=("-s")
    local_nonpersistent_flags+=("--server")
    flags+=("--short")
    local_nonpersistent_flags+=("--short")
    flags+=("--template=")
    two_word_flags+=("--template")
    local_nonpersistent_flags+=("--template=")
    flags+=("--tls")
    local_nonpersistent_flags+=("--tls")
    flags+=("--tls-ca-cert=")
    two_word_flags+=("--tls-ca-cert")
    local_nonpersistent_flags+=("--tls-ca-cert=")
    flags+=("--tls-cert=")
    two_word_flags+=("--tls-cert")
    local_nonpersistent_flags+=("--tls-cert=")
    flags+=("--tls-hostname=")
    two_word_flags+=("--tls-hostname")
    local_nonpersistent_flags+=("--tls-hostname=")
    flags+=("--tls-key=")
    two_word_flags+=("--tls-key")
    local_nonpersistent_flags+=("--tls-key=")
    flags+=("--tls-verify")
    local_nonpersistent_flags+=("--tls-verify")
    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_helm_root_command()
{
    last_command="helm"

    command_aliases=()

    commands=()
    commands+=("completion")
    commands+=("create")
    commands+=("delete")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("del")
        aliashash["del"]="delete"
    fi
    commands+=("dependency")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("dep")
        aliashash["dep"]="dependency"
        command_aliases+=("dependencies")
        aliashash["dependencies"]="dependency"
    fi
    commands+=("fetch")
    commands+=("get")
    commands+=("history")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("hist")
        aliashash["hist"]="history"
    fi
    commands+=("home")
    commands+=("init")
    commands+=("inspect")
    commands+=("install")
    commands+=("lint")
    commands+=("list")
    if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
        command_aliases+=("ls")
        aliashash["ls"]="list"
    fi
    commands+=("package")
    commands+=("plugin")
    commands+=("repo")
    commands+=("reset")
    commands+=("rollback")
    commands+=("search")
    commands+=("serve")
    commands+=("status")
    commands+=("template")
    commands+=("test")
    commands+=("upgrade")
    commands+=("verify")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--debug")
    flags+=("--home=")
    two_word_flags+=("--home")
    flags+=("--host=")
    two_word_flags+=("--host")
    flags+=("--kube-context=")
    two_word_flags+=("--kube-context")
    flags+=("--kubeconfig=")
    two_word_flags+=("--kubeconfig")
    flags+=("--tiller-connection-timeout=")
    two_word_flags+=("--tiller-connection-timeout")
    flags+=("--tiller-namespace=")
    two_word_flags+=("--tiller-namespace")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_helm()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    declare -A aliashash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __helm_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("helm")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __helm_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_helm helm
else
    complete -o default -o nospace -F __start_helm helm
fi

# ex: ts=4 sw=4 et filetype=sh

BASH_COMPLETION_EOF
}
__helm_bash_source <(__helm_convert_bash_to_zsh)
