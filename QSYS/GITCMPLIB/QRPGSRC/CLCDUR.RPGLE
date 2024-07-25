     F********************************************************************
     F*   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved    *
     F*   BFC Software, Inc.                                             *
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108                           *
     F*   Glen Ellyn, IL  60137                                          *
     F*   (630) 790-8383                                                 *
     F********************************************************************
     F*
     F*  CLCDUR    Calculate date/time durations
     F*  December 22, 1999
     F*  Max Blacknik
     F*
     F*  Revisions
     F*
     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*
     D A5              S              1    DIM(5)
     D A6              S              1    DIM(6)
     D A9              S              1    DIM(9)
     D A40             S              1    DIM(40)
     D*----------------------------------------------------------------
     D* Program parameters
     D*
     D  DURDAT         S               D   DATFMT(*ISO)
     D  DURTIM         S               T   TIMFMT(*HMS)
     D*
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD6T                19     24  0
     D  $CVD8I                25     32
     D  $CVD8D                25     32  0
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
     D* Date structure for TIME function.
     D*
     D                 DS
     D  DSBOTH                 1     12  0
     D  DSTIME                 1      6  0
     D  DSMNTH                 7      8  0
     D  DSDAY                  9     10  0
     D  DSYEAR                11     12  0
     D  DSDATE                 7     12  0
     D                 DS
     D  CVFLD1                 7      8  0
     D  CVFLD2                 9     10  0
     D  CVFLD3                11     12  0
     D  CVDATE                 1     12  0
     D                 DS
     D  SYSFMT                 1      3
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERRDTE                 1      6
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
     D*  Called programs
     D*
     D @RTVSV          C                   CONST('GETDATFMT')
     I*----------------------------------------------------------------
     I*
     I*  Input parameters
     I*
     I*     $CVCMD   -  Command
     I*                 *CURCMD   - Put current date into YYYYMMDD
     I*                 *CURYMD   - Put current date into YYMMDD
     I*                 *CURMDY   - Put current date into MMDDYY
     I*
     I*                 *CMDYMD   - YYYYMMDD ==> YYMMDD
     I*                 *CMDMDY   - YYYYMMDD ==> MMDDYY
     I*                 *CMDCMD   - YYYYMMDD ==> YYYYMMDD - Date/Time duration p
     I*
     I*                 *YMDMDY   - YYMMDD   ==> MMDDYY
     I*                 *YMDCMD   - YYMMDD   ==> YYYYMMDD
     I*                 *YMDYMD   - YYMMDD   ==> YYMMDD - Date/Time duration pro
     I*
     I*                 *MDYYMD   - MMDDYY   ==> YYMMDD
     I*                 *MDYCMD   - MMDDYY   ==> YYYYMMDD
     I*                 *MDYMDY   - MMDDYY   ==> MMDDYY - Date/Time duration pro
     I*                 *YMDEDT   - Edit YYMMDD date - Not supported for date du
     I*                 *MDYEDT   - Edit MMDDYY date - Not supported for date du
     I*                 *TIMEDUR  - Add/subtract time duration.
     I*
     I*     $CVPRG   -  Program to send messages back to.
     I*     $CVD6I   -  6 digit date (alpha)
     I*     $CVD8I   -  8 digit date (alpha)
     I*     $CVDR1   -  Duration 1 command
     I*                 *ADDDAYS  - Add days to a date
     I*                 *ADDMTHS  - Add months to a date
     I*                 *ADDYRS   - Add years to a date
     I*                 *SUBDAYS  - Subtract days from a date
     I*                 *SUBMTHS  - Subtract months from a date
     I*                 *SUBYRS   - Subtract years from a date
     I*                 *ADDSECS  - Add seconds to a time
     I*                 *ADDMINS  - Add minutes to a time
     I*                 *ADDHRS   - Add hours to a time
     I*                 *SUBSECS  - Subtract seconds from a time
     I*                 *SUBMINS  - Subtract minutes from a time
     I*                 *SUBHRS   - Subtract hours from a time
     I*     $CVVL1   -  Duration 1 value - Amount to add/subtract
     I*     $CVDR2   -  Duration 2 command
     I*                 * See values for $CVDR1
     I*     $CVVL2   -  Duration 2 value - Amount to add/subtract
     I*     $CVDR3   -  Duration 3 command
     I*                 * See values for $CVDR1
     I*     $CVVL3   -  Duration 3 value - Amount to add/subtract
     I*     $CVDR4   -  Duration 4 command
     I*                 * See values for $CVDR1
     I*     $CVVL4   -  Duration 4 value - Amount to add/subtract
     I*
     I* Note: Up to four values can be specified at one time, but time and date
     I*       cannot be mixed together.
     I*
     I*  Output parameters
     I*
     I*     $CVD6O   -  6 digit date (numeric) or time if $CVCMD = *TIMEDUR
     I*     $CVD8O   -  8 digit date (numeric)
     I*     $CVSTO   -  Date in words
     I*     $CVRTN   blank    - No problem encountered.
     I*              *CANCEL  - CMD12 was entered
     I*              *ERROR   - Error occured. Message in $PERM
     I*              *PGMQ    - Error occured. Message sent to pgmq.
     I*     $CVERM   Error message or pointer to message in pgmq.
     I*
     I*
     C*
     C*     **********************
     C*     *                    *
     C*     * FIRST TIME THROUGH *
     C*     *                    *
     C*     **********************
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $CVTDT
     C                   Z-ADD     0             $CVD6O
     C                   Z-ADD     0             $CVD8O
     C                   MOVE      *BLANKS       $CVSTO
     C                   MOVE      *BLANKS       $CVRTN
     C****temptemp       MOVE      *BLANKS       $CVERM
     C                   MOVE      *ZEROS        DSBOTH
     C                   MOVE      *ZEROS        CVDATE
     C*
     C     $CVCMD        CASEQ     '*CURCMD '    CURCMD
     C     $CVCMD        CASEQ     '*CURYMD '    CURYMD
     C     $CVCMD        CASEQ     '*CURMDY '    CURMDY
     C     $CVCMD        CASEQ     '*CMDYMD '    CMDYMD
     C     $CVCMD        CASEQ     '*CMDMDY '    CMDMDY
     C     $CVCMD        CASEQ     '*YMDEDT '    YMDEDT
     C     $CVCMD        CASEQ     '*YMDMDY '    YMDMDY
     C     $CVCMD        CASEQ     '*YMDCMD '    YMDCMD
     C     $CVCMD        CASEQ     '*MDYEDT '    MDYEDT
     C     $CVCMD        CASEQ     '*MDYYMD '    MDYYMD
     C     $CVCMD        CASEQ     '*MDYCMD '    MDYCMD
     C                   END
     C*
     C*    Calculate time/date duration to be added/subtracted.
     C*
     C     $CVCMD        IFNE      '*YMDEDT '
     C     $CVCMD        ANDNE     '*MDYEDT '
     C*
     C     $CVDR1        IFGT      *BLANKS
     C     $CVDR2        ORGT      *BLANKS
     C     $CVDR3        ORGT      *BLANKS
     C     $CVDR4        ORGT      *BLANKS
     C                   EXSR      DURPROC
     C                   ENDIF
     C                   ENDIF
     C*
     C                   RETURN
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CVTFMT           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Convert system date format to MMDDYY format.                     DOC
     C*                                                                   DOC
     CSR   CVTFMT        BEGSR
     CSR                 TIME                    CVDATE
     CSR                 SELECT
     CSR   SYSFMT        WHENEQ    'MDY'
     CSR                 Z-ADD     CVDATE        DSDATE
     C*
     CSR   SYSFMT        WHENEQ    'YMD'
     CSR                 Z-ADD     CVFLD1        DSYEAR
     CSR                 Z-ADD     CVFLD2        DSMNTH
     CSR                 Z-ADD     CVFLD3        DSDAY
     C*
     CSR   SYSFMT        WHENEQ    'DMY'
     CSR                 Z-ADD     CVFLD1        DSDAY
     CSR                 Z-ADD     CVFLD2        DSMNTH
     CSR                 Z-ADD     CVFLD3        DSYEAR
     C*
     CSR                 ENDSL
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CURCMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Put current date into YYYYMMDD format.                           DOC
     C*                                                                   DOC
     CSR   CURCMD        BEGSR
     CSR                 EXSR      GETFMT
     CSR                 EXSR      CVTFMT
     C*
     C*R         UYEAR     MULT 10000     $CVD8O
     CSR   DSYEAR        MULT      10000         $CVD8O
     CSR   $CVD8O        IFGE      930000
     CSR                 ADD       19000000      $CVD8O
     CSR                 ELSE
     CSR                 ADD       20000000      $CVD8O
     CSR                 END
     C*R         UMONTH    MULT 100       WORK4N  40
     CSR   DSMNTH        MULT      100           WORK4N            4 0
     CSR                 ADD       WORK4N        $CVD8O
     C*R                   ADD  UDAY      $CVD8O
     CSR                 ADD       DSDAY         $CVD8O
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CURYMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Put current date into YYMMDD format.                             DOC
     C*                                                                   DOC
     CSR   CURYMD        BEGSR
     CSR                 EXSR      GETFMT
     CSR                 EXSR      CVTFMT
     C*
     C*R         UYEAR     MULT 10000     $CVD6O
     CSR   DSYEAR        MULT      10000         $CVD6O
     C*R         UMONTH    MULT 100       WORK4N
     CSR   DSMNTH        MULT      100           WORK4N
     CSR                 ADD       WORK4N        $CVD6O
     C*R                   ADD  UDAY      $CVD6O
     CSR                 ADD       DSDAY         $CVD6O
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CURMDY           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Put current date into MMDDYY format.                             DOC
     C*                                                                   DOC
     CSR   CURMDY        BEGSR
     CSR                 EXSR      GETFMT
     CSR                 EXSR      CVTFMT
     C*
     C*R         UMONTH    MULT 10000     $CVD6O
     CSR   DSMNTH        MULT      10000         $CVD6O
     C*R         UDAY      MULT 100       WORK4N
     CSR   DSDAY         MULT      100           WORK4N
     CSR                 ADD       WORK4N        $CVD6O
     C*R                   ADD  UYEAR     $CVD6O
     CSR                 ADD       DSYEAR        $CVD6O
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CMDYMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  YYYYMMDD ==> YYMMDD                                              DOC
     C*                                                                   DOC
     CSR   CMDYMD        BEGSR
     CSR                 MOVE      $CVD8I        $CVD6I
     CSR                 EXSR      YMDEDT
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE CMDMDY           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  YYYYMMDD ==> MMDDYY                                              DOC
     C*                                                                   DOC
     CSR   CMDMDY        BEGSR
     CSR                 MOVE      $CVD8I        $CVD6I
     CSR                 EXSR      YMDMDY
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE DTEDT3           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*-------------------------------------------------------------------------
     C* VERIFY DATE ROUTINE
     C*    THIS ROUTINE WILL TAKE A 6 DIGIT DATE AND VERIFY THAT IT IS  VALID.
     C*    THE DATE CAN BE IN YYMMDD OR MMDDYY FORMAT. IF THE LAST CHARACTER
     C*    OF THE DATE IS BLANK EVERYTHING IS SHIFTED 1 CHAR. TO THE RIGHT.
     C*
     C*    THIS ROUTINE IS VERY SIMILAR TO DTEDIT. A NEW FEATURE WAS ADDED
     C*    THAT ALLOWS THE USER TO ENTER 3M, 2W OR 10D FOR 3 MONTHS, 2 WEEKS
     C*    OR 10 DAYS - OF COURSE THE NUMBER CAN BE ANYTHING. IF THIS ROUTINE
     C*    FINDS AN 'M', 'W', OR 'D' IT WILL CALCULATE A NEW DATE BASED ON
     C*    TODAYS DATE. TO MAKE THE CALCULATION A LITTLE EASIER A MONTH ('M')
     C*    WILL BE EQUAL TO 30 DAYS.
     C*
     C* INPUT FIELDS
     C*    $CVD6I   6    DATE TO BE CHECKED
     C*    DTFRMT  1.0   FORMAT OF DATE (1-YYMMDD, 2-MMDDYY)
     C* OUTPUT FIELDS
     C*    $CVD6O   6.0  VERIFIED, FORMATED DATE
     C*    G$JD     5.0  JULIAN DATE
     C* ERRORS
     C*    IF AN ERROR OCCURS A MESSAGE WILL BE SENT TO THE MSGQ OF THE
     C*    PROGRAM THAT CALLED THIS ROUTINE.
     C*
     C*-------------------------------------------------------------------------
     C     DTEDT3        BEGSR
     CSR                 MOVE      '0'           ERROR             1
     CSR                 MOVE      $CVD6I        DTDATE            6
     C*
     C* DEFINE INPUT FIELDS (DOES NOT AFFECT CONTENTS)
     C*
     C     DTFRST        IFNE      '1'
     C                   ADD       0             DTFRMT            1 0
     C*                    MOVE UDATE     G$DATE
     CSR                 EXSR      GETFMT
     CSR                 EXSR      CVTFMT
     C*
     C*                    MOVELUMONTH    WORK4
     C                   MOVEL     DSMNTH        WORK4
     C*                    MOVE UDAY      WORK4
     C                   MOVE      DSDAY         WORK4
     C                   MOVEL     WORK4         G$DATE
     C*                    MOVE UYEAR     G$DATE
     C                   MOVE      DSYEAR        G$DATE
     C                   Z-ADD     DTFRMT        SVFRMT            1 0
     C                   Z-ADD     2             DTFRMT
     C                   EXSR      GTOJ$
     C                   Z-ADD     G$JD          UDATEJ            5 0
     C                   Z-ADD     SVFRMT        DTFRMT
     C                   MOVE      '1'           DTFRST            1
     C                   END
     C*
     C* SEE IF WE ARE WORKING WITH A NORMAL DATE OR A 'MWD' DATE
     C*
     C                   MOVE      *BLANKS       DTTYPE            8
     C                   Z-ADD     0             DTDAYS            3 0
     C                   MOVEA     DTDATE        A6
     C*
     C                   Z-ADD     1             X                 2 0
     C     'M'           LOOKUP    A6(X)                                  50
     C     *IN50         IFEQ      '1'
     C                   MOVE      'MONTHS  '    DTTYPE
     C                   Z-ADD     30            DTDAYS
     C                   END
     C*
     C     DTTYPE        IFEQ      *BLANKS
     C                   Z-ADD     1             X
     C     'W'           LOOKUP    A6(X)                                  50
     C     *IN50         IFEQ      '1'
     C                   MOVE      'WEEKS   '    DTTYPE
     C                   Z-ADD     7             DTDAYS
     C                   END
     C                   END
     C*
     C     DTTYPE        IFEQ      *BLANKS
     C                   Z-ADD     1             X
     C     'D'           LOOKUP    A6(X)                                  50
     C     *IN50         IFEQ      '1'
     C                   MOVE      'DAYS    '    DTTYPE
     C                   Z-ADD     1             DTDAYS
     C                   END
     C                   END
     C*
     C     DTTYPE        IFEQ      *BLANKS
     C                   MOVE      'NORMAL  '    DTTYPE
     C                   END
     C*
     C* 'MWD' PROCESSING
     C*
     C     DTTYPE        IFEQ      'MONTHS  '
     C     DTTYPE        OREQ      'WEEKS   '
     C     DTTYPE        OREQ      'DAYS    '
     C                   MOVEA     *BLANKS       A6(X)
     C                   MOVEA     A6            RA0A
     C                   EXSR      RADJ
     C                   Z-ADD     RA0N          DTMWD#            5 0
     C     DTMWD#        MULT      DTDAYS        DTTOTL            5 0
     C     UDATEJ        ADD       DTTOTL        J$JD
     C                   EXSR      JTOG$
     C                   MOVE      J$DATE        $CVD6O
     C                   GOTO      ENDDT
     C                   END
     C*
     C* NORMAL PROCESSING
     C*
     C*
     C* IF LAST CHAR OF DATE IS BLANK SHIFT EVERYTHING TO RIGHT 1 CHAR
     C*
     C                   MOVE      DTDATE        WORK1             1
     C     WORK1         IFEQ      ' '
     C                   MOVEL     DTDATE        WORK5             5
     C                   MOVE      WORK5         $CVD6I            6
     C                   MOVEL     '0'           $CVD6I
     C                   END
     C*
     C* CONVERT DATE TO JULIAN FORMAT THEN BACK TO NORMAL FORMAT FOR CHECK
     C*
     C                   MOVE      DTDATE        G$DATE
     C                   EXSR      GTOJ$
     C                   Z-ADD     G$JD          J$JD              5 0
     C                   EXSR      JTOG$
     C*
     C* CHECK FOR VALID DATE (DATE FROM JTOG$ WILL MATCH INPUT DATE)
     C*
     C     G$YYYY        IFNE      J$YYYY
     C     G$MM          ORNE      J$MM
     C     G$DD          ORNE      J$DD
     C                   MOVE      '1'           ERROR
     C                   MOVE      '*PGMQ   '    $CVRTN
     C                   EXSR      ZM1007
     C                   ELSE
     C                   Z-ADD     J$DATE        $CVD6O
     C                   END
     C     ENDDT         ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE DURPROC          *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     CSR   DURPROC       BEGSR
     C*
     C*    Convert outbound numeric date/time into Date/Time data type field.
     C*
     CSR                 SELECT
     CSR   $CVCMD        WHENEQ    '*CURCMD '
     CSR   $CVCMD        OREQ      '*YMDCMD '
     CSR   $CVCMD        OREQ      '*MDYCMD '
     CSR   *ISO          MOVE      $CVD8O        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*CURYMD '
     CSR   $CVCMD        OREQ      '*CMDYMD '
     CSR   $CVCMD        OREQ      '*MDYYMD '
     CSR   *YMD          MOVE      $CVD6O        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*CURMDY '
     CSR   $CVCMD        OREQ      '*YMDMDY '
     CSR   *MDY          MOVE      $CVD6O        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*CMDCMD '
     CSR   *ISO          MOVE      $CVD8D        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*YMDYMD '
     CSR   *YMD          MOVE      $CVD6T        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*MDYMDY '
     CSR   *MDY          MOVE      $CVD6T        DURDAT
     C*
     CSR   $CVCMD        WHENEQ    '*TIMEDUR'
     CSR   *HMS          MOVE      $CVD6T        DURTIM
     C*
     CSR                 ENDSL
     C*
     C*    Process duration value 1.
     C*
     CSR   $CVDR1        IFGT      *BLANKS
     CSR                 MOVE      $CVDR1        DURCMD            8
     CSR                 MOVE      $CVVL1        DURVAL            5 0
     CSR                 EXSR      DURCALC
     CSR                 ENDIF
     C*
     C*    Process duration value 2.
     C*
     CSR   $CVDR2        IFGT      *BLANKS
     CSR                 MOVE      $CVDR2        DURCMD
     CSR                 MOVE      $CVVL2        DURVAL
     CSR                 EXSR      DURCALC
     CSR                 ENDIF
     C*
     C*    Process duration value 3.
     C*
     CSR   $CVDR3        IFGT      *BLANKS
     CSR                 MOVE      $CVDR3        DURCMD
     CSR                 MOVE      $CVVL3        DURVAL
     CSR                 EXSR      DURCALC
     CSR                 ENDIF
     C*
     C*    Process duration value 4.
     C*
     CSR   $CVDR4        IFGT      *BLANKS
     CSR                 MOVE      $CVDR4        DURCMD
     CSR                 MOVE      $CVVL4        DURVAL
     CSR                 EXSR      DURCALC
     CSR                 ENDIF
     C*
     C*    Convert new date/time into proper format for return.
     C*
     CSR                 SELECT
     CSR   $CVCMD        WHENEQ    '*CURCMD '
     CSR   $CVCMD        OREQ      '*YMDCMD '
     CSR   $CVCMD        OREQ      '*MDYCMD '
     CSR   $CVCMD        OREQ      '*CMDCMD '
     CSR   *ISO          MOVE      DURDAT        $CVD8O
     C*
     CSR   $CVCMD        WHENEQ    '*CURYMD '
     CSR   $CVCMD        OREQ      '*CMDYMD '
     CSR   $CVCMD        OREQ      '*MDYYMD '
     CSR   $CVCMD        OREQ      '*YMDYMD '
     CSR   *YMD          MOVE      DURDAT        $CVD6O
     C*
     CSR   $CVCMD        WHENEQ    '*CURMDY '
     CSR   $CVCMD        OREQ      '*YMDMDY '
     CSR   $CVCMD        OREQ      '*MDYMDY '
     CSR   *MDY          MOVE      DURDAT        $CVD6O
     C*
     CSR   $CVCMD        WHENEQ    '*TIMEDUR'
     CSR   *HMS          MOVE      DURTIM        $CVD6O
     C*
     CSR                 ENDSL
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE DURCALC          *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C     DURCALC       BEGSR
     C*
     C*    Calculate date duration.
     C*
     CSR                 SELECT
     CSR   DURCMD        WHENEQ    '*ADDDAYS'
     CSR   DURDAT        ADDDUR    DURVAL:*DAYS  DURDAT
     C*
     CSR   DURCMD        WHENEQ    '*ADDMTHS'
     CSR   DURDAT        ADDDUR    DURVAL:*MONTHSDURDAT
     C*
     CSR   DURCMD        WHENEQ    '*ADDYRS '
     CSR   DURDAT        ADDDUR    DURVAL:*YEARS DURDAT
     C*
     CSR   DURCMD        WHENEQ    '*SUBDAYS'
     CSR   DURDAT        SUBDUR    DURVAL:*DAYS  DURDAT
     C*
     CSR   DURCMD        WHENEQ    '*SUBMTHS'
     CSR   DURDAT        SUBDUR    DURVAL:*MONTHSDURDAT
     C*
     CSR   DURCMD        WHENEQ    '*SUBYRS '
     CSR   DURDAT        SUBDUR    DURVAL:*YEARS DURDAT
     C*
     C*    Calculate time duration.
     C*
     CSR   DURCMD        WHENEQ    '*ADDHRS '
     CSR   DURTIM        ADDDUR    DURVAL:*HOURS DURTIM
     C*
     CSR   DURCMD        WHENEQ    '*ADDMINS'
     CSR   DURTIM        ADDDUR    DURVAL:*MN    DURTIM
     C*
     CSR   DURCMD        WHENEQ    '*ADDSECS'
     CSR   DURTIM        ADDDUR    DURVAL:*S     DURTIM
     C*
     CSR   DURCMD        WHENEQ    '*SUBHRS '
     CSR   DURTIM        SUBDUR    DURVAL:*HOURS DURTIM
     C*
     CSR   DURCMD        WHENEQ    '*SUBMINS'
     CSR   DURTIM        SUBDUR    DURVAL:*MN    DURTIM
     C*
     CSR   DURCMD        WHENEQ    '*SUBSECS'
     CSR   DURTIM        SUBDUR    DURVAL:*S     DURTIM
     C*
     CSR                 ENDSL
     C*
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE GETFMT           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     CSR   GETFMT        BEGSR
     CSR                 CALL      @RTVSV
     CSR                 PARM      'QDATFMT '    $LVAL            10
     CSR                 PARM      *BLANKS       $LDTA             3
     CSR                 MOVEL     $LDTA         SYSFMT
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE GTOJ$            *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C     GTOJ$         BEGSR
     C                   MOVE      G$DATE        G$DATE            6 0
     C* SPLIT DATE INTO MONTH, DAY, YEAR FIELDS
     C     DTFRMT        IFEQ      1
     C                   MOVEL     G$DATE        G$YY              2 0
     C                   MOVE      G$DATE        WORK4             4
     C                   MOVEL     WORK4         G$MM              2 0
     C                   MOVE      WORK4         G$DD              2 0
     C                   ELSE
     C                   MOVEL     G$DATE        G$MM
     C                   MOVE      G$DATE        WORK4
     C                   MOVEL     WORK4         G$DD
     C                   MOVE      WORK4         G$YY
     C                   END
     C* CREATE 4 DIGIT YEAR
     C                   MOVE      G$YY          G$YYYY            4 0
     C     G$YY          IFGE      60
     C                   MOVEL     '19'          G$YYYY
     C                   ELSE
     C                   MOVEL     '20'          G$YYYY
     C                   END
     C                   Z-ADD     0             G$JD
     C     G$MM          SUB       3             G$MMWK            2 0
     C                   Z-ADD     G$MMWK        GMWKSV            2 0
     C     G$MMWK        IFLT      0
     C                   ADD       12            G$MMWK
     C                   END
     C     GMWKSV        IFNE      0
     C     G$MMWK        MULT(H)   30.6          G$JD
     C                   END
     C                   ADD       G$DD          G$JD              5 0
     C     G$YYYY        SUB       1900          G$YYWK            3 0
     C     G$YYWK        IFNE      0
     C     GMWKSV        IFLT      0
     C                   SUB       1             G$YYWK
     C                   END
     C                   END
     C     G$YYWK        MULT      365.25        G$JYD             7 0
     C                   ADD       G$JYD         G$JD
     C     G$JD          DIV       7             G$WK7             7 0
     C                   MVR                     G$DW              1 0
     C                   ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE JTOG$            *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C     JTOG$         BEGSR
     C     J$JD          DIV       365.25        J$YYWK            3 0
     C     J$JD          DIV       365.25        J$TST             9 9
     C     J$TST         IFEQ      0
     C                   SUB       1             J$YYWK
     C                   END
     C     J$YYWK        MULT      365.25        J$YD              7 0
     C     J$JD          SUB       J$YD          J$YD
     C     J$YD          IFGT      306
     C                   ADD       1             J$YYWK
     C                   END
     C                   Z-ADD     0             J$X               2 0
     C     J$YD          DOULE     J$MD
     C                   ADD       1             J$X
     C     J$X           MULT(H)   30.6          J$MD              3 0
     C                   END
     C                   SUB       1             J$X
     C     J$X           MULT(H)   30.6          J$MD
     C     J$YD          SUB       J$MD          J$DD              2 0
     C     J$X           ADD       3             J$MM              2 0
     C     J$MM          IFGT      12
     C                   SUB       12            J$MM
     C                   END
     C     J$YYWK        ADD       1900          J$YYYY            4 0
     C     DTFRMT        IFEQ      1
     C                   MOVE      J$YYYY        WORK2             2
     C                   MOVEL     J$MM          WORK4             4
     C                   MOVE      J$DD          WORK4
     C                   MOVEL     WORK2         J$DATE            6 0
     C                   MOVE      WORK4         J$DATE
     C                   ELSE
     C                   MOVE      J$YYYY        WORK2
     C                   MOVEL     J$MM          WORK4
     C                   MOVE      J$DD          WORK4
     C                   MOVE      WORK2         J$DATE
     C                   MOVEL     WORK4         J$DATE
     C                   END
     C                   ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE MDYEDT           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Edit date in MMDDYY format.                                      DOC
     C*                                                                   DOC
     CSR   MDYEDT        BEGSR
     CSR                 Z-ADD     2             DTFRMT
     CSR                 EXSR      DTEDT3
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE MDYCMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  MMDDYY ==> YYYYMMDD                                              DOC
     C*                                                                   DOC
     CSR   MDYCMD        BEGSR
     CSR   *LIKE         DEFINE    $CVD6I        SVVD6I
     CSR                 EXSR      MDYYMD
     CSR                 MOVE      $CVD6I        SVVD6I
     CSR                 MOVE      $CVD6O        $CVD6I
     CSR                 EXSR      YMDCMD
     CSR                 MOVE      SVVD6I        $CVD6I
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE MDYYMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  MMDDYY ==> YYMMDD                                                DOC
     C*                                                                   DOC
     CSR   MDYYMD        BEGSR
     CSR                 Z-ADD     2             DTFRMT
     CSR                 EXSR      DTEDT3
     CSR   ERROR         IFEQ      '0'
     CSR   $CVD6O        MULT      10000.01      $CVD6O
     CSR                 END
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE RADJ             *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     CSR   RADJ          BEGSR
     C* SUBR TO RIGHT ADJUST & STRIP DEC POINT
     C* INPUT IS FIELDXRA0A 12 BYTE ALPHA
     C* OUTPUT IS FIELDXRA0N 9.0  RA2N 11.2   RA5N 11.5
     C                   MOVEA     RA0A          A40
     C                   Z-ADD     0             RA2N             11 2
     C                   Z-ADD     0             RA5N             11 5
     C                   Z-ADD     0             RA0N             11 0
     C                   Z-ADD     12            DX                2 0
     C     LRA01         TAG
     C* FINDXLAST SIG DIGIT
     C     A40(DX)       COMP      ' '                                    50
     C  N50              GOTO      HRA01
     C     DX            SUB       1             DX
     C     DX            COMP      0                                      50
     C  N50              GOTO      LRA01
     C                   GOTO      ENDRA0
     C     HRA01         TAG
     C                   Z-ADD     12            D2                2 0
     C     LRA02         TAG
     C* RADJ TO FIRST 12 BYTES
     C     A40(DX)       COMP      ','                                    50
     C  N50              MOVE      A40(DX)       A40(D2)
     C     DX            SUB       1             DX
     C  N50D2            SUB       1             D2
     C     DX            COMP      0                                      50
     C  N50              GOTO      LRA02
     C     LRA03         TAG
     C* PUT IN LEADING BLANKS
     C     D2            COMP      0                                      50
     C   50              GOTO      ERA03
     C                   MOVE      ' '           A40(D2)
     C     D2            SUB       1             D2
     C                   GOTO      LRA03
     C     ERA03         TAG
     C                   Z-ADD     1             DX                2 0
     C* FINDXDEC PIOIN
     C     LRA06         TAG
     C     A40(DX)       COMP      '.'                                    50
     C   50              GOTO      HRA03
     C     DX            ADD       1             DX
     C     DX            COMP      13                                     50
     C  N50              GOTO      LRA06
     C     HRA03         TAG
     C                   MOVE      *BLANK        A9
     C                   MOVE      *BLANK        A5
     C                   Z-ADD     DX            D2                2 0
     C                   Z-ADD     1             D3                2 0
     C* INSERT AFTER DEC POINT
     C     LRA04         TAG
     C     D2            ADD       1             D2
     C     D2            COMP      13                                 50  50
     C   50              GOTO      ERA04
     C                   MOVE      A40(D2)       A5(D3)
     C     D3            ADD       1             D3
     C     D3            COMP      6                                      50
     C  N50              GOTO      LRA04
     C     ERA04         TAG
     C                   Z-ADD     DX            D2
     C                   Z-ADD     9             D3
     C     LRA05         TAG
     C     D2            SUB       1             D2
     C     D2            COMP      0                                      50
     C   50              GOTO      ERA05
     C                   MOVE      A40(D2)       A9(D3)
     C     D3            SUB       1             D3
     C     D3            COMP      0                                      50
     C  N50              GOTO      LRA05
     C     ERA05         TAG
     C                   MOVEA     A5            WORK5A            5
     C                   MOVEA     A9            WORK9A            9
     C                   MOVE      WORK9A        WORK9N            9 0
     C                   MOVEL     WORK5A        WORK2N            2 2
     C                   MOVE      WORK5A        WORK5N            5 5
     C                   Z-ADD     WORK9N        RA0N
     C                   Z-ADD     WORK9N        RA2N             11 2
     C                   ADD       WORK2N        RA2N
     C                   Z-ADD     WORK9N        RA5N             11 5
     C                   ADD       WORK5N        RA5N
     C     ENDRA0        TAG
     C                   MOVE      *BLANK        RA0A             12
     C                   ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE YMDCMD           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  YYMMDD ==> YYYYMMDD                                              DOC
     C*                                                                   DOC
     CSR   YMDCMD        BEGSR
     CSR                 EXSR      YMDEDT
     CSR   $CVD6O        IFGE      930000
     CSR   19000000      ADD       $CVD6O        $CVD8O
     CSR                 ELSE
     CSR   20000000      ADD       $CVD6O        $CVD8O
     CSR                 END
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE YMDEDT           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  Edit date in YYMMDD format.                                      DOC
     C*                                                                   DOC
     CSR   YMDEDT        BEGSR
     CSR                 Z-ADD     1             DTFRMT
     CSR                 EXSR      DTEDT3
     CSR                 ENDSR
     C*                                                                   DOC
     C*     ******************************************                    DOC
     C*     *                                        *                    DOC
     C*     *            SUBROUTINE YMDMDY           *                    DOC
     C*     *                                        *                    DOC
     C*     ******************************************                    DOC
     C*                                                                   DOC
     C*  YYMMDD ==> MMDDYY                                                DOC
     C*                                                                   DOC
     CSR   YMDMDY        BEGSR
     CSR                 Z-ADD     1             DTFRMT
     CSR                 EXSR      DTEDT3
     CSR   ERROR         IFEQ      '0'
     CSR   $CVD6O        MULT      100.0001      $CVD6O
     CSR                 END
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
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
     CSR                 PARM      $CVPRG        #PGMQ            10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     PIR1007  Invalid date
     C*
     CSR   ZM1007        BEGSR
     CSR                 MOVE      'PIR1007'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVE      $CVD6I        ERRDTE
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $CVMSG
     CSR                 ENDSR
