#!/bin/sh
#scp -C -r build/* root@jojolepro.com:/var/www/jojolepro.com/
rsync -avp --delete target/html/* root@jojolepro.com:/var/www/jojolepro.com/
rsync -avp --delete target/gemini/* root@jojolepro.com:/var/gemini/

