#!/bin/sh

# cd; wget -N https://raw.githubusercontent.com/ryanpcmcquen/config-o-matic/master/slackConfigROOT.sh; sh slackConfigROOT.sh; rm slackConfigROOT.sh

## BASHGITVIM="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/bashGitVimROOT.sh"

## added in 4.2.0
## note that some configuration options may not match
## depending on the system, as config-o-matic tries
## to avoid overwriting most files
CONFIGOMATICVERSION=6.9.15


if [ ! $UID = 0 ]; then
  cat << EOF
This script must be run as root.
EOF
  exit 1
fi


## versions!
cd
## get stable slackware version
wget www.slackware.com -O ~/slackware-home-page.html
cat ~/slackware-home-page.html | grep "is released!" | head -1 | sed 's/Slackware//g' | \
  sed 's/is released!//g' | sed 's/ //g' > ~/slackwareStableVersion
rm -v ~/slackware-home-page.html

export SLACKSTAVER=${SLACKSTAVER="$(tr -d '\n\r' < ~/slackwareStableVersion)"}
export DASHSLACKSTAVER=${DASHSLACKSTAVER=-"$(tr -d '\n\r' < ~/slackwareStableVersion)"}

## sbopkg
wget www.sbopkg.org -O ~/sbopkg-home-page.html
cat ~/sbopkg-home-page.html | grep sbopkg | grep -G tgz | cut -d= -f2 | \
  tr -d '"' > ~/sbopkgVersion
rm -v ~/sbopkg-home-page.html

export SBOPKGDL=${SBOPKGDL="$(tr -d '\n\r' < ~/sbopkgVersion)"}

## slackpkg+
wget sourceforge.net/projects/slackpkgplus/files/ -O ~/slackpkgplus-download-page.html
cat ~/slackpkgplus-download-page.html | grep slackpkg%2B | head -1 | cut -d= -f2 | sed 's/\/download//' | \
  tr -d '"' > ~/slackpkgPlusVersion
rm -v ~/slackpkgplus-download-page.html

export SPPLUSDL=${SPPLUSDL="$(tr -d '\n\r' < ~/slackpkgPlusVersion)"}

## caledonia
wget caledonia.sourceforge.net -O ~/caledonia-home-page.html
cat ~/caledonia-home-page.html | grep Plasma-KDE%20Theme | cut -d= -f5 | tr -d '"' | tr -d "'" | sed 's@/download>Download <i class@@g' | \
  sed 's@http://sourceforge.net/projects/caledonia/files/Caledonia%20%28Plasma-KDE%20Theme%29/@@g' > ~/caledoniaPlasmaVersion
cat ~/caledonia-home-page.html | grep Official%20Wallpapers | cut -d= -f5 | tr -d '"' | tr -d "'" | sed 's@/download>Download <i class@@g' | \
  sed 's@http://sourceforge.net/projects/caledonia/files/Caledonia%20Official%20Wallpapers/@@g' > ~/caledoniaWallpaperVersion
rm -v ~/caledonia-home-page.html

export CALPLAS=${CALPLAS="$(tr -d '\n\r' < ~/caledoniaPlasmaVersion)"}
export CALWALL=${CALWALL="$(tr -d '\n\r' < ~/caledoniaWallpaperVersion)"}


## set config files:

## sets ulimit, umask and whatnot
INSCRPT="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/initscript"

BASHRC="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bashrc"
BASHPR="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/root/.bash_profile"

VIMRC="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/.vimrc"
VIMCOLOR="https://raw.githubusercontent.com/ryanpcmcquen/vim-plain/master/colors/vi-clone.vim"

TMUXCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/tmux.conf"

GITNAME="Ryan P.C. McQuen"
GITEMAIL="ryan.q@linux.com"

TOUCHPCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/51-synaptics.conf"

ASOUNDCONF="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/asound.conf"

GETEXTRASLACK="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getExtraSlackBuilds.sh"

GETSOURCESTA="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getSystemSlackBuildsSTABLE.sh"
GETSOURCECUR="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getSystemSlackBuildsCURRENT.sh"

GETJAVA="https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/getJavaSlackBuild.sh"

MINECRAFTDL="https://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar"

## eric hameleers has updated multilib to include this package
#LIBXSHM="libxshmfence-1.1-i486-1.txz"

### my shell functions  ;^)
make_sbo_pkg_upgrade_list() {
  sbopkg -c > ~/sbopkg-upgrade-list.txt
}

## the echo p keeps sbopkg from prompting you if something goes wrong
no_prompt_sbo_pkg_install_or_upgrade() {
  for ITEM in "$@"; do
    SBO_PACKAGE=$ITEM
    if [ -z "`find /var/log/packages/ -name $SBO_PACKAGE-*`" ] || [ "$(cat ~/sbopkg-upgrade-list.txt | grep $SBO_PACKAGE)" ]; then
      echo p | sbopkg -B -e continue -i $SBO_PACKAGE
    fi
  done
}

slackpkg_update_only() {
  slackpkg update gpg
  slackpkg update
}

## a function in a function!
slackpkg_full_upgrade() {
  slackpkg_update_only
  if [ "$HEADLESS" = "no" ]; then
    slackpkg install-new
  fi
  slackpkg upgrade-all
}

## actually pretty simple
set_slackpkg_to_auto() {
  sed -i 's/^BATCH=off/BATCH=on/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/g' /etc/slackpkg/slackpkg.conf
}

set_slackpkg_to_manual() {
  sed -i 's/^BATCH=on/BATCH=off/g' /etc/slackpkg/slackpkg.conf
  sed -i 's/^DEFAULT_ANSWER=y/DEFAULT_ANSWER=n/g' /etc/slackpkg/slackpkg.conf
}

## install packages from my unofficial github repo
my_repo_install() {
  ## set to wherever yours is
  MY_REPO=~/ryanpc-slackbuilds/unofficial
  ## just do one initial pull 
  cd ${MY_REPO}/
  git pull
  ## begin the beguine
  for ITEM in "$@"; do
    MY_REPO_PKG=$ITEM
    ## check if it is already installed
    if [ -z "`find /var/log/packages/ -name ${MY_REPO_PKG}-*`" ]; then
      cd ${MY_REPO}/${MY_REPO_PKG}/
      . ${MY_REPO}/${MY_REPO_PKG}/${MY_REPO_PKG}.info
      ## no use trying to download if these vars are empty
      if [ "$DOWNLOAD" ] || [ "$DOWNLOAD_x86_64" ]; then
        if [ "$(uname -m)" = "x86_64" ] && [ "$DOWNLOAD_x86_64" ] && [ "$DOWNLOAD_x86_64" != "UNSUPPORTED" ] && [ "$DOWNLOAD_x86_64" != "UNTESTED" ]; then
          wget -N $DOWNLOAD_x86_64 -P ${MY_REPO}/${MY_REPO_PKG}/
        else
          wget -N $DOWNLOAD -P ${MY_REPO}/${MY_REPO_PKG}/
        fi
      fi
      ## finally run the build
      sh ${MY_REPO}/${MY_REPO_PKG}/${MY_REPO_PKG}.SlackBuild
      ls -t --color=never /tmp/${MY_REPO_PKG}-*_SBo.tgz | head -1 | xargs -i upgradepkg --install-new {}
      cd
    fi
  done
}

