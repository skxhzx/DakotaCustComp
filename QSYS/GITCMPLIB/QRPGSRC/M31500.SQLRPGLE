      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M31500     OPS *RCVLBL Upd                                    me
     *  16 July 2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
740 A*    07/16/20  LMC  7.40
     *      - Created.
750aA*    12/13/21  LMC  7.50a
     *      - Added 2 new options opspck & opsbrd
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Specs
     *
     Flblfmtd   if   e           k disk    usropn

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*RCVLBL')

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
     D  pplpgm         s             10
     D  ppupct         s              3  0
     D  pppdef         s              1  0
     D  pppbld         s              1  0
     D  pppact         s              1  0
     D  ppfdef         s              1  0
     D  ppfasl         s              1  0
     D  ppfsid         s              1  0
     D  ppflvl         s              1  0
     D  pppasl         s              1  0
     D  pppfrc         s              1
     D  ppplcn         s              1
     D  pppchm         s              1
     D  pppmix         s              1
     D  ppapck         s              1
     D  ppfrcm         s              1
     D  ppexck         s              1
     D  ppcwen         s              1
     D  ppcwtp         s              1
     D  ppcwfr         s              1
     D  ppipck         s              1
     D  pprupc         s              1
     D  pprups         s              1
     D  pprupf         s              1
     D  ppmspo         s              1
     D  ppmplt         s              1
     D  pppexp         s              1
     D  pplotr         s              1
     D  pppsra         s              1
     D  pppltd         s              1
     D  ppossa         s              1
     D  ppsqto         s              1
     D  ppbrka         s              1
     D  ppexpe         s              1
     D  ppspn1         s              1
     D  ppspn2         s              3  0
     D  ppspn3         s             10
     D  pfrom          s              6
750aAD  ppspck         s              1
750aAD  ppsbrd         s              1

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

     D w1lset          s              6
     D w1lpgm          s             10
     D savew1lpgm      s             10
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
     *  *RCVLBL  -  Receiving options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPGM  -  Receiving label program.
     *    OPUPCT  -  Ideal slot usage percentage.
     *    OPPDEF  -  PIR minimum number of slots priority.
     *    OPPBLD  -  PIR same build code priority.
     *    OPPACT  -  PIR same activity zone priority.
     *    OPFDEF  -  Fixed minimum number or slots priority.
     *    OPFASL  -  Fixed same aisle priority.
     *    OPFSID  -  Fixed same side priority.
     *    OPFLVL  -  Fixed highest level priority.
     *    OPPASL  -  PIR same aisle priority.
     *    OPPFRC  -  Force PIR same aisle priority.
     *    OPPLCN  -  Use generic license plates.
     *    OPPCHM  -  Check chimney (Y,N)
     *    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
     *    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
     *    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
     *    OPEXCK  -  Expiration date check (1,2,3)
     *                What to do when exp date being rcvd comes
     *                earlier than existing overflow exp date ...
     *                  1 = Let it go through
     *                  2 = Prevent
     *                  3 = Warn user & log when overridden
     *    OPCWEN  -  Allow catch weight entry (1,2,3)
     *                  1 = Every receipt
     *                  2 = First receipt only
     *                  3 = Never
     *    OPCWTP  -  Catch weight value entered (1,2,3)
     *                  1 = User choice
     *                  2 = Average
     *                  3 = Total
     *    OPCWFR  -  Force catch weight entry (Y,N)
     *    OPIPCK  -  Ignore existing pick slots (Y,N)
     *    OPRUPC  -  Prompt user for Retail UPC during receiving? (Y,N)
     *    OPRUPS  -  Allow user to skip Retail UPC scan? (Y,N)
     *    OPRUPF  -  Require Retail UPC on file before receipt? (Y,N)
     *    OPMSPO  -  Allow single po attached to multiple Super P/Os? (Y/N)
     *    OPMPLT  -  Allow Gui Multiple Pallet Receiving    (Y,N)     (Y/N)
     *    OPPEXP  -  Allow Partial Export in gui Receiving  (Y,N)     (Y/N)
     *    OPLOTR  -  Lot required if lot item               (Y,N)     (Y/N)
     *    OPPSRA  -  Allow Pick slot receiving              (Y,L,N)   (Y/N)
     *    OPPLTD  -  Default pallets to 1                   (Y,N)     (Y/N)
     *    OPOSSA  -  Allow offsite storage receipt          (Y,N)     (Y/N)
     *    OPSQTO  -  Show qty ordered during receiving      (Y,N)     (Y/N)
     *    OPBRKA  -  Allow breakdown qty to be received     (Y,N)     (Y/N)
     *    OPEXPE  -  Expiration date Error or Warning       (E,W)     (Y/N)
     *    OPSPN1  -  Spin pallet for license placement      (Y,N)     (Y/N)
     *    OPSPN2  -  Spin pallet length                               (Y/N)
     *    OPSPN3  -  Spin pallet text                                 (Y/N)
