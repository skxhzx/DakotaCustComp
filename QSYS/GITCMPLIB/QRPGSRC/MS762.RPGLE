      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS762      Clean up UPCLOGD  records
     *  26 February 2020
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740 A*    02/26/20  LMC   7.40
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fupclogd   uf   e           k disk

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
     c                   read      upclogd
      /free
       if %eof(upclogd);
        leave;
       endif;

       if udaddts = dfttimestamp;
        iter;
       endif;

       if  udaddts > CDateTS;
        leave;
       endif;

       if udaddts < CDateTS;
        delete updrec;
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
       CDateTS = CDateTS - %days(365);
      /end-free

     C                   endsr
