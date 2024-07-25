600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  QDLT006LL  Replace LP in LICLOG file
     *  28 May 2009
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fliclog    up   e           k disk

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

         if lllcns = $fromLcns;
           lllcns = $toLcns;
           updFlag = *on;
         endif;

         if llolcns = $fromLcns;
           llolcns = $toLcns;
           updFlag = *on;
         endif;

         if llflcns = $fromLcns;
           llflcns = $toLcns;
           updFlag = *on;
         endif;

         if updFlag;
           update llrec;
         endif;

      /end-free
