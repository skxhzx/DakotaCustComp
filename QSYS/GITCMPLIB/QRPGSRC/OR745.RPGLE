     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR745    Export Route Details for Goal Time Calcs
     *  29 September 2009
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    09/29/09  MLB  5.20
     *      - Created.
     *      - Client custom code support included.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
xxx A*    mm/dd/yy  iii  ccc
     *      -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  78        - EOF for ORDH
     *  79        - EOF for ORDD
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Flabel90   if   e           k disk
     Fpltsum3   if   e           k disk
     Fpltsum12  if   e           k disk
     F                                     prefix(p12)
     F                                     rename(psrec:psrec12)
     Fexpfgoal  o  a e           k disk
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Working variables
     *
     D batchplts       s              5  0
     D error           s              1
     D palletcnt       s              5  0
     D svplid          s                   like(psplid)
     D today           s              8  0
     *----------------------------------------------------------------
     *  Constants
     *
     D forever         c                   const('1')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *
     * Data structure
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $prte             5
     C                   parm                    $prtn             8
     * Main line
     *
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     *
     *  Process Pallet Summary file.
     *
     C     keyps3        setll     pltsum3
     C                   dow       forever = forever
     C     keyps3        reade     pltsum3
     *
     C                   if        %eof(pltsum3)
     C                   leave
     C                   endif
     *
     *      Omit pallet records with no transaction assigned.
     C                   if            pstrn# = 0
     *      Omit pallet records where nothing was picked.
     C                              or pspcs = 0
     C                   iter
     C                   endif
     *
     *      Count pallets on transaction.
     C                   exsr      cntpallets
     *
     *      Count number of aisles on transaction.
     C                   exsr      cntaslchgs
     *
     *      Count catchweight/non-catchweigh pieces on transaction.
     C                   exsr      cntpieces
     *
     *      Count number of unique items on transaction.
     C                   exsr      cntitems
     *
     *      Count number of batch pick pallets on transaction.
     C                   exsr      cntbatplts
     *
     *      Move data into export file record.
     C                   exsr      filgel
     *
     C                   write     gelrec
     *
     C                   enddo
     *
     C     bottom        tag
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *   Define partial key for LABEL90 file.
     *
     C     keylb90       klist
     C                   kfld                    $pwhse
     C                   kfld                    pstrn#
     *
     *   Define partial key for PLTSUM3 file.
     *
     C     keyps3        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *   Define full key for PLTSUM12 file.
     *
     C     keyps12       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    pstrn#
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CNTASLCHGS  Count number of aisle changes on transaction.
     *
     C     cntaslchgs    begsr
     *
     *     Count number of aisles on transaction.
     C                   call      'CNTASLCHG'
     C                   parm      pswhse        $iwhse
     C                   parm      psrtid        $irtid
     C                   parm      pstrn#        $itrn#            7 0
     C                   parm      0             $inbrasl          5 0
     C                   parm      ' '           $ireturn
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CNTBATPLTS  Count number of batch pick pallets on transaction.
     *
     C     cntbatplts    begsr
     *
     *     Count number of batch pick pallets on transaction.
     C     keylb90       setll     label90
     C     keylb90       reade     label90
     C                   if        %eof(label90)
     C                   eval      batchplts = 0
     C                   else
     C                   if        %subst(lbpo:6:4) > ' '
     C                   eval      batchplts = 1
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CNTITEMS   Count number of unique items on pallet.
     *
     C     cntitems      begsr
     *
     *     Count number of items on pallet.
     C                   call      'CNTPLTITM'
     C                   parm      pswhse        $iwhse            3 0
     C                   parm      psrtid        $irtid            5
     C                   parm      psplid        $iplid            7 0
     C                   parm      0             $iitems           5 0
     C                   parm      '  '          $ipltsct          2
     C                   parm      ' '           $ireturn          8
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CNTPALLETS   Count number of Pallets on Transaction.
     *
     C     cntpallets    begsr
     *
     C                   eval      palletcnt = 0
     C                   eval      svplid = -9999999
     C     keyps12       setll     pltsum12
     C                   dow       forever = forever
     C     keyps12       reade     pltsum12
     C                   select
     C                   when      %eof(pltsum12)
     C                   leave
     C                   other
     C                   if        p12psplid <> svplid
     C                   eval      palletcnt = palletcnt + 1
     C                   eval      svplid = p12psplid
     C                   endif
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  CNTPIECES  Count number of catchweight/non-catchweight pieces.
     *
     C     cntpieces     begsr
     *
     *     Count number of catchweight/non-catchweight pieces on pallet.
     C                   call      'CNTTRNPCS'
     C                   parm      pswhse        $iwhse
     C                   parm      psrtid        $irtid
     C                   parm      pstrn#        $itrn#
     C                   parm      0             $incwtpcs         5 0
     C                   parm      0             $icwgtpcs         5 0
     C                   parm      ' '           $ireturn
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  FILGEL   Fill export Goal fields.
     *
     C     filgel        begsr
     *
     *  Initialize record
     *
     C                   clear                   gelrec
     *
     *  Move fields from file fields to export file.
     *
     C                   eval      gelwhs = $pwhse
     C                   eval      gelrte = $prte
     C                   eval      gelrid = $prtid
     C                   eval      geltrn = pstrn#
     C                   eval      gelszn = psszon
     *
     C                   eval      gelpal = palletcnt
     C                   eval      gelasl = $inbrasl
     C                   eval      gelnwg = $incwtpcs
     C                   eval      gellin = $iitems
     C                   eval      gelwgt = $icwgtpcs
     C                   eval      gelbat = batchplts
     *
     C                   endsr
