# peco-completion-file

zstyle ':completion:*:*:peco:*:*' format '%BCompleting %d%b'

_peco_completion()
{
	_arguments \
		'-h, --help[show this help message and exit]' \
		'--tty[path to the TTY (usually, the value of $TTY)]' \
		'--query[initial value for query]' \
		'--rcfile[path to the settings file]' \
		'--no-ignore-case[start in case-sensitive-mode (DEPRECATED)]' \
		'--version[print the version and exit]' \
		'-b, --buffer-size[number of lines to keep in search buffer]' \
		'--null[expect NUL (\0) as separator for target/output]' \
		'--initial-index[position of the initial index of the selection (0 base)]' \
		'--initial-matcher[specify the default matcher]' \
		'--prompt[specify the prompt string]' \
		'--layout[layout to be used "top-down"(default) or "bottom-up"]' \
 		'*:file:_files'
}

compdef _peco_completion peco
