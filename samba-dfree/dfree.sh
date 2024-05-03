#!/bin/sh
/bin/df -k $1 | tail -1 | awk '{print $3" "$5}'