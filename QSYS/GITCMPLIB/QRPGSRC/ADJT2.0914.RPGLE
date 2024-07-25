     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2003')
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ADJTRAN     Adjust transaction record (EPM version)
     *  04 February, 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Old ADJTRAN Revisions
     *
412 A*    08/31/99  RH   4.12
     *      - Change to not remove employee # for *UNDO.
     *
414 A*    06/28/00  DAS  4.14
     *      - Added commands *DECTTL and *INCTTL. These commands
     *        are used when multiple license plates are scanned as
     *        a single transaction. An example would be the RC300
     *        staged putaway program.
     *      - Added command *CLOSE to do simple close of transaction
     *        that has no label records to close.
     *      - Added routine ZZCKU1 and ZZCKU2 to check for
     *        overlapping manual transactions.
     *      - Added routine ZZTIME used by ZZCKU2
     *      - Added file PIRTRAN2 used by ZZCKU2
     *      - Added command *ENDCUR to end current transaction
     *        for user.
     *
415 A*    06/14/01  HNK  4.15
     *      - Get current date just before updating the record instead
     *        of in *INZSR routine.
     *
     *  Old ADDSTDTRN/2 Revisions
     *
213 A*    05/22/96  DAS
     *      - Added new fields to PIRTRAN (PTRDTE, PTGRP1, PTGRP2).
     *      - Added GRP1 and GRP2 to parameter list.
     *      - Moved values into new PIRTRAN fields.
     *
218 A*    01/23/97  HNK
     *      - Added one more parameter $PCMD. Logic added to create
     *        and start transaction. Call ADJTSKDET program with
     *        with "*START" command to start the task.
     *
415 A*    06/14/01  HNK  4.15
     *      - Get current date just before updating the record instead
     *        of in *INZSR routine.
     *
     *  Revisions for ADJTRAN2
     *
417 A*    05/01/03  DAS  4.17
     *      - Converted to ILE.
     *      - Used ADJTRAN as a base.
     *      - Added Date/Time parameters, which were used in ADDSTDTRN2.
     *      - Added ADDSTDTRN logic.
     *      - Revised ADJTRAN, ADDSTDTRN/2 to call this program.
     *      - Changed $PCMD to 10.
     *      - Added $PTYPE, $PUSER, $PDATE and $PTIME.
     *      - Revised to always end current trans for *START and *CRTSTRT.
     *      - Added *ENDNONIDL to end current tran if not IDLE.
     *      - Added *UPDTIME to update total time for a transaction.
     *
417aA*    02/12/03  MLB  4.17a
     *      - Enh: Added new command *CLOSEI to close active Indirect
     *        task.
417bA*    05/19/03  MLB  4.17b
     *      - Enh: Revised routine ZZENDI,ZZTSKI to look for active
     *        IDLE tasks in addition to active indirect tasks.
417cA*    07/21/03  MLB  4.17c
     *      - Enh: Revised program when processing command *UNDO to
     *        clear employee number from transaction. Transactions
     *        later deleted were being attributed to the last employee
     *        to have worked with the transaction when they actually
     *        didn't have anything to do with the transaction.
417dA*    07/24/03  MLB  4.17d
     *      - Enh: Revised program when processing command *UNDO to
     *        pass back start date/time for transaction being reset.
417eA*    07/25/03  MLB  4.17e
     *      - Enh: Revised program when processing command *ABORT to
     *        pass back start date/time for transaction being aborted.
     *
417fA*    09/17/03  DAS  4.17f
     *      - Revised routine ZZTIME to initialize strtim/endtim variables
     *        with ptstim/ptetim fields.
     *      - Revised call to ZZTIME for *UPDTIME to update ptdmin or
     *        ptimin depending on tktype field.
     *      - Revised *CLOSE to make sure dates are not zero.
     *      - Revised *CLOSE to execute ZZTIME.
     *      - Revised to get TASK record after getting transaction record.
     *
500aA*    08/10/04  DAS  5.00a
     *      - Added commands *STARTMULT.
     *      - Revised routine ZZEND to call TE130 if transaction
     *        being ended exists in the MULTRAN file.
     *      - Revised ZZENDC to only end an IDLE task for *STARTMULT.
     *      - Added logic to ZZCREATE to get task info because it was
     *        getting wiped out when looking for overlapping tasks.
     *      - Revised *UNDO to try and delete transaction from MULTRAN file
     *      - Added *ENDNONSEL to end current tran if not Selection task.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftask      if   e           k disk
     Fpirtran   uf a e           k disk
     Fpiruser   if   e           k disk
