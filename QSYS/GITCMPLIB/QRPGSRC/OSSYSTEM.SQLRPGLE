      /copy *libl/qcopysrc,hspecs
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
640 A*    08/13/12  DAS  6.40
     *      - Created.
     *
650aA*    03/07/14  DAS  6.50a
     *      - Added pSessId, pUser, pPgm.
     *      - Added call to WRTSESSLOG with submitted info.
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
650aAD  pSessId        s             40
650aAD  pUser          s             10
650aAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  pepm           s              1
     D  prf            s              1
     D  pcapc          s              1
     D  pletd          s              1
410 AD  pwrnc          s              1
410 AD  prg1c          s              3  1
410 AD  prg2c          s              3  1
411 AD  pimpi          s              1
412 AD  picw           s              1
412 AD  pmpck          s              1
413aAD  prcdy          s              1  0
413aAD  ppkdy          s              1  0
414bAD  prths          s              3  0
414bAD  pcrhs          s              3  0
414bAD  ppohs          s              3  0
414bAD  piahs          s              3  0
414bAD  pmshs          s              3  0
510cAD  ptbjq          s              1
510 AD  pishs          s              3  0
610bAD  puci           s              1
610cAD  pwrncr         s              1
610cAD  picwr          s              1
530 AD  ptrax          s              1
640eAD  ptaxr          s              1
640eAD  pchkr          s              1
640eAD  pvoice         s              1

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

405 A*----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
610bD*****OPWRNC  -  Perform catch weight variance check (Y,N).
610bM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import item fields from host.(Y,N).
610bD*****OPICW   -  Individual catch weight entry (Y,N).
610bM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414bA*    OPRTHS  -  Number of weeks - exported routes to keep.
414bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510c *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
510 A*    OPISHS  -  Number of weeks to keep history file
610aA*    OPUCI   -  Use UCI processing (Y,N)
610bA*    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
610bM*    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
530 A*    OPTRAX  -  Using TRAX module (Y,N).
640eA*    OPTAXR  -  Using TAXR module (Y/N).
640eA*    OPCHKR  -  Using CHKR module (Y/N).
640eA*    OPVOICE -  Using VOICE module (Y/N).
     *
     * Data structure
     *
     D optionRec       ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
412 AD  opmpck                14     14
413aAD  oprcdy                15     15  0
413aAD  oppkdy                16     16  0
414bAD  oprths                17     19  0
414bAD  opcrhs                20     22  0
414bAD  oppohs                23     25  0
414bAD  opiahs                26     28  0
414bAD  opmshs                29     31  0
510cAD  optbjq                32     32
510 AD  opishs                33     35  0
610bAD  opuci                 36     36
610cAD  opwrncr               37     37
610cAD  opicwr                38     38
530 AD  optrax                39     39
640eAD  optaxr                40     40
640eAD  opchkr                41     41
640eAD  opvoice               42     42
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
     c                   parm                    pepm
     c                   parm                    prf
     c                   parm                    pcapc
     c                   parm                    pletd
410 Ac                   parm                    pwrnc
410 Ac                   parm                    prg1c
410 Ac                   parm                    prg2c
411 Ac                   parm                    pimpi
412 Ac                   parm                    picw
412 Ac                   parm                    pmpck
413aAc                   parm                    prcdy
413aAc                   parm                    ppkdy
414bAc                   parm                    prths
414bAc                   parm                    pcrhs
414bAc                   parm                    ppohs
414bAc                   parm                    piahs
414bAc                   parm                    pmshs
510cAc                   parm                    ptbjq
510 Ac                   parm                    pishs
610bAc                   parm                    puci
610cAc                   parm                    pwrncr
610cAc                   parm                    picwr
530 Ac                   parm                    ptrax
640eAc                   parm                    ptaxr
640eAc                   parm                    pchkr
640eAc                   parm                    pvoice

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

	        opepm   = pepm;
         oprf    = prf;
         opcapc  = pcapc;
         opletd  = pletd;
         opwrnc  = pwrnc;
         oprg1c  = prg1c;
         oprg2c  = prg2c;
         opimpi  = pimpi;
         opicw   = picw;
         opmpck  = pmpck;
         oprcdy  = prcdy;
         oppkdy  = ppkdy;
         oprths  = prths;
         opcrhs  = pcrhs;
         oppohs  = ppohs;
         opiahs  = piahs;
         opmshs  = pmshs;
         optbjq  = ptbjq;
         opishs  = pishs;
         opuci   = puci;
         opwrncr = pwrncr;
         opicwr  = picwr;
         optrax  = ptrax;
         optaxr  = ptaxr;
         opchkr  = pchkr;
         opvoice = pvoice;

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
