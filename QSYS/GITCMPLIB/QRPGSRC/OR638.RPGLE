417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OR638     Truck build - Assign PIR seq#
     *  07 October 2006
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    10/07/06  DAS  5.10
     *      - Created
510aA*    05/30/07  MLB  5.10a
     *      - Fix: Revised program to loop if the LABEL11
     *        record read doesn't match the route being
     *        processed.
520 A*    05/13/08  RBD  5.20
     *      - Recompiled only, LABEL32X changed.
640aA*    04/13/11  DAS  6.40
     *      - Revised to use PLTSUM12 instead of PLTSUM3. This will
     *        allow the program to handle multiple transactions within
     *        a zone.
     *      - With the use of this file we are assuming all the
     *        transactions for a zone will be consecutive.
700aA*    12/28/15  RH   7.00a
     *      - Enh: Change IF to Select to add ICB mod.
700 A*    03/10/16  MLB  7.00b
     *      - Recompiled only, LABEL32X changed.
     *
     *----------------------------------------------------------------
     *  Client custom revisions - Inter County Bakery
ICBaA*    12/28/15  JCJ/RH ICBa
     *      - Add to print PIR Count Label - ICB uses LABEL32D
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

640aDF*ltsum3   if   e           k disk
640aMFpltsum12  if   e           k disk
     Flabel32c  if   e           k disk
     Flabel32x  if   e           k disk
ICBaAFlabel32d  if   e           k disk
     Flabel11   if   e           k disk
     Fpirseq1   uf a e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#citylin
      /copy qcopysrc,id#icb

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
     *  Variables
     *----------------------------------------------------------------

     D @psect          s              2
     D $pwhse          s              3  0
     D forevr          s              1
     D kylbl#          s                   like(lblbl#)
     D kyltyp          s                   like(lbtype)
     D kytype          s                   like(pstype)
     D lstzon          s                   like(psszon)
     D mergeseq#       s                   like(psqbeg)
     D nextseq#        s                   like(psqbeg)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtid            5
     C                   move      $whse         $pwhse

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Delete all existing pirseq records for route.

     C                   exsr      delpirseq

     *  Loop through pallets like OR640/PFMT does.

640aDC**                 eval      kytype = 'O'
     C                   move      *hival        lstzon
640aDC**   keyps3        setll     pltsum3
640aMC     keyps12       setll     pltsum12

     C                   dow       forevr = forevr
640aDC**   keyps3        reade     pltsum3
640aMC     keyps12       reade     pltsum12
     C                   if        %eof
     C                   leave
     C                   endif

     *    Skip ...
640aD ***    Duplicate zones. (we now allow dup zones)
     *      Generation 1 zones.
     *      Zero transaction number.
640aM*      Type not 'O'.

640aDC**                 if        psszon = lstzon
640aMC                   if        pstype <> 'O'
     C                             or psgen =1
     C                             or pstrn# = 0
     C                   iter
     C                   endif

640aA*    Assign PIR sequence numbers for zone.
640aA
640aAC                   if        psszon <> lstzon
640aAC                   eval      nextseq# = 1
     C                   eval      lstzon = psszon
640aAC                   endif

     *    Assign PIR sequence numbers for zone.

     C                   exsr      assignPIR
     *
     C                   enddo

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forevr = *off

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    client2          10

     *  Define partial key for PIRSEQ1 file.

     C     keypsq        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

640aD ** Define partial key for PLTSUM3 file.
640aD **
640aDC**   keyps3        klist
640aDC**                 kfld                    $pwhse
640aDC**                 kfld                    $prtid
640aDC**                 kfld                    kytype

640aA*  Define partial key for PLTSUM12 file.
640aA
640aAC     keyps12       klist
640aAC                   kfld                    $pwhse
640aAC                   kfld                    $prtid

     *  Define partial key for LABEL32.

     C     keyl32        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    kyltyp
     C                   kfld                    pstrn#

     *  Define partial key for LABEL11 file.

     C     keylb11       klist
     C                   kfld                    kylbl#

     C                   endsr

     *----------------------------------------------------------------
     *  assignPIR  Assign seq# to PIR labels.
     *----------------------------------------------------------------

     C     assignPIR     begsr

640aD ** Start sequence at 1 for each zone.
640aD **
640aDC**                 eval      nextseq# = 1

     *  Read records in PFMT PRTSEL order.

     C                   move      'O'           kyltyp
700aAC                   select
700aDC*                  if        client = cityline
700aMC                   when      client = cityline
     C     keyl32        setll     label32x
ICBaAC                   when      client = ICB
ICBaAC     keyl32        setll     label32d
700aMC                   other
700aDC*                  else
     C     keyl32        setll     label32c
700aDC*                  endif
700aMC                   endsl

     C                   dou       forevr <> forevr
700aAC                   select
700aAC                   when      client = cityline
     C     keyl32        reade     label32x                               78
