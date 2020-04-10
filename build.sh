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

            sed -E "s|^(https[:]//[^ )]{50})([^ )]*)|<a href='\0'>\1</a>|g" |

            sed -E "s/^\.\/.*\.(png|jpg|svg)/<img src='\0'\/>/g" |

            sed '/%%CONTENT%%/r /dev/stdin' /tmp/template.html |
            sed '/%%CONTENT%%/d' |

            sed "s|%%SOURCE%%|/${page##./}|" \
                > "${page%%.txt}.html"

            ln -f "../src/$page" "$page"

            printf '%s\n' "CC $page"
        ;;

        # Copy over any images or non-txt files.
        *)
            cp "../src/$page" "$page"

            printf '%s\n' "CP $page"
        ;;
    esac
done
