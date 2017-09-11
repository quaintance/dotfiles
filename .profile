#my junk drawer, years of weirdness all piled into one file.
# jeffq

#++++++++++++++++++++ exports
#export NMON=cnDkm
export NMON=cmt
#export NMON=ckmto^V
export EDITOR=vi
export FCEDIT=vi
export GOPATH=~/go
export PATH=$PATH:.:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/admin/sbin:/opt/puppet/bin:~/google-cloud-sdk/bin:/usr/local/opt/go/libexec/bin:~/bin
export host=`hostname|cut -d. -f1`
function _update_ps1() {
    PS1="$(~/powerline-shell.py --mode=patched --cwd-mode=plain  2> /dev/null)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
#export PS1='[\!][${host}]:${PWD}> '
#if [[ -x $(which git 2>/dev/null) ]]; then
#  export GIT_PROMPT_ONLY_IN_REPO=1
#  #source ~/.bash-git-prompt/gitprompt.sh 
#  source ~/.gitbashrc
#else
#  export PS1='[\!][${host}]:${PWD}> '
#fi

export PS2='=> '
export PS3='-> '
export PS4='#$LINENO++ '

[ -x /bin/less ] || [ -x /usr/bin/less ] && export PAGER=less || export PAGER=more

if [ $PAGER = "less" ]; then
	export LESS='--quit-at-eof --squeeze-blank-lines --RAW-CONTROL-CHARS --ignore-case --hilite-unread' # nice stuff for less
	export LESS_TERMCAP_mb=$'\E[01;31m'		# begin blinking
	export LESS_TERMCAP_md=$'\E[01;38;5;74m'	# begin bold
	export LESS_TERMCAP_me=$'\E[0m'			# end mode
	export LESS_TERMCAP_se=$'\E[0m'			# end standout-mode
	export LESS_TERMCAP_so=$'\E[01;50;5;174m'	# start standout-mode - bright white on grey
	#export LESS_TERMCAP_so=$'\E[38;5;246m'		# start standout-mode - info box 
	export LESS_TERMCAP_ue=$'\E[0m'			# end underline
	export LESS_TERMCAP_us=$'\E[04;38;5;146m'	# start underline
fi

# my collection of history files
[ ! -d $HOME/.hist ] && mkdir $HOME/.hist
	export HISTFILE=$HOME/.hist/`hostname|cut -f1 -d'.'`.history
[ ! -f $HISTFILE ] && touch $HISTFILE && chmod 600 $HISTFILE
	export HISTSIZE=99000

# Get the latest changes on master pulled down locally
# and then rebase them into/onto the current branch
function grm {
  CURRENT=`git rev-parse --abbrev-ref HEAD` # figures out the current branch
  git checkout master
  git pull
  git checkout $CURRENT
  git rebase master
}

function retry { # impatiently keep trying to ssh to a host until success.. when you're rebooting.
	while :
		do sleep 1
		ssh $1
		if [ "$?" = "0" ]; then
			break	
		fi 
	done 
}

function bk { # timestamp back up files before editing them
	if [ "$SHELL" = "/bin/bash" ]; then
		if [[ $1 = "-s" ]]; then
			echo "backing up file: $2"
			sudo cp $2{,.`date '+%Y%m%d-%H%M%S'`}
		else
			echo "backing up file: $1"
			cp $1{,.`date '+%Y%m%d-%H%M%S'`}
		fi
	else # i wish the world were made of bash shells.. i could have just made the function do it the most compatible way
	     # but that isn't as cool... 
                if [[ $1 = "-s" ]]; then
                        echo "backing up file: $2"
                        sudo cp $2 $2.`date '+%Y%m%d-%H%M%S'
                else
                        echo "backing up file: $1"
                        cp $1 $1.`date '+%Y%m%d-%H%M%S'
                fi
	fi

}

function c { # commandline math using bashcalc
	if [[ $1 = "-i" ]]; then
		while true
			do read -p "" bashcalc;
			echo "scale=2; ${bashcalc}" | bc ;
			echo "---------------------";
		done
	else
		echo "scale=2;$*" | bc 
	fi
}

function hexc { # convert hex yo
	echo "base=16;$*" |bc
}

function tf-graph { # graph all the things (for tf)
   terraform graph > $1.dot
   dot $1.dot -Tsvg -o $1.svg
}

function fb { # print human readable format largest files in a filesystem, handy for finding fs full culprits
	directory=""
	if [[ -n $1 && -d $1 ]]; then
		directory=$1
	else
		echo "$1 is not a directory, using `pwd`"
		directory=`pwd`
	fi
	sudo find $directory -xdev -ls|sort -rnk7|head -30|awk '
	{printf("size: %5.2f MB -> %s\n",$7/1024/1024,$NF)}'
}

function etime { # epoch translation
	if [ "$1" != "" ]; then
		perl -e 'my $input=scalar(localtime('"$1"'));print "actual time: $input \n"'
	else
		perl -e 'my $ep=time;print "seconds since epoch: $ep \n"'
		perl -e 'my $realtime=scalar(localtime(time));print "real time: $realtime \n"'
	fi
}


function extr { # wrap all the compression types into one command
if [ -f $1 ] ; then
	case $1 in
		*.tar.bz2)   tar xvjf $1 ;;
		*.tar.gz)    gunzip -c $1|tar -xvf - ;; # gnu tar doesnt exist everywhere.
		*.tar.Z)	 uncompress -c $1|tar -xvf - ;;
		*.bz2)       bunzip2 $1 ;;
		*.rar)       unrar x $1 ;;
		*.gz)        gunzip $1 ;;
		*.tar)       tar xvf $1 ;;
		*.tbz2)      tar xvjf $1 ;;
		*.tgz)       gunzip -c $1|tar -xvf - ;;
		*.zip)       unzip $1 ;;
		*.Z)         uncompress $1 ;;
		*)           echo "'$1' unknown compression type" ;;
	esac
