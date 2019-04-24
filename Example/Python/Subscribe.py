#!/usr/bin/env python
import sys
import time

import zmq
import numpy

def main():
    connect_to = "tcp://127.0.0.1:5559"
    topics = ""

    ctx = zmq.Context()
    s = ctx.socket(zmq.SUB)
    s.connect(connect_to)
    s.setsockopt(zmq.SUBSCRIBE, b'')

    try:
        while True:
            recv = s.recv_multipart()
            recvMsg = recv[0].decode("utf-8")
            message = recvMsg.split(" ")
            quotes = message[1].split("|")

            v_symbol = quotes[0]
            v_ask = quotes[1]
            v_bid = quotes[2]
            v_spread = quotes[3]
            
            print("Symbol: ", v_symbol, ", Ask: ", v_ask, ", Bid: ", v_bid, ", Spread: ", v_spread)
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    main()
