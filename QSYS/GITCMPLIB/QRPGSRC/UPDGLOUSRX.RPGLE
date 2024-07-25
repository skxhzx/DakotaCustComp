      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDGLOUSR   Update GLOUSRFILE - Pgem for UPDGLOUSR proc
     *  05 May 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650  *    05/05/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $iwhse       Warehouse
     *      $irtid       Route id
     *
     *    Returned Parameters
     *      $irtn   Return flag
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $iwhse            3 0
     C                   parm                    $irtid            5
     C                   parm                    $irtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
520aDC**                 eval      qcmd = 'DSPLIBL OUTPUT(*PRINT)'
520aDC**                 CALL      'QCMDEXC'                            78
520aDC**                 PARM                    qcmd             80
520aDC**                 PARM      22            qlen             15 5

     *  Call program to see if route is in use.

     C                   eval      $pcmd = '*VERIFY'
     C                   eval      $pwhse = $iwhse
     C                   eval      $prtid = $irtid

     C                   Call(e)   'CHKIUSE'
     C                   Parm                    $pcmd             8
     C                   Parm                    $pwhse            3 0
     C                   Parm                    $prtid            5
     C                   Parm                    $prtn             8

     *  Set return code.

     C                   if        %error
     C                   eval      $irtn = '*CALLERR'
     C                   else
     C                   eval      $irtn = $prtn
     C                   endif

     C                   eval      *inlr = *on
