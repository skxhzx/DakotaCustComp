      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPD510LMA  Initialize Extendend history OPTIONS
     *  12 October 2007
     *  Lynn McMahon
     *
     *  Copied from UPD510MBa
     *
     *----------------------------------------------------------------
     *  Revisions
510 A*    10/12/07  LMC  5.10
     *      - Created. Program will initialize to zero the *SYSTEM
     *        records. This was done for a request to save LABEL,PIRTRAN
     *        LICENSE,LICINFO to history files during the cleanup process.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Foptions   up   e           k disk

     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *
     * *SYSTEM Fields
     *
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import Item fields (Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     I*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     I*    OPRCDY  -  Number of days to keep receiving logs.
     I*    OPMPCK  -  Number of days to keep picking logs.
     I*    OPRTHS  -  Number of weeks - exported routes to keep.
     I*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     I*    OPPOHS  -  Number of weeks - exported p/o's to keep.
     I*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     I*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     I*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
     I*    OPISHS  -  Number of weeks to keep history file
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opmpck                14     14
     D  oprcdy                15     15  0
     D  oppkdy                16     16  0
     D  oprths                17     19  0
     D  opcrhs                20     22  0
     D  oppohs                23     25  0
     D  opiahs                26     28  0
     D  opmshs                29     31  0
     D  optbjq                32     32
     D  opishs                33     35  0
     D  opishsinz             33     35
     D  optend               117    117

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


     *   Initialize new options

     C                   if        opcode = '*SYSTEM'
     c                   If        opishsinz = ' '
     C                   eval      opishs = 0
     C                   update    oprec
     C                   endif
     C                   endif

     C     bottom        tag
