#!/bin/bash

# Link in binding caps lock to another layer and start keyd
sudo ln -s ~/supercaps.conf /etc/keyd/default.conf
sudo systemctl enable keyd --now
