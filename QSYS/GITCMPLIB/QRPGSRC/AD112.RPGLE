     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     F*
     F*  AD112     Inventory adjustment code maintenance - Change
     F*  21 June 1993
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
416 AF*    10/29/01  DAS  4.16
     F*      - Added file ADJMISC.
     F*      - Added new 'System to Update' field.
     F*
416aAF*    12/27/01  DAS  4.16a
     F*      - Removed ability to enter 'H' for system to update.
     F*        Re: Programs that allow adjustments have not been
     F*            modified to check for this code.
     F*
510 AF*    06/15/06  RMC  5.10
     F*      - Enh: Display Packers verion of SCREEN.
     F*             Add logic to determine if Packers is accessing
     F*             this program.
     F*
510bAF*    09/19/06  RAH  5.10b
     F*      - Enh: Add additional fields from SAPMOVE file to screen
     F*
600aAF*    02/23/09  DAS  6.00a  P#00045
     F*      - Enh: Revised so codes that start witn '@' must be
     F*             defined as Dakota only. These are normally system
     F*             codes. This was implemented for code @R which is
     F*             used in PO144 when delete a Receiving tran and
     F*             removing the qty from the corresponding RCV slot.
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
     fad112fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     fadjcode   uf a e           k disk
     f                                     rename(adrec:record)
416 Afadjmisc   uf a e           k disk
510  fsapmove1  uf a e           k disk
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     d a10             s              1    dim(10)
416 DD**                  DESC    1   1 20
510 MD*416                DESC    1   2 20
510  d desc            s             20    dim(3) ctdata perrcd(1)
600aDd*msg             s             50    dim(1) ctdata perrcd(1)
600aMd msg             s             50    dim(2) ctdata perrcd(1)
510  D*
510   /COPY QCOPYSRC,ID#PACKERS
     d @getcl          c                   const('GETCLIENT')
     D*----------------------------------------------------------------
     D*  Program parameters
     D*
     d $parms          ds
     d  $pcmd                  1      8
     d  $pprg                  9     18
     d  $puky                 19     68
     d  $prtn                 69     76
     d  $perm                 77    136
     d  $pmsg                 77     80
     D*
     D*   Redefine key
     D*
     d  $pcode                19     20
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     d @cvtdt          c                   const('CVTDTE')
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     d $cvtdt          ds
     d  $cvdop                 1      8
     d  $cvdd6                 9     14  0
     d  $cvdd8                15     22  0
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
     C*      $PCMD   *ADD     - Create new batch.
     C*              *EDIT    - Edit batch.
     C*              *DELETE  - Delete batch.
     C*              *PRINT   - Print batch edit listing.
     C*              *POST    - Post batch.
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key for everything by *ADD.
     C*
     C*    Returned Parameters
     C*      $PUKY   Contains new batch number for *ADD.
     C*              Unchanged for everything else.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     c     *entry        plist
     c                   parm                    $parms
     C*----------------------------------------------------------------
     C*  Main line
     C*
     c                   move      *on           *in97
     c                   move      *off          *in90
     c                   move      *off          *in91
     c                   move      *off          error
     c                   move      *blanks       $prtn
     c                   move      *blanks       $perm
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
510  c                   select
510  c     client        wheneq    packers
510  c                   exfmt     scrpck1
510 Ac                   other
     c                   exfmt     screen1                              50
