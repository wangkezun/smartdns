#!/bin/sh

curl $1 |grep -v Premium|awk -F ',' '{gsub(/ /,"",$2)gsub(/ /,"",$3);printf "domain-rules /%s/ -speed-check-mode tcp:%s -nameserver domestic\n",$2,$3}'|sort|uniq >> nexitally.conf