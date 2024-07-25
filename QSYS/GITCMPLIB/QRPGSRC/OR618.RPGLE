     F*----------------------------------------------------------------
     F*   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  OR618     Truck build - Allocate against SLOTDTE file
     F*  17 April 2007
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
510 AF*    04/17/07  MLB  5.10
     F*      -  Created.
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        CHAIN INDICATOR
     F*  90        OVERFLOW INDICATOR FOR EXCEPTION REPORT
     F*  91        OVERFLOW INDICATOR FOR CATCH WEIGHT REPORT
     F*  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FSLOTDTE   IF   E           K DISK
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D*----------------------------------------------------------------
     D*  Customer id
     D*
     D @GETCL          C                   CONST('GETCLIENT')
     D*  Insert client id /copy mbrs here.
     D*
     D*----------------------------------------------------------------
     D*  Redefinition data structures
     D*
     D $AERM           DS
     D  XAERM                  1     60
     D  $AMSG                  1      4
     D $CERM           DS
     D  XCERM                  1     60
     D  $CMSG                  1      4
     D*----------------------------------------------------------------
     D*  Working Variable(s)
     D*
     D                 DS
     D  TOTAV1                 1      7  0
     D  TOTAV2                 8     14  0
     D  TOTAV3                15     21  0
     D                 DS
     D  DIFFQ1                 1      7  0
     D  DIFFQ2                 8     14  0
     D  DIFFQ3                15     21  0
     D                 DS
     D  TOTBK1                 1      7  0
     D  TOTBK2                 8     14  0
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRCL1                 1     10
     D  ERRCL2                11     16
     D                 DS
     D  $EC                    1      2P 0
     D*----------------------------------------------------------------
     D*  Message control
     D*
     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)
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
     C*      $PCMD   *ALLOC   - Allocate pick quantity against slot.
     C*      $PWHSE  Warehouse
     C*      $PWHDP  Department
     C*      $PDISP  Slot display
     C*      $PITEM  Item number
     C*      $PUMQ2  Breakdown qty 1
     C*      $PUMQ3  Breakdown qty 2
     C*      $PCTOF  Cutoff date
     C*      $PLTQ1  Quantity left to pick 1
     C*      $PLTQ2  Quantity left to pick 2
     C*      $PLTQ3  Quantity left to pick 3
     C*      $PALC1  Slot allocated quantity 1
     C*      $PALC2  Slot allocated quantity 2
     C*      $PALC3  Slot allocated quantity 3
     C*      $PPCK1  Slot picked quantity 1
     C*      $PPCK2  Slot picked quantity 2
     C*      $PPCK3  Slot picked quantity 3
     C*
     C*    Returned Parameters
     C*      $PRTQ1  Quantity 1 allocated from slot.
     C*      $PRTQ2  Quantity 2 allocated from slot.
     C*      $PRTQ3  Quantity 3 allocated from slot.
     C*      $PRTN   blank    - No problem encountered.
     C*              *ERROR   - Error occured.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PCMD             8
     C                   PARM                    $PWHSE            3 0
     C                   PARM                    $PWHDP            5
     C                   PARM                    $PDISP           12
     C                   PARM                    $PITEM           15
     C                   PARM                    $PUMQ1            3 0
     C                   PARM                    $PUMQ2            3 0
     C                   PARM                    $PCTOF            8 0
     C*
     C                   PARM                    $PLTQ1            5 0
     C                   PARM                    $PLTQ2            5 0
     C                   PARM                    $PLTQ3            5 0
     C*
     C                   PARM                    $PALC1            5 0
     C                   PARM                    $PALC2            5 0
     C                   PARM                    $PALC3            5 0
     C*
     C                   PARM                    $PPCK1            5 0
     C                   PARM                    $PPCK2            5 0
     C                   PARM                    $PPCK3            5 0
     C*
     C                   PARM                    $PRTQ1            5 0
     C                   PARM                    $PRTQ2            5 0
     C                   PARM                    $PRTQ3            5 0
     C*
     C                   PARM                    $PRTN             8
     C*
     C*----------------------------------------------------------------
     C*  Main line
     C*
     C*    Clear return quantity fields.
     C                   MOVE      *ZEROS        $PRTQ1
     C                   MOVE      *ZEROS        $PRTQ2
     C                   MOVE      *ZEROS        $PRTQ3
     C*
     C                   MOVE      *BLANKS       $PRTN
     C
     C                   Select
     C*
     C*    Accumulate quantity available from SLOTDTE file.
     C                   When      $pcmd = '*ALLOC'
     C
     C                   EXSR      TOTQTY
     C*
     C*    Compute quantity to be picked from slot.
     C                   EXSR      ALLOC
     C                   Endsl
     C
     C*
     C                   RETURN
     C                   MOVE      *ON           *INLR
     C*
     C*----------------------------------------------------------------
     C*
     C*          Subroutines in Alphabetical Order
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subroutine
     C*
     C     *INZSR        BEGSR
     C*
     C* Get client id.
     C*
     C                   CALL      @GETCL
     C                   PARM                    CLIENT           10
     C*
     C*  Define key for SLOTDTE file.
     C*
     C     KEYSDT        KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    $PWHDP
     C                   KFLD                    $PDISP
     C                   KFLD                    $PITEM
     C*
     C*  Variables and constants.
     C*
     C                   MOVE      *OFF          FOREVR            1
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ALLOC   Allocate item from SLOTDTE file.
     C*
     C     ALLOC         BEGSR
     C*
     C                   SELECT
     C*    Normal unit quantity to allocate.
     C     $PLTQ1        WHENGT    0
     C*
     C*    Subtract Allocated/Picked quantity from total qty.
     C     TOTAV1        SUB       $PALC1        DIFFQ1
     C     TOTAV1        SUB       $PPCK1        DIFFQ1
     C*
     C     TOTAV1        SUB       $PLTQ1        DIFFQ1
     C     DIFFQ1        IFLT      0
     C     DIFFQ1        MULT      -1            DIFFQ1
     C     $PLTQ1        SUB       DIFFQ1        $PRTQ1
     C                   ELSE
     C                   Z-ADD     $PLTQ1        $PRTQ1
     C                   ENDIF
     C*
     C*    Breakdown 1 quantity to allocate.
     C     $PUMQ2        WHENGT    0
     C     $PLTQ2        ANDGT     0
     C*
     C*    Subtract Allocated/Picked quantity from total qty.
     C     TOTAV1        SUB       $PALC1        TOTAV1
     C     TOTAV1        SUB       $PPCK1        TOTAV1
     C*
     C*    Convert Normal units to total brkdown 1 units.
     C     TOTAV1        MULT      $PUMQ2        TOTBK1
     C     TOTBK1        ADD       TOTAV2        TOTBK1
     C*
     C*    Subtract Allocated/Picked quantity from brkdown qty.
     C     TOTBK1        SUB       $PALC2        TOTBK1
     C     TOTBK1        SUB       $PPCK2        TOTBK1
     C*
     C     TOTBK1        SUB       $PLTQ2        DIFFQ2
     C     DIFFQ2        IFLT      0
     C     DIFFQ2        MULT      -1            DIFFQ2
     C     $PLTQ2        SUB       DIFFQ2        $PRTQ2
     C                   ELSE
     C                   Z-ADD     $PLTQ2        $PRTQ2
     C                   ENDIF
     C*
     C*    Breakdown 2 quantity to allocate.
     C     $PUMQ2        WHENGT    0
     C     $PLTQ3        ANDGT     0
     C*
     C*    Subtract Allocated/Picked quantity from total qty.
     C     TOTAV1        SUB       $PALC1        TOTAV1
     C     TOTAV1        SUB       $PPCK1        TOTAV1
     C*
     C*    Convert Normal+Brkdwn1 units to total brkdown 2 units.
     C     TOTAV1        MULT      $PUMQ1        TOTBK1
     C     TOTBK1        ADD       TOTAV2        TOTBK1
     C     TOTBK1        MULT      $PUMQ2        TOTBK2
     C     TOTBK2        ADD       TOTAV3        TOTBK2
     C*
     C*    Subtract Allocated/Picked quantity from brkdown qty.
     C     TOTBK2        SUB       $PALC3        TOTBK2
     C     TOTBK2        SUB       $PPCK3        TOTBK2
     C*
     C     TOTBK2        SUB       $PLTQ3        DIFFQ3
     C     DIFFQ3        IFLT      0
     C     DIFFQ3        MULT      -1            DIFFQ3
     C     $PLTQ3        SUB       DIFFQ3        $PRTQ3
     C                   ELSE
     C                   Z-ADD     $PLTQ3        $PRTQ3
     C                   ENDIF
     C*
     C                   ENDSL
     C*
     C                   ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  TOTQTY  Total quantity available from SLOTDTE file.
     C*
     C     TOTQTY        BEGSR
     C*
     C                   MOVE      *ZEROS        TOTAV1
     C                   MOVE      *ZEROS        TOTAV2
     C                   MOVE      *ZEROS        TOTAV3
     C*
     C* Loop through SLOTDTE file.
     C*
     C     FOREVR        DOWEQ     FOREVR
     C*
     C     KEYSDT        READE     SLOTDTE                                79
     C                   SELECT
     C*
     C*    Loop through detail records for order.
     C*
     C     *IN79         WHENEQ    *ON
     C                   LEAVE
     C*
     C*       Product has expired. Skip quantity.
     C     SDTDTE        WHENLE    $PCTOF
     C                   ITER
     C*
     C*       Product has good date.
     C                   OTHER
     C*
     C*       Accumulate slot quantity by date.
     C*
     C                   ADD       SDTQT1        TOTAV1
     C                   ADD       SDTQT2        TOTAV2
     C                   ADD       SDTQT3        TOTAV3
     C*
     C                   ENDSL
     C*
     C                   ENDDO
     C*
     C                   ENDSR
     C*
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
