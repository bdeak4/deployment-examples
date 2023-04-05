#!/usr/bin/env bash

curl --json "{ text: \"*[$AUDIT_BROADCAST_APP]* $1\" }" "$AUDIT_BROADCAST_WEBHOOK"
