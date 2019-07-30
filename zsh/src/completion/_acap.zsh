# acap-completion-file

zstyle ':completion:*:*:acap.pl:*:*' format '%BCompleting %d%b'

_acap_completion()
{
	 _arguments \
		 '-h[help メッセージを出力する]' \
		 '-D-[指定されたサフィックスの中間表現を出力する]:出力ファイル指定:__option_D' \
		 '-T-[指定されたサフィックスの中間表現を出力して終了する]:opT:__option_T' \
		 '-Z-[CPU + プログラムと等価なHWを合成. リンク済アセンブリの全区間が対象]:opZ:__option_Z' \
		 '-O-[最適化オプション付加で合成. (デフォルトは -O2 )]:opO:__option_O' \
		 '-o[結果を OUTFILE に出力する. 省略すると標準出力]' \
		 '-t-[入力がどの中間表現かを指定する（省略可能）]:opt:__file_type' \
		 '-l[ACAP の全ての出力を directory 下に置く]' \
 		 '-M[ACAP で合成するハードウェアのデータパス情報を指定(default:~/ccap/bin/dp_std32.pl)]' \
 		 '-m[ACAP で合成する各演算器の制約を指定(default:~ccap/bin/std32_1.cst)]' \
 		 '-v-[メッセージの量を 0, 1, 2, 3, … で調節 (デフォルトは 1 )]:opv:__option_v' \
 		 '-c[チェイニング時の1サイクルの時間 (単位 : ns)]:opc:__option_c' \
 		 '-s-[バインディング時の演算器共有方法]:ops:__option_s' \
  		 '-A[リンク済アセンブリを対象に合成 (/ccap3/lib を LIBDIR に設定する必要あり)]' \
  		 '-V[可変スケジューリングで合成]' \
   		 '-C-[ハードウェアをコプロセッサとして合成]:opC:__option_C' \
		 '-e[評価用(busyloop, RUNなどは含めないで合成)]' \
		 '-u[1 ファイル を 1 HW 化 (unitfly)]' \
		 '-E[HW 入口出口コード DFG, HW 起動待ち DFG を生成しない(将来的に削除)]' \
		 '--gccopts[gcc でコンパイルする際に使用するオプションを指定(スペースで複数指定可)]' \
		 '--gccdir[mips-elf-gcc のあるディレクトリを指定]' \
		 '--libdir[ccaplib のパスを指定(省略すると, 環境変数 LIBDIR を参照)]' \
		 '--st[関数併合における状態変換を有効にする (-E および -u オプションとの併用必須)]' \
		 '--dm[データメモリ(.dmem)を入力. 省略すると, 合成ファイルと同名のものを使用]' \
		 '--sfu[softfloat 関数の呼出しを専用演算に変換]' \
		 '*:file:_files'
}

__option_D() { _values '出力形式指定' 'all' 'out' 'low' 'dfa' 'sch' 'bnd' 'stl' 'rtl' 'v' }
__option_T() { _values '停止するステップ' 'out' 'low' 'dfa' 'sch' 'bnd' 'stl' 'rtl'}
__option_v() { _values 'エラーの表示レベル(最大不明)' '0' '1' '2' '3' '4'}

__option_Z()
{
    _values \
        '合成モードの指定' \
		'1[通常モード]' \
		'2[割込み処理合成モード]'
}

__file_type()
{
	_values \
		'ファイル形式の指定' \
		'c[ Cプログラム]' \
		'out[mips アセンブリ]' \
		'cdfg0[.out を cdfg に変換したもの]' \
		'cdfg[.cdfg0 に正規化処理を行い hls 向けの変換処理を行ったもの]' \
		'low[.cdfg を DFG の状態遷移に変換したもの]' \
		'dfa0[.low のデータフロー解析を行ったもの]' \
		'dfa[.dfg0 にマージ処理を行ったもの]' \
		'sch[.dfa に対してスケジューリングを行ったもの]' \
		'bnd[.sch に対してバインディングを行ったもの]' \
		'stl[バインディング済み cdfg を状態機械に変換したもの]' \
		'dstl[動的バインディング済み cdfg を状態機械に変換したもの]' \
		'rtl[stl を HDL 非依存な RTL 表現に変換したもの]' \
		'v[rtl からハードウェア記述言語である Verilog HDL を生成したもの]' \
}

__option_O()
{
	_values \
		'最適化の指定' \
		'0[最適化なし]' \
		'1[-O1 で最適化]' \
		'2[-O2 で最適化]' \
		'3[-O3 で最適化]' \
		's[コードサイズについて最適化]'
}

__option_c()
{
	_values \
		'チェイニング時の1サイクルの時間(default : 0)' \
		'0[チェイニング非適用]' \
		'[(1以上)1サイクルあたりの時間(ns)]'
}

__option_s()
{
	_values \
		'バインディング時の演算器共有方法(default : 2)' \
	    '0[完全非共有]' \
		'1[部分共有]' \
		'2[完全共有]' 
}

__option_C()
{
	_values \
		'ハードウェアをコプロセッサとして合成' \
		'1[CDFG段階での命令抽出 (入力がC言語の場合, STL段階以降は何もしない.)]' \
		'2[アセンブリ段階での命令抽出 (入力がC言語の場合, CDFG段階以降は何もしない)]'
}


compdef _acap_completion acap.pl
