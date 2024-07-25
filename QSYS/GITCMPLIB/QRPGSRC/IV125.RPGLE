     F*----------------------------------------------------------------
     F*   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     F*   West Chicago, IL  60185
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  IV125     Print inventory sheets - Print
     F*  31 January 1996
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*  Revisions:
408 AF*    01/12/97  RH    4.08
     F*      - Added TIME to time stamp printed inventory sheets.
409 AF*    07/14/98  RH    4.09
     F*      - Print 'Cont. on next page' at bottom of page if hand
     F*        stack or virtual slots are continued from one page to
     F*        the next.  IVPMOR=*ON
414aAF*    05/11/00  RH    4.14
     F*      - Re-compiled, INVSLOT file changed.
416 AF*  09/25/01  RH   4.16
     F*    - Recompile - INVSLOT file changed.
416bAF*  11/06/01  RH   4.16b
     F*    - Print entered quantities on detail line.
500aAF*    04/16/04  MLB  500a
     F*      - Converted pgm source to ILE to support this mod.
     F*      - Added item UPC code to report. Added file UPC to pgm.
500bAF*    09/10/04  RH   500b
     F*      - Add tie high to report, added ITEMDEF & SLOT2 files
510aAF*    08/24/06  RH   510a
     F*      - Enh: Add COLUMN2 and DETAIL2 to increase item & desc
510bAF*    08/24/06  RH   5.10b
     F*      - Enh: Added client code.
510cAF*    09/12/06  RH   5.10c
     F*      - Fix: Change to clear fields, can not clear record
     F*        if file is input only.  UPC was being left & printed.
530aAF*    12/17/09  GJA  5.30a
     F*      - Enh: Add slot quantity to sheet when *IN95 is set on
530b F*    11/18/10  GJA  5.30b
     F*      - Fix: Clear W1QTY when no item found
650a F*    01/12/15  GJA  6.50a
     F*      - Enh: Print MFG Code instead of UPC
700a F*    06/18/16  RH   7.00a
     F*      - Fix: Add Detail8 to print item 8 long.
700b F*    12/01/16  RH   7.00b
     F*      - ENH: Add License for overflow to Detail8, replace UPC.
700c F*    12/02/16  RH   7.00c
     F*      - ENH: Create Detail9 to print original Detail1 with UPC
     F*        Change Detail1 to print License, replace UPC.
     F*
700d *    11/03/16  LMC  7.00d
     *      - Enh: UPC file has a database change. Recompile only.
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:  Presto
PFCa F*    01/12/15  GJA  PFCa
     F*      - Add Client code and print mfg code instead of UPC
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
vip AF*    09/18/06  JCJ  VIP A
     F*      - Enh: For VIP print "NA" for Level
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Springfield
SGCa F*    12/17/09  GJA  SGCa
     F*      - Enh: Set on *IN95 so slot quantity will print
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Glazier
GFCa F*    12/17/09  GJA  GFCa
     F*      - Enh: Set on *IN95 so slot quantity will print
     F*----------------------------------------------------------------
     F*  Client Custom Revisions:
CDIaAF*    06/18/16  RH   CDI A
     F*      - Enh: Print using detail8, item 8 long
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADF A*    05/14/18  LMC  ADF
     *      - Enh: Print using detaial8, item 8 long.
     *
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
     FINVSLOT1  UP   E           K DISK
     FINVPAGE   UF   E           K DISK
     FWAREHS    IF   E           K DISK
     FWHDEPT    IF   E           K DISK
     FPIRITEM   UF   E           K DISK
500aAFUPC1      IF   E           K DISK
500bAFSLOT2     IF   E           K DISK
500bAFITEMDEF   IF   E           K DISK
510aAFITEMDSC   IF   E           K DISK
510aAFOPTIONS   IF   E           K DISK
700bAFLICACTIVE1IF   E           K DISK
     FIV125PR   O    E             PRINTER OFLIND(*IN90)
     F                                     USROPN
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
510bAD @getcl          c                   const('GETCLIENT')
510bAD*
510bA /COPY QCOPYSRC,ID#PACKERS
VIP A /COPY QCOPYSRC,ID#VIP
SGCaA /COPY QCOPYSRC,ID#SGC
GFCaA /COPY QCOPYSRC,ID#GLAZIER
PFCaA /COPY QCOPYSRC,ID#PFC
CDIaA /COPY QCOPYSRC,ID#CDI
ADF A /copy qcopysrc,id#adf
     D*----------------------------------------------------------------
     D*
     D*  Table and array
     D*
     D A80             S              1    DIM(80)
     D OVRPRT          S             80    DIM(1) CTDATA PERRCD(1)
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
     D                 DS
     D  UPVEN                  1     11  0
     D  ITVEN#                 2     11  0
