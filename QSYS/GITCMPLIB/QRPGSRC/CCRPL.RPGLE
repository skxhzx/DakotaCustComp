     F*----------------------------------------------------------------
     F*   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*   24 N. Washington Ave Suite 203
     F*   Batavia, IL 60510
     F*   (630) 562-0375
     F*----------------------------------------------------------------
     F*
     F*  CCRPL     Create Replenishments for Container/Cruise
     F*  30 December 2003
     F*  Roxanne Harrison
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
417 AF*    12/30/03  RH   4.17
     F*      - Created.
     F*
417aAF*    01/14/04  DAS  4.17a
     F*      - Revise DRI logic to use DRICOP.
417aAF*    01/15/04  RH   4.17b
     F*      - Revise to use LABEL7 to pass slot to DRICOP for replenishment
500bA*    11/10/04  RH   5.00b
     *      - FIX: End if trans # is zero.
     *      - Only process type 'O' label records.
520aA*    10/23/08  DAS  5.20a
     *      - FIX: Revised to handle breakdown qtys correctly.
530aA*    08/03/10  RH   5.30a
     *      - Enh: Added "client" logic.
610aA*    08/03/10  RH   6.10a
     *      - Enh: Revised to get priority repl seq # passed in from
     *        DRIPRTYRPL. Add $PRSEQ#.
640aA*    09/25/12  RH/MLB  6.40a
     *      - FIX: Revised to base item for type 'S' item to pass to
     *        DRIPRTYRPL, was not creating JIT for 'S' items.
     *
     F*----------------------------------------------------------------
     F*  Client Custom Revisions: Andrews Foodservice
     F*
AFSa *    08/04/10  RH   AFSb
     *      - Enh: Call PFMTTLA with *PRNTJIT to print JIT replen
     *        in place of old letdowns.
     F*
     F*----------------------------------------------------------------
     F*  Notes
     F*
     F*   This program will read thru the labels for a Container/Cruise
     F*   order and call DRIPRTYRPL to create Priority Replenishments.
     F*   Calls DRIPRTYRPL with *CRTRPLSQ7 to create Priority Replenishments
     F*   with seq # of -7 to allow seq# -8 & -9 with higher priority.
     F*
     F*----------------------------------------------------------------
     F*  File Specs
     F*
417b FLabel7    IF   E           K DISK
417b F*abel4    IF   E           K DISK
610b FRtehed    IF   E           K DISK

     D*----------------------------------------------------------------
     D*  Table and array definitions
     D*----------------------------------------------------------------

     D A30             S              1    DIM(30)
     D A50             S              1    DIM(50)
     D MSG             S             50    DIM(5) CTDATA PERRCD(1)

     D*----------------------------------------------------------------
     D*  DRI parameters
     D*----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     D*----------------------------------------------------------------
     D*  Data Formats
     D*----------------------------------------------------------------
520aA /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#PRTYRPL
417aAD savever#        s                   like($prver#)

AFSaA*----------------------------------------------------------------
AFSaA*  Variable
AFSaA*----------------------------------------------------------------
AFSaAD $cwhse          s              3  0
     *----------------------------------------------------------------
530a *  Client id's for custom mods.
     *----------------------------------------------------------------

530aA /copy qcopysrc,id#andrews
530aAD client          s             10
530aAD clientloc       s             10
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
520aAD first           s               n   Inz(*On)
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
500b * End and return if transacton # is zero.                        .
500b C                   if        $ptrn# = 0
500b C                   goto      bottom
500b C                   endif

417bDC*  Read Label4 records.

417bDC*    KeyRte        Setll     Label4
417bDC*    forever       Doweq     forever
417bDC*    KeyRte        ReadE     Label4

417b C*  Read Label7 records.

520aAC                   Eval      first = *on
417b C                   Eval      Doflag = *OFF
520aDC**                 Z-add     0             tlqpck            5 0
520aMC                   Z-add     0             tlqpck1           5 0
520aMC                   Z-add     0             tlqpck2           5 0
520aMC                   Z-add     0             tlqpck3           5 0
417b C     KeyTrn        Setll     Label7
417b C     forever       Doweq     forever
417b C     KeyTrn        ReadE     Label7
     C                   If        %eof
     C                   Leave
     C                   Endif

520aAC                   If        first
520aAC                   exsr      getItem
520aAC                   if        error
520aAC                   leave
520aAC                   endif
520aAC                   endif
520aA
500b *    Only process 'O' label records.
500b C                   if        lbtype <> 'O'
500b C                   iter
500b C                   endif

520aDC**                 Add       Lbqpck        tlqpck
520aAC                   select
520aAC                   when      lbutyp = 'N'
520aAC                   Add       Lbqpck        tlqpck1
520aAC                   when      lbutyp = '1'
520aAC                   Add       Lbqpck        tlqpck2
520aAC                   when      lbutyp = '2'
520aAC                   Add       Lbqpck        tlqpck3
520aAC                   endsl
417b C                   Eval      Doflag = *ON
417b C                   Iter
417bDC*                  exsr      crtprtyrpl

