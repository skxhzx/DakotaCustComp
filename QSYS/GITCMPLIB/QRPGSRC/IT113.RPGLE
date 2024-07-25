      /COPY qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT113     Item maintenance - Copy
     *  27 July 1996
     *  Hemant Kapadia
     *
     *
     *  Revisions
219  *    03/10/97  RH   2.19
     *      - Add Extended item description ITEMDSC
411 A*    06/21/99  RH
     *      - Recompiled - ITEMLNK file changed.
650a *    03/25/13  KDE  6.50a
     *      - Added code to copy KITCOMP, KITITEM and ITEMFLD
     *      - Also converted to ILE
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit113fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Fpiritem   uf a e           k disk
     F                                     rename(itrec:record)
     Fitemdef   uf a e           k disk
     Fitemqty   o  a e           k disk
     Fitemlnk   uf a e           k disk
219 AFitemdsc   uf a e           k disk
650aAFkitcomp   uf a e           k disk
650aAFkititem   uf a e           k disk
650aAFitemfld   uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
219 AD  $pxflg                37     37
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtwh          c                   const('FRMTWH')
     D @fmtit          c                   const('FRMTIT')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritem                 1     15
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Variables
     *
     D $cdesc          s             30
     D $cstr           s             40
     D $cwhse          s              3  0
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s              1
     D fmsdef          s                   like(idsdef)
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D svactv          s                   like(itactv)
     D svbld           s                   like(itbld)
     D svbrd           s              1
     D svcat           s             10
     D svcitm          s             15
     D svcsov          s              1
     D svcube          s                   like(itcube)
     D svcwgt          s                   like(itcwgt)
     D svdesc          s                   like(itdesc)
     D svdesg          s                   like(itdesg)
     D svdisp          s             12
     D svdsc1          s             40
     D svdsc2          s             40
     D svflgb          s                   like(itflgb)
     D svflgd          s                   like(itflgd)
     D svflg1          s                   like(itflg1)
     D svflg2          s                   like(itflg2)
     D svitm2          s                   like(ilitm2)
     D svnday          s                   like(itnday)
     D svpdsc          s                   like(itpdsc)
     D svqty1          s              5  0
     D svqty2          s              5  0
     D svqty3          s              5  0
     D svrcv           s              1
     D svrcvd          s                   like(itrcvd)
     D svreor          s                   like(itreor)
     D svrepl          s                   like(itrepl)
     D svrptp          s             15
     D svslif          s                   like(itslif)
     D svslot          s             12
     D svslt           s              1
     D svstyp          s                   like(itstyp)
     D svswgt          s                   like(itswgt)
     D svtype          s                   like(ittype)
     D svuci           s              1
     D svuhgt          s                   like(ituhgt)
     D svulen          s                   like(itulen)
     D svumq2          s                   like(itumq2)
     D svumq3          s                   like(itumq3)
     D svum1           s                   like(itum1)
     D svum2           s                   like(itum2)
     D svum3           s                   like(itum3)
     D svupc           s                   like(itupc)
     D svuwdt          s                   like(ituwdt)
     D svven#          s                   like(itven#)
     D svvit#          s                   like(itvit#)
     D svwhdp          s                   like(itwhdp)
     D warn            s              1
     D w1fitm          s             15
     D w1fwhs          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *COPY    - Copy record to new record
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       616263
     C                   setoff                                       646566
     C                   setoff                                       676869
     C                   setoff                                       70
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     C                   exsr      zzdft1
     *
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so go home.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11202   Item number cannot be blank.
     *
     C     zm1202        begsr
     C                   eval      #msgid = 'IT11202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IT11301   Broken case item cannot be copied, if the full
     *             case item for it does not exist.
     *
     C     zm1301        begsr
     C                   eval      #msgid = 'IT11301'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1twhs
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *    Make sure item was entered.
     *
     C                   if        w1titm = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     C                   endif
     *
     *    Make sure item doesn't already exist.
     *
     C     tokey         chain(n)  record                             79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   exsr      zm02
     C                   endif
     *
     *    Broken case item cannot be copied, if Full case link item
     *    does not exist.
     *
     C                   if        ittype = 'B'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C     lnkey         chain     piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm1301
     C                   endif
     C                   endif
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 9
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = 0
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1twhs = $lwhse
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   Get warehouse description.
     *
     C                   eval      w1fwhs = $pwhse
     C                   eval      w1fmwh = *blanks
     C                   eval      $cstr = *blanks
     C     whkey         chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   movel     $pwhse        $cwhse
     *
     C                   eval      $cdesc = whdesc
     C                   eval      $cstr = *blanks
     C                   call      @fmtwh
     C                   parm                    $cwhse
     C                   parm                    $cdesc
     C                   parm                    $cstr
     C                   eval      w1fmwh = $cstr
     *
     *   Item description and pack description.
     *
     C                   eval      w1fitm = ititem
     C                   eval      w1fmit = *blanks
     C                   eval      $iitem = ititem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         w1fmit
     *
     C                   eval      w1twhs = $pwhse
     C                   eval      w1titm = ititem
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     C     fmkey         chain(n)  record                             7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     *
     *  Copy fields from 'FROM item' to 'TO item'.
     *
     C                   eval      svtype = ittype
     C                   eval      svdesc = itdesc
     C                   eval      svstyp = itstyp
     C                   eval      svwhdp = itwhdp
     C                   eval      svdesg = itdesg
     C                   eval      svactv = itactv
     C                   eval      svupc = itupc
     C                   eval      svbld = itbld
     C                   eval      svven# = itven#
     C                   eval      svvit# = itvit#
     C                   eval      svpdsc = itpdsc
     C                   eval      svum1 = itum1
     C                   eval      svum2 = itum2
     C                   eval      svumq2 = itumq2
     C                   eval      svflg1 = itflg1
     C                   eval      svum3 = itum3
     C                   eval      svumq3 = itumq3
     C                   eval      svflg2 = itflg2
     C                   eval      svulen = itulen
     C                   eval      svuwdt = ituwdt
     C                   eval      svuhgt = ituhgt
     C                   eval      svcube = itcube
     C                   eval      svswgt = itswgt
     C                   eval      svcwgt = itcwgt
     C                   eval      svreor = itreor
     C                   eval      svrepl = itrepl
     C                   eval      svflgd = itflgd
     C                   eval      svflgb = itflgb
     C                   eval      svslif = itslif
     C                   eval      svnday = itnday
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for item file. (From Item)
     *
     C     fmkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for item file. (To Item)
     *
     C     tokey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1titm
