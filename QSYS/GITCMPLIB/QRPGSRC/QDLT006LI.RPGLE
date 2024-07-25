600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  QDLT006LI  Replace LP in LICENSE file
     *  28 May 2009
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Flicense   up   e           k disk

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600aA /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D updFlag         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $cmd       *UPDATE
     *      $fromLcns  From license
     *      $toLcns    To license
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $cmd              8
     C                   parm                    $fromLcns        15
     C                   parm                    $toLcns          15

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         if $cmd <> '*UPDATE'
            or $fromLcns = ' '
            or $toLcns = ' ';
           dsply '**Error with parms**';
           return;
         endif;

         updFlag = *off;

         if lilcns = $fromLcns;
           lilcns = $toLcns;
           updFlag = *on;
         endif;

         if updFlag;
           update lirec;
         endif;

      /end-free
