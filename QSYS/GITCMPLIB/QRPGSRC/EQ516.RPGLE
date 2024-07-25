     F*----------------------------------------------------------------
     F*   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  EQ516     Print work orders (*ALL or one)
     F*  Roxanne Harrison
     F*  17 March, 2003
     F*
     F*  3/17/03 RH   4.17
     F*  - Created
     F*
     F*  Revisions
417a *    04/17/03  RH   4.17a
     *      - Change program to override printer file.
417b *    07/24/03  RH   4.17b
     *      - Recompile - EQUIPT1 file changed.
417c *    02/18/04  RH   4.17c
     *      - Do not print detail EQUIPA if status =3 (repeat)
417d *    04/29/04  RH   4.17d
     *      - Increase EQ ID from 6 to 8
     F*
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FEQ516     IP   E           K DISK
     FEQUIPT1   IF   E           K DISK
     FWAREHS    IF   E           K DISK
     FPIRUSER1  IF   E           K DISK
     FEQUIP     IF   E           K DISK
     FEQUIPQ1   IF   E           K DISK
     FEQUIPA1   IF   E           K DISK
     FREPORTS   IF   E           K DISK
     FEQUIPW    UF   E           K DISK
     F                                     RENAME(EWREC:RECRD)
417a F*Q516PR   O    E             PRINTER OFLIND(*IN90)
417a Feq516pr   O    E             printer usropn
     F                                     oflind(*IN90)
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D*                   RPD     1   3 30
     D RECK            S              7  0 DIM(3)
     D LVLK            S              7  0 DIM(3)
     D A22             S              1    DIM(22)
     D DTE             S             22    DIM(4) CTDATA PERRCD(1)
     D*----------------------------------------------------------------
     D*  Called programs
     D*
     D @CVTDT          C                   CONST('CVTDTE')
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
     D*  Date redefinition data structure
     D*
     D $PFMDT          DS
     D  $PFMCC                 1      2
     D  $PFMYY                 3      4
     D  $PFMMM                 5      6
     D  $PFMDD                 7      8
     D $PTODT          DS
     D  $PTOCC                 1      2
     D  $PTOYY                 3      4
     D  $PTOMM                 5      6
     D  $PTODD                 7      8
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D noon            s               t   inz(t'12.00.00')

     D currtimestamp   s               z

     D $fromdate       s               d
     D $todate         s               d

     D datestamp       s               d
     D timestamp       s               t

     D datedsp         s              8
     D timedsp         s              8

     I*
     I*----------------------------------------------------------------
     IOQREC
     I                                          EWWRK#        L1
     I*----------------------------------------------------------------
     Irecrd
     I              ewwhse                      eiwhse
     I              ewwrk#                      eiwrk#
     I              ewgdte                      eigdte
     I              ewetrn                      eietrn
     I              ewio                        eiio
     I              ewpdte                      eipdte
     I              ewemp#                      eiemp#
     I              ewcdte                      eicdte
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHSE            3
     C                   PARM                    $PWRK#            5
     C*
     C*----------------------------------------------------------------
     C*
     C*  Report Heading
     C*
     C*
     C     *IN90         IFEQ      '1'
     C     *INL1         OREQ      '1'
     C                   EXSR      ZRZERO
     C                   EXSR      ZRHEAD
     C                   END
     C*
     C*  Init total levels
     C*
     C*
     C*  Level 1 break - Work order
     C*
     C     *INL1         IFEQ      '1'
     C                   Z-ADD     1             L
     C                   END
     C*
     C*  Output Headings
     C*
     C     *IN91         IFEQ      *ON
     C     *INL1         OREQ      *ON
     C*
     C     ewio          ifeq      'I'
     C                   eval      w1io = ' IN'
     C                   else
     C                   eval      w1io = 'OUT'
     C                   endif
     C                   MOVE      *BLANKS       WKNAME
     C     ETKEY         CHAIN     EQUIPT1                            78
     C     *IN78         IFEQ      *OFF
     C*  convert generated date.
     C                   move      ewgdte        datestamp
     C     *MDY/         movel     datestamp     w1gdte
     C*
     C     ETEMP#        CHAIN     PIRUSER1                           79
     C     *IN79         IFEQ      *OFF
     C                   MOVE      '*LFM    '    $CMD              8
     C                   MOVE      *BLANKS       $NAME            40
     C                   CALL      'FRMTNM'
     C                   PARM                    $CMD
     C                   PARM                    USFNAM
     C                   PARM                    USINIT
     C                   PARM                    USLNAM
     C                   PARM                    $NAME
     C                   MOVEL     $NAME         WKNAME
     C                   ENDIF
     C                   ENDIF
     C*
     C*  Get equipment ID description
     C                   MOVE      *BLANKS       WKEDSC
     C     EPKEY         CHAIN     EQUIP                              77
     C     *IN77         IFEQ      *OFF
     C                   MOVE      EQDESC        WKEDSC
     C                   ENDIF
     C*
     C     ewpdte        ifne      0
     C                   eval      w1rprt = '*REPRINT*'
     C                   else
     C                   eval      w1rprt = *blanks
     C                   endif
     C*
     C                   WRITE     EWHEAD
     C*
     C                   WRITE     COLUMNS
     C     EWPDTE        IFEQ      0
     C     ewkey         chain     equipw                             75
     C     *in75         ifeq      *off
     C                   eval      eipdte = today
     C                   UPDATE    RECRD
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
     C*----------------------------------------------------------------
     C*
     C* Detail Calcs
     C*
     C                   eval      w1by = *blanks
     C                   eval      w1bydt = *blanks
     C*  Get exception questions and answers
     C     eakey         setll     equipa1                            77
     C                   move      *in77         eof               1
     C     eof           doweq     *off
     C                   move      *blanks       w1ansr
     C     eakey         reade     equipa1                                77
     C                   move      *in77         eof
     C                   move      *blanks       w1qstn
     C     *in77         ifeq      *off
     C     eaexcp        ifeq      '0'
     C                   iter
     C                   endif
