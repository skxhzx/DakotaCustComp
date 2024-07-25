      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  OCTRAX  OPC *TRAX Upd - Pgm for SQL procedure of same name
     *  14 March 2018
     *  Retha Davis
     *
     *  Revisions:
     *
720 A*    03/14/18  RBD  7.20
     *      - Created.
     *
720aA*    04/04/18  KDE  7.20a
     *      - When purely numeric Customer pad to 11 digits with zeros
     *
730aA*    03/30/19  RBD  7.30a
     *      - Added several customer level options.
     *
730bA*    09/12/19  RBD  7.30b
     *      - Fix: only edit 'Customer on site delivery verification
     *        period' if 'Customer on site delivery' is enabled.
     *
     *----------------------------------------------------------------
     *  Client Custom
     *----------------------------------------------------------------
     *  Client Custom Revisions - SouthWest Trader
     *
SWTa *    08/30/19  GJA  SWTa
     *      - Fix: customer number format
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Clients
     *----------------------------------------------------------------

SWTa D/copy qcopysrc,ID#SWT
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D opcrec        E ds                  extname(optionc) inz(*EXTDFT)
     D  optionCode     s             10    inz('*TRAX')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pObjLoc        s             10
     D  pSubCmd        s             10
     D  pData          s            117
     D  pWhse          s              3  0
     D  pCus           s             20
     D  pcwr           s              1
     D  pbda           s              1
     D  pgbd           s              1
     D  prtq           s              1
     D  potq           s              1
     D  pcce           s              1
     D  psig           s              1
     D  ppiv           s              1
     D  psda           s              1
     D  pare           s              1
     D  ppal           s              1
     D  pbul           s              1
     D  pgss           s              1
     D  pgsu           s              1
     D  pnsr           s              1
     D  pfbd           s              1
730aAD  psor           s              1
730aAD  podx           s              1
730aAD  podp           s              2  0
730aAD  pont           s              1
730aAD  potp           s              1
730aAD  pnsb           s              1

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D logText         s            100

     D client          s             10
     D clientloc       s             10
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

     *----------------------------------------------------------------
     *  *TRAX  -  TRAX customer options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCCWR  -  Catch weight required
     *    OPCBDA  -  Breakdowns allowed
     *    OPCGBD  -  Generic breakdown allowed
     *    OPCRTQ  -  Pre-trip questions
     *    OPCOTQ  -  Post-trip questions
     *    OPCCCE  -  Credit card enabled
     *    OPCSIG  -  Signature enabled
     *    OPCPIV  -  Print invoice
     *    OPCSDA  -  Send data after stop
     *    OPCARE  -  Add return enabled
     *    OPCPAL  -  Pallets enabled
     *    OPCBUL  -  Bulk items enabled
     *    OPCGSS  -  GS1 scanning
     *    OPCGSU  -  GS1 unique
     *    OPCNSR  -  Non scan reason prompt.
     *    OPCFBD  -  Filter by department.
730aA*    OPCSOR  -  Sort items by compartment Y/N.
730aA*    OPCODX  -  Customer on site delivery enable Y/N.
730aA*    OPCODP  -  Customer on site delivery verification period, 5-60.
730aA*    OPCONT  -  On truck picking Y/N.
730aA*    OPCOTP  -  Override truck picking Y/N.
730aA*    OPCNSB  -  No signee button on signature screen Y/N.
     *
     * Data structure
     *
     D optionRec       ds
     D  opccwr                 5      5
     D  opcbda                14     14
     D  opcgbd                15     15
     D  opcrtq                16     16
     D  opcotq                17     17
     D  opccce                18     18
     D  opcsig                19     19
     D  opcpiv                20     20
     D  opcsda                21     21
     D  opcare                76     76
     D  opcpal                79     79
     D  opcbul                82     82
     D  opcgss                89     89
     D  opcgsu                90     90
     D  opcnsr               100    100
     D  opcfbd               101    101
