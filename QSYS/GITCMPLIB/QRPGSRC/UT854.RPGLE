     F*----------------------------------------------------------------
     F*   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  UT854     Delete invalid UPC codes.
     F*  09 April, 2001
     F*  Hemant Kapadia
     F*
     F*  Revisions
     F*    04/09/01  HNK  4.15
     F*      - Created
     F*
     F*    11/28/01  DAS  4.16
     F*      - Converted to ILE
     F*      - Automatically delete any codes less than 12 characters long.
700aAF*    11/02/16  LMC  7.00a
     F*      - Recompile only - UPC file changed.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FUPC1      UF   E           K DISK
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
     C*  Let the show begin .....
     C*
     C*  Main line
     C*
     C* Send UPC to CVTBAR prog for validation.
     C*
     C     UPCKY         SETLL     UPC1
     C     FOREVR        DOWEQ     FOREVR
     C     UPCKY         READE     UPC1                                   79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ENDIF
     C*
     C                   if        %Len(%Trim(UPUPC)) < 12
     C                   delete    uprec
     C                   iter
     C                   endif

     C                   MOVE      '*UPC    '    $CBCMD
     C                   MOVEL(P)  UPUPC         $CBBAR
     C*
     C                   CALL      'CVTBAR'
     C                   PARM                    $CBCMD            8
     C                   PARM                    $CBBAR          100
     C                   PARM                    $CBCOD            3 0
     C                   PARM                    $CBDEC            1 0
     C                   PARM                    $CBDSC           30
     C                   PARM                    $CBPOS            3 0
     C                   PARM                    $CBTYP            1 0
     C                   PARM                    $CBV1            11 3
     C                   PARM                    $CBV2            50
     C                   PARM                    $CBRTN            8
     C                   PARM                    $CBERM           60
     C*
     C                   SELECT
     C     $CBRTN        WHENNE    '*OK'
     C                   DELETE    UPREC
     C                   ENDSL

     C                   ENDDO

     C                   MOVE      *ON           *INLR
     C                   RETURN
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
     C*
     C*  Initialize variables
     C*
     CSR                 MOVE      *ON           FOREVR            1
     CSR                 Z-ADD     900           $PWHSE            3 0
     C*
     C*   Define keys
     C*
     CSR   UPCKY         KLIST
     CSR                 KFLD                    $PWHSE
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
