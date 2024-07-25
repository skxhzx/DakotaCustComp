      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD520RDA  Initialize new zone option OPPITM
     *  24 August 2009
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    08/24/09  RBD  5.20  P#00219
     *      - Created. Program will set OPPITM to one for all *PICK
     *        records.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Foptionz   up   e           k disk

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     *     11/28/94  DAS
     *       - Changed OPFSTP to 2 digits from 1.
     *
     *     02/16/95  DAS   2.09
     *       - Moved option from OPTIONS to OPTIOND in order to have
     *         the options by department.
     *       - Added option OPFBLD for identifying the method to use
     *         for building a fixed pallet.
     *
213 A*     06/11/96  DAS   2.13
     *       - Redefined OPBPCK to 3.0 from 2.0.
     *       - Added option OPPBRK.
     *
214 A*     07/01/96  DAS
     *       - Redefined OPPBRK to 3 from 1 and to contain aisle
     *         instead of Y/N.
     *
300 A*     06/11/97  DAS
     *       - Moved into OPTIONZ from OPTIOND file.
     *       - OPPBRK is not used with zones.
     *
416 A*     06/20/01  MLB  4.16
     *       - Added new option for field OPPBLD for
     *         record *PICK.
     *
500 A*     02/21/06  DAS  5.00
     *       - Added option OPTOTE and OPTCUB.
     *
500aA*     03/02/06  DAS  5.00a
     *       - Added option OPBMRG and OPNWPL before OPTOTE & OPTCUB
     *
500bA*     03/31/06  DAS  5.00b
     *       - Added option OPFPCS.
     *
500cA*     04/06/06  DAS  5.00c
     *       - Renamed OPTOTE to OPPTYP.
     *       - Added option OPNWOR.
     *
500dA*     04/18/06  DAS  5.00d
     *       - Added option xxxx
     *
510 A*     01/03/07  JCJ  5.10
     *       - Added option OPSTOP.
     *
510aA*     01/18/07  JCJ  5.10a
     *       - Added option OPGCDE.
520 A*       - OPGCDE is used only by US Foods.  For all other
     *         clients, pos 62 is populated by OPPKUP.
     *
520 A*     08/10/09  RBD  5.20  P#00219
     *       - Added record type *PICKLBA which holds printing info
     *         for the standard pick, retail, and tote labels.
     *       - Added record type *PICKLBB which holds printing info
     *         for the pick list and ASN labels and pick list report.
     *       - Added option OPPITM to *PICK.
     *       - Added options OPTAXR and OPCHKR to *PICKLBL.
     *       - Added notation for fields OPPKUP, OPSPAL, and OPAISL
     *         which were previously added to ZH122.
     *       - Revised OPPTYP to include B = Batch.
     *
     *----------------------------------------------------------------
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
500cM*    OPFORD  -  Maximum orders per pallet.
500cM*    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
500 A*    OPFTOT  -  Maximum totes per pallet.
500 A*    OPTECB  -  External tote cube.
500 A*    OPTICB  -  Internal tote cube.
500bA*    OPTSTP  -  Maximum stops per tote.
500bA*    OPTORD  -  Maximum orders per tote.
500bA*    OPTPCS  -  Maximum pieces per tote.
510 A*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
510aA*    OPGCDE  -  USF Group Code (0-9).
520 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520 A*    OPSPAL  -  Merge pallet should only contain
520 A*               items for single truck pallet (Y=Yes, N=No).
520 A*    OPPITM  -  Maximum items per pallet.
     *
     * Data structure
     *
     D opzdta          ds
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
500cMD  opptypold             39     39
500cMD  opford                39     40  0 inz(0)
500cMD  opptyp                41     41
500aAD  opftot                42     43  0 inz(0)
500aAD  optecb                44     48  2 inz(0)
500aAD  opticb                49     53  2 inz(0)
500aAD  optstp                54     55  0 inz(0)
500aAD  optord                56     57  0 inz(0)
500bAD  optpcs                58     60  0 inz(0)
510 AD  opstop                61     61
520 A** Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
510aAD  opgcde                62     62
520 AD  oppkup                62     62
520 AD  opspal                63     63
520 AD  oppitm                64     67  0 inz(0)
     D  opdend               117    117

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *   Initialize new option

     C                   if        opzcod = '*PICK'
     C                   eval      oppitm = 1
     C                   update    opzrec
     C                   endif
