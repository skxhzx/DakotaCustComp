      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M29900U   Update Realtime Count Options
     *  05 August 2019
     *  Kenneth Elder
     *

     *----------------------------------------------------------------
     *  Revisions
     *
730 A*    08/05/19  KDE  7.30
     *      - Created
750 A*    03/22/19  KDE  7.50
     *      - Added fifth sort
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

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
750 A*    OPSRT5  -  Sort pages by Dept, Aisle, Location, Level, Hand
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
     D opdta           ds
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
     D  opsrt5                18     18
     D oprec         E ds                  extname(options) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     d dpCombo         s             20
     D forevr          s               n
     d n               s             18  0
     d pattern         s            200
     d fieldCnt        s              2  0
     d filename        s            100
     d cmdString       s            200
     d count           s             10  0
     d lastpos         s              5  0
     d nextBegin       s              5  0
     d lenchar         s              5  0
     d lpos            s              5  0
     d newDir          s            300
     d pcmd            s             10
     d p_whse          s              3  0
     d p_opcode        s              8
     d p_asgnpg        s              1
     d p_pglvl         s              1
     d p_ztrn          s              1
     d p_srt1          s              1
     d p_srt2          s              1
     d p_srt3          s              1
     d p_srt4          s              1
750 Ad p_srt5          s              1
     d p_mslt          s              3
     d p_opcupc        s              1
     d p_opcadd        s              1
     d p_opcscn        s              1
     d p_opckin        s              1
     d p_opccwt        s              1
     d p_opdqty        s              1
     d p_opccwv        s              1
     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2
     d psubcmd         s              1
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'
     d   numonly       c                   ' 0123456789'

      *  Client Name Data Area
     dpirclient        ds            10    DTAARA('PIRCLIENT')

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSess          s             40
     D  puser          s             10
     D  pDict          s             10
     D  ppgm           s             10
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D NoSuchPath      C                   'CPE3025'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSess       Session
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pobjLoc     MRC Object Location
     *      pparmStr1   Parm String 1
     *      pparmStr2   Parm String 2
     *      pparmStr3   Parm String 3
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     d WrtBeforeDebug  pr
     d WrtAfterDebug   pr
     d WrtDebugError   pr

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSess
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Combine dictionary/program

        dpCombo = %trim(pDict) + '.' + pPgm;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        // Extract parameters from delimited string

        ExtractParms();

        if %trim(pMessage) = '';
           exsr Afteract;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Get Client name to use in Batchreports directory path
         in pirclient;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr fillRec;
         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(opwhse) + ') '
                    + 'OpCode(' + %trim(opcode) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;

       if not error;

         exsr GetRec;

         select;
           when pSubCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pSubCmd
                      + %trim(pSubCmd)
                      + ' (' + %trim(#pgm) +')';
         endsl;
       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

       if %check(numonly:%trim(p_mslt)) <> 0;
          pMessage='Max Slots per page must be numeric and less than 1000';
          error=*on;
          leavesr;
       endif;

       if p_asgnpg='Y' and p_mslt='0';
          pMessage='When Assign Page Id is checked you must define number ' +
                   'per page';
          error=*on;
          leavesr;
       endif;

       if p_asgnpg='Y' and p_srt1=*blanks and p_srt2=*blanks and
                           p_srt3=*blanks and p_srt4=*blanks and p_srt5=*blanks;
          pMessage='When Assign Page Id is checked you must select desired ' +
                   'Sort Order';
          error=*on;
          leavesr;
       endif;

       if p_srt1='Y' and (p_srt2='Y' or p_srt3='Y' or p_srt4='Y' or p_srt5='Y');
          pMessage='Only one Sort can be selected';
          error=*on;
          leavesr;
       endif;

       if p_srt2='Y' and (p_srt1='Y' or p_srt3='Y' or p_srt4='Y' or p_srt5='Y');
          pMessage='Only one Sort can be selected';
          error=*on;
          leavesr;
       endif;

       if p_srt3='Y' and (p_srt1='Y' or p_srt2='Y' or p_srt4='Y' or p_srt5='y');
          pMessage='Only one Sort can be selected';
          error=*on;
          leavesr;
       endif;

       if p_srt4='Y' and (p_srt1='Y' or p_srt2='Y' or p_srt3='Y' or p_srt5='Y');
          pMessage='Only one Sort can be selected';
          error=*on;
          leavesr;
       endif;

750 A  if p_srt5='Y' and (p_srt1='Y' or p_srt2='Y' or p_srt3='Y' or p_srt4='Y');
750 A     pMessage='Only one Sort can be selected';
750 A     error=*on;
750 A     leavesr;
750 A  endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opwhse    = p_whse;
	        opcode    = p_opcode;
         opasgnp   = p_asgnpg;
         oppglvl   = p_pglvl;
         opcadj    = p_ztrn;
         opmslt    = %dec(p_mslt:3:0);
         opsrt1    = p_srt1;
         opsrt2    = p_srt2;
         opsrt3    = p_srt3;
         opsrt4    = p_srt4;
750 A    opsrt5    = p_srt5;
         opcupc    = p_opcupc;
         opcadd    = p_opcadd;
         opcscn    = p_opcscn;
         opckin    = p_opckin;
         opccwt    = p_opccwt;
         opdqty    = p_opdqty;
         opccwv    = p_opccwv;
         opdata    = opdta;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :oprec
                  from options
                  where opwhse = :p_whse and opcode=:p_opcode;

         if sqlstt = sqlSuccess;
           found = *on;
           eval opdta=opdata;
         else;
           eval opdta=*blanks;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;

         exec sql update options
                  set opwhse=:opwhse, opcode=:opcode, opdata=:opdata
                  where opwhse = :opwhse and
                 opcode = :opcode;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(p_Whse) + ') '
                    + 'Opcode(' + %trim(Opcode) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from options
                  where opwhse=:p_Whse and
                        opcode=:p_opcode;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Whse(' + %char(p_Whse) + ') '
                    + 'Opcode(' + %trim(Opcode) +')';
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

730bAd  parmValuec     s            100

      /free

730bA  parmValuec = parmValue;
730bA  if %subst(parmValuec:1:5)='undef';
730bA     parmValue  = *blanks;
730bA  endif;

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'whs';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_Whse =  %dec(parmValue: 3: 0);

           when parmName = 'opcode';
             p_Opcode = %trim(parmValue);

           when parmName = 'GFA01_01';
             p_asgnpg = %trim(parmValue);

           when parmName = 'GFA01_02';
             p_pglvl = %trim(parmValue);

           when parmName = 'GFA01_04';
             p_ztrn = %trim(parmValue);

           when parmName = 'GFN030_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             p_mslt =  parmValue;

           when parmName = 'GFA01_05';
             p_srt1 = %trim(parmValue);

           when parmName = 'GFA01_06';
             p_srt2 = %trim(parmValue);

           when parmName = 'GFA01_07';
             p_srt3 = %trim(parmValue);

           when parmName = 'GFA01_08';
             p_srt4 = %trim(parmValue);

750 A      when parmName = 'GFA01_16';
750 A        p_srt5 = %trim(parmValue);

           when parmName = 'GFA01_09';
             p_opcupc = %trim(parmValue);

           when parmName = 'GFA01_10';
             p_opcadd = %trim(parmValue);

           when parmName = 'GFA01_11';
             p_opcscn = %trim(parmValue);

           when parmName = 'GFA01_12';
             p_opckin = %trim(parmValue);

           when parmName = 'GFA01_13';
             p_opccwt = %trim(parmValue);

           when parmName = 'GFA01_14';
             p_opdqty = %trim(parmValue);

           when parmName = 'GFA01_15';
             p_opccwv = %trim(parmValue);

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
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

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

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
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
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
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
