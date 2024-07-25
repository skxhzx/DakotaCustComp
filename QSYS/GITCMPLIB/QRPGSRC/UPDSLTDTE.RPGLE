      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSLTDTE   Update SLOTDTE file.
     *  05 June 2006
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    06/05/06  DAS  5.10
     *      - Created.
510bA*    08/01/06  RH   5.10b
     *      - Fix: Change to delete records if all qty in rec are zero
510dA*    08/25/06  RH   5.10d
     *      - Enh: Change to update slot expire/entered date with next
     *        SLOTDTE date.
510eA*    10/05/06  RH   5.10e
     *      - Fix: Was updating slot expire/entered date with last date
510fA*    10/11/06  RH   5.10f
     *      - Fix: Was not updating slot expire date with oldest date.e
510gA*    04/18/07  RH   5.10g
     *      - Enh: Create new CMD FIFOE to not process expired dates.
     *
520aA*    04/14/08  JCJ  5.20a-P#00000
     *      - Enh: Removed client specific code for VIP.
520bA*    12/05/08  DAS  5.20b-P#00000   (GJA applied)
     *      - Enh: Added *CHGEXPD
520cA*    12/05/08  RH   5.20c-P#00000
     *      - Fix: Only update records with date less than new date
520dA*    12/22/08  MLB  5.20d-P#00000
     *      - Fix: Change test after chain to qualify %found/no %found
     *        %eof/ not %eof with file name.
530aA*    07/23/10  RH   5.30a-
     *      - Fix: Do not update slot expiration date if slotdte = 0
     *        Return whole order did not capture expiration date and
600aA*    05/15/09  DAS  6.00a  P#00045
     *      - License tracking
     *      - SLOTDTE file not used in license tracking. Therefore,
     *        just returning.
     *        cleared pick slot expiration date.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fslotdte   uf a e           k disk
510d Fslot2     uf a e           k disk
510c Flogslotdteo  a e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#vip

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)
     D ck4err          s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *
510g D @cvtdt          c                   const('CVTDTE')
510g *
510g D $cvtdt          ds
510g D  $cvcmd                 1      8
510g D  $cvprg                 9     18
510g D  $cvd6i                19     24
510g D  $cvd8i                25     32
510g D  $cvd6o                33     38  0
510g D  $cvd8o                39     46  0
510g D  $cvsto                47     64
510g D  $cvrtn                65     72
510g D  $cverm                73    132
510g D  $cvmsg                73     76
     d $pdate          s                   like($pentd)
     d error           s               n
     d forever         s               n   inz(*on)
     d left$pqty       s              7  0
     d low$pqty        s              7  0
     d lowsdtqty       s              7  0
510g D today           s              8  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $pcmd    -  *DATE    - Update a specific date.
     *                 *FIFO    - Update in FIFO order.
510g *                 *FIFOE   - Update in FIFO order, skip expired date
     *                 *FIX     - Called from FIXSLTDTE.
     *                 *DELETE  - Delete records for slot.
     *                 *CHGITEM - Delete records for slot.
520bA*                 *CHGEXPD - Change exp date for slot.
     *     $ppgm    -  Original calling program
     *     $ppgm2   -  DRI program.
     *     $pwhse   -  Warehouse
     *     $pwhdp   -  Department
     *     $pslot   -  Slot
     *     $ppick   -  Pick slot flag (Y,N)
     *     $pitem   -  Item number
     *     $pnewi   -  New item number (only used for *CHGITEM)
     *     $pentd   -  Entered date
     *     $pexpd   -  Expiration date
     *     $pqty1   -  Quantity 1
     *     $pqty2   -  Quantity 2
     *     $pqty3   -  Quantity 3
     *
     *  Output parameters
     *
     *     $prtn    -  Retun code
     *                 *OK    - Valid userid
     *                 *ERROR - Invalid userid
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $ppgm            10
     C                   parm                    $ppgm2           10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pslot           12
     C                   parm                    $ppick            1
     C                   parm                    $pitem           15
     C                   parm                    $pnewi           15
     C                   parm                    $pentd            8 0
     C                   parm                    $pexpd            8 0
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $prtn             8

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

600aA*  Not used in license tracking, so just return.
600aA
600aAC                   return


510c *  Write log rec.
510c C                   exsr      zzwLog
XXXX C                   if        $pitem= '41019'
XXXX C                   eval      error = *off
XXXX C                   endif
     *  Only user for certain clients.

