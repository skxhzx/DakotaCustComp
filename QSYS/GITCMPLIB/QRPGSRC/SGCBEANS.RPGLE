      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SGCBEANS   Special SGC program called from IT252
     *  08 June 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
600 A*    06/08/09  DAS  6.00
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    When SGC first started, some OSS labels were assigned
     *    correctly. The end result is that 2 pallets ended up with
     *    the same OSSKANSAS slot number.
     *
     *    The ones that were received incorrectly were all for
     *    item 076406 Pork & Beans Fancy. All the pallets ended up
     *    going into RCV slots, then had to be manually transferred
     *    to OSSKANSAS slots.
     *
     *    Now, when these slot numbers come back into the warehouse
     *    we have to ask the user if they are working with the
     *    beans. If they are, we change the slot number, otherwise
     *    we leave it alone.
     *
     *    Also, DRISLOT has been revised to not use these slot numbers
     *    any more.
     *
     *----------------------------------------------------------------

     F*----------------------------------------------------------------
     F*  File Specs
     F*
     fsgcbeansfmcf   e             workstn
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

417qA*----------------------------------------------------------------
417qA*  Variables
417qA*----------------------------------------------------------------

     D temp3a          s              3
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $pdisp  Slot from IT252
     C*
     C*    Returned Parameters
     C*      $pdisp  Slot to use
     C*      $popt   Option Y/N
     C*              blank = F3/F12 pressed
     C*              X     = Not a messed up OSS slot.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $pdisp           12
     c                   parm                    $popt             1
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   move      *blanks       $popt
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
416 Ac                   setoff                                       010203
510  c                   setoff                                       04
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
     c                   exsr      zzdft1
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
     c                   move      'EOJ'         nxtscr
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
416 AC*----------------------------------------------------------------
416 AC*   PIR0105  Generic message.
416 AC*
416 Ac     zm0105        begsr
416 Ac                   move      'PIR0105'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   movea     errmsg        $md(1)
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
416 AC*----------------------------------------------------------------
416 AC*   PIR1001  Invalid value entered.
416 AC*
416 Ac     zm1001        begsr
416 Ac                   move      'PIR1001'     #msgid
416 Ac                   move      '*DIAG  '     #msgtp
416 Ac                   movea     errmsg        $md(1)
416 Ac                   exsr      zmpmsg
416 Ac                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
416 AC*
416 AC*   Verify option.
416 AC*
416 Ac     w1opt         ifne      'Y'
416 Ac     w1opt         andne     'N'
416 Ac                   move      *on           error
416 Ac                   move      *on           *in21
416 Ac                   move      *on           *in01
416 Ac                   eval      errmsg = 'Yes/No Option'
416 Ac                   exsr      zm1001
416 Ac                   endif
      *
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
     c                   eval      w1opt = ' '
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

     c*  Return if not working with an OSSKANSAS slot.

     c                   if        %subst($pdisp:1:9) <> 'OSSKANSAS'
     c                   eval      $popt = 'X'
     c                   eval      nxtscr = 'EOJ'
     c                   leavesr
     c                   endif

     c*  Return if not one of the messed up OSSKANSAS slots.

     c                   eval      temp3a = %subst($pdisp:10:3)
     c                   if        temp3a <> '2EY'
     c                             and temp3a <> '2EZ'
     c                             and temp3a <> '2FA'
     c                             and temp3a <> '2FE'
     c                             and temp3a <> '2GO'
     c                             and temp3a <> '2GP'
     c                             and temp3a <> '2KE'
     c                             and temp3a <> '2KK'
     c                             and temp3a <> '2KT'
     c                             and temp3a <> '2KU'
     c                             and temp3a <> '2QP'
     c                             and temp3a <> '2QW'
     c                             and temp3a <> '2WW'
     c                             and temp3a <> '2WX'
     c                             and temp3a <> '2WY'
     c                             and temp3a <> '2WZ'
     c                   eval      $popt = 'X'
     c                   eval      nxtscr = 'EOJ'
     c                   leavesr
     c                   endif

     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error

     c                   eval      $popt = w1opt

     c                   if        $popt = 'N'
     c                   leavesr
     c                   endif

     C*   If we are dealing with 076406 Beans,
     C*     Then send back manually assigned slot.

     c                   select
     c                   when      temp3a = '2EY'
     c                   eval      $pdisp = 'OSSKANSAS2IZ'
     c                   when      temp3a = '2EZ'
     c                   eval      $pdisp = 'OSSKANSAS2KF'
     c                   when      temp3a = '2FA'
     c                   eval      $pdisp = 'OSSKANSAS2KG'
     c                   when      temp3a = '2FE'
     c                   eval      $pdisp = 'OSSKANSAS2KM'
     c                   when      temp3a = '2GO'
     c                   eval      $pdisp = 'OSSKANSAS2KN'
     c                   when      temp3a = '2GP'
     c                   eval      $pdisp = 'OSSKANSAS2KO'
     c                   when      temp3a = '2KE'
     c                   eval      $pdisp = 'OSSKANSAS2LY'
     c                   when      temp3a = '2KK'
     c                   eval      $pdisp = 'OSSKANSAS2LZ'
     c                   when      temp3a = '2KT'
     c                   eval      $pdisp = 'OSSKANSAS2MA'
     c                   when      temp3a = '2KU'
     c                   eval      $pdisp = 'OSSKANSAS2MB'
     c                   when      temp3a = '2QP'
     c                   eval      $pdisp = 'OSSKANSAS2MC'
     c                   when      temp3a = '2QW'
     c                   eval      $pdisp = 'OSSKANSAS2PH'
     c                   when      temp3a = '2WW'
     c                   eval      $pdisp = 'OSSKANSAS2PI'
     c                   when      temp3a = '2WX'
     c                   eval      $pdisp = 'OSSKANSAS2QQ'
     c                   when      temp3a = '2WY'
     c                   eval      $pdisp = 'OSSKANSAS2QR'
     c                   when      temp3a = '2WZ'
     c                   eval      $pdisp = 'OSSKANSAS2QX'
     c                   endsl

     c     endupd        endsr
