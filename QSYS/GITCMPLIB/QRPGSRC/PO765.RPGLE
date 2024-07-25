      /copy *libl/qcopysrc,hspecs
     F*----------------------------------------------------------------
     F*   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  PO765     Remove receiving/picking log entries - Post
     F*  28 September 1999
     F*  Max Blacknik
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
500 AF*  11/15/04  MLB  5.00
     F*    - Enh: Added client custom enhancements.
500aAF*  11/15/04  MLB  5.00a
     F*    - Enh: Changed size of days to keep to 3,0 from 1,0.
500bAF*  11/15/04  MLB  5.00b
     F*    - Enh: Changed default number of days to keep to 7 from 4
     F*      when OPTIONS file record not found.
     F*
510 AF*  07/08/06  MLB  5.10
     F*    - Fix: Revised program to change NBRPCK, NBRRCV fields to
     F*      7,0 from 5,0. Revised program to send multiple messages
     F*      until removed is less than 99,999.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
CHY AF*  11/15/04  MLB  CHY
     F*    - Enh: Added logic to keep 75 days of tracking history.
CHY1AF*  04/28/05  MLB  CHY1
     F*    - Fix: Revised program to change NBRPCK, NBRRCV fields to
     F*      7,0 from 5,0. Revised program to send multiple messages
     F*      until removed is less than 99,999.
     F*      NOTE: This mod added as base mod fix with ver 5.10.
     F*
     F*----------------------------------------------------------------
     F* Indicators
     F*
     F*
     F*----------------------------------------------------------------
     F* File Specs
     F*
     FPIRTRCK3  UF   E           K DISK
     FOPTIONS   IF   E           K DISK
500 AI*----------------------------------------------------------------
500 AI*  Customer id
500 AI*
      /COPY QCOPYSRC,ID#CHENEY
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D DESC            S             50    DIM(2) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D  TODAY          S               D   DATFMT(*ISO)
     D  CUTRCV         S               D   DATFMT(*ISO)
     D  CUTPCK         S               D   DATFMT(*ISO)
     D  TSTDAT         S               D   DATFMT(*ISO)
     D DATDS           DS
     D  HMS                    1      6  0
     D  MDY                    7     12  0
     D  HMSMDY                 1     12  0
     D $MDT            DS
     D  ERRMSG                 1     50
     D*
     D  ERRECS                 1      3P 0
     D  ERDESC                 4     48
     D DECDS           DS
510 DD* NBRRCV                 1      5  0
510 MD  NBRRCV                 1      7  0
510 DD* NBRPCK                 6     10  0
510 MD  NBRPCK                 8     14  0
     D*----------------------------------------------------------------
     D*  *SYSTEM  -  System options.
     D*----------------------------------------------------------------
     D*
     D* Fields
     D*
     D*    OPEPM   -  Using EPM module (Y,N).
     D*    OPRF    -  Using RF module (Y,N).
     D*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     D*    OPLETD  -  Print letdown labels (Y,N).
     D*    OPWRNC  -  Perform catch weight variance check (Y,N).
     D*    OPRG1C  -  Catch weight low variance percentage.
     D*    OPRG2C  -  Catch weight high variance percentage.
     D*    OPIMPI  -  Import item fields from host.(Y,N).
     D*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     D*    OPRCDY  -  Number of days to keep receiving log entries.
     D*    OPPKDY  -  Number of days to keep picking log entries.
     D*
     D* Data structure
     D*
     DOPDAT2           DS
     D  OPEPM                  1      1
     D  OPRF                   2      2
     D  OPCAPC                 3      3
     D  OPLETD                 4      4
     D  OPWRNC                 5      5
     D  OPRG1C                 6      8  1
     D  OPRG2C                 9     11  1
     D  OPIMPI                12     12
     D  OPMPCK                14     14
     D  OPRCDY                15     15  0
     D  OPPKDY                16     16  0
     D  OPTEN2               117    117
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D DIGITS          C                   CONST('0123456789')
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PPRG   - Program to send message back to.
     C*      &PWHSE  - Warehouse
     C*      &PRCDY  - Remove receiving log entries older than x days.
     C*      &PPKDY  - Remove picking log entries older than x days.
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PPRG            10
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PRCDY            1
     C                   PARM                    $PPKDY            1
     C                   MOVE      $PWHSE        $KWHSE            3 0
