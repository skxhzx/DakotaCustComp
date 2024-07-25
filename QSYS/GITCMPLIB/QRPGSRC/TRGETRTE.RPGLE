417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRGETRTE    Tracker - Get route
     *  12 December 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    12/11/09  DAS  6.10
     *      - Created.
     *
640 A*    12/12/11  RBD  6.40
     *      - Added serial number parm.
     *
650 A*    01/24/14  RBD  6.50
     *      - Added logic to accomodate multiple warehouses.
     *      - For production, append the whse to PIRJOBD, ie PIRJOBD001.
     *      - For test, append the whse to PIRJOBT, ie PIRJOBT001.
     *      - Send the PIRJOBDxxx or PIRJOBTxxx jobd to SETJDLIBL to
     *        set the library list.
     *
700aA*    01/11/16  RBD  7.00a
     *      - Added version number parm.
     *      - Added additional call to TR720, one for when version
     *        is passed in, one for when version is not passed in.
     *
700bA*    06/08/16  DAS  7.00b
     *      - Added some temporary test logic for Susan to work with.
     *
710aA*    11/17/17  DAS  7.10a
     *     - Added debug logic
     *     - Moved endsl of setjdlibl to before error check.
     *     - Revised to not leave if error setting jobd library list.
     *       Re: At some clients it will fail and only works because
     *           BFCTRAX user profile has jobd with correct library list.
     *     - Cleaned up creating $pjobd.
     *
710bA*    12/11/17  DAS  7.10b
     *      - Revised to use the library list of the job.
     *        This assumes that each warehouse will have its own
     *        Tomcat server, which has its own web.xml file, which
     *        defines the user to connect to the IBM i for the
     *        direct call to the program. If we only wanted to use
     *        1 server for multiple warehouses, a parameter would
     *        need to be added to identify the jobd to use.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *
     *----------------------------------------------------------------

710aA*----------------------------------------------------------------
710aA*  File Specs
710aA*----------------------------------------------------------------
710aA
710aAfbfcdbgflg if   e           k disk    usropn
710aAfbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
     *----------------------------------------------------------------
650 A*  Program info data structure

650 A /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
700aAD pversion        s              3
700aAD prtncode        s             10
700aAD prtnvalue       s             60

710aAd dbgflgExists    s               n
710aAd debug           s               n
710aAd debugAfter      s               n
710aAd debugBefore     s               n
710aAd debugLoc        s              1

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pEmpNo      Employee Number
     *      $pWhse       Warehouse
     *      $pRtid       Route id
640 A*      $pSerial#    Serial Number
700aA*      $pVersion    Version Number
     *
     *    Returned Parameters
     *      $pRtnCode   -  Return code (*OK, *ERROR)
     *      $pRtnValue  -  Error message or file name
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pEmpNo           5
     C                   parm                    $pWhse            3
     C                   parm                    $pRtid            5
640 AC                   parm                    $pSerial#        30
700aAC                   parm                    $pVersion         3
     C                   parm                    $pRtnCode        10
     C                   parm                    $pRtnValue       60

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

700b  /free
700b     // Temp code. Comment out when not testing.
700b     // dsply 'stop' '' reply;
700b     //$pRtnValue = '*OK';
700b     //*inlr = *on;
700b     //return;
700b  /end-free