750aA*    OPSPCK  -  Show pack description                  (Y,N)     (Y/N)
750aA*    OPSBRD  -  Show brand                             (Y,N)     (Y/N)
     *
     * Data structure
     *
     D optionRec       ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  oppchm                24     24
     D  oppmix                25     25
     D  opapck                26     26
     D  opfrcm                27     27
     D  opexck                28     28
     D  opcwen                29     29
     D  opcwtp                30     30
     D  opcwfr                31     31
     D  opipck                32     32
     D  oprupc                33     33
     D  oprups                34     34
     D  oprupf                35     35
     D  opmspo                36     36
     D  opmplt                37     37
     D  oppexp                38     38
     D  oplotr                39     39
     D  oppsra                40     40
     D  oppltd                41     41
     D  opossa                42     42
     D  opsqto                43     43
     D  opbrka                44     44
     D  opexpe                45     45
     D  opspn1                46     46
     D  opspn2                47     49  0
     D  opspn3                50     59
750aAD  opspck                60     60
750aAD  opsbrd                61     61
     D  optend               117    117

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
         //wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);
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

         oplpgm =  pplpgm;
         opupct =  ppupct;
         oppdef =  pppdef;
         oppbld =  pppbld;
         oppact =  pppact;
         opfdef =  ppfdef;
         opfasl =  ppfasl;
         opfsid =  ppfsid;
         opflvl =  ppflvl;
         oppasl =  pppasl;
         oppfrc =  pppfrc;
         opplcn =  ppplcn;
         oppchm =  pppchm;
         oppmix =  pppmix;
         opapck =  ppapck;
         opfrcm =  ppfrcm;
         opexck =  ppexck;
         opcwen =  ppcwen;
         opcwtp =  ppcwtp;
         opcwfr =  ppcwfr;
         opipck =  ppipck;
         oprupc =  pprupc;
         oprups =  pprups;
         oprupf =  pprupf;
         opmspo =  ppmspo;
         opmplt =  ppmplt;
         oppexp =  pppexp;
         oplotr =  pplotr;
         oppsra =  pppsra;
         oppltd =  pppltd;
         opossa =  ppossa;
         opsqto =  ppsqto;
         opbrka =  ppbrka;
         opexpe =  ppexpe;
         opspn1 =  ppspn1;
         opspn2 =  ppspn2;
         opspn3 =  ppspn3;