510a D*----------------------------------------------------------------
510a D*  OPTIONS data structure
510a D OPDATA          DS
510a D  OPSTYP                 1      1
510a D  OPWHDP                 2      6
510a D  OPUM1                  7      8
510a D  OPDUM                  9     23
510a D  OPCUM                 24     43
510a D  OPCDIV                44     52  2
510a D  OPCAUT                53     53
510a D  OPCWRN                54     54
510a D  OPCRNG                55     57  1
510a D  OPWUM                 58     72
510a D  OPXDSC                73     73
510a D  OPTEND               117    117
     D*
     D*----------------------------------------------------------------
     D*  Data structure for error message parameters
     D*
     D $MDT            DS
     D  ERRMSG                 1     50
     D  ERCNT                  1      3P 0
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
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     I*----------------------------------------------------------------
     I*  Input record
     I*
     IIVSREC
     I                                          IVSWHS        L1
     I                                          IVSPAG        L1
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PRPRT            1
     C*----------------------------------------------------------------
     C*  Main Line
     C*
     C*  Start new page if one of following happened.
     C*     - Level break.
     C*
     C     *INL1         IFEQ      *ON
408 AC                   TIME                    TIME
     C                   EXSR      OPNPRT
     C                   EXSR      ZRHEAD
     C                   MOVE      IVSWHS        LSTWHS
     C                   MOVE      IVSWHD        LSTWHD
     C                   ADD       1             COUNT             5 0
     C                   ENDIF
510a C*  Get extended description option.
510a C     UXFLAG        IFEQ      'X'
510a C                   EXSR      ZZXOPT
510a C                   ENDIF
     C*
     C*  Get item information.
     C*
     C     ivsitm        ifeq      *BLANKS
     C                   clear                   itrec
510cMC                   clear                   ixdsc1
510cMC                   clear                   ixdsc2
510cMC                   clear                   upupc
500bAC                   eval      w1ti = 0
500bAC                   eval      w1hi = 0
530bAC                   eval      w1qty= *blanks
530bAC                   eval      w1tihi=*blanks
     C                   else
     C     keyit         chain(n)  PIRITEM                            79
     C     *IN79         ifeq      *ON
     C                   clear                   ITREC
     C                   endif
510a C     uxflag        ifeq      '1'
510a C     keyit         chain     itemdsc                            76
510a C     *IN76         ifeq      *ON
510cDC*                  CLEAR                   IXREC
510cMC                   clear                   IXDSC1
510cMC                   clear                   IXDSC2
510a C                   endif
510a C                   endif
500bAC*  Get Tie Hi information.
500bAC*  Get slot definition.
500bAC                   eval      w1ti = 0
500bAC                   eval      w1hi = 0
530aAC                   eval      w1qty= *blanks
530aAC*                  eval      w1tihi=*blanks
500bAC     keysl         chain     slot2                              77
500bAC     *IN77         ifeq      *OFF
500bAC     keyid         chain     itemdef                            78
500bAC     *IN78         ifeq      *OFF
530aAC                   eval      $cstr = *blanks
530aAC                   move      idtie         $cstr
530aAC                   call      'ADJUST'
530aAC                   parm      '*LEFT   '    $ccmd             8
530aAC                   parm                    $cstr            30
530aAC                   movel     $cstr         w1tia             3
530aAC*    w1tia         cat       'x':1         w1tihi
530aAC                   eval      $cstr = *blanks
530aAC                   move      idhigh        $cstr
530aAC                   call      'ADJUST'
530aAC                   parm      '*LEFT   '    $ccmd             8
530aAC                   parm                    $cstr            30
530aAC                   movel     $cstr         w1hia             2
530aAC*    w1tihi        cat       w1hia:1       w1tihi
530aAC                   eval      w1tihi = %trim(w1tia) + 'x'
530aAC                             + %trim(w1hia)
530aAC                   endif
530aAC                   eval      $pcmd = '*QTY2STR'
530aAC                   eval      $pqty1 = slstk1
530aAC                   eval      $pqty2 = slstk2
530aAC                   eval      $pqty3 = slstk3
530aAC                   eval      $pqstr = *blanks
     *
