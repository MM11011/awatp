#!/bin/bash

# Ensure core/__init__.py exists
if [ ! -f core/__init__.py ]; then
  echo "Creating core/__init__.py..."
  mkdir -p core
  touch core/__init__.py
else
  echo "core/__init__.py already exists."
fi

# Move main.py from awatp_ui/lib/ to project root
if [ -f awatp_ui/lib/main.py ]; then
  echo "Moving main.py to project root..."
  mv awatp_ui/lib/main.py ./main.py
else
  echo "main.py not found in awatp_ui/lib/. Nothing moved."
fi

echo "✅ Done. Your layout should now be correct."
