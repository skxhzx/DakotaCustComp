      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  MS759      Clean up PIRTRAND Status B records
     *  11 July 2019
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730aA*    07/11/19  LMC  7.30a
     *      - Created
730bA*    07/15/19  LMC  7.30b
     *      - Fixed so the file will process by key
     *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

730bDF*pirtrand1 uf   e             disk
730bMFpirtrand1 uf   e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
     *    OPTBJQ  -  Run Truck Builder on Job Que (Y,N).
     *    OPISHS  -  Number of weeks to keep history file
     *    OPUCI   -  Use UCI processing (Y,N)
     *    OPWRNCR -  Check CW variance during receiving closing (N,M,C,B)
     *    OPICWR  -  Check CW count during receiving closing (N,M,C,B)
     *    OPTRAX  -  Using TRAX module (Y,N).
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
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optrax                39     39
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
     D chkymd          s              8  0
     D forevr          s              1
     *  Main line
     *----------------------------------------------------------------

     c     forevr        doweq     forevr
     C                   read      pirtrand1
     c                   if        %eof(pirtrand1)
     c                   leave
     c                   endif

      * Status X records have previously been deleted from PIRTRAN
     C                   if        ptdstat <> 'B'
     c                   iter
     C                   endif
      * once the date is greater than chkymd - leave - don't waste time
      * checking records that don't qualify for removal.
     C                   if        ptdgdte > chkymd
     c                   leave
     C                   endif
     C                   if        ptdgdte < chkymd
     c                   delete    ptdrec
     C                   endif
     c                   enddo

     *  End of file
     C                   eval      *inlr = *On
     C                   return
     *--------------------------------------------------------------
     *  *INZSR
     C     *inzsr        begsr
     *
     *  Define key for options file, system values.
     C     opkey         klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     C                   eval      forevr = *on
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM'
     C     opkey         chain     options
     C                   if        not %found(options)
     C                   eval      chkwks = 26
     C                   else
     C                   eval      chkwks = oprths
     C                   if        chkwks < opcrhs
     C                   eval      chkwks = opcrhs
     C                   endif
     C                   if        chkwks < oppohs
     C                   eval      chkwks = oppohs
     C                   endif
     C                   if        chkwks < opiahs
     C                   eval      chkwks = opiahs
     C                   endif
     C                   if        chkwks < opmshs
     C                   eval      chkwks = opmshs
     C                   endif
     C                   endif
     C                   eval      curdate = %date()
     C                   eval      chkdays = chkwks * 7
     C                   eval      curdate = curdate - %days(chkdays)
     c                   move      curdate       chkymd
     C                   eval      $dtetme= %timestamp(%char(curdate) +
     C                                     '-00.00.00.000000')
     C                   endsr
