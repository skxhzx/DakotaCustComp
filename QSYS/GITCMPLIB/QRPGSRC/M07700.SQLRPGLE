      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M07700     OPS *RUNNER Update

     *  12 Aug 2021
     *  Retha Davis
     *
     *  Revisions:
     *
750 A*    08/12/21  RBD  7.50
     *      - Created.  Converted from POSRUNNER proc with hardcoded
     *        fields to generic SQL proc.
     *      - Note, AFTERUPD is mapped with VOICE so that OP331 is
     *        called to update common runner/voice options.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*RUNNER')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  ppcrtm         s              1
     D  ppuplr         s              1
     D  pprplf         s              1
     D  ppmrgf         s              1
     D  ppclrf         s              1
     D  pprnrm         s              1
     D  ppclsf         s              2
     D  ppoutf         s              1
     D  pprpck         s              1
     D  pprlbl         s              1
     D  pprbdu         s              1
     D  pprscn         s              2
     D  pprvfs         s              1
     D  pprvfq         s              1
     D  pprloa         s              1
     D  ppscnl         s              1

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pvoice               22     22
     D  $prunner              23     23
     D  $pflgpl               24     24
     D  $pflgrt               25     25
     D  $pflgmr               26     26
     D  $pflgtf               27     27
     D  $pflgcl               28     28

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d dpCombo         s             20
     D logText         s            100
     D pparmStr1       s            999
     D pparmStr2       s            999
     D pparmStr3       s            999

     D client          s             10
     D clientloc       s             10

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
     *  *RUNNER  -  PIR Runner Flag Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCRTM  -  Create Manual Runner entries for shorts/outs (Y/N)
     *    OPUPLR  -  Update Label with quantity shorted during manual
     *               flag entry (Y/N)
     *               NOTE: Any change to this field will cause OPUPLV
     *                     in the *VOICE options record to be updated.
     *    OPRPLF  -  Replenish flagged items before print report? (Y/N)
     *               & create Priority Replenishment if necessary.
     *    OPMRGF  -  Create Runner entries for Merge records? (Y/N)
     *    OPCLRF  -  Clear Runner flags if qty still short/out? (Y/N)
     *    OPRNRM  -  Send break message to user when new Runner
     *               task has been assigned. (Y/N)
     *    OPCLSF  -  Update Label quantity at flag close (Y/N).
     *    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
     *    OPRPCK  -  Print Runner pick list. (Y/N)
     *    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
     *               printer, 2=Belt printer
     *    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
     *    OPRSCN  -  Scan tran# or label# to start pick.
     *                 1=tran#, 2=label#.
     *    OPRVFS  -  Verify pick slot, Y/N.
     *    OPRVFQ  -  Verify qty found, Y/N.
     *    OPRLOA  -  Using loader module, Y/N.
     *    OPSCNL  -  Scan short to loader required before
     *               clearing runner flag, Y/N.
     *
     * Data structure
     *
     D optionrec       ds
     D  opcrtm                 1      1
     D  opuplr                 2      2
     D  oprplf                 3      3
     D  opmrgf                 4      4
     D  opclrf                 5      5
     D  oprnrm                 6      6
     D  opclsf                 7      7
     D  opoutf                 8      8
     D  oprpck                 9      9
     D  oprlbl                10     10
     D  oprbdu                11     11
     D  oprscn                12     12
     D  oprvfs                13     13
     D  oprvfq                14     14
     D  oprloa                15     15
     D  opscnl                16     16
     D  optend               117    117
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

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
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONS data field
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
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

        // Combine dictionary/program

        dpCombo = %trim(pDict) + '.' + pPgm;

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);

        error = *off;

        // Extract parameters from delimited string

        ExtractParms();

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'BEFOREACT';
             exsr BeforeAct;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
           when pObjLoc = 'VOICE';
             exsr syncVoice;
           other;
             pMessage = 'Invalid object location sent: '
                      + %trim(pObjLoc)
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

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
     *  BeforeAct    Before action update
     *----------------------------------------------------------------

      /free
       begsr BeforeAct;

         optionRec = pData;
         exsr FillRec;
         pData = optionRec;

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

         opcrtm =  ppcrtm;
         opuplr =  ppuplr;
         oprplf =  pprplf;
         opmrgf =  ppmrgf;
         opclrf =  ppclrf;
         oprnrm =  pprnrm;
         opclsf =  ppclsf;
         opoutf =  ppoutf;
         oprpck =  pprpck;
         oprlbl =  pprlbl;
         oprbdu =  pprbdu;
         oprscn =  pprscn;
         oprvfs =  pprvfs;
         oprvfq =  pprvfq;
         oprloa =  pprloa;
         opscnl =  ppscnl;
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

         // Here's where editing, if any, should take place
      // if so and so error;
      //   pMessage = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
      //   leavesr;
      // endif;

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
     *  syncvoice   Sync fields in voice options
     *----------------------------------------------------------------

      /free
       begsr syncvoice;

         $pwhse = pwhse;
         $pvoice  = 'Y';
         $pflgpl  = ppuplr;
         $pflgrt  = ppcrtm;
         $pflgmr  = ppmrgf;
         $pflgtf  = ppoutf;
         $pflgcl  = ppclrf;
      /end-free
     C                   call      'OP331'
     C                   parm                    $parms
      /free

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

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


           when parmName = 'OPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'OPCRTM';
            ppcrtm = %trim(parmValue);

           when parmName = 'OPUPLR';
            ppuplr = %trim(parmValue);

           when parmName = 'OPRPLF';
            pprplf = %trim(parmValue);

           when parmName = 'OPMRGF';
            ppmrgf = %trim(parmValue);

           when parmName = 'OPCLRF';
            ppclrf = %trim(parmValue);

           when parmName = 'OPRNRM';
            pprnrm = %trim(parmValue);

           when parmName = 'OPCLSF';
            ppclsf = %trim(parmValue);

           when parmName = 'OPOUTF';
            ppoutf = %trim(parmValue);

           when parmName = 'OPRPCK';
            pprpck = %trim(parmValue);

           when parmName = 'OPRLBL';
            pprlbl = %trim(parmValue);

           when parmName = 'OPRBDU';
            pprbdu = %trim(parmValue);

           when parmName = 'OPRSCN';
            pprscn = %trim(parmValue);

           when parmName = 'OPRVFS';
            pprvfs = %trim(parmValue);

           when parmName = 'OPRVFQ';
            pprvfq = %trim(parmValue);

           when parmName = 'OPRLOA';
            pprloa = %trim(parmValue);

           when parmName = 'OPSCNL';
            ppscnl = %trim(parmValue);

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