414 AFpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
414 AFpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
417uAFmultran   uf a e           k disk
417uAFmultran1  uf   e           k disk
     F                                     rename(murec:murec1)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D desc            s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *----------------------------------------------------------------

     D ptparm        e ds                  extname(pirtran)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @adjtd          c                   const('ADJTSKDET')
     D @cvtdt          c                   const('CVTDTE')
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

414 A*----------------------------------------------------------------
414 A* Time Data Structure
414 A*----------------------------------------------------------------
414 A
414 AD                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0

414 A*----------------------------------------------------------------
414 A* Program variables.
414 A*----------------------------------------------------------------
414 A
     D $MSGF           s             10
417fAD curdate         s              8  0
417fAD curtime         s              6  0
     D curent          s              1
     D curtrn          s              7  0
     D curtsk          s                   like(TKCODE)
     D curtyp          s                   like(TKTYPE)
     D error           s              1
     D fintim          s              6  0
     D forevr          s              1
     D forever         s              1
     D Found           s              1
     D kystat          s                   like(PTSTAT)
500aAD kystat2         s                   like(MUSTAT)
417fAD lasttime        s              6  0
500aAD mufound         s               n
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

500aA*----------------------------------------------------------------
500aA*  TE130 Key Data Structure
500aA*----------------------------------------------------------------
500aA
500aAD $te130          ds
     D  $tlen                  1     50
     D  $temp#                 1      5  0
     D  $tstat                 6      6
414 A
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
     *      $PCMD   *START     = Start transaction
500aA*              *STARTMULT = Start transaction that is part of a
500aA*                           multiple transaction selection task.
     *              *ABORT     = Abort a transaction
     *              *UNDO      = Undo a transaction
414 A*              *DECTTL    = Decrease transaction totals
414 A*              *INCTTL    = Increase transaction totals
414 A*              *CLOSE     = Close transaction w/no label records.
500aA*              *CLOSEI    = Close Indirect transaction w/no label records.
414 A*              *ENDCUR    = End current transaction for user.
     *              *CREATE    = Create transaction
     *              *CRTSTRT   = Create and start transaction
     *              *ENDNONIDL = End current trans if not 'IDLE' task.
500aA*              *ENDNONSEL = End current trans if not 'Selection task.
     *              *UPDTIME   = Update total time for a transaction.
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER, *BATCH
     *      $PTRN#  Transaction number
     *      $PTASK  Task code
     *      $PWHSE  Warehouse
     *      $PWHDP  Department
     *      $PSTYP  Section
     *      $PCUBE  Cube
     *      $PSWGT  Weight
     *      $PPCS   Pieces
     *      $PAISL  Aisles
     *      $PQTY1  User quantity 1
     *      $PQTY2  User quantity 2
     *      $PQTY3  User quantity 3
     *      $PRTE   Route
     *      $PPO    P.O.
     *      $PGRP1  Group 1 code
     *      $PGRP2  Group 2 code
     *      $PDATE  Transaction date  (use if greater than zero)
     *      $PTIME  Transaction time
     *      $PUSER  User code (use if not blank)
     *
     *    Returned Parameters
417eM*      $PDATE  Transaction start date  (used with *UNDO,*ABORT)
417eM*      $PTIME  Transaction start time  (used with *UNDO,*ABORT)
     *      $PRTN   *OK      - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd            10
     C                   parm                    $pprg            10
     C                   parm                    $ptype            8
     C                   parm                    $ptrn#            7 0
     C                   parm                    $ptask            6
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pcube            9 3
     C                   parm                    $pswgt            9 2
     C                   parm                    $ppcs             5 0
     C                   parm                    $paisl            5 0
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $prte             5
     C                   parm                    $ppo              9
     C                   parm                    $pgrp1            1
     C                   parm                    $pgrp2            1
     C                   parm                    $pdate            8 0
     C                   parm                    $ptime            6 0
     C                   parm                    $puser           10
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      $prtn = *blanks
     C                   eval      $pmsg = *blanks
     C                   move      *off          error

     *  Get task information.

     C     $ptask        chain     task                               79
 1B  C                   if        *in79
     C                   eval      tkcat = *blanks
     C                   eval      tksub = *blanks
 1E  C                   endif

     *  Get user information.

     C                   exsr      zzgetu

     *  For *CRTSTRT and *START, end current transaction.

 1X  C                   if        $pcmd = '*CRTSTRT' or
500aAC                             $pcmd = '*STARTMULT' or
 1X  C                             $pcmd = '*START'
     C                   exsr      zzendc
     C                   endif

     *  For *CREATE and *CRTSTRT, do it and leave.

 1X  C                   if        $pcmd = '*CREATE'  or
 1X  C                             $pcmd = '*CRTSTRT'
     C                   exsr      zzcreate
     C                   goto      out
     C                   endif

     *  For *ENDCUR and *ENDNONIDL, do it and leave.

 1X  C                   if        $pcmd = '*ENDCUR'    or
