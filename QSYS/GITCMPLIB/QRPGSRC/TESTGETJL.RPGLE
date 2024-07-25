      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  TSTGETULIB  Test GETUSRLIBL called procedure
     *  20 March 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dspMsg          s             52

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
510aA*      $pcmd    *ALL     - Entire library list space delimited
510aA*               *ALLCSV  - Entire library list comma delimited
510aA*               *FILE    - File library only.
     *      $pjd     Job description
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $icmd             8
     C                   parm                    $ijd             10

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


     c                   call      'GETJDLIBL'
510aAc                   Parm                    $icmd
     c                   Parm                    $ijd
     c                   Parm                    $preturn         10
     c                   Parm                    $pmessage       275


     C                   eval      dspMsg = $pmessage
     C     dspMsg        dsply

     C                   eval      *inlr = *on
