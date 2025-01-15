flutter clean;
flutter build web --release;
cp -rf ./build/web/ ./docs/;
git add docs/*;
git commit -m "New deploy to github pages";
git push;