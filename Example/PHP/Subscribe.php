<?php
$enabled = true;
$serverAddr = "tcp://localhost:5559";

$socket = new ZMQSocket(new ZMQContext(), ZMQ::SOCKET_SUB);
$socket->connect($serverAddr );
$socket->setSockOpt(ZMQ::SOCKOPT_SUBSCRIBE, "");

// Zmq blocking mode for received the message
while ($enabled) {
    $messageReceived = trim($socket->recv());
    $messageData = explode(" ", $messageReceived);
    
    if (count($messageData) != 2)
        continue;

    $orderData = explode("|", $messageData[1]);

    if (count($orderData) != 4)
        continue;

    print_r([
        "Login"  => $messageData[0],
        "Symbol" => $orderData[0],
        "Ask"    => $orderData[1],
        "Bid"    => $orderData[2],
        "Spread" => $orderData[3]
    ]);
}

$socket->disconnect($serverAddr );