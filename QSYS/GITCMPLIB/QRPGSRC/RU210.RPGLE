     H copyright('(c) Copyright BFC Software, Inc - 2004')
     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RU210     RF - Runner Flag Assignment
     *  30 April 2004
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *      16 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    04/30/04  MLB  4.17
     *      - Created.
417aA*    08/12/04  MLB  4.17a
     *      - Enh: Revised program to send message to user when new
     *        RUNNER task has been assigned. Added file OPTIONS to
     *        program.
417bA*    08/12/04  MLB  4.17b
     *      - Enh: Revised program to retrieve printer defaults
     *        when displaying pop-up window.
417cA*    08/19/04  MLB  4.17c
     *      - Enh: Revised program to add support for client custom
     *        modifications.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions for Cheney Brothers.
     *
CBI A*    05/07/04  MLB  CBI
     *      - Revised routine ZZINZ2 to set printer defaults
     *        based on department selected.
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
     Fru210fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     FLabel     if a e           k disk
417aAFoptions   if   e           k disk
     Fpiritem   if   e           k disk
     Fpiruser1  if   e           k disk
     Frunner    uf   e           k disk
     Frunner1   uf   e           k disk
     F                                     rename(rurec:rurec1)
     F
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(12) ctdata perrcd(1)
417aAD cmdsndm         s             50    dim(3) ctdata perrcd(1)
417cA*----------------------------------------------------------------
417cA*  Customer id
417cA*
417cA /COPY QCOPYSRC,ID#CHENEY
417aA*
417aA*----------------------------------------------------------------
417aA*  *GENPICK -  General picking.
417aA*----------------------------------------------------------------
417aA*
417aA* Fields
417aA*
417aA*    OPERPT  -  Print exception (short) error report (Y,N).
417aA*    OPELBL  -  Print exception (short) labels (Y,N).
417aA*    OPRFWC  -  Using RF will call (Y,N).
417aA*    OPNRSC  -  Number of pallet sections (1-9).
417aA*    OPHPWC  -  Host pick Will Call (Y/N).
417aA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
417aA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
417aA*    OPEADJ  -  Close short labels without adjustment (Y,N).
417aA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
417aA*    OPCLRF  -  Clear runner flags if qty still short/out? (Y/N)
417aA*    OPRNRM  -  Send message to user when new RUNNER task ready?
417aA*               (Y/N)
417aA*
417aA* Data structure
417aA*
417aAD opdta1          DS
417aAD  OPERPT                 1      1
417aAD  OPELBL                 2      2
417aAD  OPRFWC                 3      3
417aAD  OPNRSC                 4      4  0
417aAD  OPHPWC                 5      5
417aAD  OPMRGA                 6      6
417aAD  OPPLSQ                 7      7
417aAD  OPEADJ                 8      8
417aAD  OPNOPK                 9      9
417aAD  OPCLRF                10     10
417aAD  OPRNRM                11     11
417aAD  OPTEND               117    117
417aA*
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Working variables
     *
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
     D DONE            s              1
     D E               s              2  0
     D ENTER           s              5  0
     D ERROR           s              1
     D EXCPTN          s              1
     D FOREVR          s              1
     D HELP            s              5  0
     D MORE            s              1
     D MSGK            s              4  0
     D NXTSCR          s              3
     D REDSPL          s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
     D tlpcs           s              7  0
     D tlswgt          s             11  2
     D tlcube          s             11  3
     D WARN            s              1
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
     D @adjtd          c                   const('ADJTSKDET')
     D @adjtr2         c                   const('ADJTRAN2 ')
417aA*
417aA*----------------------------------------------------------------
417aA* Status message(s)
417aAD sts04           c                   const('Flag task ready for pickup.')
417aA*
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhsea               19     21
     D  $lcode                22     27
     *
     D  $ltrn#                22     28  0
     D  $ltrn#a               22     28
     D  $ldev                 29     38
     D  $lform                39     48
     *
     *----------------------------------------------------------------
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     D currstamp       s               z
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     *
     D  erqty                  1      4p 0
     D  ernqty                 5      8p 0
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      zzinz2
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   Eval      *inlr = *on
     *
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
     C                   select
     C                   when      nxtscr = '01 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen61                             50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen62                             50
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     *
     C                   when      nxtscr = '03 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen63                             50
     C                   other
     C                   exfmt     screen3                              50
     C                   endsl
     *
     C                   when      nxtscr = '04 '
     *
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen64                             50
     C                   other
     C                   exfmt     screen4                              50
     C                   endsl
     *
     C                   endsl
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
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   move      '01 '         nxtscr
     C                   exsr      zzfil1
