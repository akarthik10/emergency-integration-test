#!/usr/bin/env bash



while [ ! -f tail -f ~/Library/Logs/CoreSimulator/86B2CA7C-0247-4257-BFEA-8035084AF2CF/system.log ]
do
  sleep 2
done
tail -f ~/Library/Logs/CoreSimulator/86B2CA7C-0247-4257-BFEA-8035084AF2CF/system.log
