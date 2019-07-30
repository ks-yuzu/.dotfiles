# make_vivado_script-completion-file

zstyle ':completion:*:*:make_vivado_script.pl:*:*' format '%BCompleting %d%b'

_make_vivado_script_completion()
{
	 _arguments \
		 '--help[ヘルプを表示]' \
		 '--sim[RTL シミュレーション用のスクリプトを生成]' \
		 '--synth[論理合成用のスクリプトを生成]' \
		 '--delete[生成したスクリプトを削除]' \
		 '*:file:_files'
}


compdef _make_vivado_script_completion make_vivado_script.pl