520aD ***                if        client <> vip
520aD ***                goto      bottom
520aD ***                endif

     *  For *DELETE, delete all records for slot and get out.

     C                   if        $pcmd = '*DELETE'
     C                   exsr      dltAll
     C                   goto      bottom
     C                   endif

520bA*  For *CHGEXPD, change expiration date for slot.
520bA
520bAC                   if        $pcmd = '*CHGEXPD'
520bAC                   exsr      chgExpDte
520bAC                   goto      bottom
520bAC                   endif

     *  For *CHGITEM, change item number for all records for slot.

     C                   if        $pcmd = '*CHGITEM'
     C                   exsr      chgItem
     C                   goto      bottom
     C                   endif

     *  For *FIX, delete invalid slots and change command to *FIFO.

     C                   if        $pcmd = '*FIX'
     C                   exsr      dltInvalid
     C                   eval      $pcmd = '*FIFO'
     C                   endif

     *  If slot is not a pick slot, then get out.

     C                   if        $ppick <> 'Y'
     C                   goto      bottom
     C                   endif

     *  If item is blank, then get out

     C                   if        $pitem = ' '
     C                   goto      bottom
     C                   endif

510e *  If all quantities are zero, then get out.
510e  * Code move to after get item info to allow 0 qty slots to be fix
     C*                  if        $pqty1 = 0
     C*                            and $pqty2 = 0
     C*                            and $pqty3 = 0
510e C*                  exsr      updslot
     C*                  goto      bottom
     C*                  endif

     *  Get item information.

     C                   exsr      getitem
     C                   if        error
     C                   eval      $itumq2 = 1
     C                   eval      $itumq3 = 1
     C                   eval      $itflgd = 'N'
     C                   endif

510e *  If all quantities are zero, then get out.

510e C                   if        $pqty1 = 0
510e C                             and $pqty2 = 0
510e C                             and $pqty3 = 0
510e C                   exsr      updslot
510e C                   goto      bottom
510e C                   endif

     *  Use appropriate date.

     C                   if        $itflgd = 'Y'
     C                   eval      $pdate = $pexpd
     C                   else
     C                   eval      $pdate = $pentd
     C                   endif

     *  Convert $p quantities to lowest uom quantitiy.

     C                   if        $itumq2 <= 0
     C                   eval      $itumq2 = 1
     C                   endif

     C                   if        $itumq3 <= 0
     C                   eval      $itumq3 = 1
     C                   endif

     C                   eval      low$pqty = ($pqty1 * $itumq2 * $itumq3)
     C                                      + ($pqty2 * $itumq3)
     C                                      + $pqty3

     *  Update date quantities.

     C                   if        low$pqty > 0
     C                   select
     C                   when      $pcmd = '*DATE'
     C                   exsr      incDate
     C                   when      $pcmd = '*FIFO'
     C                   exsr      incFifo
     C                   endsl
     C                   endif

     C                   if        low$pqty < 0
     C                   eval      low$pqty = %abs(low$pqty)
     C                   select
     C                   when      $pcmd = '*DATE'
     C                   exsr      decDate
     C                   when      $pcmd = '*FIFO'
     C                   exsr      decFifo
510gAC                   when      $pcmd = '*FIFOE'
510gAC                   exsr      decFifoe
     C                   endsl
     C                   endif

510d C                   exsr      updSlot

     C     bottom        tag
510dAC                   unlock    slotdte
510dAC                   unlock    slot2
     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
     C                   eval      forever = *on

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
510g *
510g *  Convert today's date into century format.
510g *
510g C                   exsr      zzzdte

     *  Define partial key for SLOTDTE file.

     C     sdtkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pslot
     C                   kfld                    $pitem

     *  Define key for SLOTDTE file.

     C     sdtkeyd       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pslot
     C                   kfld                    $pitem
     C                   kfld                    $pdate

510c *  Define key for SLOTDTE file.

510c C     sdtkeyt       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pslot
     C                   kfld                    $pitem
510c C                   kfld                    sdtdte

     *  Define partial key for SLOTDTE file.

     C     sdtkeys       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pslot

510d *  Define partial key for SLOT2 file.
510d
510d C     slkey         klist
510d C                   kfld                    $pwhse
510d C                   kfld                    $pwhdp
510d C                   kfld                    $pslot

     C                   endsr

520bA*----------------------------------------------------------------
520bA*  chgExpDte   Change expiration date for slot.
520bA*----------------------------------------------------------------
520bA
520bAC     chgExpDte     begsr
520bA
520bA*  Loop through records in First Out order.
520bA
520bAC     sdtkeys       setll     slotdte
     C                   dow       forever = forever
