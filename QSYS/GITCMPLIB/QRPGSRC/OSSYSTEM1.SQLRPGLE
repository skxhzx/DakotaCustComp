      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSSYSTEM   OPS *SYSTEM Upd - Pgm for SQL procedure of same name
     *  13 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
750 A*    04/13/21  KDE  7.50
     *      - Copied from OSSYSTEM.
     *      - This versions is called from M06703 and higher and
     *        uses Generic Procedure Call
     *
750aA*    08/26/21  KDE  7.50a
     *      - Add option (optrna) for Assigning Selection Transactions
     *        On-Demand
     *      - Add option (opsrta) for Assigning Selection Transactions
     *        in a specific order
     *      - Add option (optall) for Assigning Selection Transactions
     *        either for all routes(A) or selected routes(S)
     *
750bA*    01/31/22  KDE  7.50b
     *      - Add option (opdckv) for determining if Dockvue module is used
     *      - Add code to only override values if sent
     *      - This program is a shared call from M067xx and M069xx.  Therefore,
     *        it set "i" fields to determine what is passed so it will not
     *        step on fields updated in one and not another program
     *
760 A*    04/21/22  KDE  7.60
     *      - Cannot set off switches in ConvertFields
     *
760aA*    04/25/22  KDE  7.60a
     *      - Add options opaepf, opamrt for Auto Assignment
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*SYSTEM')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             10
     D  pObjLoc        s             10
     d  pParmStr1      s            999
     d  pParmStr2      s            999
     d  pParmStr3      s            999

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D logText         s            100
     d dpCombo         s             20
     d pMpck           s              1
750 Ad pSrte           s              1
750aAd pTrna           s              1
750aAd pSrta           s              1
750aAd pTall           s              1
750bAd pDckv           s              1
760aAd paepf           s              1
760aAd paepo           s              1
760aAd pamrt           s              1
750bAd ptbpm           s              1
750bAd pdspl           s              1
750bAd pslot           s              1
750bAd pepm            s              1
750bAd pRf             s              1
750bAd pTrax           s              1
750bAd pTaxr           s              1
750bAd pChkr           s              1
750bAd pVoice          s              1
750bAd iMpck           s               n
750bAd iSrte           s               n
750bAd iTrna           s               n
750bAd iSrta           s               n
750bAd iTall           s               n
750bAd iDckv           s               n
760bAd iaepf           s               n
760bAd iaepo           s               n
760bAd iamrt           s               n
750bAd itbpm           s               n
750bAd idspl           s               n
750bAd islot           s               n
750bAd iepm            s               n
750bAd iRf             s               n
750bAd iTrax           s               n
750bAd iTaxr           s               n
750bAd iChkr           s               n
750bAd iVoice          s               n
     D pSubCmd         s             10
     D pfrom           s              6
     D pWhse           s              3  0

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

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

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
     *    OPTAXR  -  Using TAXR module (Y/N).
     *    OPCHKR  -  Using CHKR module (Y/N).
     *    OPVOICE -  Using VOICE module (Y/N).
750 A*    OPSRTE  -  llow Super Routes
750aA*    OPTRNA  -  Assign Selection Transactions On-Demand
750aA*    OPSRTA  -  Assign Selection Transactions On-Demand Sort Order
750aA*    OPTALL  -  Assign Selection Transactions for All/Selected Routes
750bA*    OPDCKV  -  Is Customer using Dockvue
760aA*    OPAEPF  -  Assign Trans per pallet jack #pallets first
760aA*    OPAMRT  -  Assign Trans across different routes if necessary to fill pallet jack
     *
     * Data structure
     *
     D optionRec       ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
     D  optaxr                40     40
     D  opchkr                41     41
     D  opvoice               42     42
750bAD  opslot                43     43
750bAD  opdspl                44     44
750bAD  optbpm                45     45
750aMD  opsrte                46     46
750aAD  optrna                47     47
750aAD  opsrta                48     48
750aAD  optall                49     49
750bAD  opdckv                50     50
760aAD  opaepf                51     51
760aAD** open for use         52     52
760aAD  opamrt                53     53
     D  optend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

    A /copy qcopysrc,p.wrtsessl

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

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pSessId     Session
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
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pParmStr1
     C                   parm                    pParmStr2
     C                   parm                    pParmStr3

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

        // Extract parameters from delimited string

750bA   exsr setoftfrind;
        ExtractParms();

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
             exsr AfterAct;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

750bA*----------------------------------------------------------------
750bA*  setofTfrInd - Set off transfer indicators
750bA*----------------------------------------------------------------

      /free
