#!/bin/bash -e

while IFS=, read pos name type signal label 
do
  if [ "$pos" != '"Position"' ]; then
    name=$(echo $name | sed -e 's/^"\(.*\)"$/\1/' | sed -e 's/\([^-]*\)-\(.*\)$/\1/')
    label=$(echo $label | sed -e 's/^"\(.*\)"$/\1/')
    altLabel=$(echo $signal | sed -e 's/^"\(.*\)"$/\1/')
    if [ "$label" == '' ] || [ "$label" == 'Label' ]; then
      label=${altLabel}
    fi
    if [ "$label" != '' ] && [ "$label" != 'Label' ]; then
      label=$(echo ${label} | tr a-z A-Z | tr ' ' '_' | tr -cd 'A-Z0-9_')
      echo "#define ${label}_PORT GPIO${name:1:1}"
      echo "#define ${label}_PIN GPIO_PIN_${name:2}"
    fi
  fi
done < "${1:-/dev/stdin}"
