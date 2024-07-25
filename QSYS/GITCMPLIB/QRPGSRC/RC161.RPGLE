     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RC161     No directed puut-away, Update PO files only.
409 A*  18 February 1998
     *  Roxanne Harrison
     *      - Created using RC160, previous version comments removed.
     *      - Processes both manual and PO receiving.
     *
415 A*  03/13/01  DAS  4.15
     *    - Added logic to write record to PORCV file.
416aA*    05/28/02  RRH  4.16a
     *      - Initialize POREDT and PORETI, PORCV file changed.
730aA*    02/28/19  LMC  7.30a
     *      - converted to rpgle.
     *      - Added new parm to receive the user, so that I can write
     *        the actual user to the porusr field when received with
     *        gui.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpohdr     uf a e           k disk
     Fpodtl     uf a e           k disk
415 AFporcv     o  a e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
     *----------------------------------------------------------------
     *  Called program parameters
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     D  $ltype                81     88
     *
     *
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D  erqty                  1     10
     D  erpal                 11     12p 0
     D  eritem                13     27
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
     *  Variables
     *
     D $msgf           s             10
     D @pgrp1          s              1
     D @pgrp2          s              1
     D @ptask          s              6
     D error           s              1
     D first           s              1
     D forevr          s              1
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
     D svcmd           s              8
     D svseq           s              5  0
     D today           s              8  0
     D today6          s              6  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *OPEN    - Open program and return.
     *              *RECEIVE - Receiving.
     *              *TFRRCV  - Transfer receiving.
     *              *RETURN  - Customer returns.
     *              *TFRRTN  - Transfer returns.
     *              *POSRTN  - POS returns.
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER    - Interactive, use program msg queue.
     *              *BATCH    - Batch, send error code.
     *      $PWHSE  Warehouse.
     *      $PITEM  Item to put away.
     *      $PQTY1  Normal returned quantity to put-away.
     *      $PQTY2  Breakdown 1 returned quantity to put-away.
     *      $PQTY3  Breakdown 2 returned quantity to put-away.
     *      $PPO    P.O. number for *RECEIVE.
     *      $PVEN   Vendor number for *RECEIVE.
     *      $PVNAM  Vendor name for *RECEIVE.
     *      $PVITM  Vendor item number for *RECEIVE.
     *      $PORD   Order number for *RETURN.
     *      $PRCOD  Return code.
     *      $PRMEM  Return memo.
     *      $PEXPD  Expiration date.
     *      $PDEV   Printer device to use or *DEFAULT.
     *      $PFORM  Printer form to use or *DEFAULT.
     *      $PSLOT  Manual override of slot to use for putaway.
     *      $PSEQ   Seq# for P.O. receiving.  0 = Manual receiving.
     *      $PRPCK  Allow returns into Pick Slot (Y,N).
     *      $PPLBL  Print putaway labels (Y,N).
     *      $PDWGT  Catch weight
     *
     *    Returned Parameters
     *      $PORD   Batch number assigned to labels.
     *      $PRQ1   for *OK      - Normal qty put away.
     *              for *NOTENGH - Qty was not updated.
     *      $PRQ2   for *OK      - Brk1 qty put away.
     *              for *NOTENGH - Qty was not updated.
     *      $PRQ3   for *OK      - Brk2 qty put away.
     *              for *NOTENGH - Qty was not updated.
     *      $PRPAL
     *      $PRTN   *OK      - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *                         (for use with $PTYPE = *INTER).
     *              *NOTENGH - Qty not updated.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $ptype            8
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $ppo              9
     C                   parm                    $pven            11 0
     C                   parm                    $pvnam           40
     C                   parm                    $pvitm           15
     C                   parm                    $pord             7 0
     C                   parm                    $prcod            2
     C                   parm                    $prmem           30
     C                   parm                    $pexpd            8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pslot           12
     C                   parm                    $pseq             5 0
     C                   parm                    $prpck            1
     C                   parm                    $pplbl            1
     C                   parm                    $pdwgt            9 2
     C                   parm                    $prq1             5 0
     C                   parm                    $prq2             5 0
     C                   parm                    $prq3             5 0
     C                   parm                    $prpal            3 0
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
     C                   parm                    $pguiuser        10
     *----------------------------------------------------------------
     *  Main line
     *
     C     $pcmd         cabeq     '*OPEN   '    bottom
     *
     * Convert command into generic form and initialize transaction parms
     *
     C                   eval      svcmd = $pcmd
     C                   select
     C                   when      $pcmd = '*RECEIVE'
     C                   eval      @ptask = 'PUTEMP'
     C                   eval      @pgrp1 = 'P'
     C                   eval      @pgrp2 = ' '
     *
     C                   when      $pcmd = '*TFRRCV '
     C                   eval      $pcmd = '*RECEIVE'
     C                   eval      @ptask = 'PUTEMP'
     C                   eval      @pgrp1 = 'P'
     C                   eval      @pgrp2 = 'T'
     *
     C                   when      $pcmd = '*RETURN '
     C                   eval      @ptask = 'PUTRTN'
     C                   eval      @pgrp1 = 'R'
     C                   eval      @pgrp2 = ' '
     *
     C                   when      $pcmd = '*TFRRTN '
     C                   eval      $pcmd = '*RETURN '
     C                   eval      @ptask = 'PUTRTN'
     C                   eval      @pgrp1 = 'R'
     C                   eval      @pgrp2 = 'T'
     *
     C                   when      $pcmd = '*POSRTN '
     C                   eval      $pcmd = '*RETURN '
     C                   eval      @ptask = 'PUTRTN'
     C                   eval      @pgrp1 = 'R'
     C                   eval      @pgrp2 = 'P'
     *
     C                   endsl
     *
     C                   eval      $prq1 = $pqty1
     C                   eval      $prq2 = $pqty2
     C                   eval      $prq3 = $pqty3
     C                   eval      $prpal = 0
     C                   eval      $prtn = *blanks
     *
     * Perform initialization for item received.
     *
     C                   exsr      init
     C     error         cabeq     *on           bottom
     *
     *
     *  Try to update P.O. files with qty received.
     *
     C                   exsr      post
     C                   eval      $prtn = '*OK     '
     *
     *  Otherwise, reverse what has been done and send back error msg.
     *
     C                   if        error = *on
     C                   eval      $prtn = '*NOSLOT '
     C                   endif
     *
     C     bottom        tag
     *
     C                   if        $ptype = '*INTER  '
     *
     C                   select
     C                   when      $prtn = '*OK     '
     C                   exsr      zm20
     *
     C                   other
     *                    EXSR ZM21
     C                   eval      $prtn = '*PGMQ   '
     *
     C                   endsl
     C                   endif
     *
     * Make sure we haven't left any records locked.
     *
     C                   unlock    pohdr
     C                   unlock    podtl
     *
     * Restore original command.
     *
     C                   eval      $pcmd = svcmd
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      first = *on
     *
     *  Define key for POHDR file.
     *
     C     keyph         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
     *  Define key for PODTL file.
     *
     C     keypd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     C                   kfld                    svseq
     C                   kfld                    $pitem
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INIT    Initialize arrays.
     *
     C     init          begsr
     C                   eval      error = *off
     C                   eval      svcmd = $pcmd
     *
     *  Initialize quantity left.
     *
     C                   eval      q1lft = $pqty1
     C                   eval      q2lft = $pqty2
     C                   eval      q3lft = $pqty3
     *
     C                   eval      first = *off
     C     endint        endsr
     *----------------------------------------------------------------
     *
     *  POST    Post receiving.
     *
     C     post          begsr
     *
     *  Get sequence number to be used for PO detail file.
     *   If sequence number wasn't passed in PARMS.
     *
     C                   if        $pcmd = '*RECEIVE'
     C                   if        $pseq = 0
     C     keyph         setgt     podtl
     C     keyph         readpe(n) podtl                                  79
     C                   if        *in79
     C                   eval      svseq = 1
     C                   else
     C     pdseq         add       1             svseq
     C                   endif
     C                   else
     C                   eval      svseq = $pseq
     C                   endif
     C                   endif
     *
     *  Create P.O. or return record.
     *
     C                   select
     *
     *     P.O. record for receiving.
     *
     C                   when      $pcmd = '*RECEIVE'
     *
     *        Create P.O. header record.
     *
     C     keyph         chain(n)  pohdr                              79
     C                   if        *in79
     C                   clear                   phrec
     C                   eval      phwhse = $pwhse
     C                   eval      phpo = $ppo
     C                   eval      phven = $pven
     C                   eval      phvnam = $pvnam
     C                   write     phrec
     C                   endif
     *
     *        Create or update PO detail record.
     *         Seq # is retreived at the beginning of this routine -
     *         or was passed in parm $PSEQ.
     *
     C     keypd         chain     podtl                              79
     C                   if        *in79
     C                   clear                   pdrec
     C                   eval      pdwhse = $pwhse
     C                   eval      pdpo = $ppo
     C                   eval      pdseq = svseq
     C                   eval      pditem = $pitem
     C                   eval      pdvitm = $pvitm
     C                   eval      pdspcl = *blanks
     C                   eval      pdqor1 = $prq1
     C                   eval      pdqor2 = $prq2
     C                   eval      pdqor3 = $prq3
     C                   eval      pdqrc1 = $prq1
     C                   eval      pdqrc2 = $prq2
     C                   eval      pdqrc3 = $prq3
     C                   eval      pddwgt = $pdwgt
     C                   write     pdrec
     C                   else
     C                   add       $prq1         pdqrc1
     C                   add       $prq2         pdqrc2
     C                   add       $prq3         pdqrc3
     C                   add       $pdwgt        pddwgt
     C                   update    pdrec
     C                   endif
     *
     C                   eval      q1lft = 0
     C                   eval      q2lft = 0
     C                   eval      q3lft = 0
     *
