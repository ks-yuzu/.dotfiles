#!/usr/bin/env perl
use v5.12;
use warnings;
 
use utf8;
use open IO => qw/:encoding(UTF-8) :std/;
 
 
# コピーするコマンド数
my $n_copy_commands = -f $ARGV[0] ? slurp($ARGV[0]) : undef;
$n_copy_commands = 1 if ! defined $n_copy_commands || $n_copy_commands !~ /^\d+\s*$/;
 
# tmux のバッファ内容を取得 (+ 末尾の空行削除)
my @lines = <stdin>;
while ( 1 ) {
  if ( $lines[-1] eq "\n" ) { pop @lines }
  else                      { last }
}
 
# プロンプト抽出
my $prompt = $lines[-1] =~ s/\s+$//r
                        =~ s/ {10,}.*$//r;
$prompt = (length $prompt <= 1) ? $lines[-2] : $prompt; # 1 文字以下なら 2 行プロンプトと判断
chomp $prompt;
 
# プロンプトの正規表現生成
my $regexp_prompt = $prompt
  =~ s/([\\\*\+\.\?\{\}\(\)\[\]\^\$\-\|\/])/\\$1/gr
  =~ s/\d/\\d/gr;
 
# プロンプト行を後ろから n 個分抽出
my @prompt_line_no;
for my $i ( reverse 0..$#lines ) {
  if ( $lines[$i] =~ /$regexp_prompt/ ) {
    unshift @prompt_line_no, $i;
    last if scalar @prompt_line_no > $n_copy_commands; # 現在のプロンプトを含むため +1
  }
}
 
# 先頭行, 末尾行を選択
my $line_begin = $prompt_line_no[0];
my $line_end   = $prompt_line_no[-1];
 
# コマンド範囲を出力
my $output = join '', splice @lines, $line_begin, ($line_end - $line_begin);
chomp $output;
print $output;
 
 
 
sub slurp {
  my $filename = shift;
  open my $fh, '<', $filename;
  my $tmp = join '', <$fh>;
  close $fh;
  return $tmp;
}
