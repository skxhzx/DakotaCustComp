417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TRCMPRTE    Tracker - Complete route
     *  22 December 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    12/22/09  DAS  6.10
     *      - Created.
     *
610aA*    08/18/10  RBD  6.10a
     *      - Removed parm EPM file, added parm warehouse.
     *
650 A*    01/24/14  RBD  6.50
     *      - Added logic to accomodate multiple warehouses.
     *      - For production, append the whse to PIRJOBD, ie PIRJOBD001.
     *      - For test, append the whse to PIRJOBT, ie PIRJOBT001.
     *      - Send the PIRJOBDxxx or PIRJOBTxxx jobd to SETJDLIBL to
     *        set the library list.
     *      - Handheld is sending whse in as alpha, no leading zeroes,
     *        so have to make it numeric.
     *
710aA*    06/28/17  RBD  7.10
     *      - Added call to TR846 to reformat xml timestamps.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
     *
JSLa *    04/04/17  RBD/GJA   JSLa
     *      - Format URL for CLOUD
     *      - Add client code
     *
     *----------------------------------------------------------------

650 AFbfcdebug  o    e           k disk    usropn

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl
     *----------------------------------------------------------------
650 A*  Program info data structure

650 A /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
650 A*  Working variables
     *
650 AD whse3a          s              3
650 AD whse3n          s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pEmpNo      Employee Number
610aA*      $pWhse       Warehouse
     *      $pRtid       Route id
     *      $pRtnFile    Return file
610aD***    $pEpmFile    EPM file
     *
     *    Returned Parameters
     *      $pRtnCode   -  Return code (*OK, *ERROR)
     *      $pRtnMsg    -  Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pEmpNo           5
610aAC                   parm                    $pWhse            3
     C                   parm                    $pRtid            5
     C                   parm                    $pRtnFile        60
610aDC***                parm                    $pEpmFile        60
     C                   parm                    $pRtnCode        10
     C                   parm                    $pRtnMsg         60

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

650 AC                   eval      $cvstr = $pwhse
650 AC                   call      'CVTNUMB'
650 AC                   parm      '*STR2NUM'    $cvcmd            8
650 AC                   parm                    $cvstr           30
650 AC                   parm      0             $cvnum           15 5
650 AC                   parm      0             $cvdec            1 0
650 AC                   parm                    $cvrtn            8
650 AC                   if        $cvrtn = '*ERROR'
650 AC                   goto      bottom
650 AC                   endif
650 AC                   eval      whse3n = $cvnum
650 AC                   move      whse3n        whse3a

650 AC                   exsr      wrtdebuglibl

650 AC                   select

650 AC                   when      #curruser = 'BFCTRAX'
650 AC                   eval      $pjobd = %trim('PIRJOBD' + whse3a)
650 AC                   call      'SETJDLIBL'
650 AC                   parm                    $pjobd           10
650 AC                   parm                    $preturn         10
650 AC                   parm                    $pmessage        60

JSLaAC                   when      #curruser = 'JSLTRAX'
JSLaAC                   eval      $pjobd = %trim('PIRJOBDJSL' + whse3a)
JSLaAC                   call      'SETJDLIBL'
JSLaAC                   parm                    $pjobd           10
JSLaAC                   parm                    $preturn         10
JSLaAC                   parm                    $pmessage        60

JSLaAC                   when      #curruser = 'JSLTRAXTST'
JSLaAC                   eval      $pjobd = %trim('PIRJOBTJSL' + whse3a)
JSLaAC                   call      'SETJDLIBL'
JSLaAC                   parm                    $pjobd           10
JSLaAC                   parm                    $preturn         10
JSLaAC                   parm                    $pmessage        60

650 AC                   when      #curruser = 'BFCTRAXTST'
650 AC                   eval      $pjobd = %trim('PIRJOBT' + whse3a)
650 AC                   call      'SETJDLIBL'
650 AC                   parm                    $pjobd           10
650 AC                   parm                    $preturn         10
650 AC                   parm                    $pmessage        60

JSLaMC                   endsl

650 AC                   if        $preturn = '*ERROR'
650 AC                   goto      bottom
650 AC                   endif

650 AC***JSLaM           endsl         **moved up***

     C                   call      'TR730'
     C                   parm                    $pEmpNo
650 DC**                 parm                    $pWhse
650 MC                   parm                    whse3a
     C                   parm                    $pRtid
     C                   parm                    $pRtnFile
610aDC***                parm                    $pEpmFile
     C                   parm      ' '           $pRtnCode
     C                   parm      ' '           $pRtnMsg

710aAC                   call      'TR846'

650 AC     bottom        tag
650 AC                   exsr      wrtdebuglibl
     C                   eval      *inlr = *on

650 A*----------------------------------------------------------------
650 A*  wrtDebugLibl   Write out debug parm record
650 A*----------------------------------------------------------------
650 A
     C     wrtdebuglibl  begsr

     C                   if        not %open(bfcdebug)
     C                   open      bfcdebug
     C                   endif

     C                   eval      bdtype = 'LIBL'
     C                   call      'GETLIBLCL'
     C                   parm                    bdvalues

     C                   eval      bdaddts = %timestamp()
     C                   eval      bdaddpgm = #pgm
     C                   eval      bdaddcusr = #curruser
     C                   eval      bdaddjusr = #user
     C                   eval      bdaddjob = #job
     C                   eval      bdaddnbr = #jobnbr

     C                   write     bdrec

     C                   if        %open(bfcdebug)
     C                   close     bfcdebug
     C                   endif

     C                   endsr
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
     *
     C                   endsr
