      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('HTTPAPI':'QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  PODSENDP   Send PODP XML files to HTTP server
     *  21 October 2008
     *  Retha Davis
     *  Cloned from PODSEND
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    10/21/08  RBD  5.20
     *      - Created.
520aA*    06/02/09  RBD  5.20a  P#00213
     *      - Added 10 second timeout logic.
520bA*    06/03/09  RBD  5.20b  P#00212
     *      - Enh: Added 5 more POD error message recipients.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     F                                     rename(oprec:record)
     Fpodlogp   uf a e           k disk

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,httpapi_h
     D/copy qcopysrc,ifsio_h
     D/copy qcopysrc,errno_h
      /copy qcopysrc,p.bfcdteti

     D chkifsobj       pr                  extpgm('CHKIFSOBJ')
     D  path                        640A   const
     D  authority                    10A   const

     D podsndmsg       pr                  extpgm('PODSNDMSG')
     D  user                         10A   const
     D  message                     512A   const

     D parsePODrtn     PR
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   Attrs                         *   dim(32767)
     D                                     const options(*varsize)

     *----------------------------------------------------------------
     *  *POD1    -  POD options - Part 1
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPPOPT  -  Export to POD (Y,N)
     *    OPPIFS  -  IFS folder
     *    OPPSRV  -  POD HTTP Server
     *    OPPUSR  -  POD HTTP Server User Id
     *    OPPPWD  -  POD HTTP Server Password
     *
     * Data structure
     *
     D opdata1         ds
     D  oppopt                 1      1
     D  opppth                 2     33
     D  oppsrv                34     83
     D  oppusr                84     98
     D  opppwd                99    113
     D  optend1              117    117
     *----------------------------------------------------------------
     *  *POD2    -  POD options - Part 2
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPUSR1  -  Error message user 1
     *    OPUSR2  -  Error message user 2
     *    OPUSR3  -  Error message user 3
     *    OPUSR4  -  Error message user 4
     *    OPUSR5  -  Error message user 5
520bA*    OPUSR6  -  Error message user 6
520bA*    OPUSR7  -  Error message user 7
520bA*    OPUSR8  -  Error message user 8
520bA*    OPUSR9  -  Error message user 9
520bA*    OPUS10  -  Error message user 10
     *
     * Data structure
     *
     D opdata2         ds
     D  opusr1                 1     10
     D  opusr2                11     20
     D  opusr3                21     30
     D  opusr4                31     40
     D  opusr5                41     50
520bAD  opusr6                51     60
520bAD  opusr7                61     70
520bAD  opusr8                71     80
520bAD  opusr9                81     90
520bAD  opus10                91    100
     D  optend2              117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------

     D keyop           ds
     D  kyWhse                             like(opwhse)
     D  kyCode                             like(opcode)

     D keypodp         ds                  likerec(podprec : *key)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D i               s              3  0
     D msg2snd         S            512A
     D newStatus       s                   like(pdpStatus)
520aAD petimeout       s             10I 0
     D pathLen         s              3  0
     D pos             s              3  0
     D rc              s             10I 0
     D rcvXML          s              1
     D stmfSend        S            256A
     D stmfRecv        S            256A
     D try#            s                   like(pdpTry)
     D tryFile         s             33
     D url             S            256A

     D gResultType     S              7
     D gErrorCode      S             10
     D gErrorMessage   S             60

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pCmd            s              8
     D pPgm            s             10
     D pWhse           s              3  0
     D pRtid           s              5
     D pRte            s              5
     D pPlid           s              7  0
     D pUp#            s              5  0
     D pStop           s              2  0
     D pOrd            s              7  0
     D pCord           s              7  0
     D pFileSend       s             30
     D pFileRecv       s             30
     D pFileTry        s             33
     D pReturn         s             10
     D pMsg            s             60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd       *SEND    - Send file
     *                            (assumes pFileTry is sent)
     *                 *RESEND  - Resend file
     *                            (assumes pFileTry is not sent)
     *                 *TSTCON  - Test connection
     *      pPgm       Calling program.
     *      pWhse      Warehous
     *      pRtid      Route id
     *      pRte       Route code
     *      pStop      Stop number
     *      pOrd       Order Id
     *      pCord      Customer order number
     *      pFileSend  Name of file to send.
     *      pFileRecv  Name of file to receive.
     *      pFileTry   Name of file to receive w/try number
     *      pPlid      Pallet id
     *      pUp#       Unique piece#
     *
     *    Returned Parameters
     *      pReturn   OK      - No problem encountered.
     *                OPTERR  - POD options record not found.
     *                NOPATH  - IFS folder not sent
     *                IFSNOTFND - IFS folder not found.
     *                CONERR  - Connection error.
     *                SENDERR - Sending error.
520aA*                TIMEOUT - Timeout error.
     *      pMsg      Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pcmd
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pRte
     C                   parm                    pStop
     C                   parm                    pOrd
     C                   parm                    pCord
     C                   parm                    pFileSend
     C                   parm                    pFileRecv
     C                   parm                    pFileTry
     C                   parm                    pReturn
     C                   parm                    pMsg
     C                   parm                    pPlid
     C                   parm                    pUp#

     *----------------------------------------------------------------
     *  Mainline
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         eval pReturn = 'OK';
         eval pMsg    = ' ';

         http_debug(*ON);

         // Either create a new log record for *RESEND
         // or update the new log record for *SEND

         eval pReturn = 'SENDSTART';
         eval pMsg = 'Send Start';
         eval newStatus = '3';
520aA    eval petimeout = 10;

         select;
           when pCmd = '*SEND';
             eval try# = 1;
             exsr updatePodLog;
           when pCmd = '*RESEND';
             exsr crtFileTry;
             exsr writePodLog;
         endsl;

         // Get POD options

         kyWhse = pWhse;
         kyCode = '*POD1';

         chain %kds(keyop) options;
         if not %found();
           eval pReturn = 'OPTERR';
           eval pMsg = 'POD Options not found';
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;
         eval opdata1 = opdata;

         // Return if not using POD.

         if oppopt <> 'Y';
           eval pReturn = 'OK';
           eval pMsg = 'POD option is turned off';
           eval newStatus = '4';
           exsr updatePodLog;
           return;
         endif;

         // Ensure path isn't blank

         if opppth = ' ';
           eval pReturn = 'NOPATH';
           eval pMsg = 'No IFS folder defined';
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         // Verify IFS folder

         callp(e) chkifsobj (opppth: ' ');
         if %error;
           eval pReturn = 'IFSNOTFND';
           eval pMsg = 'IFS folder not found';
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         // Add '/' to end of path if necessary.

         pathLen = %len(%trimr(opppth));
         if %subst(opppth:pathLen:1) <> '/';
            url = %trimr(opppth)+ '/';
         else;
            url = opppth;
         endif;

         // Combine path and file names

         stmfSend = %trim(url) + pFileSend;
         stmfRecv = %trim(url) + pFileTry;

         // Connect to POD server with user id and password

         rc = http_setauth(HTTP_AUTH_BASIC: oppusr: opppwd);
         if rc < 0;
           eval pReturn = 'CONERR';
           eval pMsg = http_error;
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         // Send xml file to POD server and write response to file.

         rc = http_url_post_stmf(
                                 %trim(oppsrv):
                                 %trim(stmfSend):
                                 %trimr(stmfRecv):
520aD    //                      HTTP_TIMEOUT:
520aM                            petimeout:
                                 HTTP_USERAGENT:
                                 'text-xml');
520aA    if rc = 0;
520aA      eval pReturn = 'TIMEOUT';
520aA      eval pMsg = http_error;
520aA      eval newStatus = '9';
520aA      exsr updatePodLog;
520aA      return;
520aA    endif;

         if rc <> 1;
           eval pReturn = 'SENDERR';
           eval pMsg = http_error;
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         // Check response file for success or failure

         rc = http_parse_xml_stmf( %trim(stmfRecv)
                                   : HTTP_XML_CALC
                                   : *null
                                   : %paddr(parsePODrtn)
                                   : *null );

         if RC < 0;
           eval pReturn = 'XMLERR';
           eval pMsg = http_error;
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         eval rcvXML = 'Y';

         // If 'success' not returned, then a problem occured.

         if gResultType <> 'success';
           eval pReturn = gResultType;
           eval pMsg = gErrorMessage;
           eval newStatus = '9';
           exsr updatePodLog;
           return;
         endif;

         // Otherwise, POD accepted the order.

         eval pReturn = 'OK';
         eval pMsg = 'Accepted';
         eval newStatus = '4';
         exsr updatePodLog;

         return;


       //---------------------------------------------------------------
       //  crtFileTry    Create pFileTry file name.
       //---------------------------------------------------------------

       begsr crtFileTry;

         exsr getTryNum;
         pos = %scan('.':pFileRecv);
         if pos > 0;
           pFileTry = %replace(%char(try#):pFileRecv:pos:0);
         else;
           pFileTry = %trim(pFileRecv) + %char(try#);
         endif;

       endsr;

       //---------------------------------------------------------------
       //  getcurrstamp  Get current timestamps
       //---------------------------------------------------------------

       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;

       //---------------------------------------------------------------
       //  getTryNum   Get try number
       //---------------------------------------------------------------

       begsr getTryNum;

         keypodp.pdpWhse = pWhse;
         keypodp.pdpRtid = pRtid;
         keypodp.pdpPlid = pPlid;
         keypodp.pdpUp#  = pUp#;

         setgt %kds(keypodp:4) podLogP;
         readpe %kds(keypodp:4) podLogP;
         if %eof;
           if pCmd = '*RESEND';
             eval try# = 2;
           else;
             eval try# = 1;
           endif;
         else;
           if pdpTry = 99;
             eval try# = 99;
           else;
             eval try# = pdpTry + 1;
           endif;
         endif;

       endsr;

       //---------------------------------------------------------------
       //  sendMsg     Send message to users.
       //---------------------------------------------------------------

       begsr sendMsg;

         msg2snd = 'Error occured sending RteId/ToteId '
                 + %trim(pRtid) + '/' + %trim(%editc(pUp#:'Z'))
                 + ' to POD Server: '
                 + %trim(pdpErrCode) + ' - ' + %trim(pdpErrMsg);

         // Always send message to QSYSOPR.

         podsndmsg ('QSYSOPR':msg2snd);

         // Now send msg to extra users that have been defined.

         kyWhse = pWhse;
         kyCode = '*POD2';

         chain %kds(keyop) options;
         if not %found();
           leavesr;
         endif;
         eval opdata2 = opdata;

520bD  //for i = 1 to 5;
520bM    for i = 1 to 10;
           select;
             when i = 1 and opusr1 <> ' ';
               podsndmsg (opusr1:msg2snd);
             when i = 2 and opusr2 <> ' ';
               podsndmsg (opusr2:msg2snd);
             when i = 3 and opusr3 <> ' ';
               podsndmsg (opusr3:msg2snd);
             when i = 4 and opusr4 <> ' ';
               podsndmsg (opusr4:msg2snd);
             when i = 5 and opusr5 <> ' ';
               podsndmsg (opusr5:msg2snd);
520bA        when i = 6 and opusr6 <> ' ';
               podsndmsg (opusr6:msg2snd);
520bA        when i = 7 and opusr7 <> ' ';
               podsndmsg (opusr7:msg2snd);
520bA        when i = 8 and opusr8 <> ' ';
               podsndmsg (opusr8:msg2snd);
520bA        when i = 9 and opusr9 <> ' ';
               podsndmsg (opusr9:msg2snd);
520bA        when i = 10 and opus10 <> ' ';
               podsndmsg (opus10:msg2snd);
           endsl;
         endfor;

       endsr;

       //---------------------------------------------------------------
       //  setLogTime    Set appropriate log time fields
       //---------------------------------------------------------------

       begsr setLogTime;

         exsr getCurrStamp;

         select;
           when pdpStatus = '3';
             pdpTS3   = currStampLoc;
             pdpUC3   = currStampUc;
             pdpCall3 = pPgm;
             pdpPgm3  = #pgm;
             pdpUser3 = #user;
             pdpJob3  = #Job;
             pdpNbr3  = #Jobnbr;
           when pdpStatus = '4';
             pdpTS4   = currStampLoc;
             pdpUC4   = currStampUc;
         endsl;

         pdpTS9   = currStampLoc;
         pdpUC9   = currStampUc;

       endsr;

       //---------------------------------------------------------------
       //  updatePODLog   Update log
       //---------------------------------------------------------------

       begsr updatePodLog;

         keypodp.pdpWhse = pWhse;
         keypodp.pdpRtid = pRtid;
         keypodp.pdpPlid = pPlid;
         keypodp.pdpUp#  = pUp#;
         keypodp.pdpTry  = try#;

         chain %kds(keyPodp) podlogP;

         pdpStatus = newStatus;
         pdpFileTry = pFileTry;
         pdpRcvXml  = rcvXML;
         pdpErrCode = pReturn;
         pdpErrMsg  = pMsg;

         exsr setLogTime;

         update(e) podprec;

         if newStatus = '9';
           exsr sendMsg;
         endif;

       endsr;

       //---------------------------------------------------------------
       //  writePodLog   Write log record
       //---------------------------------------------------------------

       begsr writePodLog;

         clear podpRec;

         pdpWhse = pWhse;
         pdpRtid = pRtid;
         pdpRte  = pRte;
         pdpPlid = pPlid;
         pdpUp#  = pUp#;
         pdpStop = pStop;
         pdpOrd  = pOrd;
         pdpCord = pCord;
         pdpTry = try#;
         pdpStatus = '3';
         pdpFileSnd = pFileSend;
         pdpFileRcv = pFileRecv;
         pdpFileTry = pFileTry;
         pdpRcvXml  = ' ';
         pdpErrCode = pReturn;
         pdpErrMsg  = pMsg;

         exsr setLogTime;

         write(e) podprec;

       endsr;

      /end-free

     *================================================================
     * Procedure: parsePODrtn
     *================================================================
     *
     * This is called for each XML element that's received in the
     * phrase string. The string will look something like the
     * following:
     *
     *   <addPalletReply ...>
     *     <palletResult>
     *       <palletNumber>...</palletNumber>
     *       <result>
     *         <resultType>...</resultType>
     *         <errorCode>...</errorCode>
     *         <message>...</message>
     *       </result>
     *     </palletResult>
     *   </addPalletReply>
     *
     *  where <resultType> will either be 'success' or 'failure'.
     *
     *  The DEPTH parameter indicates the nesting depth of the
     *  element received.  In the above example, the <palletResult> tag
     *  would be depth 1 and <palletNumber> would be depth 2, etc.
     *
     *  The NAME parameter is the name of the XML element that
     *  has been received.  It might be something like "palletResult",
     *  "palletNumber" or "result".
     *
     *  The PATH indicates the elements that the current element
     *  is found inside. So, the path for "palletNumber" is "/palletResult".
     *
     *  The VALUE parameter gives us the text that's inside that
     *  element.
     *
     *================================================================

     P parsePODrtn     B
     D parsePODrtn     PI
     D   userdata                      *   value
     D   depth                       10I 0 value
     D   name                      1024A   varying const
     D   path                     24576A   varying const
     D   value                    65535A   varying const
     D   attrs                         *   dim(32767)
     D                                     const options(*varsize)

     D count           s             10I 0
     D attrname        s            100A   varying
     D attrval         s            100A   varying
     D PrintLine       s            100A   varying
      /free

         select;
           when name = 'addPalletReply';
           when name = 'palletResult';
           when name = 'palletNumber';
           when name = 'result';
           when name = 'resultType';
             eval gResultType = value;
           when name = 'errorCode';
             eval gErrorCode = value;
           when name = 'message';
             eval gErrorMessage = value;
         endsl;

         count = 1;
         dow attrs(count) <> *NULL;
           attrname = %str(attrs(count));
           count = count + 1;
           attrval = %str(attrs(count));
           count = count + 1;
         enddo;

      /end-free
     P                 E

      /define ERRNO_LOAD_PROCEDURE
      /copy qcopysrc,errno_h
