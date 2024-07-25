      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
     H BNDDIR('HTTPAPI':'QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  TR722   Tracker - Get route for Trax 2.0
     *          Copied from TR720 - See Notes below
     *  19 November 2009
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    11/19/09  DAS  6.10
     *      - Created.
     *
610aA*    03/31/10  RBD  6.10a
     *      - Added VfyEmpRte logic.
     *      - Added logic to verify xml file exists.
     *      - Modified error messages for consistency.
     *      - Added input parm for whse.
     *      - Fixed VfyRteId, use routeId instead of pRteId.
     *
610bA*    06/09/10  RBD  6.10b
     *      - Added log processing.
     *
640aA*    12/12/11  RBD  6.40a
     *      - Added serial number parm.
     *      - Added logic to check new option "driver assigned
     *        before download".
     *          a) If Y, driver in TTRTE must already be assigned
     *             and it must match the driver passed in.
     *          b) If N, update TTRTE with driver passed in, write
     *             new TTRTE record if it doesn't exist.
     *      - Added logic to write TTLOG record when route is
     *        successfully downloaded.
     *
640bA*    01/20/12  RBD  6.40b
     *      - Force url to point to root directory ... this ensures
     *        that the xml is written to BFCxxxx in the root directory
     *        even if the user's profile points to another one.
     *      - Added additional editing.
     *
640cA*    06/12/12  RBD  6.40c
     *      - Change user written to the Trax log download user field
     *        to be the user passed in from the handheld rather than
     *        the iSeries user which is always QUSER.
     *
650aA*    08/26/13  RBD  6.50a
     *      - Added serial# to log record.
     *
650bA*    11/26/14  RBD  6.50b
     *      - Added version number parm and editing.
     *
700aA*    01/11/16  RBD  7.00b
     *      - Changed length of version number from 5 to 3.
     *
700bA*    09/28/16  RBD  7.00b
     *      - Enh: added Trax training routes file.  If Trax training
     *        route bypass download/upload edits.
     *
710aA*    04/19/17  RBD  7.10a
     *      - For now skip over code that writes merged routes into
     *        the same xml. The handheld is not yet ready to handle
     *        multiple routes in the same xml.  So for now merged
     *        routes (TTMERG) is only used by the Loader Module.
     *        When you're ready to reinstate this logic simply take out
     *        these 710a revs.
     *
710bA*    11/17/17  DAS  7.10b
     *      - Enhanced debug logic.
     *
710cA*    11/18/17  DAS  7.10c
     *      - Revised to get IFS folder from *TRAX2 options
     *
720aA*    02/20/18  DAS  7.20a
     *      - Revised VfyEmpRte to always set Status date/time.
     *      - Revised VfyEmpRte to always set Start date/time.
     *
720b *    02/28/18  GJA  7.20b "version 020"
     *      - Reinstated logic to prevent downloading a child route
     *        for Trax 2.0.
     *
720aA*    05/21/18  DAS  7.20a
     *      - Created from TR720 (see notes below)
     *      - Revised to call TR722
     *
720bA*    09/26/18  DAS  7.20b
     *      - Added extra device id fields
     *
730aA*    12/27/19  RBD  7.30a
     *      - No longer error out if route has already been downloaded.
     *        SWT was having ongoing problem with routes being flagged
     *        on the iSeries as having been downloaded when in fact the
     *        download process on the Trax device didn't complete. Appeared
     *        to be a network/connection issue but we couldn't prove it.
     *
     *        Instead, the Trax device does not allow the route to be
     *        downloaded onto the device if it's already there. If the
     *        user wishes to download it multiple times they must clear
     *        it from the Trax device first.
     *
