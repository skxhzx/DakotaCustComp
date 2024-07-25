      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *
     *  TSTTTMERG   Test getting TTMERG record
     *
     *  24 February 2018
     *  Dave Sommerville
     *----------------------------------------------------------------

     Fttmerg    if   e           k disk
     Fttmerg2   if   e           k disk    rename(ttmrec:ttmrec2) prefix(tt2_)

     d $pwhse          s              3  0
     d $prtid          s              5

      /free
       *inlr = *on;

       read ttmerg;
       if not %eof(ttmerg);
         ttmwhs = ttmwhs;
         ttmprt = ttmprt;
         ttmpri = ttmpri;
         ttmcrt = ttmcrt;
         ttmcri = ttmcri;
       endif;


       $pwhse = 900;
       $prtid = '99005';

       chain ($pwhse: $prtid) ttmerg;
       if %found(ttmerg);
         ttmwhs = ttmwhs;
         ttmprt = ttmprt;
         ttmpri = ttmpri;
         ttmcrt = ttmcrt;
         ttmcri = ttmcri;
       endif;

       chain ($pwhse: $prtid) ttmerg2;
       if %found(ttmerg2);
         tt2_ttmwhs = tt2_ttmwhs;
         tt2_ttmprt = tt2_ttmprt;
         tt2_ttmpri = tt2_ttmpri;
         tt2_ttmcrt = tt2_ttmcrt;
         tt2_ttmcri = tt2_ttmcri;
       endif;

       setll ($pwhse: $prtid) ttmerg;
       reade ($pwhse: $prtid) ttmerg;
       if not %eof(ttmerg);
         ttmwhs = ttmwhs;
         ttmprt = ttmprt;
         ttmpri = ttmpri;
         ttmcrt = ttmcrt;
         ttmcri = ttmcri;
       endif;

       setll ($pwhse: $prtid) ttmerg2;
       reade ($pwhse: $prtid) ttmerg2;
       if not %eof(ttmerg2);
         tt2_ttmwhs = tt2_ttmwhs;
         tt2_ttmprt = tt2_ttmprt;
         tt2_ttmpri = tt2_ttmpri;
         tt2_ttmcrt = tt2_ttmcrt;
         tt2_ttmcri = tt2_ttmcri;
       endif;



       $prtid = '99008';

       chain ($pwhse: $prtid) ttmerg;
       if %found(ttmerg);
         ttmwhs = ttmwhs;
         ttmprt = ttmprt;
         ttmpri = ttmpri;
         ttmcrt = ttmcrt;
         ttmcri = ttmcri;
       endif;

       chain ($pwhse: $prtid) ttmerg2;
       if %found(ttmerg2);
         tt2_ttmwhs = tt2_ttmwhs;
         tt2_ttmprt = tt2_ttmprt;
         tt2_ttmpri = tt2_ttmpri;
         tt2_ttmcrt = tt2_ttmcrt;
         tt2_ttmcri = tt2_ttmcri;
       endif;

       setll ($pwhse: $prtid) ttmerg;
       reade ($pwhse: $prtid) ttmerg;
       if not %eof(ttmerg);
         ttmwhs = ttmwhs;
         ttmprt = ttmprt;
         ttmpri = ttmpri;
         ttmcrt = ttmcrt;
         ttmcri = ttmcri;
       endif;

       setll ($pwhse: $prtid) ttmerg2;
       reade ($pwhse: $prtid) ttmerg2;
       if not %eof(ttmerg2);
         tt2_ttmwhs = tt2_ttmwhs;
         tt2_ttmprt = tt2_ttmprt;
         tt2_ttmpri = tt2_ttmpri;
         tt2_ttmcrt = tt2_ttmcrt;
         tt2_ttmcri = tt2_ttmcri;
       endif;

      /end-free

