#!/bin/sh

curl -s https://api.pulo.dev/v1/contents?page=1 | jq -c .data[0] > last_content

last_content_id=$(cat last_content | jq -r .id)

if [ $(cat last_posted_id) -eq $last_content_id ] ; then
    echo -e "Aman, tidak ada yang perlu di posting."
    exit
fi

title=$(cat last_content | jq -r .title)
url=$(cat last_content | jq -r .url)
owner=$(cat last_content | jq -r .owner)
body=$(cat last_content | jq -r .body)
media=$(cat last_content | jq -r .media)
contributor=$(cat last_content | jq -r .contributor)

text="
[$title]($url)* - $owner *

$body

\[$media]: $url

_dimasukan oleh ${contributor}_
"

curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d "chat_id=@pulodev" \
    -d "parse_mode=markdown" \
    -d "text=$text"

echo $last_content_id > last_posted_id