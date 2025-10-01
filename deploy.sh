#!/usr/bin/env bash
#
# Github pages deployment script
#
# Author: hxuu <an.mokhtari@esi-sba.dz>
# License: GPL

# init a new git repo inside _site (safe, standalone)
git init
git checkout -b gh-pages
git add .
git commit -m "Deploy site"

# push to your repo's gh-pages branch
git remote add origin git@github.com:hxuu/ctfdi.git
git push -f origin gh-pages

