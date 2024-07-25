     F*----------------------------------------------------------------
     F*   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (708) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  RN622   RF Customer return w UCI whole order - Process
     F*  08 August 2007
     F*  Roxanne Harrison
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
     F*
     F*    08/08/07  RH   5.10
     F*      - Created using RN122
     F*      - Only for manual put away.
     F*      - Updates UCICW, creates LICENSE, ORRTN,records.
     F*      - Create license rec, license = 'R' & original label
     F*        to allow whole order put away using license in voice.
     F*
510a F*    09/10/07  HNK  5.10a
     F*      - Revise to add records to UCIADJ and UCILOG file.
     F*        Add two parms...$PDLVY and $PBILL
     F*        Add ORRTNM file and copy source member.
510b F*    09/20/07  MLB   5.10b
     F*      - Fix: Revise pgm to load correct values into Delivery
     F*        Number and Billing Document# when warehouse > 001.
510c F*    09/21/07  MLB   5.10c
     F*      - Fix: Revise pgm to receive invoice# from RN620 to
     F*        load into ORRTN file in Original invoice#.
510d F*    09/24/07  MLB   5.10d
     F*      - Fix: Revise pgm to load $PDLVY into ORINV#.
510e F*    09/27/07  MLB   5.10e
     F*      - Fix: Revise pgm to load catchwgt into UANWGT in
     F*        UCIADJ file.
     *
650 A*    03/08/13  MLB  6.50
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
     F*
700aA*    08/30/16  LMC  700a
     *      - Enh: UCILOG file was renamed to PUCILOG, so we could
     *             reuse UCILOG for our uci tracking.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
     F*
     F*
     F*----------------------------------------------------------------
     F*  Indicator usage
     F*
     F*  79        Not on file/End of file indicator
     F*  90        Overflow Indicator
     F*  9X        Top of page and level X continues.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
     FRN622     IP   E           K DISK
     FLABEL2    IF   E           K DISK
     FPIRITEM   IF   E           K DISK
     FOPTIONS   IF   E           K DISK
     FLICENSE   O  A E           K DISK
     FLABELNK   O  A E           K DISK
     FORRTN     O  A E           K DISK
     FITMEXCP   O    E           K DISK
     FUCICW10   UF   E           K DISK
510a FUCIADJ    IF A E           K DISK
700aDF*UCILOG    O    E           K DISK
700aMFPUCILOG   O    E           K DISK
510a FORRTNM    O    E           K DISK
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D*
     D A22             S              1    DIM(22)
     D*
     D*
     D*----------------------------------------------------------------
     D*QREC
     D*             LBWHSE                          LQWHSE
     D*             LBWHDP                          LQWHDP
     D*             LBSEQ                           LQSEQ
     D*             LBITEM                          LQITEM
     D*             LBPBAT                          LQPBAT
     D*             LBAISL                          LQAISL
     D*             LBLOC                           LQLOC
     D*             LBRLVL                          LQRLVL
     D*             LBHAND                          LQHAND
     D*             LBPSEQ                          LQPSEQ
     D*             LBSTYP                          LQSTYP
     D*             LBQRYF                          LQQRYF
     D*             LBDISP                          LQDISP
     D*             LBQAVL                          LQQAVL
     D*             LBWHS2                          LQWHS2
     D*             LBWHD2                          LQWHD2
     D*             LBASL2                          LQASL2
     D*             LBLOC2                          LQLOC2
     D*             LBLVL2                          LQLVL2
     D*             LBHND2                          LQHND2
     D*             LBDSP2                          LQDSP2
     D*             LBRTE                           LQRTE
     D*             LBSTOP                          LQSTOP
     D*             LBORD                           LQORD
     D*             LBSPCL                          LQSPCL
     D*             LBPO                            LQPO
     D*             LBUTYP                          LQUTYP
     D*             LBUCOD                          LQUCOD
     D*             LBUCUB                          LQUCUB
     D*             LBCUBE                          LQCUBE
     D*             LBUWGT                          LQUWGT
     D*             LBSWGT                          LQSWGT
     D*             LBQALC                          LQQALC
     D*             LBQRMN                          LQQRMN
     D*             LBQPCK                          LQQPCK
     D*             LBTIE                           LQTIE
     D*             LBHIGH                          LQHIGH
     D*             LBGRP1                          LQGRP1
     D*             LBGRP2                          LQGRP2
     D*             LBTYPE                          LQTYPE
     D*             LBLBL#                          LQLBL#
     D*             LBPAL#                          LQPAL#
     D*             LBTRN#                          LQTRN#
     D*             LBCTR#                          LQCTR#
     D*             LBSTAT                          LQSTAT
     D*             LBPRTY                          LQPRTY
     D*             LBSDTE                          LQSDTE
     D*             LBSTIM                          LQSTIM
     D*             LBRDTE                          LQRDTE
     D*             LBVRFY                          LQVRFY
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
510aA*  SAP Returns Misc field File data structures
510aA*
510aA /copy qcopysrc,rmmsc1_pak
510aA /copy qcopysrc,rmmsc2_pak
510aA /copy qcopysrc,rmmsc3_pak
510aA /copy qcopysrc,rmmsc4_pak
510aA /copy qcopysrc,rmmsc5_pak

     D*----------------------------------------------------------------
     D* Data structure
     D*
