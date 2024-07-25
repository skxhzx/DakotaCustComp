      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKMULTI    Check for multiple transactions (EPM version)
     *  29 December, 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *    12/29/09  GJA  5.30
     *      - Created
     *
640a *    04/12/11  GJA  6.40a
     *      - Enh:  Make sure all file processing is not locking.
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftask      if   e           k disk
     Fpirtran   if   e           k disk
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Fmultran3  if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Date redefinition data structure
     *
     D $pfmdt          ds
     D  $pfmcc                 1      2
     D  $pfmyy                 3      4
     D  $pfmmm                 5      6
     D  $pfmdd                 7      8
     D $ptodt          ds
     D  $ptocc                 1      2
     D  $ptoyy                 3      4
     D  $ptomm                 5      6
     D  $ptodd                 7      8
     D $pbtim          ds
     D  $pbhrs                 1      2
     D  $pbmin                 3      4
     D  $pbsec                 5      6
     D $pttim          ds
     D  $pthrs                 1      2
     D  $ptmin                 3      4
     D  $ptsec                 5      6

     *----------------------------------------------------------------
     * Time Data Structure
     *----------------------------------------------------------------
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0

     *----------------------------------------------------------------
     * Program variables.
     *----------------------------------------------------------------

     D $MSGF           s             10
     D error           s              1
     D fintim          s              6  0
     D forevr          s              1
     D stdate          s                   like(PTSDTE)
     D strtim          s              6  0
     D sttime          s                   like(PTSTIM)
     D svtlen          s                   like(PTDMIN)
     D svtrn#          s                   like(PTTRN#)
     D timlen          s                   like(PTDMIN)
     D tmpbeg          s              4  0
     D tmpend          s              4  0
     D zzedte          s              8  0
     D zzetim          s              6  0
     D zzsdte          s              8  0
     D zzstim          s              6  0
     D $tdtetme        s               z
     D $fdtetme        s               z
     D wksdtec         s              8
     D wkedtec         s              8
     D wkstimc         s              6
     D wketimc         s              6
     D tdtetme         s             26
     D fdtetme         s             26
     D dhrs            s              7  2
     D ihrs            s              7  2
     D dmins           s              5  0
     D dsecs           s              5  0

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D  erqty                  1     10
     D  erpal                 11     12p 0
     D  eritem                13     27
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
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PEMP#  Employee
     *      $PTRN#  Transaction number
     *      $PSDTE  Transaction start date
     *      $PSTIM  Transaction start time
     *      $PEDTE  Transaction end date
     *      $PETIM  Transaction end time
     *
     *    Returned Parameters
     *      $PDATE  Transaction start date  (used with *UNDO,*ABORT)
     *      $PTIME  Transaction start time  (used with *UNDO,*ABORT)
     *      $PRTN   *OK      - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pemp#            5 0
     C                   parm                    $ptrn#            7 0
     C                   parm                    $psdte            8 0
     C                   parm                    $pstim            6 0
     C                   parm                    $pedte            8 0
     C                   parm                    $petim            6 0
     C                   parm                    $pmsg             4
     C                   parm                    $pmin             5 0
     C                   parm                    $psec             5 0
     C                   parm                    $pmucnt           5 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   move      *off          error


     C                   z-add     $ptrn#        svtrn#
     *  Past overnight. (PTEDTE > PTSDTE)
     C                   if        $pedte > $psdte
     C                   z-add     $pedte        stdate
     C                   else
     C                   z-add     $psdte        stdate
     C                   endif

     C                   z-add     $psdte        zzsdte
     C                   z-add     $pedte        zzedte
     C                   z-add     $pstim        zzstim
     C                   z-add     $petim        zzetim
     C                   eval      svtlen = 0
     * Get count of multiple transactions
     C                   exsr      zzchkm
     *
     C     ptkey2        setll     pirtran2
     C                   dow       forevr = forevr
640aDC**                 read      pirtran2                               79
640aMC                   read(n)   pirtran2                               79
     *   If end of file or start date is less than
     C                   if        %EOF(pirtran2)  or
     C                             ptsdte < zzsdte or