500aAC*
500aAC                   MOVE      *ZEROS        $KRCDY            3 0
500aDC*                  MOVE      $PRCDY        $KRCDY            1 0
500aMC                   MOVE      $PRCDY        $KRCDY
500aAC*
500aAC                   MOVE      *ZEROS        $KPKDY            3 0
500aDC*                  MOVE      $PPKDY        $KPKDY            1 0
500aMC                   MOVE      $PPKDY        $KPKDY
500aAC*
     C*
     C*  Define key for options file, System values.
     C*
     C     *LIKE         DEFINE    OPWHSE        KYWHSE
     C     OPKEY         KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    OPCODE
     C*
     C*  Define key for PIRTRCK3 file
     C*
     C     *LIKE         DEFINE    $KWHSE        KYWHSE
     C     *LIKE         DEFINE    TRCODE        KYCODE
     C     TRKEY         KLIST
     C                   KFLD                    KYWHSE
     C                   KFLD                    KYCODE
     C*
     C*      Get default cutoff days.
     C*
     C                   MOVE      *ZEROS        KYWHSE
     C                   MOVE      '*SYSTEM '    OPCODE
     C     OPKEY         CHAIN     OPTIONS                            79
     C     *IN79         IFEQ      *ON
500bDC*                  MOVE      '4'           OPRCDY
500bMC                   MOVE      '7'           OPRCDY
500bDC*                  MOVE      '4'           OPPKDY
500bMC                   MOVE      '7'           OPPKDY
     C                   ELSE
     C                   MOVEL     OPDATA        OPDAT2
     C                   ENDIF
     C*
     C*       Load warehouse field for processing.
     C*
     C                   MOVE      $PWHSE        KYWHSE
     C*
     C*       Test to see if receiving entries are going to be removed.
     C*
     C     $PRCDY        IFEQ      'N'
     C                   MOVE      '*NO '        RUNRCV            4
     C                   ELSE
     C                   MOVE      '*YES'        RUNRCV
     C     DIGITS        CHECK     $PRCDY                                 10
     C     *IN10         IFEQ      *ON
     C                   MOVE      OPRCDY        $KRCDY
     C                   ENDIF
CHY AC*
CHY AC*    Client wants to keep more than 9 days of Tracking History.
CHY AC                   if        client = cheney
CHY AC                   eval      $krcdy = 75
CHY AC                   endif
CHY AC*
     C                   ENDIF
     C*
     C*       Test to see if picking entries are going to be removed.
     C*
     C     $PPKDY        IFEQ      'N'
     C                   MOVE      '*NO '        RUNPCK            4
     C                   ELSE
     C                   MOVE      '*YES'        RUNPCK
     C     DIGITS        CHECK     $PPKDY                                 10
     C     *IN10         IFEQ      *ON
     C                   MOVE      OPPKDY        $KPKDY
     C                   ENDIF
CHY AC*
CHY AC*    Client wants to keep more than 9 days of Tracking History.
CHY AC                   if        client = cheney
CHY AC                   eval      $kpkdy = 75
CHY AC                   endif
CHY AC*
     C                   ENDIF
     C*
     C*   Compute cutoff dates for receiving/picking entries.
     C*
     C     TODAY         SUBDUR    $KRCDY:*DAYS  CUTRCV
     C     TODAY         SUBDUR    $KPKDY:*DAYS  CUTPCK
     C*----------------------------------------------------------------
     C* Main line
     C*
     C*  Delete receiving log records older than x days.
     C*
     C                   EXSR      ZZRMVR
     C*
     C*  Delete picking log records older than x days.
     C*
     C                   EXSR      ZZRMVP
     C*
     C*  Send messages.
     C*
     C                   EXSR      ZM0750
     C*
     C                   MOVE      *ON           *INLR
     C*
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR

500 A *  Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client           10

     CSR                 MOVE      *ZEROS        DECDS
     CSR                 MOVE      *ZEROS        DATDS
     CSR                 TIME                    HMSMDY
     CSR   *MDY          MOVE      MDY           TODAY
     CSR                 Z-ADD     0             ERRECS
     CSR                 MOVEL     DESC(1)       ERDESC
     C*
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a different program msgq
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSG'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID            7
     CSR                 PARM                    #MSGTP            7
     CSR                 PARM                    #MSGDT
     CSR                 PARM      $PPRG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     PIR0750  Records removed.
     C*
     CSR   ZM0750        BEGSR
     C*
     C*    Send message for number of receiving entries removed.
     C*
510 AC*      Send msg(s) until nbr rmv'd less than 99999 because
510 AC*      message variable only defined as 5,0.
510 AC     Nbrrcv        ifgt      99999
510 AC                   Dow       nbrrcv > 99999
510 AC     Nbrrcv        Ifgt      99999
510 AC                   move      'PIR0750'     #msgid
510 AC                   move      '*DIAG  '     #msgtp
510 AC                   z-add     99999         errecs
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zmsmsg
510 AC     Nbrrcv        sub       99999         nbrrcv
510 AC                   Endif
510 AC                   Enddo
510 AC                   Endif
510 AC*
     CSR                 MOVE      'PIR0750'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 Z-ADD     NBRRCV        ERRECS
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     C*
     C*    Send message for number of picking entries removed.
