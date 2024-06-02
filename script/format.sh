#!/bin/sh

if [ ! $CI ]; then
  swift format -r ./Sources ./Tests ./Examples -i
fi