530aAC                   call      'CVTQTY'
530aAC                   parm                    $pcmd
530aAC                   parm                    $pprg
530aAC                   parm                    $pqty1            7 0
530aAC                   parm                    $pqty2            7 0
530aAC                   parm                    $pqty3            7 0
530aAC                   parm                    $pum1             2
530aAC                   parm                    $pum2             2
530aAC                   parm                    $pum3             2
530aAC                   parm                    $pqstr           10
530aAC                   parm                    $pustr           17
530aAC                   parm                    $prtn
530aAC                   parm                    $perm
     *
530aAC                   eval      w1qty = $pqstr
500bAC                   ENDIF
500aAC*
500aAC*  Retrieve UPC code for item.
500aAC*
500aAC*  Try to find UPC code for item/vendor.
500aAC     FIKEY         CHAIN     UPC1                               77
500aAC     *IN77         IFEQ      *ON
500aAC*  Try to find UPC code for item.
500aAC     PRTKEY        SETLL     UPC1
500aAC     PRTKEY        READE     UPC1                                   77
500aAC     *IN77         IFEQ      *ON
510cDC*                  CLEAR                   UPREC
510cMC                   CLEAR                   upupc
500aAC                   ENDIF
500aAC                   ENDIF
     C                   ENDIF
     C*
700bAC*  Get License if not pick slot
700bAC                   eval      w1lcns = *blanks
700bAC                   if        ivspck = 'N'
700bAC     keylcns       chain     licactive1                         79
700bAC                   if        *in79 = *off
700bAC                   eval      w1lcns = lalcns
700bAC                   else
700bAC                   eval      w1lcns = *blanks
700bAC                   endif
700bAC                   endif
     C*
     C*  Print detail line.
     C*
500aAC*  Move file fields into shorter report print fields.
500aAC                   MOVEL     IVSITM        W1ITEM
510aAC                   MOVEL     IVSITM        W1ITM2
700aAC                   MOVEL     IVSITM        W1ITM8
500aAC                   MOVEL     ITDESC        W1DESC
700aAC                   MOVEL     ITDESC        W1DES8
500aAC                   MOVEL     ITPDSC        W1PDSC
500aAC                   MOVEL     UPUPC         W1UPC
650aAC                   MOVEL     ITVIT#        W1VIT#
510a C     uxflag        ifeq      '1'
510aAC                   movel     IXDSC1        W1DSC2
510aAC                   move      IXDSC2        W1DSC2
510a C                   else
510aAC                   movel     ITDESC        W1DSC2
510a C                   endif
500aAC*
     C     ivsitm        ifeq      *blanks
     C                   MOVE      *ON           *IN55
     C                   ELSE
     C                   MOVE      *OFF          *IN55
     C                   ENDIF
     C                   MOVE      IVSDSP        W1SDSP           12
416bAC                   Z-ADD     IVSQT1        W1SQT1
416bAC                   Z-ADD     IVSQT2        W1SQT2
416bAC                   Z-ADD     IVSQT3        W1SQT3
530aAC                   select
PFCaAC                   when      Client = presto
PFCaAC                   WRITE     DETAIL4
PAKaAC                   when      Client = packers
PAKa C                   WRITE     DETAIL2
530aAC                   when      client = SGC
GFCaAC                             or client = glazier
530aAC                   WRITE     DETAIL3
CDIaAC                   when      Client = CDI
CDIa C                   WRITE     DETAIL8
ADF AC                   when      Client = AANDDFOODS
ADF  C                   WRITE     DETAIL8
530aAC                   other
     C                   WRITE     DETAIL1
530aAC                   endsl
PAKa C******             endif
     C*  Clear total field