520bAC     sdtkeys       reade     slotdte
520bA
520bA*    If record not found, get out.
520bA
520dMC                   if        %eof(slotdte)
520bAC                   leave
520bAC                   endif
520bA
520bA*    Otherwise, set date to new date
520bA*    only update records with date less than new date.
520bA
520cAC                   if        sdtdte < $pexpd
520bAC                   eval      sdtdte = $pexpd
520bAC                   update(e) sdtrec
520bAC                   if        %error
520bAC                   endif
520cAC                   endif
520bA
520bAC                   enddo
520bA
520bAC                   endsr
520bA
     *----------------------------------------------------------------
     *  chgItem     Change item for all records for slot.
     *----------------------------------------------------------------

     C     chgItem       begsr

     *  Loop through records in First Out order.

     C     sdtkeys       setll     slotdte
     C                   dow       forever = forever
     C     sdtkeys       reade     slotdte

     *    If record not found, get out.

520dMC                   if        %eof(slotdte)
     C                   leave
     C                   endif

     *    Change item.

     C                   eval      sdtitm = $pnewi
     C                   update(e) sdtrec
     C                   if        %error
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  crtRec    Create SLOTDTE record.
     *----------------------------------------------------------------

     C     crtRec        begsr

     C                   eval      sdtwhs = $pwhse
     C                   eval      sdtwhs = $pwhse
     C                   eval      sdtwhd = $pwhdp
     C                   eval      sdtdsp = $pslot
     C                   eval      sdtitm = $pitem
     C                   eval      sdtdte = $pdate

     *  Convert lowest uom quantitiy into standard quantites.

     C     low$pqty      div       $itumq3       low$pqty
     C                   mvr                     sdtqt3

     C     low$pqty      div       $itumq2       low$pqty
     C                   mvr                     sdtqt2

     C                   eval      sdtqt1 = low$pqty

     C                   eval      sdtpgm  = $ppgm
     C                   eval      sdtpgm2 = $ppgm2
     C                   eval      sdtcmd  = $pcmd
     C                   eval      sdtusr  = #user
     C                   eval      sdtjob  = #job
     C                   eval      sdtnbr  = #jobn
     C                   write(e)  sdtrec
     C                   if        %error
     C                   endif

     C     endcrtRec     endsr

     *----------------------------------------------------------------
     *  decDate   Decrease quantity for specific date.
     *----------------------------------------------------------------

     C     decDate       begsr

     *  Get record for specific date.

     C     sdtkeyd       chain     slotdte

     *  If not found, get out.

520dMC                   if        not %found(slotdte)
     C                   goto      enddecDate
     C                   endif

     *  Otherwise, decrease quantities.

     *    Convert to lowest uom quantitiy.

     C                   eval      lowsdtqty = (sdtqt1 * $itumq2 * $itumq3)
     C                                       + (sdtqt2 * $itumq3)
     C                                       + sdtqt3

     *    Decrease quantity.

     C                   if        low$pqty > lowsdtqty
     C                   eval      lowsdtqty = 0
     C                   else
     C                   eval      lowsdtqty = lowsdtqty - low$pqty
     C                   endif

     *  Update record.

     C                   exsr      updRec

     C     enddecDate    endsr

     *----------------------------------------------------------------
     *  decFifo     Decrease quantity for First Out date.
     *----------------------------------------------------------------

     C     decFifo       begsr

     C                   eval      left$pqty = low$pqty

     *  Loop through records in First Out order.

     C     sdtkey        setll     slotdte
     C                   dow       forever = forever
     C     sdtkey        reade     slotdte

     *    If record not found, get out.

520dMC                   if        %eof(slotdte)
     C                   leave
     C                   endif

     *    Otherwise, decrease quantities.

     *      Convert to lowest uom quantitiy.

     C                   eval      lowsdtqty = (sdtqt1 * $itumq2 * $itumq3)
     C                                       + (sdtqt2 * $itumq3)
     C                                       + sdtqt3

     *      Decrease quantity.

     C                   if        left$pqty > lowsdtqty
     C                   eval      left$pqty = left$pqty - lowsdtqty
     C                   eval      lowsdtqty = 0
     C                   else
     C                   eval      lowsdtqty = lowsdtqty - left$pqty
     C                   eval      left$pqty = 0
     C                   endif

     *    Update record.

     C                   exsr      updRec

     *    If no more qty left, get out.

     C                   if        left$pqty <= 0
     C                   leave
     C                   endif

     C                   enddo

     C     enddecNoDate  endsr

