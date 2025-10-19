#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while ps -A | grep polybar
      echo "wow";
      sleep 2;
  end;

# Launch Polybar, using default config location ~/.config/polybar/config
polybar --config="~/.config/polybar/config" notsofancy-bar &

echo "Polybar launched..."
