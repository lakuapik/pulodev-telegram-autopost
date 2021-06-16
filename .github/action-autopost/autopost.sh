#!/bin/bash

rm -rf /tmp/response
touch /tmp/response

curl -s https://api.pulo.dev/v1/contents?page=1 > /tmp/response

if [ ! -s /tmp/response ]; then
    echo -e "\n\n >> Galat, tidak bisa mendapatkan data, coba lagi nanti."
    exit;
fi

cp /tmp/response content

ready_content_ids=()

for row in $(cat content | jq -r '.data[] | @base64' ); do

    content_id=$(echo $row | base64 -d | jq -r '.id')
    last_posted_id=$(cat last_posted_id)

    if [ $last_posted_id -eq $content_id ] ; then
        break
    fi

    ready_content_ids+="$content_id "

done

reversed_ready_content_ids=$(echo "${ready_content_ids[@]}" | tac -s ' ')

for id in $reversed_ready_content_ids; do

    content=$(cat content | jq -r ".data[] | select(.id == $id) | @base64")

    _content() {
        echo $content | base64 -d
    }

    title=$(_content | jq -r '.title | values')
    url=$(_content | jq -r '.url | values')
    owner=$(_content | jq -r '.owner | values')
    body=$(_content | jq -r '.body | values')
    media=$(_content | jq -r '.media | values')
    contributor=$(_content | jq -r '.contributor | values')

    text="
[${title}](${url})* - ${owner} *

${body}

\[${media}]: ${url}

_dimasukan oleh ${contributor}._
"

    curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
        -d "chat_id=@pulodev" \
        -d "parse_mode=markdown" \
        -d "text=$text" \
    > /dev/null

    echo $id > last_posted_id
    echo -e "Sukses posting id: ${id} judul: ${title}"

    exit;

done

echo -e "\n\n >> Mantab, semua kelar."