      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR635D    Delete TOTEHDR records within a route.
     *  06 Oct 2008
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    10/06/08  RBD  5.20  P#00011
     *      - Created
     *
CWD A*    04/28/15  MLB  CWD  P#01349
     *      - Enh: Re-compiled pgm. Physical file had order id added
     *        to make file key unique.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftotehdr   uf   e           k disk

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

     C     keytote       setll     totehdr
     C*
     C                   dow       forever = forever
     C     keytote       reade     totehdr
     C                   if        %eof
     C                   leave
     C                   else
     C                   delete(e) tohrec
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

     *  Define partial key for TOTEHDR file.

     C     keytote       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     C                   endsr
