#!/bin/sh

echo "Syncing strings..."

cd translate/scripts
git checkout master
git pull
hash=$(git rev-parse --short HEAD)
commit="translate: sync strings to: $hash"

echo $commit

./translate.py -a common

cd ../../

echo "Running gen-l10n for common..."
flutter gen-l10n

git commit -am "$commit"

echo "Done"
