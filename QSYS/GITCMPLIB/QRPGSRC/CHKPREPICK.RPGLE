     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CHKPREPICK   Check Pre-Pick route status by customer order
     *               and transactions.
     *
     *  19 Nov 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
610 A*   11/19/10  RBD  6.10
     *     - Created.
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fordh4     if   e           k disk
     Fprexref3  if   e           k disk
     Frtehed    if   e           k disk
     *
     *----------------------------------------------------------------
     *  Work fields
     *
     D forevr          s              1
     D lasttrn#        s              7  0
     *
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warhouse
     *     $PRTE    -  Route
     *     $PRTID   -  Route Id
     *
     *  Output parameters
     *
     *     $PRTN    - *OK    - All transactions for the Pre-Pick route
     *                         are status Pick/Printed or beyond.
     *                *ERROR - At least 1 transaction has not reached
     *                         Pick/Printed status.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prte             5
     C                   parm                    $prtid            5
     C                   parm                    $prtn             8
     *
     *----------------------------------------------------------------
     *  Main line
     *
     *   Initialize return parameters.
     *
     C                   eval      $prtn  = '*OK     '
     *
     *   Loop through normal route's orders. For each order, loop
     *   through corresponding pre-pick route transactions, and
     *   if you encounter one whose associated route status is
     *   less than 4, set return code to *ERROR and you're done.
     *   Otherwise, you will return *OK.
     *
     C     keyordh4      setll     ordh4
     C                   dow       not %eof(ordh4)
     C     keyordh4      reade     ordh4
     C                   if        %eof
     C                   leave
     C                   endif
     *
     *    Loop through pre-pick routes.
     *
     C                   eval      lasttrn# = 0
     C     keyprex3      setll     prexref3
     C                   dow       not %eof(prexref3)
     C     keyprex3      reade     prexref3
     C                   if        %eof
     C                   iter
     C                   endif

     C                   if        pxtrn# = lasttrn#
     C     keyprex3a     setgt     prexref3
     C                   iter
     C                   endif
     C                   eval      lasttrn# = pxtrn#

     C     keyrteh       chain     rtehed
     C                   if        not %found(rtehed)
     C                             or rhstat < '4'
     C                   eval      $prtn = '*ERROR  '
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   if        $prtn = '*ERROR  '
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define partial key for ORDH4 file.
     *
     C     keyordh4      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     *  Define partial key for PREXREF3 file.
     *
     C     keyprex3      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    ohcord
     *
     *  Define partial key for PREXREF3 file.
     *
     C     keyprex3a     klist
     C                   kfld                    $pwhse
     C                   kfld                    $prte
     C                   kfld                    ohcord
     C                   kfld                    pxtrn#
     *
     *  Define full key for RTEHED file.
     *
     C     keyrteh       klist
     C                   kfld                    $pwhse
     C                   kfld                    pxprte
     *
     C                   endsr
     *
     *----------------------------------------------------------------
