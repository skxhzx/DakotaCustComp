      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  GETDBLIBL    Get library list based on db id
     *  13 January 2014
     *  Dave Sommerville
     *
     *  Revisions
     *   01/13/14  DAS  6.50
     *     - Created
     *
700aA*   08/28/15  DAS  7.00
     *     - Q&D to write error to debug log and print libl.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fglodblibl if   e           k disk    usropn
     F                                     infds(file1ds)
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

     D $pdb            S             10
     D $preturn        S             10
     D $pmessage       S            500

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54
     D  f1filename2           83     92
     D  f1lib                 93    102

     *----------------------------------------------------------------
     * Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pdb     DB source id
     *
     *    Returned Parameters
     *      $preturn    *OK
     *                  *ERROR
     *      $pmessage   Message for *ERROR
     *                  Library list for *OK
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     c     *entry        Plist
     c                   Parm                    $pdb
     c                   Parm                    $preturn
     c                   Parm                    $pmessage

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         open(e) glodblibl;
         if %error;
           $preturn = '*ERROR';
           $pmessage = 'Error opening GLODBLIBL file: ' + f1messageid;
           return;
         endif;

         chain ($pdb) glodblibl;

         if not %found(glodblibl);
           $preturn = '*ERROR';
           $pmessage = 'Record not found for ' + $pdb;
           return;
         endif;

         if gdllibl = ' ';
           $preturn = '*ERROR';
           $pmessage = 'Library list not defined for ' + $pdb;
700aA      bdtype = 'NOTFND';
700aA      bdvalues = 'pdb=-' + $pdb + '-';
700aA      bdaddts = %timestamp();
700aA      bdaddpgm = #pgm;
700aA      bdaddcusr = #curruser;
700aA      bdaddjusr = #user;
700aA      bdaddjob = #job;
700aA      bdaddnbr = #jobnbr;
700aA      write(e) bdrec;
700aA /end-free
700aAC                   eval      qcmd = 'DSPLIBL OUTPUT(*PRINT)'
700aAC                   CALL      'QCMDEXC'                            78
720aAC                   PARM                    qcmd             80
700aAC                   PARM      22            qlen             15 5
700aA /free
           return;
         endif;

         $preturn = '*OK';
         $pmessage = gdllibl;
         return;

      /end-free