### end of shell functions

## we need this to determine if the system can install wine
if [ -z "$COMARCH" ]; then
  case "$(uname -m)" in
    arm*) COMARCH=arm ;;
    *) COMARCH=$(uname -m) ;;
  esac
fi

## make sure we are home  ;^)
cd


echo
echo
echo "*************************************************************"
echo "*************************************************************"
echo "********          WELCOME TO                         ********"
echo "********              CONFIG-O-MATIC                 ********"
echo "*************************************************************"
echo "*************************************************************"
echo
echo

## go!

## OGCONFIG introduced in 6.6.0
if [ `find -name ".config-o-matic*" | tail -1` ] && [ -z `. $(find -name ".config-o-matic*" | tail -1)` ]; then
  read -p "Would you like to use your last CONFIGURATION?  [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      . "$(find -name '.config-o-matic*' | tail -1)";
      export OGCONFIG=true;
      echo You respect your original choices.;
      ;;
    *)
      echo You want to try something new.;
      ;;
  esac
fi
if [ ! "$OGCONFIG" = true ]; then
  read -p "Would you like to switch to -CURRENT? \
   (NO = STABLE) \
   [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      export CURRENT=true;
      echo You are switching to -CURRENT.;
      ;;
    *)
      echo You are going STABLE.;
      ;;
  esac
  
  read -p "Would you like to install WICD? \
   (NetworkManager will be disabled) \
   [y/N]: " response
  case $response in
    [yY][eE][sS]|[yY])
      export WICD=true;
      echo You are installing WICD.;
      ;;
    *)
      echo You are not installing WICD.;
      ;;
  esac
  if [ "$COMARCH" != "arm" ]; then
    read -p "Would you like to install a bunch of MISCELLANY?  [y/N]: " response
    case $response in
      [yY][eE][sS]|[yY])
        export MISCELLANY=true;
        echo You are installing MISCELLANY.;
        ;;
      *)
        echo "You're pretty VANILLA, read the source for more.";
        ;;
    esac
  fi
  if [ "$(uname -m)" = "x86_64" ]; then
    read -p "Would you like to go MULTILIB?  [y/N]: " response
    case $response in
      [yY][eE][sS]|[yY])
        export MULTILIB=true;
        echo You have chosen to go MULTILIB.;
        ;;
      *)
        echo You are not going MULTILIB.;
        ;;
    esac
  fi
fi


if [ "$(aplay -l | grep Analog | grep 'card 1')" ]; then
  wget -N $ASOUNDCONF -P /etc/
fi

## fix for steam & lutris
dbus-uuidgen --ensure

## detect efi and replace lilo with a script that works
if [ -d /boot/efi/EFI/boot/ ]; then
  cp -v /sbin/lilo /sbin/lilo.orig
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/EFI/lilo -P /sbin/
fi

## no need to run this on efi
if [ -e /etc/lilo.conf ]; then
  ## configure lilo
  sed -i 's/^#compact/lba32\
  compact/g' /etc/lilo.conf

  ## set to utf8 and pass acpi kernel params
  ## these fix brightness key issues on some comps
  ## and have no negative effects on others (in my testing at least)
  sed -i 's/^append=" vt.default_utf8=[0-9]"/append=" vt.default_utf8=1 acpi_osi=linux acpi_backlight=vendor"/g' /etc/lilo.conf
  sed -i 's/^timeout =.*/timeout = 5/g' /etc/lilo.conf
  if [ "$(cat /etc/lilo.conf | grep 'vga=771')" ]; then
    ## uncomment all vga settings so
    ## we don't end up with conflicts
    sed -i "s_^vga_#vga_g" /etc/lilo.conf
    ## 800x600x256 (so we can see the penguins!)
    sed -i "s_^#vga=771_vga=771_g" /etc/lilo.conf
  fi
fi

## only run lilo if it exists (arm doesn't have it)
if [ "$(which lilo)" ]; then
  lilo -v
fi

## change to utf-8 encoding
sed -i 's/^export LANG=en_US/#export LANG=en_US/g' /etc/profile.d/lang.sh
sed -i 's/^#export LANG=en_US.UTF-8/export LANG=en_US.UTF-8/g' /etc/profile.d/lang.sh
## set a utf8 font and other unicode-y stuff
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/rc.unicodeMagic -P /etc/rc.d/
chmod 755 /etc/rc.d/rc.unicodeMagic
## start it!
/etc/rc.d/rc.unicodeMagic
## make it start on boot
if [ -z "$(cat /etc/rc.d/rc.local | grep unicodeMagic)" ]; then
echo "if [ -x /etc/rc.d/rc.unicodeMagic ]; then
  /etc/rc.d/rc.unicodeMagic
fi" >> /etc/rc.d/rc.local
fi

if [ "$CURRENT" = true ]; then
  ## adjust slackpkg blacklist
  sed -i 's/^aaa_elflibs/#aaa_elflibs/g' /etc/slackpkg/blacklist
fi

## blacklist sbo stuff
sed -i 's/#\[0-9]+_SBo/\
\[0-9]+_SBo\
sbopkg/g' /etc/slackpkg/blacklist

## i always install jdk with pat's script
if [ -z "$(cat /etc/slackpkg/blacklist | grep jdk)" ]; then
  echo jdk >> /etc/slackpkg/blacklist
  echo >> /etc/slackpkg/blacklist
fi

## now with arm support! (since 6.7.0)
if [ "$COMARCH" != "arm" ]; then
  if [ "$CURRENT" = true ]; then
    ### undo stable mirrors, do current
    if [ "$(uname -m)" = "x86_64" ]; then
      sed -i \
        "s_^http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_# http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
      sed -i \
        "s_^# http://ftp.osuosl.org/.2/slackware/slackware64-current/_http://ftp.osuosl.org/.2/slackware/slackware64-current/_g" /etc/slackpkg/mirrors
    else
      sed -i \
        "s_^http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_# http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
      sed -i \
        "s_^# http://ftp.osuosl.org/.2/slackware/slackware-current/_http://ftp.osuosl.org/.2/slackware/slackware-current/_g" /etc/slackpkg/mirrors
    fi
  else
    ### undo current, go stable
    if [ "$(uname -m)" = "x86_64" ]; then
      sed -i \
        "s_^http://ftp.osuosl.org/.2/slackware/slackware64-current/_# http://ftp.osuosl.org/.2/slackware/slackware64-current/_g" /etc/slackpkg/mirrors
      sed -i \
        "s_^# http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_http://ftp.osuosl.org/.2/slackware/slackware64${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
    else
      sed -i \
        "s_^http://ftp.osuosl.org/.2/slackware/slackware-current/_# http://ftp.osuosl.org/.2/slackware/slackware-current/_g" /etc/slackpkg/mirrors
      sed -i \
        "s_^# http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_http://ftp.osuosl.org/.2/slackware/slackware${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
    fi
  fi