else
	echo "'$1' is not a recognized extension"
fi
}

#++++++++++++++++++++ shell stuff
case $0 in 
	*ksh)
		echo "ksh, beware"
		export EXTENDED_HISTORY=ON
		export PS1='[\!][${host}]:${PWD}> '
		set -o vi 
		stty erase ^?
		;;
	*ksh93)
		echo "ksh93, wow."
		export EXTENDED_HISTORY=ON
		typeset -A Keytable
		trap 'eval "${Keytable[${.sh.edchar}]}"' KEYBD
		function keybind # key action
		{
		    typeset key=$(print -f "%q" "$2")
		    case $# in
		    2)  Keytable[$1]=' .sh.edchar=${.sh.edmode}'"$key" ;;
		    1)  unset Keytable[$1] ;;
		    *)  print -u2 "Usage: $0 key [action]" ;;
		    esac
		}
		keybind $'\E[D' $'\002'             # ^B    Allows the arrow keys to
		keybind $'\E[C' $'\006'             # ^F    go through the history
		keybind $'\E[B' $'\016'             # ^N
		keybind $'\E[A' $'\020'             # ^P
		keybind $'\t' $'\E\E'               # TAB becomes command completion
		keybind $'\004' $'\E=' ;;           # ^D becomes list all matches
	*pdksh)
		echo "pdksh, lol"
		set -o vi
		set -o vi-tabcomplete;;
	*bash)
		export HISTTIMEFORMAT='[%j|%g %T] ' # julian day|year timestamp in shell history.
		export HISTCONTROL=ignoreboth
      set -o vi
		set show-all-symlinked-directories
		shopt -s extglob # turn on extended globbing commandline regex.. or something.
		shopt -s histappend # append shell history sessions rather than overwrite.
		shopt -s cdspell # correct my rushed spelling errors.
		# all the tab completes.
		complete -a unalias
		complete -c command type which
		complete -A stopped -P '"%' -S '"' bg
		complete -j -P '"%' -S '"' fg jobs disown
		complete -cf sudo # sudo tab completion.
		complete -cf which # which completion
		complete -cf man # man page completion
		complete -o default -W "$(sed -e 's/ .*//' ~/.ssh/known_hosts|tr ',' '\012'|sort -u)" ssh # ssh complete!

		# shell history search with arrows on partial commandline
		#bind '"\e[A"':history-search-backward
		#bind '"\e[B"':history-search-forward ;;
      ;;
	*)
		echo "oh dear god, not another shell?" ;;

esac

