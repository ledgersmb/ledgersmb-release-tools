#!/bin/sh

set -x
set -e

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

echo "deb https://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
apt-get -y update
apt-get -y install nodejs
npm install npm --global
npm install -g uglify-js@">=2.0 <3.0"

pip install transifex-client

echo "StreamLocalBindUnlink yes" >> /etc/ssh/sshd_config
echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config
cat >/tmp/configure-user  <<EOF
  set -x
  set -e

  (umask 077 ; mkdir ~/.ssh ; wget -O ~/.ssh/authorized_keys https://efficito.com/preseed/authorized_keys )
  echo "gpgconf --create-socketdir" >> ~/.bashrc
  gpg --keyserver pgp.mit.edu --recv 8DA0AF10

  cat >>~/.profile <<EOT
if ! [[ -f ~/.logged-in-once ]] ; then
   touch ~/.logged-in-once
   clear
   echo "Welcome to the LedgerSMB Release Manager's VM.

We're executing some post-installation configuration steps. Please answer
the questions posed during this process so we may store the responses in
the VM's configuration for use during the release process.

[Enter]
"
   read -r
   git clone https://github.com/ledgersmb/LedgerSMB.git LedgerSMB
   ( cd LedgerSMB ; git remote set-url origin git@github.com:ledgersmb/LedgerSMB.git )
   ln -s LedgerSMB/utils/release/release-ledgersmb ./
   ln -s LedgerSMB/utils/release/release-notifications.sh
   cp LedgerSMB/utils/release/.lsmb-release.sample ~/.lsmb-release

   read -p "Please provide your GitHub user name:" -r
   echo "$REPLY" > ~/.lsmb-github-releases
   read -p "Please provide your GitHub API key:" -r
   echo "$REPLY" >> ~/.lsmb-github-releases

   echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > ~/.ssh/known_hosts
   ssh-keygen -H 2>&1 >/dev/null
   rm -f ~/.ssh/known_hosts.old

cat >~/INSTRUCTIONS-FOR-USE <<INSTRUCTIONS

GPG configuration
=================

This VM has been configured to use GPG Agent forwarding,
allowing it to use the private key part to remain on your
local workstation instead of on the VM. (The public part
has already been imported into the key store.)

To make this work, you need to set up an extra gpg agent
socket in your gpg-agent.conf file by adding:

  extra-socket ~/.gnupg/S.gpg-agent.extra


Additionally, you need to add:

  Host release-vm
    HostName <your-vm-name's dns-or-ip>
    RemoteForward ~/.gnupg/S.gpg-agent ~/.gnupg/S.gpg-agent.extra

to your local ~/.ssh/config file.



SSH configuration
=================

In order to be able to commit to GitHub and publish the artifacts
on download.ledgersmb.org (and in the future on docs.ledgersmb.org),
the vm has agent forwarding enabled, allowing you to use your local
SSH key for connections made from the VM without the need to hold
your keys on the VM. Your local machine needs to be set up for this
too; add this to your local ~/.ssh/config file to do so:

  Host release-vm
    ForwardAgent yes


Note that together with the GPG agent forwarding configuration, your
local ~/.ssh/config file should have a single 'Host release-vm' entry
which looks like this:

  Host release-vm
    HostName <your-vm-name's dns-or-ip>
    ForwardAgent yes
    RemoteForward ~/.gnupg/S.gpg-agent ~/.gnupg/S.gpg-agent.extra

INSTRUCTIONS

echo "

Done.

Please read the instructions below. You can re-read these instructions
from the file INSTRUCTIONS-FOR-USE stored in your home directory.

$(cat ~/INSTRUCTIONS-FOR-USE)

" | less

else
   if [[ -z "$SSH_AUTH_SOCK" ]]; then
     echo "


Skipping automatic repository update;
you don't seem to have SSH Agent forwarding enabled.
"
   else
      echo "Automatic repository update in progress"
      (cd LedgerSMB ; git pull )
   fi
fi
EOT


EOF
su - relman -c 'sh /tmp/configure-user'