530aAC                   move      *blanks       w1qty
530aAC                   move      *blanks       w1tihi
     C*
     C*  Update record with date.
     C*
     C                   Z-ADD     TODAY         IVSPDT
     C                   TIME                    IVSPTM
     C                   UPDATE    IVSREC
     C*
     C*  Write footer and update page file.
     C*
     CL1   OPENED        IFEQ      *ON
409 DC*1                   WRITEFOOT1
     CL1   KEYIVP        CHAIN     INVPAGE                            79
     CL1   *IN79         IFEQ      *OFF
     CL1                 Z-ADD     TODAY         IVPPDT
     CL1                 TIME                    IVPPTM
     CL1                 MOVE      'P'           IVPSTA
     CL1                 UPDATE    IVPREC
     CL1                 ENDIF
409 ACL1   IVPMOR        IFEQ      *ON
409 ACL1                 MOVE      *ON           *IN25
409 ACL1                 ENDIF
409 MCL1                 WRITE     FOOT1
409 ACL1                 MOVE      *OFF          *IN25
     CL1                 ENDIF
     C*
     C*  Send message back to user on how many sheets were printed.
     C*
     CLR                 Z-ADD     COUNT         ERCNT
     CLR                 EXSR      ZM21
     C*----------------------------------------------------------------
     C*
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*
     C*----------------------------------------------------------------
     C*
     C*  *INZSR  Initialization subrotine
     C*
     CSR   *INZSR        BEGSR
510bA*
510bA* Get client id.
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bA*
     C*
     C*  Define keys
     C*
     C*    File INVPAGE
     C*
     CSR   KEYIVP        KLIST
     CSR                 KFLD                    IVSWHS
     CSR                 KFLD                    IVSPAG
510a C*
510a C*    File OPTIONS
510a C*
510a CSR   OPKEY         KLIST
510a CSR                 KFLD                    IVSWHS
510a CSR                 KFLD                    OCODE
     C*
     C*    File PIRITEM
     C*
     CSR   KEYIT         KLIST
     CSR                 KFLD                    IVSWHS
     CSR                 KFLD                    IVSITM
     C*
     C*    File WHDEPT
     C*
     CSR   KEYWD         KLIST
     CSR                 KFLD                    IVSWHS
     CSR                 KFLD                    IVSWHD
700bAC*
700bAC*    File LICACTIVE1
700bAC*
700bAC     keylcns       klist
700bAC                   kfld                    ivswhs
700bAC                   kfld                    ivswhd
700bAC                   kfld                    ivsdsp
500b C*
500b C*    File SLOT2
500b C*
500b CSR   KEYSL         KLIST
500b CSR                 KFLD                    IVSWHS
500b CSR                 KFLD                    IVSWHD
500b CSR                 KFLD                    IVSDSP
500b C*
500b C*    File ITEMDEF
500b C*
500b CSR   KEYID         KLIST
500b CSR                 KFLD                    IVSWHS
500b CSR                 KFLD                    IVSITM
500b CSR                 KFLD                    SLSDEF
500aAC*
500aAC*    File UPC
500aAC*
500aACSR   *LIKE         DEFINE    ITITEM        KYITMN
500aACSR   FIKEY         KLIST
500aACSR                 KFLD                    IVSWHS
500aACSR                 KFLD                    IVSITM
500aACSR                 KFLD                    UPVEN
500aAC*
500aAC*    File UPC
500aAC*
500aACSR   PRTKEY        KLIST
500aACSR                 KFLD                    IVSWHS
500aACSR                 KFLD                    IVSITM
     C*
     C*  Define variables
     C*
     CSR   *LIKE         DEFINE    IVSWHS        LSTWHS
     CSR   *LIKE         DEFINE    IVSWHD        LSTWHD
     CSR   *LIKE         DEFINE    $DEV          LSTDEV
     CSR   *LIKE         DEFINE    $FORM         LSTFRM
     C*