#++++++++++++++++++++ OS stuff
case `uname -s` in
	AIX )
		export MANPATH=$MANPATH:/opt/freeware/man
		alias df="df -Pg"
		alias pstree=proctree # im used to linux.
		#[ -s ~jquainta/nmon/nmon ] && alias nmon="~jquainta/nmon/nmon" # no longer needed.
		alias lstl="instfix -i|grep ML"
		alias lssp="instfix -i|grep SP"
		alias vmo="sudo vmo"
		alias ioo="sudo ioo"
		alias baddisk="iostat -Dl | awk '/hdiskpower/ &&  $2 > 60  { print $0 } '" #SAN disks with more than 60% tm_act
		alias pgsp="sudo svmon -P -O sortseg=pgsp,unit=MB|head -30" # top paging space users

		### functions

		function lshmc { # locate the HMC(s) for this host
			for i in `lsrsrc -dx IBM.ManagementServer Hostname|awk -F\" '{print $2}'`;do
				host $i 2>/dev/null
				[ $? != 0 ] && echo $i 
			done
		}
		
		function sn { # quick serial number and frame model view on Power.
			lsattr -El sys0|awk '$1~/systemid/ {print "Serial num: "substr($0,23,2)"-"substr($0,25,5)}
						 $1~/modelname/ {print "Model name: "substr($0,21,9)}'

		}

		function pidslot { #convert PID to slot # and vice versa, for use with pstat
			if [[ $1 = "-h" ]]; then
				HEX=`printf "%5x\n" "$2"`
	     		echo "PID: "$2" --> SLOT: "$HEX
				#echo $2 | awk '{printf("%x\n", $1)}';
			elif [[ $1 = "-d" ]]; then 
				DEC=`printf "%5d\n" "0x$2"`
				echo "SLOT: "$2" --> PID: "$DEC
			elif [[ $1 != "-d|-h" ]]; then
				echo "usage: pidslot [-d|-h] [SLOT|PID]"
			fi
		}

		function top10 { # top 10 memory consumers(user list, not PID)
			sudo svmon -Ut10|grep -p "==="|egrep -v "^=|^User|^$"|awk '
				{print "user: "$1"\t ----> real: "($2/256)" MB\tpaging: "($4/256)" MB"}'
		}

		function lsmem { # detailed memory stats
			#sudo vmstat -v|awk '
			#	/memory pages/ {printf("total real memory =\t %5.2f GB\n",$1/256/1024)}
			#	/free pages/   {printf("real memory free  =\t %5.2f GB\n",$1/256/1024)}
			#	/client pages/ {printf("client pages used =\t %5.2f GB\n",$1/256/1024)}'
			sudo svmon -G|awk '
				/memory/       {printf("total real memory =\t %5.2f GB\n",$2/256/1024)}
				/memory/       {printf("real memory free  =\t %5.2f GB\n",$4/256/1024)}
				/in use/       {printf("real memory used  =\t %5.2f GB\n",($3+$5)/256/1024)}
				/pg space/     {printf("paging space used =\t %5.2f GB\n",$4/256/1024)}'
			vmstat -v|awk '
				/client pages/ {printf("client pages used =\t %5.2f GB\n",$1/256/1024)}'
			echo ""
			ps -eko vsz,rssize | awk '{rss += $2; vsz+=$1} END {
				printf("total RSS: %5.2f GB\n",rss/1024/1024)
				printf("total VSZ: %5.2f GB\n",vsz/1024/1024)}'
		}

		function lsec { # display etherchannel configuration attributes
			for number in `LANG=C lsdev -Cc adapter -s pseudo -t ibm_ech -F name|
				awk -F "ent" '{print $2}' | sort -n`; do
				channel="ent${number}"
				status=`lsdev -Cc adapter -s pseudo -t ibm_ech |
				grep $channel | awk '{ print $2 }'`
				dspmsg -s 4 smit.cat 713 'EtherChannel / Link Aggregation: %s ' $channel
				dspmsg -s 4 smit.cat 714 'Status: %s ' $status
				dspmsg -s 4 smit.cat 715 'Attributes: '
				lsattr -El $channel -F "      attribute value description"
				echo ""
			done
		} 

		function lsmedia { #list media speed/duplex settings for adapters
			for adapter in `lsdev -Cc adapter | grep -i ent | awk '{print $1}'`; do
				echo "$adapter --> `lsattr -El $adapter |grep media_speed|awk '{print $2}'`" 
			done
		}

		function topmem {  # show top memory processes... not terribly useful for shmem users
			sudo svmon -Pt50 | perl -e 'while(<>){print if ($.==2||$&&&!$s++);$.=0 if (/^-+$/)}'
		} ;;


	Darwin )
		[ -f ~jquainta/.ls_colors ] && eval `dircolors ~jquainta/.ls_colors` 2>&1
		alias df="df -Ph"
		alias nmon="~jquainta/nmon/linux/nmon"
		#alias sys0="sudo dmidecode|perl -ne 'print if /0x0001/ .. /0x0002/'"
		#alias sys0="sudo dmidecode -t 1,1" # doesnt seem to work on older rhel. fuckers
		alias sys0="sudo dmidecode|perl -ne 'print if /0x(0100|0001)/ .. /0x(0200|0002)/'"

		### functions.

		function lsec { # list etherchannels.. or bonds in the case of linux
			for x in `ls /etc/sysconfig/network-scripts/ifcfg-bond?`;do 
				echo "adapter"`cat $x|awk -F= '/DEVICE|IPAD|SLAV/ {printf " - "$2}'`
			done
		}

		function lsmem { # list detailed memory stats in linux.. parsing /proc/meminfo into easy to read
			bitness=`uname -i`
			echo "memory statistics:"
			awk '
				/^MemTotal:/  {printf("total real memory   = %5.2f GB\n",$2/1024/1024)}
				/^Active:/    {printf("Active memory       = %5.2f GB\n",$2/1024/1024)}
				/^Inactive:/  {printf("Inactive memory     = %5.2f GB\n",$2/1024/1024)}
				/^MemFree:/   {printf("total free memory   = %5.2f GB\n",$2/1024/1024)}
				/^Buffers:/   {printf("Buffers for IO ops  = %5.2f GB\n",$2/1024/1024)}
				/^Cached:/    {printf("file caching used   = %5.2f GB\n",$2/1024/1024)}
				/^SwapTotal:/ {printf("total swap space    = %5.2f GB\n",$2/1024/1024)}
				/^SwapFree:/  {printf("swap space free     = %5.2f GB\n",$2/1024/1024)}
				/^Slab:/      {printf("kernel data structs = %5.2f GB\n",$2/1024/1024)}
				' /proc/meminfo
			if [ "$bitness" = "i386" ]; then
				echo ""
				echo "32bit High/Low memory utilization: "
				awk '
					/^LowTotal:/  {printf("low memory total    = %5.2f MB\n",$2/1024)}
					/^LowFree:/   {printf("low memory free     = %5.2f MB\n",$2/1024)}
					/^HighTotal:/ {printf("high memory total   = %5.2f GB\n",$2/1024/1024)}
					/^HighFree:/  {printf("high memory free    = %5.2f GB\n",$2/1024/1024)}
					' /proc/meminfo
			fi

			if [ "$1" = "-s" ]; then
				echo ""
				echo "top 10 kernel data structures allocated: "
				head -2 /proc/slabinfo && sort -rnk2 /proc/slabinfo|head -10
			fi
		 } ;;
	SunOS )
		alias df="df -k"
		echo "stupid SunOS" ;;
	CYGWIN*)
		export PATH=$PATH:/cygdrive/c/Program\ Files/:/cygdrive/c/Program\ Files/VMware/VMware\ VI\ Remote\ CLI/bin
		alias rcli="cd /cygdrive/c/Program\ Files/VMware/VMware\ VI\ Remote\ CLI/bin" ;;
	HP-UX )
		echo "hpux..... "
                stty erase ^? ;;

	* ) 
		echo "wtf is this?" ;;
