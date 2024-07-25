417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CHKRTEIUSE  Check route in use flag - Pgem for CHKRTEINUSE proc
     *  19 December 2006
     *  Dave Sommerville
     *
     *  Revisions:
     *
510 A*    12/17/06  DAS  5.10
     *      - Created.
     *
520aA*    01/04/09  DAS  5.20a
     *      - Removed call to DSPLIBL.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

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
