      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTECLSTRN  Close selection transaction
     *  12 April 2014
     *  Dave Sommerville
     *
     *  NOTE:
     *      Based on PT640
     *      If you change this program, check PT640 for same changes.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    04/12/14  DAS  6.50
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *
415aMFpirtran4  uf   e           k disk
     F                                     rename(ptrec:record)
     Fpirtran   if   e           k disk
     F                                     rename(ptrec:recordu)
415aAFLabel8    if   e           k disk
417bAFmultran1  if   e           k disk
     Frtehed    uf   e           k disk
620cMFLabel90   uf   e           k disk
500dAFworksos2  if   e           k disk
610aAFoptions   if   e           k disk
530bAFlabel7    if   e           k disk
620cMFordc1     uf a e           k disk
620aAFlabel76   if   e           k disk    prefix(L76_)
620bMFprexref1  if   e           k disk
620aAFprexref2  uf a e           k disk    rename(pxrec:pxrec2)
620aAFprexref4  uf a e           k disk    rename(pxrec:pxrec4)
620cAFlabel     if   e           k disk    rename(lbrec:lbrec0)
620cAF                                     prefix(L_)
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
     D @getcl          c                   const('GETCLIENT')
510bA*
EFCaAD/copy qcopysrc,id#eastlan
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                 1     50
     D  $kwhse                 1      3  0
     D  $krte                  4      8
     D  $krtid                 9     13
     D  $ktruk                14     23
     D  $kstat                24     24
     D  $ktype                25     25
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsukey                 1     50
     D  ukwhse                 1      3  0 inz(0)
     D  ukrte                  4      8
     D  ukpo                   9     17
     D  uktrn#                18     24  0 inz(0)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @delpg          c                   const('PT132')
     D @pckrt          c                   const('CALPCKRTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
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
     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D close           s              1
     D clsall          s              1
EFCbAD dev             s             10
     D error           s              1
     D forevr          s              1
620cAD forever         s               n
     D form            s             10
     D kypo            s                   like(l8po) inz(' ')
     D kyrtpo          s                   like(ptrtpo)
     D kywhse          s                   like(ptwhse)
     D kygrp2          s                   like(ptgrp2)
620aAD hasPrepick      s               n   inz('0')
     D p               s              2  0
     D t               s              2  0
     D v               s              2  0
     D x               s              3  0
     D y               s              3  0
530bAD cwflg           s              1
530bAD cwitm           s              1
     D logText         s            100
     D pMessage        s             99
     D trnNotFound     s               n

     *----------------------------------------------------------------
     *  OutStr Variables
     *----------------------------------------------------------------

     D errFlg          s               n
     D stat            s              1
     D statDsc         s             20
     D msg             s             99

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId  Session id
     *      pUser    User
     *      pPgm     Calling dictionary.pgm
     *      pWhse    Warehouse
     *      pRtid    Route id
     *      pRteType Route type
     *      pTran#   Tran number
     *
     *    Returned Parameters
     *      pOutStr     Output JSON string
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pSessId          40
     C                   parm                    pUser            10
     C                   parm                    pPgm             20
     C                   parm                    pWhse             3 0
     C                   parm                    pRtid             5
     C                   parm                    pRteType          1
     C                   parm                    pTran#            7 0
     C                   parm                    pOutStr         512

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pOutStr = ' ';
         error = *off;

         // Initialize variables used in PT640 routines

         clear $parms;
         $pprg = #prog;
         $ptype = '*INTER';

         $kwhse = pWhse;
         $krtid = pRtId;

         ukwhse = pWhse;
         ukpo = pRtId;
         uktrn# = pTran#;

         kywhse = pWhse;
         kyrtpo = pRtId;
         kygrp2 = pRteType;

         exsr zzinz;

         // Close transaction

         if pTran# = 0;
           exsr CloseAll;
         else;
           exsr CloseOne;
           exsr GetTran;
         endif;

         // Turn status in to word.
         // Note, GUI list display originally gets it from GLOTRNSTS

         select;
           when ptstat = '1';
             statDsc = 'Open';
           when ptstat = '2';
             statDsc = 'Started (Active)';
           when ptstat = '3';
             statDsc = 'Ended';
           when ptstat = '4';
             statDsc = 'Closed';
           when ptstat = '8';
             statDsc = 'Interrupted';
           when ptstat = '9';
             statDsc = 'Canceled';
           when ptstat = 'X';
             statDsc = 'Deleted';
           other;
             statDsc = ptstat;
         endsl;

         // Build JSON string to return

         pOutStr = '{'
                 +  '"errflg":"' + error + '",'
                 +  '"stat":"' + ptstat + '",'
                 +  '"statdsc":"' + %trimr(statDsc) + '",'
                 +  '"msg":"' + %trimr(pMessage) + '"'
                 +  '}';

         // Write GLOSESSLOG record

         logText = 'whs:' + %char(pWhse) + ','
                 + 'rtid:' + %trim(pRtid) + ','
                 + 'rtetype:' + %trim(pRteType) + ','
                 + 'trn:' + %char(pTran#) + ','
                 + 'outstr:' + %trim(pOutStr);
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
     C     *inzsr        begsr

     * Get client id.

     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    cliloc           10
     C                   endsr

     *----------------------------------------------------------------
     *  closeAll  Close all transactions for route
     *----------------------------------------------------------------

     C     CloseAll      begsr
      /free
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  closeOne  Close single transaction
     *----------------------------------------------------------------

     C     CloseOne      begsr

     * Make sure transaction exists

     C                   exsr      GetTran
     C                   if        trnNotFound
     C                   eval      error = *on
     C                   eval      pMessage = 'Transaction not found - '
     C                                      + %char(pTran#)
     C                   leavesr
     C                   endif
640cA*
640cA* Check to see if all catch weights records have been entered.
640cA*
640cAC                   exsr      zzchkCW
640cAC                   if        error = '1'
640cAC                   leavesr
640cAC                   endif
640cA*
640bA*  Prevent user from touching a transaction if any labels
640bA*  associated with the transaction has a USR slot.
640cA*
640bAC                   exsr      zzchkUSR
640bAC                   if        error = '1'
640bAC                   leavesr
640bAC                   endif
640cA*
620aA*  Stop user from touching the Normal transaction if the
620aA*  corresponding Pre-Pick transactions aren't closed.
640cA*
620aAC                   exsr      zzchkPrepick
620aAC                   if        error = '1'
620aAC                   leavesr
620aAC                   endif
640cA*
620cA*  Update normal transaction with pre-pick information.
640cA*
620cAC                   exsr      updNrmTran
620cAC                   if        error = '1'
620cAC                   leavesr
620cAC                   endif
640cA*
500b *  Check for transaction status 2=started
510 A*     -or- Transaction suspended, interupted.
640cA*
500b C                   exsr      zzchkt
500b C                   if        error = '1'
500b C                   eval      pMessage = 'Cannot close transaction. '
500b C                                      + 'Transaction has been '
500b C                                      + 'started. '
500b C                   leavesr
500b C                   endif
640cA*
     *  Check for Multi Trans
640cA*
417b C                   exsr      zzmult
417b C                   if        error = '1'
500b C                   eval      pMessage = 'Cannot close transaction. '
500b C                                      + 'Transaction has been '
500b C                                      + 'started in a multiple '
500b C                                      + 'transaction assignment. '
417b C                   leavesr
417b C                   endif
640cA*
     *  Check for Flags (shorts)
640cA*
417d C                   exsr      zzflag
417d C                   if        error = '1'
500b C                   eval      pMessage = 'Cannot close transaction. '
500b C                                      + 'Flag is pending. '
417d C                   leavesr
417d C                   endif
640cA*
500d *  Check for WORKSOS Single Order Selection in use
640cA*
500d C                   exsr      zzwsos
500d C                   if        error = '1'
500b C                   eval      pMessage = 'Cannot close transaction. '
500b C                                      + 'WORKSOS records pending. '
500b C                                      + 'There is at least one SOS '
500b C                                      + 'item being worked on. '
500d C                   leavesr
500d C                   endif
     *
     *  Call delete program
     *
     C                   eval      $pcmd = '*CLOSE  '
     C                   eval      $puky = dsukey
413 MC                   call      @delpg
413 MC                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
500d C                   eval      error = *on
     C                   eval      pMessage = $perm
     C                   else
     C                   eval      pMessage = 'Transaction '
     C                               + %char(pTran#) + ' '
     C                               + 'closed successfully'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  GetTran   See if Transaction exists
     *----------------------------------------------------------------

     C     GetTran       begsr
      /free

         chain (pTran#) pirtran;
         if not %found(pirtran);
           clear recordu;
           trnNotFound = *on;
         else;
           trnNotFound = *off;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    kywhse
     C                   kfld                    kygrp2
     C                   kfld                    kyrtpo
415aA*
415aA*  Define partial key for LABEL8 file.
415aA*
415aAC     keylb         klist
415aAC                   kfld                    $kwhse
415aAC                   kfld                    $krtid
415aAC                   kfld                    kypo
415aAC                   kfld                    pttrn#
     *
530bA*  Define partial key for LABEL7 file.
     *
530bAC     keylb7        klist
530bAC                   kfld                    pttrn#
     *
640bA*  Define partial key for LABEL7 file.
     *
640bAC     keylb7u       klist
640bAC                   kfld                    uktrn#
     *
417d *  Define partial key for LABEL90
     *
417d C     l90key        klist
417d C                   kfld                    ukwhse
417d C                   kfld                    uktrn#
     *
530bA*  Define key for ORDC1 file.
     *
530bAC     keyoc1        klist
530bAC                   kfld                    $kwhse
530bAC                   kfld                    lblbl#
620aA*
620aA*  Define partial key for LABEL76
620aA*
620aAC     kylab76       klist
620aAC                   kfld                    $kwhse
620aAC                   kfld                    $krtid
620aAC                   kfld                    uktrn#
620aA*
620aA*  Define partial key for PREXREF2
620aA*
620aAC     kyprex2       klist
620aAC                   kfld                    $kwhse
620aAC                   kfld                    $krtid
620aA*
620bA*  Define partial key for PREXREF1
620aA*
620bMC     kyprex1       klist
620aAC                   kfld                    L76_lbwhse
620aAC                   kfld                    L76_rhrte
620aAC                   kfld                    L76_ohcord
620aAC                   kfld                    L76_lbitem
     *
     *  Define partial key for RTEHED file.
     *
     C     keyrh         klist
     C                   kfld                    $kwhse
     C                   kfld                    $krtid
     *
500d *  Define partial key for WORKSOS2
     *
500d C     wsokey        klist
500d C                   kfld                    ukwhse
500d C                   kfld                    uktrn#

620aAC     kyprex2       setll     pxrec2
620aAC     kyprex2       reade     pxrec2
620aAC                   if        %eof
620aAC                   eval      hasPrepick = *off
620aAC                   else
620aAC                   eval      hasPrepick = *on
620aAC                   endif
     *
     C                   endsr
417b *----------------------------------------------------------------
417b *
417b *  ZZMULT   Check if transaction is a multiple scan transaction.
417b *            Note: IF multiple, must end using TE130 task entry.
417b *
417b C     zzmult        begsr
417b C     uktrn#        chain     multran1                           75
417b C                   if        not *in75  and
417b C                             mustat = '1'
417b C                   eval      error = *on
417b C                   endif
417b C                   endsr

     *----------------------------------------------------------------
640cA*  ZZChkCW - Check for any C/W not entered.
     *
     C     zzchkCW       begsr

     C                   eval      clsall = *on
     C     uktrn#        chain(n)  pirtran
     *
     C                   eval      ukwhse = ptwhse
     C                   eval      ukrte = *blanks
     C                   eval      ukpo = ptrtpo
     C                   eval      uktrn# = pttrn#
     *
     C                   if        ptstat <> '4'
     C                   exsr      zzcw
     C                   endif

640cAC                   endsr

620aA*----------------------------------------------------------------
620aA*  ZZCHKPrepick  Check Pre-Pick transactions.
620aA*                Stop user from touching a Normal transaction if the
620aA*                corresponding Pre-Pick transactions aren't closed.
620aA*
620aAC     zzchkPrepick  begsr

620aA*  If transaction doesn't have associated prepick, leave.

     C                   if        not hasPrepick
     C                   leavesr
     C                   endif

620aA*  Loop through labels for normal transaction.

     C     kylab76       setll     label76
     C                   dow       forevr = forevr
     C     kylab76       reade     label76
     C                   if        %eof
     C                   leave
     C                   endif

620aA*    Get corresponding prexref record.

620bMC     kyprex1       setll     prexref1
     C                   dow       forevr = forevr
620bMC     kyprex1       reade     prexref1
     C                   if        %eof
     C                   leave
     C                   endif
620dA*
620dA*      If PRE transaction not closed,

620dAC                   if        $krtid <> pxnrte
620dAC                   iter
620dAC                   endif

620aA*      If PRE transaction not closed,
620aA*        Then normal transaction cannot be touched.

     C     pxtrn#        chain     pirtran
     C                   if        not %found
     C                             or %found and ptstat < '4'
     C                   eval      error = *on
     C                   eval      pMessage = 'Cannot close tran# '
     C                             + %char(pxtrn#) + ' - '
     C                             + 'Pre-Pick transaction not closed '
     C                             + 'for route '
     C                             + %trim(pxhrte)
     C                   leavesr
     C                   endif

     C                   enddo

     C                   enddo

     C                   endsr
500b *----------------------------------------------------------------
500b *
500b *  ZZCHKT   Check if transaction is status 2=started.
500b *            Note: IF status 2, must end using TE130 task entry.
500b *
500b C     zzchkt        begsr
500b C     uktrn#        chain     pirtran                            75
500b C                   if        not *in75  and
500b C                             ptstat = '2'  or
510 A*
510 A*     -or- Transaction suspended, interupted.
510 AC                             not *in75  and
510 AC                             ptstat > '4'
500b C                   eval      error = *on
500b C                   endif
500b C                   endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  zzChkUSR  Check to see if any labels have USR slot.
640bA*
640bAC     zzChkUSR      begsr
     *
     C     keylb7u       setll     label7
     C                   dow       forevr = forevr
     C     keylb7u       reade     label7
     C                   if        %eof
     C                   leave
     C                   endif
     *
     *      If USR slot, turn on error and get out.
     C                   if        lbaisl = 'USR'
     C                   eval      error = *on
     C                   eval      pMessage = 'Cannot close tran# '
     C                             + %char(uktrn#) + ' - '
     C                             + 'USR slot exists.'
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
530bA*----------------------------------------------------------------
530bA*
530bA*  ZZCW     Check to see if c/w records exist.
530bA*
530bAC     zzcw          begsr
     C                   eval      cwflg = *off
     C                   eval      cwitm = *off
     C     keylb7        setll     label7
     C                   dow       forevr = forevr
     C     keylb7        reade     label7                                 78
     C                   if        *in78
610cMC                             or cwitm = *on
610cAC                             and cwflg = *off
     C                   leave
     C                   endif
610cAC                   eval      cwflg = *off
610cAC                   eval      cwitm = *off
530cA*
530cA*      Omit Merge label records from catchwgt tests.
530cAC                   if        lbtype = 'M'
530cAC                   iter
530cAC                   endif
610dA*      Omit LBQPCK = 0 records from catchwgt tests.
610dAC                   if        lbqpck = 0
610dAC                   iter
610dAC                   endif
530cA*
     C                   if        itcwgt = 'Y'
     C                   eval      cwitm = *on
610cAC                   else
610cAC                   iter
     C                   endif
     *  Set on c/w flag if c/w records exist.
     C     keyoc1        setll     ordc1
     C                   dow       forevr = forevr
620cMC     keyoc1        reade(n)  ordc1                                  79
     C                   if        *in79
     C                   leave
     C                   else
610cAC                   if        occwgt <> 0
     C                   eval      cwflg = *on
     C                   eval      cwitm = *on
     C                   leave
610cAC                   endif
     C                   endif
     C                   enddo
     *
610cAC                   if        cwitm = *on
610cAC                             and cwflg = *off
610cAC                   eval      error = *on
     C                   eval      pMessage = 'No catch weight '
     C                             + 'entered for tran# '
     C                             + %char(lbtrn#) + ', '
     C                             + 'item ' + %trim(lbitem) + '.'
610cAC                   endif
     C                   enddo
     *
530bAC                   endsr
     *----------------------------------------------------------------
417d *
417d *  ZZFLAG   Check if there are open flags (shorts) for this
417d *           transaction.
417d *
417d C     zzflag        begsr
     C     l90key        setll     label90
     C                   dow       forevr = forevr
620cMC     l90key        reade(n)  label90                                79
417eAC                   if        *in79
417eAC                   leave
417eAC                   endif
     C                   if        not *in79  and
     C                             lbvrfy = 'F'  or
417fAC                             not *in79  and
417fAC                             lbvrfy = 'I'
     C                   eval      error = *on
     C                   leave
     C                   endif
     C                   enddo
417d C                   endsr
500dA*----------------------------------------------------------------
500d *
500dA*  ZZWSOS   Check if there are SOS work records for this
500dA*           transaction (product not moved to new slot yet)
500d *
500dAC     zzwsos        begsr
500d C     wsokey        setll     worksos2
500d C                   dow       forevr = forevr
500d C     wsokey        reade     worksos2                               79
500d C                   if        *in79
500d C                   leave
500d C                   endif
500d C                   if        not *in79
500d C                   eval      error = *on
500d C                   leave
500d C                   endif
500d C                   enddo
500dAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSTAT   Status check.
     *           Change RTEHED status to '5' when all transactions
     *           have been closed.
     *
     C     zzstat        begsr
     *
     *  Loop through all the transaction for route.
     *
     C                   eval      close = *on
     C     partky        setll     pirtran4
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If not a selection or letdown record then loop.
     *
     C                   if        ptgrp1 <> 'S'
     C                   iter
     C                   endif
     *
     *     If transaction is not closed, we're done.
     *
     C                   if        ptstat < '4'  or
510 AC                             ptstat > '4'
     C                   eval      close = *off
415aAC                   unlock    pirtran4
     C                   leave
     C                   endif
     *
415aA*    Check to make sure that all label records are closed.
415aA*    Note: If label records found that are not closed, if
415aA*          transaction is marked as closed, reset back to
415aA*          ended status so that records can be closed.
415aA*
416aMC     keylb         setll     label8
416aAC                   read      label8                                 77
416aMC                   if        not *in77  and
416aMC                             l8trn# = pttrn#
415aAC                   eval      close = *off
415aAC                   if        ptstat = '4'
415aAC                   eval      ptstat = '3'
415aAC                   update    record
415aA*
415aAC                   else
415aAC                   unlock    pirtran4
415aAC                   endif
415aA*
415aAC                   leave
415aAC                   endif
415aA*
     C                   enddo
     *
     *  If all transaction were closed, update status.
     *
     C                   if        close = *on
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
412 AC                   if        rhstat < '5'
     C                   eval      rhstat = '5'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   update    rhrec
412 AC                   else
412 AC                   unlock    rtehed
412 AC                   endif
416bA*  Update picked qty, wt, and cube.
416bAC                   call      @pckrt
416bAC                   parm                    rhwhse
416bAC                   parm                    rhrtid
EFCaAC                   if        client = eastland
EFCbA*  Print SOS Slot Transfer Qty Report.
EFCbAC                   eval      $lcmd = '*PRINT  '
EFCbAC                   eval      $lrtn = *blanks
PAKb C                   move      rhwhse        $pwhse
PAKb C                   move      rhrtid        $prtid
EFCbAC                   call      'OR320CL'
EFCbAC                   parm                    $lcmd             8
EFCbAC                   parm                    $Pwhse            3
EFCbAC                   parm                    $prtid            5
EFCbAC                   parm      '*JOB      '  DEV              10
EFCbAC                   parm      '*STD      '  FORM             10
EFCbAC                   parm                    $lrtn             8
EFCbAC                   endif
     C                   endif
     C                   endif
415aA*
415aA*    Release record lock on PIRTRAN4.
415aAC                   unlock    pirtran4
     *
     C                   endsr

620cA*----------------------------------------------------------------
620cA*  updNrmTran      Update normal transactoin from pre transaction
620cA*----------------------------------------------------------------
620cA
620cAC     updNrmTran    begsr

      /free

         // If transaction doesn't have associated prepick, leave.

         if not hasPrepick;
           leavesr;
         endif;

         // Read through normal transaction label records

         setll ($kwhse: uktrn#) label90;

         dow forever = forever;

           reade ($kwhse: uktrn#) label90;

           if %eof(label90);
             leave;
           endif;

           // Get corresponding prexref record for normal label

           setll ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           reade ($kwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           if %eof(prexref4);
             iter;
           endif;

           if pxcpyf = 'Y';
             unlock prexref4;
             iter;
           endif;

           // Get corresponding pre-pick label

           chain (pxlbl#) label;

           if not %found(label);
             iter;
           endif;

           // Update normal label pick qty

           if lbqpck = L_lbqpck;
             unlock label90;
           else;
             lbqpck = L_lbqpck;
             update lbrec;
           endif;

           // Copy catch weights

           setll (L_lbwhse: L_lblbl#) ordc1;

           dow forever = forever;

             reade (L_lbwhse: L_lblbl#) ordc1;
             if %eof(ordc1);
               leave;
             endif;

             ocord  = lbord;
             ocseq# = lbseq;
             octran = lbtrn#;
             oclbl# = lblbl#;

             write(e) ocrec;

           enddo;

           // Copy Trax numbers


           // Update prexref copy flag

           pxcpyf = 'Y';
           update pxrec4;

         enddo;

      /end-free

     C                   endsr
