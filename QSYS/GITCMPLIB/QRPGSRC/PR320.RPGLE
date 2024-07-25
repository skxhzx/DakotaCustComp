      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PR320   Print Breakdown priority replenishments - Options
     *  Dave Sommerville
     *  27 October 2004
     *
     *  Revisions
     *
500 A*    10/27/04  DAS  5.00
     *      - Created.
500aA*    12/09/04  MLB  5.00a
     *      - Enh: Revised program to use file SLOT1 instead of
     *        LAYOUTH for aisle verification. LAYOUTH not a reliable
     *        source for aisle verification.
500bA*    03/06/05  MLB  5.00b
     *      - Enh: Revised program to add replenishment type to
     *        options screen.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  City Line Custom Mods.
     *
     *  All City Line custom mods should be conditioned with ...
     *     'if client = cityline'
     *  or 'client  cabne  cityline  skipcityline1'
     *  or 'select / when client = cityline / other / endsl'
     *
CLDaA*     10/29/04  DAS  CLDa
     *       - Defaulted label program to PFMTZBRCTL.
CLDbA*     11/18/04  HNK  CLDb
     *       - Defaulted label printing device to ZEBRA4
CLDcA*     10/11/13  DAS  CLDc
     *       - Defaulted label program to PFMTZBRCT2.
     *
     *----------------------------------------------------------------
     *  Donson's Custom Mods.
     *
DON A*     03/09/05  MLB  DON
     *       - Defaulted label program to PLST40WS.
     *       - Defaulted label printing device to CP01.
     *
     *----------------------------------------------------------------
     *  Saval Custom Mods.
     *
SVLaA*     01/28/14  JCJ  SVLa
     *       - Defaulted label program to PFMTZBRSVL.
     *       - Defaulted label printing device to ZEBRA1.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpr320fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
500aDF*layouth   if   e           k disk
500aAFslot1     if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             60    dim(7) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
CLDaA /copy qcopysrc,id#citylin
DON A /copy qcopysrc,id#donsons
SVLaA /copy qcopysrc,id#saval
     D client          s             10

     *----------------------------------------------------------------
     *  Error message parameter
     *----------------------------------------------------------------

     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

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
     D  $lwhdp                22     26
     D  $lsdef                22     23

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     *                                                                   GFG
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *                                                                   GFG
     D  eraisl                 1      4
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D cmdtkn          s              1
     D e               s              2  0
     D error           s              1
     D msgk            s              4  0
     D nxtscr          s              3
     D pos             s              3  0
     D sclear          s              1
     D warn            s              1
     D wkwhse          s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $WHSE            - Warehouse number
     *      $WHDP            - Warehouse department
     *      $RPLT            - Replenishment type
     *                          ' ' = Normal.
     *                          'B' = Breakdown.
     *                          'F' = Flowrack.
     *      $NRPL            - *ALL or number of replenishments
     *      $AISL            - Aisle to replenish
     *      $JOBQ            - Put on a job que (Y,N)
     *      $LPGM            - Label program
     *      $DEV             - Printer device
     *      $FORM            - Printer form
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $whdp             5
     C                   parm                    $rplt             1
     C                   parm                    $nrpl             3
     C                   parm                    $aisl             4
     C                   parm                    $prtn             8
     C                   parm                    $jobq             1
     C                   parm                    $lpgm            10
     C                   parm                    $dev             10
     C                   parm                    $form            10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
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
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
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
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
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
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Number must be greater than zero
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------   GFG
     *   PIR0112  Invalid range entered.                                 GFG
     *                                                                   GFG
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------   GFG
     *   PIR0122  Invalid aisle entered for replenishments.              GFG
     *                                                                   GFG
     C     zm0122        begsr
     C                   eval      #msgid = 'PIR0122'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

     *  Verify warehouse code.

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
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

     *  Verify warehouse department.

     C***                if        w1whdp <> '*ALL'
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C***                endif

     *  Validate number of replenishments entered

     C                   if        w1nrpl <= 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = 'Number of Replenishments'
     C                   exsr      zm0110
     C                   endif

     *  Validate aisle entered by user.

     C                   if        w1aisl <> '*ALL'
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm      w1aisl        $cstr            30
     C                   move      $cstr         w1aisl
