      /copy *libl/qcopysrc,hspecs
710aAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RPTGETQ    Get MRC Report Questions
     *  05 July 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
650 A*    07/05/18  KDE  7.20
     *      - Created. Started with copy of PCMGETQ
720aA*    10/30/18  KDE  7.20a
     *      - Tweak HTML Directory if non DEV2 box
730aA*    02/25/19  KDE  7.30a
     *      - Fix issue with # character in field name
730bA*    04/12/19  KDE  7.30b
     *      - Remove OPDEML from options record
730cA*    09/12/19  KDE  7.30b
     *      - Remove warehouse from BFCMRCRCFG file since global file
730dA*    12/11/19  KDE  7.30d
     *      - R323xx exceeded the 2000 byte max for json.  Had to develop
     *        same logic as in pcmgetq to work around this issue
750 A*    03/05/21  KDE  7.50
     *      - When cannot open r99999s.html use what is already in BFCMRCRPLS
750aA*    06/01/21  KDE  7.50a
     *      - Update C API that no longer works with 7.4 version of OS
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
710aA*----------------------------------------------------------------
710aA*  Binding Directories
710aA*----------------------------------------------------------------

710aAHbnddir('BFCBND') BNDDIR('BFCIFSBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fglosess   if   e           k disk
     Fglorptv1  if   e           k disk
     fglotomsrv if   e           k disk
     Fbfcmrcrcfgif   e           k disk
     fbfcmrcrplsuf a e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pCmd        Command
     *      pWhse       Warehouse
     *      pSelTbl     Selection Table
     *      pLinTyp     Line Type
     *      pScrORd     Screen Order
     *
     *    Returned Parameters
     *      pJSON       JSON String
     *
     *----------------------------------------------------------------

     D rptgetq         pr                  extpgm('RPTGETQ')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20    varying
     D  pCmd                         10    varying
     D  pWhse                         3  0
     D  pRptPgm                      20    varying
     D  pSelTbl                       1    varying
     D  pLinTyp                       3    varying
     D  pScrOrd                       4    varying
     D  pJSON                      2000    varying

     D rptgetq         pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20    varying
     D  pCmd                         10    varying
     D  pWhse                         3  0
     D  pRptPgm                      20    varying
     D  pSelTbl                       1    varying
     D  pLinTyp                       3    varying
     D  pScrOrd                       4    varying
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d @command        s            350
     d pCallnum        s              4  0
     D PathFile        S            256
750aDd* OpenMode        s              5
750aDd* FilePtr         s               *
750aMd RtvData         s         131068a
750aAD O_TEXTDATA      C                   16777216
750aAD O_RDONLY        C                   1
750aAD O_CCSID         C                   32
750aAD ccsid           s             10I 0 inz(819)
     D full            s               n
750aAd iFd             s             10U 0
750aAd iMode           s             10U 0
750aAd iFlags          s             10I 0
750aAD iBuf            s               *
730dDD*currStr         s           2000    varying
730dAD currStr         s           4000    varying
     D errStr          s             50    varying
730dDD*largeStr        s           2000    varying
730dDD*prvStr          s           2000    varying
730dAD largeStr        s           4000    varying
730dAD prvStr          s           4000    varying

     D clr             s              7    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     d rptParms        s            512
     d cfgParms        s            512
     d dCnt            s              4  0

     d htmlDir         s            256
     d savPort         s              5  0
     D id              s              5  0
     d charId          s             12
     d currRptPgm      s             20
     D lvl             s              4    varying
     D typ             s              3    varying
     D cod             s             15    varying
     D q               s             45    varying
     D atyp            s              1    varying
     D alen            s              3    varying
     D adec            s              1    varying
     D tbl             s             10    varying
     D rqd             s              1    varying
700aAD pans            s             30    varying
     D rng1            s             15    varying
     D rng2            s             15    varying
700aAD rwrn            s             30    varying

     D startPos        s              5p 0
     D endPos          s              5p 0
     D outLen          s              5p 0
     D maxLen          s              5p 0
     D len             s              5p 0
     D remainLen       s              5p 0

     D chrUser         s             10

     D addFlag         s              1p 0
     D chgFlag         s              1p 0
     D dltFlag         s              1p 0
     D viewFlag        s              1p 0
     D pgm             s             20

     D $code           s             15
     D morelicense     s              1
     D morequestions   s              1
     D savetype        s              3
     D today           s              1
700dAD laitem          s             15
     d hldhilevl       s              4
     d hldhiseqq       s              5  0
     d hlddict         s             10
     d hldpgm          s             10
710aA*----------------------------------------------------------------
710aA*  Time variables
710aA*----------------------------------------------------------------
710aA
710aAD CurrStamploc    s               z
710aAD CurrStampsys    s               z
710aAD CurrStampuc     s               z
710aAD CurrStampBeg    s               z
710aAD CurrStampEnd    s               z
710aA
710aAD bfcoffset       s              3  0 inz(0)
710aA*----------------------------------------------------------------
710aA* Function prototypes.
710aA*----------------------------------------------------------------
710aA
710aA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D hirec         E Ds                  Extname(GLORPTQ)

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

750aAD OpenInput       PR            10i 0
750aAD   fileName                  2048    const varying

750aAD ReadFile        PR            10I 0 extproc('read')
750aAD                               10I 0 value
750aAD                                 *   value
750aAD                               10U 0 value

750aAD open            PR            10I 0 extproc('open')
750aAD   path                          *   value options(*string)
750aAD   oflag                       10I 0 value
750aAD   mode                        10U 0 value options(*nopass)
750aAD   codepage                    10U 0 value options(*nopass)

750aA /if not defined(CLOSE_PROTOTYPE)
750aAD close           PR            10I 0 extproc('close')
750aAD   fildes                      10I 0 value
750aA /define CLOSE_PROTOTYPE
750aA /endif
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D authmenu        pr                  extpgm('AUTHMENU')
     D  pMenuId                      20    const
     D  pUser                        10    const
     D  pViewFLag                     1p 0
     D  pAddFlag                      1p 0
     D  pChgFlag                      1p 0
     D  pDltFlag                      1p 0
     D  pPgm                         20

     *  GoCmd used to call external commands
     *  if Returncode is not 0 then error.  Error
     *  code is returned in Errmsgid

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0

     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

    *----------------------------------------------------------------
    *  *MRCRPT  -  MRC Report Scheduling Options
    *
    * Fields
    *
    *    OPIP    -  IP address for Tomcat Server
    *    OPPORT  -  IP Port for Tomcat Server
    *    OPDPRT  -  Default Printer (Used when one not supplied)
    *    OPGSDV  -  Ghostscript Device
    *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
    *
    *----------------------------------------------------------------
    *
    * Data structure
    *

     D opdata          ds
     D  opip                   1     15
     D  opport                16     20  0
     D  opdprt                21     30
     D  opgsdv                31     39
     D  opmusr                40     49
     d  opcpre                50     52
     d  opjobd                53     62
     d  opdbsrc               63     92
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  {
     *   "recs":
     *          [
     *           {
     *            "whs":
     *            "id":
     *            "lvl":
     *            "typ":
     *            "cod":
     *            "q":
     *            "atyp":
     *            "tbl":
     *            "rqd":
     *            "pans":
     *            "len":
     *            "dec":
     *            "rng1":
     *            "rng2":
xxxx *            "rwrn":
     *           }
     *          ]
     *  }

      /free
         *inlr = *on;
730dA    monitor;
730dA      pCallNum = %dec(%trim(pScrOrd):4:0);
730dA    on-error;
730dA      pCallNum = 1;
730dA    endmon;

         // Initialize max lengths

         outLen = %size(pJSON) - 2;
         maxLen = %size(largeStr) - 2;

         // If call size greater than max length, get out

         if (pCallNum * outLen) > maxLen;
           pJSON = '';
           return;
         endif;

         // Initialize overflow string

         errStr = '{"opt":"OVRFLOW"}';


         // Build large string

         largeStr = '{"recs":[';
         delimiter = '';

         // Add the options to the string.
         // This is the order they will appear on the screen.

         select;
           when pCmd = '*ALL';
             exsr GetAllRecs;
           other;
             // not sure I will need other than getall
         endsl;

         if not full;
           exsr Append;
           largeStr += ']}';
         //else;
         //  largeStr += ']}';
         endif;

         startPos = ((pCallNum - 1) * outLen) + 1;
         endPos = pCallNum * outLen;
         if endPos > %len(largeStr);
           endPos = %len(largeStr);
         endif;
         len = endPos - startPos + 1;

         if len > 0;
           pJSON = %subst(largeStr: startPos: len);
         else;
           pJSON = '';

         endif;
       return;
      /end-free

     *----------------------------------------------------------------
     *  *inzSR    Initialize Routine
     *----------------------------------------------------------------

      /free
       begsr *inzSR;

         // If warehouse not passed in, use session warehouse.

         if pWhse = 0;
           chain (pSessId) glosess;
           if %found(glosess);
             pWhse = gswhse;
           endif;
         endif;

         // Convert inputs to uppercase

         chrUser = %trim(pUser);

         pCmd     = %xlate(xlower: xupper: pCmd);
         pLinTyp  = %xlate(xlower: xupper: pLinTyp);
         pSelTbl  = %xlate(xlower: xupper: pSelTbl);

         // change underscore to period for report program
         outlen = 0;
         outlen = %scan('_' : pRptPgm);
         if outlen <> *zeros;
            %subst(pRptPgm:outlen:1) = '.';
         endif;

        if pSelTbl = 'T';
          // Get parms for Report Level Table from previous call
          // for Selection Table
          chain (pWhse:pRptPgm) bfcmrcrpls;
          if %found(bfcmrcrpls);
             rptParms = %trim(plParmLst);
             leavesr;
          endif;
        endif;

        // for Selection Table call process which uses readHTML to
        // define current and upd to date parm list valid for users
        // version of report

        // get current version of program
        exec sql select gmipgm into :currRptPgm
                  from glomenuitm
                 where gmiid = :pRptPgm
                 order by gmipgm desc
                  fetch first row only;

        savPort = *zeros;
        // get options for Report Scheduling
        chain (pwhse:'*MRCRPT') options;
        if not %found(options);
           // Develop response and method to communicate the
           // need for a valid port in GLOTOMSRV, then return.
        else;
           setll (*loval) glotomsrv;
           read glotomsrv;
           dow 1=1;
              if %eof(glotomsrv);
                  leave;
               else;
                  if gtsport = opport;
                     savPort = gtsport;
                     leave;
                  endif;
               endif;
               read glotomsrv;
            enddo;
            if savPort = *zeros;
               // if no matching port was found return error
            else;
              // Take Tomcat Path and App Location from matching Port
              // record in GLOTOMSRV and build the IFS directory
              // to locate the proper HTML file to determine which
              // parms should be delivered to user screen per their
              // runtime version
              htmlDir = %trim(gtsTomPath) + '/' + %trim(gtsAppLoc);
              // look for m-power in path.  if found then chop
              // anything after m-power
              if %scan('m-power':htmlDir) > *zeros;
                 // remove everything after m-power
                 htmlDir = %subst(%trim(htmlDir):1:
                             %scan('m-power':htmlDir)+6);
              endif;
720aA         // if m-power missing then add
720aA         // could be case on customer box
720aA         if %scan('m-power':htmlDir) = *zeros;
720aA            htmlDir = %trim(htmlDir) + '/m-power';
720aA         endif;
              // now append remaining path to reach specific
              // Report html file to validate parms for specific
              // runtime at a customer site
              htmlDir = %trim(htmlDir) + '/mrcjava/WEB-INF/classes/BFCREPORTS';
              // setup work file to get parms and calcula values from html file
              exsr readHtml;
            endif;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  readHTML  -  Read through HTML verifying available parms for
     *               runtime version
     *----------------------------------------------------------------

      /free
         begsr readHtml;

            //Set file path
            Pathfile = %trim(htmlDir) + '/' +
                       %subst(%trim(currRptPgm):%scan('.':currRptPgm)+1:
                              %len(%trim(currRptPgm)) -
                              %scan('.':currRptPgm)) + 's.html' + x'00';

            //Open IFS HTML file
750aD       //OpenMode = 'r' + x'00' ;
750aD       //FilePtr = OpenFile(%addr(PathFile):%addr(OpenMode));
750aA       ifd = openInput(PathFile);

750aD       //if (FilePtr = *null) ;
750aM       if ifd < 0;
               //Show all parms if HTML file not found
               rptParms = cfgParms;
               chain (pWhse:pRptPgm) bfcmrcrpls;
               if %found(bfcmrcrpls);
                  rptParms = %trim(plParmLst);
                  leavesr;
               endif;
               leavesr;
            endif ;

            //Load string array with all parm names assocaited
            //with specific report being loaded per the
            //Developer Configuration

            cfgParms = *blanks;
730cD       // setll (pWhse:pRptPgm) bfcmrcrcfg;
730cD       // reade (pWhse:pRptPgm) bfcmrcrcfg;
730cM       setll (pRptPgm) bfcmrcrcfg;
730cM       reade (pRptPgm) bfcmrcrcfg;
            dow not %eof(bfcmrcrcfg) and %equal(bfcmrcrcfg);
               if bfdtarry=*blanks and %subst(bftpdata:32:10) <> *blanks;
                  // load array with non date parm
                  cfgParms = %trim(cfgParms) + %subst(bftpdata:32:10) + '|';
               else;
                  // loop through date array loading all date parms
                  dCnt=0;
                  dow dCnt < 160;
                     if %subst(bfdtarry:dcnt+1:10) <> *blanks;
                        cfgParms = %trim(cfgParms) +
                                   %subst(bfdtarry:dcnt+1:10) + '|';
                     endif;
                     dCnt = dCnt + 20;
                  enddo;
               endif;
730cD          // reade (pWhse:pRptPgm) bfcmrcrcfg;
730cM          reade (pRptPgm) bfcmrcrcfg;
            enddo;

            //now loop through HTML file for this report and
            //remove any of the parms found in configuration
            //that are not represented in this version of file
            rptParms = *blanks;

750aD       //dow  (ReadFile(%addr(RtvData):32767:FilePtr) <> *null) ;
750aA       dow forever = forever;
750aM          len = readFile(iFD: %addr(rtvData):%size(rtvData));
750aA          if len < 1;
750aA             leave;
750aA          endif;

               //Remove any formatting characters to end of line returned
               RtvData = %xlate(x'00':' ':RtvData) ;  //End of record null
               RtvData = %xlate(x'25':' ':RtvData) ;  //Line feed (LF)
               RtvData = %xlate(x'0D':' ':RtvData) ;  //Carriage return (CR)

               //Loop through report parms found in configuration
               //above and add to rptParms if found and remove
               //from cfgParms.  Ultmately getting list of all
               //parms represented on this report version

               dCnt=0;
               dow  dCnt < 499;
                  if %subst(cfgParms:dcnt+1:10) <> *blanks;
                    if %scan(%trim(%subst(cfgParms:dcnt+1:10)):
                                RtvData) > *zeros;
                       //add to rptParms since represented in version
                       rptParms = %trim(rptParms) +
                                  %trim(%subst(cfgParms:dcnt+1:10)) + '|';
                       //blank cfgParms so not to check this parm again
                       %subst(cfgParms:dCnt+1:10)=*blanks;
                    endif;
                  endif;
                  dCnt = dCnt + 11;   // 10 for parm length and char |
               enddo;
               RtvData = ' ';
            enddo;

          //Close IFS File
750aA     callp close(ifd);
750aD     //FilePtr = *null;

          // Write Parm List to file to be used for Report Level Call
          chain (pWhse:pRptPgm) bfcmrcrpls;
          if %found(bfcmrcrpls);
             plParmLst = %trim(rptParms);
             update bfplrec;
          else;
             plWhse = pWhse;
             plRptPgm = pRptPgm;
             plParmLst = %trim(rptParms);
             write bfplrec;
          endif;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *  Append    Append to large string
     *----------------------------------------------------------------

      /free
       begsr Append;

         remainLen = maxLen - %len(largeStr) - 2;

         // If everything fits, append previous string

         if (%len(prvStr)+%len(currStr)) <= remainLen;
           largeStr += prvStr;
           prvStr = currStr;
           currStr = '';
           leavesr;
         endif;

         // Otherwise we have overflow condition.
         // We should at least be able to append the error string,
         // but try to include the previous string as well.
         // End result should be screen with the last field row
         // showing an Overflow message.

         full = *on;

         if (%len(prvStr)+%len(errStr)) > remainLen;
           largeStr += errStr;
         else;
           largeStr += prvStr + errStr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPgm    Get program to call
     *----------------------------------------------------------------

      /free
       begsr GetPgm;

         viewFlag = 0;
         addFlag = 0;
         chgFlag = 0;
         dltFlag = 0;
         pgm = ' ';

         authmenu(hitabl :
                  chrUser :
                  viewFlag :
                  addFlag :
                  chgFlag :
                  dltFlag :
                  pgm);

         if viewflag = 0;
           pgm = 'NA';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonQ1    Question type 1 - Text, no validataion
     *----------------------------------------------------------------

      /free
       begsr JsonQ1;

         // Set the max length and decimal postions
         // For character strings, we want the dec field to be blank.

         select;
           when atyp = '1';
             alen = '30';
             adec = '';
           when atyp = '2';
             alen = '1';
             adec = '';
           when atyp = '3';
             alen = '30';
             adec = '';
           when atyp = '4' or atyp='L';
             alen = '20';
             adec = '';
           when atyp = '5';
             alen = '9';
             adec = '2';
           when atyp = '6';
             alen = '9';
             adec = '2';
           when atyp = '7';
             alen = '15';        // Uses generic dates like *YESTERDAY
             adec = '';
           when atyp = '8';
             alen = '15';
             adec = '';
           when atyp = '9';
             alen = '30';
             adec = '';
         endsl;

         // Start question string with std fields

         currStr = delimiter
                 + '{"whs":"' + %char(pWhse) + '",'
                 +  '"id":"' + %trim(charid) + '",'
                 +  '"lvl":"' + lvl + '",'
                 +  '"typ":"' + typ + '",'
                 +  '"cod":"' + cod + '",'
                 +  '"q":"' + q + '",'
                 +  '"atyp":"' + atyp + '",'
                 +  '"len":"' + alen + '",'
                 +  '"dec":"' + adec + '",'
700aA            +  '"rqd":"' + rqd + '",'
700aA            +  '"pans":"' + pans + '"';

         // Add extra fields for some question types

         select;

           when atyp = '3';
             exsr JsonType3;

           when atyp = '4' or atyp='L';
             exsr JsonType4;

           when atyp = '5';
             exsr JsonRange;

           when atyp = '8';
             exsr JsonRange;

         endsl;

         // End question

         currStr += '}';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonType3   Add return values to string for Question
     *              Type 3 - Values from GLORPTV file
     *
     *  An MRC Option program has been created to display the values
     *  from the GLORPTV file. A record for HV900 has been created
     *  in the global menu item file that points to the MRC program.
     *
     *----------------------------------------------------------------

      /free
       begsr JsonType3;

         // We will use an MRC program to generate the dropdown list

         hitabl = 'HV900';
         exsr GetPgm;

         // Add to string as a dropdown

         currStr +=  ',"tbltyp":"D"'
                 +   ',"tbl":"' + 'GLORPTV' + '"'
                 +   ',"pgm":"' + 'BFCDAKOTA.I22800' + 's'
                 +                '?slnk=1'
                 +                '&HVSEQ%23=' + %char(id)
                 +          '"';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonType4   Add return values to string for Question
     *              Type 4 - Table validation
     *
     *  The HITABL code must be defined in the global menu item file,
     *  pointing to an MRC Option program.
     *
     *  The default is that the Option program does not need any
     *  parameters passed in and it will create a dropdown.
     *  Exceptions to this will need to be hard code, similar to
     *  what is done in routine JsonType3.
     *
     *  If a table is expected to have a very large number of records
     *  it should be defined as a lookup instead of a dropdown.
     *
     *  The MRC program (BFCDAKOTA.M15800) has not been programmed
     *  to handle this yet.
     *
     *----------------------------------------------------------------

      /free
       begsr JsonType4;

         // Get the corresponding MRC program for the validation pgm

         // MRC Report Scheduler passes in Program and Dictionary
         // exsr GetPgm;

         // Add to string

         select;
           //when hitabl = 'IT900';
           //  currStr +=  ',"tbltyp":"L"'
           //          +   ',"tbl":"' + %trimr(hitabl) + '"'
           //          +   ',"pgm":"' + %trimr(pgm) + 's"';
           other;
             currStr +=  ',"tbltyp":"D"'
               //    +   ',"tbl":"' + %trimr(hitabl) + '"'
                     +   ',"tbl":"' + %trimr(' ') + '"'
                     +   ',"pgm":"' + %trimr(pgm) + 's"';
         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonRange  Add range to question string
     *----------------------------------------------------------------

      /free
       begsr JsonRange;

         // Get record containing range

         setll (hiseq#) glorptv1;
         reade (hiseq#) glorptv1;
         if not %found(glorptv1);
            rng1 = '0';
            rng2 = '0';
700aA       rwrn = ' ';
         else;
           select;
             when atyp = '5';
               rng1 = %char(hvt5vl);
               rng2 = %char(hvt5rg);
700aA          rwrn = %trim(hvwarn);
             when atyp = '8';
               rng1 = %char(hvvalu);
               rng2 = %char(hvvalr);
700aA          rwrn = %trim(hvwarn);
             other;
               rng1 = '0';
               rng2 = '0';
700aA          rwrn = ' ';
           endsl;
         endif;

         // Add range to question string

         currStr += ','
                 +  '"rng1":"' + rng1 + '",'
700aA            +  '"rng2":"' + rng2 + '",'
700aA            +  '"rwrn":"' + rwrn + '"';

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetAllRecs   Get all active records
     *----------------------------------------------------------------

      /free
       begsr GetAllRecs;

         // start by reading records from BFC Developer definition for
         // this Report and pass to PCM for all PCM data
730cD    // setll (pWhse:pRptPgm:pSelTbl) bfcMrcRcfg;
730cD    // reade (pWhse:pRptPgm:pSelTbl) bfcMrcRcfg;
730cM    setll (pRptPgm:pSelTbl) bfcMrcRcfg;
730cM    reade (pRptPgm:pSelTbl) bfcMrcRcfg;

         dow not %eof(bfcMrcRcfg);

            delimiter = '';

            select;
            when bflinetp='PCM';
             hldhilevl = %subst(bftpdata:23:4);
             hldhiseqq = %dec(%subst(bftpdata:27:5):5:0);
720 A        sqlstmt = 'select * from glorptq' +
720 A                  ' where ' +
720 A                  'hilevl = ' + sq + %trim(hldhilevl) + sq +
720 A                  ' and hiseq# = ' + %char(hldhiseqq);
720 A
720 A        exec sql PREPARE rp FROM :SqlStmt;
720 A        exec sql DECLARE mrcrp SCROLL CURSOR FOR rp;
720 A        exec sql OPEN mrcrp;
720 A
720 A        exec sql fetch first from mrcrp into :hirec;

             dow sqlstt = sqlSuccess;

               if bfdtarry <> *blanks;
                  charid  = %trim(%subst(bfdtarry:1:10));
               else;
                  charid = %trim(%subst(bftpdata:32:10));
               endif;

               // If parm read from configuation file is not
               // found in the version being ran at this site
               // do not show as a parm to schedule with for user
               if %scan(%trim(charId):rptParms) = *zeros;
      /end-free
     c                   goto      skipParm
      /free
               endif;
               if bflinetp = 'PCM';
                  // PCM Question Seq# used in lookup values table
                  // as well as id.
                  id = hiseq#;
               endif;
               lvl = %trimr(hilevl);
               typ = %trimr(hitype);
               cod = %trimr(hicode);
               // q = %trimr(hiqstn);
               q = %trim(bfprompt);         // use question from report config
               atyp = %trimr(hiatyp);
               tbl = %trimr(hitabl);
               rqd = %trimr(BFREQUIRED);
700aA          pans = ' ';

               exsr JsonQ1;
               exsr Append;

               if full;
                 leave;
               endif;

      /end-free
     c     skipParm      Tag
      /free
720 A          exec sql fetch next from mrcrp into :hirec;

             enddo;
720 A        exec sql close mrcrp;

         when bflinetp='DD ';
          // code to handle dd Dropdown
          hlddict = %subst(bftpdata:01:10);
          hldpgm  = %subst(bftpdata:11:10);
          // id = hiseq#;
          charid = %trim(%subst(bftpdata:32:10));

               // If parm read from configuation file is not
               // found in the version being ran at this site
               // do not show as a parm to schedule with for user
               if %scan(%trim(charId):rptParms) = *zeros;
      /end-free
     c                   goto      skipParm
      /free
               endif;

          // lvl = %trimr(hilevl);
          lvl = %trim(bflinetp);
          // typ = %trimr(hitype);
          typ = 'ALL';
          // cod = %trimr(hicode);
          cod = ' ';
          // q = %trimr(hiqstn);
          q = %trim(bfprompt);            // use question from report config
          // Send "4" if normal one select dropdown, send "L" when either
          // include in list, or not include in list has "Y"
          select;
            when %subst(bftpdata:21:1)='Y';   // include if in list
             atyp = 'L';
            when %subst(bftpdata:22:1)='Y';   // exclude if in list
             atyp = 'L';
            other;
             atyp = '4';
          endsl;
          // tbl = %trimr(hitabl);
          tbl = ' ';
          rqd = %trimr(bfrequired);
700aA     pans = ' ';
          pgm = %trim(hlddict) + '.' + %trim(hldpgm);

          exsr JsonQ1;
          exsr Append;

          if full;
            leave;
          endif;

         other;
           // Sub-Total lines
          hlddict = *blanks;
          hldpgm  = *blanks;
          // id = hiseq#;

               // If parm read from configuation file is not
               // found in the version being ran at this site
               // do not show as a parm to schedule with for user
              charid = %trim(%subst(bftpdata:32:10));
              if %scan(%trim(charId):rptParms) = *zeros;
      /end-free
     c                   goto      skipParm
      /free
              endif;

          select;
            when %trim(%subst(bftpdata:32:10)) = 'DETAIL';
              charid = 'D_' + %trim(%subst(bftpdata:32:10));
            when %trim(%subst(bftpdata:32:10)) = 'TOTAL';
              charid = 'G_' + %trim(%subst(bftpdata:32:10));
            other;
              charid = 'S_' + %trim(%subst(bftpdata:32:10));
730aA         if %scan('#':charid)<>0;
730aA            // replace # sign with "P_" for MRC sub totals
730aA            // you may want to ensure it inserts properly
730aA            // if the # happens to occur in middle of field name
730aA            // this code only works if it ens with #
730aA            %subst(charid:%scan('#':charid):1)='P';
730aA            charid = %trim(charid) + '_';
730aA         endif;
          endsl;
          // lvl = %trimr(hilevl);
          lvl = '    ';
          // typ = %trimr(hitype);
          typ = 'ALL';
          // cod = %trimr(hicode);
          cod = ' ';
          // q = %trimr(hiqstn);
          q = %trim(bfprompt);            // use question from report config
          // Send as checkbox with No value
          atyp = '2';
          // tbl = %trimr(hitabl);
          tbl = ' ';
          rqd = %trimr(bfrequired);
700aA     pans = ' ';
          pgm = *blanks;

          exsr JsonQ1;
          exsr Append;

          if full;
            leave;
          endif;

         endsl;

         if full;
           leave;
         endif;

730cD    // reade (pWhse:pRptPgm:pSelTbl) bfcMrcRcfg;
730cM    reade (pRptPgm:pSelTbl) bfcMrcRcfg;
         enddo;


       endsr;
      /end-free

710aA*----------------------------------------------------------------
710aA*
710aA*  ZZGETTIME Get Timestamp information.
710aA*
710aA*----------------------------------------------------------------
710aA /free
710aA  begsr zzgettime;
710aA    getmicrotime(currstampuc:currstampsys);
710aA  endsr;
710aA /end-free

750aA*----------------------------------------------------------------
750aA*  OpenInput    Open input file for read only
750aA*----------------------------------------------------------------

     p OpenInput       b
     d OpenInput       pi            10I 0
     d  fileName                   2048A   const varying

     *  Local Variables

     d error           S               n
     d fd              s             10I 0
     d errorStr        s            100A   varying

      /free

        // Open directory

         iflags = O_RDONLY + O_TEXTDATA + O_CCSID;
         fd = open(%trimr(fileName): iflags: 0: 0);

         if fd < 0;
           //errorStr = %str(strerror(errno));
           dsply 'Error opening file';
           return fd;
         endif;

        return fd;

      /end-free

750aAp OpenInput       e