415 AC                   exsr      zzurcv
     *
     C                   endsl
     *
     C                   endsr
415 A*---------------------------------------------------------------
415 A*
415 A*  ZZURCV   Update PORCV file.
415 A*
415 AC     zzurcv        begsr
     *
     *    Get User's employee number to be written to PORCV file
     *    if any records are flagged as touched.
     *
     C                   call      'GETUSER'
     C                   parm      #user         $code            10
     C                   parm      0             $whse             3 0
     C                   parm      0             $emp#             5 0
     C                   parm      *blanks       $fnam            15
     C                   parm      *blanks       $init             1
     C                   parm      *blanks       $lnam            20
     C                   parm      *blanks       $whdp             5
     C                   parm      *blanks       $styp             1
     C                   parm      *blanks       $shft             6
     C                   parm      *blanks       $crew             6
     C                   parm      0             $nhrs             3 1
     C                   parm      *blanks       $rtn              8
     *
     *   Add record to PORCV.
     *
     C                   eval      porwhs = $pwhse
     C                   eval      porpo = $ppo
     C                   eval      porseq = $pseq
     C                   eval      pordte = today
     C                   time                    portim
730aAc                   if        %parms >= 30
730aAC                   eval      porusr = $pguiuser
730aAc                   else
     C                   eval      porusr = #user
730aAc                   endif
     C                   eval      pordev = #job
     C                   eval      poremp = $emp#
     C                   eval      portrn = 0
416aD**                   Z-ADD0         PORLIC
416aMC                   eval      porlic = *blanks
     C                   eval      porlbl = 0
     C                   eval      poract = 'R'
416aAC                   eval      poredt = 0
416aAC                   eval      poreti = 0
     C                   write     porrec                               49
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     RC16020  Everything was ok.
     *
     C     zm20          begsr
     C                   eval      #msgid = 'RC16020'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = *blanks
     *
     *     Convert string to quantities.
     *
     C                   eval      $cqty1 = $prq1
     C                   eval      $cqty2 = $prq2
     C                   eval      $cqty3 = $prq3
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #prog
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   eval      erqty = $cqstr
     C                   eval      erpal = $prpal
     C                   eval      eritem = $pitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