510 Ac                   endsl
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
     C*
     C*  Get field defaults if this is an add.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   exsr      zzdft1
     c                   else
     C*
     C*  Otherwise get existing record(s).
     C*
     c                   move      *on           *in91
     c                   exsr      zzget1
     c                   exsr      zzfil1
     c                   end
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
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*EXIT   '    $prtn
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F5 - Refresh
     C*
     c     *inke         ifeq      *on
     c     $pcmd         ifne      '*VIEW   '
     c                   exsr      scr01i
     c                   end
     c                   goto      endsc1
     c                   end
     C*
     C*  Test for F12 - Previous
     C*
     c     *inkl         ifeq      *on
     c     *loval        setll     record
     c                   move      'EOJ'         nxtscr
     c                   move      '*CANCEL '    $prtn
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
     c     $pcmd         ifeq      '*ADD    '
     c     $pcmd         oreq      '*CHANGE '
     c                   exsr      zzchk1
     c     error         cabeq     *on           endsc1
     c                   exsr      zzupd
     c     error         cabeq     *on           endsc1
     c                   end
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
510 AC*
510 AC* Get client id.
510 AC*
510 Ac                   call      @getcl
510 Ac                   parm                    client           10
510 AC*
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
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     c     zmsmsg        begsr
     c     $msgf         ifeq      *blanks
     c                   move      #msgf         $msgf            10
     c                   end
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
     c                   move      *blanks       #msgdt
     c                   move      *blanks       $msgf
     c                   endsr
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*   PIR0201  Code must be entered for create.
     C*
     c     zm01          begsr
     c                   move      'PIR0201'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR0202  Code already exists.
     C*
     c     zm02          begsr
     c                   move      'PIR0202'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     desc          errmsg
     c                   movea     errmsg        $md(1)
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7971  Error in writing a record.
     C*
     c     zm71          begsr
     c                   move      'PIR7971'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*   PIR7972  Error in updating a record.
     C*
     c     zm72          begsr
     c                   move      'PIR7972'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   move      *blanks       $md
     c                   exsr      zmpmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*     PIR7973  Slot record does not exist.
     C*
     c     zm73          begsr
     c                   move      'PIR7973'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
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
     C*     PIR7974  Slot record is locked.
     C*
     c     zm74          begsr
     c                   move      'PIR7974'     #msgid
     c                   move      '*DIAG  '     #msgtp
     c                   movea     errmsg        $md(1)
     c                   exsr      zmsmsg
     c                   move      #msgk         $pmsg
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZCHK1   Screen 1 error checking.
     C*
     c     zzchk1        begsr
     c                   move      *off          error
     C*
     C*  When adding ....
     C*
     c     $pcmd         ifeq      '*ADD    '
     C*
     C*    Make sure code was entered.
     C*
     c     w1code        ifeq      *blanks
     c                   move      *on           error
     c                   move      *on           *in21
     c                   exsr      zm01
     c                   end
     C*
     C*    Make sure code doesn't already exist.
     C*
     c                   move      w1code        $pcode
     c     fileky        chain     record                             79
     c     *in79         ifeq      *off
     c                   move      *on           error
     c                   move      *on           *in21
     c                   exsr      zm02
     c                   end
     c                   end
416 AC*
416 AC*   Verify system.
416 AC*
416 Ac     w1sys         ifne      'D'
416 Ac     w1sys         andne     'H'
416 Ac     w1sys         andne     'B'
416 Ac                   move      *on           error
416 Ac                   move      *on           *in23
416 Ac                   move      *on           *in03
416 Ac                   movel(p)  desc(2)       errmsg
416 Ac                   exsr      zm1001
416 Ac                   endif
416aAC*
416aAC*   Disable 'H' because it is not implemented throughout system.
416aAC*
416aAc     w1sys         ifeq      'H'
416aAc                   move      *on           error
416aAc                   move      *on           *in23
416aAc                   move      *on           *in03
416aAc                   movel(p)  msg(1)        errmsg
416aAc                   exsr      zm0105
416aAc                   endif
600aAC*
600aAC*   Codes that start with '@' must be Dakota only.
600aAC*     These are normally system codes. For example, this was
600aAC*     implemented for code @R which is used in PO144 when
600aAC*     deleting a receiving transaction and removing the qty
600aAC*     from the corresponding RCV slot.
600aAC*
600aAc                   if        %subst(w1code:1:1) = '@'
600aAc                             and w1sys <> 'D'
600aAc                   move      *on           error
600aAc                   move      *on           *in23
600aAc                   move      *on           *in03
600aAc                   movel(p)  msg(2)        errmsg
600aAc                   exsr      zm0105
600aAc                   endif
510  C*
510  C*    Make sure Stock Indicator is Y or N for Packers.
510  C*
510  c     client        ifeq      packers
510  c     w1stck        ifne      'Y'
510  c     w1stck        andne     'N'
510  c                   move      *on           error
510  c                   move      *on           *in24
510  c                   move      *on           *in04
510  c                   movel(p)  desc(3)       errmsg
510  c                   exsr      zm1001
510  c                   endif
510  c                   endif
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
     c                   move      *blanks       w1code
     c                   move      *blanks       w1desc
416 Ac                   move      'B'           w1sys
510  c     client        ifeq      packers
510  c                   move      *blanks       w1sapc
510  c                   move      *blanks       w1move
510  c                   move      *blank        w1stck
510bAc                   z-add     *zero         w1cost
510bAc                   z-add     *zero         w1prft
510  c                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL1   Fill screen 1 fields with info from file.
     C*
     c     zzfil1        begsr
     c                   move      adcode        w1code
     c                   move      addesc        w1desc
