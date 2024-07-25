600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDLT003    Create RCV slots for some LP's
     *  21 May 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  File Specs
     *
600aAFLicense   uf a e           k disk
     FLabel     o  a e           k disk
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
600aA /COPY *libl/qcopysrc,C#SLOT
600aA /COPY *libl/qcopysrc,C#LICINFO
600aA /COPY *libl/qcopysrc,C#LICENSE
600aA /COPY *libl/qcopysrc,C#ITEM
600aAD savever#        s                   like($slver#)

     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pitem                22     36
     D  $ppo                  37     45
     D  $prq1                 46     50  0
     D  $prq2                 51     55  0
     D  $prq3                 56     60  0
     D  $prpal                61     63  0

600aA*  Extra parameters not part of data structure.

600aAD $pindt          s              8  0
600aAD $pfifo          s              8  0

     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
416aAD  $ltype                81     88
     *
     *   Redefine key
     *
     *                                      19  210$LWHSE
     D  $lwhdp                22     26
     D  $lrack                22     26
     *
416 AD  $lwhse                19     21  0
416 AD  $lrte                 22     26
416 AD  $lpo                  27     35
416 AD  $ltrn#                36     42  0
     *
     *
     D  $lbld                 19     20
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @addtr          c                   const('ADDSTDTRN')
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
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
     *
     D  erqty1                 1      4p 0
     D  erqty2                 5      8p 0
     D  eruom                  9     13
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
     * Data structure
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
600aA /COPY *libl/qcopysrc,C#PGMINFDS
600aAD*               sds
600aAD* #prog            *proc
600aAD* #job                 244    253
600aAD* #user                254    263
600aAD* #jobn                264    269
600aAD* #jobdt               276    281  0
600aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D #pgmq           s             10
600aAD ck4err          s              1
     D clear           s              5  0
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s               n
     D forevr          s              1
     D help            s              5  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
     D newlbl#         s              7  0
     D lcns            s             15
     D pctr            s              3  0
     D ptqty           s              6  0
     D pttrn#          s              7  0
     D q1flg           s              1
     D q1lft           s              5  0
     D q2flg           s              1
     D q2lft           s              5  0
     D q3flg           s              1
     D q3lft           s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D tmpflg          s              1
     D today           s              8  0
     D today6          s              6  0
600aAD w1qty           s                   like($prq1)
600aAD w1umt           s              1
600aAD zmflag          s               n
600aAD zmsflag         s               n

600aAD #rcvarea        s              6
600aAD #rcvitem        s                   like($ititem)
600aAD #rcvtype        s                   like($ittype)
600aAD #rcvdesc        s                   like($itdesc)
600aAD #rcvpdsc        s                   like($itpdsc)
600aAD #rcvwhdp        s                   like($itwhdp)
600aAD #rcvstyp        s                   like($itstyp)
600aAD #rcvdesg        s                   like($itdesg)
600aAD #rcvum1         s                   like($itum1)
600aAD #rcvflg1        s                   like($itflg1)
600aAD #rcvum2         s                   like($itum2)
600aAD #rcvumq2        s                   like($itumq2)
600aAD #rcvflg2        s                   like($itflg2)
600aAD #rcvum3         s                   like($itum3)
600aAD #rcvumq3        s                   like($itumq3)
600aAD #rcvdday        s                   like($imdday)
600aAD #rcvmday        s                   like($immday)
600aAD #rcvmflg        s                   like($immflg)
600aAD #rcvuday        s                   like($imuday)
600aAD #rcvnrpk        s                   like($imnrpk)
600aAD #rcvflgd        s                   like($itflgd)
600aAD #rcvcube        s                   like($itcube)
600aAD #rcvswgt        s                   like($itswgt)
600aAD #rcvupc         s                   like($itupc)

