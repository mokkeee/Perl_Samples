#!/usr/bin/perl
################################################################################
# ���ꥳ�ޥ�ɤ�������Ƿ�ޤä�����¹Ԥ��륹����ץ�
# $ARGV[0] �¹Ԥ��륳�ޥ��
#          ��������ǻ��ꤵ���ǥ��쥯�ȥ�Υե����������Ȥ��륳�ޥ�ɤ�����
# $ARGV[1] �ե�����ǥ��쥯�ȥ�
#          �ܥǥ��쥯�ȥ��۲��Υե�������������Υ��ޥ�ɰ����˻��ꤹ��
# $ARGV[2] ���ޥ�ɼ¹Դֳ�(��)
# $ARGV[3] �롼�ײ��
#          ��������Υǥ��쥯�ȥ���ե�������̤�ˤĤ��Ƥν����򣱥��åȤȤ���
#          �����åȽ�����Ԥ�������ꤹ��
#          ̵�¥롼�׻���0����ꤹ��
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