500aAC                             $pcmd = '*ENDNONSEL' or
 1X  C                             $pcmd = '*ENDNONIDL'
     C                   exsr      zzendc
     C                   goto      out
     C                   endif

     *  For *CLOSEI, do it and leave.

417aAC                   if        $pcmd = '*CLOSEI'
417aAC                   exsr      zzendi
417aAC                   goto      out
417aAC                   endif
     *
     *  Get transaction record.
     *
 1B  C*******            if        $pcmd <> '*ENDCUR '
     C     $ptrn#        chain     pirtran                            7978
     *
     *     Record is locked.
     *
 2B  C                   if        *in78
     C                   move      *on           error
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7978
     C                   eval      $prtn = '*PGMQ   '
 2E  C                   endif
     *
     *     Record not found.
     *
 2B  C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = desc(1)
     C                   exsr      zm7979
     C                   eval      $prtn = '*PGMQ   '
 2E  C                   endif
     *
     C     error         cabeq     *on           out
 1E  C**********         endif
417fA
417fA*  Get task information.
417fA
417fAC     pttask        chain     task                               79
417fAC                   if        *in79
417fAC                   eval      tkcat = *blanks
417fAC                   eval      tksub = *blanks
417fAC                   eval      tktype = 'I'
417fAC                   endif
     *
     *  Update transaction detail record.
     *
 1B  C                   if        $pcmd <> '*INCTTL '  and
     C                             $pcmd <> '*DECTTL '  and
417aMC                             $pcmd <> '*ENDCUR '  and
417aAC                             $pcmd <> '*CLOSEI '
     C                   call      @adjtd
     C                   parm      $pcmd         @pcmd             8
     C                   parm      '*INTER  '    @ptype            8
     C                   parm                    ptparm
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
 1E  C                   endif
     *
     *  Update transaction record.
     *
 1B  C                   select
 1X  C                   when      $pcmd = '*START  '
     C                   eval      ptstat = '2'
     C**   #user         chain     piruser                            79
 2B  C**                 if        not *in79
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#
 2X  C**                 else
     C**                 eval      ptshft = *blanks
     C**                 eval      ptcrew = *blanks
     C**                 eval      ptemp# = 0
 2E  C**                 endif
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptsdte = $cvd8o
417fDC**                 time                    ptstim
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime
     *
500aAC                   when      $pcmd = '*STARTMULT'
500aAC                   exsr      getmultran2
500aAC                   eval      ptstat = '2'
500aAC                   eval      ptshft = usshft
500aAC                   eval      ptcrew = uscrew
500aAC                   eval      ptemp# = usemp#
500aAC                   if        mufound
500aAC                   eval      ptsdte = musdte
500aAC                   eval      ptstim = mustim
500aAC                   else
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime
500aAC                   endif
500aAC                   exsr      addmultran
500aA*
 1X  C                   when      $pcmd = '*UNDO   '
500aAC                   exsr      delmultran
     C                   eval      ptstat = '1'
417dA*
417dA*    Pass back start date/time for use in starting IDLE task.
417dAC                   eval      $pdate = ptsdte
417dAC                   eval      $ptime = ptstim
     C                   eval      ptsdte = 0
     C                   eval      ptstim = 0
     C                   eval      ptshft = *blanks
     C                   eval      ptcrew = *blanks
 2B  C                   if        ptemp# = 0
     C                   eval      ptemp# = 99999
 2E  C                   endif
417cAC                   eval      ptemp# = 0
     *
 1X  C                   when      $pcmd = '*ABORT  '
     C     $ptrn#        chain     pirtran                            79
 2B  C                   if        not *in79
417eA*
417eA*    Pass back start date/time for use in starting IDLE task.
417eAC                   eval      $pdate = ptsdte
417eAC                   eval      $ptime = ptstim
     C                   delete    ptrec
 2E  C                   endif
