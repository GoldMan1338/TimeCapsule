#!/bin/bash

if  [ `whoami`  != 'root' ]
	then
		echo "MUST RUN AS ROOT"
		exit
fi


CD=`pwd`
apt-get install -yqq curl cpanminus make --force-yes
cpanm Set::Crontab
chdir ~/Documents/
curl -O  https://cpan.metacpan.org/authors/id/K/KO/KOHTS/Schedule-Cron-Events-1.95.tar.gz
tar -xvf Schedule-Cron-Events-1.95.tar.gz
cd Schedule-Cron-Events-1.95/
perl Makefile.PL
make Makefile
make install
chdir $CD
perl FINAL.pl
