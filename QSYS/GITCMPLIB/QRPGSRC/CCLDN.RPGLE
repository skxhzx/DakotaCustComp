     F*----------------------------------------------------------------
     F*   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   799 Roosevelt Rd.  Bldg 6, Suite 108
     F*   Glen Ellyn, IL  60137
     F*   (630) 790-8383
     F*----------------------------------------------------------------
     F*
     F*  CCLDN     Create JIT Letdowns
     F*  22 September 2004
     F*  Roxanne Harrison
     F*
     F*  Revisions
     F*
417 AF*    09/22/04  RH   4.17
     F*      - Created using CCRPL
500bA*    11/10/04  RH   5.00b
     *      - FIX: End if trans # is zero or SLOT2 not found.
     *      - Only process type 'O' label records.
500cA*    11/11/04  RH   5.00c
     *      - FIX: Add code to calculate breakdown quantity.
500dA*    11/15/04  RH   5.00d
     *      - FIX: Add code, unlock slot file & don't process overflow slot
500eA*    05/04/05  RH   5.00e
     *      - FIX: Add code to set stock1, 2 or 3 to 0 if negative.
     *      - HQ121 changed to allow slot stock to be negative.
     F*
     F*
     F*  CUSTOM
     F*
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*   This program will read thru the labels for a transaction
     F*   item and call OR632 or OR634 to create letdowns.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
417b FLabel7    IF   E           K DISK
417b FPiritem   IF   E           K DISK
417b FSlot2     UF   E           K DISK
417b FPirtran6  IF   E           K DISK

     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*----------------------------------------------------------------

     D A30             S              1    DIM(30)
     D A50             S              1    DIM(50)
     D MSG             S             50    DIM(5) CTDATA PERRCD(1)

     D*----------------------------------------------------------------
     D*  Program parameters
     D*----------------------------------------------------------------

     D $PARMS          DS
     D  $PCMD                  1      8
     D  $PPRG                  9     18
     D  $PUKY                 19     68
     D  $PRTN                 69     76
     D  $PERM                 77    136
     D  $PMSG                 77     80
     D*
     D*   Redefine key
     D*
417b D  $PTRN#                19     25  0
417b D  $PITEM                26     40
417bDD* $PPBAT                19     25  0
417bDD* $PWHSE                26     28  0
417bDD* $PRTID                29     33

      *------------------------------------------------------------------
      * Constants ...
      *------------------------------------------------------------------
     D   Forever       C                   Const('1')

      *------------------------------------------------------------------
      * Misc defs ...
      *------------------------------------------------------------------

     D Error           s               n   Inz(*Off)
     D FlagOp          s              1    Inz(*Off)
     D Doflag          s              1    Inz(*Off)
     D Today           s              8  0

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------
     D @CVTDT          C                   CONST('CVTDTE')

      *----------------------------------------------------------------
      *  Called program parameters
      *----------------------------------------------------------------
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


      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *----------------------------------------------------------------

     D $MDT            DS
     D  ERRMSG                 1     50

     D*----------------------------------------------------------------
     D*  Message control
     D*----------------------------------------------------------------

     D #MSGF           C                   CONST('PIRMSGF   ')
     D*
     D                 DS
     D  #MSGDT                 1    128
     D  $MD                    1    128
     D                                     DIM(128)

     D*----------------------------------------------------------------
     D*  Program info data structure
     D*----------------------------------------------------------------

     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0

     C*----------------------------------------------------------------
     C*  Parameters
     C*----------------------------------------------------------------
     C*
     C*    Input Parameters
     C*      $PCMD
     C*      $PPRG   Program to send messages back to.
     C*      $PUKY   Contains key to process.
     C*
     C*    Returned Parameters
     C*      $MSGK   Message id sent to previous message queue.
     C*      $PRTN   *OK      - No problem encountered.
     C*              *ERROR   - Error occured. Message in $PERM
     C*              *PGMQ    - Error occured. Message sent to pgmq.
     C*      $PERM   Error message or pointer to message in pgmq.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....

     C     *Entry        PList
     C                   PARM                    $Parms

     C                   Eval      $PRtn = '*OK'

     C*----------------------------------------------------------------
     C*  Main line

500b * End and return if transacton # is zero.
500b C                   if        $ptrn# = 0
500b C                   goto      bottom
500b C                   endif
417b C*  Read Label7 records.