750aA    opspck =  ppspck;
750aA    opsbrd =  ppsbrd;
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
         // the first sets of edit apply to receiving options
         if pfrom = 'M31500';
           // validate program to print receiving labels
           if pplpgm <> ' ' and pplpgm <> '*NONE' and ppplcn = 'N';
             // save the label program name if it begins with RFMT.
             // so it can be replaced after the edit.
             if %subst(pplpgm:1:4) = 'RFMT';
               savew1lpgm = pplpgm;
               w1lset = %subst(pplpgm: 5 : 6);
               w1lpgm = %subst(pplpgm: 1 : 4);
             endif;
      /end-free
     c                   if        w1lpgm <> 'RFMT'
     C                   call      w1lpgm                               50
     C                   parm      '*CLOSE  '    $rcmd             8
     C                   parm      0             $rtrn#            7 0
     C                   parm      0             $rwhse            3 0
     C                   parm                    $rwhdp            5
     C                   parm                    $rstyp            1
     C                   parm                    $rdisp           12
     C                   parm                    $rpslt           12
     C                   parm      0             $rqty             5 0
     C                   parm                    $rum              2
     C                   parm      0             $rtie             4 0
     C                   parm      0             $rhigh            2 0
     C                   parm                    $ritem           15
     C                   parm                    $rdesc           30
     C                   parm                    $rpdsc           15
     C                   parm                    $rupc            15
     C                   parm      0             $rven            11 0
     C                   parm                    $rvitm           15
     C                   parm                    $rpo              9
     C                   parm      0             $rrcvd            6 0
     C                   parm      0             $rexpd            6 0
     C                   parm                    $rdev            10
     C                   parm                    $rform           10
     *
      /free
               if *in50;
                 pMessage = 'Invalid Label Program';
                 leavesr;
               endif;
             endif;
             // Verify label set name.
             if %subst(w1lpgm:1:4) = 'RFMT';
               if not %open(lblfmtd);
                 open(e) lblfmtd;
               endif;
               chain(n) (w1lset) lblfmtd;
               if not %found(lblfmtd);
                 pMessage = 'Invalid Label Set Name';
                 leavesr;
               endif;
             endif;
             // put the original program back
             if %subst(w1lpgm:1:4) = 'RFMT';
               pplpgm = savew1lpgm;
             endif;
           endif;

         endif;
         // the second sets of edits apply to receiving priorities
         if pfrom = 'M31600';
         // Verify slot usage percentage.
           if ppupct <1 or ppupct >100;
             pmessage = 'Invalide Slot Usage percentage';
             leavesr;
           endif;
           // Verify PIR priorities.
           if pppdef < 1 or pppdef > 4;
             pmessage = 'PIR minimun number of slots must be 1-4';
             leavesr;
           endif;
           if pppbld < 1 or pppbld > 4;
             pmessage = 'PIR same build code must be 1-4';
             leavesr;
           endif;
           if pppact < 1 or pppact > 4;
             pmessage = 'PIR same activity zone must be 1-4';
             leavesr;
           endif;
           if pppasl < 1 or pppasl > 4;
             pmessage = 'PIR same aisle must be 1-4';
             leavesr;
           endif;
           // Verify Fixed priorities.
           if ppfsid < 1 or ppfsid > 4;
             pmessage = 'Fixed same side of aisle must be 1-4';
             leavesr;
           endif;
           if ppfasl < 1 or ppfasl > 4;
             pmessage = 'Fixed same aisle must be 1-4';
             leavesr;
           endif;
           if ppfdef < 1 or ppfdef > 4;
             pmessage = 'Fixed minimum number of slots must be 1-4';
             leavesr;
           endif;
           if ppflvl < 1 or ppflvl > 4;
             pmessage = 'Fixed highest level must be 1-4';
             leavesr;
           endif;
           // Verify that each PIR priority is unique.
           if pppdef = pppbld or
              pppdef = pppact or
              pppdef = pppasl or
              pppbld = pppact or
              pppbld = pppasl or
              pppact = pppasl;
             pmessage = 'PIR priorities must be unique';
             leavesr;
           endif;
           // verify that each fixed priority is unique
           if ppfasl = ppfsid or
              ppfasl = ppfdef or
              ppfasl = ppflvl or
              ppfsid = ppfdef or
              ppfsid = ppflvl or
              ppfdef = ppflvl;
             pmessage = 'Fixed priorities must be unique';
             leavesr;
           endif;
           // verify that the side priority is gt the aisle.
           if ppfsid < ppfasl;
             pmessage = 'Fixed side priority must be greater than aisle';
             leavesr;
           endif;
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

           when parmName = 'FROM';
             pfrom  = %xlate(xlower: xupper: parmValue);

           when parmName = 'OPWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'OPLPGM';
            pplpgm = %trim(parmValue);

           when parmName = 'OPUPCT';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppupct =  %dec(parmValue: 3: 0);

           when parmName = 'OPPDEF';
             if parmValue = '';
               parmValue = '0';
             endif;
            pppdef =  %dec(parmValue: 1: 0);

           when parmName = 'OPPBLD';
             if parmValue = '';
               parmValue = '0';
             endif;
            pppbld =  %dec(parmValue: 1: 0);

           when parmName = 'OPPACT';
             if parmValue = '';
               parmValue = '0';
             endif;
            pppact =  %dec(parmValue: 1: 0);

           when parmName = 'OPFDEF';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppfdef =  %dec(parmValue: 1: 0);

           when parmName = 'OPFASL';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppfasl =  %dec(parmValue: 1: 0);

           when parmName = 'OPFSID';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppfsid =  %dec(parmValue: 1: 0);

           when parmName = 'OPFLVL';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppflvl =  %dec(parmValue: 1: 0);

           when parmName = 'OPPASL';
             if parmValue = '';
               parmValue = '0';
             endif;
            pppasl =  %dec(parmValue: 1: 0);

           when parmName = 'OPPFRC';
            pppfrc = %trim(parmValue);

           when parmName = 'OPPLCN';
            ppplcn = %trim(parmValue);

           when parmName = 'OPPCHM';
            pppchm = %trim(parmValue);

           when parmName = 'OPPMIX';
            pppmix = %trim(parmValue);

           when parmName = 'OPAPCK';
            ppapck = %trim(parmValue);

           when parmName = 'OPFRCM';
            ppfrcm = %trim(parmValue);

           when parmName = 'OPEXCK';
            ppexck = %trim(parmValue);

           when parmName = 'OPCWEN';
            ppcwen = %trim(parmValue);

           when parmName = 'OPCWTP';
            ppcwtp = %trim(parmValue);

           when parmName = 'OPCWFR';
            ppcwfr = %trim(parmValue);

           when parmName = 'OPIPCK';
            ppipck = %trim(parmValue);

           when parmName = 'OPRUPC';
            pprupc = %trim(parmValue);

           when parmName = 'OPRUPS';
            pprups = %trim(parmValue);

           when parmName = 'OPRUPF';
            pprupf = %trim(parmValue);

           when parmName = 'OPMSPO';
            ppmspo = %trim(parmValue);

           when parmName = 'OPMPLT';
            ppmplt = %trim(parmValue);

           when parmName = 'OPPEXP';
            pppexp = %trim(parmValue);

           when parmName = 'OPLOTR';
            pplotr = %trim(parmValue);

           when parmName = 'OPPSRA';
            pppsra = %trim(parmValue);

           when parmName = 'OPPLTD';
            pppltd = %trim(parmValue);

           when parmName = 'OPOSSA';
            ppossa = %trim(parmValue);

           when parmName = 'OPSQTO';
            ppsqto = %trim(parmValue);

           when parmName = 'OPBRKA';
            ppbrka = %trim(parmValue);

           when parmName = 'OPEXPE';
            ppexpe = %trim(parmValue);

750aA      when parmName = 'OPSPCK';
750aA       ppspck = %trim(parmValue);

750aA      when parmName = 'OPSBRD';
750aA       ppsbrd = %trim(parmValue);

           when parmName = 'OPSPN1';
            ppspn1 = %trim(parmValue);

           when parmName = 'OPSPN2';
             if parmValue = '';
               parmValue = '0';
             endif;
            ppspn2 =  %dec(parmValue: 3: 0);

           when parmName = 'OPSPN3';
            ppspn3 = %trim(parmValue);

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
