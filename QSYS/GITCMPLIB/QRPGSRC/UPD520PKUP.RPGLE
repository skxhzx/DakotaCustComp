     Hcopyright('(c) Copyright BFC Software, Inc - 2004')
     Hoptimize(*NONE)
     Hdecedit(*JOBRUN)
     Htruncnbr(*NO)
     Hoption(*srcstmt : *nodebugio)

      *----------------------------------------------------------------
      *
      *  UPD520PKUP  Q&D to set OPPKUP
      *  06 November 2009
      *  Ginger Andrews
      *
      *  Setup default values for OPPKUP
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Files
      *----------------------------------------------------------------

     Foptionz   up   e           k disk
     Fzoneh     if   e           k disk

     D*----------------------------------------------------------------
     D*  OPTIONZ data structure
     D*
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
     D opzdta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
     D  oppkup                62     62
     D  opspal                63     63
     D  oppitm                64     67  0 inz(0)
     D  opdend               117    117

      *----------------------------------------------------------------
      *  Main Line
      *----------------------------------------------------------------

     C                   if        opzcod = '*PICK   '
     C                   if        oppkup = ' '
     C     keyzone       klist
     C                   kfld                    opzwhs
     C                   kfld                    opztrk
     C                   kfld                    opzzon
     C     keyzone       chain     zoneh
     C                   if        %found(zoneh)
     C                   if        zhcomp = ' ' and zhpzon <> *blanks
     C                   eval      oppkup = 'S'
     C                   update(e) opzrec
     C                   endif
     C                   endif
     C                   if        %error
     C                   endif
     C                   endif
     C                   endif