740aA*   12/11/20  RBD  7.40a
     *     - Fix: Enlarged size of exRtnMsg from 60 to 120 because
     *       #pgmmsg, which is 80 long, was being returned as part
     *       of the msg in EXTTRTE *PSSR and could potentially cause
     *       it to blow up.
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
710aA*  Notes
710aA*
710aA*    In the early stages of Trax 2.0, TRGETRTE was revised to
710aA*    include a version parameter, which was put in the middle of
710aA*    the parameter list. Also, at that time we thought we would
710aA*    use the same webservice for Trax 1 and 2. Therefore, the
710aA*    Trax 1 webservice was revised to use the new parameter.
710aA*
710aA*    Later, it was determined to keep as much separation between
710aA*    Trax 1 and 2 as possible. TRGETRTE and TR720 remained as
710aA*    being used by both 1 and 2, and the extra parm was forgotten.
710aA*
710aA*    Things worked fine at I-Supply, so at some point they must
710aA*    have gotten the revised Trax 1 webservice program.
710aA*
710aA*    We ran into problems at Springfield because of the extra
710aA*    parameter, so we revised the Trax 2 webservice to use
710aA*    this TRGETRTE2, which will call TR722 instead of TR720.
710aA*
710aA*----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

610bAFttlog     uf a e           k disk
640aAFoptions   if   e           k disk
640bAFttmerg1   if   e           k disk    prefix(t1_)
640bAf***ttmerg2   if   e           k disk    prefix(t2_)
720bMFttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
720bMF                                     prefix(t2_)
640aAFttrte     uf a e           k disk
700bAftttrain   if   e           k disk
710bAfbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *
JSLaA /COPY QCOPYSRC,ID#jsl

610bA*----------------------------------------------------------------
610bA*  File data data structure
610bA*----------------------------------------------------------------

610bAD rtehed        E ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyttl          ds                  likerec(ttlrec : *key)

640aAD keyrte          ds                  likerec(ttrrec: *key)

640aAD keyop           ds                  likerec(oprec : *key)

640bAD keyttm1         ds                  likerec(tmjrec : *key)

640bAD*keyttm2         ds                  likerec(ttmrec : *key)
720bMD keyttm2         ds                  likerec(ttmrec2: *key)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n   inz(*on)
610bAD newStatus       s                   like(ttlStatus)
610bAD try#            s                   like(ttlTry)
640bAD url             s            100A   varying
640aAD whse#           s              3  0
700bAD train           s              1
710cAD dirLen          s              3  0

710bAd dbgflgExists    s               n
710bAd debug           s               n
710bAd debugAfter      s               n
710bAd debugBefore     s               n
710bAd debugLoc        s              1

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gEmp#           s              5  0
     D gUser           s             10
     D gWhse           s              3  0
     D gFileName       s             60
610bAD gRhrte          s              5
640aAD gRhtruk         s             10

     *----------------------------------------------------------------
610bA*  Date/time variables
     *
610bAD bfcoffset       s              3  0 inz(0)
610bAD CurrStamploc    s               z
610bAD CurrStampsys    s               z
610bAD CurrStampuc     s               z
610bAD currtimestamp   s               z
610bAD datestamp       s               d
610bAD editdate        s               d
610bAD edittime        s               t   timfmt(*hms:)
610bAD micro           s             26
610bAD micro4          s              4
610bAD timestamp       s               t   timfmt(*hms:)
720bAD exRtnCode       s             10
740aDD*exRtnMsg        s             60
740aMD exRtnMsg        s            120
720bAD dspType         s             10

640aA*----------------------------------------------------------------
640aA*  *TRAX  -  TRAX options
640aA*
640aA* Fields
640aA*
     *    OPTHST  -  Days to keep TRAX export data (1-999)
     *    OPTSLI  -  Save log info
     *    OPTCWR  -  Catch weight required
     *    OPTOFT  -  Order number field type
     *    OPTDFT  -  Driver field type
     *    OPTRFT  -  Route field type
     *    OPTCAP  -  Capitalize input
     *    OPTDBL  -  Double click delivery
     *    OPTEKD  -  Entry key delivery
     *    OPTDAR  -  Delivery after return
     *    OPTIDB  -  Include item data base
     *    OPTBDA  -  Breakdowns allowed
     *    OPTGBD  -  Generic breakdown allowed
     *    OPTRTQ  -  Pre-trip questions
     *    OPTOTQ  -  Post-trip questions
     *    OPTCCE  -  Credit card enabled
     *    OPTSIG  -  Signature enabled
     *    OPTPIV  -  Print invoice
     *    OPTSDA  -  Send data after stop
     *    OPTWSP  -  Ws port
     *    OPTWSI  -  Ws IP
     *    OPTSVD  -  Save days
     *    OPTERT  -  Environment run time
     *    OPTEDV  -  Environment device
     *    OPTEOS  -  Environment OS
     *    OPTESW  -  Environment screen width
     *    OPTESH  -  Environment screen height
     *    OPTARE  -  Add return enabled
     *    OPTIDL  -  Icon delivery
     *    OPTDCI  -  Double click icons
     *    OPTPAL  -  Pallets enabled
     *    OPTCRA  -  Cradle upload enabled
     *    OPTDRV  -  Driver assigned before download
     *
     * Data structure
     *