640aAC                             ptemp# <> $pemp#
     C                   leave
     C                   endif
     *
     *   Skip the transaction we are checking
     *
     C                   if        not %eof(pirtran2)  and
     C                             pttrn# = svtrn#
     C                   iter
     C                   endif
     *
     *   Skip 'IDLE' task
     *
     C                   if        pttask = 'IDLE'
     C                   iter
     C                   endif
     *
     *   Verify task type
     *
     C     pttask        chain     task
     C                   if        not %found(task)
     C                   eval      tktype = ' '
     C                   else
     *
     *   Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
     C                   select
     C                   when      ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
     C                   exsr      zzstamp
     C                   exsr      zztime
     C                   add       timlen        svtlen
     *
     *   Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
     C                   when      ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
     C                   exsr      zzstamp
     C                   exsr      zztime
     C                   add       timlen        svtlen
     *
     *   Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
     C                   when      ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim  and
     C                             tktype = 'I'
     C                   exsr      zzstamp
     C                   exsr      zztime
     C                   add       timlen        svtlen
     *
     C                   endsl
     *
     C                   endif
     C                   enddo
     *
     *   Update the task that just ended.
     *
     C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
     C                   else
     C                   eval      ptimin = ptimin - svtlen
     C                   endif
     *
     C                   eval      *inlr=*on
     C                   return
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
     C                   eval      forevr = *on
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    $pemp#
     C                   kfld                    stdate
     *
     *  Define key for MULTRAN3
     *
     C     mukey3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pemp#
     C                   kfld                    $psdte
     C                   kfld                    $pstim
     C                   kfld                    $pedte
     C                   kfld                    $petim

     C                   endsr

     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
     C                   endif
     C                   call      'PUTMSGP'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     * zzchkm:  get number of multiple transaction
     *----------------------------------------------------------------
     *
     C     zzchkm        begsr
     *
     C                   z-add     0             $pmucnt
     C     mukey3        setll     multran3
     C                   dow       forevr = forevr
     C     mukey3        reade(n)  multran3                               79
     *   If end of file or start date is less than
     C                   if        %EOF(multran3)  or
     C                             *in79 = *on
     C                   if        $Pmucnt=0
     C                   add       1             $pmucnt
     C                   endif
     C                   leave
     C                   else
     C                   add       1             $pmucnt
     C                   endif
     C                   enddo
     C                   endsr

     *----------------------------------------------------------------
     * zzstamp:  setup date stamp for chain
     *----------------------------------------------------------------
     *
     C     zzstamp       begsr
     C                   if        ptedte<>0
     C                   move      ptsdte        wksdtec
     C                   move      ptedte        wkedtec
     C                   move      ptstim        wkstimc
     C                   move      ptetim        wketimc
     C                   eval      fdtetme=%subst(wksdtec:1:4) + '-' +
     C                             %subst(wksdtec:5:2) + '-' +
     C                             %subst(wksdtec:7:2) + '-' +
     C                             %subst(wkstimc:1:2) + '.' +
     C                             %subst(wkstimc:3:2) + '.'   +
     C                             %subst(wkstimc:5:2) + '.000000'
     C                   eval      tdtetme=%subst(wkedtec:1:4) + '-' +
     C                             %subst(wkedtec:5:2) + '-' +
     C                             %subst(wkedtec:7:2) + '-' +
     C                             %subst(wketimc:1:2) + '.' +
     C                             %subst(wketimc:3:2) + '.' +
     C                             %subst(wketimc:5:2) + '.000000'
     C                   move      tdtetme       $tdtetme
     C                   move      fdtetme       $fdtetme
     C     $tdtetme      subdur    $fdtetme      dmins:*mn
     C     $tdtetme      subdur    $fdtetme      dsecs:*s
     C     dsecs         div       60            $pmin
     C                   mvr                     $psec
     C                   else
     C                   eval      $pmin=0
     C                   eval      $psec=0
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptetim
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     C     dshh          mult      60            tmpbeg
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *   Round up minute, if the seconds is >= 30
     C                   if        dsss >= 30
     C                   add       1             dsmm
     C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
     C                   if        fintim < strtim
     C                   add       24            dshh
     C                   endif
     C     dshh          mult      60            tmpend
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
     C                   if        timlen < 0
     C                   eval      timlen = 0
     C                   endif
     *
     C     endtim        endsr
