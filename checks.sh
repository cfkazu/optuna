#!/bin/bash

res_pip_list=$(pip freeze)
missing_dependencies=()
if [ ! "$(echo $res_pip_list | grep black)" ] ; then
  missing_dependencies+=(black)
fi
if [ ! "$(echo $res_pip_list | grep flake8)" ] ; then
  missing_dependencies+=(flake8)
fi
if [ ! "$(echo $res_pip_list | grep isort)" ] ; then
  missing_dependencies+=(isort)
fi
if [ ! "$(echo $res_pip_list | grep mypy)" ] ; then
  missing_dependencies+=(mypy)
fi
if [ ! ${#missing_dependencies[@]} -eq 0 ]; then
  echo "The following dependencies are missed:" "${missing_dependencies[@]}"
  read -p "Would you like to install the missing dependencies? (y/N): " yn
  case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac
  pip install "${missing_dependencies[@]}"
fi

update=0
while getopts "u" OPT
do
  case $OPT in
    u) update=1
       ;;
    *) ;;
  esac
done

res_black=$(black . --check 2>&1)
if [ "$(echo $res_black | grep reformatted)" ] ; then
  if [ $update -eq 1 ] ; then
    echo "Failed with black. The code will be formatted by black."
    black .
  else
    echo "$res_black"
    echo "Failed with black."
    exit 1
  fi
else
  echo "Success in black."
fi

res_flake8=$(flake8 .)
if [ $res_flake8 ] ; then
  echo "$res_flake8"
  echo "Failed with flake8."
  exit 1
fi
echo "Success in flake8."

res_isort=$(isort . --check 2>&1)
if [ "$(echo $res_isort | grep ERROR)" ] ; then
  if [ $update -eq 1 ] ; then
    echo "Failed with isort. The code will be formatted by isort."
    isort .
  else
    echo "$res_isort"
    echo "Failed with isort."
    exit 1
  fi
else
  echo "Success in isort."
fi

res_mypy=$(mypy .)
if [ ! "$(echo $res_mypy | grep Success)" ] ; then
  echo "$res_mypy"
  echo "Failed with mypy."
  exit 1
fi
echo "Success in mypy"