500 AD OPDATA          DS
500 AD  OPLPGM                 1     10
500 AD  OPUPCT                11     13  0
500 AD  OPPDEF                14     14  0
500 AD  OPPBLD                15     15  0
500 AD  OPPACT                16     16  0
500 AD  OPFDEF                17     17  0
500 AD  OPFASL                18     18  0
500 AD  OPFSID                19     19  0
500 AD  OPFLVL                20     20  0
500 AD  OPPASL                21     21  0
500 AD  OPPFRC                22     22
500 AD  OPPLCN                23     23
500 AD  OPCUM                 24     43
500 AD  OPCDIV                44     52  2
500 AD  OPCAUT                53     53
500 AD  OPCWRN                54     54
500 AD  OPCRNG                55     57  1
500 AD  OPWUM                 58     72
500 AD  OPXDSC                73     73
500 AD  OPTEND               117    117
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
     D  $LITEM                22     36
     D*
     D  $LCODE                19     20
     D*
     D  $LTRN#                19     25  0
     D*
     D  $LUSER                19     28
     D*
     D  $LPO                  37     45
     D  $LRQ1                 46     50  0 INZ(0)
     D  $LRQ2                 51     55  0 INZ(0)
     D  $LRQ3                 56     60  0 INZ(0)
     D  $LRPAL                61     63  0
     D*----------------------------------------------------------------
     D*
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
     D                 DS
     D  T#DATE                 1      6  0
     D  MONTH                  1      2  0
     D  DAY                    3      4  0
     D  YEAR                   5      6  0
     I*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PWHSE  Warehouse #
     C*      $PRTN   Return
     C*      $PLORD  Label order#
     C*      $PMPUT  Manual put away
510cAC*      $Pinv#  Original invoice number
     C*
     C*    Returned Parameters
     C*      None
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PWHS             3
     C                   PARM                    $PRTN             8
     C                   PARM                    $PLORD            7
     C                   PARM                    $PMPUT            1
     C                   PARM                    $PCODE            2
     C                   PARM                    $PDCDE            5
     C                   PARM                    $PUSER           10
     C                   PARM                    $PCORD            7
     C                   PARM                    $PINVF            1
510a C                   PARM                    $PDLVY            9
510a C                   PARM                    $PBILL           10
510a C                   PARM                    $PSLS             4
510c C                   PARM                    $Pinv#           12
     C*
     C                   MOVE      $PWHS         $PWHSE            3 0
     C                   MOVE      $PLORD        $PLOD#            7 0
     C                   MOVE      $PCORD        $PCOD#            7 0
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C                   MOVE      '*CHANGE '    $LCMD
     C                   Z-ADD     $PWHSE        $LWHSE
     C                   Z-ADD     0             $CRQ1             5 0
     C                   Z-ADD     0             $CRQ2             5 0
     C                   Z-ADD     0             $CRQ3             5 0
     C                   SELECT
     C     LQUTYP        WHENEQ    'N'
     C                   Z-ADD     LQQPCK        $CRQ1
     C     LQUTYP        WHENEQ    '1'
     C                   Z-ADD     LQQPCK        $CRQ2
     C     LQUTYP        WHENEQ    '2'
     C                   Z-ADD     LQQPCK        $CRQ3
     C                   ENDSL
     C                   MOVE      LQITEM        $LITEM
     C                   Z-ADD     1             $LRPAL
     C* $PCOD# IS CUSTOMER ORDER #
     C                   Z-ADD     $PCOD#        $LORD             7 0
