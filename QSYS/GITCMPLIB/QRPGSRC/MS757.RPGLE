650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS756      Clean up GLORTELOG records
     *  08 August 2013
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650aA*    08/08/13  JCJ   6.50a
     *      - Created
     *
700aX*    06/16/15  NLK   7.00a
     *      - NO lines added, deleted, modified hence the 'X'(CL mods)
     *      this pgm was MS756 now MS757 due to dup name in BASE code
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fglortelog3uf   e           k disk

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
     c                   read      glortelog3
      /free
       if        %eof(glortelog3);
        leave;
       endif;

       if grladdts = dfttimestamp;
        iter;
       endif;

       if  grladdts > CDateTS;
        leave;
       endif;

       if grladdts < CDateTS;
        delete grlrec;
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
       CDateTS = CDateTS - %days(21);
      /end-free

     C                   endsr