750bA  begsr setofTfrInd;
750bA      impck  = *off;
750bA      isrte  = *off;
750bA      itrna  = *off;
750bA      isrta  = *off;
750bA      itall  = *off;
750bA      idckv  = *off;
750bA      iepm   = *off;
750bA      irf    = *off;
750bA      itrax  = *off;
750bA      itaxr  = *off;
750bA      ichkr  = *off;
750bA      ivoice = *off;
750bA      itbpm  = *off;
750bA      idspl  = *off;
750bA      islot  = *off;
750bA  endsr;

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;
         opdata = optionRec;

         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

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

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DelRec    Delete record
     *----------------------------------------------------------------

      /free
       begsr DelRec;

         error = *off;

         exec sql delete from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opcode = optionCode;
         opwhse = pWhse;

750bA    if iepm;
           opepm   = pepm;
750bA    endif;

750bA    if irf;
750 A      oprf    = prf;
750bA    endif;

750bA    if itrax;
750aA      optrax  = ptrax;
750bA    endif;

750bA    if itaxr;
750aA      optaxr  = ptaxr;
750bA    endif;

750bA    if ichkr;
750aA      opchkr  = pchkr;
750bA    endif;

750bA    if ivoice;
750aA      opvoice = pvoice;
750bA    endif;

750bA    if idckv;
750bA      opdckv  = pdckv;
750bA    endif;

750bA    if itbpm;
750bA      optbpm  = ptbpm;
750bA    endif;

750bA    if idspl;
750bA      opdspl  = pdspl;
750bA    endif;

750bA    if islot;
750bA      opslot  = pslot;
750bA    endif;

750bA    if impck;
750bA      opmpck  = pmpck;
750bA    endif;

750bA    if isrte;
750bA      opsrte  = psrte;
750bA    endif;

750bA    if itrna;
750bA      optrna  = ptrna;
750bA    endif;

750bA    if itall;
750bA      optall  = ptall;
750bA    endif;

750bA    if isrta;
750bA      opsrta  = psrta;
750bA    endif;

760aA    if iaepf;
760aA      opaepf  = paepf;
760aA    endif;

760aA    if iamrt;
760aA      opamrt  = pamrt;
760aA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FldValid   Validate fields
     *----------------------------------------------------------------

      /free
       begsr FldValid;

         if pSubCmd = 'D';
           leavesr;
         endif;

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
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt = sqlSuccess;
           optionrec = opdata;
           found = *on;
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
         opdata = optionRec;

         exec sql update options
                  set opdata = :opdata
                  where opcode = :opcode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

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

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'FROM';
             pfrom  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

760 D      //impck  = *off;
           when parmName = 'OPMPCK';
            pmpck  = %trim(parmValue);
750bA       impck  = *on;

760 D      //isrte  = *off;
750 A      when parmName = 'OPSRTE';
750 A       psrte  = %trim(parmValue);
750bA       isrte  = *on;

760 D      //itrna  = *off;
750aA      when parmName = 'OPTRNA';
750aA       ptrna  = %trim(parmValue);
750bA       itrna  = *on;

760 D      //isrta  = *off;
750aA      when parmName = 'OPSRTA';
750aA       psrta  = %trim(parmValue);
750bA       isrta  = *on;

760 D      //itall  = *off;
750aA      when parmName = 'OPTALL';
750aA       ptall  = %trim(parmValue);
750bA       itall  = *on;

760 D      //idckv  = *off;
750bA      when parmName = 'OPDCKV';
750bA       pdckv  = %trim(parmValue);
750bA       idckv  = *on;

760aA      when parmName = 'OPAEPF';
760aA       paepf  = %trim(parmValue);
760aA       iaepf  = *on;
760aA      when parmName = 'OPAMRT';
760aA       pamrt  = %trim(parmValue);
760aA       iamrt  = *on;

760 D      //iepm   = *off;
750bA      when parmName = 'OPEPM';
750bA       pepm   = %trim(parmValue);
750bA       iepm   = *on;

760 D      //irf    = *off;
750bA      when parmName = 'OPRF';
750bA       prf   = %trim(parmValue);
750bA       irf   = *on;

760 D      //itrax  = *off;
750bA      when parmName = 'OPTRAX';
750bA       ptrax  = %trim(parmValue);
750bA       itrax  = *on;

760 D      //itaxr  = *off;
750bA      when parmName = 'OPTAXR';
750bA       ptaxr  = %trim(parmValue);
750bA       itaxr  = *on;

760 D      //ichkr  = *off;
750bA      when parmName = 'OPCHKR';
750bA       pchkr  = %trim(parmValue);
750bA       ichkr  = *on;

760 D      //oice = *off;
750bA      when parmName = 'OPVOICE';
750bA       pvoice = %trim(parmValue);
750bA       ivoice = *on;

760 D      //itbpm  = *off;
750bA      when parmName = 'OPTBPM';
750bA       ptbpm  = %trim(parmValue);
750bA       itbpm  = *on;

760 D      //idspl  = *off;
750bA      when parmName = 'OPDSPL';
750bA       pdspl  = %trim(parmValue);
750bA       idspl  = *on;

760 D      //islot  = *off;
750bA      when parmName = 'OPSLOT';
750bA       pslot  = %trim(parmValue);
750bA       islot  = *on;

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