500  C*
500  C* Get license options
500  C*
500  C                   EXSR      ZZLCNS
     C*
     C* If manual put away,
     C*
     C                   Z-ADD     $CRQ1         $LRQ1
     C                   Z-ADD     $CRQ2         $LRQ2
     C                   Z-ADD     $CRQ3         $LRQ3
     C                   CALL      'RN246L'
     C                   PARM                    $LPARM
     C                   PARM                    $LORD
     C     $LRTN         IFEQ      '*CANCEL '
     C                   GOTO      ENDIT1
     C                   ENDIF
     C*
     C*      Write to label link file for label #.                     .
     C*
     C                   EXSR      ZZULNK
500  C*      Write to license file, license = 'R' & original label#    .
500  C*
500  C                   Z-ADD     $PWHSE        LIWHSE
500  C                   MOVEL     'R'           LTLCNS            8
500  C                   MOVE      LQLBL#        LTLCNS
500  C                   MOVEL     LTLCNS        LILCNS
500  C                   Z-ADD     LBTRN#        LITRN#
500  C                   WRITE     LIREC
500  C*
     C*      Write exception record to notify inventory control.       .
     C     $PINVF        IFEQ      'Y'
     C                   MOVE      LQITEM        EXITEM
     C                   MOVE      *BLANKS       EXCITM
     C                   MOVE      'INVCTRL'     EXERID
     C                   EXSR      ZZEXCP
     C                   ENDIF
     C*      Product put away. Write history record and display message.
     C                   CLEAR                   ORREC
     C                   Z-ADD     $PWHSE        ORWHSE
     C                   Z-ADD     LQTRN#        ORTRN#
     C*                    Z-ADD$PORD     ORORD
     C                   Z-ADD     $PCOD#        ORORD
     C                   Z-ADD     $LORD         ORPBAT
     C                   MOVE      LQITEM        ORITEM
     C                   Z-ADD     $CRQ1         ORQTY1
     C                   Z-ADD     $CRQ2         ORQTY2
     C                   Z-ADD     $CRQ3         ORQTY3
    DC*                    Z-ADDLQUWGT    ORCWTR
     C                   Z-ADD     0             ORCWTR
     C*    Retrieve current date.
     C                   MOVE      '*CURCMD '    $CVCMD
     C                   CALL      @CVTDT
     C                   PARM                    $CVTDT
     C                   Z-ADD     $CVD8O        ORRDTE
     C                   TIME                    ORRTIM
     C                   MOVE      $PUSER        ORRUSR
     C                   MOVE      ' '           ORTYPE
     C                   Z-ADD     LQTRN#        ORTRN#
     C                   MOVE      *BLANKS       ORCITM
     C                   MOVE      $PCODE        ORRCOD
     C                   MOVE      $PDCDE        ORDCOD
     C                   MOVE      'Y'           ORIINV
     C                   Z-ADD     LQLBL#        OROLB#
510dDC*                  MOVE      *BLANKS       ORINV#
510dMC                   MOVE      $PDLVY        ORINV#
     C                   MOVE      'WHOLE OD'    ORRMEM
     C                   MOVE      *BLANKS       ORSLOT
     C                   Z-ADD     LQORD         OROORD
     C                   MOVE      'Y'           ORWHOL
     C                   WRITE     ORREC
     C*
     C     KEYUCI        SETLL     UCICW10
     C     FOREVR        DOWEQ     FOREVR
     C     KEYUCI        READE     UCICW10                                79
     C     *IN79         IFEQ      *ON
     C                   LEAVE
     C                   ELSE
     C                   Z-ADD     ORRDTE        UCIRDE
     C                   Z-ADD     ORRTIM        UCIRTI
     C                   MOVE      ORRCOD        UCIRCD
     C                   MOVE      'Y'           UCISTS
     C                   MOVE      'N'           UCIPCK
     C                   MOVE      'Y'           UCIRTS
     C                   Z-ADD     LBTRN#        UCIRTT
     C                   UPDATE    UCIREC
     C*
