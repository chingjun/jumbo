#!/bin/sh
cd $(dirname "$0")
f="$PWD/tmp.tar"
final="$PWD/list.tar.gz"

cd $(dirname "$0")/installs
ls | while read i
do
    pkgname_expected=${i%.jumbo}
    [ "$pkgname_expected" == "$i" ] && continue
    (
        . "$i" && [ "$pkgname" == "$pkgname_expected" ]
    ) || continue
    tar -rf "$f.tmp" "$i"
done
if [ -f "$f.tmp" ]
then
    mv "$f.tmp" "$f"
    gzip "$f"
    mv "$f.gz" "$final"
fi
