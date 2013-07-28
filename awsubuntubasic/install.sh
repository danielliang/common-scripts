#!/bin/sh -e

# Update: 20130728

if [ "`id -u`" != "0" ]; then
  echo "Please execute with a superuser..." 1>&2
  exit 1
fi

# Timezone
TIMEZONE="Asia/Taipei"
echo "Set the time zone as ${TIMEZONE}... "
echo ${TIMEZONE} > /etc/timezone &&
	dpkg-reconfigure --frontend noninteractive tzdata ||
	echo "time zone fail!" 1>&2

echo

# change default editor
echo 'Use vim.basic as default editor...'
update-alternatives --set editor /usr/bin/vim.basic ||
	echo "default editor fail!" 1>&2

echo

# set bash PS1 for screen
echo ".bash_aliase for screen of PS1..."
cp -v .bash_aliases /etc/skel/

# set bash history time format
echo "bash history time format..."
cp -v profile.d_local-bash-history-time.sh /etc/profile.d/local-bash-history-time.sh

# vimrc
echo 'set bg=dark' > /etc/vim/vimrc.local
echo 'set hlsearch' >> /etc/vim/vimrc.local

#
#cp /etc/skel/.* $HOME

# disable IPv6
echo 'Disable eth0 ipv6...'
SYSCTLCONF_IPV6=/etc/sysctl.d/60-ipv6.conf
echo 'net.ipv6.conf.eth0.disable_ipv6 = 1' > $SYSCTLCONF_IPV6 &&
	sysctl -p $SYSCTLCONF_IPV6 && echo 'done.'

# increase connections limits
cp -v 60-connection-limits.conf /etc/sysctl.d/ && \
	sysctl -p /etc/sysctl.d/60-connection-limits.conf && echo 'done.'
cp -v nofile.conf /etc/security/limits.d/ && echo 'done.'


# NTP
echo "install ntpd && diable ntpdate when ifup..."
apt-get install -y ntp || echo "apt-get install ntp failed!"
mv -v /etc/network/if-up.d/ntpdate /etc/network/if-up.d/ntpdate.disabled ||
	echo "disable ntpdate failed!" 1>&2
mv -v /etc/cron.daily/popularity-contest /etc/cron.daily/popularity-contest.disabled ||
	echo "disable daily popularity-contest failed!" 1>&2
apt-get -y purge whoopsie || echo "remove whoopsie failed!"