510g *----------------------------------------------------------------
510g *  decFifoe    Decrease quantity for First Out date,skip expired
510g *----------------------------------------------------------------
510g
510g C     decFifoe      begsr
510g
510g C                   eval      left$pqty = low$pqty
510g
510g *  Loop through records in First Out order.
510g
510g C     sdtkey        setll     slotdte
510g C                   dow       forever = forever
510g C     sdtkey        reade     slotdte
510g
510g *    If record not found, get out.
510g
520dMC                   if        %eof(slotdte)
510g C                   leave
510g C                   endif
510g
510g *    If product expired, loop.
510g
510g C                   if        $itflgd = 'Y' and
510g C                             sdtdte < today
510g C                   iter
510g C                   endif
510g *    Otherwise, decrease quantities.
510g
510g *      Convert to lowest uom quantitiy.
510g
510g C                   eval      lowsdtqty = (sdtqt1 * $itumq2 * $itumq3)
510g C                                       + (sdtqt2 * $itumq3)
510g C                                       + sdtqt3
510g
510g *      Decrease quantity.
510g
510g C                   if        left$pqty > lowsdtqty
510g C                   eval      left$pqty = left$pqty - lowsdtqty
510g C                   eval      lowsdtqty = 0
510g C                   else
510g C                   eval      lowsdtqty = lowsdtqty - left$pqty
510g C                   eval      left$pqty = 0
510g C                   endif
510g
510g *    Update record.
510g
510g C                   exsr      updRec
510g
510g *    If no more qty left, get out.
510g
510g C                   if        left$pqty <= 0
510g C                   leave
510g C                   endif
510g
510g C                   enddo
510g
510g C     enddecNoDte   endsr

     *----------------------------------------------------------------
     *  dltAll      Delete all records for slot
     *----------------------------------------------------------------

     C     dltAll        begsr

     *  Loop through records in First Out order.

     C     sdtkeys       setll     slotdte
     C                   dow       forever = forever
     C     sdtkeys       reade     slotdte

     *    If record not found, get out.

520dMC                   if        %eof(slotdte)
     C                   leave
     C                   endif

     *    Delete record.

     C                   delete    sdtrec

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  dltInvalid  Delete records invalid item number
     *----------------------------------------------------------------

     C     dltInvalid    begsr

     *  Loop through records in First Out order.

     C     sdtkeys       setll     slotdte
     C                   dow       forever = forever
     C     sdtkeys       reade     slotdte

     *    If record not found, get out.

520dMC                   if        %eof(slotdte)
     C                   leave
     C                   endif

     *    If items don't match, delete record.

     C                   if        $pitem <> sdtitm
     C                   delete    sdtrec
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr
     C                   eval      error = *off

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = $pitem

     C                   call(e)   'DRIITEM'
     C                   parm      '*GETMAIN'    $drisubcmd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  incDate   Increase quantity for specific date.
     *----------------------------------------------------------------

     C     incDate       begsr

     *  Get record for specific date.

     C     sdtkeyd       chain     slotdte

     *  If not found, create new record.

520dMC                   if        not %found(slotdte)
     C                   exsr      crtRec
     C                   goto      endincDate
     C                   endif

     *  Otherwise, increase quantities and update record.

     *      Convert to lowest uom quantitiy.

     C                   eval      lowsdtqty = (sdtqt1 * $itumq2 * $itumq3)
     C                                       + (sdtqt2 * $itumq3)
     C                                       + sdtqt3

     *      Increase quantity

     C                   eval      lowsdtqty = lowsdtqty + low$pqty

     *      Update record.

     C                   exsr      updRec

     C     endincDate    endsr

     *----------------------------------------------------------------
     *  incFifo     Increase quantity for First Out date.
     *----------------------------------------------------------------

     C     incFifo       begsr

     *  Get First Out record.

     C     sdtkey        setll     slotdte
     C     sdtkey        reade     slotdte

     *    If record not found, create one.

