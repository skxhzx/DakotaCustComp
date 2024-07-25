650aA /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  PCK224    Create random test orders for warehouse 900 - WORKLBL
     *  29 July 1997
     *  Dave Sommerville
     *
     *  Revisions
     *
650aA*    10/28/13  DAS  6.50a
     *      - Converted to ILE
     *      - Added warehouse option
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    - The screen for this program must be compiled with
     *      defer write equal to *NO.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpck224fm  cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot3     if   e           k disk
     Fpiritem   if   e           k disk
     Fworklbl1  uf a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $pmsg           s              4
     D $pprg           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D dummy           s              1
     D error           s              1
     D forevr          s              1
     D kywhse          s              3  0
     D msgk            s              4  0
     D sclear          s              1
     D today           s              8  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PJTYP  0 - Batch
     *              1 - Interactive
     *      $PRTE   Route
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pjtyp            1
     C                   parm                    $prte             5
     C                   parm                    $ptruk           10
     C                   parm                    $prtid            5
650aAC                   parm                    $pwhse            3 0
     *----------------------------------------------------------------
     *  Main line
     *
     *  Only work with warehouse 900.
     *
650aDC**                 eval      kywhse = 900
650aMC                   eval      kywhse = $pwhse
650aAC                   eval      w1whse = $pwhse
     *
     *  Delete any existing WORKLBL records.
     *
     C                   if        $pjtyp = *on
     C                   eval      w1item = 'REMOVE'
     C                   write     screen1
     C                   endif
     C     keylbl        setll     worklbl1
     C                   dow       forevr = forevr
     C     keylbl        reade     worklbl1                               79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    lwrec
     C                   enddo
     *
     *  Initialize WORKLBL fields that are the same for all items.
     *
     C                   clear                   lwrec
     C                   eval      lwwhse = kywhse
     C                   eval      lwtruk = $ptruk
     C                   eval      lwrte = $prtid
     C                   eval      lwstop = 99
     C                   eval      lword = 9999999
     C                   eval      lwseq = 99
     C                   eval      lwpbat = 9999999
     C                   eval      lwgrp1 = 'X'
     C                   eval      lwgrp2 = 'X'
     *
     *  Loop through slot file by whse/item/stat/pick(descending)
     *
     C     keysl3        setll     slot3
     C                   dow       forevr = forevr
     C     keysl3        reade     slot3                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Ignore record if it is not active or does not have an item.
     *
     C                   if        slstat <> 'A'  or
     C                             slitem = *blanks
     C                   iter
     C                   endif
     *
     *     Only write one record per item.
     *
     C                   if        slitem = w1item
     C                   iter
     C                   endif
     *
     *     Get item info and keep user informed.
     *
     C                   if        slitem <> w1item
     C                   eval      w1item = slitem
     C                   if        $pjtyp = *on
     C                   write     screen1
     C                   endif
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   move      *hival        w1item
     C                   iter
     C                   endif
     C                   eval      lwutyp = 'N'
     C                   eval      lwucod = itum1
     C                   eval      lwucub = itcube
     C                   eval      lwuwgt = itswgt
     C                   endif
     *
     *     Create label record.
     *
     *       The label number is a negative sequential number.  This
     *       will allow us to use it as a relative record number in
     *       the order creation program.
     *
     C                   eval      lwwhdp = slwhdp
     C                   eval      lwaisl = slaisl
     C                   eval      lwloc = slloc
     C                   eval      lwrlvl = slrlvl
     C                   eval      lwhand = slhand
     C                   eval      lwpseq = slpseq
     C                   eval      lwstyp = slstyp
     C                   if        lwstyp = 'P'
     C                   eval      lwqryf = 1
     C                   else
     C                   eval      lwqryf = 0
     C                   endif
     C                   eval      lwdisp = sldisp
     C                   eval      lwitem = slitem
     C                   if        slstyp = 'F'  and
     C                             slpick <> 'Y'
     C                   eval      lwtype = 'B'
     C                   else
     C                   eval      lwtype = 'O'
     C                   endif
     C                   eval      lwstat = 'A'
     C                   eval      lwsdte = today
     C                   time                    lwstim
     C                   eval      lwrdte = today
     *                    CALL 'PIRLBL#'
     *                    PARM           LWLBL#
     C                   eval      lwlbl# = lwlbl# - 1
     C                   write     lwrec
     *
     C                   enddo
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize variables
     *
     C                   eval      forevr = *on
     C                   eval      error = *off
     *
     *   Define keys
     *
     C     keysl3        klist
     C                   kfld                    kywhse
     *
     C     keylbl        klist
     C                   kfld                    kywhse
     C                   kfld                    $prtid
     C     keyit         klist
     C                   kfld                    kywhse
     C                   kfld                    slitem
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $pjtyp = *on
     C                   open      pck224fm
     C                   endif
     *
     *   Initialize message handling
     *
     C                   if        $pjtyp = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *   Fool the compiler.
     *
     C                   eval      dummy = *blanks
     C                   if        dummy <> *blanks
     C                   read      pck224fm                               50
     C                   endif
     *
     C                   eval      $pprg = #prog
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCPMQ  Clear program message queue.
     *
     C     zmcpmq        begsr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMCSBF  Clear message subfile.
     *
     C     zmcsbf        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   UT81201  Item recalculated successfully.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'UT81201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81221  Item not recalculated - No ITEMQTY record.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'UT81221'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81222  Item not recalculated - Item does not exist.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'UT81222'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   UT81223  Item not recalculated - Error updating ITEMQTY.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'UT81223'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