416 AC                   Enddo
416aA
417b C                   If        Doflag = *ON
417b C                   exsr      crtprtyrpl
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

530aA* Get client id

530aAC                   call      'GETCLIENT'
530aAC                   parm                    client
530aAC                   parm                    clientloc

417bDC*  Define partial key for LABEL4 file.

417bDC*    KeyRte        KList
417bDC*                  KFld                    $PPbat
417bDC*                  KFld                    $PWhse
417bDC*                  KFld                    $PRtId

417b C*  Define partial key for LABEL7 file.

417b C     KeyTrn        KList
417b C                   KFld                    $PTrn#
417b C                   KFld                    $PItem

610b C*  Define key for RTEHED file.
610b C     KyRte         KList
610b C                   KFld                    lbwhse
610b C                   KFld                    lbrte


     C*  Get current date.

     C                   Eval      $Cvcmd = '*CURCMD '
     C                   Call      @Cvtdt
     C                   Parm                    $Cvtdt
     C                   Eval      Today = $Cvd8o

     C                   ENDSR

     C*----------------------------------------------------------------

417aA*----------------------------------------------------------------
417aA*  crtprtyrpl  Create priority replenishment for item.
417aA*----------------------------------------------------------------
417aA
417aAC     crtprtyrpl    begsr
520aA
520aA*  First try to "up" the calculated quantities.
520aA
520aA*    Breakdown 3 ...
520aA
520aAC                   if        $itumq3 > 0
520aAC                   dow       tlqpck3 >= $itumq3
520aAC                   eval      tlqpck3 = tlqpck3 - $itumq3
520aAC                   eval      tlqpck2 = tlqpck2 + 1
520aAC                   enddo
520aAC                   endif
520aA
520aA*    Breakdown 2 ...
520aA
520aAC                   if        $itumq2 > 0
520aAC                   dow       tlqpck2 >= $itumq2
520aAC                   eval      tlqpck2 = tlqpck2 - $itumq2
520aAC                   eval      tlqpck1 = tlqpck1 + 1
520aAC                   enddo
520aAC                   endif
520aA
520aA*  If any breakdown qty remains, add 1 case.
520aA
520aAC                   if        tlqpck2 > 0 or tlqpck3 > 0
520aAC                   eval      tlqpck1 += 1
520aAC                   endif
520aA
520aA*  Now call DRIPRTYRPL

     C                   exsr      clr$prtyrpl

     C                   eval      $prwhseu = *on
     C                   eval      $prwhse  = lbwhse

     C                   eval      $pritemu = *on
640aAC                   if        $ittype = 'S'
640aAC                   eval      $pritem  = #bitem
640aAC                   else
     C                   eval      $pritem  = lbitem
640aAC                   endif

     C                   eval      $prwhdpu = *on
     C                   eval      $prwhdp  = lbwhdp

     C                   eval      $prslotu = *on
     C                   eval      $prslot  = lbdisp

     C                   eval      $prqtynu = *on
520aAC                   eval      $prqtyn  = tlqpck1
520aDC**                 eval      $prqtyn  = tlqpck
417bDC*                  eval      $prqtyn  = lbqpck

     C                   eval      $prfillu = *on
     C                   eval      $prfill  = 'Y'
610aAC                   eval      $prseq#u = *on
610aAC                   eval      $prseq#  = 0

     C                   eval      $dricommand = '*PRTYRPL'
     C                   eval      $drisubcmd  = '*CRTRPLSQ7'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     * Call program to print JIT replenishment.                       .
AFSaAC                   if           client = andrews
AFSaAC                                and $prseq# <> 0
AFSaAC     KyRte         chain     rtehed
AFSaAC                   if        %found(rtehed)
AFSaAC                   eval      $crte = rhrte
AFSaAC                   else
AFSaAC                   eval      $crte = *blanks
AFSaAC                   endif
AFSaAC                   eval      $ctrn# = $prseq#
AFSaAC                   eval      $cwhse = lbwhse
AFSaAC                   eval      $crtid = lbrte
AFSaAC                   eval      $cszon = lbwhdp
AFSaAC                   call      'PFMTTLA'
AFSaAC                   parm      '*PRNTJIT'    $ccmd             8
AFSaAC                   parm      'FMTTLA'      $cset             6
AFSaAC                   parm                    $cfmt             8
AFSaAC                   parm                    $cwhse
AFSaAC                   parm                    $crtid            5
AFSaAC                   parm                    $ccomp            1
AFSaAC                   parm                    $ctzon            6
AFSaAC                   parm      1             $cgen             1 0
AFSaAC                   parm                    $cszon            6
AFSaAC                   parm                    $ctruk           10
AFSaAC                   parm                    $crte             5
AFSaAC                   parm                    opdta2          117
AFSaAC                   parm                    $ctrn#            7 0
AFSaAC                   parm      0             $clbl#            7 0
AFSaAC                   parm      0             $cqty             5 0
AFSaAC                   parm      0             $ccwt             7 2
AFSaA*
AFSa C                   endif

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  getbase  Get base item information
640aA*----------------------------------------------------------------

