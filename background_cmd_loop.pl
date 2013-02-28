#!/usr/bin/perl
################################################################################
# 指定コマンドを定周期で決まった回数実行するスクリプト
# $ARGV[0] 実行するコマンド
#          第二引数で指定されるディレクトリのファイルを引数とするコマンドを想定
# $ARGV[1] ファイルディレクトリ
#          本ディレクトリ配下のファイルを、第一引数のコマンド引数に指定する
# $ARGV[2] コマンド実行間隔(秒)
# $ARGV[3] ループ回数
#          第二引数のディレクトリ内ファイル一通りについての処理を１セットとして
#          何セット処理を行うかを指定する
#          無限ループ時は0を指定する
################################################################################
use strict;
use warnings;

my ($exec_cmd, $file_dir, $exec_interval, $loop_num) = @ARGV; 

my $cnt=0;
while(1) {
	my @csv_files = glob "${file_dir}/*.*";
	foreach my $csv_file ( @csv_files ) {
		system("$exec_cmd $csv_file &" );
		sleep $exec_interval;
	}

	if ( $loop_num != 0 ) {
		last if ( $loop_num == ++$cnt );
	}
}