650aA*
650aA*  Define key for item file. (To Item)
650aA*
650aAC     tokit         klist
650aAC                   kfld                    w1twhs
650aAC                   kfld                    w1titm
650aAC                   kfld                    kccitm
     *
     *  Define key for item link file.
     *
     C     iltkey        klist
     C                   kfld                    w1twhs
     C                   kfld                    w1titm
     *
     *  Define key for item link file.
     *
     C     ilkey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1fitm
     *
     *  Define key for item file. (LINK Item)
     *
     C     lnkey         klist
     C                   kfld                    w1twhs
     C                   kfld                    ilitm2
     *
     *  Define key for Warehouse file. (From warehouse)
     *
     C     whkey         klist
     C                   kfld                    $pwhse
     *
     *  Define key for item quantity file. (To Item)
     *
     C     iqkey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1titm
     *
     *  Define partial key for item definition file. (From Item)
     *
     C     idkeyp        klist
     C                   kfld                    w1fwhs
     C                   kfld                    w1fitm
     *
     *  Define key for item definition file. (To Item)
     *
     C     idkey         klist
     C                   kfld                    w1twhs
     C                   kfld                    w1titm
     C                   kfld                    fmsdef
     *
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      w1fmwh = *blanks
     C                   endif
     *
     *   Get From Item.
     *
     C                   exsr      zzget1
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Add item record.
     *
     C                   eval      itwhse = w1twhs
     C                   eval      ititem = w1titm
     C     tokey         chain     record                             79
     C                   if        *in79
     C                   eval      ittype = svtype
     C                   eval      itdesc = svdesc
     C                   eval      itstyp = svstyp
     C                   eval      itwhdp = svwhdp
     C                   eval      itdesg = svdesg
     C                   eval      itactv = svactv
     C                   eval      itupc = svupc
     C                   eval      itbld = svbld
     C                   eval      itven# = svven#
     C                   eval      itvit# = svvit#
     C                   eval      itpdsc = svpdsc
     C                   eval      itum1 = svum1
     C                   eval      itum2 = svum2
     C                   eval      itumq2 = svumq2
     C                   eval      itflg1 = svflg1
     C                   eval      itum3 = svum3
     C                   eval      itumq3 = svumq3
     C                   eval      itflg2 = svflg2
     C                   eval      itulen = svulen
     C                   eval      ituwdt = svuwdt
     C                   eval      ituhgt = svuhgt
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
     C                   eval      itcwgt = svcwgt
     C                   eval      itreor = svreor
     C                   eval      itrepl = svrepl
     C                   eval      itflgd = svflgd
     C                   eval      itflgb = svflgb
     C                   eval      itslif = svslif
     C                   eval      itnday = svnday
     C                   write     record
     C                   endif
     *
     *  Add item quantity record.
     *
     C                   eval      iqwhse = w1twhs
     C                   eval      iqitem = w1titm
     C                   eval      iqstk1 = 0
     C                   eval      iqstk2 = 0
     C                   eval      iqstk3 = 0
     C                   eval      iqalc1 = 0
     C                   eval      iqalc2 = 0
     C                   eval      iqalc3 = 0
     C                   eval      iqhld1 = 0
     C                   eval      iqhld2 = 0
     C                   eval      iqhld3 = 0
     C                   eval      iqtri1 = 0
     C                   eval      iqtri2 = 0
     C                   eval      iqtri3 = 0
     C                   eval      iqtro1 = 0
     C                   eval      iqtro2 = 0
     C                   eval      iqtro3 = 0
     C                   eval      iqord1 = 0
     C                   write     iqrec
     *
     *  Add item definition record.
     *
     C     idkeyp        setll     itemdef                            79
     C                   move      *in79         eof
     C                   dow       eof = *off
     C     idkeyp        reade     itemdef                                79
     C                   move      *in79         eof
     C                   if        not *in79
     C                   eval      idwhse = w1twhs
     C                   eval      iditem = w1titm
     C                   write     idrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup1
     C                   endif
     C                   endif
     C                   enddo
     *
     *  Add item link record.
     *
     C                   if        ittype = 'B'
     C     ilkey         chain(n)  itemlnk                            79
     C                   eval      svitm2 = ilitm2
     C     iltkey        chain     itemlnk                            79
     C                   if        *in79
     C                   eval      ilwhse = w1twhs
     C                   eval      ilitem = w1titm
     C                   eval      ilitm2 = svitm2
     C                   write     ilrec
     C                   endif
     C                   endif