640aAC     getbase       begsr
640a
640a *  Get base item information.
640a
640a C                   call      'GETBASE'
640a C                   parm      $itwhse       $gwhse            3 0
640a C                   parm      $ititem       $gitem           15
640a C                   parm      ' '           #bitem           15
640a C                   parm                    #bityp            1
640a C                   parm                    #bdesc           30
640a C                   parm                    #bpdsc           15
640a C                   parm                    #bwhdp            5
640a C                   parm                    #bstyp            1
640a C                   parm                    #bum              2
640a C                   parm                    #bum2             2
640a C                   parm                    #bumq2            3 0
640a C                   parm                    #bum3             2
640a C                   parm                    #bumq3            3 0
640a C                   parm      ' '           #bcitm           15
640a C                   parm                    #bctyp            1
640a C                   parm                    #bcdsc           30
640a C                   parm                    #bcpds           15
640a C                   parm                    #bcwdp            5
640a C                   parm                    #bcstp            1
640a C                   parm                    #bcum             2
640a C                   parm                    #bcum2            2
640a C                   parm                    #bcuq2            3 0
640a C                   parm                    #bcum3            2
640a C                   parm                    #bcuq3            3 0
640a C                   parm                    #brtn             8
640a
640a *  See if base item was found.
640a
640a C                   if        #brtn = '*ERROR'
640a C                   eval      error = *on
640a C**                 eval      $preturn  = 'BASENOTFND'
640a C**                 exsr      getmsg
640a C**                 exsr      writelog
640a C                   goto      endgetbase
640a C                   endif
640a
640a *  Make sure base item has a brokencase uom.
640a
640a C                   if        #bumq2 <= 0
640a C                   eval      error = *on
640a C**                 eval      $preturn  = 'UM2NOTDEF'
640a C**                 exsr      getmsg
640a C**                 exsr      writelog
640a C                   goto      endgetbase
640a C                   endif
640a
640aAC     endgetbase    endsr
640aA
520aA*----------------------------------------------------------------
520aA*  getItem     Get item information
520aA*----------------------------------------------------------------
520aA
520aAC     getItem       begsr

     C                   exsr      clr$item
     C                   eval      $itwhse  = lbwhse
     C                   eval      $ititem  = lbitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      bottom
     C                   endif

640aAC                   if        $ittype = 'S'
640aAC                             or $ittype = 'A'
640aAC                   exsr      getbase
640aAC                   endif
     C                   endsr

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

520aA*----------------------------------------------------------------
520aA*  clr$item  Clear $item data structure fields
520aA*----------------------------------------------------------------
520aA
520aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$prtyrpl  Clear $prtyrpl data structure fields
     *----------------------------------------------------------------

     C     clr$prtyrpl   begsr
     C                   eval      savever# = $prver#
     C                   clear                   $prtyrpl
     C                   eval      $prver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $dridata = $prtyrpl
520aAC                   when      $dricommand = '*ITEM'
520aAC                   eval      $dridata = $item
520aAC                   eval      $dridata2 = $item2
     C                   endsl

520aAC                   if        $dricommand = '*ITEM'
520aAC                   call(e)   'DRICOP'
520aAC                   parm                    $dricommand
520aAC                   parm                    $drisubcmd
520aAC                   parm                    $drisys2upd
520aAC                   parm      #prog         $driprogram
520aAC                   parm      ' '           $drireturn
520aAC                   parm      ' '           $drimessage
520aAC                   parm                    $dridata
520aAC                   parm                    $dridata2
520aAC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
520aAC                   endif

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C*                  eval      errmsg    = 'Error occured on call to '
     C*                                      + 'DRICOP'
     C*                                      + '/' + %trim($drisubcmd)
     C*                                      + ' from ' + #prog
     C*                  if        zmsflag
     C*                  exsr      zm0105s
     C*                  else
     C*                  exsr      zm0105
     C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
     C*                  exsr      zm0001
     C*                  exsr      zzerrind
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*PRTYRPL'
     C                   eval      $prtyrpl = $dridata
520aAC                   when      $dricommand = '*ITEM'
520aAC                   eval      $item = $dridata
520aAC                   eval      $item2 = $dridata2
     C                   endsl

     C*                  eval      zmsflag = *off
     C     enddricop     endsr

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
