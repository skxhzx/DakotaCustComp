      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *----------------------------------------------------------------
     *
     *  QDCBI011
     *
     *    Created pgm to remove old Routid's from file.
     *
     *----------------------------------------------------------------
     *  11 July  2017
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     * File Specs

     Fcadecrte  uf   e           k disk
     Frtehed    if   e           k disk

     *----------------------------------------------------------------
     *  Working variables

520jAD $pwhse          s              3  0 inz(001)
510bAD forever         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      -None-
     *
     *    Returned Parameters
     *      -None-
     *
     *----------------------------------------------------------------
     *  Let the show begin .....

     C     key           klist
     C                   kfld                    $pwhse
     C                   kfld                    crfrte

510bAC                   eval      *inlr = *on

     * Main line

510bAC     *loval        setll     cadecrte
510bAC                   dow       forever = forever
510bAC                   read      cadecrte
510bAC                   if        %eof(cadecrte)
510bAC                   leave
510bAC                   endif

510cAC     key           chain     rtehed
     C                   if        not %found(rtehed)
510cAC                   delete    crfrec
510cAC                   endif

510bAC                   enddo