500aDC*                  move      $cstr         lhaisl
500aMC                   move      $cstr         slaisl
500aDC*    keylh         setll     lhrec                                  79
500aMC     keysl         setll     slrec                                  79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   eval      eraisl = w1aisl
     C                   exsr      zm0122
     C                   endif
     C                   endif
500bA
500bA*  Verify replenishment type.
500bA
500bAC                   if        w1rplt <> 'N'  and
500bAC                             w1rplt <> 'B'  and
500bAC                             w1rplt <> 'F'
500bAC                   eval      error = *on
500bAC                   eval      *in29 = *on
500bAC                   eval      *in09 = *on
500bAC                   eval      errmsg = 'Replenishment type'
500bAC                   exsr      zm1001
500bAC                   endif

     *  Verify jobq option

     C                   if        w1jobq <> 'Y'  and
     C                             w1jobq <> 'N'
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = 'Job queue option'
     C                   exsr      zm1001
     C                   endif

     *  Validate printer device.

     C                   if        %subst(w1dev:1:1) = '*'
     C                             and w1dev <> '*SYSVAL'
     C                             and w1dev <> '*JOB'
     C                             or  w1dev = ' '
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = 'Printer device'
     C                   exsr      zm1001
     C                   endif

     *  Validate form type

     C                   if        %subst(w1form:1:1) = '*'
     C                             and w1form <> '*STD'
     C                             or  w1form = ' '
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = 'Form type'
     C                   exsr      zm1001
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off

     *  Test for F4 - Lookup

     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin

     *     Warehouse.

     C                   select
     C                   when      row# = 8
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif

     *     Warehouse department.

     C                   when      row# = 9
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif

     C                   other

     *     Cursor not on a valid lookup field.

     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif

     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
210 A
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0

     C                   eval      w1whdp = 'DRY'
409 MC                   eval      w1nrpl = 0
     C                   eval      w1aisl = '*ALL'
500bAC                   eval      w1rplt = 'N'
     C                   eval      w1jobq = 'N'
     C                   select
CLDaAC                   when      client = cityline
500bAC                   eval      w1rplt = 'B'
CLDcD ***                eval      w1lpgm = 'PFMTZBRCTL'
CLDcMC                   eval      w1lpgm = 'PFMTZBRCT2'
CLDcAC                   eval      w1jobq = 'Y'
CLDb C                   eval      w1dev  = 'ZEBRA4'
DON AC*
DON AC                   when      client = donsons
DON AC                   eval      w1lpgm = 'PLST40WS  '
DON AC                   eval      w1dev  = 'CP01  '
DON AC*
SVLaAC                   when      client = saval
SVLaAC                   eval      w1rplt = 'N'
SVLaAC                   eval      w1lpgm = 'PFMTZBRSVL'
SVLaAC                   eval      w1dev  = 'ZEBRA1'
SVLaAC*
     C                   other
     C                   eval      w1lpgm = 'PFMTPLBL40'
CLDb C                   eval      w1dev  = '*JOB'
     C                   endsl
     C                   eval      w1form = '*STD'

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     C                   eval      $lprg = #prog

500aDC*    keylh         klist
500aMC     keysl         klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
500aDC*                  kfld                    lhaisl
500aMC                   kfld                    slaisl

      *  Get client id

     C                   call      'GETCLIENT'
     C                   parm                    client

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Select first screen to display.

     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *----------------------------------------------------------------

     C     zznxt1        begsr

     C                   move      w1whse        $whse
     C                   eval      $whdp = w1whdp
500bAC                   select
500bAC                   when      w1rplt = 'N'
500bAC                   eval      $rplt = ' '
500bAC                   when      w1rplt = 'B'
     C                   eval      $rplt = 'B'
500bAC                   when      w1rplt = 'F'
500bAC                   eval      $rplt = w1rplt
500bAC                   endsl
     C                   move      w1nrpl        $nrpl
     C                   eval      $aisl = w1aisl
     C                   eval      $jobq = w1jobq
     C                   eval      $lpgm = w1lpgm
     C                   eval      $dev  = w1dev
     C                   eval      $form = w1form

     C                   eval      nxtscr = 'EOJ'
     C                   endsr
** Description array







