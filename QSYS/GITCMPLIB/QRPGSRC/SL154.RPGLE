610aA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  SL154     Verify zero slots - Verify
     *  14 October 1994
     *  Dave Sommerville
     *
     *  SK114 - 1.00
     *
     *  ***  THIS PROGRAM'S PROCESS WILL MIRROR SL160.  ***
     *
     *  Revisions
     *
404  *    09/04/97  RH      4.04
     *      - If Cross dock type, delete slot record and cross dock record.
     *
406  *    10/09/97  DAS     4.06
     *      - Revised to set reserved PIR slots back to 'A' instead of 'V'.
409  *    02/16/98  RH      4.09
     *      - If Virtual slot, delete slot record and vslot record.
409A *    07/06/98  RH      4.09
     *      - Can't verify slot if it has virtual slots tied to it.
412  *    09/02/99  RH      4.12
     *      - Fix IF statement for 409A change, was allowing verify.
414a *    07/28/00  RRH     4.14a
     *      - Revised to allow reserved PIR slots to go to 'V'.
414b *    09/05/00  RRH     4.14b
     *      - Revised to delete printed exception records VSLEXCP.
414cA*    09/20/00  DAS  4.14c
     *      - Now allowing a base slot to be verified even if it      d
     *        has a corresponding virtual slot.
     *
416 A*    02/18/02  DAS  4.16
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZS2D, ZZZCOP
     *
416bA*    06/11/02  DAS  4.16b
     *      - Changed A$LIC# from 7.0 to 15.
     *
510aA*    06/09/06  DAS  5.10a
     *      - Enh: Revised ZZUPD2 to call UPDSLTDTE.
     *
610aA*    12/12/09  DAS  6.10a
     *      - Converted to ILE
     *      - Replaced old DRI logic with ILE DRI logic.
     *      - Physically removed routeine ZZCHKD because it didn't
     *        do anything.
     *      - Removed all files.
     *      - Revised ZZUPD to just call DRISLOT with %ZEROVFY.
640aA*    04/12/11  RH   6.40a
     *      - Fix: Do not exit program if DRISLOT returns error
     *        INVLDSLOT for virutal slot, virutal was already verified
     *        if base slot was verified.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
610aDF*lot2     uf   e           k disk
610aDF*                                    rename(slrec:record)
610aDF*pclord   uf   e           k disk
610aDF*rossdk   uf   e           k disk
610aDF*slot1    uf   e           k disk
610aDF*slot2    if   e           k disk
610aDF*                                    rename(vsrec:vsrec2)
610aDF*slexcp   uf   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D msg             s             50    dim(1) ctdata perrcd(1)

610aA*----------------------------------------------------------------
610aA*  DRI parameters
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#DRIPARMS

610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA
610aA /COPY *libl/qcopysrc,C#SLOT
610aAD saveVer#        s                   like($slver#)

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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     *----------------------------------------------------------------
     *  Called programs
     *
