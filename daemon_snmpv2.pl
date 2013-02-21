#!/usr/bin/perl

use IO::File;
use Proc::Daemon;
use Net::SNMP;

use strict;
use warnings;


# 初期化処理
# 本初期化処理中で、daemonプロセスを起動する
init();

# 業務処理を実行開始
action();


# 以降は関数定義

# 初期化処理
# 本関数は、親プロセス(デーモン起動元)の処理となる
# 本関数内で、Proc::Daemon::Initコールした時にデーモンが起動される
sub init {
	# シグナルハンドラ登録
    $SIG{INT}  = 'finalize';         # Ctrl-C が押された場合
    $SIG{HUP}  = 'finalize';         # HUP  シグナルが送られた場合
    $SIG{TERM} = 'finalize';         # TERM シグナルが送られた場合
    
    # Daemon起動
    # 本関数実行により、以降の処理はDaemonとして起動された
    # 子プロセス側の処理としてのみ実行される
    Proc::Daemon::Init( {
    	work_dir		=> '/tmp/',
    	child_STDOUT	=> '+>>/tmp/stdout.log',	# 標準出力への出力内容が出力される
    	child_STDERR	=> '+>>/tmp/stdERR.log',	# 標準エラー出力への出力内容が出力される
    	pid_file		=> 'child.pid'	# daemonのPIDが出力される
	} );
    
    # 復帰値を取得すると、デーモン起動した親プロセスの処理も並行する
    # Daemon起動後に親プロセスとしての処理が不要な場合は、復帰値取得なしで
    # 処理を実行する
    #my $pid = Proc::Daemon::Init(
    #	work_dir		=> '/tmp/',
    #	pid_file		=> 'child.pid'
    #);
}

# 業務処理
# 常駐プロセスの動作は、この関数内の処理となる
sub action {
	print "daemon: pid:$$\n";
	my $sleep_interval = 3;     # スリープの間隔（秒）
	my $starttime = time;
    while(1) {
    	#open(my $filehandle, '>>', '/tmp/daemon_output.txt') or die;
    	#print $filehandle time." action!\n";
    	#close($filehandle);
    	
    	send_snmptrap('127.0.0.1', time - $starttime, '.1.3.6.1.6.3.1.1.5.10');
    	
    	print "time:".time."\n";
    	
        sleep($sleep_interval);
    }
}

# 終了処理
# 本関数はシグナル受信時のコールバック関数として定義している
# 本関数のコールによりプロセスを終了する
sub finalize {
    my $sig = shift; 
    die "killed by $sig"; 

    exit(0);
}

# SNMP-TRAP送信
sub send_snmptrap {
	# 送信先IP、プロセス起動からの経過時刻、TrapOID, 追加するVarBindList
	my ($destIp, $upTime, $trapOid, @additionalVarBindList ) = @_;
	my @varBindList = [
		# sysUpTime
		'.1.3.6.1.2.1.1.3.0',
		TIMETICKS,
		$upTime,

		# sysTrapOID
		'.1.3.6.1.6.3.1.1.4.1.0',
		OBJECT_IDENTIFIER,
		$trapOid,
		
		# 追加するVarBindList
		# OID、データ型、データのセットを指定する
		# セットは複数のセットでも可
		@additionalVarBindList
	];
	
	# SNMP-TRAP(v2c)のセッションオープン
	my ( $snmpsession, $error ) = Net::SNMP->session(
		-version => 'snmpv2c',
		-hostname => $destIp,
		-community => 'public',
		-port => 162
	);

	# SNMP-TRAP(v2c)を送信
	my $result = $snmpsession->snmpv2_trap(
		-varbindlist  => @varBindList
	);
	
	if ( not defined($result) ) {
    	warn( "Net::SNMP trap ERROR: $!¥n", $snmpsession->error );
	}
} 