417c C     eastat        ifeq      '3'
417c C                   iter
417c C                   endif
     C                   move      eaansr        w1ansr
     C     eqkey         chain     equipq1                            76
     C     *in76         ifeq      *off
     C                   move      euqstn        w1qstn
     C                   endif
     C*
     C*  Write detail line
     C*
     C*
     C     EWPDTE        IFGT      0
     C                   MOVE      '*CMDMDY '    $CVCMD
     C                   MOVE      EWPDTE        $CVD8I
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD6O        W1PDTE            6 0
     C                   ELSE
     C                   Z-ADD     0             W1PDTE
     C                   ENDIF
     C*
     C*
     C                   WRITE     DETAIL1
     C*
     C*  Increment record counters
     C*
     C                   ADD       1             COUNT
     C                   ADD       1             RECK(1)
     C                   ADD       1             LVLK(1)
     C*
     C*  Set off top-of-page indicators
     C*
     C                   MOVE      '0'           *IN91
     C                   endif
     C                   enddo
     C*----------------------------------------------------------------
     C*
     C* Slot type/Department totals
     C*
     CL1                 Z-ADD     1             L
     CL1                 EXSR      ZRROLL
     C**                   Z-ADDCOUNT     TRNCNT
     C**                   WRITETOTAL1
     CL1                 Z-ADD     0             COUNT
     C*
     C*----------------------------------------------------------------
     C*
     C* REPORT TOTALS
     C*
     CLR                 Z-ADD     2             L
     C*
     CLR   RECK(L)       IFGT      0
     CLR                 WRITE     SKIP1
     CLR                 WRITE     FOOT1
     CLR                 END
     CLR                 exsr      clsprt
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
     C*  Convert today's date into century format.
     C*
     C                   MOVE      '0'           *IN91
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        TODAY             8 0
     C*
     C*
     CSR   RPKEY         KLIST
     CSR                 KFLD                    WKPRTF           10
     C*
     CSR   ETKEY         KLIST
     CSR                 KFLD                    EWWHSE
     CSR                 KFLD                    EWETRN
     C*
     CSR   EPKEY         KLIST
     CSR                 KFLD                    ETWHSE
     CSR                 KFLD                    ETCODE
     C*
     CSR   EAKEY         KLIST
     CSR                 KFLD                    EWWHSE
     CSR                 KFLD                    EWETRN
     CSR                 KFLD                    EWIO
     C*
     CSR   EQKEY         KLIST
     CSR                 KFLD                    EASEQ#
     C*
     CSR   EWKEY         KLIST
     CSR                 KFLD                    EWWHSE
     CSR                 KFLD                    EWWRK#
     C*
     C*   Get report title.
     C*
     CSR                 MOVEL     'EQ516PR '    WKPRTF
     CSR                 MOVE      *BLANKS       RPTTTL
     C                   MOVE      *BLANKS       $PSTR
