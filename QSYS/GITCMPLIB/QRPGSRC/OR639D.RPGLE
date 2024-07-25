520 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR639D    Delete unique sscc-18 numbers within route.
     *  06 February 2008
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    02/06/08  RBD  5.20  P#00003
     *      - Created
     *
520aA*    03/21/08  DAS  5.20a P#00003
     *      - Changed definition of $PWHSE from Packed to Signed
     *        because that is the way it is defined from calling
     *        program RH134.
     *
520bA*    09/25/08  RBD  5.20b P#00003
     *      - Reverse 5.20a rev, was causing dec data error.
     *        Defined $pwhse as 3-0 in calc.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fordad     uf   e           k disk
     Fordh4     if   e           k disk

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D forever         s               n
520aAD*$pwhse          s              3S 0   **520bD**

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
520aMC**520bD            parm                    $pwhse
520bMC                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Read through order header for the route, then use order# to
     *  delete the records in ORDAD.

     C     keyoh4        setll     ordh4

     C                   dow       forever = forever
     C     keyoh4        reade     ordh4
     C                   if        %eof
     C                   leave
     C                   endif

     C     keyord        setll     ordad

     C                   dow       forever = forever
     C     keyord        reade     ordad
     C                   if        %eof
     C                   leave
     C                   else
     C                   delete(e) ordrec
     C                   endif
     C                   enddo

     C                   enddo

     *  Bye, Bye

     C     bottom        tag
     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *inzsr  -  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define partial key for ORDAD file.

     C     keyord        klist
     C                   kfld                    $pwhse
     C                   kfld                    ohord

     *  Define partial key for ORDH4 file.

     C     keyoh4        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr
