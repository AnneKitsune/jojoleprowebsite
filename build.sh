#!/bin/sh

rm -r ./build
mkdir -p ./build
cp ./template.html /tmp/template.html
cd ./build

(cd ../src; find . -type f -a -not -path \*/\.\* -a -not -path ./templates/\*) |

while read -r page; do
    mkdir -p "${page%/*}"

    case $page in
        *.txt)
            sed "s/&/\&amp;/g" "../src/$page" |
            sed "s/</\&lt;/g" |
            sed "s/>/\&gt;/g" |

            sed -E "s|([^=][^\'\"])(https[:]//[^ )]*)|\1<a href='\2'>\2</a>|g" |

            sed -E "s|^(https[:]//[^ )]{2,71})([^ )]*)|<a href='\0'>\1</a>|g" |

            sed -E "s/^\.\/.*\.(png|jpg|svg)/<img src='\0'\/>/g" |

            sed '/%%CONTENT%%/r /dev/stdin' /tmp/template.html |
            sed '/%%CONTENT%%/d' |

            sed "s|%%SOURCE%%|/${page##./}|" \
                > "${page%%.txt}.html"

            ln -f "../src/$page" "$page"

            printf '%s\n' "CC $page"
        ;;

        *.html)
            cat "../src/$page" |
            sed '/%%CONTENT%%/r /dev/stdin' /tmp/template.html |
            sed '/%%CONTENT%%/d' > "${page%%.html}.html"

            printf '%s\n' "CC $page"
        ;;

        # Copy over any images or non-txt files.
        *)
            cp "../src/$page" "$page"

            printf '%s\n' "CP $page"
        ;;
    esac
done

echo Building RSS

rss='<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<title>Jojolepro Blog</title>
<description>The Blog of the Fockses!</description>
<link>https://www.jojolepro.com</link>
<atom:link href="https://www.jojolepro.com/blog/blog.xml" rel="self" type="application/rss+xml"/>'

rss_end="</channel>
</rss>"

item="<item>
<title>{{title}}</title>
<link>https://www.jojolepro.com/blog/{{link}}</link>
</item>"

echo "$rss" > blog/blog.xml

cat ../src/blog/index.html | grep -v blog.xml | grep -vE "^$" |
while read -r entry; do
# <a href="2020-08-20_event_chaining">Event Chaining as a Decoupling Method in ECS Game Engines</a>
    title1="${entry##*\">}"
    title="${title1%%<*}"
    link1="${entry##*=\"}"
    link="${link1%%\"*}"
    echo "$item" | sed "s/{{title}}/$title/" | sed "s/{{link}}/$link/" >> blog/blog.xml
done

echo "$rss_end" >> blog/blog.xml

