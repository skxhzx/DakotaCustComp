      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  LD637D    Delete Ldrhdr and Ldrdetl records within route.
     *  8 February 2011
     *  Jose G. Duque
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640 A*    02/08/11  JGD  6.40
     *      - Created
     *
650aA*    01/20/15  RBD  6.50a
     *      - Recompiled, LDRDETL file changed.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fldrhdr3   uf   e           k disk
     Fldrdetl   uf   e           k disk

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D forever         s               n

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
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     keyldrh       setll     ldrhdr3
     C*
     C                   dow       forever = forever
     C     keyldrh       reade     ldrhdr3
     C                   if        %eof
     C                   leave
     C                   else
     C     keyldrd       setll     ldrdetl
     C                   dow       forever = forever
     C     keyldrd       reade     ldrdetl
     C                   if        %eof
     C                   leave
     C                   else
     C                   delete(e) lddrec
     C                   endif
     C                   enddo
     C                   delete(e) lhrec
     C                   endif
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

     *  Define partial key for LDRHDR3 file.

     C     keyldrh       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define partial key for LDRDETL file.

     C     keyldrd       klist
     C                   kfld                    $pwhse
     C                   kfld                    lhrte
     C                   kfld                    $prtid

     C                   endsr