500bAC                   z-add     0             w1ti              4 0
500bAC                   z-add     0             w1hi              2 0
     C*  Get report heading.
     C*
     CSR                 EXSR      ZRFRMT
     C*
     C*  Convert today's date into century format.
     C*
     CSR                 MOVE      '*CURCMD '    $CVCMD
     CSR                 CALL      @CVTDT
     CSR                 PARM                    $CVTDT
     CSR                 Z-ADD     $CVD8O        TODAY             8 0
     C*
     C*   Clear previous program's message queue.
     C*
     CSR                 MOVE      '*CLEAR '     #MSGID            7
     CSR                 MOVE      '*NULL  '     #MSGTP            7
     CSR                 EXSR      ZMSMSG
510a C*
510a C*  Initialize uxflag to only get extended item desc option once.
510a C*
510aACSR                 MOVE      'X'           uxflag
     C*
     C*  Dummy update for compiler.
     C*
     CSR   0             IFNE      0
     CSR                 UPDATE    ITREC
     CSR                 ENDIF
     C*
SGCaAC                   if        Client = sgc
GFCaAC                              or Client = glazier
SGCaAC                   eval      *in95 = *on
SGCaAC                   else
SGCaAC                   eval      *in95 = *off
SGCaAC                   endif
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C*  OPNPRT  Open printer file.
     C*
     CSR   OPNPRT        BEGSR
     C*
     C*   Get device and form type for department.
     C*
     CSR   IVSWHD        IFNE      LSTWHD
     CSR                 CALL      'GETRPT'
     CSR                 PARM      '*DEVFORM'    $CMD              8
     CSR                 PARM      'IV125PR'     $LRPT            10
     CSR                 PARM      IVSWHS        $WHSE             3 0
     CSR                 PARM      IVSSTP        $STYP             1
     CSR                 PARM      IVSWHD        $WHDP             5
     CSR                 PARM                    $DESC            50
     CSR                 PARM                    $DEV             10
     CSR                 PARM                    $FORM            10
     CSR                 ENDIF
     C*
     C*   Open printer file for department.
     C*
     CSR   OPENED        IFNE      *ON
     CSR   $DEV          ORNE      LSTDEV
     CSR   $FORM         ORNE      LSTFRM
     C*
     C*      If printer already open then close it.
     C*
     CSR   OPENED        IFEQ      *ON
     CSR                 CLOSE     IV125PR
     CSR                 ENDIF
     C*
     C*      Override printer file.
     C*
     C*          OVRPRTF FILE(IV125PR) OUTQ(*DEV) DEV($dev)
     C*                  FORMTYPE($form)
     C*
     CSR                 MOVEA     OVRPRT(1)     A80
     CSR                 MOVEA     $DEV          A80(38)
     CSR                 MOVEA     $FORM         A80(59)
     CSR                 MOVEA     A80           QCMD
     C*
     CSR                 CALL      'QCMDEXC'
     CSR                 PARM                    QCMD             80
     CSR                 PARM      80            QLEN             15 5
     C*
     C*      Open printer file.
     C*
     CSR                 OPEN      IV125PR
     CSR                 MOVE      *ON           OPENED            1
     CSR                 MOVE      $DEV          LSTDEV
     CSR                 MOVE      $FORM         LSTFRM
     C*
     CSR                 ENDIF
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRFRMT        BEGSR
     C*
     C*   Format report title.
     C*
     C*  Get report title.
     C*
     CSR   $PRPRT        IFEQ      'Y'
     CSR                 MOVE      'REPRINT'     RPRT
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       RPRT
     CSR                 ENDIF
     C*
     CSR                 CALL      'GETRPT'
     CSR                 PARM      '*DESC  '     $CMD              8
     CSR                 PARM      'IV125PR'     $LRPT            10
     CSR                 PARM      0             $WHSE             3 0
     CSR                 PARM      ' '           $STYP             1
     CSR                 PARM      ' '           $WHDP             5
     CSR                 PARM                    $DESC            50
     CSR                 PARM                    $DEV             10
     CSR                 PARM                    $FORM            10
     C*
     C*   Center report title.
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM      $DESC         $PSTR            60
     CSR                 PARM      40            $PLEN             3 0
     CSR                 MOVEL     $PSTR         RPTTTL
     C*
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*
     C     ZRHEAD        BEGSR
     C*
     C*   Get warehouse description.
     C*
     CSR   IVSWHS        IFNE      LSTWHS
     CSR                 MOVE      *BLANKS       W1WHSE
     CSR                 MOVE      *BLANKS       $PSTR
     CSR   IVSWHS        CHAIN     WAREHS                             79
     CSR   *IN79         IFEQ      *OFF
     CSR                 MOVEL     WHDESC        $PSTR            60
     CSR                 ELSE
     CSR                 MOVE      *BLANKS       $PSTR
     CSR                 ENDIF
     CSR                 Z-ADD     30            $PLEN             3 0
     C*
     C*   Center warehouse description.
     C*
     CSR                 CALL      'CENTER'
     CSR                 PARM                    $PSTR
     CSR                 PARM                    $PLEN
     CSR                 MOVEL     $PSTR         W1WHSE
     C*
     CSR                 ENDIF
     C*
     C*   Get warehouse department description.
     C*
     CSR   IVSWHD        IFNE      LSTWHD
     CSR                 MOVE      *BLANKS       W1WHDP
     CSR                 MOVE      *BLANKS       $PSTR
     CSR   KEYWD         CHAIN     WHDEPT                             79
     CSR   *IN79         IFEQ      *ON
     CSR                 MOVE      *BLANKS       WDDESC
     CSR                 ENDIF
     CSR   IVSWHD        CAT       '-':1         W1WHDP
     CSR   W1WHDP        CAT       WDDESC:1      W1WHDP
     CSR                 ENDIF
     C*
     C*   Convert section into a word.
     C*
     CSR   IVSSTP        IFEQ      'P'
     CSR                 MOVE      'PIR  '       W1STYP
     CSR                 ELSE
     CSR                 MOVE      'Fixed'       W1STYP
     CSR                 ENDIF
     C*
     C*   Convert side into a word.
     C*
     CSR   IVSSID        IFEQ      0
     CSR                 MOVE      'Even'        W1SIDE
     CSR                 ELSE
     CSR                 MOVE      'Odd '        W1SIDE
     CSR                 ENDIF
     C*