else
  if [ "$CURRENT" = true ]; then
    ### undo stable mirrors
    sed -i \
      "s_^http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm${DASHSLACKSTAVER}/_# http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
    ### do the current
    sed -i \
      "s_^# http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm-current/_http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm-current/_g" /etc/slackpkg/mirrors
  else
    ### undo current
    sed -i \
      "s_^http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm-current/_# http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm-current/_g" /etc/slackpkg/mirrors
    sed -i \
      "s_^# http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm${DASHSLACKSTAVER}/_http://mirrors.vbi.vt.edu/mirrors/linux/slackwarearm/slackwarearm${DASHSLACKSTAVER}/_g" /etc/slackpkg/mirrors
  fi
fi


## set vim as the default editor
if [ -z "$(cat /etc/profile | grep 'export EDITOR' && cat /etc/profile | grep 'export VISUAL')" ]; then
  echo >> /etc/profile
  echo "export EDITOR=vim" >> /etc/profile
  echo "export VISUAL=vim" >> /etc/profile
  echo >> /etc/profile
fi

## make ls colorful by default,
## when parsing ls output, always use:
## ls --color=never
if [ -z "$(cat /etc/profile | grep 'alias ls=')" ]; then
  echo >> /etc/profile
  echo "alias ls='ls --color=auto'" >> /etc/profile
  echo >> /etc/profile
fi

## make alsamixer go to the card you actually want to edit  ;-)
if [ "$(aplay -l | grep Analog | grep 'card 1')" ] \
  && [ -z "$(cat /etc/profile | grep 'alias alsamixer=')" ]; then
    echo >> /etc/profile
    echo "alias alsamixer='alsamixer -c 1'" >> /etc/profile
    echo >> /etc/profile
fi

## make compiling faster  ;-)
if [ -z "$(cat /etc/profile | grep 'MAKEFLAGS')" ]; then
  echo >> /etc/profile
  echo 'if [ "$(nproc)" -gt 2 ]; then' >> /etc/profile
  ## cores--
  echo '  export MAKEFLAGS=" -j$(expr $(nproc) - 1) "' >> /etc/profile
  ## half the cores
  #echo '  export MAKEFLAGS=" -j$(expr $(nproc) / 2) "' >> /etc/profile
  echo 'else' >> /etc/profile
  echo '  export MAKEFLAGS=" -j1 "' >> /etc/profile
  echo 'fi' >> /etc/profile
  echo >> /etc/profile
fi

## otherwise all our new stuff won't load until we log in again  ;^)
. /etc/profile


wget -N $BASHRC -P ~/
wget -N $BASHPR -P ~/
wget -N $VIMRC -P ~/
mkdir -p ~/.vim/colors/
wget -N $VIMCOLOR -P ~/.vim/colors/

## touchpad configuration
wget -N $TOUCHPCONF -P /etc/X11/xorg.conf.d/
wget -N $INSCRPT -P /etc/

wget -N $TMUXCONF -P /etc/


## git config
git config --global user.name "$GITNAME"
git config --global user.email "$GITEMAIL"
git config --global credential.helper 'cache --timeout=3600'
git config --global push.default simple
git config --global core.pager "less -r"

## give config-o-matic a directory
## to store all the crazy stuff we download
mkdir -pv /var/cache/config-o-matic/{images,pkgs,themes}/

## install sbopkg & slackpkg+
wget -N $SBOPKGDL -P /var/cache/config-o-matic/pkgs/
if [ "$COMARCH" != "arm" ]; then
  wget -N $SPPLUSDL -P /var/cache/config-o-matic/pkgs/