416 AC*
416 AC*  Get info from the ADJMISC file.
416 AC*
416 Ac     fileky        chain(n)  adjmisc                            78
416 Ac     *in78         ifeq      *off
416 Ac                   move      admsys        w1sys
416 Ac                   else
416 Ac                   move      'B'           w1sys
416 Ac                   endif
510 AC*
510 AC*  Get info from the SAPMOVE file.
510 AC*
510  c     client        ifeq      packers
510 Ac     fileky        chain(n)  sapmove1                           78
510 Ac     *in78         ifeq      *off
510 Ac                   movel     smsapc        w1sapc
510 Ac                   movel     smmove        w1move
510 Ac                   move      smindc        w1stck
510bAc                   z-add     smcost        w1cost
510bAc                   z-add     smprft        w1prft
510 Ac                   else
510 Ac                   move      *blanks       w1sapc
510 Ac                   move      *blanks       w1move
510 Ac                   move      *blanks       w1stck
510bAc                   z-add     *zero         w1cost
510bAc                   z-add     *zero         w1prft
510 Ac                   endif
510 Ac                   endif
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZGET1   Get record(s) for screen 1.
     C*
     c     zzget1        begsr
     C*
     C*   Get record from main file.
     C*
     c     fileky        chain     record                             7978
     C*
     C*  Record locked.
     C*
     c     *in78         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm74
     c                   goto      endgt2
     c                   end
     C*
     C*  Record not found.
     C*
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   move      '*PGMQ   '    $prtn
     c                   exsr      zm73
     c                   goto      endgt2
     c                   end
     C*
     C*   If viewing, release record.
     C*
     c     $pcmd         ifeq      '*VIEW   '
     c                   move      *on           *in90
     c     *loval        setll     record
     c                   end
     c     endgt2        endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     c     zzinz         begsr
     C*
     C*  Define key for main file.
     C*
     c     fileky        klist
     c                   kfld                    $pcode
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     c     zzinz2        begsr
     C*
     C*   Select first screen to display.
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   move      *blanks       $pcode
     c                   end
     c                   exsr      scr01i
     c                   endsr
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Update record.
     C*
     c     zzupd         begsr
     c                   move      *off          error
     C*
     C*  Move screen fields to record fields
     C*
     c                   move      w1code        adcode
     c                   move      w1desc        addesc
     C*
     C*
     C*   Add record
     C*
     c     $pcmd         ifeq      '*ADD    '
     c                   write     record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm71
     c                   goto      endupd
     c                   end
     c                   else
     C*
     C*   -OR- Update record (it was read and locked in ZZGET2)
     C*
     c                   update    record                               79
     c     *in79         ifeq      *on
     c                   move      *on           error
     c                   exsr      zm72
     c                   goto      endupd
     c                   end
     c                   end
416 AC*
416 AC*   Add/Change record to ADJMISC file.
416 AC*
416 Ac     fileky        chain     adjmisc                            79
416 Ac     *in79         ifeq      *off
416 Ac                   move      w1sys         admsys
416 Ac                   update    admrec
416 Ac                   else
416 Ac                   move      adcode        admcod
416 Ac                   move      w1sys         admsys
416 Ac                   write     admrec
416 Ac                   endif
     C*
510  C*
510  C*   Add/Change record for Packers
510  C*
510  c     client        ifeq      packers
510  c     fileky        chain     sapmove1                           79
510  c     *in79         ifeq      *off
510  c                   movel     w1sapc        smsapc
510  c                   movel     w1move        smmove
510  c                   move      w1stck        smindc
510bAc                   z-add     w1cost        smcost
510bAc                   z-add     w1prft        smprft
510  c                   update    spmrec
510  c                   else
510  c                   move      w1code        smbfcc
510  c                   movel     w1sapc        smsapc
510  c                   movel     w1move        smmove
510  c                   move      w1stck        smindc
510bAc                   z-add     w1cost        smcost
510bAc                   z-add     w1prft        smprft
510  c                   write     spmrec
510  c                   endif
510  c                   endif
     C*
     C*   Move key values to parameters
     C*
     c                   move      adcode        $pcode
     c     endupd        endsr
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
**
Adjustment Code
System to update
Stock Indicator
**
'H' not allowed at this time.
Only 'D' is allowed for an '@' code.
