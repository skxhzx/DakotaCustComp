650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS754      Clean up DDLOG records
     *  26 July 2013
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    07/26/13  JCJ   6.50a
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fddlog1    uf   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D dfttimestamp    s             26z
     D cdatets         s             26z
     D forevr          s              1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     c     forevr        doweq     forevr
     c                   read      ddlog1
      /free
       if        %eof(ddlog1);
        leave;
       endif;

       if ddladdts = dfttimestamp;
        iter;
       endif;

       if  ddladdts > CDateTS;
        leave;
       endif;

       if ddladdts < CDateTS;
        delete ddlrec;
       endif;

      /end-free
     c                   enddo

     *  End of file
     c                   eval      *inlr = *On
     c                   return
     *--------------------------------------------------------------
     *  *INZSR
     c     *inzsr        begsr

      /free
       CDateTS = %timestamp();
       CDateTS = CDateTS - %days(14);
      /end-free

     C                   endsr
