# ilpbind-completion-file

zstyle ':completion:*:*:ilpbind.pl:*:*' format '%BCompleting %d%b'

_ilpbind_completion()
{
	_arguments \
		'-S-[ソルバー (GLPK または CPLEX) を指定する]:ソルバーの指定:__option_S' \
		'-M[ハードウェアのデータパス情報 (デフォルトは/home/yuzu/ccap/bin/dp_std32.pl)]' \
		'-m-[レジスタ (reg) と演算器の制約をどれだけ緩和するかを指定]:m:__option_m' \
		'-c-[delay[チェイニングを行っている場合の 1 サイクルの時間]:c:__option_c' \
 		'*:file:_files'
}

__option_S()
{
    _values \
        'ソルバーの指定(デフォルトは CPLEX, CPLEX がなければ GLPK)' \
		'CPLEX' \
		'GLPK'
}

__option_m()
{
    _values \
		'レジスタと演算器の制約の緩和を次のように指定する  e.g.) -m reg+3,ALU+2,MLDV_MUL+1' \
		'reg' \
		'ALU' \
		'MLDV' \
		'MUL'
}

__option_c()
{
	_values \
		'チェイニングを行っている場合の 1 サイクルの時間' \
		'0[チェイニングなし(default)]' \
		'[(1以上)1サイクルあたりの時間を指定]'
}

 # -T bdat
 #   bdat (バックエンドの ILP ファイルを生成するためのデータ) を出力して終了
 # -b BDAT_F.bdat
 #   BDAT_F に保存していた bdat データを使って問題を解く
 # -D
 #   ILP の解をダンプする (-b の場合は自動的に出る)
 # -t N 
 #   ソルバーの CPU 時間制限を 1 パスあたり N [sec] とする
 #   (default 2147483647)
 # -i N
 #   ILP の 1 パスで解くステップ数の上限を N とする
 #   (デフォルトは 2147483647)
 # -l N
 #   ILP で解く以外のパスに実数制約を課すステップ数の上限を N とする
 #   (デフォルトは 2147483647)
 # -I N
 #   ILP の 1 パスで解くステップに含まれる節点数の上限を N とする
 #   ただし, 最初のステップの節点数が N を超える場合は 1 とする
 #   (デフォルトは 2147483647)
 # -L N
 #   ILP で解く以外のパスに実数制約を課すステップ含まれる節点数の上限を N とする
 #   ただし, 最初のステップの節点数が N を超える場合は 1 とする
 #   (デフォルトは 2147483647)
 # -P R
 #   1以上の実数を指定. -I と -L で指定した値を, 繰り返し毎に R 倍する
 #   (デフォルトは 1)
 # -C
 #   インタラクティブモード





# sannkou

# 		 '-h[help メッセージを出力する]' \
# 		 '-D-[指定されたサフィックスの中間表現を出力する]:出力ファイル指定:__option_D' \
# 		 '-T-[指定されたサフィックスの中間表現を出力して終了する]:opT:__option_T' \
# 		 '-Z-[CPU + プログラムと等価なHWを合成. リンク済アセンブリの全区間が対象]:opZ:__option_Z' \
# 		 '-O-[最適化オプション付加で合成. (デフォルトは -O2 )]:opO:__option_O' \
# 		 '-o[結果を OUTFILE に出力する. 省略すると標準出力]' \
# 		 '-t-[入力がどの中間表現かを指定する（省略可能）]:opt:__file_type' \
# 		 '-l[ACAP の全ての出力を directory 下に置く]' \
#  		 '-M[ACAP で合成するハードウェアのデータパス情報を指定(default:~/ccap/bin/dp_std32.pl)]' \
#  		 '-m[ACAP で合成する各演算器の制約を指定(default:~ccap/bin/std32_1.cst)]' \
#  		 '-v-[メッセージの量を 0, 1, 2, 3, … で調節 (デフォルトは 1 )]:opv:__option_v' \
#  		 '-c-[チェイニング時の1サイクルの時間 (単位 : ns)]:opc:__option_c' \
#  		 '-s-[バインディング時の演算器共有方法]:ops:__option_s' \
#   		 '-A[リンク済アセンブリを対象に合成 (/ccap3/lib を LIBDIR に設定する必要あり)]' \
#   		 '-V[可変スケジューリングで合成]' \
#    		 '-C-[ハードウェアをコプロセッサとして合成]:opC:__option_C' \
# 		 '-e[評価用(busyloop, RUNなどは含めないで合成)]' \
# 		 '-u[1 ファイル を 1 HW 化 (unitfly)]' \
# 		 '-E[HW 入口出口コード DFG, HW 起動待ち DFG を生成しない(将来的に削除)]' \
# 		 '--gccopts[gcc でコンパイルする際に使用するオプションを指定(スペースで複数指定可)]' \
# 		 '--gccdir[mips-elf-gcc のあるディレクトリを指定]' \
# 		 '--libdir[ccaplib のパスを指定(省略すると, 環境変数 LIBDIR を参照)]' \
# 		 '--st[関数併合における状態変換を有効にする (-E および -u オプションとの併用必須)]' \
# 		 '--dm[データメモリ(.dmem)を入力. 省略すると, 合成ファイルと同名のものを使用]' \
# 		 '--sfu[softfloat 関数の呼出しを専用演算に変換]' \
# 		 '*:file:_files'
# }



compdef _ilpbind_completion ilpbind.pl