goto C                   goto      out
     *
 1X  C                   when      $pcmd = '*INCTTL '
     C                   call      @adjtd
     C                   parm      '*DECACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   add       $ppcs         ptpcs
     C                   add       $pcube        ptcube
     C                   add       $pswgt        ptswgt
     C                   add       $paisl        ptaisl
     C                   add       $pqty1        ptqty1
     C                   add       $pqty2        ptqty2
     C                   add       $pqty3        ptqty3
     *
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
 1X  C                   when      $pcmd = '*DECTTL '
     C                   call      @adjtd
     C                   parm      '*DECACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   eval      ptpcs = ptpcs - $ppcs
     C                   eval      ptcube = ptcube - $pcube
     C                   eval      ptswgt = ptswgt - $pswgt
     C                   eval      ptaisl = ptaisl - $paisl
     C                   eval      ptqty1 = ptqty1 - $pqty1
     C                   eval      ptqty2 = ptqty2 - $pqty2
     C                   eval      ptqty3 = ptqty3 - $pqty3
 2B  C                   if        ptpcs < 0
     C                   eval      ptpcs = 0
 2E  C                   endif
 2B  C                   if        ptcube < 0
     C                   eval      ptcube = 0
 2E  C                   endif
 2B  C                   if        ptswgt < 0
     C                   eval      ptswgt = 0
 2E  C                   endif
 2B  C                   if        ptaisl < 0
     C                   eval      ptaisl = 0
 2E  C                   endif
 2B  C                   if        ptqty1 < 0
     C                   eval      ptqty1 = 0
 2E  C                   endif
 2B  C                   if        ptqty2 < 0
     C                   eval      ptqty2 = 0
 2E  C                   endif
 2B  C                   if        ptqty3 < 0
     C                   eval      ptqty3 = 0
 2E  C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*INCACT '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
 1X  C                   when      $pcmd = '*CLOSE  '
     C                   eval      ptstat = '4'
     C****               exsr      zzgetu
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

417fAC                   if        ptsdte = 0
417fAC                   eval      ptsdte = ptgdte
417fAC                   eval      ptstim = ptgtim
417fAC                   endif

417fAC                   if        ptedte = 0
417fAC                   if        $pdate > 0
417fAC                   eval      ptedte = $pdate
417fAC                   eval      ptetim = $ptime
417fAC                   else
417fAC                   exsr      getdatetime
417fAC                   eval      ptedte = curdate
417fAC                   eval      ptetim = curtime
417fAC                   endif
417fAC                   endif

417fAC                   if        ptcdte = 0
417fAC                   eval      ptcdte = ptedte
417fAC                   eval      ptctim = ptetim
417fAC                   endif

417fAC                   exsr      zztime
417fAC                   if        tktype = 'D'
417fAC                   eval      ptdmin = timlen
417fAC                   eval      ptimin = 0
417fAC                   else
417fAC                   eval      ptimin = timlen
417fAC                   eval      ptdmin = 0
417fAC                   endif
     *
 1X  C****               when      $pcmd = '*ENDCUR '
     C****               exsr      zzgetu
     C****               eval      ptshft = usshft
     C****               eval      ptcrew = uscrew
     C****               eval      ptemp# = usemp#
     C****               exsr      zzendc
     *
 1X  C                   when      $pcmd = '*UPDTIME'
     C                   exsr      zztime
417aAC                   if        tktype = 'D'
417fAC                   eval      ptdmin = timlen
417fAC                   eval      ptimin = 0
417fAC                   else
417fAC                   eval      ptimin = timlen
417fAC                   eval      ptdmin = 0
417fAC                   endif
     *
 1E  C                   endsl
     *
 1B  C****               if        $pcmd <> '*ENDCUR '
     C                   update    ptrec
 1E  C****               endif
     *
     *  When *CLOSEing a task, the possibility exists that a manual
     *  task might have been added during the task that is being
     *  closed. Therefore, check it out and make any necessary
     *  adjustments.
     *
 1B  C                   if        $pcmd = '*CLOSE  ' or
 1B  C                             $pcmd = '*UPDTIME'
     C                   exsr      zzcku1
 1E  C                   endif
     *
     C     out           tag
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
     C                   eval      forevr = *on
     *
     *  Define partial key for PIRTRAN2 file.
     *
     C     ptkey2        klist
     C                   kfld                    usemp#
     C                   kfld                    stdate
     *
     *     PIRTRAN2 file.
     *
     C     ptke22        klist
     C                   kfld                    usemp#
     C                   kfld                    stdate
     C                   kfld                    sttime
     *
     *     PIRTRAN1 file.
     *
     C     ptkey1        klist
     C                   kfld                    usemp#
     C                   kfld                    kystat
500aA*
500aA*     Partial key for MULTRAN file.
500aA*
500aAC     keymu         klist
500aAC                   kfld                    usemp#
500aAC                   kfld                    kystat2
     *
     *  Convert today's date into century format.
     *
     **                   MOVE '*CURCMD '$CVCMD
     **                   CALL @CVTDT
     **                   PARM           $CVTDT
     **                   Z-ADD$CVD8O    TODAY   80
     C                   endsr

