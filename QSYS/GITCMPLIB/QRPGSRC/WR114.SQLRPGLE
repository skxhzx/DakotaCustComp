      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  WR114     Work orders / Repack - Close
     *  06 March 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    03/06/07  DAS  5.10
     *      - Created.
     *
650aA*    03/08/2013  KDE  650a
     *      -  WR112 was changed with same revision number to recreate
     *         Repack Slots when the Work Order pulled EXACTLY what
     *         was needed and removed once it was completed.  If the
     *         user went back into option 2 using WR112 it would fail
     *         due to Repack Slot missing for those parents.  A change
     *         was put in here to remove those zero qty Repack slots
     *         once the Work Order is closed
710 A*    09/01/2017  KDE  710
     *      -  Change to not delete RPK slot if other work orders exist
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fkitordh   uf   e           k disk
     F                                     rename(kohrec:record)
610 AFkitcomp   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D msg             s             50    dim(1) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
510aAD  $lndt                 22     29  0
     D  $pord                 30     36  0
     D  $pitem                37     51

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

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
     *  CVTDTE parameters
     *----------------------------------------------------------------

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

710 A*----------------------------------------------------------------
710 A*  SQL Data Structures
710 A*----------------------------------------------------------------
710 AD kithdr        E Ds                  Extname(kitordh) prefix(k_)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $msgf           s             10
710 Ad cnt             s              3  0
     D error           s              1
     D temp8           s              7
     D hldisp          s             12
     D chk4err         s               n
     D drierr          s               n
710 AD $rcmd           s             10
710 AD $rrtn           s             10
710 AD $rmsg           s             60
     D zmsflag         s               n
     D saveVer#        s                   like($slver#)

610 A*----------------------------------------------------------------
610 A*  Called program parameters
610 A*----------------------------------------------------------------

610 AD $lparm          ds
610 AD  $lcmd                  1      8
610 AD  $lprg                  9     18
610 AD  $luky                 19     68
610 AD  $lrtn                 69     76
610 AD  $lerm                 77    136
610 AD  $lmsg                 77     80

610 A*   Redefine key

610 AD  $lwhse                19     21  0
610 AD  $litem                22     36


510aA*----------------------------------------------------------------
510aA*  Called programs
510aA*----------------------------------------------------------------
510aAD @mntpr          c                   const('WR122')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   Not used
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for delete.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *              *OK      - Record deleted successfully.
     *                         Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C     fileky        chain     record                             79
     C                   if        not *in79
710 AC                   exsr      zzdel
610 AC                   exsr      zzAdjPrtyRepl
710 DC*                  exsr      zzdel
     C                   if        error = *off
     C*********          delete    record
     C                   exsr      zzok
     C                   endif
     C                   else
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   endif
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

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

     *---------------------------------------------------------------
     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *----------------------------------------------------------------

     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *----------------------------------------------------------------

     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  ZZ Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

610 A*----------------------------------------------------------------
610 A*  ZZAdjPrtyRepl
610 A*----------------------------------------------------------------

610 AC     zzAdjPrtyRepl begsr

610 AC                   eval      $lcmd  = '*CHANGE'
610 AC                   eval      $lwhse = $pwhse
610 AC                   eval      $lprg  = $pprg

610 AC                   eval      $litem = *blanks
650aA ***  loop now that more than 1 parent is can be used on repack
650aAC     kitkey        setll     kitcomp
650aAC     kitkey        reade(e)  kitcomp
650aAc                   dow       %equal and not %eof
650aMC**   kitkey        chain     kitcomp
650aMC**                 if        %found(kitcomp)
610 AC                   eval      $litem = kccitm
650aMC**                 endif

610 AC                   call      @mntpr
610 AC                   parm                    $lparm
650aAc                   exsr      zzRmzRpkSlt
650aAC     kitkey        reade(e)  kitcomp
650aAc                   enddo
610 AC                   endsr

650aA*----------------------------------------------------------------
650aA*  ZZRmzRptSlt - Remove any Parent Repack Slots with no data
650aA*----------------------------------------------------------------

650aAC     zzRmzRpkSlt   begsr

