#!/bin/bash

if [ "$1" = "" ] || [ "$2" = "" ]; then
  echo "Usage: ./check-my-ip <DYN_HOSTNAME> <MY_EMAIL>" >&2
  exit 1;
fi

DYN_HOSTNAME="$1"
MY_EMAIL="$2"

LAST_WAN_IP_FILE="$HOME/.last-known-wanip-$DYN_HOSTNAME"

if ! [ -x "$(command -v dig)" ]; then
  echo "DiG not found. Aborting." >&2
  exit 1;
fi

if ! [ -x "$(command -v mail)" ]; then
  echo "Mailx not found. Aborting." >&2
  exit 1;
fi

if [ -f "$LAST_WAN_IP_FILE" ]; then
  LAST_WAN_IP=`cat $LAST_WAN_IP_FILE`
  echo Last WAN IP: $LAST_WAN_IP
else
  echo Last WAN IP: Unknown
  touch "$LAST_WAN_IP_FILE"
fi

WAN_IP=`dig A $DYN_HOSTNAME +short`

echo Current WAN IP: $WAN_IP

if [ "$LAST_WAN_IP" != "$WAN_IP" ]; then
  echo IP Change Detected
  echo -n $WAN_IP > $LAST_WAN_IP_FILE

  mail -s "$DYN_HOSTNAME IP Address Changed To $WAN_IP" $MY_EMAIL <<EOF
    Hello.

    This is to inform you that your IP address was changed to $WAN_IP from $LAST_WAN_IP
EOF
fi
