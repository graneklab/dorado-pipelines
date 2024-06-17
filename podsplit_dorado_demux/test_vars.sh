
#!/usr/bin/env bash



export MY_DEFINED_VAR="I am defined"


if [ -v MY_DEFINED_VAR ]; then 
  echo "MY_DEFINED_VAR IS set"
else 
  echo "No MY_DEFINED_VAR"
fi


if [ -v NOT_DEFINED_VAR ]; then 
  echo "NOT_DEFINED_VAR IS set"
else 
  echo "No NOT_DEFINED_VAR"
fi