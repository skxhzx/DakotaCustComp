510 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  CLNLICLOG  Clean up LICLOG records
     *  31 December 2010
     *  Ginger Andrews
     *
     *----------------------------------------------------------------
     *  Revisions
     *
510 A*    12/31/10  GJA
     *      - Created
     *
640aA*    06/11/11  DAS  6.40a
     *      - Recompiled because of change to LICLOG file.

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fliclog    uf   e           k disk
     Flicense   if   e           k disk
     Flicactive if   e           k disk
     Foptions   if   e           k disk
     Fliclogh   o  a e           k disk

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
     *
     * Data structure
     *
     D opdata          ds
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
     D  optend               117    117
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D curdate         s               d
     D $dtetme         s               z
     D dtetme          s             26
     D kywhse          s              3  0
     D chkwks          s              3  0
     D chkdays         s              4  0
     *  Main line
     *----------------------------------------------------------------

     C     likey         klist
     C                   kfld                    llwhse
     C                   kfld                    lllcns
     C                   read      liclog
     C                   if        not %EOF(liclog)
     C                   if        lladdts < $dtetme
     *  look to see if license exist in LICENSE file
     C     likey         chain     license
     C                   if        not %found(license)
     C     likey         chain     licactive
     C                   if        not %found(licactive)
     C                   write     llhrec
     C                   delete    llrec
     C                   endif
     C                   endif
     C                   endif
     C                   endif

     *  End of file
     C                   if        %EOF(liclog)
     C                   eval      *inlr = *On
     C                   return
     C                   end
     *--------------------------------------------------------------
     *  *INZSR
     C     *inzsr        begsr
     *
     *  Define key for options file, system values.
414aAC     opkey         klist
414aAC                   kfld                    kywhse
414aAC                   kfld                    opcode
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM'
     C     opkey         chain     options
414aAC                   if        not %found(options)
414aAC                   eval      chkwks = 26
414aAC                   else
414aAC                   eval      chkwks = oprths
414aAC                   if        chkwks < opcrhs
414aAC                   eval      chkwks = opcrhs
414aAC                   endif
414aAC                   if        chkwks < oppohs
414aAC                   eval      chkwks = oppohs
414aAC                   endif
414aAC                   if        chkwks < opiahs
414aAC                   eval      chkwks = opiahs
414aAC                   endif
414aAC                   if        chkwks < opmshs
414aAC                   eval      chkwks = opmshs
414aAC                   endif
414aAC                   endif
414aAC                   eval      curdate = %date()
     C                   eval      chkdays = chkwks * 7
     C                   eval      curdate = curdate - %days(chkdays)
     C                   eval      $dtetme= %timestamp(%char(curdate) +
     C                                     '-00.00.00.000000')
     C                   endsr
