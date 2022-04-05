@echo off

cmd /C npm run build

cd dist
git init
git add -A
git commit -m "deploy with dist directory"
git push -f https://sundlee:{personalAccessToken}@github.com/sundlee/my-vue-online-editor.git master:gh-pages

cd ..