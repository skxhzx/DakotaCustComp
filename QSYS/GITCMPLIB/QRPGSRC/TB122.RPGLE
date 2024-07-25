     H copyright('(c) Copyright BFC Software, Inc - 2010')
     H option(*nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 Washington Ave North #203
     *   Batavia, IL  60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TB122     RF - Tote and Bundle Count maintenance
     *  09 April 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *      16 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    04/09/10  RBD  5.30
     *      - Created.
     *
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions - Finkle
     *
FDI A*    04/26/10  RBD  FDI
     *      - Call label printing pgm twice so that two labels
     *        will print.
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
     Ftb122fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Flblfmtd   if   e           k disk
     Fpltsum15  if   e           k disk
     Ftotebund  uf   e           k disk    prefix(tb_)
     Ftotebund1 uf   e           k disk
     F                                     rename(tbrec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(4) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     D*
      /COPY QCOPYSRC,ID#FINKLE
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#STDVAR

     *----------------------------------------------------------------
     *  Working variables
     *
     D @lblset         s              6
     D @plfmtl         c                   const('PALLET ')
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
     D completed       s              1
     D DONE            s              1
     D E               s              2  0
     D EXCPTN          s              1
     D FOREVR          s              1
     D HELP            s              5  0
     D lblcnt          s              1  0
     D MORE            s              1
     D MSGK            s              4  0
     D NXTSCR          s              3
     D REDSPL          s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
     D svwhse          s              3  0
     D today           s              8  0
     D $pcmd           s              8
     D $plbl#          s              7  0
     D $pqty           s              5  0
     D $ldoor2         s             15  5
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @prtpg1         c                   const('TB300')
     D @prtpg2         c                   const('TB310')
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
     D  $lrtid                22     26
     D  $ltrn#                27     33  0
     D  $lwhdp                34     38
     D  $ldoor                39     41p 0
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
     D  erfld                  1     30
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
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen61                             50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     *
     C                   when      nxtscr = '02 '
     C                   select
     C                   when      #lline =  '16'
     C                   exfmt     screen62                             50
     C                   other
     C                   exfmt     screen2                              50
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
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
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
     C                   eval      refrsh = *off
     C                   move      '01 '         nxtscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Initialize special keys
     *
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
     *----------------------------------------------------------------
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
     *    Verify transaction entered.
     *
     C                   If        w1trn# <= 0
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(1)       errmsg
     C                   exsr      zm0110
     C                   Endif
     *
     C                   If        w1trn# >= 0
     *
     *    Verify transaction exists.
     C     fileky        chain     totebund1
     C                   Select
     C                   When      not %found(totebund1)
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(2)       errmsg
     C                   exsr      zm0105
     *
     C                   When      %Found(totebund1)
     *
     *    Transaction already closed.
     C                   if        tbstat = '4'
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     desc(3)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     C                   Endsl
     *
     C                   Endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
     *
     C     endck2        endsr
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
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1trn# = *zeros
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     C                   eval      w2trn# = w1trn#
     *
     C                   eval      w2szon = tbszon
     C                   eval      w2qtot = tbqtot
     C                   eval      w2qbun = tbqbun
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGet2   Get screen 2 data.
     *
     C     zzget2        begsr
     *
     C     endgt2        Endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C     *loval        setll     lblfmtd
     C                   dou       %eof(lblfmtd)
     C                   read      lblfmtd
     C                   if        not %eof(lblfmtd)
     C                   if        lfdfmt = @plfmtl
     C                   eval      @lblset = lfdset
     C                   leave
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   move      *off          forevr
     *
     C                   endsr
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
     *  Define key for PLTSUM15.
     *
     C     keyPS15       klist
     C                   kfld                    tbwhse
     C                   kfld                    tbrtid
     C                   kfld                    tbmpl#
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1trn#
     *
     *  Define full key for TOTEBUND.
     *
     C     keyTB         klist
     C                   kfld                    tbwhse
     C                   kfld                    tbrtid
     C                   kfld                    tbmpl#
     C                   kfld                    tbszon
     *
     *  Define partial key for TOTEBUND.
     *
     C     keyTBx        klist
     C                   kfld                    tbwhse
     C                   kfld                    tbrtid
     C                   kfld                    tbmpl#
     *
     C                   exsr      scr01i
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPRT   Check to see if all tote and bundle records for this
     *          pallet have been completed, and if so, go print the pallet
     *          label and the Palletizer report.
     *
     C     zzPrt         begsr
     *
     C                   eval      completed = *on
     *
     C     keyTBx        setll     totebund
     C                   dow       forever = forever
     C     keyTBx        reade(n)  totebund
     C                   select
     C                   when      %eof(totebund)
     C                   leave
     C                   other
     C                   if        tb_tbstat <> '4'
     C                   eval      completed = *off
     C                   leave
     C                   endif
     C                   endsl
     *
     C                   enddo
     *
     C                   if        completed = *on
     C                   exsr      zzprt1
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPRT1  Print pallet label and Palletizer report.
     *
     C     zzPrt1        begsr
     *
     *  Print Palletizer report.
     C                   call      @prtpg1
     C                   parm                    tbwhse
     C                   parm                    tbrtid
     C                   parm                    tbmpl#
     *
     *  Print pallet label.
     *
     *     Get pallet number.
     C     keyPS15       chain     pltsum15
     C                   if        not %found(pltsum15)
     C                   eval      pspal# = 0
     C                   endif
     *     Get dock door for the transaction.
     C                   eval      $lwhse = w1whse
     C                   eval      $lrtid = tbrtid
     C                   eval      $ltrn# = tbtrn#
     C                   eval      $lwhdp = *blanks
     C                   eval      $ldoor = 0
     C                   call      'DH900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*OK     '
     C                   eval      $ldoor = 0
     C                   endif
     *
     C                   select
FDI AC                   when      client = finkle
FDI AC                   eval      lblcnt = 2
     C                   other
     C                   eval      lblcnt = 1
     C                   endsl
     *
     C                   do        lblcnt
     C                   call      @prtpg2
     C                   parm      '*PALLET '    $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmtl       $plfmt            8
     C                   parm      tbwhse        $pwhse            3 0
     C                   parm      pspal#        $pal#             7 0
     C                   parm      tbrte         $prte             5
     C                   parm      tbmpl#        $plid             7 0
     C                   parm      tbrtid        $rtid             5
     C                   parm      tbcomp        $pcomp            1
     C                   parm      $ldoor        $ldoor2
     C                   parm      'ZEBRAPRT1'   $pdev            10
     C                   parm      '*STD'        $pform           10
     C                   enddo
     *
     C                   call      @prtpg2
     C                   parm      '*DONE'       $pcmd             8
     C                   parm      *blanks       $plset            6
     C                   parm      *blanks       $plfmt            8
     C                   parm      *zeros        $pwhse            3 0
     C                   parm      *zeros        $pal#             7 0
     C                   parm      *blanks       $prte             5
     C                   parm      *zeros        $plid             7 0
     C                   parm      *blanks       $rtid             5
     C                   parm      *blanks       $pcomp            1
     C                   parm      *zeros        $ldoor
     C                   parm      *blanks       $pdev            10
     C                   parm      *blanks       $pform           10
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDZONE   Update tote and bundle records for this pallet and
     *              zone, marking them complete.
     *
     C     zzUpdZone     begsr
     *
     C     keyTB         setll     totebund
     C                   dow       forever = forever
     C     keyTB         reade     totebund
     C                   select
     C                   when      %eof(totebund)
     C                   leave
     C                   other
     C                   eval      tb_tbstat = '4'
     C                   time                    tb_tbstst
     C                   eval      tb_tbstsd = today
     C                   eval      tb_tbuser = #user
     C                   update    tbrec
     C                   unlock    totebund
     C                   endsl
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     *
     C                   move      *off          error
     *
     *         On to screen 2...
     C                   exsr      scr02i
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     *
     C                   move      *off          error
     C                   eval      tbqtot = w2qtot
     C                   eval      tbqbun = w2qbun
     C                   time                    tbstst
     C                   eval      tbstsd = today
     C                   eval      tbuser = #user
     *
     C                   Update    Record
     C                   unlock    totebund1
     *
     C                   If        %Error
     C                   eval      error = *on
     C                   Eval      errmsg = desc(4) + ' ' +
     C                               %trim(%editc(w1trn#: '4'))
     C                   exsr      zm7872
     C                   else
     *
     *  If F1 ...
     C                   if        *inka
     *  Update tote and bundles recs for this pallet and zone.
     C                   exsr      zzUpdZone
     *  Check to see if all recs for this pallet have now
     *  been closed, and if so, print rpt and label.
     C                   exsr      zzPrt
     C                   endif
     *
     C                   Eval      errmsg = 'Trn' + ' ' +
     C                             %trim(%editc(w1trn#: '4')) + ' updated.'
     C                   exsr      zm0105
     C                   exsr      scr01i
     C                   Endif
     *
     C     endupd2       endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Transaction number
Invalid transaction
Trans already closed
Trans not updated