417b C                   Eval      Doflag = *OFF
417b C                   Z-add     0             tlqpck            5 0
417b C     KeyTrn        Setll     Label7
417b C     forever       Doweq     forever
417b C     KeyTrn        ReadE     Label7
     C                   If        %eof
     C                   Leave
     C                   Endif

500b * Only process 'O' label records.                                .
500b C                   if        lbtype <> 'O'
500b C                   iter
500b C                   endif

417b C                   Add       Lbqpck        tlqpck
417b C                   Eval      Doflag = *ON
417b C                   Iter

416 AC                   Enddo
416aA
417b C                   If        Doflag = *ON
417b C                   z-add     tlqpck        leftq1            5 0
417b C     KeyIt         chain     piritem                            79
417b C                   If        *in79 = *ON
417b C                   eval      ititem = lbitem
417b C                   endif
417b C     KeySl         chain     slot2                              79
`17b C                   If        *in79 = *ON
417b C                   eval      slitem = lbitem
500b C                   goto      bottom
500d C                   else
500d C                   If        slpick = 'N'
500d C                   unlock    slot2
500d C                   goto      bottom
500d C                   endif
417b C                   endif
417x C                   exsr      availj
     C*     Create letdown if not enough available.
     C*     Loop until pick slot has enough or we are out of reserve stock.
     C     forevr        doune     forevr
500c C*
500c C*      Breakdown carton if necessary.
500c C*
500c C                   select
500c C*
500c C*        Breakdown 1 quantity.
500c C*
500c C                   when      lbutyp = '1'
500c C     tlqpck        dowgt     stock2
500c C     stock1        andgt     0
500c C                   If        itumq2 <= 0
500c C                   leave
500c C                   endif
500c C                   sub       1             stock1
500c C                   add       itumq2        stock2
500c C                   sub       1             slstk1
500c C                   add       itumq2        slstk2
500c C                   enddo
     C*
     C*        Breakdown 2 quantity.
     C*
500c C                   when      lbutyp = '2'
500c C     tlqpck        dowgt     stock3
500c C     stock1        ifle      0
500c C     stock2        andle     0
500c C                   leave
500c C                   endif
500c C                   if        itumq2 <= 0
500c C                             or itumq3 <= 0
500c C                   leave
500c C                   endif
500c C     stock2        ifgt      0
500c C                   sub       1             stock2
500c C                   add       itumq3        stock3
500c C                   sub       1             slstk2
500c C                   add       itumq3        slstk3
500c C                   else
500c C                   sub       1             stock1
500c C                   add       itumq2        stock2
500c C                   sub       1             slstk1
500c C                   add       itumq2        slstk2
     C*
500c C                   sub       1             stock2
500c C                   add       itumq3        stock3
500c C                   sub       1             slstk2
500c C                   add       itumq3        slstk3
500c C                   endif
     C*
500c C                   enddo
     C*
500c C                   endsl
     C*
500e C* Set stock to 0 if negative to prevent extra replenishments
500e C* from being created when slot stock is negative.
500e C     stock1        Iflt      0
500e C                   z-add     0             stock1
500e C                   endif
500e C     stock2        Iflt      0
500e C                   z-add     0             stock2
500e C                   endif
500e C     stock3        Iflt      0
500e C                   z-add     0             stock3
500e C                   endif
     C*
417b C     lbutyp        Ifeq      'N'
417b C     tlqpck        andle     stock1
417b C     lbutyp        oreq      '1'
417b C     tlqpck        andle     stock2
417b C     lbutyp        oreq      '2'
417b C     tlqpck        andle     stock3
417b C                   leave
417b C                   endif
417b C                   eval      $lwhse = lbwhse
417x C                   eval      $lwhdp = lbwhdp
417x C                   eval      $ltail = lbaisl
417x C                   eval      $ltdis = lbdisp
417x C*                  eval      $lwhdp = slwhdp
417x C*                  eval      $ltail = slaisl
417x C*                  eval      $ltdis = sldisp
417b C                   If        ittype = 'C'
417b C                   eval      $litem = lbitem
417b C***                eval      $litem = oditem
417b C                   else
417b C                   eval      $litem = slitem
417b C                   endif
417b C                   eval      $lqty  = leftq1
417b C                   eval      $lqtyb = leftq1
417b C                   eval      $lsdef = slsdef
417b C                   eval      $lloc  = slloc
417b C                   eval      $lrlvl = slrlvl
417b C                   eval      $lhand = slhand
417b C                   eval      $lstyp = slstyp
417b C                   eval      $ltype = ittype
417b C                   eval      $lavl1 = 0
417b C                   eval      $lavl2 = 0
417b C                   eval      $lavl3 = 0
417b C                   eval      $lrtn  = *blanks
417b C                   eval      $lrtid = lbrte
417b C                   eval      $lbat  = lbpbat
417b C                   If        ittype = ' '
417b C                   call      'OR632'
417b C                   parm                    $lbat
417b C                   parm                    $lwhse
417b C                   parm                    $lrtid
417b C                   parm                    $litem
417b C                   parm                    itum1
417b C                   parm                    itcube
417b C                   parm                    itswgt
417b C                   parm                    lbtrn#
417b C                   parm                    lbpal#
417b C                   parm                    $lwhdp
417b C                   parm                    $ltail
417b C                   parm                    $lloc
417b C                   parm                    $lrlvl
417b C                   parm                    $lhand
417b C                   parm                    $ltdis
417b C                   parm      0             $lqty             7 0
417b C                   parm                    $lentd            8 0
417b C                   parm                    $lexpd            8 0
417b C                   parm                    $lrtn
     C*   If nothing was replenished then get out of loop.
417b C                   If        $lqty = 0
417b C                   leave
417b C                   endif
417b C                   z-add     $lqty         slqty
417b C                   else
417b C                   call      'OR634'
417b C                   parm                    $lwhse            3 0
417b C                   parm                    $lwhdp
417b C                   parm                    $lrtid
417b C                   parm                    $lbat
417b C                   parm                    $ltail            3
417b C                   parm                    $ltdis           12
417b C                   parm                    $litem           15
417b C                   parm                    $lqtyb            3 0
417b C                   parm                    $lsdef            2
417b C                   parm                    $lloc             3 0
417b C                   parm                    $lrlvl            2 0
417b C                   parm                    $lhand            2
417b C                   parm                    $lstyp            1
417b C                   parm                    $ltype            1
417b C                   parm                    $lavl1            3 0
417b C                   parm                    $lavl2            3 0
417b C                   parm                    $lavl3            3 0
417b C                   parm                    $lrtn             8
417b C                   If        $lqtyb = 0
417b C                   leave
417b C                   endif
417b C                   z-add     $lqtyb        slqty             7 0
417b C                   Endif
     C*      Otherwise, update stock qty and repeat loop.
417b C                   add       slqty         stock1
417b C                   add       slqty         slrcv1
417b C                   z-add     $lentd        slentd
417b C                   z-add     $lexpd        slexpd
417b C                   Enddo
417b C                   update    slrec
417b C                   Endif

     C     Bottom        Tag

     C                   Eval      *INLR = *On

     C*----------------------------------------------------------------
     C*          SUBROUTINES IN ALPHABETICAL ORDER
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  *INZSR  Initialization subrotine
     C*----------------------------------------------------------------

     C     *INZSR        BEGSR


417bDC*  Define partial key for LABEL4 file.

417bDC*    KeyRte        KList
417bDC*                  KFld                    $PPbat
417bDC*                  KFld                    $PWhse
417bDC*                  KFld                    $PRtId

417b C*  Define partial key for LABEL7 file.

417b C     KeyTrn        KList
417b C                   KFld                    $PTrn#
417b C                   KFld                    $PItem
417b C*  Define partial key for LABEL7 file.

417b C     KeyLbl        KList
417b C                   KFld                    PTtrn#
417b C                   KFld                    $PItem
417b C*  Define partial key for PIRTRAN6 file.

417b C     KeyPck        KList
417b C                   KFld                    KyWhse
417b C                   KFld                    KyGrp1
417b C*                  KFld                    KyGrp2

417b C*  Define key for SLOT2 file.

417b C     KeySl         KList
417b C                   KFld                    LBwhse
417b C                   KFld                    LBwhdp
417b C                   KFld                    LBdisp

417b C*  Define key for PIRITEM file.

417b C     KeyIt         KList
417b C                   KFld                    LBwhse
417b C                   KFld                    LBitem

     C     *like         define    lbrte         $lrtid
     C     *like         define    itwhdp        $lwhdp
     C     *like         define    lbpbat        $lbat
     C     *like         define    ptgrp1        KyGrp1
     C     *like         define    ptgrp2        KyGrp2
     C     *like         define    lbwhse        KyWhse
     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o
     CSR                 move      *OFF          forevr            1

     C                   ENDSR

     C*----------------------------------------------------------------
     C*
     C*  AVAILJ  Calculate available quantities for slot for JIT
     C*
417aAC     availj        begsr
CBIj C*  Total pick quantity for started or ended trans.
CBIj C*  Calculate stock quantity without pick quantity.
     C                   z-add     0             stock1            5 0
     C                   z-add     0             stock2            3 0
     C                   z-add     0             stock3            3 0
     C                   z-add     0             tlpck1            5 0
     C                   z-add     0             tlpck2            3 0
     C                   z-add     0             tlpck3            3 0
     C                   z-add     0             avail1            5 0
     C                   z-add     0             avail2            3 0
     C                   z-add     0             avail3            3 0
     C     slstk1        add       slrcv1        stock1
     C     slstk2        add       slrcv2        stock2
     C     slstk3        add       slrcv3        stock3
CBIj C*  Calculate pick quantity using started and ended transactions.
     C                   eval      KyGrp1 = 'S'
     C                   eval      KyWhse = lbwhse
CBI MC     KeyPck        setll     pirtran6
     C     forevr        doweq     forevr
CBI MC     KeyPck        reade     pirtran6                               78
CBI MC     *in78         ifeq      *on
CBI MC                   leave
CBI MC                   endif
CBI MC     ptstat        ifeq      '1'
CBI MC                   iter
CBI MC                   endif
CBI MC     KeyLbl        setll     label7
     C     forevr        doweq     forevr
CBI MC     KeyLbl        reade     label7                                 77
CBI MC     *in77         ifeq      *on
CBI MC                   leave
CBI MC                   endif
     C                   select
CBI MC                   when      lbutyp = 'N'
     C                   add       lbqpck        tlpck1
CBI MC                   when      lbutyp = '1'
     C                   add       lbqpck        tlpck2
CBI MC                   when      lbutyp = '2'
     C                   add       lbqpck        tlpck3
     C                   endsl
CBI MC                   iter
CBI MC                   enddo
     C**
CBI MC                   iter
CBI MC                   enddo
     C     stock1        sub       tlpck1        avail1
     C     stock2        sub       tlpck2        avail2
     C     stock3        sub       tlpck3        avail3
     C**
     C     avail1        iflt      0
     C                   z-add     0             avail1
     C                   endif
     C     avail2        iflt      0
     C                   z-add     0             avail2
     C                   endif
     C     avail3        iflt      0
     C                   z-add     0             avail3
     C                   endif
     C                   ENDSR

     C*----------------------------------------------------------------
     C*  SUBROUTINE ZMxxxx  Control message display subfile
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*    ZMSMSG  Send program message to a different program msgq
     C*----------------------------------------------------------------

     CSR   ZMSMSG        BEGSR
     CSR   $MSGF         IFEQ      *BLANKS
     CSR                 MOVE      #MSGF         $MSGF            10
     CSR                 END
     CSR                 CALL      'PUTMSGP'
     CSR                 PARM                    $MSGF
     CSR                 PARM                    #MSGID            7
     CSR                 PARM                    #MSGTP            7
     CSR                 PARM                    #MSGDT
     CSR                 PARM      #PROG         #PGMQ2           10
     CSR                 PARM                    #MSGK             4
     CSR                 MOVE      *BLANKS       #MSGDT
     CSR                 MOVE      *BLANKS       $MSGF
     CSR                 ENDSR

     C*----------------------------------------------------------------
     C*    ZMnnnn  Build and send message nnnn to this program
     C*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*      0105
     C*----------------------------------------------------------------

     CSR   ZM0105        BEGSR
     CSR                 MOVE      'PIR0105'     #MSGID
     CSR                 MOVE      '*DIAG  '     #MSGTP
     CSR                 MOVEA     ERRMSG        $MD(1)
     CSR                 EXSR      ZMSMSG
     CSR                 MOVE      #MSGK         $PMSG
     CSR                 MOVEL(P)  '*PGMQ'       $PRTN
     CSR                 ENDSR

417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------
417aA*                     DRI SUBROUTINES
417aA*----------------------------------------------------------------
417aA*----------------------------------------------------------------

     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
     O*----------------------------------------------------------------

**  MSG - Error Messages
Route xxxxx does not exist
Route xxxxx locked by another program
Route xxxxx is not at Built, Allocated or Picked Status
Out Lbl Undo R:99999 L:9999999
Route xxxxx reversed successfully
