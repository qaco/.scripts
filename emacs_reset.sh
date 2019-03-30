#!/bin/bash

cd
emacsclient -e '(kill-emacs)' ; emacs24 --daemon
