#!/usr/bin/env bash

#######################
# MAIN script body
#######################

. /hive/miners/custom/kaspa-miner/h-manifest.conf

local stats_raw=`cat $CUSTOM_LOG_BASENAME.log | grep -w "hashrate" | tail -n 1 `


#Calculate miner log freshness
local maxDelay=120
local time_now=`date -u +%T | awk -F: '{ print ($1 * 3600) + $2*60 + $3 }'`
local time_rep=`echo $stats_raw | awk -FT '{print $2}' | awk -FZ '{print $1}' | awk -F: '{ print ($1*3600) + $2*60 + $3}'`
local diffTime=`echo $((time_now-time_rep)) | tr -d '-'`

if [ "$diffTime" -lt "$maxDelay" ]; then
        local total_hashrate=`echo $stats_raw | awk '{print $7}' | cut -d "." -f 1,2 --output-delimiter='' | sed 's/$/0/'`
        stats=$(jq -nc \
                --argjson hs "[$total_hashrate]"\
                --arg ver "$CUSTOM_VERSION" \
                --arg ths "$total_hashrate" \
                '{ hs: $hs, hs_units: "khs", algo : "heavyhash", ver:$ver }')
        khs=$total_hashrate
else
  khs=0
  stats="null"
fi

[[ -z $khs ]] && khs=0
[[ -z $stats ]] && stats="null"

