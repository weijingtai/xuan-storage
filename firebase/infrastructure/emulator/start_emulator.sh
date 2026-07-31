#!/bin/bash
set -e
cd "$(dirname "$0")"
firebase emulators:start --import=./seed --export-on-exit