710aA /free
710aA   // See if debug is turned on
710aA
710aA   debug = *on;
710aA   debugBefore = *off;
710aA   debugAfter = *off;
710aA   if dbgflgExists;
710aA     chain(e) (#pgm) bfcdbgflg;
710aA     if %found(bfcdbgflg);
710aA       select;
710aA         when bdfflag = 1;
710aA           debug = *on;
710aA           debugAfter = *on;
710aA         when bdfflag = 2;
710aA           debug = *on;
710aA           debugBefore = *on;
710aA         when bdfflag = 3;
710aA           debug = *on;
710aA           debugBefore = *on;
710aA           debugAfter = *on;
710aA       endsl;
710aA     endif;
710aA   endif;
710aA /end-free

710bDC**  Revised to used library list of the job

710bDC**                 select

710bDC**                 when      #curruser = 'BFCTRAX'
710aDC**                 eval      $pjobd = %trim('PIRJOBD' + $pwhse)
710bDC**                 eval      $pjobd = 'PIRJOBD' + $pwhse
710bDC**                 call      'SETJDLIBL'
710bDC**                 parm                    $pjobd           10
710bDC**                 parm                    $preturn         10
710bDC**                 parm                    $pmessage        60

710bDC**                 when      #curruser = 'BFCTRAXTST'
710aDC**                 eval      $pjobd = %trim('PIRJOBT' + $pwhse)
710bMC**                 eval      $pjobd = 'PIRJOBT' + $pwhse
710bDC**                 call      'SETJDLIBL'
710bDC**                 parm                    $pjobd           10
710bDC**                 parm                    $preturn         10
710bDC**                 parm                    $pmessage        60

710bDC**                 when      #curruser = 'JSLTRAX'
710bDC**                 eval      $pjobd = 'PIRJOBDJSL'
710bDC**                 call      'SETJDLIBL'
710bDC**                 parm                    $pjobd           10
710bDC**                 parm                    $preturn         10
710bDC**                 parm                    $pmessage        60

710bDC**                 when      #curruser = 'JSLTRAXTST'
710bDC**                 eval      $pjobd = 'PIRJOBTJSL'
710bDC**                 call      'SETJDLIBL'
710bDC**                 parm                    $pjobd           10
710bDC**                 parm                    $preturn         10
710bDC**                 parm                    $pmessage        60

710bDC**                 endsl

710bDC**                 if        $preturn = '*ERROR'
710bDC**                 if        debug
710bDC**                 eval      bdtype = 'ERROR'
710bDC**                 eval      bdvalues = %trimr(#curruser) + '/'
710bDC**                                    + %trimr($pjobd) +' - ' + $pmessage
710bDC**                 eval      bdaddts = %timestamp()
710bDC**                 eval      bdaddpgm = #pgm
710bDC**                 eval      bdaddcusr = #curruser
710bDC**                 eval      bdaddjusr = #user
710bDC**                 eval      bdaddjob = #job
710bDC**                 eval      bdaddnbr = #jobnbr
710bDC**                 write(e)  bdrec
710bDC**                 endif
710aDC**                 goto      bottom
710bDC**                 endif

710bDC**                 endsl

700aAC                   if        %parms < 7
700aAC                   call      'TR720'
700aAC                   parm                    $pEmpNo
700aAC                   parm                    $pWhse
700aAC                   parm                    $pRtid
700aAC                   parm                    $pSerial#
700aAC                   parm      '012'         pVersion
700aAC                   parm      ' '           pRtnCode
700aAC                   parm      ' '           pRtnValue
700aAC                   eval      $pversion = prtncode
700aAC                   eval      $prtncode = prtnvalue

700aAC                   else

     C                   call      'TR720'
     C                   parm                    $pEmpNo
     C                   parm                    $pWhse
     C                   parm                    $pRtid
640 AC                   parm                    $pSerial#
700aAC                   parm                    $pVersion
     C                   parm      ' '           $pRtnCode
     C                   parm      ' '           $pRtnValue

710aAC                   if        debug
710aAC                   if        $pRtnCode <> '*OK'
710aAC                   eval      bdType = 'ERROR'
710aAC                   else
710aAC                   eval      bdtype = 'INFO'
710aAC                   endif
710aAC                   eval      bdvalues = 'usr: ' + %trim(#curruser) + ', '
710aAC                                      + 'emp: ' + %trim($pEmpNo) + ', '
     C                                      + 'whs: ' + $pWhse + ', '
     C                                      + 'rid: ' + $pRtid + ', '
     C                                      + 'rtn: ' + %trim($pRtnCode) + '-'
     C                                      +           %trim($pRtnValue)
710aAC                   exsr      WrtDebug
710aAC                   endif
700aAC                   endif

650 AC     bottom        tag
     C                   eval      *inlr = *on

JSLaA*----------------------------------------------------------------
JSLaA*
JSLaA*  *INZSR  Initialization subroutine
     *
JSLaAC     *inzsr        begsr
     *
     *   Call get client code
     *
JSLaAC                   call      'GETCLIENT'
JSLaAC                   parm                    client           10
JSLaAC                   parm                    clientloc        10

710aA /free
710aA    open(e) bfcdbgflg;
710aA    if %error;
710aA      dbgflgExists = *off;
710aA    else;
710aA      dbgflgExists = *on;
710aA    endif;
710aA /end-free

     C                   endsr

710aA*----------------------------------------------------------------
710aA*  wrtDebug       Write out debug entry
710aA*----------------------------------------------------------------
710aA
710aAC     WrtDebug      begsr

      /free

        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

      /end-free

     C                   endsr