417aAC                   exsr      zzgetop
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
     *
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
     *
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
     C                   move      'EOJ'         nxtscr
     *
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     *
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   If        W2nrsn > 0
     C                   Exsr      Zzabort
     C                   Endif
     *
     C                   If        Error = *off
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   Endif
     *
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   If        W2nrsn > 0
     C                   Exsr      Zzabort
     C                   Endif
     *
     C                   If        Error = *off
     C                   eval      refrsh = *off
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     C                   endif
     *
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   move      '02 '         nxtscr
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      '02 '         nxtscr
     C                   exsr      scr02i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   move      '02 '         nxtscr
     C                   exsr      scr02i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C     redspl        cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
417cA*
417cA* Get client id.
417cA*
417cAC                   call      'GETCLIENT'
417cAC                   parm                    client           10
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
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
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
     C                   eval      msgk = *zeros
     *
     C                   if        #lline = '16'
     C                   write     m16clr
     *
     C                   else
     C                   write     msgclr
     C                   endif
     *
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     *
     C                   if        #lline = '16'
     C                   write     m16ctl
     *
     C                   else
     C                   write     msgctl
     C                   endif
     *
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
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endif
     *
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     *
     C                   if        #lline = '16'
     C                   write     m16rec
     *
     C                   else
     C                   write     msgrec
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110  Number must be > 0
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR7872  Record not updated in file.
     *
     C     zm7872        begsr
     C                   move      'PIR7872'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify employee number entered.
     *
     C                   If        w1emp# <= 0
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     C                   If        w1emp# >= 0
     C     W1emp#        chain     Piruser1
     C                   Select
     C                   When      not %found(Piruser1)
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(2)       errmsg
     C                   exsr      zm0105
     *
     C                   endsl
     C                   endif
     *
     *  Verify default device
     *
     C                   If        %subst(w1dev:1:1) = '*'
     C                             and w1dev <> '*SYSVAL'
     C                             and w1dev <> '*JOB'
     C                             or  w1dev = *blanks
     C                   eval      error  = *on
     C                   eval      *in24  = *on
     C                   eval      *in04  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(11)
     C                   exsr      zm1001
     C                   Endif
     *
     *  Verify default form type
     *
     C                   If        %subst(w1form:1:1) = '*'
     C                             and w1form <> '*STD'
     C                             or  w1form = *blanks
     C                   eval      error  = *on
     C                   eval      *in25  = *on
     C                   eval      *in05  = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(12)
     C                   exsr      zm1001
     C                   Endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Verify label number entered.
     *
     C                   If        w2lbl# <  0
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(3)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     C                   If        w2lbl# >  0
     C     W2lbl#        chain     Label
     C                   Select
     C                   When      not %found(Label)
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(3)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Label)
     *
     *    Label not flagged yet.
     C                   Select
     C                   When      Lbvrfy <> 'F'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(4)       errmsg
     C                   exsr      zm0105
     *
     *    Label already closed.
     C                   When      Lbstat = 'C'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(5)       errmsg
     C                   exsr      zm0105
     *
     C                   Endsl
     *
     *    Retrieve Flag file record.
     C     W2lbl#        chain (n) Runner
     C                   Select
     C                   When      not %found(Runner)
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(4)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(Runner)
     *
     *    Flag record has been picked.
     C                   Select
     C                   When      Rustat = 'P'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(7)       errmsg
     C                   exsr      zm0105
     *
     *    Flag record already closed.
     C                   When      Rustat = 'C'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     DESC(6)       errmsg
     C                   exsr      zm0105
     *
     *    Flag record at open status.
     C                   Other
     *
     C                   Endsl
     *
     C                   Endsl
     *
     C                   Endsl
     C                   Endif
     *
     C     endck2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     *
     C                   Exsr      Zzchk2
     *
     *    Qty short/out must be greater than zero.
     *
     C                   If        w3qyso <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     DESC(9)       errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     *    Qty short/out can't be greater than original pick qty.
     C                   If        w3qyso >  lbqpck
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     DESC(10)      errmsg
     C                   exsr      zm0105
     C                   Endif
     *
     C     endck3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   move      *off          error
     *
     *
     C     endck4        endsr
     *
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
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
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
     *
     C                   endif
     *
     C     endcm1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     *
     C                   endif
     *
     C     endcm4        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1emp# = *zeros
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2emp# = usemp#
     C                   eval      w2lnam = uslnam
     C                   eval      w2lbl# = 0
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3lbl# = w2lbl#
     *
     C                   eval      $iitem = lbitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr  = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   movel     $istr         woitem
     *
     C                   eval      w3qyso = 0
     C                   eval      w3ucod = lbucod
     *
     C     endfl3        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGet2   Get  PIR employee master record.
     *
     C     zzget2        begsr
     *
     C     w1emp#        chain     piruser1
     C                   if        Not %found
     C                   eval      usemp# = 0
     C                   eval      usfnam = ' '
     C                   eval      uslnam = ' '
     C                   endif
     *
     C     endgt2        Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZGet3   Get  PIR item master record.
     *
     C     zzget3        begsr
     *
     C     Itkey         chain     piritem
     C                   if        Not %found
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     *
     C     endgt3        Endsr
