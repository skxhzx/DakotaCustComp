500gA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
      *
      *  QDA104    Default Prevent *SP Flag to 'N' for all Truck Zones.
     *  18 January 2007
      *  Jeffrey Jahnke
      *
      *----------------------------------------------------------------
      *  Revisions
      *
      *
      *----------------------------------------------------------------
      *  Indicator usage
      *
      *  21 - 30   Field input error (Reverse Display)
      *  90        View mode (Protect input fields)
      *  91        Change mode (Protect key)
      *  97        Always ON (Used for SFLEND Keyword)
      *  98        Error on screen (Sound buzzer)
      *  99        Universal record indicator (Very temporary usage)
      *
      *----------------------------------------------------------------
      *  File Specs
      *
     Fzoneh     if   e           k disk
     Foptionz   uf   e           k disk
      *----------------------------------------------------------------
      *  Table and array definitions
      *
     D A10             S              1    DIM(10)
     D $MD             S              1    DIM(128)

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
     *    OPPBRK  -  Aisle to start new pallet.
400 A*    OPPBLD  -  Pallet building method.
400 A*                1 = By stop then slot location.
400 A*                2 = By slot location then stop.
417bA*                3 = Descending by stop then location.
400 A*    OPSELM  -  Selection method.
400 A*                1 = Single pass (By location).
400 A*                2 = Multiple pass (By stop).
400 A*    OPSPLT  -  Allow stop to be split across pallets (Y/N).
400 A*    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
417dA*    OPNWPL  -  Start new pallet when aisle changes if build method
417dA*               is 2=Location.
500iM*    OPFORD  -  Maximum orders per pallet.
500eM*    OPPTYP  -  Pallet type (P=Pallet, T-Tote).
500cA*    OPFTOT  -  Maximum totes per pallet
500dA*    OPTECB  -  External tote cube.
500dA*    OPTICB  -  Internal tote cube.
500dA*    OPTSTP  -  Maximum stops per tote.
500dA*    OPTORD  -  Maximum orders per tote.
500eA*    OPFPCS  -  Maximum pieces per fixed pallet.
510lA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
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
400 AD  oppbld                34     34
400 AD  opselm                35     35
400 AD  opsplt                36     36
400 AD  opbmrg                37     37
417dAD  opnwpl                38     38
500dAD  opford                39     40  0
500cMD  opptyp                41     41
500dAD  opftot                42     43  0
500dAD  optecb                44     48  2
500dAD  opticb                49     53  2
500dAD  optstp                54     55  0
500dAD  optord                56     57  0
500dAD  optpcs                58     60  0
510lAD  opstop                61     61
     D  opdend               117    117
      *----------------------------------------------------------------
      *  Program info data structure
      *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     * Variables
     *
     D kycod1          s              8
      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      None
      *
      *    Returned Parameters
      *      None
      *
      *----------------------------------------------------------------
      *  Let the show begin .....
      *
      *----------------------------------------------------------------

      *  Define key for pick options.

     C                   eval      kycod1 = '*PICK   '

     C     pickky        klist
     C                   kfld                    kycod1
     C                   kfld                    zhwhse
     C                   kfld                    zhtruk
     C                   kfld                    zhzone
      *  Main line
      *
     C                   dou       %eof(zoneh)
     C                   read      zoneh
     C                   if        not %eof(zoneh)
     C     pickky        chain     optionz
     C                   if        %found(optionz)

     C                   if        opstop = *Blanks
     C                   eval      opstop = 'N'
     c                   update    opzrec
     C                   endif

     C                   endif
     c                   endif

     C                   enddo

      *   Do some clean up before leaving.

     C                   eval      *inlr = *on

      *----------------------------------------------------------------*********
      *
      *  COMPILE TIME TABLES
      *
