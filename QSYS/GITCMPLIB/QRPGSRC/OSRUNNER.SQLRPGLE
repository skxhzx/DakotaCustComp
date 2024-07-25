      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OSRUNNER   OPS *RUNNER Upd - Pgm for SQL procedure of same name
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
740aA*    08/05/20  LMC  7.40a
     *      - Added call to op331 to sync voice  options
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*RUNNER')

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
     D  pcrtm          s              1
     D  puplr          s              1
     D  prplf          s              1
     D  pmrgf          s              1
     D  pclrf          s              1
     D  prnrm          s              1
     D  pclsf          s              1
     D  poutf          s              1
     D  prpck          s              1
     D  prlbl          s              1
     D  prbdu          s              1
     D  prscn          s              1
     D  prvfs          s              1
     D  prvfq          s              1
     D  prloa          s              1

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
500bA*               NOTE: Any change to this field will cause OPFCLR
500bA*                     in the *VOICE options record to be updated.
     *    OPRNRM  -  Send break message to user when new Runner
     *               task has been assigned. (Y/N)
     *    OPCLSF  -  Update Label quantity at flag close (Y/N).
     *    OPOUTF  -  Create Runner entry after slot marked out. (Y/N)
500aA*    OPRPCK  -  Print Runner pick list. (Y/N)
500aA*    OPRLBL  -  Print Runner pick labels. 0=No, 1=full size Zebra
500aA*               printer, 2=Belt printer
500cA*    OPRBDU  -  Allow shorts to be filled with breakdown units (Y/N).
520 A*    OPRSCN  -  Scan tran# or label# to start pick.
520 A*                 1=tran#, 2=label#.
520 A*    OPRVFS  -  Verify pick slot, Y/N.
520 A*    OPRVFQ  -  Verify qty found, Y/N.
520 A*    OPRLOA  -  Using loader module, Y/N.
     *----------------------------------------------------------------
     * Data structure
     *
     D optionRec       ds
     D  opcrtm                 1      1
     D  opuplr                 2      2
     D  oprplf                 3      3
     D  opmrgf                 4      4
     D  opclrf                 5      5
     D  oprnrm                 6      6
     D  opclsf                 7      7
     D  opoutf                 8      8
500aAD  oprpck                 9      9
500aAD  oprlbl                10     10
500cAD  oprbdu                11     11
520 AD  oprscn                12     12
520 AD  oprvfs                13     13
520 AD  oprvfq                14     14
520 AD  oprloa                15     15
520 AD  optendr              117    117

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
     c                   parm                    pcrtm
     c                   parm                    puplr
     c                   parm                    prplf
     c                   parm                    pmrgf
     c                   parm                    pclrf
     c                   parm                    prnrm
     c                   parm                    pclsf
     c                   parm                    poutf
     c                   parm                    prpck
     c                   parm                    prlbl
     c                   parm                    prbdu
     c                   parm                    prscn
     c                   parm                    prvfs
     c                   parm                    prvfq
     c                   parm                    prloa

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
740aA      when pObjLoc = 'VOICE';
740aA        exsr syncVoice;
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

	        opcrtm  = pcrtm;
	        opuplr  = puplr;
	        oprplf  = prplf;
	        opmrgf  = pmrgf;
	        opclrf  = pclrf;
	        oprnrm  = prnrm;
	        opclsf  = pclsf;
	        opoutf  = poutf;
	        oprpck  = prpck;
	        oprlbl  = prlbl;
	        oprbdu  = prbdu;
	        oprscn  = prscn;
	        oprvfs  = prvfs;
	        oprvfq  = prvfq;
	        oprloa  = prloa;

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
740aA*  syncvoice   Sync fields in voice  options
740aA*----------------------------------------------------------------

740aA /free
740aA  begsr syncvoice;

740aA    $pwhse = pwhse;
740aA    $pvoice  = 'Y';
740aA    $pflgpl  = puplr;
740aA    $pflgrt  = pcrtm;
740aA    $pflgmr  = pmrgf;
740aA    $pflgtf  = poutf;
740aA    $pflgcl  = pclrf;
740aA /end-free
740aAC                   call      'OP331'
740aAC                   parm                    $parms
740aA /free

740aA  endsr;
740aA /end-free
