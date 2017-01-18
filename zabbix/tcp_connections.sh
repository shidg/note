#!/bin/bash
#scripts for tcp status 
function SYNRECV { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'SYN-RECV' | awk '{print $2}'
} 
function ESTAB { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'ESTAB' | awk '{print $2}'
} 
function FINWAIT1 { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-1' | awk '{print $2}'
} 
function FINWAIT2 { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-2' | awk '{print $2}'
} 
function TIMEWAIT { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'TIME-WAIT' | awk '{print $2}'
} 
function LASTACK { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LAST-ACK' | awk '{print $2}'
} 
function LISTEN { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LISTEN' | awk '{print $2}'
} 
function CLOSED { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'CLOSED' | awk '{print $2}'
} 
function SYN_SENT { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'SYN_SENT' | awk '{print $2}'
} 
function CLOSE_WAIT { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'CLOSE_WAIT' | awk '{print $2}'
} 
function CLOSING { 
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'CLOSING' | awk '{print $2}'
} 
case $1 in
   SYNRECV)
          SYNRECV
        ;;
  ESTAB)
         ESTAB
        ;;
  FINWAIT1)
          FINWAIT1
        ;;
  FINWAIT2)
          FINWAIT2
        ;;
  TIMEWAIT)
          TIMEWAIT
        ;;
  LASTACK)
          LASTACK
        ;;
  LISTEN)
         LISTEN
        ;;
#  CLOSED)
#         CLOSED
#        ;;
#  SYN_SENT)
#         SYN_SENT
#        ;;
#  CLOSE_WAIT)
#         CLOSE_WAIT
#        ;;
#  CLOSING)
#         CLOSING
#        ;;
       *)
          exit 1
        ;;
esac