500aA*----------------------------------------------------------------
500aA*  addmultran   Add MULTRAN record for employee.
500aA*----------------------------------------------------------------
500aA
500aAC     addmultran    BegSr

     C                   eval      muwhse = ptwhse
     C                   eval      mutrn# = pttrn#
     C                   eval      muemp# = ptemp#
     C                   eval      mustat = '1'
     C                   eval      musdte = ptsdte
     C                   eval      mustim = ptstim
     C                   eval      muedte = 0
     C                   eval      muetim = 0
     C                   write(e)  murec
     C                   if        %error
     C                   endif

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  delmultran   Delete MULTRAN record for transaction.
500aA*----------------------------------------------------------------
500aA
500aAC     delmultran    BegSr

     C     pttrn#        chain     multran1
     C                   if        %found
     C                   delete    murec1
     C                   endif

     C                   endsr

417fA*----------------------------------------------------------------
417fA*  getdatetime  Get current date & time
417fA*----------------------------------------------------------------
417fA
417fAC     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime or curdate = 0
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  getmultran   Get MULTRAN record for employee, if any.
500aA*----------------------------------------------------------------
500aA
500aAC     getmultran    BegSr

     C     curtrn        chain(n)  multran1
     C                   if        %found
     C                   eval      mufound = *on
     C                   else
     C                   eval      mufound = *off
     C                   endif

     C                   endsr

