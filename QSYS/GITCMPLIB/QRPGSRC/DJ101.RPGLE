     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  DJ101     DSPJRN extraction program.
     F*  30 April 2001
     F*  Dave Sommerville
     F*
     F*  Revisions
     F*
415 AF*    04/30/01  DAS  4.15
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        CHAIN INDICATOR
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FJRNOUTF1  IP   E           K DISK
     FRTETRCK   O  A E           K DISK
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
     D @CLCDR          C                   CONST('CLCDUR')
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
     D  $CVDR1               133    140
     D  $CVVL1               141    145  0
     D  $CVDR2               146    153
     D  $CVVL2               154    158  0
     D  $CVDR3               159    166
     D  $CVVL3               167    171  0
     D  $CVDR4               172    179
     D  $CVVL4               180    184  0
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
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      None
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C*  If the program didn't change ...
     C*    Then skip to the end.
     C*
     C                   If            JoJob  = LstJob
     C                             And JoUser = LstUsr
     C                             And JoNbr  = LstJb#
     C                             And JoPgm  = LstPgm
     C                   Eval      LstDte = JoDate
     C                   Eval      LstTim = JoTime
     C                   Goto      Bottom
     C                   EndIf
     C*
     C*  The program did change ...
     C*
     C*    If program is not one that we want to track,
     C*      then get next record.
     C*
     C                   If        JoPgm <> 'OR610'
     C                             And JoPgm <> 'OR615'
     C                             And JoPgm <> 'OR620'
     C                             And JoPgm <> 'OR625'
     C                             And JoPgm <> 'OR630'
     C                             And JoPgm <> 'OR605'
     C                   Goto      Bottom
     C                   EndIf
     C*
     C*    If we are tracking a program ...
     C*      We already know that the program changed
     C*        Therefore, write out the record and set tracking off.
     C*
     C                   If        Tracking = *On
     C                   Move      LstDte        $Cvd6i
     C                   Eval      $CvCmd = '*MDYCMD'
     C                   Call      @CVTDT
     C                   Parm                    $CVTDT
     C                   Eval      RttEdt = $Cvd8o
     C                   Eval      RttETm = LstTim
     C                   Exsr      CalcDur
     C                   Write     RttRec
     C                   Eval      Tracking = *Off
     C                   EndIf
     C*
     C*    When we get here, we know we are not tracking anything.
     C*      Therfore see if we should start.
     C*
     C                   If        JoPgm = 'OR610'
     C                             Or JoPgm = 'OR615'
     C                             Or JoPgm = 'OR620'
     C                             Or JoPgm = 'OR625'
     C                             Or JoPgm = 'OR630'
     C                   Eval      Tracking = *On
     C                   Eval      RttWhs = 0
     C                   Eval      RttRid = ' '
     C                   Eval      $Cvd6i = JoDate
     C                   Eval      $CvCmd = '*MDYCMD'
     C                   Call      @CVTDT
     C                   Parm                    $CVTDT
     C                   Eval      RttSdt = $Cvd8o
     C                   Eval      RttStm = JoTime
     C                   Eval      RttPgm = JoPgm
     C                   Eval      RttEdt = RttSdt
     C                   Eval      RttEtm = RttStm
     C                   Eval      RttJob = JoJob
     C                   Eval      RttUsr = JoUser
     C                   Eval      RttJb# = JoNbr
     C                   Eval      RttRdt = RttSdt
     C*
     C*      If start time is less than 5:00am
     C*       Then subtract 1 from the day for report date.
     C*
     C                   If        RttStm < 50000
     C                   Eval      $CvCmd = '*CMDCMD'
     C                   Move      RttSdt        $CvD8i
     C                   Eval      $CvDr1 = '*SUBDAYS'
     C                   Eval      $CvVl1 = 1
     C                   Call      @CLCDR
     C                   PARM                    $CVTDT
     C                   Eval      RttRdt = $CvD8o
     C                   EndIf
     C*
     C                   EndIf
     C*
     C                   Eval      LstJob = JoJob
     C                   Eval      LstUsr = JoUser
     C                   Eval      LstJb# = JoNbr
     C                   Eval      LstPgm = JoPgm
     C                   Eval      LstDte = JoDate
     C                   Eval      LstTim = JoTime
     C*
     C     BOTTOM        TAG
     C*
     CLR                 If        Tracking = *On
     CLR                 Move      LstDte        $Cvd6i
     CLR                 Eval      $CvCmd = '*MDYCMD'
     CLR                 Call      @CVTDT
     CLR                 Parm                    $CVTDT
     CLR                 Eval      RttEdt = $Cvd8o
     CLR                 Eval      RttETm = LstTim
     CLR                 Write     RttRec
     CLR                 Eval      Tracking = *Off
     CLR                 EndIf
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
     CSR                 Move      *On           FOREVR            1
     CSR                 Move      *Off          Tracking          1
     C*
     CSR                 Move      *Blanks       LstDte            6
     CSR                 Z-Add     0             LstTim            6 0
     CSR                 Move      *Blanks       LstJob           10
     CSR                 Move      *Blanks       LstUsr           10
     CSR                 Z-Add     0             LstJb#            6 0
     CSR                 Move      *Blanks       LstPgm           10
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  CalcDur  Calculate duration in minutes.
     C*
     CSR   CalcDur       BEGSR
     C*
     C                   Call      'CALCTIME'
     C                   Parm      '*MINUTES'    $PCmd             8
     C                   Parm                    RttSdt
     C                   Parm                    RttStm
     C                   Parm                    RttEdt
     C                   Parm                    RttEtm
     C                   Parm                    RttMin
     C*
     CSR                 ENDSR