710 Ac*  If other Work Orders exist return without deleting RPK slot
710 Ac*  but call an update process first to modify existing replen
710 A /free
710 A       cnt = *zeros;
710 A       exec sql select count(*) into :cnt
710 A            from kitordh as h,kitcomp as k
710 A           where h.kohwhs=k.kcwhse and h.kohitm=k.kcitem
710 A             and k.kccitm=:kccitm and h.kohsta<'4'
710 A             and h.kohord <> :$pord;
710 A
710 A       if cnt <> *zeros;
710 A       // get one extra remaining work order to use for
710 A       // replenishment update process
710 A       exec sql select h.* into :kithdr
710 A            from kitordh as h,kitcomp as k
710 A           where h.kohwhs=k.kcwhse and h.kohitm=k.kcitem
710 A             and k.kccitm=:kccitm and h.kohsta<'4'
710 A             and h.kohord <> :$pord
710 A              fetch first row only;
710 A /end-free
710 AC                   call      'CRTWRKORD'
710 AC                   parm      '*UPDWRKORD'  $rcmd
710 AC                   parm                    k_kohwhs
710 AC                   parm                    k_kohitm
710 AC                   parm                    k_kohqty
710 AC                   parm      'M'           k_kohby
710 AC                   parm                    k_kohref
710 AC                   parm      ' '           $rrtn
710 AC                   parm      ' '           $rmsg
710 AC                   parm                    k_kohord
710 AC                   parm                    k_kohndt
710 A /free
710 A          leavesr;
710 A       endif;
710 A /end-free
710 A
650aA ***  Get Parent Item Information
650aAC                   exsr      clr$item
650aAC                   eval      $itwhse  = $pwhse
650aAC                   eval      $ititem  = kccitm

650aAC                   eval      $dricommand = '*ITEM'
650aAC                   eval      $drisubcmd  = '%GETALL'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      chk4err = *on
650aAC                   eval      zmsflag = *on
650aAC                   exsr      zzzdricop
650aAC                   if        drierr
650aAC                   goto      endrmzslt
650aAC                   endif

650aA *** Retrieve Repack Slot for Parent Item
650aAC                   exsr      clr$slot
650aAC                   eval      $slwhseu = *on
650aAC                   eval      $slwhse  = $pwhse
650aAC                   eval      $slwhdpu = *on
650aAC                   eval      $slwhdp  = $itwhdp
650aAC                   eval      $slitemu = *on
650aAC                   eval      $slitem  = kccitm

650aAC                   eval      $dricommand = '*SLOT'
650aAC                   eval      $drisubcmd  = '%GETREPACK'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      chk4err = *on
650aAC                   eval      zmsflag = *on
650aAC                   exsr      zzzdricop
650aAC                   if        drierr
650aAC                   goto      endrmzslt
650aAc                   else
650aAc                   eval      hldisp = $sldisp
650aAC                   endif

650aAc                   if        ($slstk1+$slstk2+$slstk3)=0
650aAc                              and ($slalc1+$slalc2+$slalc3)=0
650aAc                              and ($sltfr1+$sltfr2+$sltfr3)=0
650aAc                              and ($slpck1+$slpck2+$slpck3)=0
650aAc                              and ($slrcv1+$slrcv2+$slrcv3)=0
650aAc                              and ($slphy1+$slphy2+$slphy3)=0
650aAc                              and ($slavl1+$slavl2+$slavl3)=0
650aAC                   exsr      clr$slot
650aAC                   eval      $slwhseu = *on
650aAC                   eval      $slwhse  = $pwhse
650aAC                   eval      $slwhdpu = *on
650aAC                   eval      $slwhdp  = $itwhdp
650aAC                   eval      $sldispu = *on
650aAC                   eval      $sldisp  = hldisp

650aAC                   eval      $dricommand = '*SLOT'
650aAC                   eval      $drisubcmd  = '%DELETE'
650aAC                   eval      $drisys2upd = 'D'
650aAC                   eval      chk4err = *on
650aAC                   eval      zmsflag = *off
650aAC                   exsr      zzzdricop
650aAC                   endif

650aAC     endrmzslt     endsr

     *----------------------------------------------------------------
     *  ZZDEL    Delete corresponding records.
     *----------------------------------------------------------------

     C     zzdel         begsr
     C                   eval      error = *off
     C     fileky        chain(e)  kitordh
     C                   if        %found
     C                   eval      kohsta = '4'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      'CVTDTE'
     C                   parm                    $cvtdt
     C                   eval      kohcdt = $cvd8o
     C                   time                    kohctm
     C                   update    record
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pord
     C                   kfld                    $pitem

     C     kitkey        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

     C                   endsr

     *----------------------------------------------------------------
     *  ZZOK     Send back "successful" message.
     *----------------------------------------------------------------

     C     zzok          begsr
     C                   eval      $md = *blanks
     C                   eval      errmsg = %trim(msg(1))
     C                                    + ' '
     C                                    + %trim(%editc($pord:'Z'))
     C                   movea     errmsg        $md(1)
     C                   exsr      zm9803
     C                   eval      $prtn = '*OK     '
     C                   endsr

     *----------------------------------------------------------------
      *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

510aAC                   select
510aMC                   when      $dricommand = '*ITEM'
530 AC                             or $dricommand = '*SLOT'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
510aMC                   endsl

     C                   select

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
     C                   if        zmsflag
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  Compile time tables
     *----------------------------------------------------------------
**
Work Order
