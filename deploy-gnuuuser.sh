#!/bin/sh


zypper --no-gpg-checks -n install git puppet

if [ ! -d /etc/puppet/modules ]; then
  mkdir -p /etc/puppet/modules
fi 

if [ ! -d /etc/puppet/manifests ]; then
  mkdir -p /etc/puppet/manifests
fi

git config --global http.sslVerify false
git clone https://github.com/eumel8/puppet-gnuuuser.git /etc/puppet/modules/gnuuuser

cat > ../manifests/gnuuuser.pp <<EOF

    class {'gnuuuser':
      site     => '6913306960778',
      password => '2RlLJyMV',
    }

EOF

puppet apply /etc/puppet/manifests/gnuuuser.pp

