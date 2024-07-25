      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSVOICE    OPS *VOICE Upd - Pgm for SQL procedure of same name
     *  15 August 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
640 A*    08/15/12  DAS  6.40
     *      - Created.
     *
650aA*    03/07/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm.
     *      - Added call to WRTSESSLOG with submitted info.
     *
730aA*    01/03/20  LMC  7.30a
     *      - Added Extended stop number length
     *      - Added Voice location verification.
740aA*    08/04/20  LMC  7.40a
     *      - Added call to op331 to sync runner options
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*VOICE')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  pincp          s              1
     D  pcrtr          s              1
     D  puplv          s              1
     D  pvmrg          s              1
     D  poutf          s              1
     D  pfclr          s              1
     D  pvmlt          s              1
     D  pvspn          s              1
     D  pvspz          s              1
     D  pvslw          s              1
     D  pvcep          s              1
     D  pvssn          s              1
     D  pvcpz          s              1
730aAD  pvest          s              1
730aAD  pvgvf          s              1

740aA*----------------------------------------------------------------
740aa*  Program parameters
740aA*----------------------------------------------------------------

740aAD $parms          ds
740aAD  $pcmd                  1      8
740aAD  $pprg                  9     18
740aAD  $puky                 19     68
740aAD  $prtn                 69     76
740aAD  $perm                 77    136
740aAD  $pmsg                 77     80
740aA
740aA*   Redefine key
740aA
740aAD  $pwhse                19     21  0
740aAD  $pvoice               22     22
740aAD  $prunner              23     23
740aAD  $pflgpl               24     24
740aAD  $pflgrt               25     25
740aAD  $pflgmr               26     26
740aAD  $pflgtf               27     27
740aAD  $pflgcl               28     28
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

650aAD logText         s            100

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
     *  *VOICE  -  PIR Voice options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPINCP  -  Include pack description (Y/N)
500 A*    OPCRTR  -  Create RUNNER entries for shorts (Y/N)
500aA*    OPUPLV  -  Update Label with quantity picked during Voice
500aA*               selection (Y/N)
500aA*               NOTE: Any change to this field will cause OPUPLR
500aA*                     in the *RUNNER options record to be updated.
500aA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
500aA*    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500cM*    OPFCLR  -  Clear Runner flag if qty still short/out? (Y/N)
500cA*               NOTE: Any change to this field will cause OPCLRF
500cA*                     in the *RUNNER options record to be updated.
500kA*    OPVMLT  -  Allow multiple transaction (Y/N)
500kA*    OPVSPN  -  Speak pallet number (Y/N)
500kA*    OPVSPZ  -  Speak pallet zone (Y/N)
500kA*    OPVSLW  -  Speak large quantity warning (Y/N)
500kA*    OPVSUW  -  Speak unit of measure change warning (Y/N)
     *
     * Data structure
     *
     *----------------------------------------------------------------

     D optionRec       ds
     D  opincp                 1      1
500 AD  opcrtr                 2      2
500aAD  opuplv                 3      3
500aAD  opvmrg                 4      4
500aAD  opoutf                 5      5
500cMD  opfclr                 6      6
500kAD  opvmlt                 7      7
500kAD  opvspn                 8      8
500kAD  opvspz                 9      9
500kAD  opvslw                10     10
500kAD  opvcep                11     11
500kAD  opvssn                12     12
500kAD  opvcpz                13     13
730aAD  opestp                14     14
730aAD  opgvfy                15     15
     D  optend               117    117

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

650aA /copy qcopysrc,p.wrtsessl

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
650aA*      pSessId     Session Id
650aA*      pUser       GUI User
650aA*      pPgm        GUI dictionary.program
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
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
650aAC                   parm                    pSessId
650aAC                   parm                    pUser
650aAC                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
     c                   parm                    pincp
     c                   parm                    pcrtr
     c                   parm                    puplv
     c                   parm                    pvmrg
     c                   parm                    poutf
     c                   parm                    pfclr
     c                   parm                    pvmlt
     c                   parm                    pvspn
     c                   parm                    pvspz
     c                   parm                    pvslw
     c                   parm                    pvcep
     c                   parm                    pvssn
     c                   parm                    pvcpz
730aAc                   parm                    pvest
730aAc                   parm                    pvgvf

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

650aA    // Write GLOSESSLOG record
650aA    logText = 'objloc:' + pObjLoc;
650aA    wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'FLDVALID';
             exsr FldValid;
           when pObjLoc = 'BEFOREACT';
             exsr BeforeAct;
           when pObjLoc = 'AFTERACT';
             exsr AfterAct;
740aA      when pObjLoc = 'RUNNER';
740aA        exsr syncRunner;
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

500sA*----------------------------------------------------------------
500sA*  BeforeAct    Before action update
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr BeforeAct;

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

	        opincp  = pincp;
	        opcrtr  = pcrtr;
	        opuplv  = puplv;
	        opvmrg  = pvmrg;
	        opoutf  = poutf;
	        opfclr  = pfclr;
	        opvmlt  = pvmlt;
	        opvspn  = pvspn;
	        opvspz  = pvspz;
	        opvslw  = pvslw;
	        opvcep  = pvcep;
	        opvssn  = pvssn;
	        opvcpz  = pvcpz;
730aA    opestp  = pvest;
730aA    opgvfy  = pvgvf;

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
740aA*----------------------------------------------------------------
740aA*  syncrunner  Sync fields in runner options
740aA*----------------------------------------------------------------

740aA /free
740aA  begsr syncrunner;

740aA    $pwhse = pwhse;
740aA    $prunner = 'Y';
740aA    $pflgpl  = puplv;
740aA    $pflgrt  = pcrtr;
740aA    $pflgmr  = pvmrg;
740aA    $pflgtf  = poutf;
740aA    $pflgcl  = pfclr;
740aA /end-free
740aAC                   call      'OP331'
740aAC                   parm                    $parms
740aA /free

740aA  endsr;
740aA /end-free