417aA*
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZGETOP  Get General Picking Options record.
417aA*
417aAC     zzgetop       begsr
417aA*
417aAC                   MOVE      '*GENPICK'    opcode
417aA*
417aAC     opkey         chain     options
417aAC                   if        not %found(options)
417aAC                   eval      opclrf = 'Y'
417aAC                   eval      oprnrm = 'N'
417aAC                   else
417aAC                   movel     opdata        opdta1
417aAC                   endif
417aA*
417aAC                   endsr
417aA*
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   move      *off          forever           1
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    rulbl#
417aA*
417aA*  Define key for OPTIONS file.
417aA*
417aAC     opkey         klist
417aAC                   kfld                    w1whse
417aAC                   kfld                    opcode
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    lbitem
     *
     *  Define key for RUNNER1 file.
     *
     C     rukey         klist
     C                   kfld                    w1whse
     C                   kfld                    svtrn#
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get screen size being used.
     *
     C                   Call      'PIRRFSCR'
     C                   parm      '*GET'        #LCMD             8
     C                   parm                    #LLINE            2
     C                   parm                    #LCOL             3
     *
     C                   move      *on           refrsh
     C                   move      *off          more
     C                   move      *off          done
     C                   move      *off          excptn
     C     *like         define    lbtrn#        svtrn#
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     *
     C                   eval      w1whse = #whse
     *
417bA*       Retrieve default printer device.
417bAC                   call      'GETRPT'
417bAC                   parm      '*DEVFORM'    $cmd              8
417bAC                   parm      'RU365PR'     $lprt            10
417bAC                   parm      w1whse        $whse             3 0
417bAC                   parm      ' '           $styp             1
417bAC                   parm      ' '           $whdp             5
417bAC                   parm      ' '           $desc            50
417bAC                   parm      ' '           $dev             10
417baC                   parm      ' '           $form            10
     *
CBI AC                   select
CBI AC                   when      client = cheney
CBI A*
CBI A*    Set printer defaults.
CBI AC                   select
CBI AC                   when      #whdp = 'DRY  '
CBI AC                   eval      w1dev = 'LP08     '
CBI A*
CBI AC                   when      #whdp    = 'FRZ  '
CBI AC                             or #whdp = 'CLR  '
CBI AC                   eval      w1dev = 'LP26       '
CBI A*
CBI AC                   Endsl
CBI AC                   eval      w1form = '*STD      '
     *
CBI AC                   other
417bA*
417bAC                   if        $dev > ' '
417bAC                   eval      w1dev  = $dev
417bAC                   eval      w1form = $form
417bAC                   else
     C                   eval      w1dev  = '*JOB       '
     C                   eval      w1form = '*STD       '
417bAC                   endif
     *
