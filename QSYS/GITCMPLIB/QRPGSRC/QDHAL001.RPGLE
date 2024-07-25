     F*----------------------------------------------------------------
     F*   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  QDHAL001    Create ItemFld Records from Q&D file QDHALITM.
     F*  12 August 2011
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FQDHALITM  IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FITEMFLD   UF A E           K DISK
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
     C*----------------------------------------------------------------
     C* Main line
     C*
     C                   EXSR      ZZINZ2
     C*
     C*  Select which to process, Single item or *ALL items.
     C*
     C     *loval        setll     qdhalitm
     C                   dow       forevr = forevr
     C                   read      qdhalitm
     C                   if        %eof(qdhalitm)
     C                   leave
     C                   endif
     C*
     C     itkey         chain     piritem
     C                   if        %found(piritem)
     C     itkey         chain     itemfld
     C                   if        not %found(itemfld)
     C                   eval      ifwhse = itwhse
     C                   eval      ifitem = ititem
     C                   eval      ifcat = %trim(halcat)
     C                   eval      ifcaseovf = 'N'
     C                   write     ifrec
     C                   else
     C                   eval      ifcat = %trim(halcat)
     C                   update    ifrec
     C                   endif
     C
     C                   endif
     C*
     C                   enddo
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
     C* Key definitions
     C*
     C* FS-WMS file keys
     C     ITKEY         KLIST
     C                   KFLD                    halwhs
     C                   KFLD                    halitm
     C*
     C*  Variables and constants.
     C*
     CSR                 MOVE      *OFF          FOREVR            1
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
     C*
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
     C*
     O*----------------------------------------------------------------*********
     O*
     O*  COMPILE TIME TABLES
     O*
