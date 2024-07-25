      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M29900G    Return Relatime Cycle Count Options to MRC M29900
     *
     *  05 August 2019
     *  Kenneth Elder
     *
     *  Revisions
     *
730 A*    08/05/19  KDE  7.30
     *      - Created.
750 A*    03/22/21  KDE  7.50
     *      - Added fifth sort
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     foptions   if   e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2
      /copy qcopysrc,p.updrtch

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *RTC     -  Realtime Inventory Count Options
     *
     * Fields
     *
     *    OPASGNP -  Assign Slots to Page Id
     *    OPPGLVL -  Assign Page Id for each Level Break
     *    OPCADJ  -  Create Adjustment for zero Quantity
     *    OPMSLT  -  Max Slots per Page when assigning Page Id's
     *    OPSRT1  -  Sort pages by Dept, Aisle, Side Descending, Level, Location, Hand
     *    OPSRT2  -  Sort pages by Dept, Aisle, Side Descending, Location, Level, Hand
     *    OPSRT3  -  Sort pages by Dept, Slot (F or P),Aisle,Side Descending,Location,Level,Hand
     *    OPSRT4  -  Sort pages by Dept, Slot (F or P), Aisle, Side Descending, Location, Hand
     *    OPSRT5  -  Sort pages by Dept, Aisle, Location, Level, Hand
     *    OPCUPC  -  Scan UPC to confirm item counted
     *    OPCADD  -  RF add item in slot
     *    OPCSCN  -  RF Scan UPC or License to add item
     *    OPCKIN  -  RF key in item to add item
     *    OPCCWT  -  Capture catch weight
     *    OPDQTY  -  Show current inventory
     *    OPCCWV  -  Catch weight variance check
     *
     * Data structure
     *
     D opdata          ds
     D  opasgnp                1      1
     D  oppglvl                2      2
     D  opcadj                 3      3
     d  opmslt                 4      6  0
     D  opsrt1                 7      7
     D  opsrt2                 8      8
     D  opsrt3                 9      9
     D  opsrt4                10     10
     d  opcupc                11     11
     d  opcadd                12     12
     d  opcscn                13     13
     d  opckin                14     14
     d  opccwt                15     15
     d  opdqty                16     16
     d  opccwv                17     17
750 AD  opsrt5                18     18
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z
     D bfcoffset       s              3  0 inz(0)
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
     d assignpg        s              1
     d assignbylvl     s              1

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000
     d dbgflgExists    s               n
     d debug           s               n
     d debugAfter      s               n
     d debugBefore     s               n
     d debugLoc        s              1

     d errMsg          s             99    varying
     d dpCombo         s             20    varying

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pSessId        s             40    varying
     d  pUser          s             10    varying
     d  pdict          s             10    varying
     d  ppgm           s             10    varying
     d  pWhse          s              3p 0
     d  popcode        s              8
     d  pparmstr       s           1024     varying
     d  poutstr        s           1024     varying

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr    Parm String from Generic Function
     *      pOutStr     Json Return String
     *
     *    Returned Parameters
     *      pOutStr     Json Returned String
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pParmStr
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

        exsr getcurrstamp;

         // Extract parameters from delimited string

         ExtractParms();

         // Get out if error

         if errMsg <> '';
         pOutStr = '{'
                 +    '"assignpg":"N",'
                 +    '"assignbylvl":"N",'
                 +    '"teamsused":"N",'
                 +    '"wrtzeroqty":"N"'
                 + '}';
           WrtDebugError();
           return;
         endif;

         // Do processing

         // Get option record data for opcode *RTC (Realtime Inventory Counts)
         chain (pWhse:pOpcode) options;
         if not %found(options);
            opasgnp='N';
            oppglvl='N';
            opcadj='N';
            opsrt1='N';
            opsrt2='N';
            opsrt3='N';
            opsrt4='N';
750 A       opsrt5='N';
            opcupc='N';
            opcadd='N';
            opcscn='M';
            opckin='N';
            opccwt='N';
            opdqty='N';
            opccwv='N';
            opmslt=0;
         else;
            // make sure the numerics are good to prevent dde
            monitor;
             if opmslt >= 0;
             endif;
            on-error;
             opmslt=0;
            endmon;
         endif;
         pOutStr = '{'
                 +    '"assignpg":"' + opasgnp + '",'
                 +    '"assignbylvl":"' + oppglvl + '",'
                 +    '"maxslots":"' + %char(opmslt) + '",'
                 +    '"sort1":"' + opsrt1 + '",'
                 +    '"sort2":"' + opsrt2 + '",'
                 +    '"sort3":"' + opsrt3 + '",'
                 +    '"sort4":"' + opsrt4 + '",'
750 A            +    '"sort5":"' + opsrt5 + '",'
                 +    '"opcupc":"' + opcupc + '",'
                 +    '"opcadd":"' + opcadd + '",'
                 +    '"opcscn":"' + opcscn + '",'
                 +    '"opckin":"' + opckin + '",'
                 +    '"opccwt":"' + opccwt + '",'
                 +    '"opdqty":"' + opdqty + '",'
                 +    '"opccwv":"' + opccwv + '",'
                 +    '"wrtzeroqty":"' + opcadj + '"'
                 + '}';

         // Write out 'After' Debug info

         if debugAfter;
           debugLoc = 'A';
           wrtAfterDebug();
         endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'opcode';
             popcode =  parmValue;

         endsl;

       on-error;

         errMsg = 'Error extracting parameter '
                + %char(parmCount) + ' '
                + parmName + ' '
                + '(' + parmValue + ')'
                + '('
                + %trimr(#Job) + '/'
                + %trimr(#JobNbr) + '/'
                + %trimr(#user)
                + ')';

       endmon;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

      /free

         // Error if parameter string is blank

         if pParmStr = '';
           errMsg = 'Error: Parameter string is empty '
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';
           return;
         endif;

         // Extract parms for string 1

         ExtractParmStr();

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(pParmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': pParmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(pParmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(pParmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           errMsg = 'Error: Invalid parameter group '
                   + %char(parmCount) + ' '
                   + '(' + parmGroup + ')'
                   + '('
                   + %trimr(#Job) + '/'
                   + %trimr(#JobNbr) + '/'
                   + %trimr(#user)
                   + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if errMsg <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtBeforeDebug  Write out 'Before' debug info
     *----------------------------------------------------------------

     p WrtBeforeDebug  b
     d WrtBeforeDebug  pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtAfterDebug  Write out 'After' debug info
     *----------------------------------------------------------------

     p WrtAfterDebug   b
     d WrtAfterDebug   pi

      /free

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'dbgloc:' + %trimr(debugLoc) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pOutStr:' + %trimr(pOutStr) + ', '
                  + 'pParm:' + pParmStr;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

     p WrtDebugError   b
     d WrtDebugError   pi

      /free

         bdtype = 'ERROR';

         bdvalues = errMsg;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

         return;

      /end-free

     p                 e
