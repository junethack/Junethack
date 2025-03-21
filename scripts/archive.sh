#!/bin/bash -xe

rm -rf /tmp/junethack_mirror/

httrack_params="--max-rate=0 --connection-per-second=0 --disable-security-limits"
httrack $httrack_params http://127.0.0.1:4567 -O /tmp/junethack_mirror '+https://www.gravatar.com*' '-127.0.0.1:4567/archive/*' -%v

rm -rf public/archive/2024
mv /tmp/junethack_mirror/127.0.0.1_4567 public/archive/2024

mkdir -p public/archive/www.gravatar.com/2024/
cp /tmp/junethack_mirror/www.gravatar.com/avatar/* public/archive/www.gravatar.com/2024/

sed -i "s/<a class='logo' href='index.html'>/<a class='logo' href='\/'>/" public/archive/2024/*.html

find public/archive/2024/ -name \*.html -print0 | xargs -0 sed -i "s/href='http:\/\/127.0.0.1:4567\/archive\//href='\/archive\//"
find public/archive/2024/ -name \*.html -print0 | xargs -0 sed -i "s/www.gravatar.com.avatar/www.gravatar.com\/2024/"

git add public

echo "git commit public -m 'Archival of 2024 tournament'"
