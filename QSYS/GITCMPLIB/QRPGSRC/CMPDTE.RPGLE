     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  CMPDTE    Compute Cutoff date based on nbr of weeks
     *  27 April 2000
     *  Max Blacknik
     *
     *  Revisions
417aA*    07/15/04  RH   4.17a
     *      - Add CMD *DLYHIT to calculate date for Daily Slot Hits
520aA*    09/10/08  DAS  5.20a
     *      - Converted to ILE
     *      - Added parmeter $p
     *      - Added *POD
530 A*    07/07/10  RBD  5.30
     *      - Added *TRAX
640aA*    03/16/11  RBD  6.40a
     *      - Change *TRAX to be by whse.
640bA*    01/10/12  LMC  6.40B
     *      - Added *ROUTEH COMMAND
     *      - Added *POH    COMMAND
     *      - Added *INVADJH COMMAND
     *      - Added *CSTRTNH COMMAND
     *      - Added *MISCH  COMMAND
     *      - increased field size for WKWEEK to handle the combination
     *        of regular weeks of history plus extended history weeks
700aA*    06/24/15  NLK  7.00a
     *      - Added *TOMCAT
720aA*    02/02/18  DAS  7.20a
     *      - Revised number for TOMCAT from 14 to 2 because the value
     *        is put into wkweek, so it was keeping 14 weeks not days.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - NRF for OPTIONS
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Foptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
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
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import Item fields (Y,N).
     *    OPICW   -  Individual catch weight entry (Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
     *    OPRCDY  -  Number of days to keep receiving logs.
     *    OPMPCK  -  Number of days to keep picking logs.
     *    OPRTHS  -  Number of weeks - exported routes to keep.
     *    OPCRHS  -  Number of weeks - exported customer rtns to keep.
     *    OPPOHS  -  Number of weeks - exported p/o's to keep.
     *    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
     *    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
640bA*    OPTBJQ  -  Run Truck builder on Job Que (Y/N)
640bA*    OPISHS  -  Number of weeks - extra history files to keep.
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
640bAD  optbjq                32     32
640bAD  opishs                33     35  0
     D  optend               117    117
     *----------------------------------------------------------------
417kA*  *DLYHIT  -  Daily Slot Hit Process options.
417kA*----------------------------------------------------------------
417kA*
417kA* Fields
417kA*
417kA*    OPHSTR  -  Daily Slot Hit start time
417kA*    OPHWKS  -  # of weeks to keep history.
417kA*
417kA* Data structure
417kA*
417kAD opdat2          ds
417kAD  ophstr                 1      6  0
417kAD  ophwks                 7      8  0
417k D  opten2               117    117
520aA*----------------------------------------------------------------
520aA*  *PODSYS  -  POD System options
520aA*----------------------------------------------------------------
520aA*
520aA* Fields
520aA*
520aA*    OPPHST  -  Days to keep POD export data (1-999)
520aA*
520aA* Data structure
520aA*
520aAD opdat3          ds
520aAD  opphst                 1      3  0
520aAD  opten3               117    117
700aA*----------------------------------------------------------------
700aA*  *TOMCAT  -  Tomcat System options (not yet in the Options file
700aA*----------------------------------------------------------------
700aA*
700aA* Fields
700aA*
700aA*    OPMHST  -  Days to keep TOMCAT export data (1-999)
700aA*  at this time no rcd in options; **Hard Code - 14 days**
700aA* Data structure
700aA*
700aAD opdat5          ds
700aAD  opmhst                 1      3  0
700aAD  opten5               117    117
530 A*----------------------------------------------------------------
530 A*  *TRAX    -  TRAX options
530 A*----------------------------------------------------------------
530 A*
530 A* Fields
530 A*
530 A*    OPTHST  -  Days to keep TRAX export data (1-999)
530 A*
530 A* Data structure
530 A*
530 AD opdat4          ds
530 AD  opthst                 1      3  0
530 AD  opten4               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @clcdr          c                   const('CLCDUR')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
     D                 ds
     D  $ec                    1      2p 0
     D digits          c                   const('0123456789')
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $kdate          s              8  0
     D ckfld           s              3
     D cutoff          s              8  0
     D kycode          s                   like(opcode)
     D kywhse          s                   like(opwhse)
     D today           s              8  0
640bDD*wkweek          s                   like(opiahs)
640bMD wkweek          s              4  0
     D wkdays          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ROUTE   - Remove exported routes.
     *              *CSTRTN  - Remove exported customer returns.
640bA*              *CSTRTNH - Remove history  customer returns.
     *              *PO      - Remove exported purchase orders.
640bA*              *POH     - Remove exported purchase orders history
     *              *INVADJ  - Remove exported inventory adjustments.
640bA*              *INVADJH - Remove history inventory adjustments.
     *              *MISC    - Remove exported misc. labels/transactions.
640bA*              *MISCH   - Remove history misc. labels/transactions.
520aA*              *POD     - Remove POD history
700aA*              *TOMCAT  - Remove TOMCAT history
530 A*              *TRAX    - Remove TRAX history
640bA*              *ROUTEH  - Remove exported routes history.
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Number of weeks to keep.
     *
     *    Returned Parameters
     *      $PDATE  - New cutoff date.
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     *----------------------------------------------------------------
     * Main line
     *
     C                   eval      *inlr = *on
     *
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      $kdate = *zeros
     C                   eval      cutoff = *zeros
     C                   eval      ckfld = *blanks
     *
     *    Define full key for file OPTIONS.
     *
     C                   eval      kywhse = *zeros
     C                   eval      kycode = '*SYSTEM '
     C     keyop         klist
     C                   kfld                    kywhse
     C                   kfld                    kycode
     *
     *    Compute cutoff date to be used.
     *
     C                   select
     C                   when      $pcmd = '*ROUTE  '  or
640bAC                             $pcmd = '*ROUTEH '  or
     C                             $pcmd = '*CSTRTN '  or
640bAC                             $pcmd = '*CSTRTNH'  or
     C                             $pcmd = '*PO     '  or
640bAC                             $pcmd = '*POH    '  or
     C                             $pcmd = '*INVADJ '  or
640bAC                             $pcmd = '*INVADJH'  or
     C                             $pcmd = '*MISC   '  or
640bAC                             $pcmd = '*MISCH  '  or
520aAC                             $pcmd = '*POD    '  or
700aAC                             $pcmd = '*TOMCAT '  or
530 AC                             $pcmd = '*TRAX   '  or
417a C                             $pcmd = '*DLYHIT '
     C                   exsr      zzcldt
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCHCK   Make sure week# is not less than system default.
     *
     C     zzchck        begsr
     C                   select
     C                   when      $pcmd = '*ROUTE  '  and
     C                             wkweek < oprths
     C                   eval      wkweek = oprths
     *
640bAC                   when      $pcmd = '*ROUTEH '  and
640bAC                             wkweek < (oprths + opishs)
640bAC                   eval      wkweek = (oprths + opishs)
640bA*
     C                   when      $pcmd = '*CSTRTN '  and
     C                             wkweek < opcrhs
     C                   eval      wkweek = opcrhs
640bA*
640bAC                   when      $pcmd = '*CSTRTNH'  and
640bAC                             wkweek < (opcrhs + opishs)
640bAC                   eval      wkweek = (opcrhs + opishs)
     *
     C                   when      $pcmd = '*PO     '  and
     C                             wkweek < oppohs
     C                   eval      wkweek = oppohs
     *
640bAC                   when      $pcmd = '*POH    '  and
640bAC                             wkweek < (oppohs + opishs)
640bAC                   eval      wkweek = (oppohs + opishs)
640bA*
     C                   when      $pcmd = '*INVADJ '  and
     C                             wkweek < opiahs
     C                   eval      wkweek = opiahs
640bA*
640bAC                   when      $pcmd = '*INVADJH'  and
640bAC                             wkweek < (opiahs + opishs)
640bAC                   eval      wkweek = (opiahs + opishs)
     *
     C                   when      $pcmd = '*MISC   '  and
     C                             wkweek < opmshs
     C                   eval      wkweek = opmshs
640bA*
640bAC                   when      $pcmd = '*MISCH  '  and
640bAC                             wkweek < (opmshs + opishs)
640bAC                   eval      wkweek = (opmshs + opishs)
     *
417a C                   when      $pcmd = '*DLYHIT '  and
417a C                             wkweek < ophwks
417a C                   eval      wkweek = ophwks
     *
520aAC                   when      $pcmd = '*POD    '  and
520aAC                             wkweek < opphst
520aAC                   eval      wkweek = opphst
     *
700aAC                   when      $pcmd = '*TOMCAT '  and
700aAC                             wkweek < opmhst
700aAC                   eval      wkweek = opmhst
     *
530 AC                   when      $pcmd = '*TRAX   '  and
530 AC                             wkweek < opthst
530 AC                   eval      wkweek = opthst
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *     ZZCLDT   Calculate cutoff date to be used.
     *
     C     zzcldt        begsr
     *
     *    Retrieve System options.
     *
     C     keyop         chain     options                            79
     C                   if        *in79
     C                   eval      oprths = 4
     C                   eval      opcrhs = 4
     C                   eval      oppohs = 4
     C                   eval      opiahs = 4
     C                   eval      opmshs = 4
640bAC                   eval      opishs = 0
     C                   endif
520aA*
520aA*    Retrieve *POD options.
520aA*
520aAC                   if        $pcmd = '*POD'
520aAC                   eval      kywhse = 0
520aAC                   eval      kycode = '*PODSYS'
520aAC     keyop         chain     options                            79
520aAC                   if        *in79
520aAC                   eval      opphst = 7
520aAC                   else
520aAC                   eval      opdat3 = opdata
520aAC                   endif
520aAC                   endif
700aA*
700aA*    Retrieve *TOMCAT options.
700aA*                              hard code 14 days for now
700aAC                   if        $pcmd = '*TOMCAT'
700aA *                  eval      kywhse = 0
700aA *                  eval      kycode = '*PODSYS'
700aA *    keyop         chain     options                            79
700aA *                  if        *in79
720aDC**                 eval      opmhst = 14
720aMC                   eval      opmhst = 2
700aA *                  else
700aA *                  eval      opdat3 = opdata
700aA *                  endif
700aAC                   endif
     *
530 A*    Retrieve *TRAX options.
530 A*
530 AC                   if        $pcmd = '*TRAX'
640aDC**                 eval      kywhse = 0
640aMc                   eval      kywhse = %dec($pWhse: 3: 0)
530 AC                   eval      kycode = '*TRAX'
530 AC     keyop         chain     options                            79
530 AC                   if        *in79
530 AC                   eval      opthst = 7
530 AC                   else
530 AC                   eval      opdat4 = opdata
530 AC                   endif
530 AC                   endif
     *
417A *    Retrieve *DLYHIT options.
     *
     C                   if        $pcmd = '*DLYHIT'
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     C                   eval      kycode = '*DLYHIT '
     C                   eval      kywhse = #whse
     C     keyop         chain     options                            79
     C                   if        not *in79
     C                   eval      opdat2 = opdata
     C                   else
     C                   eval      ophwks = 4
     C                   endif
     C                   endif
     *
     *    Check if defaults are being used.
     *
     C                   select
     C                   when      $pdate = '*DFT    '
     *
     C                   exsr      zztype
     *
     C                   other
     *
     *    Specific value being used - validate and proceed.
     *
     C                   movel     $pdate        ckfld
     *
     *    Check for invalid characters in week# value.  If any
     *    invalid characters, set week value to system default.
     *    80=Invalid values in week value.
     *
     C     digits        check     ckfld                                  80
     C                   select
     C                   when      *in80
     C                   exsr      zztype
     C                   other
     C                   movel     ckfld         wkweek
     C                   exsr      zzchck
     C                   endsl
     C                   endsl
     *
     *    Retrieve today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *    Compute cutoff date.
520aA*
520aA*      *POD value is in days.
530 A*      *TRAX value is in days.
700aA*      *TOMCAT value is in days.
520aA*      everything else is in weeks.
     *
     C                   eval      $cvcmd = '*CMDCMD '
     C                   move      today         $cvd8i
     C                   eval      $cvdr1 = '*SUBDAYS'
520aAC                   if        $pCmd = '*POD'
530 AC                             or $pCmd = '*TRAX'
700aAC                             or $pCmd = '*TOMCAT'
520aAC                   eval      $cvvl1 = wkweek
520aAC                   else
     C                   eval      $cvvl1 = wkweek * 7
520aAC                   endif
     C                   call      @clcdr
     C                   parm                    $cvtdt
     C                   move      $cvd8o        $pdate
     *
     C                   endsr
     *----------------------------------------------------------------
     *     ZZTYPE   Initialize week# for rcd type being removed.
     *
     C     zztype        begsr
     C                   select
     C                   when      $pcmd = '*ROUTE  '
     C                   eval      wkweek = oprths
     *
640bAC                   when      $pcmd = '*ROUTEH '
640bAC                   eval      wkweek = (oprths + opishs)
640bA*
     C                   when      $pcmd = '*CSTRTN '
     C                   eval      wkweek = opcrhs
640bA*
640bAC                   when      $pcmd = '*CSTRTNH'
640bAC                   eval      wkweek = (opcrhs + opishs)
     *
     C                   when      $pcmd = '*PO     '
     C                   eval      wkweek = oppohs
     *
640baC                   when      $pcmd = '*POH    '
640bAC                   eval      wkweek = (oppohs + opishs)
640bA*
     C                   when      $pcmd = '*INVADJ '
     C                   eval      wkweek = opiahs
640bA*
640bAC                   when      $pcmd = '*INVADJH'
640bAC                   eval      wkweek = (opiahs + opishs)
     *
     C                   when      $pcmd = '*MISC   '
     C                   eval      wkweek = opmshs
     *
640bAC                   when      $pcmd = '*MISCH  '
640bAC                   eval      wkweek = (opmshs + opishs)
640bA*
417a C                   when      $pcmd = '*DLYHIT '
417a C                   eval      wkweek = ophwks
     *
520aAC                   when      $pcmd = '*POD    '
520aAC                   eval      wkweek = opphst
     *
530 AC                   when      $pcmd = '*TRAX   '
530 AC                   eval      wkweek = opthst
     *
700aAC                   when      $pcmd = '*TOMCAT '
700aAC                   eval      wkweek = opmhst
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
