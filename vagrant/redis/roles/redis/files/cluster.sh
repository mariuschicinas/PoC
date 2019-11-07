#!/bin/sh

echo "yes" | redis-cli --cluster create 10.10.0.3:6379 10.10.0.4:6379 10.10.0.5:6379