610aDD*@cvtdt          c                   const('CVTDTE')
610aDD*@sltdt          c                   const('UPDSLTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
610aDD*$cvtdt          ds
610aDD* $cvcmd                 1      8
610aDD* $cvprg                 9     18
610aDD* $cvd6i                19     24
610aDD* $cvd8i                25     32
610aDD* $cvd6o                33     38  0
610aDD* $cvd8o                39     46  0
610aDD* $cvsto                47     64
610aDD* $cvrtn                65     72
610aDD* $cverm                73    132
610aDD* $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
610aA /Copy qcopysrc,c#pgminfds
610aDD*               sds
610aDD* #prog            *proc
610aDD* #job                 244    253
610aDD* #user                254    263
610aDD* #jobn                264    269
610aDD* #jobdt               276    281  0
610aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D ck4err          s              1
610aMD error           s               n
     D forevr          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
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
610aDC**   fileky        chain     record                             79
610aDC**                 if        not *in79
610aDC**                 exsr      zzdel
610aDC**                 exsr      zzchkv
610aDC**                 if        error = *off
     C                   exsr      zzupd
610aAC                   if        not error
     C                   exsr      zzok
610aAC                   endif
610aDC**                 else
610aDC**                 if        hasvs = *off
610aDC**                 exsr      zm75
610aDC**                 else
610aDC**                 exsr      zm22
610aDC**                 endif
610aDC**                 eval      $prtn = '*PGMQ   '
610aDC**                 endif
610aDC**                 endif
     C                   return
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
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*    DRI0001s Local system caused error (send to different program)
610aA*----------------------------------------------------------------
610aA
610aAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
610aA*----------------------------------------------------------------
610aA*      0105s
610aA*
610aAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     SL15421  Slot verified.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'SL15421'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
409aA*----------------------------------------------------------------
409aA*     SL15422  Slot not verified, has virtual slots attached.
409aA*
409aAC     zm22          begsr
409aAC                   eval      #msgid = 'SL15422'
409aAC                   eval      #msgtp = '*DIAG  '
409aAC                   movea     errmsg        $md(1)
409aAC                   exsr      zmsmsg
409aAC                   eval      $pmsg = #msgk
409aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDEL    Delete corresponding records.
     *
     C     zzdel         begsr
     C                   eval      error = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   eval      forevr = *off
610aDC**
610aDC** Define key for main file.
610aDC**
610aDC**   fileky        klist
610aDC**                 kfld                    $pwhse
610aDC**                 kfld                    $pwhdp
610aDC**                 kfld                    $pdisp
610aDC**
610aDC** Convert today's date into century format.
610aDC**
610aDC**                 eval      $cvcmd = '*CURCMD '
610aDC**                 call      @cvtdt
610aDC**                 parm                    $cvtdt
610aDC**                 eval      today = $cvd8o
610aDC**
610aDC**                 eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOK     Send back "successful" message.
     *
     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   movea     msg(1)        $md(1)
610aDC**                 movea     sldisp        $md(6)
610aMC                   movea     $pdisp        $md(6)
     C                   exsr      zm21
     C                   eval      $prtn = '*OK     '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
610aA
610aA*  Get user employee number
610aA
610aAC                   call      'GETUSER'
610aAC                   parm                    #curruser
610aAC                   parm      0             #whse             3 0
610aAC                   parm      0             #emp#             5 0
610aAC                   parm                    #fnam            15
610aAC                   parm                    #init             1
610aAC                   parm                    #lnam            20
610aAC                   parm                    #whdp             5
610aAC                   parm                    #styp             1
610aAC                   parm                    #shft             6
610aAC                   parm                    #crew             6
610aAC                   parm      0             #nhrs             3 1
610aAC                   parm                    #rtn              8
610aAC                   parm                    e$bpu             1
610aAC                   parm                    e$lng             2
610aA
610aA*   Call DRISLOT to do verification.
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = $pwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = $pWhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = $pdisp
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'ZVF'
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%ZEROVFY'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   exsr      zzzdricop
610aA
611eAC                   if        error
611eAC                   eval      $prtn = '*PGMQ'
611eAC                   endif
611eA
610aAC                   leavesr
610aA
610aA
610aDC**
610aDC**  Delete special order record(s).
610aDC**
610aDC**   fileky        setll     spclord
610aDC**                 dou       forevr <> forevr
610aDC**   fileky        reade     sprec                                7879
610aDC**                 if        *in79
610aDC**                 leave
610aDC**                 endif
610aDC**                 delete    sprec
610aDC**                 enddo
610aDC**
610aDC**  Delete Printed exception record(s).
610aDC**
610aDC**   fileky        chain     vslexcp                            79
610aDC**                 if        not *in79  and
610aDC**                           vxpdte <> 0
610aDC**                 delete    vxrec
610aDC**                 endif
610aDC**
610aDC**  Change status code.
610aDC**
610aDC**                 select
610aDC**
610aDC**     Cross Dock slots.
610aDC**
610aDC**                 when      slstyp = 'X'
610aDC**                 delete    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs2
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = '%DELETEX'
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**   fileky        setll     crossdk
610aDC**                 dou       forevr <> forevr
610aDC**   fileky        reade     cdrec                                7879
610aDC**                 if        *in79
610aDC**                 leave
610aDC**                 endif
610aDC**                 delete    cdrec
610aDC**                 enddo
610aDC**                 goto      endup
610aDC**
610aDC**     Virtual slots.
610aDC**
610aDC**                 when      slrsrv = 'V'
610aDC**                 delete    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs2
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = '%DELETEX'
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**   fileky        chain     vslot1                             79
610aDC**                 if        not *in79
610aDC**                 delete    vsrec
610aDC**                 endif
610aDC**                 goto      endup
610aDC**
610aDC**     All other types.
610aDC**
610aDC**                 other
610aDC**                 eval      slstat = 'V '
610aDC**                 eval      slitem = *blanks
610aDC**                 endsl
610aDC**                 eval      slsdte = today
610aDC**                 time                    slstim
610aDC**
610aDC**  Initialize dates, picking priority and quantities.
610aDC**
610aDC**                 eval      slentd = 0
610aDC**                 eval      slexpd = 0
610aDC**                 eval      slprty = 0
610aDC**                 eval      slstk1 = 0
610aDC**                 eval      slstk2 = 0
610aDC**                 eval      slstk3 = 0
610aDC**                 eval      slrcv1 = 0
610aDC**                 eval      slrcv2 = 0
610aDC**                 eval      slrcv3 = 0
610aDC**                 eval      slalc1 = 0
610aDC**                 eval      slalc2 = 0
610aDC**                 eval      slalc3 = 0
610aDC**                 eval      sltfr1 = 0
610aDC**                 eval      sltfr2 = 0
610aDC**                 eval      sltfr3 = 0
610aDC**                 eval      slpck1 = 0
610aDC**                 eval      slpck2 = 0
610aDC**                 eval      slpck3 = 0
610aDC**
610aDC**  Update record.
610aDC**
610aDC**                 update    record
610aDC**
610aDC**                 exsr      zzzs2d
610aDC**                 exsr      zzzfs1
610aDC**                 eval      dricmd = '*SLOT'
610aDC**                 eval      drisub = @vfysl
610aDC**                 eval      drirtn = @noupd
610aDC**                 eval      ck4err = *off
610aDC**                 exsr      zzzcop
610aDC**
610aDC**  Delete SLOTDTE records.
610aDC**
610aDC**                 call      @sltdt
610aDC**                 parm      '*DELETE'     $ucmd             8
610aDC**                 parm      #prog         $upgm            10
610aDC**                 parm      ' '           $upgm2           10
610aDC**                 parm      slwhse        $uwhse            3 0
610aDC**                 parm      slwhdp        $uwhdp            5
610aDC**                 parm      sldisp        $uslot           12
610aDC**                 parm      slpick        $upick            1
610aDC**                 parm      ' '           $uitem           15
610aDC**                 parm      ' '           $unewi           15
610aDC**                 parm      0             $uentd            8 0
610aDC**                 parm      0             $uexpd            8 0
610aDC**                 parm                    $uqty1            5 0
610aDC**                 parm                    $uqty2            5 0
610aDC**                 parm                    $uqty3            5 0
610aDC**                 parm                    $urtn             5 0
416 A*
404 MC     endup         endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105s

     C                   when      $drireturn <> '*OK'
640aAC                             and $drireturn <> 'INVLDSLOT'
     C                   eval      error = *on
     C                   exsr      zm0001s

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   endsl

     C     enddricop     endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Slot