710cDD*opdata          ds
710cMD opdta           ds
     D  opthst                 1      3  0
     D  optsli                 4      4
     D  optcwr                 5      5
     D  optoft                 6      6
     D  optdft                 7      7
     D  optrft                 8      8
     D  optcap                 9      9
     D  optdbl                10     10
     D  optekd                11     11
     D  optdar                12     12
     D  optidb                13     13
     D  optbda                14     14
     D  optgbd                15     15
     D  optrtq                16     16
     D  optotq                17     17
     D  optcce                18     18
     D  optsig                19     19
     D  optpiv                20     20
     D  optsda                21     21
     D  optwsp                22     26  0
     D  optwsi                27     41
     D  optsvd                42     43  0
     D  optert                44     47
     D  optedv                48     57
     D  opteos                58     67
     D  optesw                68     71  0
     D  optesh                72     75  0
     D  optare                76     76
     D  optidl                77     77
     D  optdci                78     78
     D  optpal                79     79
     D  optcra                80     80
     D  optdrv                81     81
710cDD* optend               117    117
710cMD  opten                117    117
710cA*----------------------------------------------------------------
710cA*  *TRAX2  -  More TRAX options
710cA*----------------------------------------------------------------
710cA*
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
     *    OPTV12  -  Default = N.  Y = create V1.2 xml.
     *    OPTV20  -  Default = N.  Y = create V2.0 xml.
     *    OPTDIR  -  IFS main directory
     *
     * Data structure
     *
     D opdta2          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
     D  optv12                18     18
     D  optv20                19     19
     D  optdir                20     39
     D  opten2               117    117

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

610bA /copy qcopysrc,p.bfcdteti
     D/copy qcopysrc,p.getempl
640aA /copy qcopysrc,p.cvtdte

     D getliblcl       pr                  extpgm('GETLIBLCL')
     D  zLibl                      1024

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A
     D  authority                    10A

640aA*----------------------------------------------------------------
640aA*  CVTDTE constant and parameter data structure.
640aA*----------------------------------------------------------------
640aAD @cvtdt          c                   const('CVTDTE')

640aAD $cvtdt          ds
640aAD  $cvcmd                 1      8
640aAD  $cvprg                 9     18
640aAD  $cvd6i                19     24
640aAD  $cvd8i                25     32
640aAD  $cvd6o                33     38  0
640aAD  $cvd8o                39     46  0
640aAD  $cvsto                47     64
640aAD  $cvrtn                65     72
640aAD  $cverm                73    132
640aAD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D VerifyParms     pr
     D VfyEmployee     pr
     D VfyEmpRte       pr
     D VfyRteId        pr
     D VfyXmlFile      pr
     D wrtDebugErr     pr
     D wrtDebugLibl    pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.exttrte

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pEmpNo      Employee number
     *      pWhse       Warehouse
     *      pRteId      Route Id
     *
     *    Returned Parameters
     *      pRtnCode       Return code (*OK, *ERROR)
     *      pRtnMessage    Return file name or error message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pEmpNo            5
     C                   parm                    pWhse             3
     C                   parm                    pRteId            5
640aAC                   parm                    pSerial#         30
700aDC**                 parm                    pVersion          5
700aMC                   parm                    pVersion          3
     C                   parm                    pRtnCode         10
     C                   parm                    pRtnMessage      60