600aAD #slotitem       s                   like($ititem)
600aAD #slottype       s                   like($ittype)
600aAD #rcvcwgt        s                   like($itcwgt)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Update licnese #.
     *              *VIEW    - View only
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Unchanged.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $pwhse = 1
     C                   eval      $pitem = '073056'
     C                   exsr      zzinz2
     *
     C                   eval      w1qty = 2
     C                   eval      pttrn# = 523953
     C                   eval      newlbl# = 5797094
     C                   eval      lcns    = '1022711'
     C                   exsr      zzurcvslot


     C                   eval      $pwhse = 1
     C                   eval      $pitem = '071738'
     C                   exsr      zzinz2
     *
     C                   eval      w1qty = 1
     C                   eval      pttrn# = 523937
     C                   eval      newlbl# = 5797075
     C                   eval      lcns    = '1022712'
     C                   exsr      zzurcvslot
     *
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      e = 0
600aA
600aA*  Use DRI interface to get item.
600aA
600aAC                   exsr      clr$item
600aAC                   eval      $itwhse  = $pwhse
600aAC                   eval      $ititem  = $pitem
600aA
600aAC                   eval      $dricommand = '*ITEM'
600aAC                   eval      $drisubcmd  = '%GETALL'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      ck4err = *on
600aAC                   exsr      zzzdricop
600aAC                   if        error
600aAC                   clear                   #rcvitem
600aAC                   clear                   #rcvtype
600aAC                   clear                   #rcvdesc
600aAC                   clear                   #rcvpdsc
600aAC                   clear                   #rcvwhdp
600aAC                   clear                   #rcvstyp
600aAC                   clear                   #rcvdesg
600aAC                   clear                   #rcvum1
600aAC                   clear                   #rcvflg1
600aAC                   clear                   #rcvum2
600aAC                   clear                   #rcvumq2
600aAC                   clear                   #rcvflg2
600aAC                   clear                   #rcvum3
600aAC                   clear                   #rcvumq3
600aAC                   clear                   #rcvnrpk
600aAC                   clear                   #rcvmflg
600aAC                   clear                   #rcvdday
600aAC                   clear                   #rcvmday
600aAC                   clear                   #rcvuday
600aAC                   clear                   #rcvflgd
600aAC                   clear                   #rcvcube
600aAC                   clear                   #rcvswgt
600aAC                   clear                   #slotitem
600aAC                   clear                   #slottype
600aAC                   clear                   #rcvcwgt
600aAC                   goto      enditm
600aAC                   endif
600aA
600aAC                   eval      #rcvitem = $ititem
600aAC                   eval      #rcvtype = $ittype
600aAC                   eval      #rcvdesc = $itdesc
600aAC                   eval      #rcvpdsc = $itpdsc
600aAC                   eval      #rcvwhdp = $itwhdp
600aAC                   eval      #rcvstyp = $itstyp
600aAC                   eval      #rcvdesg = $itdesg
600aAC                   eval      #rcvum1  = $itum1
600aAC                   eval      #rcvflg1 = $itflg1
600aAC                   eval      #rcvum2  = $itum2
600aAC                   eval      #rcvumq2 = $itumq2
600aAC                   eval      #rcvflg2 = $itflg2
600aAC                   eval      #rcvum3  = $itum3
600aAC                   eval      #rcvumq3 = $itumq3
600aAC                   eval      #rcvnrpk = $imnrpk
600aAC                   eval      #rcvmflg = $immflg
600aAC                   eval      #rcvdday = $imdday
600aAC                   eval      #rcvmday = $immday
600aAC                   eval      #rcvuday = $imuday
600aAC                   eval      #rcvflgd = $itflgd
600aAC                   eval      #rcvcube = $itcube
600aAC                   eval      #rcvswgt = $itswgt
600aAC                   eval      #rcvcwgt = $itcwgt
600aA
600aAC     enditm        tag
600aA*
600aA*    Get User's employee number to be written to PORCV file
600aA*    if any records are flagged as touched.
600aA*
600aAC                   call      'GETUSER'
600aAC                   parm      #curruser     $code            10
600aAC                   parm      0             $whse             3 0
600aAC                   parm      0             $emp#             5 0
600aAC                   parm      *blanks       $fnam            15
600aAC                   parm      *blanks       $init             1
600aAC                   parm      *blanks       $lnam            20
600aAC                   parm      *blanks       $whdp             5
600aAC                   parm      *blanks       $styp             1
600aAC                   parm      *blanks       $shft             6
600aAC                   parm      *blanks       $crew             6
600aAC                   parm      0             $nhrs             3 1
600aAC                   parm      *blanks       $rtn              8
     *
     C                   endsr
600aA*---------------------------------------------------------------
600aA*
600aA*  zzurcvSlot   Put license into RCV slot
600aA*
600aAC     zzurcvSlot    begsr

     *  Put license into a RCV slot

     C                   eval      #rcvArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #rcvwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = #rcvitem
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #rcvstyp
     C****               eval      $slexpdu = *on
     C****               eval      $slexpd = $pexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #rcvitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = w1qty
     C**                 eval      $saqty2 = w1qty
     C**                 eval      $saqty3 = w1qty

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'RCV'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = pttrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = newlbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on

     C                   eval      $saToLcns = lcns

     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea
     C                   eval      $saOLcnsU = *on
     C                   eval      $lnlcns  = $saToLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endurcvslot
     C                   endif

     C     endurcvslot   endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*                     DRI SUBROUTINES
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  clr$item  Clear $item data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$license  Clear $license data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$licinfo  Clear $licinfo data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #curruser
     C                   eval      $lnemp# = $emp#
     C                   eval      $lnpgm  = #pgm
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobnbr

     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$slot  Clear $slot data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  zzzdricop  Call DRICOP
600aA*----------------------------------------------------------------
600aA
600aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
600aAC                   eval      errmsg    = 'Error occured on call to '
600aAC                                       + 'DRICOP'
600aAC                                       + '/' + %trim($drisubcmd)
600aAC                                       + ' from ' + #pgm
600aAC*                  select
600aAC*                  when      zmsflag
600aAC*                  exsr      zm0105s
600aAC*                  when      zmflag
600aAC*                  exsr      zm0105
600aAC*                  endsl

417yMC                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
600aAC*                  select
600aAC*                  when      zmsflag
600aAC*                  exsr      zm0001s
600aAC*                  when      zmflag
600aAC*                  exsr      zm0001
     C*                  exsr      zzerrind
600aAC*                  endsl

     C                   endsl

     C                   select
417yAC                   when      $dricommand = '*SLOT'
417yAC                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
600aAC                   when      $dricommand = '*LICENSE'
600aAC                   eval      $license = $dridata
600aAC                   eval      $license2 = $dridata2
500 AC                   when      $dricommand = '*ITEM'
500 AC                   eval      $item = $dridata
500 AC                   eval      $item2 = $dridata2
     C                   endsl

600aAC                   eval      zmflag = *off
600aAC                   eval      zmsflag = *off
417yAC                   eval      ck4err = *off
     C     enddricop     endsr
