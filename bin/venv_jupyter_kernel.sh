#!/bin/bash
# https://www.codegrepper.com/code-examples/whatever/create+a+venv+in+jupyter

# Assume user has mkvirtualenv
[ -f ~/.virtualenvs/circalizer/bin/activate ] || mkvirtualenv circalizer
source ~/.virtualenvs/circalizer/bin/activate
~/.virtualenvs/circalizer/bin/pip3 install --user --upgrade -r requirements.txt

ipython3 kernel install --user --name=circalizer
