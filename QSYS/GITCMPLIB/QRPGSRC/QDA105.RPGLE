500gA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave Suite 203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *  QDA105    Populate new Catch Weight options
     *  13 May 2010
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
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
     Foptions   uf   e           k disk
     F                                     rename(oprec:record)
      *----------------------------------------------------------------
      *  Table and array definitions
      *
     D A10             S              1    DIM(10)
     D $MD             S              1    DIM(128)

     *----------------------------------------------------------------
405 A*  *SYSTEM  -  System options.
405 A*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
610aD*****OPWRNC  -  Perform catch weight variance check (Y,N).
610aM*    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
410 A*    OPRG1C  -  Catch weight low variance percentage.
410 A*    OPRG2C  -  Catch weight high variance percentage.
411 A*    OPIMPI  -  Import Item fields (Y,N).
610aD*****OPICW   -  Individual catch weight entry (Y,N).
610aM*    OPICW   -  Check CW count during selection closing (N,M,C,B)
412 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
413aA*    OPRCDY  -  Number of days to keep receiving logs.
413aA*    OPMPCK  -  Number of days to keep picking logs.
414aA*    OPRTHS  -  Number of weeks - exported routes to keep.
414aA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
414aA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
414aA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
414aA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
510aA*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
520aA*    OPISHS  -  Number of weeks to keep history file
520aA*    OPTRAX  -  Using TRAX module (Y/N)
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
414aAD  oprths                17     19  0
414aAD  opcrhs                20     22  0
414aAD  oppohs                23     25  0
414aAD  opiahs                26     28  0
414aAD  opmshs                29     31  0
510aAD  optbjq                32     32
520aAD  opishs                33     35  0
520aAD  opishsa               33     35
610bAD  opuci                 36     36
610aAD  opwrncr               37     37
610aAD  opicwr                38     38
610aAD  optrax                39     39
     D  optend               117    117
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
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz
     C                   exsr      zzget1
     C                   exsr      zzupd1

      *   Do some clean up before leaving.

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opwhse = 0
     C                   eval      opcode = '*SYSTEM '
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             7978
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     *
     *  Move screen fields to record fields
     *
610aAC                   eval      opicwr = 'N'
610aAC                   eval      opwrncr = 'N'
610aAC                   eval      optrax = 'N'
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     C                   endsr
