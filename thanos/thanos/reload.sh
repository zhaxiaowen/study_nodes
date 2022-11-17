#!/bin/bash
ip=`kubectl get pod -o wide -n thanos | grep prometheus | awk '{ print $8 }'`
for j in $ip
do
    echo $j;
    curl -s -X POST "$j":9090/-/reload
done
echo 'reload success'
