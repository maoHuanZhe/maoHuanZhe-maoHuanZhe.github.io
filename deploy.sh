#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run build

# 进入生成的文件夹
cd docs/.vuepress/dist

msg='deploy'
githubUrl=git@github.com:maoHuanZhe/maoHuanZhe-maoHuanZhe.github.io.git

git init
git add -A
git commit -m "${msg}"
git push -f $githubUrl main:dist # 推送到github gh-pages分支

cd -
rm -rf docs/.vuepress/dist
