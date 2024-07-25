510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNORDDM   Clean up ORDDM records with no associated ORDH
     *  07 April 2009
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    04/06/09  GJA
     *      - Created

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Forddm     uf   e           k disk
     Fordh      if   e           k disk

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     Keyddm        klist
     C                   kfld                    omwhse
     C                   kfld                    omord
     C                   read      orddm
     C                   if        not %EOF(orddm)
     *  look to see if order exist in order header file
     C     Keyddm        chain     ordh
     C                   if        not %found(ordh)
     C                   delete    omrec
     C                   end
     C                   end

     *  End of file
     C                   if        %EOF(orddm)
     C                   eval      *inlr = *On
     C                   return
     C                   end