VIP AC                   if        client = vip
VIP AC                   eval      w1slvl = 'NA'
VIP AC                   else
VIP AC                   move      ivslvl        w1slvl
VIP AC                   endif
VIP AC*
     CSR                 WRITE     HEAD1
530aAC                   select
PAKaAC                   when      Client = packers
PAKa CSR                 WRITE     COLUMN2
PFCaAC                   when      Client = presto
PFCaAC                   WRITE     COLUMN4
PAKa C******             else
530aAC                   when      Client = sgc
GFCaAC                             or client = glazier
530aACSR                 WRITE     COLUMN3
CDIaAC                   when      Client = CDI
CDIaACSR                 write     COLUMN8
ADF AC                   when      Client = AANDDFOODS
ADF ACSR                 write     COLUMN8
530aACSR                 other
     CSR                 WRITE     COLUMNS
530aACSR                 endsl
PAKa C*****              endif
     C*
     CSR                 ENDSR
     C*---------------------------------------------------------------
     C*
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*
     C*    ZMSMSG  Send program message to a previous program msgq
     C*
     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSGP'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID
     CSR                 PARM                    #MSGTP
     CSR                 PARM                    #MSGDT
     CSR                 PARM      #PROG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR
     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------
     C*     IV12521  Number of sheets printed.
     C*
     CSR   ZM21          BEGSR
     CSR                 MOVE      'IV12521'     #MSGID
     CSR                 MOVE      '*COMP  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 ENDSR
510a C*----------------------------------------------------------------
510a C*
510aAC*  ZZXOPT   Get use extended description option
510a C*
510aACSR   ZZXOPT        BEGSR
     C*
510aAC*   Get extended description option.
510aACSR                 MOVE      '0'           uxflag            1
510aACSR                 MOVE      '*ITEMMNT'    ocode             8
     C*
510aACSR   OPKEY         CHAIN     OPTIONS                            79
510aACSR   *IN79         IFEQ      *OFF
510aACSR   OPXDSC        IFEQ      'Y'
510aACSR                 MOVE      '1'           uxflag
510aACSR                 ENDIF
510aACSR                 ENDIF
     C*
510aACSR                 ENDSR
     C*
      *----------------------------------------------------------------
      *
      * Compile time tables
      *
**   OVRPRTF statment
OVRPRTF FILE(IV125PR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