500aA*----------------------------------------------------------------
500aA*  gegmultran2  Get first MULTRAN record for employee.
500aA*----------------------------------------------------------------
500aA
500aAC     getmultran2   BegSr

     C                   eval      kystat2 = '1'
     C     keymu         setll     multran
     C     keymu         reade(n)  multran
     C                   if        %eof
     C                   eval      mufound = *off
     C                   else
     C                   eval      mufound = *on
     C                   endif

     C                   endsr

     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR7872  Record not updated.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7978  Record is locked.
     *
     C     zm7978        begsr
     C                   eval      #msgid = 'PIR7978'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU1   Check for overlapping manual task.
     *
     C     zzcku1        begsr
     *
     C                   z-add     pttrn#        svtrn#
     *  Past overnight. (PTEDTE > PTSDTE)
 1B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 1X  C                   else
     C                   z-add     ptsdte        stdate
 1E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKU2   Check for overlapping task and update the current
     *           task just ended, by adjusting the time.
     *
     C     zzcku2        begsr
     C                   eval      svtlen = 0
     C     ptkey2        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2                               79
 2B  C                   if        *in79  or
     C                             ptsdte < zzsdte
 1L  C                   leave
 2E  C                   endif
     *   Skip the task that just ended.
 2B  C                   if        not *in79  and
     C                             pttrn# = svtrn#
 1I  C                   iter
 2E  C                   endif
     *
     *   Skip 'IDLE' task
     *
 2B  C                   if        pttask = 'IDLE'
 1I  C                   iter
 2E  C                   endif
     *
     C     pttask        chain     task                               79
 2B  C                   if        *in79
     C                   eval      tktype = ' '
 2E  C                   endif
     *   Accumulate overlapping minutes.(Same start and end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  10:00:23   11:30:35  1/25/96
     *Manual(PT) BREAK 1/25/96  10:30:00   10:45:00  1/25/96   (15)
     *
     *   Auto    CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *   Manual  BREAK 1/25/96  23:30:00    1:30:00  1/26/96   (120)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptstim >= zzstim  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *   Accumulate overlapping minutes(Diff start date/same end date)
     *                                  (Past midnight)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/26/96   8:00:00    8:30:00  1/26/96   (30)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte > zzsdte  and
     C                             ptedte = zzedte  and
     C                             ptetim <= zzetim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
     *   Accumulate overlapping minutes.(Same start date/diff end date)
     *                  Start     Start       End      End    Overlap
     *           Task    date      time       time     date   Minutes
     *Auto  (ZZ) CLEAN 1/25/96  14:50:23    9:30:23  1/26/96
     *Manual(PT) BREAK 1/25/96  16:00:00   16:30:00  1/25/96   (30)
     *
 2B  C                   if        not *in79  and
     C                             ptsdte = zzsdte  and
     C                             ptedte < zzedte  and
     C                             ptstim >= zzstim  and
     C                             tktype = 'I'
417fDC**                 z-add     ptstim        strtim
417fDC**                 z-add     ptetim        fintim
     C                   exsr      zztime
     C                   add       timlen        svtlen
 2E  C                   endif
 1E  C                   enddo
     *
     *   Update the task that just ended.
     *
     C     svtrn#        chain     pirtran                            79
 1B  C                   if        not *in79
 2B  C                   if        ptdmin > 0
     C                   eval      ptdmin = ptdmin - svtlen
 2X  C                   else
     C                   eval      ptimin = ptimin - svtlen
 2E  C                   endif
     C                   update    ptrec
 1E  C                   endif
     C     endcu2        endsr

     *----------------------------------------------------------------
     *  ZZCREATE   Create transaction (from ADDSTDTRN2)
     *----------------------------------------------------------------

     C     zzcreate      begsr
500aA
500aA*  Get task information.
500aA
500aAC     $ptask        chain     task                               79
500aAC                   if        *in79
500aAC                   eval      tkcat = *blanks
500aAC                   eval      tksub = *blanks
500aAC                   endif

     *  Create transaction record.

     *    Note: The task tracking level determines whether or not the
     *          department and the section are written to the transaction
     *          record.  This was done in order to make it possible to
     *          use a simple join between the transaction records and
     *          the task detail file which contains the standards.

     C                   clear                   ptrec
     C                   if        $ptrn# = 0
     C                   call      'PIRTRN#'
     C                   parm                    $ptrn#
     C                   endif
     C                   eval      pttrn# = $ptrn#
     C                   eval      ptwhse = $pwhse
     C                   eval      pttask = $ptask
     C                   eval      ptcat = tkcat
     C                   eval      ptsub = tksub
 1B  C                   select
 1X  C                   when      tktlvl = 'D'
     C                   eval      ptwhdp = $pwhdp
 1X  C                   when      tktlvl = 'S'
     C                   eval      ptwhdp = $pwhdp
     C                   eval      ptstyp = $pstyp
 1E  C                   endsl
     C                   eval      ptcube = $pcube
     C                   eval      ptswgt = $pswgt
     C                   eval      ptpcs  = $ppcs
     C                   eval      ptaisl = $paisl
     C                   eval      ptqty1 = $pqty1
     C                   eval      ptqty2 = $pqty2
     C                   eval      ptqty3 = $pqty3

 1B  C                   select

     *    Use date/time passed in for Generated date/time.

 1X  C                   when      $pdate > *zeros
     C                   eval      ptgdte = $pdate
     C                   eval      ptgtim = $ptime

 1X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptgdte = $cvd8o
417fDC**                 time                    ptgtim
417fAC                   exsr      getdatetime
417fAC                   eval      ptgdte = curdate
417fAC                   eval      ptgtim = curtime
 1E  C                   endsl
 1B  C                   if        $ppo <> *blanks
     C                   eval      ptrtpo = $ppo
 1X  C                   else
     C                   movel     $prte         ptrtpo
 1E  C                   endif

 1B  C                   select

     *    Use date/time passed in for Report date/time.

 1X  C                   when      $pdate > *zeros
     C                   eval      ptrdte = $pdate

 1X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptrdte = $cvd8o
417fAC                   exsr      getdatetime
417fAC                   eval      ptrdte = curdate
 1E  C                   endsl

     C                   eval      ptgrp1 = $pgrp1
     C                   eval      ptgrp2 = $pgrp2

 1B  C                   select
 1X  C                   when      $pcmd = '*CREATE '
     C                   eval      ptstat = *on

 1X  C                   when      $pcmd = '*CRTSTRT'
     C                   eval      ptstat = '2'
     C                   eval      ptshft = usshft
     C                   eval      ptcrew = uscrew
     C                   eval      ptemp# = usemp#

 2B  C                   select

     *    Use date/time passed in for Transaction start date/time.

 2X  C                   when      $pdate > *zeros
     C                   eval      ptsdte = $pdate
     C                   eval      ptstim = $ptime

 2X  C                   other
417fDC**                 eval      $cvcmd = '*CURCMD '
417fDC**                 call      @cvtdt
417fDC**                 parm                    $cvtdt
417fDC**                 eval      ptsdte = $cvd8o
417fDC**                 time                    ptstim
417fAC                   exsr      getdatetime
417fAC                   eval      ptsdte = curdate
417fAC                   eval      ptstim = curtime

 2E  C                   endsl
 1E  C                   endsl

     C                   write     ptrec

     *  Update task totals

 1X  C                   if        $pcmd = '*CRTSTRT'
     C                   eval      @pcmd = '*START'
     C                   else
     C                   eval      @pcmd = '*GEN'
     C                   endif

     C                   call      @adjtd
     C                   parm                    @pcmd             8
     C                   parm                    $ptype
     C                   parm                    ptparm
     C                   parm                    $prtn
     C                   parm                    $pmsg

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZEND  End current task.
     *
     C     zzend         begsr
500aA*
500aA*  If transaction is part of a multiple transaction selection
500aA*   then close it with a different program.
500aA*
500aAC                   exsr      getmultran
500aAC                   if        mufound
500aAC                   eval      $temp# = usemp#
500aAC                   eval      $tstat = '*'
500aAC                   call      'TE130'
500aAC                   parm                    $te130
500aAC                   parm                    $trtn             8
500aAC                   goto      endend
500aAC                   endif
500aAC*
     *  No current task to end.
     C     curtrn        cabeq     0             endend
     *  End current task
     C     curtrn        chain     pirtran                            79
 1B  C                   if        not *in79
 2B  C                   if        curtyp = 'D'  and
     C                             curtsk <> 'IDLE  '
     C                   eval      ptstat = '3'
 2X  C                   else
     C                   eval      ptstat = '4'
 2E  C                   endif
     C                   eval      ptetyp = 'N'
 1E  C                   endif
     *
     C                   call      @adjtd
     C                   parm      '*END    '    @pcmd
     C                   parm      '*INTER  '    @ptype
     C                   parm                    ptparm
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C                   update    ptrec                                79
 1B  C                   if        *in79
     C                   eval      error = *on
     **                   EXSR ZM72
goto Csr                 goto      endend
 1E  C                   endif
     *
 1B  C                   if        curtyp = 'D'
     *
     *        There is a posibility that a manual task might have
     *        been added before the current task was ended. Hence
     *        adjust the current task just ended, if there is
     *        any overlapping manual task.
     *
     C                   z-add     pttrn#        svtrn#
     *  Past overnight. (PTEDTE > PTSDTE)
 2B  C                   if        ptedte > ptsdte
     C                   z-add     ptedte        stdate
 2X  C                   else
     C                   z-add     ptsdte        stdate
 2E  C                   endif
     C                   z-add     ptsdte        zzsdte
     C                   z-add     ptedte        zzedte
     C                   z-add     ptstim        zzstim
     C                   z-add     ptetim        zzetim
     C                   exsr      zzcku2
 1E  C                   endif
     *
     C     endend        endsr
     *----------------------------------------------------------------
     *
     *  ZZENDC   End current transaction for user.
     *
     C     zzendc        begsr

     *  Get current task.

     C                   exsr      zztask
     C     found         cabeq     *off          endendc

     *  Get out if task is IDLE but we don't want to end an IDLE task.

     C                   if        $pcmd = '*ENDNONIDL' and
     C                             pttask = 'IDLE'
     C                   goto      endendc
     C                   endif
500aA
500aA*  Get out if Selection task but we don't want to end it.
500aA
500aAC                   if        $pcmd = '*ENDNONSEL' and
500aAC                             ptgrp1 = 'S'
500aAC                   goto      endendc
500aAC                   endif
500aA
500aA*  For *STARTMULT only end an IDLE task.
500aA
500aAC                   if        $pcmd = '*STARTMULT' and
500aAC                             pttask <> 'IDLE'
500aAC                   goto      endendc
500aAC                   endif

     *  End open task.
     *    If task is Direct, just end it and get out.
     *    If task is Indirect, end it and any other open tasks.

 1B  C                   select
 1X  C                   when      curtyp = 'D'
     C                   exsr      zzend

 1X  C                   when      curtyp = 'I'
 2B  C                   dow       forever = forever
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   exsr      zztask
 3B  C                   if        found = *off
 2L  C                   leave
 3E  C                   endif
     C                   exsr      zzend
 2E  C                   enddo

 1E  C                   endsl

     C     endendc       endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZENDI  End current Indirect task.
417aA*
417aAC     zzendi        begsr
     *
     *    Find any open tasks.
     C                   eval      curtsk = *blanks
     C                   eval      curtyp = *blanks
     C                   eval      curent = *off
     C                   eval      found = *off
     C                   exsr      zztski
     *
     *    End current Indirect task
417bA*    or IDLE Direct task.
 1B  C                   if        curent = *on  and
     C                             curtyp = 'I'
417bAC                             or curent = *on  and
417bAC                             curtyp = 'D' and curtsk = 'IDLE '
     *
     C     curtrn        chain     pirtran                            79
 2B  C                   if        not *in79
     C                   eval      ptstat = '4'
     C                   eval      ptetyp = 'N'
     *
 3B  C                   if        ptsdte = *zeros
     C                   eval      ptsdte = ptgdte
     C                   eval      ptstim = ptgtim
 3E  C                   endif
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      ptcdte = $cvd8o
     C                   time                    ptctim
     *
     C                   eval      ptedte = $cvd8o
     C                   eval      ptetim = ptctim
     *
     *    Calculate time duration for this Indirect task.
417bA*    or Direct IDLE task.
     C                   eval      strtim = ptstim
     C                   eval      fintim = ptctim
     C                   exsr      zztime
417bAC                   if        curtyp = 'D' and curtsk = 'IDLE  '
417bAC                   eval      ptdmin = timlen
417bAC                   else
     C                   eval      ptimin = timlen
417bAC                   endif
     *
     C                   update    ptrec                                79
 3B  C                   if        *in79
     C                   move      *on           error
     C                   eval      $prtn = '*ERROR  '
goto Csr                 goto      endi
 3E  C                   endif
 2E  C                   endif
 1X  C                   else
     C                   eval      $prtn = '*ERROR  '
 1E  C                   endif
     *
     C     endi          endsr
     *----------------------------------------------------------------
     *
     *  ZZGETU   Get user
     *
     C     zzgetu        begsr
     C                   if        $puser <> *blanks
     C     $puser        chain     piruser                            79
     C                   else
     C     #user         chain     piruser                            79
     C                   endif
 1B  C                   if        *in79
     C                   eval      usshft = *blanks
     C                   eval      uscrew = *blanks
     C                   eval      usemp# = 0
 1E  C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
     C     zztask        begsr

     C                   eval      found = *off

     C                   eval      stdate = *hival
     C                   eval      sttime = *hival
     *
     C                   move      '2'           kystat
     C     ptkey1        setll     pirtran1
     C     ptkey1        reade     pirtran1                               79
 1B  C                   if        *in79
goto C                   goto      endtsk
 1E  C                   endif
     *
     C     ptke22        setll     pirtran2
 1B  C                   dow       forevr = forevr
     C                   read      pirtran2                               79
 2B  C                   if        *in79  or
     C                             ptemp# <> usemp#
 1L  C                   leave
 2E  C                   endif
417aMC                   if        ptstat <> '2' or
417aA*
417aA*    If closing Indirect task, make sure that current Direct
417aA*    task isn't selected to be closed.
417aAC                             $pcmd = '*CLOSEI '  and
417aAC                             pttrn# = $ptrn#
 1I  C                   iter
 2E  C                   endif
     *   Found an active transaction
     C                   move      *on           found
     C                   z-add     pttrn#        curtrn
     C     pttask        chain     task                               79
 2B  C                   if        not *in79
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 2E  C                   endif
 1L  C                   leave
 1E  C                   enddo
     C     endtsk        endsr
417aA*----------------------------------------------------------------
417aA*
417aA*  ZZTSKI  Get current Indirect task.
417aA*
417aAC     zztski        begsr
     *
     C                   move      '2'           kystat
     C     ptkey1        setll     pirtran1
 1B  C                   dow       forevr = forevr
     C     ptkey1        reade     pirtran1                               79
 2B  C                   select
 2X  C                   when      *in79
     C                   move      *off          found
     C                   move      *off          curent
 1L  C                   leave
     *
     *    When closing Indirect task, make sure that current Direct
     *    task isn't selected to be closed.
 2X  C                   when      pttrn# = $ptrn#
 1I  C                   iter
     *
 2X  C                   other
     *
     C     pttask        chain     task                               79
 3B  C                   select
     *    Task record not found. Find next record.
 3X  C                   when      *in79
 1I  C                   iter
     *    Not a Indirect task. Find next record.
417bDC*                  when      tktype <> 'I'
417bA*    or Not a Direct IDLE task. Find next record.
417bAC                   when      tktype = 'D' and tkcode <> 'IDLE  '
 1I  C                   iter
     *    Process Indirect task.
 3X  C                   when      tktype = 'I'
417bA*    or Process Direct IDLE task.
417bAC                             or tktype = 'D' and tkcode = 'IDLE  '
     C                   move      *on           curent
     C                   move      *on           found
     C                   z-add     pttrn#        curtrn
     C                   move      tkcode        curtsk
     C                   move      tktype        curtyp
 1L  C                   leave
 3E  C                   endsl
 2E  C                   endsl
 1E  C                   enddo
     *
     C     endtki        endsr
     *----------------------------------------------------------------
     *
     *  ZZTIME   Update for screen 1.
     *
     C     zztime        begsr
417fAC                   eval      strtim = ptstim
417fAC                   eval      fintim = ptetim
     *
     *      Calculate length of time in minutes for output.
     *
     C                   eval      dshms = strtim
     *   Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     C     dshh          mult      60            tmpbeg
     C                   add       dsmm          tmpbeg
     *
     C                   eval      dshms = fintim
     *   Round up minute, if the seconds is >= 30
 1B  C                   if        dsss >= 30
     C                   add       1             dsmm
 1E  C                   endif
     *
     *   If the ending time is < starting time, than
     *   we have gone past the midnight.
     *
 1B  C                   if        fintim < strtim
     C                   add       24            dshh
 1E  C                   endif
     C     dshh          mult      60            tmpend
     C                   add       dsmm          tmpend
     *
     C                   eval      timlen = tmpend - tmpbeg
 1B  C                   if        timlen < 0
     C                   eval      timlen = 0
 1E  C                   endif
     *
     C     endtim        endsr
**
Transaction
