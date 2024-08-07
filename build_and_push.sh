#!/bin/bash

# build
python3 -m pip install --upgrade build
python3 -m build

# push
python3 -m pip install --upgrade twine
python3 -m twine upload --repository pypi dist/*
