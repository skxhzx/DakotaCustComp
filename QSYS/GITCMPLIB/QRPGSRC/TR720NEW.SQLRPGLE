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
     *  TR720   Tracker - Get route
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
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

610bAFttlog     uf a e           k disk
     Fbfcdebug  o    e           k disk

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

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n   inz(*on)
610bAD newStatus       s                   like(ttlStatus)
610bAD try#            s                   like(ttlTry)

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

     D gEmp#           s              5  0
     D gUser           s             10
     D gWhse           s              3  0
     D gFileName       s             60
610bAD gRhrte          s              5

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

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  IFS Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

610bA /copy qcopysrc,p.bfcdteti
     D/copy qcopysrc,p.getempl

     D getliblcl       pr                  extpgm('GETLIBLCL')
     D  zLibl                      1024

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A
     D  authority                    10A

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D VerifyParms     pr
     D VfyEmployee     pr
     D VfyEmpRte       pr
     D VfyRteId        pr
     D VfyXmlFile      pr
     D wrtDebugLibl    pr

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
     C                   parm                    pRtnCode         10
     C                   parm                    pRtnMessage      60

      /free
        *inlr = *on;
        pRtnCode    = ' ';
        pRtnMessage = ' ';

        wrtDebugLibl();

        // Verify Parameters

        VerifyParms();
        if pRtnMessage <> ' ';
610bA   // Write log file
610bA   newStatus  = '9';
610bA   exsr writeTTLlog;
          return;
        endif;

        // Verify xml file exists

        VfyXmlFile();
        if pRtnMessage <> ' ';
610bA   // Write log file
610bA   newStatus  = '9';
610bA   exsr writeTTLlog;
          return;
        endif;

        // Send back file name

        pRtnCode = '*OK';
        pRtnMessage = gFileName;

610bA   // Write log file
610bA   pRtnCode = 'DOWNLOADED';
610bA   pRtnMessage  = 'File has been downloaded';
610bA   newStatus  = '3';
610bA   exsr writeTTLlog;

        return;

610bA  //---------------------------------------------------------------
610bA  //  getcurrstamp  Get current timestamps
610bA  //---------------------------------------------------------------
610bA
610bA  begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  getTryNum   Get try number
610bA  //---------------------------------------------------------------
610bA
610bA  begsr getTryNum;

         keyttl.ttlWhse = gWhse;
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
             ttlUser3 = #user;
             ttlJob3  = #Job;
             ttlNbr3  = #Jobnbr;
         endsl;

         ttlTS9   = currStampLoc;

       endsr;

610bA  //---------------------------------------------------------------
610bA  //  writeTTLlog   Write log record
610bA  //---------------------------------------------------------------
610bA
610bA  begsr writeTTLlog;

         clear ttlRec;

         exsr getTryNum;

         ttlWhse = gWhse;
         ttlRtid = pRteid;
         ttlRte  = gRhrte;
         ttlTry = try#;
         ttlStatus = newStatus;
         ttlFileSnd = gFileName;
         ttlErrCode = pRtnCode;
         ttlErrMsg  = pRtnMessage;

         exsr setLogTime;

         write(e) ttlrec;

       endsr;

       //---------------------------------------------------------------

      /end-free

     *----------------------------------------------------------------
     *  VerifyParms   Verify parameters
     *----------------------------------------------------------------

     p VerifyParms     b
     d VerifyParms     pi

      /free

        // Verify employee number

        VfyEmployee();
        if pRtnMessage <> ' ';
          return;
        endif;

        // Verify route id

        VfyRteId();
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
           pRtnMessage = '(TR710) Invalid Emp# - '
                    + pEmpNo;
           return;
         endmon;

         // Get employee info

         monitor;
           getEmpl(gEmp#: gWhse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                   e$bpu: e$lng);
         on-error;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR710) Error calling getEmpl';
           return;
         endmon;

         if e$rtn = '*ERROR';
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR710) User not found for emp# - '
                    + pEmpNo;
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyEmpRte  Verify employee is assigned to route
     *----------------------------------------------------------------

     p VfyEmpRte       b
     d VfyEmpRte       pi

     * Local variables

     d  rteUser        s             10
     d  routeId        s              5

      /free

         // Verify route exists in TTRTE file

           routeId = pRteId;

         exec sql select ttrusr
                into  :rteUser
                from ttrte
                where ttrwhs = :gWhse and ttrrti = :routeId;
         If sqlstt <> sqlSuccess;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR720) Route '
                       + pRteId
                       + ' not assigned to an emp';
           return;
         endif;

         // Verify emp passed in is the emp assigned to the route

         If rteUser <> gUser;
              pRtnCode    = '*ERROR';
              pRtnMessage = '(TR720) Route '
                       + pRteId
                       + ' is assigned to '
                       + %trim(rteUser)
                       + ', not '
                       + %trim(gUser);
             return;
         endif;

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
                where rhwhse = :gWhse and rhrtid = :routeId;
         If sqlstt <> sqlSuccess;
           pRtnCode    = '*ERROR';
           pRtnMessage = '(TR720) Route '
                       + pRteId
                       + ' not found';
           return;
         endif;

         // Verify route status is Closed or Exported

         If rhstat <> '5'
            and rhstat <> '6';
              pRtnCode    = '*ERROR';
           pRtnMessage = '(TR720) Route '
                       + pRteId
                       + ' not at Closed or Exported status';
             return;
         endif;

610bA        eval gRhrte = rhrte;

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

         gFileName = 'W' + (pwhse) + 'R' + (pRteID)
                   + '_RTE.XML';

         ppath = 'BFCTrax/'
              + %trim(gFileName);

         callp(e) chkifsobj (ppath:pauth);
         if %error;
              pRtnCode    = '*ERROR';
              pRtnMessage = '(TR720) XML file not found '
                       + 'for route '
                       + pRteId;
           return;
         endif;

       return;
      /end-free

     p VfyXmlFile      e

     *----------------------------------------------------------------
     *  wrtDebugLibl   Write out debug parm record
     *----------------------------------------------------------------

     p wrtDebugLibl    b
     d wrtDebugLibl    pi

      /free

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