219 A*
219 A*   Add record to ITEMDSC file.
219 A*
219 AC                   if        $pxflg = '1'
219 AC     fmkey         chain     itemdsc                            79
219 AC                   if        not *in79
219 AC                   eval      svdsc1 = ixdsc1
219 AC                   eval      svdsc2 = ixdsc2
219 AC     tokey         chain     itemdsc                            79
219 AC                   if        *in79
219 AC                   eval      ixwhse = itwhse
219 AC                   eval      ixitem = ititem
219 AC                   eval      ixdsc1 = svdsc1
219 AC                   eval      ixdsc2 = svdsc2
219 AC                   write     ixrec
219 AC                   endif
219 AC                   endif
219 AC                   endif
650aA*
650aA*   Add record to KITCOMP file.
650aA*
650aAC     fmkey         setll     kitcomp
650aAC     fmkey         reade     kitcomp                                79
650aAC                   dow       not *in79
650aAC                   eval      svcitm = kccitm
650aAC                   eval      svdisp = kcdisp
650aAC                   eval      svqty1 = kcqty1
650aAC                   eval      svqty2 = kcqty2
650aAC                   eval      svqty3 = kcqty3
650aAC     tokit         chain     kitcomp                            77
650aAC                   if        *in77
650aAC                   movel     w1twhs        kcwhse
650aAC                   eval      kcitem = w1titm
650aAC                   eval      kccitm = svcitm
650aAC                   eval      kcdisp = svdisp
650aAC                   eval      kcqty1 = svqty1
650aAC                   z-add     svqty2        kcqty2
650aAC                   z-add     svqty3        kcqty3
650aAC                   write     kcrec
650aAC                   endif
650aAC     fmkey         reade     kitcomp                                79
650aAC                   enddo
650aA*
650aA*   Add record to KITITEM file.
650aA*
650aAC     fmkey         chain     kititem                            79
650aAC                   if        not *in79
650aAC                   movel     kirptp        svrptp
650aAC                   eval      svdisp = kidisp
650aAC                   eval      svqty1 = kiqty1
650aAC                   eval      svqty2 = kiqty2
650aAC                   eval      svqty3 = kiqty3
650aAC     tokey         chain     kititem                            79
650aAC                   if        *in79
650aAC                   movel     w1twhs        kiwhse
650aAC                   eval      kiitem = w1titm
650aAC                   movel     svrptp        kirptp
650aAC                   eval      kidisp = svdisp
650aAC                   z-add     svqty1        kiqty1
650aAC                   z-add     svqty2        kiqty2
650aAC                   z-add     svqty3        kiqty3
650aAC                   write     kirec
650aAC                   endif
650aAC                   endif
650aA*
650aA*   Add record to ITEMFLD file.
650aA*
650aAC     fmkey         chain     itemfld                            79
650aAC                   if        not *in79
650aAC                   eval      svcat = ifcat
650aAC                   eval      svcsov = ifcaseovf
650aAC                   eval      svslot = ifodrslot
650aAC                   eval      svuci = ifucicde
650aAC                   eval      svrcv = ifrcvmth
650aAC                   eval      svslt = ifsltmth
650aAC                   eval      svbrd = ifbrdflg
650aAC     tokey         chain     itemfld                            79
650aAC                   if        *in79
650aAC                   eval      ifwhse = w1twhs
650aAC                   eval      ifitem = w1titm
650aAC                   eval      ifcat = svcat
650aAC                   eval      ifcaseovf = svcsov
650aAC                   eval      ifodrslot = svslot
650aAC                   eval      ifucicde = svuci
650aAC                   eval      ifrcvmth = svrcv
650aAC                   eval      ifsltmth = svslt
650aAC                   eval      ifbrdflg = svbrd
650aAC                   write     ifrec
650aAC                   endif
650aAC                   endif
650aA*
     C     endup1        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item