510a C                   EXSR      ZZUADJ
     C*
510a C                   Z-ADD     ORWHSE        RMWHSE
510a C                   Z-ADD     ORORD         RMORD
510a C                   MOVE      ORITEM        RMITEM
510a C                   Z-ADD     ORRDTE        RMRDTE
510a C                   Z-ADD     ORRTIM        RMRTIM
510a C                   Z-ADD     ORPBAT        RMPBAT
510a C                   Z-ADD     ORTRN#        RMTRN#
510a C                   MOVE      ORRCOD        RMRCOD
510a C                   MOVE      ORDCOD        RMDCOD
510a C                   Z-ADD     0             RMUDTE
510a C                   Z-ADD     0             RMUTIM
510bAc                   if        orwhse = 1
510a c                   eval      pakrm1_delv = $PDLVY
510bDc*                  if        orwhse = 1
510a c                   eval      pakrm1_vkorg = $psls
510bAc                   else
510bAc                   eval      pakrm1_delv = $pdlvy
510bAc                   eval      pakrm1_bdoc = $pbill
510a c                   endif
510a c                   eval      rmmsc1 = pakrm1_base
510a c                   eval      rmmsc2 = *blanks
510a c                   eval      rmmsc3 = *blanks
510a c                   eval      rmmsc4 = *blanks
510a c                   eval      rmmsc5 = *blanks
510a C                   WRITE     RMREC
     C*
     C                   ITER
     C                   ENDIF
     C                   ENDDO
     C*
     C*
     C     ENDIT1        TAG
     CLR                 RETURN
     C*
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     C     *INZSR        BEGSR
     C*
     C                   MOVE      *ON           FIRST             1
     C                   MOVE      #PROG         $CVPRG
     C                   EXSR      ZZINZ
     C                   ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZEXCP Write item exception record to file.
     C*
     CSR   ZZEXCP        BEGSR
     C*
     C*    Write an item exception record for item.
     C*
     C     ITKEY         CHAIN     PIRITEM                            79
     C     *IN79         IFEQ      *OFF
     CSR                 MOVE      ITWHDP        EXWHDP
     CSR                 MOVE      ITSTYP        EXSTYP
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       EXWHDP
     CSR                 MOVE      *BLANKS       EXSTYP
     CSR                 ENDIF
     CSR                 Z-ADD     $PWHSE        EXWHSE
650 A*
650 AC                   if        $lrq1 > 999
650 AC                   eval      exqty = 999
650 AC                   else
650 A*
     CSR                 Z-ADD     $LRQ1         EXQTY
650 AC                   endif
650 A*
     CSR                 Z-ADD     $LRQ2         EXQTY2
     CSR                 Z-ADD     $LRQ3         EXQTY3
     CSR                 MOVE      *BLANKS       EXFDIS
     CSR                 MOVE      *BLANKS       EXTDIS
     CSR                 MOVE      'PUTRTN'      EXTASK
     C*    Retrieve current date.
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        EXGDTE
     CSR                 TIME                    EXGTIM
     CSR                 MOVE      #USER         EXGBY
     CSR                 MOVE      '1 '          EXESTA
     CSR                 WRITE     EXREC
     C*
     CSR   ENDEXC        ENDSR
     C*----------------------------------------------------------------
     C*
     C*  ZZINZ    Extra program initialization. Called from *INZSR.
     C*
     CSR   ZZINZ         BEGSR
     CSR                 MOVE      #PROG         $LPRG
     CSR                 MOVE      #PROG         $CVPRG
     CSR                 MOVE      *OFF          FOREVR            1
     C*
     CSR   ITKEY         KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    LQITEM
     C*
     CSR   PARTK2        KLIST
     CSR                 KFLD                    $LORD
     CSR                 KFLD                    $PWHSE
     C*
     CSR   KEYUCI        KLIST
     CSR                 KFLD                    $PWHSE
     CSR                 KFLD                    LQLBL#
     C*
     CSR                 MOVE      '*PICK   '    KYCODE            8
     C*
     C     OPKEY         KLIST
     C                   KFLD                    $PWHSE
     C                   KFLD                    KYCODE
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
500 AC*  ZZLCNS   Get use generic license option
     C*
