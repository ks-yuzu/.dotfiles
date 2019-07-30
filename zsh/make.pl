#!/usr/bin/env perl
use v5.26;
use warnings;
use diagnostics;
use autodie qw(:all);

use utf8;
use open IO => qw/:encoding(UTF-8) :std/;

use Cwd;
use Path::Tiny;

use Term::ANSIColor;

my $SOURCE_DIR = './src/';
my $OUTPUT_DIR = './dist/';
my $JOINED_SRC = './dist/.zshrc';


sub build {
  path($OUTPUT_DIR)->mkpath;
  path($JOINED_SRC)->spew('');
  # rm -f ~/.zcompdump

  # TODO: src に

  my @zshfiles = path($SOURCE_DIR)->children(qr/\.zsh/);
  for my $zshfile ( sort @zshfiles ) {
    say sprintf "* %-30s %s",
      $zshfile->basename,
      ($zshfile->basename =~ /\.zsh$/ ? color('green').'enabled '.color('reset')
                                      : color('red').'disabled'.color('reset'));


    if ( $zshfile->basename =~ /\.zsh$/ ) {
      path($JOINED_SRC)->append($zshfile->lines)
    }
  }


  system qq(zsh -n $JOINED_SRC);              # syntax check
  system qq(zsh -c "zcompile $JOINED_SRC");   # compile
  system qq(zsh -c "autoload -Uz compinit && compinit"); # compinit は毎回実行しない

  path("${JOINED_SRC}.zwc")->copy( "${JOINED_SRC}.zwc.bak" );
  path("${JOINED_SRC}.zwc")->copy( "$ENV{HOME}/.zshrc.zwc" );

  say "\ngenerated.";
}

build()
