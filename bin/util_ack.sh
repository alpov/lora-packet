#!/usr/bin/php
<?php

error_reporting(E_ALL | E_STRICT);

$running = true;
declare(ticks=1);
function signalHandler($signo)
{
    global $running;
    $running = false;
}
pcntl_signal(SIGINT, 'signalHandler'); 

$conn = new mysqli("127.0.0.1", "lora", "lora", "lora") or die("DB fail");

$socket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP);
socket_bind($socket, '0.0.0.0', 1680);
printf("Ready...\n");

while ($running) {
    usleep(30000); /* 30 ms */
    
    $from = '';
    $port = 0;
    $byte_nb = @socket_recvfrom($socket, $buf, 4096, MSG_DONTWAIT, $from, $port);
    
    if ($byte_nb === false) continue;

    if ($byte_nb < 12) continue; /* not enough bytes for packet from gateway */
    if (ord($buf[0]) != 1 && ord($buf[0]) != 2) continue; /* check protocol version number */
    if (ord($buf[3]) != 0) continue; /* interpret only gateway command PKT_PUSH_DATA */
    
    $data = json_decode(substr($buf, 12), true);
    $sgwm = bin2hex(substr($buf, 4, 8));
    
    if (array_key_exists("rxpk", $data)) {
        $rxpk = $data["rxpk"];
        foreach ($rxpk as $key => $rxpk_row) {
	    $sql = "INSERT INTO rxpk (sgwm, tmst, time, chan, rfch, freq, stat, modu, datr, codr, lsnr, rssi, size, data) VALUES (" .
		"'" . $sgwm . "', " .
		$rxpk_row["tmst"] . ", " .
		"'" . $rxpk_row["time"] . "', " .
		$rxpk_row["chan"] . ", " .
		$rxpk_row["rfch"] . ", " .
		$rxpk_row["freq"] . ", " .
		$rxpk_row["stat"] . ", " .
		"'" . $rxpk_row["modu"] . "', " .
		"'" . $rxpk_row["datr"] . "', " .
		"'" . $rxpk_row["codr"] . "', " .
		$rxpk_row["lsnr"] . ", " .
		$rxpk_row["rssi"] . ", " .
		$rxpk_row["size"] . ", " .
		"'" . $rxpk_row["data"] . "')";
	    $conn->query($sql);
        }
    }
    if (array_key_exists("stat", $data)) {
        $stat = $data["stat"];
        $sql = "INSERT INTO stat (sgwm, time, rxnb, rxok, rxfw, ackr, dwnb, txnb, `desc`) VALUES (" .
	    "'" . $sgwm . "', " .
	    "'" . $stat["time"] . "', " .
	    $stat["rxnb"] . ", " .
	    $stat["rxok"] . ", " .
	    $stat["rxfw"] . ", " .
	    $stat["ackr"] . ", " .
	    $stat["dwnb"] . ", " .
	    $stat["txnb"] . ", " .
	    "'" . $stat["desc"] . "')";
	$conn->query($sql);
	echo $sql;
    }
    
    printf("from %s:\n", $sgwm);
    print_r($data);
    
    /* send acknowledge and check return value */
    $buf[3] = 2; /* PKT_PUSH_ACK */
    socket_sendto($socket, $buf, 4, 0, $from, $port);
}

$conn->close();
