#!/usr/bin/php
<?php

error_reporting(E_ALL | E_STRICT);
date_default_timezone_set('Europe/Prague');

$running = true;
declare(ticks=1);
function signalHandler($signo)
{
    global $running;
    $running = false;
}
pcntl_signal(SIGINT, 'signalHandler'); 

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
    
    $sgwm = str_replace("b827ebfffeafacff", "st-lora919", $sgwm);
    $sgwm = str_replace("b827ebfffe269969", "st-lora920", $sgwm);
    
    if (array_key_exists("rxpk", $data)) {
        $rxpk = $data["rxpk"];
        foreach ($rxpk as $key => $rxpk_row) {
	    $payload = bin2hex(base64_decode($rxpk_row["data"]));
	    printf(
		$sgwm . "\t" .
//		$rxpk_row["tmst"] . "\t" .
		date("H:i:s") . "\t" .
		$rxpk_row["chan"] . "\t" .
//		$rxpk_row["rfch"] . "\t" .
		$rxpk_row["freq"] . "\t" .
//		$rxpk_row["stat"] . "\t" .
//		$rxpk_row["modu"] . "\t" .
		$rxpk_row["datr"] . "\t" .
		$rxpk_row["codr"] . "\t" .
		$rxpk_row["lsnr"] . "\t" .
		$rxpk_row["rssi"] . "\t" .
//		$rxpk_row["size"] . "\t" .
		$payload . "\n"
	    );
        }
        passthru("/home/povalac/lora-packet/bin/lora-packet-decode --hex " . $payload);
	//printf("from %s:\n", $sgwm);
	//print_r($data);
    }
    
    /* send acknowledge and check return value */
    $buf[3] = 2; /* PKT_PUSH_ACK */
    socket_sendto($socket, $buf, 4, 0, $from, $port);
}