730aAD  opcsor               103    103
730aAD  opcodx               104    104
730aAD  opcodp               105    106  0
730aAD  opcont               107    107
730aAD  opcotp               108    108
730aAD  opcnsb               109    109
     D  opcend               117    117

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
     *      pSessId     Session Id
     *      pUser       GUI User
     *      pPgm        GUI dictionary.program
     *      pObjLoc     External object location
     *      pSubCmd     A=Add, U/C=Update, D=Delete
     *      pWhse       Warehouse
     *      pCus        Customer
     *      option fields
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *      pData      OPTIONC data field
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pData
     C                   parm                    pWhse
     C                   parm                    pCus
     c                   parm                    pcwr
     c                   parm                    pbda
     c                   parm                    pgbd
     c                   parm                    prtq
     c                   parm                    potq
     c                   parm                    pcce
     c                   parm                    psig
     c                   parm                    ppiv
     c                   parm                    psda
     c                   parm                    pare
     c                   parm                    ppal
     c                   parm                    pbul
     c                   parm                    pgss
     c                   parm                    pgsu
     c                   parm                    pnsr
     c                   parm                    pfbd
730aAc                   parm                    psor
730aAc                   parm                    podx
730aAc                   parm                    podp
730aAc                   parm                    pont
730aAc                   parm                    potp
730aAc                   parm                    pnsb

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pMessage = ' ';

         // Write GLOSESSLOG record
         logText = 'objloc:' + pObjLoc;
         wrtsesslog(pSessId: #pgm: pPgm: pUser: logText);

         select;
           when pObjLoc = 'AFTERACT';
730aA        if pSubCmd = 'A' or pSubCmd = 'U';
730aA          exsr editFlds;
730aA        endif;
730aA        if pMessage = *blanks;
               exsr AfterAct;
730aA        endif;
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
         opcdta = optionRec;

         exec sql insert into optionc values(:opcrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opccod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Cust(' + %trim(pCus) + ') '
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
SWTaA    if client <> SWT;
720aA      if %check('0123456789':%trim(pCus)) <> 0;
720aA         // Alph-numeric customer
720aA      else;
720aA         // purely numeric.  Set as zero padded and 11 long
720aA         monitor;
720aA           pCus = %editc(%dec(%trim(pCus):11:0):'X');
720aA         on-error;
720aA           pCus = *blanks;
720aA         endmon;
720aA      endif;
SWTaA    endif;

         select;

           when pSubCmd = 'A';
             if found;
               pMessage = 'Cannot add, customer '
                        + %trim(pCus)
                        + ' already exists.';
             else;
               exsr AddRec;
             endif;

           when pSubCmd = 'U' or pSubCmd = 'C';
             if found;
               exsr UpdRec;
             else;
               pMessage = 'Cannot update, customer '
                        + %trim(pCus)
                        + ' does not exist';
             endif;

           when pSubCmd = 'D';
             if found;
               exsr DelRec;
             else;
               pMessage = 'Cannot delete, customer '
                        + %trim(pCus)
                        + ' does not exist';
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

         exec sql delete from optionc
                  where opccod = :optionCode
                    and opcwhs = :pWhse
                    and opccus = :pCus;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opccod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Cust(' + %trim(pCus) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  editFlds  Verify contents of data passed
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr editFlds;

          if %parms > 25;

730bD    // if pOdp < 5 or pOdp > 60;
730bM       if pOdx = 'Y' and (pOdp < 5 or pOdp > 60);
              pMessage = 'Cust on site delivery verification +
                          period must be 5 - 60';
              leavesr;
            endif;

          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opccod = optionCode;
         opcwhs = pWhse;
         opccus = pCus;

         opccwr = pcwr;
         opcbda = pbda;
         opcgbd = pgbd;
         opcsig = psig;
         opcpiv = ppiv;
         opcare = pare;
         opcpal = ppal;
         opcbul = pbul;
         opcgss = pgss;
         opcgsu = pgsu;

730aA    if %parms > 25;
730aA      opcsor = psor;
730aA      opcodx = podx;
730aA      opcodp = podp;
730aA      opcont = pont;
730aA      opcotp = potp;
730aA      opcnsb = pnsb;
730aA    endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :opcrec
                  from optionc
                  where opccod = :optionCode
                    and opcwhs = :pWhse
                    and opccus = :pCus;

         if sqlstt = sqlSuccess;
           found = *on;
           optionrec = opcdta;
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
         opcdta = optionRec;

         exec sql update optionc
                  set opcdta = :opcdta
                  where opccod = :opccod
                    and opcwhs = :pWhse
                    and opccus = :pCus;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opccod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Cust(' + %trim(pCus) + ') '
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

