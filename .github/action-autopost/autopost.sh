#!/bin/sh

rm -rf /tmp/response
touch /tmp/response

curl -s https://api.pulo.dev/v1/contents?page=1 > /tmp/response

if [ ! -s /tmp/response ]; then
    echo -e "\n\n >> Galat, tidak bisa mendapatkan data, coba lagi nanti."
    exit;
fi

cp /tmp/response content

for row in $(cat content | jq -r '.data | reverse | .[] | @base64' ); do

    _content() {
        echo $row | base64 -d
    }

    content_id=$(_content | jq -r '.id')

    if [ $(cat last_posted_id) -eq $content_id ] ; then
        echo -e "\n\n >> Aman, tidak ada yang perlu di posting lagi."
        exit
    fi

    title=$(_content | jq -r '.title | values')
    url=$(_content | jq -r '.url | values')
    owner=$(_content | jq -r '.owner | values')
    body=$(_content | jq -r '.body | values')
    media=$(_content | jq -r '.media | values')
    contributor=$(_content | jq -r '.contributor | values')


    text="[$title]($url)\* - $owner \* \n\n $body \n\n \[$media]: $url \n\n _dimasukan oleh ${contributor}_ \n\n"

    curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage \
    -d "chat_id=@pulodev" \
    -d "parse_mode=markdown" \
    -d "text=$text"

    echo $content_id > last_posted_id
    echo -e "Sukses posting id: ${content_id} judul: ${title}"

done

echo -e "\n\n >> Mantab, semua kelar."