      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   NOTE: THIS IS NOT A NORMAL SCREEN PROGRAM
     *         $PARMS is not used, no $pcmd is sent in, etc ...
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  MF125     Manufacturer code decipher - test
     F*  26 Sept 2007
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
     F*    09/26/07  DAS  5.10
     F*      - Created
510aAF*    10/02/07  LMC  5.10a
     F*      - Fix: Correct manufacturer field size to 11 positions
510bAF*    10/03/07  LMC  5.10b
     F*      - Enh: Added parm to retrieve definition type
520aA*    02/13/07  LMC  5.20a
     *      - Fix: Added blank parms on cal to CVTMFRDTE to correct
     *        pointer error
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  01 - 20   Field position to
     F*  21 - 40   Field input error (reverse display)
     F*  90        View mode (Protect input fields)
     F*  91        Change mode (protect key)
     F*  97        Error message subfile indicator
     F*  98        Error on screen (sound buzzer)
     F*  99        Universal record indicator (very temporary usage)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fmf125fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     d $mdt            ds
     d  errmsg                 1     50
     D*
     d  erpo#                  1      5p 0
     d  eritem                 6     20
     d                 ds
     d  $ec                    1      2p 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     d #msgf           c                   const('PIRMSGF   ')
     D*
     d                 ds
     d  #msgdt                 1    128
     d  $md                    1    128
     d                                     dim(128)
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     d                sds
     d  #prog            *proc
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0
     D*----------------------------------------------------------------
     D*  Workstation exception data structure
     D*
     d infds           ds
     d  status           *status
     d  rowin                370    370
     d  colin                371    371
     D*----------------------------------------------------------------
     D*  Workstation exception redefinition data structure
     D*
     d                 ds
     d  row#                   1      2b 0
     d  row                    2      2
     d  col#                   3      4b 0
     d  col                    4      4
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $pMfr#     - Mfr #
     C*      $pMfrDef#  - Mfr definition #
     C*      $pMfrItem  - Mfr item number
     C*      $pDktItem  - Dakota item number
     C*
     C*    Returned Parameters
     C*      none
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
510aDC*                  parm                    $pMfr#           10 0
510aAC                   parm                    $pMfr#           11 0
     C                   parm                    $pMfrDef#         2 0
     C                   parm                    $pMfrItem        15
     C                   parm                    $pDktItem        15
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   exsr      zzinz2
     c     error         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   end
     C*
     c     nxtscr        downe     'EOJ'
     c                   exsr      dspscr
     c     nxtscr        caseq     '01 '         sc1
     c                   end
     c                   end
     C*
     C*   Do some clean up before leaving.
     C*
     c                   exsr      zsclr
     c                   return
     C*----------------------------------------------------------------
     C*  DSPSCR - Display screen
     C*
     c     dspscr        begsr
     C*
     C*   Set ON alarm indicator if error occured
     C*
     c     error         ifeq      *on
     c                   move      *on           *in98
     c                   end
     C*
     C*   Overlay screen with error messages
     C*
     c                   exsr      zmdmsg
     C*
     C*  Overlay screen with screen to be processed.
     C*
     c     nxtscr        ifeq      '01 '
     c                   exfmt     screen1                              50
     c                   end
     C*
     C*   Initialize error indicators and fields
     C*
     c                   setoff                                       010203
     c                   setoff                                       04
     c                   setoff                                       212223
     c                   setoff                                       242526
     c                   setoff                                       272829
     c                   setoff                                       30
     c                   setoff                                       98
     c                   move      *off          warn              1
     c                   move      *off          error             1
     c                   move      *off          cmdtkn            1
     c                   z-add     0             e                 2 0
     C*
     C*   Initialize error subfile
     C*
     c                   exsr      zmcmsg
     C*
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*     Screen initialization and wrap-up routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  Screen 01 initialization
     C*
     c     scr01i        begsr
     c                   move      '01 '         nxtscr            3
     c                   move      *on           *in91
     c                   exsr      zzfil1
     c     end01i        endsr
     C*----------------------------------------------------------------
     C*
     C*              Screen Processing Routines
     C*
     C*----------------------------------------------------------------
     C*
     C*  SC1  -  Screen 1
     C*
     c     sc1           begsr
     C*
     C*  Test for F3 - Exit
     C*
     c     *inkc         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c                   exsr      scr01i
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c                   move      'EOJ'         nxtscr
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for other command keys
     C*
     c                   exsr      zzcmd1
     c     cmdtkn        cabeq     *on           endsc1
     C*
     C*  Some other key pressed.
     C*
     C*     Check input and write/update record.
     C*
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     C*
     c     endsc1        endsr
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     c     *inzsr        begsr
     C*
     C*  Initialize special keys
     C*
     c                   z-add     0             enter             5 0
     c                   z-add     2             comand            5 0
     c                   z-add     01122         rollup            5 0
     c                   z-add     01123         rolldn            5 0
     c                   z-add     01124         clear             5 0
     c                   z-add     01125         help              5 0
     C*
     C*  Initialize message handling
     C*
     c                   exsr      zmimsg
     C*
     C*   Call user added initialization routine.
     C*
     c                   exsr      zzinz
     c                   endsr
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMCMSG  Clear message record subfile
     C*
     c     zmcmsg        begsr
     c                   move      *off          *in97
     c                   write     msgctl
     c                   z-add     *zero         msgk              4 0
     c                   write     msgclr
     c                   move      '*CLEAR '     #msgid            7
     c                   move      '*NULL  '     #msgtp            7
     c                   exsr      zmpmsg
     c                   endsr
     C*
     C*    ZMDMSG  Display message record subfile
     C*
     c     zmdmsg        begsr
     c                   move      *on           *in97
     c     msgk          ifgt      0
     c                   write     msgctl
     c                   z-add     *zero         msgk
     c                   end
     c                   endsr
     C*
     C*    ZMIMSG  Initialization necessary for message subfile
     C*
     c     zmimsg        begsr
     c                   move      #prog         #pgmq            10
     c                   exsr      zmcmsg
     c                   endsr
     C*
     C*    ZMPMSG  Add message record to subfile
     C*
     c     zmpmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
     c     #msgid        ifne      '*CLEAR '
     c                   add       1             msgk
     c                   write     msgrec
     c                   end
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*
     C*    ZSCLR   Clear screen
     C*
     c     zsclr         begsr
     c                   write     clrscr
     c                   move      *on           sclear            1
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0105  Generic message.
     C*
     c     zm0105        begsr
     c                   move      'PIR0105'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR1001  Invalid value entered.
     C*
     c     zm1001        begsr
     c                   move      'PIR1001'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     c     endck1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCMD1   User defined command keys for screen 1.
     C*
     c     zzcmd1        begsr
     c     endcm1        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZDFT1   Get default values for add.
     C*
     c     zzdft1        begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr

     c                   eval      w1Mfr#    = $pMfr#
     c                   eval      w1MfrDef# = $pMfrDef#
     c                   eval      w1MfrItem = $pMfrItem
     c                   eval      w1DktItem = $pDktItem

     c                   eval      w1Code    = ' '
     c                   eval      w1DateCMD = 0
     c                   eval      w1Msg     = ' '

     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Select first screen to display.
     C*
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error

     C                   call      'CVTMFRDTE'
     C                   parm      ' '           $dCmd            10
     C                   parm      w1code        $dCode           30
510aDC*                  parm      w1mfr#        $dMfr#           10 0
510aAC                   parm      w1mfr#        $dMfr#           11 0
     C                   parm      w1mfritem     $dMfrItem        15
     C                   parm      w1dktitem     $dDktItem        15
     C                   parm      w1mfrdef#     $dMfrDef#         2 0
     C     w1datecmd     parm      0             $dDateCMD         8 0
     C                   parm      0             $dDateMDY         6 0
     C                   parm      ' '           $dReturn         10
     C     w1msg         parm      ' '           $dMsg            60
     C                   parm      ' '           $ddeftype         1
520aAC                   parm      ' '           $dupc            20

     c     endupd        endsr
