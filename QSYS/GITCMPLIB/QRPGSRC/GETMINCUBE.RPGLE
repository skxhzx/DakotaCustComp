      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETMINCUBE  Get minimum cube for zone
     *  22 June 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    06/22/15  DAS  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptionz   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  trkTmpl        s             10
     D  zoneTmpl       s             10

     *----------------------------------------------------------------
     *  Parms
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtid          s              5
     D  pZone          s              6
     D  pMinCube       s              5p 2

     *----------------------------------------------------------------
     *  OPTIONZ data structure
     *----------------------------------------------------------------
     D opzdta          ds
     D  opzend               117    117

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
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
500dA*    OPFORD  -  Maximu orders per pallet.
520 M*    OPPTYP  -  Pallet type (P=Pallet, T=Tote, B=Batch).
500dA*    OPFTOT  -  Maximum totes per pallet.
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500dA*    OPTPCS  -  Maximum pieces per tote.
510 A*    OPSTOP  -  Prevent *SP flag (Y=Yes, N=No).
510aA*    OPGCDE  -  USF Group Code (0-9).
520 A*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520 A*    OPSPAL  -  Merge pallet should only contain
520 A*               items for single truck pallet (Y=Yes, N=No).
520 A*    OPPITM  -  Maximum items per pallet.
650aA*    OPLBL   -  Pick Label Printing method.
650aA*                N = Normal
650aA*                S = Side by Side
656aA*                C = Custom
700aA*    OPPMTZ  -  Allow multi-truck assignments.
700aA*    OPDDDO  -  Dock door drop off order.
700aA*    OPMCUB  -  Minimum cube per fixed pallet.
     *
     * Data structure
     *
     D opdata          ds
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
700aD ***Note: Pos 62 is OPGCDE for USF, but OPPKUP for all other clients.
700aD ** OPGCDE moved to pos 76 as of 700
700aDD**opgcde                62     62
520 AD  oppkup                62     62
520 AD  opspal                63     63
520 AD  oppitm                64     67  0 inz(0)
650aAD  oplbl                 68     68
700aAD  opdddo                69     69
700aAD  opmcub                70     74  2 inz(0)
700aAD  wkmcub                70     74
700aAD  oppmtz                75     75
700aAD  opgcde                76     76
     D  opend                117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getzont2

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRtid       Route id
     *      pZone       Zone
     *
     *    Returned Parameters
     *      pMinCube    Minimum pallet cube
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRtid
     C                   parm                    pZone
     C                   parm                    pMinCube

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMinCube = 0;

        // Get zone template.

        getzontmp2(pWhse: pRtid: trkTmpl: zoneTmpl);

        // If not found, leave

        if zoneTmpl = '';
          return;
        endif;

        // Get *PICK options

        chain  ('*PICK': pWhse: zoneTmpl: pZone) optionz;
        if not %found(optionz);
          return;
        endif;

        // Get minimum cube, protect against blanks.

        opdata = opzdta;

        monitor;
          pMinCube = opmcub;
        on-error;
          pMinCube = 0;
        endmon;

        return;

      /end-free

