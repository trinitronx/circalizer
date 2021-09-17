#!/bin/bash
# https://www.codegrepper.com/code-examples/whatever/create+a+venv+in+jupyter

# Assume user has mkvirtualenv
[ -f ~/.virtualenvs/circalizer/bin/activate ] || mkvirtualenv circalizer
if ! grep -qE '^include-system-site-packages\s+=\s+true$' ~/.virtualenvs/circalizer/pyvenv.cfg
then
	sed -i -e 's/^include-system-site-packages[[:space:]]*=[[:space:]]*.*$/include-system-site-packages = true/g' ~/.virtualenvs/circalizer/pyvenv.cfg
fi
source ~/.virtualenvs/circalizer/bin/activate
~/.virtualenvs/circalizer/bin/pip3 install --user --upgrade -r build-aux/jupyter-requirements.txt

ipython3 kernel install --user --name=circalizer