CBI AC                   endsl
     *
     C                   exsr      scr01i
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZABORT  Abort runner pick list transaction created.
     *
     C     zzabort       begsr
     *
     C                   move      *off          error
     *
     C     rukey         setll     Runner1
     C                   Dow       Forever = Forever
     C     rukey         reade     Runner1
     C                   Select
     C                   When      %eof(runner1)
     C                   Leave
     *
     C                   Other
     *         Set item to Picked status.
     C                   eval      Rustat = 'O'
     C                   Eval      Rupdts = *loval
     C                   Update    Rurec1
     C                   If        %Error
     C                   Eval      Error  = *on
     C                   Eval      errmsg = DESC(8) + ' ' +
     C                               %trim(%editc(rulbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
     C                   Endsl
     C                   Enddo
     *
     *
     *         Close Runner Transaction.
     C                   Call      @adjtr2
     C                   Parm      '*CLOSE    '  $Pcmd            10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      svtrn#        $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      W1whse        $Pwhse            3 0
     C                   Parm      Lbwhdp        $pwhdp            5
     C                   Parm      Lbstyp        $pstyp            1
     C                   Parm      0             $pcube            9 3
     C                   Parm      0             $pswgt            9 2
     C                   Parm      0             $ppcs             5 0
     C                   Parm      0             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      lbrte         $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
     C                   Parm      #user         $puser           10
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   if        $Prtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     C                   endsr
417aA*
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZSNDMSG Position to record
417aA*
417aAC     zzsndmsg      begsr
417aA*
417aA*    SNDBRKMSGU MSGTXT(msg text) USRPRF(user id) msgtyp(*info)
417aA*
417aAC                   eval      qcmd = %trim(cmdsndm(1)) + %trim(sts04) +
417aAC                             %trim(cmdsndm(2)) + %trim(uscode) +
417aAC                             cmdsndm(3)
417aA*
417aAC                   call (e)  'QCMDEXC'
417aAC                   parm                    qcmd            200
417aAC                   parm      200           qlen             15 5
417aA*
417aAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   move      *off          error
     *
     *         On to screen 2...
     C                   eval      w2llbl = 0
     C                   eval      w2nrsn = 0
     C                   eval      Tlpcs  = 0
     C                   eval      Tlswgt = 0
     C                   eval      Tlcube = 0
     *
     *         Create Runner Transaction number.
     C                   Call      @adjtr2
     C                   Parm      '*CRTSTRT  '  $Pcmd            10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      0             $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      W1whse        $Pwhse            3 0
     C                   Parm      '     '       $pwhdp            5
     C                   Parm      ' '           $pstyp            1
     C                   Parm      0             $pcube            9 3
     C                   Parm      0             $pswgt            9 2
     C                   Parm      0             $ppcs             5 0
     C                   Parm      1             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      '     '       $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
     C                   Parm      #user         $puser           10
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   if        $Prtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     C                   If        Error = *off
417aA*
417aA*  Get picking options for warehouse.
417aAC                   exsr      zzgetop
417aA*
     C                   Eval      Svtrn# = $ptrn#
     C                   exsr      scr02i
     C                   Endif
     *
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     *
     C                   move      *off          error
     *
     C                   Select
     *    Proceed to third screen. Confirm label rcd for printing.
     C                   When      Error = *off and W2lbl# > 0
     C                   exsr      scr03i
     *    Proceed to forth screen. Confirm printing of Runner Pick Sheet.
     C                   When      Error = *off and W2lbl# = 0 and
     C                             tlpcs > 0
     C                   exsr      scr04i
     *    Proceed to first screen. No shorts/outs entered by user.
     C                   When      Error = *off and W2lbl# = 0 and
     C                             tlpcs <= 0
     C                   exsr      scr01i
     C                   Endsl
     *
     C     endupd2       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 2.
     *
     C     zzupd3        begsr
     *
     C                   move      *off          error
     *
     C     W2lbl#        chain     Runner
     C                   If        Not %found(Runner)
     C                   eval      error  = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     *
     C                   Else
     *
     C                   Eval      TLpcs  = Tlpcs  + w3qyso
     C                   eval      TLswgt = Tlswgt + (w3qyso * lbuwgt)
     C                   eval      TLcube = Tlcube + (w3qyso * lbucub)
     *
     C                   Eval      Ruqyso = w3qyso
     C                   Eval      Rutrn# = Svtrn#
     *
     C                   Update    Rurec
     C                   If        %Error
     C                   move      *on           error
     C                   Eval      errmsg = DESC(8) + ' ' +
     C                               %trim(%editc(w2lbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
     C                   Endif
     *
     *    Return to second screen. Scan next label number.
     C                   If        Error = *off
     *
     C                   Eval      W2llbl = W2lbl#
     C                   Eval      W2nrsn = W2nrsn + 1
     C                   exsr      scr02i
     C                   Endif
     *
     C     endupd3       endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     *
     C                   move      *off          error
     *
     C                   time                    currstamp
     C     rukey         setll     Runner1
     C                   Dow       Forever = Forever
     C     rukey         reade     Runner1
     C                   Select
     C                   When      %eof(runner1)
     C                   Leave
     *
     C                   Other
     *         Set item to Picked status.
     C                   eval      Rustat = 'P'
     C                   Eval      Rupdts = Currstamp
     C                   Update    Rurec1
     C                   If        %Error
     C                   Eval      Error  = *on
     C                   Eval      errmsg = DESC(8) + ' ' +
     C                               %trim(%editc(rulbl#: 'X'))
     C                   exsr      zm7872
     C                   Endif
     C                   Endsl
     C                   Enddo
     *
     *         Update Runner Transaction totals.
     *
     C                   If        Error = *off
     C                   Call      @adjtr2
     C                   Parm      '*INCTTL   '  $Pcmd
     C                   Parm      #Job          $Pprg
     C                   Parm      '*INTER  '    $Ptype
     C                   Parm      svtrn#        $Ptrn#
     C                   Parm      'RUNNER'      $Ptask
     C                   Parm      W1whse        $Pwhse
     C                   Parm      ' '           $pwhdp
     C                   Parm      ' '           $pstyp
     C                   Parm      tlcube        $pcube
     C                   Parm      tlswgt        $pswgt
     C                   Parm      tlpcs         $ppcs
     C                   Parm      0             $paisl
     C                   Parm      0             $pqty1
     C                   Parm      0             $pqty2
     C                   Parm      0             $pqty3
     C                   Parm      ' '           $prte
     C                   Parm      ' '           $ppo
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
     C                   Parm      #user         $puser           10
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   if        $Prtn = '*ERROR  '
     C                   move      *on           error
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
417aA*
417aAC                   else
417aA*
417aA*         Send break message to Flag Runner if Yes.
417aAC                   if        oprnrm = 'Y'
417aAC                   exsr      zzsndmsg
417aAC                   endif
417aA*
     C                   endif
     C                   endif
     C                   endif
     *
     *         Close Runner Transaction.
     C                   If        Error = *off
     C                   Call      @adjtr2
     C                   Parm      '*CLOSE    '  $Pcmd            10
     C                   Parm      #Job          $Pprg            10
     C                   Parm      '*INTER  '    $Ptype            8
     C                   Parm      svtrn#        $Ptrn#            7 0
     C                   Parm      'RUNNER'      $Ptask            6
     C                   Parm      W1whse        $Pwhse            3 0
     C                   Parm      ' '           $pwhdp            5
     C                   Parm      ' '           $pstyp            1
     C                   Parm      0             $pcube            9 3
     C                   Parm      0             $pswgt            9 2
     C                   Parm      0             $ppcs             5 0
     C                   Parm      1             $paisl            5 0
     C                   Parm      0             $pqty1            5 0
     C                   Parm      0             $pqty2            5 0
     C                   Parm      0             $pqty3            5 0
     C                   Parm      ' '           $prte             5
     C                   Parm      ' '           $ppo              9
     C                   Parm      ' '           $pgrp1            1
     C                   Parm      ' '           $pgrp2            1
     C                   Parm      0             $pdate            8 0
     C                   Parm      0             $ptime            6 0
     C                   Parm      #user         $puser           10
     C                   Parm      ' '           $prtn             8
     C                   Parm      ' '           $pmsg             4
     *
     C                   if        $Prtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $Prtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     C                   endif
     *
     *
     *         Print Runner Pick Sheet.
     C                   If        Error = *off
     C                   eval      $lwhsea = %editc(w1whse:'X')
     C                   eval      $ltrn#a = %editc(svtrn#:'X')
     C                   Call      'RU360CL'
     C                   Parm      '*PRINT  '    $lcmd
     C                   Parm                    $lwhsea
     C                   Parm                    $ltrn#a
     C                   Parm      w1dev         $ldev
     C                   Parm      w1form        $lform
     C                   Parm      *blanks       $lrtn
     *
     *         Return to Starting display.
     C                   Exsr      Scr01i
     C                   Endif
     *
     C     endupd4       endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Employee number
Invalid employee#
Invalid label#
Lbl not flagged.
Lbl already closed.
Flag rcd closed.
Flag being picked.
Label number
Short/out qty <= 0.
Qty > Pick qty.
Printer device
Form type
** Send break message to user
sndbrkmsgu msgtxt('
') usrprf(
) msgtyp(*info)