720bAC                   parm                    pNetId           30
720bAC                   parm                    pBlueId          30
720bAC                   parm                    pSimId           30
720bAC                   parm                    pPhone           30
720bAC                   parm                    pAppVer          20

      /free
        *inlr = *on;

710bA   // See if debug is turned on
710bA   // We are defaulting debug to *on because that is what it originally was.
710bA
710bA   debug = *on;
710bA   debugBefore = *off;
710bA   debugAfter = *off;
710bA   if dbgflgExists;
710bA     chain(e) (#pgm) bfcdbgflg;
710bA     if %found(bfcdbgflg);
710bA       select;
710bA         when bdfflag = 1;
710bA           debug = *on;
710bA           debugAfter = *on;
710bA         when bdfflag = 2;
710bA           debug = *on;
710bA           debugBefore = *on;
710bA         when bdfflag = 3;
710bA           debug = *on;
710bA           debugBefore = *on;
710bA           debugAfter = *on;
710bA       endsl;
710bA     endif;
710bA   endif;

        pRtnCode    = ' ';
        pRtnMessage = ' ';
640aA   whse# = %dec(pwhse:3:0);
640aA   exsr getOptions;

700bA   // Is this a Trax training route ?
700bA   chain (whse#: pRteId) tttrain;
700bA   if %found;
700bA     train = 'Y';
700bA   endif;

710bA   // Write library list to log
710bA
710bA   if debug;
          wrtDebugLibl();
710bA   endif;

        // Verify Parameters

        VerifyParms();
        if pRtnMessage <> ' ';
610bA   // Write log file
610bA     newStatus  = '9';
610bA     exsr writeTTLOG;
          return;
        endif;

        // Verify xml file exists

        VfyXmlFile();
        if pRtnMessage <> ' ';
610bA   // Write log file
610bA     newStatus  = '9';
610bA     exsr writeTTLOG;
          return;
        endif;

640aA   if pSerial# <> ' ';
640aA   // Write serial# to TTRTE file
640aA     exsr writeSerial;
640aA   endif;

640aA   // Write log file
640aA   newStatus  = '3';
640aA   pRtnCode = 'DOWNLOADED';
640aA   pRtnMessage  = 'File has been downloaded';
640aA   exsr writeTTLOG;

        // Send back file name

        pRtnCode = '*OK';
        pRtnMessage = gFileName;

        return;

710bA  //---------------------------------------------------------------
710bA  //  *INZSR   Initialization subroutine
710bA  //---------------------------------------------------------------
710bA
710bA  begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

640bA /end-free
650fAC                   call      'GETCLIENT'
650fAC                   parm                    client           10
650fAC                   parm                    clientloc        10
640bA /free

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  getcurrstamp  Get current timestamps
610bA  //---------------------------------------------------------------
610bA
610bA  begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;

640aA  //---------------------------------------------------------------
640aA  //  getOptions  Get options
640aA  //---------------------------------------------------------------
640aA
640aA  begsr getOptions;

       //  get *TRAX options

         keyop.opWhse = whse#;
         keyop.opCode = '*TRAX   ';

         chain %kds(keyop) Options;

         if not %found;
710cD      //opdata = ' ';
710cM      opdta = ' ';
         else;
           opdta = opdata;
         endif;

710cA  //  get *TRAX2 options
710cA
         keyop.opWhse = whse#;
         keyop.opCode = '*TRAX2  ';

         chain %kds(keyop) Options;

         if not %found;
           opdta2  = ' ';
         else;
           opdta2  = opdata;
         endif;

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  getTryNum   Get try number
610bA  //---------------------------------------------------------------
610bA
610bA  begsr getTryNum;

         keyttl.ttlWhse = whse#;
         keyttl.ttlRtid = pRteid;

         setgt %kds(keyttl:2) ttlog;
         readpe %kds(keyttl:2) ttlog;
         if %eof;
           eval try# = 1;
         else;
           if ttlTry = 99;
             eval try# = 99;
           else;
             eval try# = ttlTry + 1;
           endif;
         endif;

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  setLogTime    Set appropriate log time fields
610bA  //---------------------------------------------------------------
610bA
610bA  begsr setLogTime;

         exsr getCurrStamp;

         select;
           when ttlStatus = '1';
             ttlTS1   = currStampLoc;
             ttlPgm1  = #pgm;
             ttlUser1 = #user;
             ttlJob1  = #Job;
             ttlNbr1  = #Jobnbr;
           when ttlStatus = '2';
             ttlTS2   = currStampLoc;
           when ttlStatus = '3';
             ttlTS3   = currStampLoc;
             ttlPgm3  = #pgm;
640cD    //  ttlUser3 = #user;
             ttlJob3  = #Job;
             ttlNbr3  = #Jobnbr;
         endsl;

         ttlTS9   = currStampLoc;

       endsr;

640aA  //---------------------------------------------------------------
640aA  //  writeSerial   Write serial number to TTRTE file
640aA  //---------------------------------------------------------------
640aA
640aA  begsr writeSerial;

         keyrte.ttrwhs = whse#;
         keyrte.ttrrti = pRteid;

         chain %kds(keyrte) TTrte;
         if %found;
           ttrser = pSerial#;
           update(e) ttrrec;
         endif;

720bA    // Write device into to TTRTEEXA file.
720bA
720bA    if %parms >= 8;
720bA
720bA      trawhse = whse#;
720bA
720bA      dspType = 'BLUE';
720bA      select;
720bA        when dspType = 'PHONE';
720bA          tradspid = pSerial#;
720bA        when dspType = 'BLUEID';
720bA          tradspid = pBlueId;
720bA        other;
720bA          tradspid = pSerial#;
720bA      endsl;
720bA
720bA      exttrte ('*ADD': exRtnCode: exRtnMsg: trawhse: pRteId:
720bA               tradspid: '1': pSerial#: '1': pNetId: '1':
720bA               pBlueId: '1': pSimId: '1':  pPhone: '1': pAppVer: '1');
720bA
720bA      if exRtnCode <> '*OK';
720bA        exttrte ('*CHANGE': exRtnCode: exRtnMsg: trawhse: pRteId:
720bA                 tradspid: '1': pSerial#: '1': pNetId: '1':
720bA                 pBlueId: '1': pSimId: '1':  pPhone: '1': pAppVer: '1');
720bA      endif;
720bA
720bA    endif;

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  writeTTLOG   Write log record
610bA  //---------------------------------------------------------------
610bA
610bA  begsr writeTTLOG;

         clear ttlRec;

         exsr getTryNum;

         ttlWhse = whse#;
         ttlRtid = pRteid;
         ttlRte  = gRhrte;
         ttlTry = try#;
         ttlStatus = newStatus;
640cA    ttlUser3 = pEmpNo;
         ttlFileSnd = gFileName;
         ttlErrCode = pRtnCode;
         ttlErrMsg  = pRtnMessage;
650aA    ttlSer = pSerial#;

         exsr setLogTime;

         write(e) ttlrec;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  VerifyParms   Verify parameters
     *----------------------------------------------------------------

     p VerifyParms     b
     d VerifyParms     pi

      /free

        // Verify route id

        VfyRteId();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify employee number

        VfyEmployee();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify employee assigned to route

        VfyEmpRte();
        if pRtnMessage <> ' ';
          return;
        endif;

       return;
      /end-free

     p VerifyParms     e

     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2

      /free

         // Convert to a number

         monitor;
           gEmp# = %dec(pEmpNo:5:0);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = 'Invalid Emp# - '
                    + pEmpNo;
710bA      WrtDebugErr();
           return;
         endmon;

         // Get employee info

         monitor;
           getEmpl(gEmp#: gWhse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                   e$bpu: e$lng);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = 'Error calling getEmpl';
710bA      WrtDebugErr();
           return;
         endmon;

         if e$rtn = '*ERROR';
           pRtnCode    = '*ERROR';
           pRtnMessage = 'User not found for emp# - '
                    + pEmpNo;
710bA      WrtDebugErr();
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyEmpRte  Verify employee assigned to route
     *
640aA*          Based on option "driver assigned before download" :
640aA*
640aA*          a) If Y, driver in TTRTE must already be assigned
640aA*             and it must match the driver passed in.
640aA*          b) If N, update TTRTE with driver passed in, write
640aA*             new TTRTE record if it doesn't exist.
     *
     *----------------------------------------------------------------

     p VfyEmpRte       b
     d VfyEmpRte       pi

     * Local variables

      /free

640aA    keyrte.ttrwhs = whse#;
640aA    keyrte.ttrrti = pRteid;
640aA
640aA    chain %kds(keyrte) TTrte;

640aA    // If driver assigned before dwnld option = Y and driver has
640aA    // not been assigned, send error.
640aA
640aA    if not %found and optdrv = 'Y';
640aA      pRtnCode    = '*ERROR';
640aA      pRtnMessage = 'Route '
640aA                  + %trim(gRhrte)
640aA                  + '/'
640aA                  + %trim(pRteId)
640aA                  + ' not assigned to an emp';
710bA      WrtDebugErr();
640aA      return;
640aA    endif;

640aA    // If driver assigned before dwnld option = Y but the driver
640aA    // in TTRTE is not the same as the driver passed in, send error.
640aA
640aA    if %found and optdrv = 'Y'and ttrusr <> guser;
640aA      pRtnCode    = '*ERROR';
640aA      pRtnMessage = 'Route '
640aA                  + %trim(gRhrte)
640aA                  + '/'
640aA                  + %trim(pRteId)
640aA                  + ' is assigned to '
640aA                  + %trim(ttrusr);
710bA      WrtDebugErr();
640aA      return;
640aA    endif;

640aA    // Driver assigned before dwnld option = Y and the driver
640aA    // passed in matches the driver assigned in TTRTE.
720aD    // Let this fall through so start date/time are updated.
640aA
720aD    //if optdrv = 'Y';
720aD    //  return;
720aD    //endif;

640aA    // Driver assigned before dwnld option = N. Update TTRTE
640aA    // with driver passed in if different, or create a TTRTE rec
640aA    // it doesn't exist.

640aA /end-free

640aA*  getDateTime  Get current date & time
640aAC                   eval      $cvcmd = '*CURCMD '
640aAC                   call      @cvtdt
640aAC                   parm                    $cvtdt
640aAC                   eval      ttrstd = $cvd8o
640aAC                   time                    ttrstt

640aA /free

720aD    //if %found and ttrusr <> guser;
720aM    if %found;
640aA      ttrusr = guser;
720aA      ttrsrd = ttrstd;
720aA      ttrsrt = ttrstt;
640aA      update ttrrec;
             return;
         endif;

640aA    if not %found;
640aA      ttrwhs = whse#;
640aA      ttrrti = prteid;
640aA      ttrrte = grhrte;
640aA      ttrusr = guser;
640aA      ttrs   = 0;
640aA      ttrsd  = 0;
640aA      ttrqs1 = 0;
640aA      ttrqs2 = 0;
640aA      ttrqs3 = 0;
640aA      ttrqn1 = 0;
640aA      ttrqn2 = 0;
640aA      ttrqn3 = 0;
640aA      ttrqc1 = 0;
640aA      ttrqc2 = 0;
640aA      ttrqc3 = 0;
640aA      ttrqp1 = 0;
640aA      ttrqp2 = 0;
640aA      ttrqp3 = 0;
720aM      ttrsrd = ttrstd;
720aM      ttrsrt = ttrstt;
640aA      ttrfid = 0;
640aA      ttrfit = 0;
640aA      write ttrrec;
640aA      return;
640aA    endif;

       return;
      /end-free

     p VfyEmpRte       e

     *----------------------------------------------------------------
     *  VfyRteId   Verify route id
     *----------------------------------------------------------------

     p VfyRteId        b
     d VfyRteId        pi

     * Local variables

     d  routeId        s              5

      /free

         // Verify route exists in RTEHED file

           routeId = pRteId;

        exec sql select * into :rtehed
                 from rtehed
                where rhwhse = :whse# and rhrtid = :routeId;
         If sqlstt <> sqlSuccess;
           pRtnCode    = '*ERROR';
           pRtnMessage = 'Route '
                       + %trim(pRteId)
                       + ' not found';
           return;
         endif;

610bA        eval gRhrte = rhrte;
640aA        eval gRhtruk = rhtruk;

         // Verify route status is Exported

         If rhstat <> '6';
           pRtnCode    = '*ERROR';
           pRtnMessage = 'Route '
                       + %trim(rhrte)
                       + '/'
                       + %trim(pRteId)
                       + ' not at Exported status';
710bA      WrtDebugErr();
           return;
         endif;

700bA    // If Trax training route you can skip the following edits
700bA    if train = 'Y';
700bA      return;
700bA    endif;

730aA    // No longer check to see if route has already been downloaded
730aA    //
640bA    // If non-merged route or merged route parent has already been
640bA    // downloaded, return error.
640bA
640bA    // 730aD keyttl.ttlWhse = whse#;
640bA    // 730aD keyttl.ttlRtid = pRteid;
640bA
640bA    // 730aD setll %kds(keyttl:2) ttlog;
640bA    // 730aD dow forever = forever;
640bA    // 730aD   reade %kds(keyttl:2) ttlog;
640bA    // 730aD   if %eof;
640bA    // 730aD     leave;
640bA    // 730aD   endif;
640bA    // 730aD   if ttlstatus = '3' or ttlstatus = '4';
640bA    // 730aD     pRtnCode    = '*ERROR';
640bA    // 730aD     pRtnMessage = 'Route '
640bA    // 730aD                 + %trim(rhrte)
640bA    // 730aD                 + '/'
640bA    // 730aD                 + %trim(pRteId)
640bA    // 730aD                 + ' has already been downloaded';
710bA    // 730aD     WrtDebugErr();
640bA    // 730aD     return;
640bA    // 730aD   endif;
640bA    // 730aD enddo;

710aA    // skip merged route logic for now
720bA    // don't skip merged route logic if version 020
720bA    if pVersion <> '020';
710aA      return;
720bA    endif;

640bA    // If user requested the download of a child route, return
640bA    // an error message, and let the user know whether the child
640bA    // has already been downloaded or not.
640bA
640bA    keyttm2.t2_ttmwhs = whse#;
640bA    keyttm2.t2_ttmcri = pRteid;
640bA
640bA    setll %kds(keyttm2:2) ttmerg2;
640bA    reade %kds(keyttm2:2) ttmerg2;
640bA    if %eof;
640bA    else;
640bA
640bA      keyttl.ttlWhse = whse#;
640bA      keyttl.ttlRtid = t2_ttmpri;
640bA
640bA      setll %kds(keyttl:2) ttlog;
640bA      dow forever = forever;
640bA        reade %kds(keyttl:2) ttlog;
640bA        if %eof(ttlog);
640bA          pRtnCode    = '*ERROR';
640bA          pRtnMessage = 'Dwnld parent rte '
640bA                    + %trim(t2_ttmprt)
640bA                    + '/'
640bA                    + %trim(t2_ttmpri)
640bA                    + ' to get '
640bA                    + %trim(t2_ttmcrt)
640bA                    + '/'
640bA                    + %trim(pRteId);
710bA          WrtDebugErr();
640bA          return;
640bA          leave;
640bA        endif;
640bA        // 730aD if ttlstatus ='3' or ttlstatus = '4';
640bA        // 730aD   pRtnCode    = '*ERROR';
640bA        // 730aD   pRtnMessage = 'Rte '
640bA        // 730aD               + %trim(rhrte)
640bA        // 730aD               + '/'
640bA        // 730aD               + %trim(pRteId)
640bA        // 730aD               + ' was downloaded with '
640bA        // 730aD               + %trim(t2_ttmprt)
640bA        // 730aD               + '/'
640bA        // 730aD               + %trim(t2_ttmpri);
710bA        // 730aD   WrtDebugErr();
640bA        // 730aD   return;
640bA        // 730aD endif;
640bA      enddo;
640bA    endif;

640bA    // If this is a merged route, all of the children must have
640bA    // been exported too, if not, return an error.
640bA
640bA    keyttm1.t1_ttmwhs = whse#;
640bA    keyttm1.t1_ttmpri = pRteid;
640bA
640bA    setll %kds(keyttm1:2) ttmerg1;
640bA    dow forever = forever;
640bA      reade %kds(keyttm1:2) ttmerg1;
640bA      if %eof;
640bA        leave;
640bA      else;

650bA    // If version is 12 this cannot be a merged route. Merged routes,
650bA    // aka add-ons and multi routes, must be version 13 or higher.

700aD    //  if pVersion = '00012';
700aM        if pVersion = '012';
650bA          pRtnCode    = '*ERROR';
650bA          pRtnMessage = 'Merged routes not allowed in version 1.2';
710bA          WrtDebugErr();
650bA          return;
650bA        endif;

640bA        if t1_rhstat = '6';
640bA          iter;
640bA        else;
640bA          pRtnCode    = '*ERROR';
640bA          pRtnMessage = 'All rtes merged with '
640bA                      + %trim(t1_ttmprt)
640bA                      + '/'
640bA                      + %trim(pRteId)
640bA                      + ' not exported';
710bA          WrtDebugErr();
640bA          return;
640bA        endif;
640bA      endif;
640bA    enddo;

       return;
      /end-free

     p VfyRteId        e

     *----------------------------------------------------------------
     *  VfyXmlFile  Verify XML file exists
     *----------------------------------------------------------------

     p VfyXmlFile      b
     d VfyXmlFile      pi

     * Local variables

     D  ppath          s            640A
     D  pauth          s             10A

      /free

700aD    // if pVersion = '12';
700aM    if pVersion = '012';
           gFileName = 'W' + (pwhse) + 'R' + (pRteID)
                     + '_RTE.XML';
650bA    else;
650bA      gFileName = 'W' + (pwhse) + 'R' + (pRteID)
650bA                + '_V' + (pVersion) + '_RTE.XML';
650bA    endif;

640bA    select;

710cA      when optdir <> '';
710cA        dirLen = %len(%trimr(optdir));
710cA        if %subst(optdir:1:1) <> '/';
710cA          url = '/' + optdir;
710cA        else;
710cA          url = optdir;
710cA        endif;
710cA        if %subst(optdir:dirLen:1) <> '/';
710cA          url = %trimr(url) + '/';
710cA        endif;

640bA      when optert = 'PROD';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTrax/';
JSLaA        else;
640bA          url = '/BFCTrax/';
JSLaA        endif;

640bA      when optert = 'TEST';
JSLaA        if client = JSilvert;
JSLaA          url = '/JSLTraxTest/';
JSLaA        else;
640bA          url = '/BFCTraxTest/';
JSLaA        endif;

640bA      when optert = 'DEV ';
640bA        url = '/BFCTraxDev/';

640bA    endsl;

640bM    ppath = %trimr(url) + %trim(gFileName);

         callp(e) chkifsobj (ppath:pauth);
         if %error;
              pRtnCode    = '*ERROR';
              pRtnMessage = 'XML file not found '
                       + 'for route '
640bA                  + %trim(gRhrte)
640bA                  + '/'
640bA                  + %trim(pRteId);
710bA         WrtDebugErr();
              return;
         endif;

       return;
      /end-free

     p VfyXmlFile      e

710bA*----------------------------------------------------------------
710bA*  wrtDebugErr    Write out debug error
710bA*----------------------------------------------------------------
710bA
710bAp wrtDebugErr     b
710bAd wrtDebugErr     pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

        // We always write error messages to log

        bdtype = 'ERROR';
        bdvalues = pRtnMessage;
        bdaddts = %timestamp();
        bdaddpgm = #pgm;
        bdaddcusr = #curruser;
        bdaddjusr = #user;
        bdaddjob = #job;
        bdaddnbr = #jobnbr;

        write(e) bdrec;

        return;
      /end-free

     p wrtDebugErr     e

     *----------------------------------------------------------------
     *  wrtDebugLibl   Write out debug parm record
     *----------------------------------------------------------------

     p wrtDebugLibl    b
     d wrtDebugLibl    pi

      /free

        if not %open(bfcdebug);
          open bfcdebug;
        endif;

         bdtype = 'LIBL';

         getliblcl(bdvalues);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       return;

      /end-free

     p wrtDebugLibl    e
