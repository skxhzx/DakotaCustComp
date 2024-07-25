417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ZONEHUPD    Zone Upd - Pgm for SQL procedure of same name
     *  30 March 2012
     *  Dave Sommerville
     *
     *  Revisions:
     *
610 A*    03/30/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D opzrec        E ds                  extname(optionz) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage                     99
     D  pCmd                          1
     D  pWhse                         3  0
     D  pTruck                       10
     D  pZone                         6
     D  pnxtp                         7  0
213 AD  pbpck                         3  0
     D  pfpal                         1  0
520 AD  pspal                         1
     D  pfcub                         5  2
     D  pfstp                         2  0
520 AD  ppitm                         4  0
     D  pincl                         1
     D  psrch                         2  0
209 AD  pfbld                         1  0
400 AD  ppbld                         1
400 AD  pselm                         1
400 AD  psplt                         1
500aAD  pnwpl                         1
500dAD  pford                         2  0
500cMD  pptyp                         1
520 AD  ppkup                         1
510 AD  pstop                         1
500dAD  pftot                         2  0
500dAD  ptecb                         5  2
500dAD  pticb                         5  2
500dAD  ptstp                         2  0
500dAD  ptord                         2  0
500dAD  ptpcs                         3  0

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
     *  *PICK  -  Picking options
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
214 D**** OPPBRK  -  Break pallets by aisle (Y,N).
214 M*    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
416 A*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
500aA*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
500aA*    OPNWPL  -  Start new pallet when aisle changes if build method
500aA*               is 2=Location.
500dA*    OPFORD  -  Maximu orders per pallet.
520 M*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510 A*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
510aA*    OPGCDE  -  USF Group Code (0-9).
520 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520 A*    OPSPAL  -  Merge pallet should only contain
520 A*               items for single truck pallet (Y=Yes, N=No).
520 A*    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D pickRec         ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
209 AD  opfbld                27     27  0 inz(0)
213 AD  opbpck                28     30  0 inz(0)
214 AD  oppbrk                31     33
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
500aAD  opbmrg                37     37
500aAD  opnwpl                38     38
500dAD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500dAD  opftot                42     43  0 inz(0)
500dAD  optecb                44     48  2 inz(0)
500dAD  opticb                49     53  2 inz(0)
500dAD  optstp                54     55  0 inz(0)
500dAD  optord                56     57  0 inz(0)
500dAD  optpcs                58     60  0 inz(0)
510 AD  opstop                61     61
520 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
510aAD  opgcde                62     62
520 AD  oppkup                62     62
520 AD  opspal                63     63
520 AD  oppitm                64     67  0 inz(0)
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pCmd        A=Add, U=Update, D=Delete
     *      pWhse       Warehouse
     *      pTruck      Truck
     *      pZone       Zone
     *      pIncl       Include
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
     C                   parm                    pCmd
     C                   parm                    pWhse
     C                   parm                    pTruck
     C                   parm                    pZone
     c                   parm                    pnxtp
213 Ac                   parm                    pbpck
     c                   parm                    pfpal
520 Ac                   parm                    pspal
     c                   parm                    pfcub
     c                   parm                    pfstp
520 Ac                   parm                    ppitm
     c                   parm                    pincl
     c                   parm                    psrch
209 Ac                   parm                    pfbld
400 Ac                   parm                    ppbld
400 Ac                   parm                    pselm
400 Ac                   parm                    psplt
500aAc                   parm                    pnwpl
500dAc                   parm                    pford
500cMc                   parm                    pptyp
520 Ac                   parm                    ppkup
510 Ac                   parm                    pstop
500dAc                   parm                    pftot
500dAc                   parm                    ptecb
500dAc                   parm                    pticb
500dAc                   parm                    ptstp
500dAc                   parm                    ptord
500dAc                   parm                    ptpcs

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
500sA
      /free

         *inlr = *on;
         pMessage = ' ';

         exsr GetRec;

         select;
           when pCmd = 'A';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pCmd = 'U';
             if found;
               exsr UpdRec;
             else;
               exsr AddRec;
             endif;
           when pCmd = 'D';
             if found;
               exsr DelRec;
             endif;
           other;
             pMessage = 'Invalid command sent: ' + pCmd
                      + ' (' + %trim(#pgm) +')';
         endsl;

         return;
      /end-free

500sA*----------------------------------------------------------------
500sA*  AddRec    Add record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr AddRec;

         error = *off;
         opzcod = '*PICK';
         exsr FillRec;
         opzdta = pickRec;

         exec sql insert into optionz values(:opzrec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  DelRec    Delete record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr DelRec;

         error = *off;
         opzcod = '*PICK';

         exec sql delete from optionz
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Deleting record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  FillRec   Fill record fields
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr FillRec;

         opzwhs = pWhse;
         opztrk = pTruck;
         opzzon = pZone;

         opnxtp = pnxtp;
213 A    opbpck = pbpck;
         opfpal = pfpal;
520 A    opspal = pspal;
         opfcub = pfcub;
         opfstp = pfstp;
520 A    oppitm = ppitm;
         opincl = pincl;
         opsrch = psrch;
209 A    opfbld = pfbld;
400 A    oppbld = ppbld;
400 A    opselm = pselm;
400 A    opsplt = psplt;
500aA    opnwpl = pnwpl;
500dA    opford = pford;
500cM    opptyp = pptyp;
520 A    oppkup = ppkup;
510 A    opstop = pstop;
500dA    opftot = pftot;
500dA    optecb = ptecb;
500dA    opticb = pticb;
500dA    optstp = ptstp;
500dA    optord = ptord;
500dA    optpcs = ptpcs;

       endsr;
      /end-free

500sA*----------------------------------------------------------------
500sA*  GetRec    Get record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr UpdRec;

         found = *off;
         opzcod = '*PICK';

         exec sql select * into :opzrec
                  from optionz
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free


500sA*----------------------------------------------------------------
500sA*  UpdRec    Update record
500sA*----------------------------------------------------------------
500sA
      /free
500sA  begsr UpdRec;

         error = *off;
         opzcod = '*PICK';
         exsr FillRec;
         opzdta = pickRec;

         exec sql update optionz
                  set opzdta = :opzdta
                  where opzcod = :opzcod
                    and opzwhs = :pWhse
                    and opztrk = :pTruck
                    and opzzon = :pZone;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opzcod) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Truck(' + %trim(pTruck) + ') '
                    + 'Zone(' + %trim(pZone) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
