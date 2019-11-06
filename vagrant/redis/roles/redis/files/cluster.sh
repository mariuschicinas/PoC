#!/bin/sh

echo "yes" | redis-cli --cluster create 192.168.33.50:6379 192.168.33.51:6379 192.168.33.52:6379