esac

#++++++++++++++++++++ generics
alias json="python -mjson.tool"                     # formatted puppet catalogs, anyone?
alias unperl="perl -MO=Deparse,-p,-q,-x=9"          # handy
alias cperl="perl -MO=Concise,-exec"                # even more handy
#alias more=less                                    # the most handy
alias sudoq="sudo /usr/local/admin/sbin/qs5.pl"     # why didnt i just call it qs5?
alias fssh="sudo fssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"                              #
alias fscp="sudo fscp"                              # 
alias pshog="ps aux|awk 'NR>1'|sort -k 3nr|head"    # ...
alias view='vim -v'                                 # pointless
alias Grep="grep"                                   # stolen from mark!
alias grpe="grep"                                   # ditto
alias gerp="grep"                                   # i dont mystype gerp but just in case
alias hh="fc -l"                                    # history lovers
alias fce="fc -e vi "                               # edit!
alias lss='ls -l|sort -k 5nr|head -30'              # list files in a dir by size.
alias lsd="ls -aF|grep \/"                          # list directories
alias l.='ls -d .* --color=tty'                     # show my dot files, please
alias epochs="perl -le 'print time'"                # seconds since epoch
alias epochd="perl -e 'printf qq{%d\n},time/86400'" # days since epoch
alias diff="diff --side-by-side"	            # i generally prefer this mode.
alias puppet-ls="sudo /opt/puppet/bin/puppet catalog --terminus json select `hostname -f` file" # pe managed files`
alias pval="puppet parser validate --parser=future "
alias webshare='python -c "import SimpleHTTPServer;SimpleHTTPServer.test()"' # lol
alias kc=kubectl
alias tf=terraform


# ever wonder when?
alias rpmbydate='rpm -qa --queryformat "%{NAME}-%{VERSION}.%{RELEASE} (%{ARCH}) INSTALLED: %{INSTALLTIME:date}\n"'
alias mobile-np='ssh -i ~/.ssh/mobile-np-key.pem -o "ProxyCommand ssh -W %h:%p -i ~/.ssh/mobile-np-key.pem ec2-user@10.242.35.29"'

[ `uname -n` = "AgentSmith" ] && alias sinfo="cat /usr/local/admin/etc/server.list|egrep -i"

if [[ $TERM = "vt320" ]]; then
	stty erase
fi

# save myself from the perils of ctrl-s in vim
stty -ixon

# fin!