510 AC*      Send msg(s) until nbr rmv'd less than 99999 because
510 AC*      message variable only defined as 5,0.
     C*
510 AC     Nbrpck        ifgt      99999
510 AC                   Dow       nbrpck > 99999
510 AC     Nbrpck        Ifgt      99999
510 AC                   move      'PIR0750'     #msgid
510 AC                   move      '*DIAG  '     #msgtp
510 AC                   z-add     99999         errecs
510 AC                   movel     desc(2)       erdesc
510 AC                   movea     errmsg        $md(1)
510 AC                   exsr      zmsmsg
510 AC     Nbrpck        sub       99999         nbrpck
510 AC                   Endif
510 AC                   Enddo
510 AC                   Endif
510 AC*
     CSR                 Z-ADD     NBRPCK        ERRECS
     CSR                 MOVEL     DESC(2)       ERDESC
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZZRMVR   Remove receiving log entries older than x days
     C*
     CSR   ZZRMVR        BEGSR
     C*
     CSR                 MOVEL(P)  '*RCV'        KYCODE
     CSR   TRKEY         SETLL     PIRTRCK3
     CSR                 MOVE      *OFF          EOF
     CSR   EOF           DOWEQ     *OFF
     CSR   KYWHSE        READE     PIRTRCK3                               79
     C*
     CSR                 MOVE      *IN79         EOF               1
     CSR                 MOVEL     TRCODE        CODE              4
     C*
     C*    If past pick codes, exit loop.
     C*
     CSR   CODE          IFGT      '*RCV'
     CSR                 LEAVE
     CSR                 ENDIF
     C*
     C*    Test date for validity, 40=Invalid date and allow
     C*    record to be removed.
     C*
     CSR   *ISO          TEST(D)                 TRRCDT                 40
     CSR   *IN40         IFEQ      *OFF
     CSR   *ISO          MOVE      TRRCDT        TSTDAT
     CSR                 ENDIF
     C*
     CSR                 SELECT
     CSR   *IN79         WHENEQ    *OFF
     CSR   CODE          ANDEQ     '*RCV'
     CSR   TSTDAT        ANDLT     CUTRCV
     CSR   RUNRCV        ANDEQ     '*YES'
     C*
     CSR   *IN79         OREQ      *OFF
     CSR   CODE          ANDEQ     '*RCV'
     CSR   *IN40         ANDEQ     *ON
     CSR   RUNRCV        ANDEQ     '*YES'
     CSR                 DELETE    TRREC3
     CSR                 ADD       1             NBRRCV
     C*
     CSR                 ENDSL
     CSR                 ENDDO
     C*
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*    ZZRMVP   Remove picking log entries older than x days
     C*
     CSR   ZZRMVP        BEGSR
     C*
     CSR                 MOVEL(P)  '*PCK'        KYCODE
     CSR   TRKEY         SETLL     PIRTRCK3
     CSR                 MOVE      *OFF          EOF
     CSR   EOF           DOWEQ     *OFF
     CSR   KYWHSE        READE     PIRTRCK3                               79
     C*
     CSR                 MOVE      *IN79         EOF               1
     CSR                 MOVEL     TRCODE        CODE              4
     C*
     C*    If past pick codes, exit loop.
     C*
     CSR   CODE          IFGT      '*PCK'
     CSR                 LEAVE
     CSR                 ENDIF
     C*
     C*    Test date for validity, 40=Invalid and allow entry
     C*    to be removed.
     C*
     CSR   *ISO          TEST(D)                 TRRCDT                 40
     CSR   *IN40         IFEQ      *OFF
     CSR   *ISO          MOVE      TRRCDT        TSTDAT
     CSR                 ENDIF
     C*
     CSR                 SELECT
     CSR   *IN79         WHENEQ    *OFF
     CSR   CODE          ANDEQ     '*PCK'
     CSR   TSTDAT        ANDLT     CUTPCK
     CSR   RUNPCK        ANDEQ     '*YES'
     C*
     CSR   *IN79         OREQ      *OFF
     CSR   CODE          ANDEQ     '*PCK'
     CSR   *IN40         ANDEQ     *ON
     CSR   RUNPCK        ANDEQ     '*YES'
     CSR                 DELETE    TRREC3
     CSR                 ADD       1             NBRPCK
     C*
     CSR                 ENDSL
     CSR                 ENDDO
     C*
     CSR                 ENDSR
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**
Receiving log entries
Picking log entries
