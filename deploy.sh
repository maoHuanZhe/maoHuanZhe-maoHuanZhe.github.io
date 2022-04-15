#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

git pull gitee

git pull github

git add -A
git commit -m "linux change file"
git push gitee

git push github


