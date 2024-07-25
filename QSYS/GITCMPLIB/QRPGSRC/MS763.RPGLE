      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS763      Clean up PLTLCNS  records
     *  15 June 2021
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
750 A*    06/15/21  LMC   7.50
     *      - Created
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpltlcns   uf   e           k disk

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
     c                   read      pltlcns
      /free
       if %eof(pltlcns);
        leave;
       endif;

       if rnladdts = dfttimestamp;
        iter;
       endif;

       if  rnladdts > CDateTS;
        iter;
       endif;

       if rnladdts < CDateTS;
        delete rnlrec;
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
       CDateTS = CDateTS - %days(30);
      /end-free

     C                   endsr
