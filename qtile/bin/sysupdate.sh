#!/bin/bash

echo "Updating the system..."

# update system
sudo aptitude safe-upgrade

# restart qtile
qtile-cmd -o cmd -f restart
