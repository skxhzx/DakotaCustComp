510dA*----------------------------------------------------------------
510dA*  ellenbeeseq  -  Special sequencing for Ellenbee-Leggett
510dA*----------------------------------------------------------------
510dA
510dAC     ellenbeeseq   begsr
     C                   eval      iflag = *off

     *    Retrieve corresponding SLOT2 record for aisle 2F.

     C                   if        lbaisl = ' 2F'
     C     keysl2        chain     slot2
     C                   if        not %found
     C                   eval      slside = 0
     C                   endif
     C                   endif

     *    Retrieve corresponding WORKLBL record for Merge records.
     *    Note, for Merge records we need to get the corresponding label
     *    record from WORKLBL because we do not populate the aisle field
     *    for merge records.

     C                   eval      lwaisl = *blanks
     C                   if        lbtype = 'M'
     C     lbctr#        chain     worklbl
     C                   if        not %found
     C                   eval      lwaisl = *blanks
     C                   endif
     C                   endif

     *    Working with all departments.

     *    Only update type 'O' and 'M' labels.

     C                   if        lbtype <> 'O'
     C                             and lbtype <> 'M'
     C                   eval      iflag = *on
     C                   goto      endellenbee
     C                   endif

     *    Set up custom sequence for use with LABEL32C.

     C                   select

     *      Aisles 3G - 3M with unit weight >= 35 lbs (DRY PIR)

     C                   when      lwaisl >= ' 3G'
     C                             and lwaisl <= ' 3M'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 5

     *      Aisles 3A - 3D (DRY Main Floor)

     C                   when      lbaisl >= ' 3A'
     C                             and lbaisl <= ' 3D'
     C                   eval      lblvl2 = 10

     *      Aisle 2X (DRY Main Floor)

     C                   when      lbaisl = ' 2X'
     C                   eval      lblvl2 = 15

     *      Aisles 2A - 2D with unit weight >= 35 lbs (COOL PIR)

     C                   when      lwaisl >= ' 2A'
     C                             and lwaisl <= ' 2D'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 20

     *      Aisles 2F Even (COOL Main Floor)

     C                   when      lbaisl >= ' 2F'
     C                             and slside = 0
     C                   eval      lblvl2 = 25

     *      Aisles 2G - 2K (COOL Main Floor)

     C                   when      lbaisl >= ' 2G'
     C                             and lbaisl <= ' 2K'
     C                   eval      lblvl2 = 25

     *      Aisles 2A - 2D with unit weight < 35 lbs (COOL PIR)

     C                   when      lwaisl >= ' 2A'
     C                             and lwaisl <= ' 2D'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
     C                   eval      lblvl2 = 30

     *      Aisles 3E - 3F (DRY Main Floor)

     C                   when      lbaisl >= ' 3E'
     C                             and lbaisl <= ' 3F'
     C                   eval      lblvl2 = 35

     *      Aisles 3G - 3M with unit weight < 35 lbs (DRY PIR)

     C                   when      lwaisl >= ' 3G'
     C                             and lwaisl <= ' 3M'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
     C                   eval      lblvl2 = 40

     *      Aisle 2F Odd (Box Beef)

     C                   when      lbaisl = ' 2F'
     C                             and slside = 1
     C                   eval      lblvl2 = 45

     *      Aisles 1A - 1D with unit weight >= 35 lbs (FRZ PIR)

     C                   when      lwaisl >= ' 1A'
     C                             and lwaisl <= ' 1D'
510iDC**                           and lwuwgt >= 35
510iMC                             and lwuwgt >= ophvy
     C                   eval      lblvl2 = 50

     *      Aisles 1M - 1T (FRZ Main Floor)

     C                   when      lbaisl >= ' 1M'
     C                             and lbaisl <= ' 1T'
     C                   eval      lblvl2 = 55

     *      Aisles 1A - 1D with unit weight < 35 lbs (FRZ PIR)

     C                   when      lwaisl >= ' 1A'
     C                             and lwaisl <= ' 1D'
510iDC**                           and lwuwgt < 35
510iMC                             and lwuwgt < ophvy
     C                   eval      lblvl2 = 60

     *      Aisles 2Z (FRZ Main Floor)

     C                   when      lbaisl = ' 2Z'
     C                   eval      lblvl2 = 65

     *      Then everything else.

     *        Note, by setting everything else to 80, the normal Aisle,
     *        Picking Seq. order takes affect. Also, by using 80, the
     *        possibility is left open to assign an aisle to be picked last

     C                   other
     C                   eval      lblvl2 = 80

     C                   endsl

     C     endellenbee   endsr
