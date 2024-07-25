     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')
     H Option(*NODEBUGIO)

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  OR203     RF single order pick - Create label records
     *  29 May 2002
     *  Dave Sommerville
     *
416  *    05/29/02  DAS  4.16
     *      - Created
     *
416aA*    06/11/02  DAS  4.16a
     *      - Recompiled because of change to C#SLOT.
416bA*    06/19/02  MLB  4.16b
     *      - Fix: Changed program to turn on $SLWHDPU.
     *        Fix: If no pick slot found for item, default to
     *             items' department. Same for section type.
     *
416cA*    06/11/03  DAS  4.16c
     *      - Recompiled because of change to C#ITEM.
     *      - Note, this program doesn't use the second data
     *        parameter, $item2, because the fields are not used.
500aA*    12/20/05  RH   5.00a
     *      - ENH: Add code to get slot with CMD %NXTPICKAV to find
     *        slot with available quantity.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordd      if   e           k disk
     Flabel     o  a e           k disk    infds(file1ds)
     Fbatctl    o  a e           k disk    infds(file2ds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#ORDH
     D savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D $pwhse          s                   like(odwhse)
     D $pord           s                   like(odord)
     D $ptrn#          s              7  0
     D $pbat           s              7  0
     D $preturn        s              8

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curdate         s              8  0
     D curtime         s              6  0
     D error           s               n
     D forever         s               n   inz(*on)
     D lasttime        s              6  0 inz(999999)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     D File2DS         ds
     D  f2filename             1      8
     D  f2openind              9      9
     D  f2endoffile           10     10
     D  f2status              11     15  0
     D  f2opercode            16     21
     D  f2routine             22     29
     D  f2stmtnbr             30     37
     D  f2recordcd            38     45
     D  f2messageid           46     52
     D  f2sourceid            53     54

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $pwhse     Warehouse
      *      $pord      Order id
      *      $prte      Route id
      *
      *    Returned Parameters
      *      $ptrn      Transaction number
      *      $pbat      Picking batch number
      *      $preturn   Return code
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $pord
     C                   parm                    $ptrn#
     C                   parm                    $pbat
     C                   parm                    $preturn

     C                   eval      $preturn = '*OK'

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  Get current date and time.

     C                   exsr      getdatetime

     *  Get order header information.

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     C                   eval      $ohwhseu = *on
     C                   eval      $ohwhse = $pwhse

     C                   eval      $ohoidu = *on
     C                   eval      $ohoid = $pord

     C                   eval      $dricommand = '*ORD'
     C                   eval      $drisubcmd  = '%GETHDR'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Create picking batch control record.

     C                   call      'PIRBAT#'
     C                   parm                    $pbat

     C                   eval      btbat# = $pbat
     C                   eval      btwhse = $pwhse
     C                   eval      bttype = $ohtype
     C                   eval      btstat = '4'
     C                   eval      btrte  = $ohrid
     C                   eval      btstrd = curdate
     C                   eval      btstrt = curtime
     C                   eval      btstrb = #user
     C                   write     btrec

     *  Get transaction number to use.

     C                   call      'PIRTRN#'
     C                   parm                    $ptrn#

     *  Initialize transaction variables.

     C                   eval      @pwhse = 0
     C                   eval      @pwhdp = ' '
     C                   eval      @pstyp = ' '
     C                   eval      @pcube = 0
     C                   eval      @pswgt = 0
     C                   eval      @ppcs  = 0
     C                   eval      @paisl = 0
     C                   eval      @pqty1 = 0
     C                   eval      @pqty2 = 0
     C                   eval      @pqty3 = 0
     C                   eval      @prte = ' '
     C                   eval      @ppo = ' '

     *  Add task detail records.

     C     keyod         setll     ordd
 1B  C                   dow       forever = forever
     C     keyod         reade     ordd
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
     C                   exsr      crtlabel
 1E  C                   enddo

     *  Create transaction record.

     C                   call      'ADDSTDTRN'
     C                   parm      '*CREATE'     @pcmd             8
     C                   parm                    #job
     C                   parm      $ptrn#        @ptrn#            7 0
     C                   parm      'FIXED'       @ptask            6
     C                   parm                    @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm                    @ppcs             5 0
     C                   parm                    @paisl            5 0
     C                   parm                    @pqty1            5 0
     C                   parm                    @pqty2            5 0
     C                   parm                    @pqty3            5 0
     C                   parm                    @prte             5
     C                   parm                    @ppo              9
     C                   parm      'S'           @pgrp1            1
     C                   parm      'S'           @pgrp2            1
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *  We are finished so get out

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for ORDD file.

     C     keyod         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord

     C                   endsr

     *----------------------------------------------------------------
     *  crtlabel   Create label record for order detail line
     *----------------------------------------------------------------

     C     crtlabel      begsr

     *  Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = odwhse
     C                   eval      $ititem = oditem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Get slot for item.

500a *  Try to get slot with available quantity
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse = odwhse

416bAC                   eval      $slwhdpu = *on

     C                   eval      $slitemu = *on
     C                   eval      $slitem = oditem

     C                   eval      $slstatu = *on
     C                   eval      $slstat = 'A'

     C                   eval      $slaislu = *on
     C                   eval      $slpsequ = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $slprtyu = *on
     C                   eval      $slexpdu = *on
     C                   eval      $slentdu = *on
     C                   eval      $slpicku = *on

     C                   eval      $dricommand = '*SLOT'
500aDC*                  eval      $drisubcmd  = '%NXTITEM'
500aMC                   eval      $drisubcmd  = '%NXTPICKAV'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
500a *  If error, just get next slot.
500aAC                   if        $drireturn = 'EOF'
500a C                   eval      savever# = $slver#
500a C                   clear                   $slot
500a C                   eval      $slver# = savever#
500a
500a C                   eval      $slwhseu = *on
500a C                   eval      $slwhse = odwhse
500a
500a C                   eval      $slwhdpu = *on
500a
500a C                   eval      $slitemu = *on
500a C                   eval      $slitem = oditem
500a
500a C                   eval      $slstatu = *on
500a C                   eval      $slstat = 'A'
500a
500a C                   eval      $slaislu = *on
500a C                   eval      $slpsequ = *on
500a C                   eval      $slrlvlu = *on
500a C                   eval      $slhandu = *on
500a C                   eval      $slprtyu = *on
500a C                   eval      $slexpdu = *on
500a C                   eval      $slentdu = *on
500a C                   eval      $slpicku = *on
500a
500a C                   eval      $dricommand = '*SLOT'
500a C                   eval      $drisubcmd  = '%NXTITEM'
500a C                   eval      $drisys2upd = 'D'
500a C                   exsr      zzzdricop
500aAC                   endif

     *  Create label record.

     C                   clear                   lbrec

     C                   eval      lbwhse = odwhse
     C                   eval      lbord  = odord
     C                   eval      lbseq  = odseq
     C                   eval      lbitem = oditem
     C                   eval      lbspcl = odspcl

     C                   eval      lbrte  = $ohrid
     C                   eval      lbstop = $ohstop

416bAC                   if        $slwhdp > *blanks
     C                   eval      lbwhdp = $slwhdp
416bAC                   else
416bAC                   eval      lbwhdp = $itwhdp
416bAC                   endif
     C                   eval      lbaisl = $slaisl
     C                   eval      lbloc  = $slloc
     C                   eval      lbrlvl = $slrlvl
     C                   eval      lbhand = $slhand
     C                   eval      lbpseq = $slpseq
416bAC                   if        $slstyp > *blanks
     C                   eval      lbstyp = $slstyp
416bAC                   else
416bAC                   eval      lbstyp = $itstyp
416bAC                   endif
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      lbdisp = $sldisp
416aA
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = curdate
     C                   eval      lbstim = curtime
     C                   eval      lbrdte = curdate
     C                   eval      lbtype = 'O'
     C                   eval      lbgrp1 = 'S'
     C                   eval      lbgrp2 = 'S'
     C                   eval      lbtrn# = $ptrn#
     C                   eval      lbpbat = $pbat

     C                   if        odqor1 > 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbutyp = 'N'
     C                   eval      lbucod = $itum1
     C                   eval      lbucub = $itcube
     C                   eval      lbcube = odqor1 * lbucub
     C                   eval      lbuwgt = $itswgt
     C                   eval      lbswgt = odqor1 * lbuwgt
     C                   eval      lbqalc = odqor1

     C                   write     lbrec
     C                   if        %error
     C                   endif

     C                   eval      @pcube = @pcube + lbcube
     C                   eval      @pswgt = @pswgt + lbswgt
     C                   eval      @ppcs  = @ppcs + lbqalc
     C                   endif

     C                   if        odqor2 > 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbutyp = '1'
     C                   eval      lbucod = $itum2
     C                   eval      lbucub = $itcube/$itumq2
     C                   eval      lbcube = odqor2 * lbucub
     C                   eval      lbuwgt = $itswgt/$itumq2
     C                   eval      lbswgt = odqor2 * lbuwgt
     C                   eval      lbqalc = odqor2

     C                   write     lbrec
     C                   if        %error
     C                   endif

     C                   eval      @pcube = @pcube + lbcube
     C                   eval      @pswgt = @pswgt + lbswgt
     C                   eval      @ppcs  = @ppcs + lbqalc
     C                   endif

     *  Update transaction fields.

     C                   if        @pwhse = 0
     C                   eval      @pwhse = lbwhse
     C                   eval      @pwhdp = lbwhdp
     C                   eval      @pstyp = lbstyp
     C                   eval      @prte  = lbrte
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   when      $dricommand = '*ORD'
     C                   eval      $dridata = $ordh
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C**                 eval      error = *on
     C**                 eval      errmsg    = 'Error occured on call to '
     C**                                     + 'DRICOP'
     C**                                     + '/' + %trim($drisubcmd)
     C**                                     + ' from ' + #prog
     C**                 exsr      zm0105

     C                   when      $drireturn <> '*OK'
     C**                 eval      error = *on
     C**                 exsr      zm0001
     C**                 exsr      zzzerrind

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   when      $dricommand = '*ORD'
     C                   eval      $ordh = $dridata
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C     enddricop     endsr