ICBaAC                   when      client = ICB
ICBaAC     keyl32        reade     label32d                               78
700aAC                   other
700aAC     keyl32        reade     label32c                               78
700aAC                   endsl
700aDC*                  if        %eof
700aMC                   if        *in78
     C                   leave
     C                   endif

     *     Skip label if nothing was picked.

     C                   if        lbqpck = 0
     C                   iter
     C                   endif

     *     Create PIRSEQ record for PIR record.

     C                   eval      psqwhs = pswhse
     C                   eval      psqrid = psrtid
     C                   eval      psqtrn = pstrn#
     C                   eval      psqlbl = lblbl#
     C                   exsr      getpltsect
     C                   eval      psqind = @psect
     C                   eval      psqbeg = nextseq#
     C                   eval      psqend = nextseq# + lbqpck - 1
     C                   eval      nextseq# = psqend + 1
     C                   eval      psqpid = psplid
     C                   eval      psqpal = pspal#
     C                   eval      psqgen = psgen
     C                   write     psqrec

     *     Now assign sequence number to merge range.

     C                   exsr      assignmerge

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  assignMerge  Assign seq# to merge labels.
     *----------------------------------------------------------------

     C     assignMerge   begsr

     C                   eval      mergeseq# = psqbeg

     *  Read corresponding merge record(s) for label.

     C                   eval      kylbl# = lblbl#
     C     keylb11       setll     label11

     C                   dou       forevr <> forevr
     C     keylb11       reade     label11
     C                   if        %eof
     C                   leave
     C                   endif

     *     Skip label if nothing was picked.

     C                   if        lbqpck = 0
510aA*     Or wrong warehouse, wrong route id
510aA*     or wrong Group Code type, skip label.
510aAC                             or lbwhse <> $pwhse
510aAC                             or lbrte  <> $prtid
510aAC                             or lbgrp1 <> 'S'
     C                   iter
     C                   endif

     *     Get pallet information for Merge record.

     C                   call      'GETPALLET'
     C                   parm                    $pwhse
     C                   parm                    $prtid
     C                   parm      'O'           $gtype            1
     C                   parm                    lbpal#
     C                   parm                    $gpal#            7 0
     C                   parm                    $gtzon            6
     C                   parm                    $gpzon            6
     C                   parm                    $gszon            6
     C                   parm                    $gcomp            1
     C                   parm                    $ggen             1 0
     C                   parm                    $gtruk           10
     C                   parm                    $gunld            2 0
     C                   parm                    $grow             2 0
     C                   parm                    $gcol             1 0
     C                   parm                    $gstp1            2 0
     C                   parm                    $gstp2            2 0
     C                   parm                    $gpcs             5 0
     C                   parm                    $gcube            7 3
     C                   parm                    $gswgt            9 2
     C                   parm                    $gbcnt            1 0
     C                   parm                    $gflag            1
     C                   parm                    $glbl#            7 0
     C                   parm                    $gtrn#            7 0
     C                   parm                    $greturn          8

     *     Create PIRSEQ record for mrege label.

     C                   eval      psqwhs = pswhse
     C                   eval      psqrid = psrtid
     C                   eval      psqtrn = lbtrn#
     C                   eval      psqlbl = lblbl#
     C                   exsr      getpltsect
     C                   eval      psqind = @psect
     C                   eval      psqbeg = mergeseq#
     C                   eval      psqend = mergeseq# + lbqpck - 1
     C                   eval      mergeseq# = psqend + 1
     C                   eval      psqpid = lbpal#
     C                   eval      psqpal = $gpal#
     C                   eval      psqgen = $ggen
     C                   write     psqrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  delpirseq   Delete all existing PIRSEQ records for route.
     *----------------------------------------------------------------

     C     delpirseq     begsr

     C     keypsq        setll     pirseq1

     C                   dou       forevr <> forevr
     C     keypsq        reade     pirseq1
     C                   if        %eof
     C                   leave
     C                   else
     C                   delete    psqrec
     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getpltsect   Get pallet section
     *----------------------------------------------------------------

     C     getpltsect    begsr

500eAC                   if        lbhnd2 = '*P'
500eAC                   call      'GETSCID'
500eAC                   parm      *blanks       $scmd             8
500eAC                   parm      lbwhse        $swhse            3 0
500eAC                   parm      lblbl#        $slbl#            7 0
500eAC                   parm      lbqpck        $scas#            5 0
500eAC                   parm      *blanks       $sscid            2
500eAC                   parm      *blanks       $srtn             8
500eAC                   if        $srtn = '*OK'
500eAC                   move      $sscid        @psect
500eAC                   else
500eAC                   eval      @psect = *blanks
500eAC                   endif
500eAC                   else
CLDdAC                   move      lbhnd2        @psect
500eAC                   endif

     C                   endsr