520dMC                   if        %eof(slotdte)
     C                   exsr      crtRec
     C                   goto      endincNoDate
     C                   endif

     *    Otherwise, increase quantities and update record.

     *      Convert to lowest uom quantitiy.

     C                   eval      lowsdtqty = (sdtqt1 * $itumq2 * $itumq3)
     C                                       + (sdtqt2 * $itumq3)
     C                                       + sdtqt3

     *      Increase quantity

     C                   eval      lowsdtqty = lowsdtqty + low$pqty

     *      Update record.

     C                   exsr      updRec

     C     endincNoDate  endsr

     *----------------------------------------------------------------
     *  updRec    Update SLOTDTE record.
     *----------------------------------------------------------------

     C     updRec        begsr

     *  Converty lowest uom quantitiy into standard quantites.

     C     lowsdtqty     div       $itumq3       lowsdtqty
     C                   mvr                     sdtqt3

     C     lowsdtqty     div       $itumq2       lowsdtqty
     C                   mvr                     sdtqt2

     C                   eval      sdtqt1 = lowsdtqty

     *  Note, we always do an update, even if all qtys are zero, in
     *  order to capture information in journal.

     C                   eval      sdtpgm  = $ppgm
     C                   eval      sdtpgm2 = $ppgm2
     C                   eval      sdtcmd  = $pcmd
     C                   eval      sdtusr  = #user
     C                   eval      sdtjob  = #job
     C                   eval      sdtnbr  = #jobn
     C                   update(e) sdtrec
     C                   if        %error
     C                   endif

     *  If all quantities are zero, delete record.

510bDC*                  if        $pqty1=0 and $pqty2=0 and $pqty3=0
510bMC*                  if        sdtqt1=0 and sdtqt2=0 and sdtqt3=0
510cDC*    sdtkeyd       chain     slotdte
510cMC     sdtkeyt       chain     slotdte
520dMC                   if        %found(slotdte)
510bMC                   if        sdtqt1=0 and sdtqt2=0 and sdtqt3=0
     C                   delete(e) sdtrec
     C                   if        %error
     C                   endif
     C                   endif
     C                   endif
510eAC                   unlock    slotdte

     C     endupdRec     endsr
510d *----------------------------------------------------------------
     *  updSlot     Update Slot expire / entered date.
     *----------------------------------------------------------------

510d C     updSlot       begsr

     *  Loop through records in First Out order.

     C     sdtkeys       setll     slotdte
     C                   dow       forever = forever
     C     sdtkeys       reade(n)  slotdte

     *    If record not found, get out.

520dMC                   if        %eof(slotdte)
     C                   leave
     C                   endif

     *    Update Slot expiration / entered date

     C     slkey         chain     slot2

     *  If not found, get out.

520dMC                   if        not %found(slot2)
     C                   leave
     C                   endif

     *  Otherwise, update slot date.

     C                   if        $itflgd = 'Y'
510eDC*                  if        slexpd <> sdtdte
510fDC*                  if        slexpd > sdtdte
510f C                   if        slexpd <> sdtdte
530aAC                             and sdtdte > 0
     C                   eval      slexpd = sdtdte
     C                   update(e) slrec
510eAC                   leave
     C                   if        %error
510fAC                   leave
     C                   endif
510fAC                   leave
     C                   endif
510fAC                   leave
     C                   endif
     *  Code removed to NOT update entered date.
     C*                  else
     C*                  if        slentd <> sdtdte
     C*                  eval      slentd = sdtdte
     C*                  endif
     C*                  endif
     C*                  update(e) slrec
     C*                  if        %error
     C*                  endif

510d C                   enddo
510dAC                   unlock    slot2

510d C     Endupdslot    endsr

     *----------------------------------------------------------------
510c *  zzwLog    Create LOGSLOTDTE record.
     *----------------------------------------------------------------

510c C     zzwlog        begsr

     C                   eval      lgsldtcmd = $pcmd
     C                   eval      lgsldtpgm = $ppgm
     C                   eval      lgsldtpgm2 = $ppgm2
     C                   eval      lgsldtwhse = $pwhse
     C                   eval      lgsldtwhdp = $pwhdp
     C                   eval      lgsldtslot = $pslot
     C                   eval      lgsldtpick = $ppick
     C                   eval      lgsldtitem = $pitem
     C                   eval      lgsldtnewi = $pnewi
     C                   eval      lgsldtentd = $pentd
     C                   eval      lgsldtexpd = $pexpd
     C                   eval      lgsldtqty1 = $pqty1
     C                   eval      lgsldtqty2 = $pqty2
     C                   eval      lgsldtqty3 = $pqty3
     C                   eval      lgsldtrtn = $prtn
     C                   write(e)  lgsldtrec
     C                   if        %error
     C                   endif

510c C     endzzwLog     endsr
510g *----------------------------------------------------------------
510g *
510g *  ZZZDTE   Get date.
510g *
510g C     zzzdte        begsr
510g *
510g C                   eval      $cvcmd = '*CURCMD '
510g C                   call      @cvtdt
510g C                   parm                    $cvtdt
510g C                   eval      today = $cvd8o
510g *
510g C                   endsr


