#!/bin/sh
#scp -C -r build/* root@jojolepro.com:/var/www/jojolepro.com/
rsync -avp --delete build/* root@jojolepro.com:/var/www/jojolepro.com/

