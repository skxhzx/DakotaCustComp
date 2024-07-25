     F*----------------------------------------------------------------
     F*   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   249 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDGBFCTIHI    Create Item Def Records from ITEMMSC file.
     F*  15 October 2009
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*  79        - General purpose EOF indicator.
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FPIRITEM   IF   E           K DISK
     FITEMDEF1  IF   E           K DISK
     F                                     RENAME(IJREC:IJREC1)
     F                                     PREFIX(L)
     FSLOT3     IF   E           K DISK
     FITEMMSC   IF   E           K DISK
     FITEMDEF   UF A E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*                   DESC    1  44 30
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D*----------------------------------------------------------------
     D*  Redefined field varialbles
     D*
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D*----------------------------------------------------------------
     D*  Called program parameters
     D*
     D $LPARM          DS
     D  $LCMD                  1      8
     D  $LPRG                  9     18
     D  $LUKY                 19     68
     D  $LRTN                 69     76
     D  $LERM                 77    136
     D  $LMSG                 77     80
     D*
     D*   Redefine key
     D*
     D  $LWHSE                19     21  0
     D*----------------------------------------------------------------
     D*  Program info data structure
     D*
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHS   Warehouse to process.
     C*      $POPT   Processing option.
     C*        *PIR - Create PIR item tie/highs
     C*        *FIX - Create Fixed item tie/highs
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $POPT             4
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   EXSR      ZZINZ2
     C*
     C*  Select which to process, Single item or *ALL items.
     C*
     C                   SELECT
     C     $POPT         WHENEQ    '*PIR'
     C                   EXSR      ZZPIR
     C     $POPT         WHENEQ    '*FIX'
     C                   EXSR      ZZFIX
     C                   ENDSL
     C*
     C*  We are finished so get out
     C*
     C                   MOVE      *ON           *INLR
     C*----------------------------------------------------------------
     C*
     C*          Subroutines in Alphabetical Order
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     CSR   *INZSR        BEGSR
     CSR                 MOVE      $PWHS         $PWHSE            3 0
     C* Key definitions
     C*
     C* FS-WMS file keys
     CSR   *LIKE         DEFINE    IDWHSE        KYWHSE
     CSR   IDKEY         KLIST
     CSR                 KFLD                    KYWHSE
     CSR                 KFLD                    ITITEM
     C     IDKEY2        KLIST
     C                   KFLD                    ITWHSE
     C                   KFLD                    ITITEM
     C                   KFLD                    slsdef
     C     IMKEY         KLIST
     C                   KFLD                    ITWHSE
     C                   KFLD                    ITITEM
     C*
     CSR   *LIKE         DEFINE    SLSTAT        KYSTAT
     CSR   *LIKE         DEFINE    SLPICK        KYPICK
     CSR                 MOVE      'A '          KYSTAT
     CSR                 MOVE      'Y'           KYPICK
     CSR   SLKEY         KLIST
     CSR                 KFLD                    ITWHSE
     CSR                 KFLD                    ITITEM
     CSR                 KFLD                    KYSTAT
     CSR                 KFLD                    KYPICK
     C*
     C*  Variables and constants.
     C*
     CSR                 MOVE      *OFF          FOREVR            1
     CSR                 MOVE      *ZEROS        POS               3 0
     CSR                 MOVE      *ZEROS        LEN               3 0
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
     C*
     CSR                 MOVE      #PROG         $LPRG
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIX    Process Fixed item slot definitions.
     C*
     CSR   ZZFIX         BEGSR
     CSR   $PWHSE        SETLL     PIRITEM
     C*
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   $PWHSE        READE     PIRITEM                                79
     CSR                 SELECT
     CSR   *IN79         WHENEQ    *ON
     CSR                 LEAVE
     C*
     CSR   ITSTYP        WHENEQ    'F'
     C*
     CSR   SLKEY         SETLL     SLOT3
     CSR   SLKEY         READE     SLOT3                                  78
     CSR                 SELECT
     CSR   *IN78         WHENEQ    *ON
     CSR                 ITER
     C*
     CSR                 OTHER
     C*
     C     imkey         chain     itemmsc
     C                   select
     C                   when      not %found(itemmsc)
     C*
     C                   when      imtie > 0
     C                             or imhigh > 0
     C*
     CSR                 EXSR      ZZUPD2
     C*
     CSR                 ENDSL
     C*
     CSR                 ENDSL
     C*
     CSR                 ENDSL
     CSR                 ENDDO
     C*
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZPIR    Process PIR Item definitions.
     C*
     CSR   ZZPIR         BEGSR
     CSR   $PWHSE        SETLL     PIRITEM
     C*
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   $PWHSE        READE     PIRITEM                                79
     CSR                 SELECT
     CSR   *IN79         WHENEQ    *ON
     CSR                 LEAVE
     C*
     CSR   ITSTYP        WHENEQ    'P'
     C*
     CSR   IDKEY         SETLL     ITEMDEF1
     C*
     CSR   FOREVR        DOWEQ     FOREVR
     CSR   IDKEY         READE     ITEMDEF1                               78
     CSR                 SELECT
     CSR   *IN78         WHENEQ    *ON
     CSR                 LEAVE
     C*
     CSR                 OTHER
     C*
     CSR                 EXSR      ZZUPD
     C*
     CSR                 ENDSL
     CSR                 ENDDO
     C*
     CSR                 ENDSL
     CSR                 ENDDO
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL    Load import fields with values from files.
     C*
     CSR   ZZFIL         BEGSR
     C*
     CSR                 MOVE      LIDSDEF       IDSDEF
     CSR                 Z-ADD     LIDTIE        IDTIE
     CSR                 Z-ADD     LIDHIGH       IDHIGH
     CSR                 MOVE      LIDUM         IDUM
     CSR                 MOVE      LIDPREF       IDPREF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZFIL2   Load import fields with values from files.
     C*
     CSR   ZZFIL2        BEGSR
     C*
     CSR                 MOVE      SLSDEF        IDSDEF
     CSR                 Z-ADD     imtie         IDTIE
     CSR                 Z-ADD     imhigh        IDHIGH
     CSR                 MOVE      'N'           IDUM
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ2   Program initialization. Called from main line.
     C*
     CSR   ZZINZ2        BEGSR
     C*
     C*    Get import date/time.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        IMPDTE            8 0
     CSR                 TIME                    IMPTIM            6 0
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD    Write/Update a record to Item definition file.
     C*
     CSR   ZZUPD         BEGSR
     CSR                 CLEAR                   IDREC
     CSR                 Z-ADD     ITWHSE        IDWHSE
     CSR                 MOVE      ITITEM        IDITEM
     CSR                 EXSR      ZZFIL
     CSR                 WRITE     IDREC
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZUPD2   Write/Update a record to Item definition file.
     C*
     CSR   ZZUPD2        BEGSR
     C     idkey2        chain     itemdef
     C                   if        not %found(itemdef)
     CSR                 CLEAR                   IDREC
     CSR                 Z-ADD     ITWHSE        IDWHSE
     CSR                 MOVE      ITITEM        IDITEM
     CSR                 EXSR      ZZFIL2
     CSR                 WRITE     IDREC
     C                   else
     C                   Z-ADD     imtie         IDTIE
     C                   Z-ADD     imhigh        IDHIGH
     C                   update    idrec
     C                   endif
     C*
     CSR                 ENDSR
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
