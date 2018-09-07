#!/bin/bash -e

CURR_VER="undefined"    # Ansible version you currently have installed
GOOD_VER="2.6.4"    # For XO laptops (pip install) & CentOS (yum install rpm)
# On other OS's we attempt the latest from PPA, which might be more recent
    
export DEBIAN_FRONTEND=noninteractive

echo -e '\n\nSTRONGLY RECOMMENDED PREREQUISITE: (1) remove all prior versions of Ansible using "apt purge ansible" and/or "pip uninstall ansible" and (2) clear out all lines containing ansible from /etc/apt/sources.list and /etc/apt/sources.list.d/*\n'

echo -e 'COMPLETE INSTALL INSTRUCTIONS:\nhttps://github.com/iiab/iiab/wiki/IIAB-Installation#do-everything-from-scratch\n'

echo -e 'VERIFY YOU'"'"'RE ONLINE BEFORE RUNNING THIS: /opt/iiab/iiab/scripts/ansible-2.6.x'
echo -e 'Alternative: Run /opt/iiab/iiab/scripts/ansible for the very latest Ansible\n'

if [ $(command -v ansible-playbook) ]; then   # "command -v" is POSIX compliant; also catches built-in commands like "cd"
    CURR_VER=`ansible --version | head -1 | awk '{print $2}'`    # To match iiab-install.  Was: CURR_VER=`ansible --version | head -n 1 | cut -f 2 -d " "`
    echo "Currently installed Ansible: $CURR_VER"
    echo -e "INTERNET-IN-A-BOX GENERALLY REQUIRES ANSIBLE VERSION: $GOOD_VER or higher"
    if [ -f /etc/centos-release ] || [ -f /etc/fedora-release ]; then
        echo "Please use your system's package manager (or pip if nec) to update Ansible."
        exit 0
    elif [ -f /etc/olpc-release ]; then
        echo 'Please use pip package manager to update Ansible.'
        exit 0
    fi
else
    echo -e 'Ansible NOT found on this computer.'
    echo -e "INTERNET-IN-A-BOX GENERALLY REQUIRES ANSIBLE VERSION: $GOOD_VER or higher"
fi

echo -e 'scripts/ansible will now try to install Ansible 2.6.x...\n'
if [ -f /etc/olpc-release ]; then
    yum -y install ca-certificates nss
    yum -y install git bzip2 file findutils gzip hg svn sudo tar which unzip xz zip libselinux-python
    yum -y install python-pip python-setuptools python-wheel patch
    # Can above 3 lines be merged into 1 line?
    pip install --upgrade pip setuptools wheel #EOL just do it
    pip install ansible==$GOOD_VER --disable-pip-version-check
elif [ -f /etc/centos-release ]; then
    yum -y install ansible
# 2018-09-07: the next 4 lines aren't needed according to https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#latest-release-via-dnf-or-yum
#    yum -y install ca-certificates nss epel-release
#    yum -y install git bzip2 file findutils gzip hg svn sudo tar which unzip xz zip libselinux-python
#    yum -y install python-pip python-setuptools python-wheel patch
#    yum -y install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-$GOOD_VER-1.el7.ans.noarch.rpm
#elif [ -f /etc/fedora-release ]; then
#    CURR_VER=`grep VERSION_ID /etc/*elease | cut -d= -f2`
#    URL=https://github.com/jvonau/iiab/blob/ansible/vars/fedora-$CURR_VER.yml
#    dnf -y install ansible git bzip2 file findutils gzip hg svn sudo tar which unzip xz zip libselinux-python
#    dnf -y install python-pip python-setuptools python-wheel patch
## Parens are optional, but greatly clarify :)
#elif (grep -qi ubuntu /etc/lsb-release 2> /dev/null) || (grep -qi ubuntu /etc/os-release); then
#    apt update
#    #apt -y install python-pip python-setuptools python-wheel patch    # 2018-09-05: fails on @kananigit's Ubuntu 18.04/Server.  Fix @ https://github.com/iiab/iiab/pull/1091
#    apt -y install software-properties-common    # adds command "apt-add-repository"
#    apt-add-repository -y ppa:ansible/ansible    # adds correct line to correct file e.g. adds line "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" to /etc/apt/sources.list.d/ansible-ubuntu-ansible-bionic.list
## elif UBUNTU MUST REMAIN ABOVE (as Ubuntu ALSO contains /etc/debian_version, which would trigger the line just below)
#elif [ -f /etc/debian_version ] || (grep -qi raspbian /etc/*elease) ; then
#elif [ ! -f /etc/centos-release ] && [ ! -f /etc/fedora-release ] && [ ! -f /etc/olpc-release ]; then
elif [ -f /etc/debian_version ]; then    # Includes Debian, Ubuntu & Raspbian

    echo -e '\napt update; install dirmngr; PPA to /etc/apt/sources.list.d/iiab-ansible.list\n'
    apt update
    apt -y install dirmngr    # Raspbian needs.  Formerly: python-pip python-setuptools python-wheel patch
    echo "deb http://ppa.launchpad.net/ansible/ansible-2.6/ubuntu xenial main" \
         > /etc/apt/sources.list.d/iiab-ansible.list

    echo -e '\nIF YOU FACE ERROR "signatures couldn'"'"'t be verified because the public key is not available" THEN REPEATEDLY RE-RUN "apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367"\n'
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

    echo -e '\napt update; apt install ansible\n'
    apt update
    apt -y --allow-downgrades install ansible
    echo -e '\nPlease verify Ansible using "ansible --version" and/or "apt -a list ansible"'

    # TEMPORARILY USE ANSIBLE 2.4.4 (REMOVE IT WITH "pip uninstall ansible")
    #pip install ansible==2.4.4

    # TEMPORARILY USE ANSIBLE 2.4.2 DUE TO 2.4.3 MEMORY BUG. DETAILS @ https://github.com/iiab/iiab/issues/669
    #echo "Install http://download.iiab.io/packages/ansible_2.4.2.0-1ppa~xenial_all.deb"
    #cd /tmp
    #wget http://download.iiab.io/packages/ansible_2.4.2.0-1ppa~xenial_all.deb
    #apt -y --allow-downgrades install ./ansible_2.4.2.0-1ppa~xenial_all.deb

    echo -e '\n\nPPA source "deb http://ppa.launchpad.net/ansible/ansible-2.6/ubuntu xenial main" successfully saved to /etc/apt/sources.list.d/iiab-ansible.list'
    echo -e '\nIF *OTHER* ANSIBLE SOURCES ARE ALSO IN THE LIST BELOW, PLEASE MANUALLY REMOVE THEM TO ENSURE ANSIBLE UPDATES CLEANLY: (then re-run this script to be sure!)\n'
    grep '^deb .*ansible' /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep -v '^/etc/apt/sources.list.d/iiab-ansible.list:'
    echo
else
    echo -e "\nEXITING: Could not detect your OS (unsupported?)\n"
    exit 1
fi

# Needed?
mkdir -p /etc/ansible
echo -e '[local]\nlocalhost\n' > /etc/ansible/hosts
