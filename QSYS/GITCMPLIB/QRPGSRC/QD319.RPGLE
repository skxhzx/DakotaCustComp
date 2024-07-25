      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  QD319     Delete WORKLBL rec if no LABEL and no RTEHED match.
     *  19 Mar 2010
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
530 A*    03/19/10  RBD  5.30
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fworklbl   uf   e           k disk
     Flabel     if   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Variables.
     *----------------------------------------------------------------

     D ctr             s              5  0
     D diff            s              5  0
     D forever         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     *loval        setll     worklbl
     C                   dow       forever = forever
     C                   read      worklbl
     C                   if        %eof(worklbl)
     C                   leave
     C                   endif

     C     lwlbl#        setll     label
     C                   if        not %equal(label)
     C     keyrte        chain     rtehed
     C                   if        not %found(rtehed)
     C                             or %found(rtehed)
     C                             and rhstat > '6'
     C                   delete    lwrec
     C                   endif
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

     *  Define key for RTEHED.

     C     keyrte        klist
     C                   kfld                    lwwhse
     C                   kfld                    lwrte

     C                   endsr
