#!/usr/bin/env bash

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
socat pty,raw,echo=0,link=./uart/pty/uart pty,raw,echo=0,link=./uart/pty/uart_wrapper &
sleep .25
./uart/Vtop_level