417a C                   MOVE      *BLANKS       wpdev            10
417a C                   MOVE      *BLANKS       wpform           10
     CSR   RPKEY         CHAIN     REPORTS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVEL     RPDESC        $PSTR            60
417a CSR                 MOVEL     RPDEV         wpdev
417a CSR                 MOVEL     RPFORM        wpform
     CSR                 ELSE
417a C                   eval      wpdev = '*JOB'
417a C                   eval      wpform = '*STD'
     CSR                 ENDIF
     CSR                 Z-ADD     40            $PLEN             3 0
     C*
     C*   Center report title.
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         RPTTTL
     C*
417a Csr                 exsr      opnprt
     C*
     CSR                 TIME                    TIME
     CSR                 Z-ADD     0             COUNT             3 0
     CSR                 Z-ADD     2             L                 1 0
     CSR                 EXSR      ZRZERO
     CSR                 ENDSR
417a C*----------------------------------------------------------------
417a C*
417a C*  CLSPRT  Close printer file.
417a C*----------------------------------------------------------------
417a C     clsprt        BegSr

     *  Close printer file

     C                   close(e)  eq516pr
     C                   if        %error
     C                   endif

     *  Delete override for printer file.

     C                   eval      qcmd = 'DLTOVR '
     C                                  + 'FILE(EQ516PR) '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
417a C     endclsprt     endsr
417a C*----------------------------------------------------------------
417a C*
417a C*  OPNPRT  Open printer file.
417a C*----------------------------------------------------------------
417a C     opnprt        BegSr
     *  Initialize print fields.


     *  Override printer file

     C                   if        wpdev = ' '
     C                   eval      wpdev = '*JOB'
     C                   endif

     C                   if        wpform = ' '
     C                   eval      wpform = '*STD'
     C                   endif

     C                   eval      qcmd = 'OVRPRTF '
     C                                  + 'FILE(EQ516PR) '
     C                                  + 'OUTQ(*DEV) '
     C                                  + 'DEV(' + %trim(wpdev) + ') '
     C                                  + 'FORMTYPE(' + %trim(wpform) + ') '

     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5

     *  Open printer file

     C                   open(e)   eq516pr
     C                   if        %error
     C                   endif
417a C     endopnprt     endsr
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C     *INL1         IFEQ      '0'
     C                   MOVE      '1'           *IN91
     C                   END
     C*
     C                   MOVE      '0'           *IN90
     C*
     C*   Get warehouse description.
     C*
     C                   MOVE      *BLANKS       WHSE             50
     C                   MOVE      *BLANKS       $PSTR
     C     EWWHSE        CHAIN     WAREHS                             79
     C     *IN79         IFEQ      *OFF
     C                   MOVEL     WHDESC        $PSTR            60
     C                   ELSE
     C                   MOVE      *BLANKS       $PSTR
     C                   ENDIF
     C                   Z-ADD     30            $PLEN             3 0
     C*
     C*   Center warehouse description.
     C*
     C                   CALL      'CENTER'
     C                   PARM                    $PSTR
     C                   PARM                    $PLEN
     C                   MOVEL     $PSTR         WHSE
     C*
     C                   WRITE     HEAD1
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRROLL        BEGSR
     C*
     C     *LIKE         DEFINE    L             M
     C     L             ADD       1             M
     C*
     C                   ADD       1             LVLK(M)
     C                   ADD       RECK(L)       RECK(M)
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRTOTL        BEGSR
     C*
     C*          L         IFEQ 1
     C*                    WRITETOTAL1
     C*                    END
     C*
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRZERO        BEGSR
     C*
     C                   Z-ADD     0             LVLK(L)
     C                   Z-ADD     0             RECK(L)
     C*
     C                   ENDSR
     O*----------------------------------------------------------------
     O*
     O* Compile time tables
     O*
**      DTE   Date headings
99/99/99 thru 99/99/99
     From 99/99/99
     Thru 99/99/99