500 ACSR   ZZLCNS        BEGSR
     C*
500 AC*   Get use generic license option.
500 ACSR                 MOVE      '0'           LCNFLG            1
500 ACSR                 MOVE      '*RCVLBL '    KYCODE
     C*
     CSR   OPKEY         CHAIN     OPTIONS                            79
     CSR   *IN79         IFEQ      *OFF
     CSR   OPPLCN        IFEQ      'Y'
     CSR                 MOVE      '1'           LCNFLG
     CSR                 ENDIF
     CSR                 ENDIF
     C*
     CSR                 ENDSR
     C*
     C*----------------------------------------------------------------
     C*
     C*  ZZULNK   Update for LABELNK FILE
     C*
     CSR   ZZULNK        BEGSR
     C*
     C*
     C*      Write to label link file if Label # was entered.          .
     C*
     CSR   PARTK2        SETLL     LABEL2
     CSR                 MOVE      *OFF          STOP              1
     CSR   STOP          DOUEQ     *ON
     CSR   PARTK2        READE     LABEL2                                 79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *ON           STOP
     CSR                 ELSE
     CSR                 Z-ADD     LQLBL#        LLLBLO
     CSR                 Z-ADD     LBLBL#        LLLBL#
     CSR                 Z-ADD     LBTRN#        LLTRN#
     CSR                 Z-ADD     LBQPCK        LLQPCK
     CSR                 MOVE      LBUCOD        LLUCOD
     CSR                 WRITE     LLREC
     CSR                 ENDIF
     CSR                 ENDDO
     CSR   ENDLNK        ENDSR
     C*
     C*----------------------------------------------------------------
     C*
510a C*  ZZUADJ   Add to UCIADJ file and PUCILOG file....
     C*
510a CSR   ZZUADJ        BEGSR
510a C* Add to UCIADJ
510a C                   CLEAR                   UACREC
510a C                   Z-ADD     $PWHSE        UAWHSE
510a C                   MOVE      UCINBR        UAINBR
510a C                   MOVE      UCIRCD        UARSCD
510a C                   MOVEL     'RN622'       UAAPGM
510a C                   MOVE      'R'           UATYPE
510a C                   MOVE      UCIITM        UAOITM
510a C                   MOVE      UCIITM        UANITM
510e C                   Z-ADD     UCIWGT        UANWGT
510a C                   Z-ADD     ORRDTE        UADATE
510a C                   Z-ADD     ORRTIM        UATIME
510a C                   Z-ADD     0             UAEDAT
510a C                   Z-ADD     0             UAETIM
510a C                   Z-ADD     $LORD         UAPBAT
510a C                   WRITE     UACREC
510a C* Add to PUCILOG
510a C                   CLEAR                   ULREC
510a C                   Z-ADD     $PWHSE        ULWHSE
510a C                   MOVE      UCINBR        ULINBR
510a C                   MOVE      UCIITM        ULIITM
510a C                   Z-ADD     UCIWGT        ULCWGT
510a C                   Z-ADD     ORRDTE        ULADTE
510a C                   Z-ADD     ORRTIM        ULATIM
510a C                   MOVE      #USER         ULUSER
510a C                   MOVE      #JOB          ULJOB
510a C                   MOVE      #JOBN         ULJNBR
510a C                   MOVE      *BLANKS       ULTYPE
510a C                   MOVE      *BLANKS       ULPTYP
510a C                   MOVEL     'RN620'       ULCPGM
510a C                   MOVEL     'RN622'       ULUPGM
510a C                   MOVE      *BLANKS       ULPO
510a C                   Z-ADD     0             ULSEQ#
510a C                   Z-ADD     0             ULPTRN
510a C                   MOVE      *BLANKS       ULLCN#
510a C                   Z-ADD     0             ULORD
510a C                   Z-ADD     0             ULOSEQ
510a C                   Z-ADD     0             ULSTRN
510a C                   Z-ADD     0             ULLBL#
510a C                   MOVE      UCIRCD        ULCODE
510a C                   MOVE      *BLANKS       ULTFLG
510a C                   WRITE     ULREC
510a CSR   ENDADJ        ENDSR
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
