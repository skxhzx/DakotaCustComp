650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS761      Clean up BFCDEBUG records
     *  21 August 2019
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730aA*    08/21/19  LMC   7.30a
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fbfcdebug  uf   e           k disk

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
     c                   read      bfcdebug
      /free
       if %eof(bfcdebug);
        leave;
       endif;

       if bdaddts = dfttimestamp;
        iter;
       endif;

       if  bdaddts > CDateTS;
        leave;
       endif;

       if bdaddts < CDateTS;
        delete bdrec;
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