fi
upgradepkg --install-new /var/cache/config-o-matic/pkgs/*.t?z

## a few more vars
if [ "`find /var/log/packages/ -name xorg-*`" ]; then
  export HEADLESS=no;
fi

if [ `find /var/log/packages/ -name slackpkg+*` ]; then
  export SPPLUSISINSTALLED=true;
fi

## use SBo master git branch instead of a specific version
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sbo/90-SBo-master.repo \
  -P /etc/sbopkg/repos.d/

## use SBo-master as default ...
## but only comment out the old lines for an easy swap
if [ -z "$(cat /etc/sbopkg/sbopkg.conf | grep SBo-master)" ]; then
  sed -i "s@REPO_BRANCH=@#REPO_BRANCH=@g" /etc/sbopkg/sbopkg.conf
  sed -i "s@REPO_NAME=@#REPO_NAME=@g" /etc/sbopkg/sbopkg.conf
  echo >> /etc/sbopkg/sbopkg.conf
  echo "REPO_BRANCH=\${REPO_BRANCH:-master}" >> /etc/sbopkg/sbopkg.conf
  echo "REPO_NAME=\${REPO_NAME:-SBo-master}" >> /etc/sbopkg/sbopkg.conf
  echo >> /etc/sbopkg/sbopkg.conf
fi

## applies to qemu
if [ -z "$(cat /etc/sbopkg/sbopkg.conf | grep TARGETS)" ]; then
  echo "export TARGETS=\${TARGETS:-all}" >> /etc/sbopkg/sbopkg.conf
  echo >> /etc/sbopkg/sbopkg.conf
fi
## applies to google-go-lang
if [ -z "$(cat /etc/sbopkg/sbopkg.conf | grep RUN_TEST)" ]; then
  echo "export RUN_TEST=\${RUN_TEST:-false}" >> /etc/sbopkg/sbopkg.conf
  echo >> /etc/sbopkg/sbopkg.conf
fi
## applies to a few packages
if [ "$MULTILIB" = true ]; then
  if [ -z "$(cat /etc/sbopkg/sbopkg.conf | grep COMPAT32)" ]; then
    echo "export COMPAT32=\${COMPAT32:-yes}" >> /etc/sbopkg/sbopkg.conf
    echo >> /etc/sbopkg/sbopkg.conf
  fi
fi
## applies to ssr
if [ "$MISCELLANY" = true ]; then
  if [ -z "$(cat /etc/sbopkg/sbopkg.conf | grep JACK)" ]; then
    echo >> /etc/sbopkg/sbopkg.conf
    echo "export JACK=\${JACK:-on}" >> /etc/sbopkg/sbopkg.conf
    echo >> /etc/sbopkg/sbopkg.conf
  fi
fi

## create sbopkg directories
mkdir -pv /var/lib/sbopkg/SBo-master/
mkdir -pv /var/lib/sbopkg/queues/
mkdir -pv /var/log/sbopkg/
mkdir -pv /var/cache/sbopkg/
mkdir -pv /tmp/SBo/
## reverse
#rm -rfv /var/lib/sbopkg/
#rm -rfv /var/log/sbopkg/
#rm -rfv /var/cache/sbopkg/
#rm -rfv /tmp/SBo/


## gkrellm theme
mkdir -pv /usr/share/gkrellm2/themes/
wget -N https://github.com/ryanpcmcquen/themes/raw/master/egan-gkrellm.tar.gz -P /var/cache/config-o-matic/themes/
tar xvf /var/cache/config-o-matic/themes/egan-gkrellm.tar.gz -C /usr/share/gkrellm2/themes/

## amazing stealthy fluxbox
wget -N https://github.com/ryanpcmcquen/themes/raw/master/67966-Stealthy-1.1.tgz -P /var/cache/config-o-matic/themes/
tar xvf /var/cache/config-o-matic/themes/67966-Stealthy-1.1.tgz -C /usr/share/fluxbox/styles/

## set slackpkg to non-interactive mode to run without prompting
set_slackpkg_to_auto

## to reset run with RESETSPPLUSCONF=y prepended,
## adds a bunch of mirrors for slackpkg+, as well as other
## settings, to the existing config, so updates are clean
if [ "$SPPLUSISINSTALLED" = true ]; then
  if [ "$COMARCH" != "arm" ]; then
    if [ ! -e /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP ] || [ "$RESETSPPLUSCONF" = y ]; then
      if [ "$RESETSPPLUSCONF" = y ]; then
        cp -v /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP /etc/slackpkg/BACKUP0-slackpkgplus.conf.old-BACKUP0
        cp -v /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP /etc/slackpkg/slackpkgplus.conf
      fi
      cp -v /etc/slackpkg/slackpkgplus.conf.new /etc/slackpkg/slackpkgplus.conf
      cp -v /etc/slackpkg/slackpkgplus.conf /etc/slackpkg/BACKUP-slackpkgplus.conf.old-BACKUP
      sed -i 's@REPOPLUS=( slackpkgplus restricted alienbob slacky )@#REPOPLUS=( slackpkgplus restricted alienbob slacky )@g' /etc/slackpkg/slackpkgplus.conf
      sed -i "s@MIRRORPLUS\['slacky'\]@#MIRRORPLUS['slacky']@g" /etc/slackpkg/slackpkgplus.conf
    
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( multilib:.* ktown:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( ktown:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( multilib:.* ktown-testing:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( ktown-testing:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      if [ "$MULTILIB" != true ]; then
        if [ "$CURRENT" = true ]; then
          echo >> /etc/slackpkg/slackpkgplus.conf
          echo "PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
        else
          echo "#PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
        fi
        echo "#PKGS_PRIORITY=( multilib:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      fi
    
      if [ "$MULTILIB" = true ] && [ "$(uname -m)" = "x86_64" ]; then
        if [ "$CURRENT" = true ]; then
          sed -i "s@#MIRRORPLUS\['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/current/@MIRRORPLUS['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/current/@g" \
          /etc/slackpkg/slackpkgplus.conf
          echo >> /etc/slackpkg/slackpkgplus.conf
          echo "PKGS_PRIORITY=( multilib:.* restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
        else
          sed -i "s@#MIRRORPLUS\['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/${SLACKSTAVER}/@MIRRORPLUS['multilib']=http://taper.alienbase.nl/mirrors/people/alien/multilib/${SLACKSTAVER}/@g" \
          /etc/slackpkg/slackpkgplus.conf
          echo >> /etc/slackpkg/slackpkgplus.conf
          echo "PKGS_PRIORITY=( multilib:.* )" >> /etc/slackpkg/slackpkgplus.conf
        fi
        echo >> /etc/slackpkg/slackpkgplus.conf
        echo "#PKGS_PRIORITY=( restricted-current:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      fi
    
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( multilib:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( multilib:.* ktown:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( ktown:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( multilib:.* ktown-testing:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo "#PKGS_PRIORITY=( ktown-testing:.* alienbob-current:.* )" >> /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "#REPOPLUS=( slackpkgplus restricted alienbob slacky )" >> /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "REPOPLUS=( slackpkgplus restricted alienbob )" >> /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      echo "#REPOPLUS=( slackpkgplus alienbob )" >> /etc/slackpkg/slackpkgplus.conf
      echo >> /etc/slackpkg/slackpkgplus.conf
      
      if [ "$(uname -m)" = "x86_64" ]; then
        echo >> /etc/slackpkg/slackpkgplus.conf
        echo "#MIRRORPLUS['ktown']=http://taper.alienbase.nl/mirrors/alien-kde/current/latest/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
        echo "#MIRRORPLUS['ktown-testing']=http://taper.alienbase.nl/mirrors/alien-kde/current/testing/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
        if [ "$CURRENT" = true ]; then
          echo "MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
          echo "MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
        else
          echo "#MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
          echo "#MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86_64/" >> /etc/slackpkg/slackpkgplus.conf
        fi
        echo >> /etc/slackpkg/slackpkgplus.conf
      else
        echo >> /etc/slackpkg/slackpkgplus.conf
        echo "#MIRRORPLUS['ktown']=http://taper.alienbase.nl/mirrors/alien-kde/current/latest/x86/" >> /etc/slackpkg/slackpkgplus.conf
        echo "#MIRRORPLUS['ktown-testing']=http://taper.alienbase.nl/mirrors/alien-kde/current/testing/x86/" >> /etc/slackpkg/slackpkgplus.conf
        if [ "$CURRENT" = true ]; then
          echo "MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
          echo "MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
        else
          echo "#MIRRORPLUS['alienbob-current']=http://taper.alienbase.nl/mirrors/people/alien/sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
          echo "#MIRRORPLUS['restricted-current']=http://taper.alienbase.nl/mirrors/people/alien/restricted_sbrepos/current/x86/" >> /etc/slackpkg/slackpkgplus.conf
        fi
        echo >> /etc/slackpkg/slackpkgplus.conf
      fi
    fi
  fi
fi

## this installs all the multilib/compat32 goodies
## thanks to eric hameleers
if [ "$SPPLUSISINSTALLED" = true ]; then
  if [ "$MULTILIB" = true ] && [ "$(uname -m)" = "x86_64" ]; then
    slackpkg_full_upgrade
    slackpkg_update_only
    slackpkg upgrade multilib
    slackpkg_update_only
    slackpkg install multilib
    set_slackpkg_to_auto

    ## script to set up the environment for compat32 building
    wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/multilib-dev.sh \
      -P ~/
  fi
fi

## this prevents breakage if slackpkg gets updated
slackpkg_full_upgrade

## mate
git clone https://github.com/mateslackbuilds/msb.git
## add a script to build & blacklist everything for msb
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/checkmate.sh -P ~/msb/

## slackbook.org
git clone https://github.com/ryanpcmcquen/slackbook.org.git

## enlightenment!
git clone https://github.com/ryanpcmcquen/slackENLIGHTENMENT.git

## my slackbuilds
git clone https://github.com/ryanpcmcquen/ryanpc-slackbuilds.git

## ponce's repo with -current fixes
git clone https://github.com/Ponce/slackbuilds.git ponce-sbo

## script to download tarballs from SlackBuild .info files
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sboGizmos/sbdl \
  -P /usr/local/bin/
chmod 755 /usr/local/bin/sbdl

## simpler version of download script
## only downloads for your ARCH
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sboGizmos/sbdl0 \
  -P /usr/local/bin/
chmod 755 /usr/local/bin/sbdl0

## update version vars for SBo builds
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sboGizmos/sbup \
  -P /usr/local/bin/
chmod 755 /usr/local/bin/sbup

## put md5sums in info file for easier updates
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/sboGizmos/sbmd \
  -P /usr/local/bin/
chmod 755 /usr/local/bin/sbmd

if [ "$SPPLUSISINSTALLED" = true ]; then
  if [ "$MISCELLANY" = true ]; then
    ## set slackpkg to non-interactive mode to run without prompting
    ## we set again just in case someone overwrites configs
    set_slackpkg_to_auto
    slackpkg_update_only
    slackpkg install vlc chromium

    ## auto-update once a day to keep the doctor away
    wget -N \
      https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/daily-slackup \
      -P /etc/cron.daily/
    chmod -v 755 /etc/cron.daily/daily-slackup

    ## eric hameleers has updated multilib to include this package
    #  if [ "$(uname -m)" = "x86_64" ]; then
    #    wget -N http://mirrors.slackware.com/slackware/slackware-current/slackware/x/$LIBXSHM -P ~/
    #    upgradepkg --install-new ~/$LIBXSHM
    #    rm ~/$LIBXSHM
    #    slackpkg blacklist libxshmfence
    #  fi

    ## set up ntp daemon (the good way)
    if [ -x /etc/rc.d/rc.ntpd ]; then
      /etc/rc.d/rc.ntpd stop
    fi
    ntpdate 0.pool.ntp.org
    ntpdate 1.pool.ntp.org
    hwclock --systohc
    sed -i 's/#server pool.ntp.org iburst / \
    server 0.pool.ntp.org iburst \
    server 1.pool.ntp.org iburst \
    server 2.pool.ntp.org iburst \
    server 3.pool.ntp.org iburst \
    /g' /etc/ntp.conf
    chmod -v +x /etc/rc.d/rc.ntpd
    /etc/rc.d/rc.ntpd start
  fi
fi

## check for sbopkg update,
## then sync the slackbuilds.org repo
sbopkg -B -u
sbopkg -B -r
## generate a readable list
make_sbo_pkg_upgrade_list

if [ "$VANILLA" = "yes" ] || [ "$HEADLESS" != "no" ] || [ "$SPPLUSISINSTALLED" != true ]; then
  echo "Headless or source reader?"
else
  ###########
  ### dwm ###
  ###########

  ## sweet, sweet dwm
  no_prompt_sbo_pkg_install_or_upgrade dwm
  no_prompt_sbo_pkg_install_or_upgrade dmenu
  no_prompt_sbo_pkg_install_or_upgrade trayer-srg
  no_prompt_sbo_pkg_install_or_upgrade tinyterm

  ## clean, simple text editor
  no_prompt_sbo_pkg_install_or_upgrade textadept

  ## gists are the coolest
  no_prompt_sbo_pkg_install_or_upgrade gisto

  ## everyone needs patchutils!
  no_prompt_sbo_pkg_install_or_upgrade patchutils

  ## great lightweight file manager with optional DEPS
  no_prompt_sbo_pkg_install_or_upgrade libgnomecanvas
  no_prompt_sbo_pkg_install_or_upgrade zenity
  no_prompt_sbo_pkg_install_or_upgrade udevil
  no_prompt_sbo_pkg_install_or_upgrade spacefm

  ## my dwm tweaks
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/xinitrc.dwm \
    -P /etc/X11/xinit/
  chmod 755 /etc/X11/xinit/xinitrc.dwm
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/dwm-autostart \
    -P /usr/local/etc/

  ## make tinyterm the default
  ln -sfv /usr/bin/tinyterm /usr/local/bin/uxterm
  ln -sfv /usr/bin/tinyterm /usr/local/bin/xterm
  ln -sfv /usr/bin/tinyterm /usr/local/bin/Eterm
  ln -sfv /usr/bin/tinyterm /usr/local/bin/st

  ###########
  ### end ###
  ### dwm ###
  ###########

  ## these are for the image ultimator
  no_prompt_sbo_pkg_install_or_upgrade iojs
  no_prompt_sbo_pkg_install_or_upgrade jpegoptim
  no_prompt_sbo_pkg_install_or_upgrade mozjpeg
  no_prompt_sbo_pkg_install_or_upgrade optipng
  no_prompt_sbo_pkg_install_or_upgrade pngquant
  no_prompt_sbo_pkg_install_or_upgrade gifsicle
  npm install -g svgo
  ## install the image ultimator now that we have the dependencies
  wget -N \
    https://raw.githubusercontent.com/ryanpcmcquen/image-ultimator/master/imgult -P /var/cache/config-o-matic/
  install -v -m755 /var/cache/config-o-matic/imgult /usr/local/bin/
  ## end of imgult stuff
fi

if [ "$SPPLUSISINSTALLED" = true ]; then
  if [ "$MISCELLANY" = true ]; then
    if [ "$CURRENT" != true ]; then
      no_prompt_sbo_pkg_install_or_upgrade pysetuptools
    fi
    no_prompt_sbo_pkg_install_or_upgrade pip

    ## non-sbopkg stuff
    gem install bundler
    pip install --upgrade asciinema

    ## requires pysetuptools
    no_prompt_sbo_pkg_install_or_upgrade speedtest-cli

    ## hydrogen
    no_prompt_sbo_pkg_install_or_upgrade scons
    ## no longer a dependency
    no_prompt_sbo_pkg_install_or_upgrade libtar
    no_prompt_sbo_pkg_install_or_upgrade ladspa_sdk
    no_prompt_sbo_pkg_install_or_upgrade liblrdf
    ## celt is broken
    #no_prompt_sbo_pkg_install_or_upgrade celt
    no_prompt_sbo_pkg_install_or_upgrade jack-audio-connection-kit
    no_prompt_sbo_pkg_install_or_upgrade lash
    no_prompt_sbo_pkg_install_or_upgrade hydrogen
    ##

    ## build qemu with all the architectures
    TARGETS=all no_prompt_sbo_pkg_install_or_upgrade qemu

    ## fails if we don't turn off the tests
    RUN_TEST=false no_prompt_sbo_pkg_install_or_upgrade google-go-lang

    ## more compilers, more fun!
    no_prompt_sbo_pkg_install_or_upgrade pcc
    no_prompt_sbo_pkg_install_or_upgrade tcc

    ## a lot of stuff depends on lua
    no_prompt_sbo_pkg_install_or_upgrade lua
    no_prompt_sbo_pkg_install_or_upgrade luajit

    ## i can't remember why this is here
    no_prompt_sbo_pkg_install_or_upgrade bullet

    ## helps with webkit and some other things
    no_prompt_sbo_pkg_install_or_upgrade libwebp

    ## i don't even have optical drives on all my comps, but ...
    no_prompt_sbo_pkg_install_or_upgrade libdvdcss
    no_prompt_sbo_pkg_install_or_upgrade libbluray

    if [ "$CURRENT" != true ]; then
      no_prompt_sbo_pkg_install_or_upgrade orc
      no_prompt_sbo_pkg_install_or_upgrade gstreamer1
      no_prompt_sbo_pkg_install_or_upgrade gst1-plugins-base
    fi

    ## e16, so tiny!
    no_prompt_sbo_pkg_install_or_upgrade imlib2
    no_prompt_sbo_pkg_install_or_upgrade giblib
    ## broken on current
    #no_prompt_sbo_pkg_install_or_upgrade e16
    no_prompt_sbo_pkg_install_or_upgrade gmrun

    ## pekwm! (is broken on -current)
    #no_prompt_sbo_pkg_install_or_upgrade pekwm

    ## lumina!
    no_prompt_sbo_pkg_install_or_upgrade lumina

    if [ -z "$(cat /usr/share/e16/config/bindings.cfg | grep gmrun)" ]; then
      echo >> /usr/share/e16/config/bindings.cfg
      echo "## my bindings" >> /usr/share/e16/config/bindings.cfg
      echo "KeyDown   A    Escape exec gmrun" >> /usr/share/e16/config/bindings.cfg
      echo >> /usr/share/e16/config/bindings.cfg
    fi

    no_prompt_sbo_pkg_install_or_upgrade scrot

    no_prompt_sbo_pkg_install_or_upgrade screenfetch

    ## this library is necessary for some games,
    ## doesn't hurt to have it  ; ^)
    no_prompt_sbo_pkg_install_or_upgrade libtxc_dxtn

    no_prompt_sbo_pkg_install_or_upgrade lame

    no_prompt_sbo_pkg_install_or_upgrade x264

    no_prompt_sbo_pkg_install_or_upgrade OpenAL

    ## SDL ftw!
    ## SDL_Pango broken on current
    #no_prompt_sbo_pkg_install_or_upgrade SDL_Pango
    no_prompt_sbo_pkg_install_or_upgrade SDL_gfx
    no_prompt_sbo_pkg_install_or_upgrade SDL_sound
    no_prompt_sbo_pkg_install_or_upgrade SDL2
    no_prompt_sbo_pkg_install_or_upgrade SDL2_gfx
    no_prompt_sbo_pkg_install_or_upgrade SDL2_image
    no_prompt_sbo_pkg_install_or_upgrade SDL2_mixer
    no_prompt_sbo_pkg_install_or_upgrade SDL2_net
    no_prompt_sbo_pkg_install_or_upgrade SDL2_ttf

    no_prompt_sbo_pkg_install_or_upgrade speex
    ## script now detects multilib,
    ## thanks to b. watson
    no_prompt_sbo_pkg_install_or_upgrade apulse

    my_repo_install ffmpeg

    JACK=on no_prompt_sbo_pkg_install_or_upgrade ssr

    no_prompt_sbo_pkg_install_or_upgrade rar
    no_prompt_sbo_pkg_install_or_upgrade unrar

    no_prompt_sbo_pkg_install_or_upgrade p7zip
    no_prompt_sbo_pkg_install_or_upgrade libmspack
    no_prompt_sbo_pkg_install_or_upgrade wxPython

    ## wineing
    if [ "$MULTILIB" = true ] || [ `getconf LONG_BIT` = "32" ]; then
      no_prompt_sbo_pkg_install_or_upgrade webcore-fonts
      no_prompt_sbo_pkg_install_or_upgrade cabextract
      no_prompt_sbo_pkg_install_or_upgrade wine
      no_prompt_sbo_pkg_install_or_upgrade winetricks
      no_prompt_sbo_pkg_install_or_upgrade php-imagick
      no_prompt_sbo_pkg_install_or_upgrade icoutils
      no_prompt_sbo_pkg_install_or_upgrade playonlinux
    fi
    ##

    ## nostalgic for me
    no_prompt_sbo_pkg_install_or_upgrade codeblocks
    no_prompt_sbo_pkg_install_or_upgrade geany
    no_prompt_sbo_pkg_install_or_upgrade geany-plugins

    ## good ol' audacity
    no_prompt_sbo_pkg_install_or_upgrade soundtouch
    no_prompt_sbo_pkg_install_or_upgrade vamp-plugin-sdk
    my_repo_install audacity

    ## i may make stuff someday
    no_prompt_sbo_pkg_install_or_upgrade blender
    no_prompt_sbo_pkg_install_or_upgrade pitivi

    ## scribus
    ## cppunit breaks podofo on 32-bit
    #no_prompt_sbo_pkg_install_or_upgrade cppunit
    no_prompt_sbo_pkg_install_or_upgrade podofo
    no_prompt_sbo_pkg_install_or_upgrade scribus
    ##

    ## inkscape
    no_prompt_sbo_pkg_install_or_upgrade gts
    no_prompt_sbo_pkg_install_or_upgrade graphviz
    ## broken on current and optional anyways
    #no_prompt_sbo_pkg_install_or_upgrade libwpg
    no_prompt_sbo_pkg_install_or_upgrade numpy
    no_prompt_sbo_pkg_install_or_upgrade BeautifulSoup
    no_prompt_sbo_pkg_install_or_upgrade lxml
    no_prompt_sbo_pkg_install_or_upgrade libsigc++
    no_prompt_sbo_pkg_install_or_upgrade glibmm
    no_prompt_sbo_pkg_install_or_upgrade cairomm
    no_prompt_sbo_pkg_install_or_upgrade pangomm
    no_prompt_sbo_pkg_install_or_upgrade atkmm
    no_prompt_sbo_pkg_install_or_upgrade mm-common
    no_prompt_sbo_pkg_install_or_upgrade gtkmm
    no_prompt_sbo_pkg_install_or_upgrade gsl
    no_prompt_sbo_pkg_install_or_upgrade inkscape
    ##

    ## open non-1337 stuff
    no_prompt_sbo_pkg_install_or_upgrade libreoffice

    ## web messin'
    no_prompt_sbo_pkg_install_or_upgrade brackets

    ## android stuff!
    no_prompt_sbo_pkg_install_or_upgrade gmtp
    no_prompt_sbo_pkg_install_or_upgrade android-tools
    no_prompt_sbo_pkg_install_or_upgrade android-studio

    ## librecad
    no_prompt_sbo_pkg_install_or_upgrade muParser
    no_prompt_sbo_pkg_install_or_upgrade librecad
    ##

    ## make gtk stuff elegant
    no_prompt_sbo_pkg_install_or_upgrade murrine
    no_prompt_sbo_pkg_install_or_upgrade murrine-themes

    ## because QtCurve looks amazing
    if [ "`find /var/log/packages/ -name kdelibs-*`" ]; then
      no_prompt_sbo_pkg_install_or_upgrade QtCurve-KDE4
      no_prompt_sbo_pkg_install_or_upgrade kde-gtk-config
    fi
    no_prompt_sbo_pkg_install_or_upgrade QtCurve-Gtk2

    no_prompt_sbo_pkg_install_or_upgrade dmg2img

    no_prompt_sbo_pkg_install_or_upgrade qtfm

    no_prompt_sbo_pkg_install_or_upgrade mirage

    no_prompt_sbo_pkg_install_or_upgrade copy

    no_prompt_sbo_pkg_install_or_upgrade mdp

    if [ "$(uname -m)" = "x86_64" ]; then
      no_prompt_sbo_pkg_install_or_upgrade spotify64
    else
      no_prompt_sbo_pkg_install_or_upgrade spotify32
    fi

    no_prompt_sbo_pkg_install_or_upgrade tiled-qt

    no_prompt_sbo_pkg_install_or_upgrade google-webdesigner

    ## lutris
    ## recommended
    no_prompt_sbo_pkg_install_or_upgrade eawpats
    no_prompt_sbo_pkg_install_or_upgrade allegro
    ## required
    no_prompt_sbo_pkg_install_or_upgrade pyxdg
    no_prompt_sbo_pkg_install_or_upgrade PyYAML
    no_prompt_sbo_pkg_install_or_upgrade pygobject3
    no_prompt_sbo_pkg_install_or_upgrade lutris

    ## retro games!
    no_prompt_sbo_pkg_install_or_upgrade higan
    no_prompt_sbo_pkg_install_or_upgrade mednafen

    ## grab latest steam package
    if [ -z "`find /var/log/packages/ -name steamclient-*`" ]; then
      rsync -avz rsync://taper.alienbase.nl/mirrors/people/alien/slackbuilds/steamclient/pkg/current/ /var/cache/config-o-matic/steamclient/
      upgradepkg --install-new /var/cache/config-o-matic/steamclient/steamclient-*.tgz
      if [ -z "$(cat /etc/slackpkg/blacklist | grep steamclient)" ]; then
        echo steamclient >> /etc/slackpkg/blacklist
        echo >> /etc/slackpkg/blacklist
      fi
    fi

    if [ "$(uname -m)" = "x86_64" ]; then
      wget -N http://www.desura.com/desura-x86_64.tar.gz \
        -P /var/cache/config-o-matic/
    else
      wget -N http://www.desura.com/desura-x86_64.tar.gz \
        -P /var/cache/config-o-matic/
    fi
    tar xvf /var/cache/config-o-matic/desura-*.tar.gz -C /opt/
    ln -sfv /opt/desura/desura /usr/local/bin/

    ## minecraft!!
    mkdir -pv /opt/minecraft/
    wget -N $MINECRAFTDL -P /opt/minecraft/
    wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/minecraft -P /usr/local/bin/
    chmod 755 /usr/local/bin/minecraft

    curl $GETJAVA | sh

    ## numix stuff is dead sexy
    git clone https://github.com/numixproject/numix-icon-theme.git /var/cache/config-o-matic/themes/numix-icon-theme/
    cd /var/cache/config-o-matic/themes/numix-icon-theme/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme/Numix/ /usr/share/icons/
    cd

    git clone https://github.com/numixproject/numix-icon-theme-bevel.git /var/cache/config-o-matic/themes/numix-icon-theme-bevel/
    cd /var/cache/config-o-matic/themes/numix-icon-theme-bevel/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme-bevel/Numix-Bevel/ /usr/share/icons/
    cd

    git clone https://github.com/numixproject/numix-icon-theme-circle.git /var/cache/config-o-matic/themes/numix-icon-theme-circle/
    cd /var/cache/config-o-matic/themes/numix-icon-theme-circle/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme-circle/Numix-Circle/ /usr/share/icons/
    ## make the default theme even better
    cp -rv /usr/share/icons/Numix-Circle/* /usr/share/icons/Adwaita/
    cd

    git clone https://github.com/numixproject/numix-icon-theme-shine.git /var/cache/config-o-matic/themes/numix-icon-theme-shine/
    cd /var/cache/config-o-matic/themes/numix-icon-theme-shine/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme-shine/Numix-Shine/ /usr/share/icons/
    cd

    git clone https://github.com/numixproject/numix-icon-theme-utouch.git /var/cache/config-o-matic/themes/numix-icon-theme-utouch/
    cd /var/cache/config-o-matic/themes/numix-icon-theme-utouch/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme-utouch/Numix-uTouch/ /usr/share/icons/
    cd

    git clone https://github.com/shimmerproject/Numix.git /var/cache/config-o-matic/themes/Numix/
    cd /var/cache/config-o-matic/themes/Numix/
    git pull
    cp -rv /var/cache/config-o-matic/themes/numix-icon-theme-utouch/Numix-uTouch/ /usr/share/icons/
    cd

    git clone https://github.com/shimmerproject/Numix.git /usr/share/themes/Numix/
    cd /usr/share/themes/Numix/
    git pull
    cd

    wget -N \
      https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.colors -P /usr/share/apps/color-schemes/
    mv -v /usr/share/apps/color-schemes/Numix.colors /usr/share/apps/color-schemes/Numix-KDE.colors
    wget -N \
      https://raw.githubusercontent.com/numixproject/numix-kde-theme/master/Numix.qtcurve -P /usr/share/apps/QtCurve/
    mv -v /usr/share/apps/QtCurve/Numix.qtcurve /usr/share/apps/QtCurve/Numix-KDE.qtcurve

    ## caledonia kde theme
    wget -N \
      http://sourceforge.net/projects/caledonia/files/Caledonia%20%28Plasma-KDE%20Theme%29/$CALPLAS \
      -P /usr/share/apps/desktoptheme/
    tar xvf /usr/share/apps/desktoptheme/$CALPLAS -C /usr/share/apps/desktoptheme/

    ## caledonia color scheme
    wget -N http://sourceforge.net/projects/caledonia/files/Caledonia%20Color%20Scheme/Caledonia.colors \
      -P /usr/share/apps/color-schemes/

    ## get caledonia wallpapers, who doesn't like nice wallpapers?
    wget -N \
      http://sourceforge.net/projects/caledonia/files/Caledonia%20Official%20Wallpapers/$CALWALL \
      -P /usr/share/wallpapers/
    tar xvf /usr/share/wallpapers/$CALWALL -C /usr/share/wallpapers/
    cp -rv /usr/share/wallpapers/Caledonia_Official_Wallpaper_Collection/* /usr/share/wallpapers/
    rm -rfv /usr/share/wallpapers/Caledonia_Official_Wallpaper_Collection/

    ## a few numix wallpapers also
    wget -N \
      http://fc03.deviantart.net/fs71/f/2013/305/3/6/numix___halloween___wallpaper_by_satya164-d6skv0g.zip -P /var/cache/config-o-matic/
    wget -N \
      http://fc00.deviantart.net/fs70/f/2013/249/7/6/numix___fragmented_space_by_me4oslav-d6l8ihd.zip -P /var/cache/config-o-matic/
    wget -N \
      http://fc09.deviantart.net/fs70/f/2013/224/b/6/numix___name_of_the_doctor___wallpaper_by_satya164-d6hvzh7.zip -P /var/cache/config-o-matic/
    unzip -o /var/cache/config-o-matic/numix___halloween___wallpaper_by_satya164-d6skv0g.zip -d /var/cache/config-o-matic/images/
    unzip -o /var/cache/config-o-matic/numix___fragmented_space_by_me4oslav-d6l8ihd.zip -d /var/cache/config-o-matic/images/
    unzip -o /var/cache/config-o-matic/numix___name_of_the_doctor___wallpaper_by_satya164-d6hvzh7.zip -d /var/cache/config-o-matic/images/

    cp -v /var/cache/config-o-matic/images/*.png /usr/share/wallpapers/
    cp -v /var/cache/config-o-matic/images/*.jpg /usr/share/wallpapers/

    ## symlink all wallpapers so they show up in other DE's
    mkdir -pv /usr/share/backgrounds/mate/custom/
    find /usr/share/wallpapers -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.jpe' -o -iname '*.gif' -o -iname '*.png' \) \
      -exec ln -sfv {} /usr/share/backgrounds/mate/custom/ \;
    find /usr/share/wallpapers -type f -a \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.jpe' -o -iname '*.gif' -o -iname '*.png' \) \
      -exec ln -sfv {} /usr/share/backgrounds/xfce/ \;
  else
    echo "You have gone VANILLA."
  fi
fi


## used to be beginning of SCRIPTS

wget -N $GETEXTRASLACK -P ~/

if [ "$CURRENT" = true ]; then
  wget -N $GETSOURCECUR -P ~/
else
  wget -N $GETSOURCESTA -P ~/
fi

wget -N $GETJAVA -P ~/

## bumblebee/nvidia scripts
if [ "$(lspci | grep NVIDIA)" ]; then
  wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/crazybee.sh -P ~/
fi

## auto generic-kernel script
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/switchToGenericKernel.sh -P ~/
chmod 755 ~/switchToGenericKernel.sh

## compile latest mainline/stable/longterm kernel
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/kernelMe.sh -P /usr/src/
chmod 755 /usr/src/kernelMe.sh

if [ "`find /var/log/packages/ -name raspi-*`" ]; then
  curl -L --output /usr/bin/rpi-update https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update \
    && chmod +x /usr/bin/rpi-update
fi

## script to install latest firefox developer edition
wget -N https://raw.githubusercontent.com/ryanpcmcquen/ryanpc-slackbuilds/master/unofficial/fde/getFDE.sh -P ~/

## run mednafen with sexyal-literal-default
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/slackware/medna \
  -P /usr/local/bin/
chmod 755 /usr/local/bin/medna

## fix firefox's endless default browser prompts; also less typing  ;-)
wget -N https://raw.githubusercontent.com/ryanpcmcquen/linuxTweaks/master/ff \
  -P /usr/local/bin/
cp -v /usr/local/bin/ff /usr/local/bin/firefox
chmod 755 /usr/local/bin/ff /usr/local/bin/firefox

## used to be end of SCRIPTS

## disables any interfaces that may interfere with wicd
if [ "$WICD" = true ]; then
  slackpkg_update_only
  slackpkg install wicd
  chmod -v -x /etc/rc.d/rc.networkmanager
  sed -i 's/^\([^#]\)/#\1/g' /etc/rc.d/rc.inet1.conf
fi

## let there be sound!
/etc/rc.d/rc.alsa
if [ "$(aplay -l | grep Analog | grep 'card 1')" ]; then
  amixer set -c 1 Master 0% unmute
  amixer set -c 1 Master 97% unmute
  amixer set -c 1 Headphone 0% unmute
  amixer set -c 1 Headphone 87% unmute
  amixer set -c 1 PCM 0% unmute
  amixer set -c 1 PCM 97% unmute
  amixer set -c 1 Mic 0% unmute
  amixer set -c 1 Mic 50% unmute
  amixer set -c 1 Capture 0% cap
  amixer set -c 1 Capture 50% cap
else
  amixer set Master 0% unmute
  amixer set Master 97% unmute
  amixer set Headphone 0% unmute
  amixer set Headphone 87% unmute
  amixer set PCM 0% unmute
  amixer set PCM 97% unmute
  amixer set Mic 0% unmute
  amixer set Mic 50% unmute
  amixer set Capture 0% cap
  amixer set Capture 50% cap
fi

alsactl store


## set slackpkg back to normal
set_slackpkg_to_manual


## create an info file
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "########################################" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "## CONFIG-O-MATIC $CONFIGOMATICVERSION ##" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "## BLANK=false ##" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION

echo "VANILLA=$VANILLA" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "HEADLESS=$HEADLESS" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "SPPLUSISINSTALLED=$SPPLUSISINSTALLED" >> ~/.config-o-matic_$CONFIGOMATICVERSION

echo >> ~/.config-o-matic_$CONFIGOMATICVERSION

echo "CURRENT=$CURRENT" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "WICD=$WICD" >> ~/.config-o-matic_$CONFIGOMATICVERSION
if [ "$COMARCH" != "arm" ]; then
  echo "MISCELLANY=$MISCELLANY" >> ~/.config-o-matic_$CONFIGOMATICVERSION
fi
if [ "$(uname -m)" = "x86_64" ]; then
  echo "MULTILIB=$MULTILIB" >> ~/.config-o-matic_$CONFIGOMATICVERSION
fi

echo >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo "########################################" >> ~/.config-o-matic_$CONFIGOMATICVERSION
echo >> ~/.config-o-matic_$CONFIGOMATICVERSION

rm -v ~/slackwareStableVersion
rm -v ~/sbopkgVersion
rm -v ~/sbopkg-upgrade-list.txt
rm -v ~/slackpkgPlusVersion
rm -v ~/caledoniaPlasmaVersion
rm -v ~/caledoniaWallpaperVersion

## thanks!
echo
echo
echo "************************************"
echo "********** CONFIG-O-MATIC **********"
echo "************************************"
echo
echo "Your system is now set to UTF-8."
echo "(e.g. You should use uxterm, instead of xterm)."
echo "Thank you for using config-o-matic!"
echo
echo "You should now run the $ user script."
echo




