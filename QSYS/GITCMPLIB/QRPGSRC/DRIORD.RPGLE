     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIORD      Dakota realtime interface - Customer orders
     *  16 May 2002
     *  Dave Sommerville
     *
416  *    05/16/02  DAS  4.16
     *      - Created
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
      *      *ADDDTL           Add order detail line.
      *
      *      *ADDHDR           Add order header.
      *
      *      *CHGDTL           Change order detail line.
      *
      *      *CHGHDR           Change order header.
      *
      *      *CRTRTE           Create route header.
      *
      *      *DELDTL           Delete order detail line.
      *
      *      *DELORD           Delete order.
      *
      *      *DELRTE           Delete route.
      *
      *      *GETDTL           Get order detail info using order id.
      *
      *      *GETHDR           Get order header info using order id.
      *
      *      *GETHDRWCO        Get order header info using customer ord#.
      *
      *      *RTVCORD          Retrieve order using customer ord#.
      *
      *      *RTVCORDDT        Retrieve order detail.
      *                        ** Only sent to Host from this program **
      *
      *      *RTVCORDHD        Retrieve order header using customer order #
      *                        ** Only sent to Host from this program **
      *
      *      *UPDSTAT          Update status.
      *
      *      *VFYADDDTL        Do "*ADDDTL" verification without update.
      *      *VFYADDHDR        Do "*ADDHDR" verification without update.
      *      *VFYCHGDTL        Do "*CHGDTL" verification without update.
      *      *VFYCHGHDR        Do "*CHGHDR" verification without update.
      *      *VFYDELDTL        Do "*DELDTL" verification without update.
      *      *VFYDELORD        Do "*DELORD" verification without update.
      *      *VFYDELRTE        Do "*DELRTE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordd      uf a e           k disk    infds(file1ds)
     Fordh      uf a e           k disk    infds(file2ds)
     Frtehed    uf a e           k disk    infds(file3ds)
     Frtesum    uf a e           k disk    infds(file4ds)
416bAF                                     usropn
416bAFordh3     uf   e           k disk    usropn
     F                                     rename(ohrec:ohrec3)
416bAFordh5     if   e           k disk    usropn
     F                                     rename(ohrec:ohrec5)
     F*ogord    o    e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDD
      /COPY *libl/qcopysrc,C#ORDH
      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($ohver#)
     D driitem         s               n

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(ohwhse)
     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D check4err       s               n
     D curdate         s              8  0
     D curtime         s              6  0
     D error           s               n
     D forever         s               n   inz(*on)
     D i               s              3  0
     D kyseq           s                   like(odseq)
     D lasttime        s              6  0 inz(999999)
     D orddetail       s               n
     D ordheader       s               n
     D lock            s               n
     D pssrflag        s               n
     D rcvd            s               n
     D rcvdfull        s               n
     D rcvdpart        s               n
     D ssbflag         s               n
     D svitem          s                   like(oditem)
     D vfyfld          s             10    dim(20)

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

     D File3DS         ds
     D  f3filename             1      8
     D  f3openind              9      9
     D  f3endoffile           10     10
     D  f3status              11     15  0
     D  f3opercode            16     21
     D  f3routine             22     29
     D  f3stmtnbr             30     37
     D  f3recordcd            38     45
     D  f3messageid           46     52
     D  f3sourceid            53     54

     D File4DS         ds
     D  f4filename             1      8
     D  f4openind              9      9
     D  f4endoffile           10     10
     D  f4status              11     15  0
     D  f4opercode            16     21
     D  f4routine             22     29
     D  f4stmtnbr             30     37
     D  f4recordcd            38     45
     D  f4messageid           46     52
     D  f4sourceid            53     54

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return message
      *      $pdata     Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

     *  Determine data structure to work with.


     C                   if        $psubcmd = '*ADDHDR'    or
     C                             $psubcmd = '*CHGHDR'    or
     C                             $psubcmd = '*CRTRTE'    or
     C                             $psubcmd = '*DELORD'    or
     C                             $psubcmd = '*DELRTE'    or
     C                             $psubcmd = '*GETHDR'    or
     C                             $psubcmd = '*GETHDRWCO' or
     C                             $psubcmd = '*RTVCORD' or
     C                             $psubcmd = '*UPDSTAT'   or
     C                             $psubcmd = '*VFYADDHDR' or
     C                             $psubcmd = '*VFYCHGHDR' or
     C                             $psubcmd = '*VFYDELORD' or
     C                             $psubcmd = '*VFYDELRTE'
     C                   eval      ordheader = *on
     C                   eval      orddetail = *off
     C                   else
     C                   eval      ordheader = *off
     C                   eval      orddetail = *on
     C                   endif

     C                   if        ordheader
     C                   eval      $ordh = $pdata
     C                   else
     C                   eval      $ordd = $pdata
     C                   endif

     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   endif
     C                   exsr      aaaclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADDDTL'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      dtlvfyadd
     C                   if        not error
     C                   exsr      dtladd
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*ADDHDR'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      hdrvfyadd
     C                   if        not error
     C                   exsr      hdradd
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHGDTL'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      dtlvfychg
     C                   if        not error
     C                   exsr      dtlchg
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHGHDR'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      hdrvfychg
     C                   if        not error
     C                   exsr      hdrchg
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CRTRTE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      rtevfycrt
     C                   if        not error
     C                   exsr      rtecrt
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELDTL'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      dtlvfydel
     C                   if        not error
     C                   exsr      dtldel
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELORD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      hdrvfydel
     C                   if        not error
     C                   exsr      hdrdel
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELRTE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   endif
     C                   if        not error
     C                   exsr      rtevfydel
     C                   if        not error
     C                   exsr      rtedel
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GETDTL'
     C                   exsr      vfygetdtl
     C                   if        not error
     C                   eval      lock = *off
     C                   exsr      getordd
     C                   if        not error
     C                   exsr      ordd2ds
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GETHDR'
     C                   exsr      vfygethdr
     C                   if        not error
     C                   eval      lock = *off
     C                   exsr      getordh
     C                   if        not error
     C                   eval      lock = *off
     C                   eval      check4err = *off
     C                   eval      $ohrid = ohrte
     C                   exsr      getrte
     C                   exsr      ordh2ds
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GETHDRWCO'
     C                   exsr      vfygethdrwco
     C                   if        not error
     C                   eval      lock = *off
     C                   exsr      getordhwco
     C                   if        not error
     C                   eval      check4err = *off
     C                   eval      $ohrid = ohrte
     C                   exsr      getrte
     C                   exsr      ordh2ds
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*RTVCORD'
     C                   exsr      vfyrtvcord
     C                   if        not error
     C                   exsr      rtvcord
     C                   endif

     C                   when      $psubcmd = '*VFYADDDTL'
     C                   exsr      dtlvfyadd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYADDHDR'
     C                   exsr      hdrvfyadd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYCHGDTL'
     C                   exsr      dtlvfychg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYCHGHDR'
     C                   exsr      hdrvfychg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYDELDTL'
     C                   exsr      dtlvfydel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYDELORD'
     C                   exsr      hdrvfydel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYDELRTE'
     C**                 exsr      rtevfydel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '

     C                   endsl

     C     bottom        tag

     *  Log it

     C                   exsr      writelog

     *  We are finished so get out

     C                   if        ordheader
     C                   eval      $pdata = $ordh
     C                   else
     C                   eval      $pdata = $ordd
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for ORDH file.

     C     keyoh         klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohoid

     *  Define key for ORDH5 file.

     C     keyoh5        klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohcord

     *  Define key for ORDD file.

     C     keyod         klist
     C                   kfld                    $odwhse
     C                   kfld                    $odoid
     C                   kfld                    $odseq
     C                   kfld                    $oditem

     *  Define partial key for ORDD file.

     C     keyods        klist
     C                   kfld                    $odwhse
     C                   kfld                    $odoid
     C                   kfld                    $odseq

     *  Define key for RTEHED file.

     C     keyrh         klist
     C                   kfld                    $ohwhse
     C                   kfld                    $ohrid

     C                   endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaaclose  Close open programs
     *----------------------------------------------------------------

     C     aaaclose      begsr

     C                   if        driitem
     C                   call(e)   'DRIITEM'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   eval      driitem = *off
     C                   endif

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      0             $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   eval      vfywhse = *off
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr

     C                   if        ordheader
     C                   eval      $dricommand = '*ORD'
     C                   eval      $dridata = $ordh
     C                   else
     C                   eval      $dricommand = '*ORD'
     C                   eval      $dridata = $ordd
     C                   endif

     C                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIMAIN2'
     C                                       + '/' + %trim($dricommand)
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      $drireturn <> '*OK' and
     C                             $drireturn <> '*NOPROGRAM'
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = 'H:' + $drimessage

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost2  Call host program.
     *----------------------------------------------------------------

     C     aaacallhost2  begsr

     C                   if        $drisubcmd = '*RTVCORDHD'
     C                   eval      $dricommand = '*ORD'
     C                   eval      $dridata = $ordh
     C                   else
     C                   eval      $dricommand = '*ORD'
     C                   eval      $dridata = $ordd
     C                   endif

     C                   call(e)   'DRIMAIN2'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIMAIN2'
     C                                       + '/' + %trim($dricommand)
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   when      $drireturn <> '*OK' and
     C                             $drireturn <> '*EOF'
     C                   eval      error = *on
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = 'H:' + $drimessage

     C                   endsl

     C                   if        $drisubcmd = '*RTVCORDHD'
     C                   eval      $ordh = $dridata
     C                   else
     C                   eval      $ordd = $dridata
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     *  Header flags

     C                   select
     C                   when      ordheader

     C                   if        $ohwhsee = '1'
     C                   eval      $ohwhsee = '0'
     C                   endif

     C                   if        $ohoide  = '1'
     C                   eval      $ohoide  = '0'
     C                   endif

     C                   if        $ohorige = '1'
     C                   eval      $ohorige = '0'
     C                   endif

     C                   if        $ohtypee = '1'
     C                   eval      $ohtypee = '0'
     C                   endif

     C                   if        $ohcuste = '1'
     C                   eval      $ohcuste = '0'
     C                   endif

     C                   if        $ohcorde = '1'
     C                   eval      $ohcorde = '0'
     C                   endif

     C                   if        $ohcpoe  = '1'
     C                   eval      $ohcpoe  = '0'
     C                   endif

     C                   if        $ohcname = '1'
     C                   eval      $ohcname = '0'
     C                   endif

     C                   if        $ohcad1e = '1'
     C                   eval      $ohcad1e = '0'
     C                   endif

     C                   if        $ohcad2e = '1'
     C                   eval      $ohcad2e = '0'
     C                   endif

     C                   if        $ohcctye = '1'
     C                   eval      $ohcctye = '0'
     C                   endif

     C                   if        $ohcste  = '1'
     C                   eval      $ohcste  = '0'
     C                   endif

     C                   if        $ohczipe = '1'
     C                   eval      $ohczipe = '0'
     C                   endif

     C                   if        $ohrtee  = '1'
     C                   eval      $ohrtee  = '0'
     C                   endif

     C                   if        $ohstope = '1'
     C                   eval      $ohstope = '0'
     C                   endif

     C                   if        $ohtruke = '1'
     C                   eval      $ohtruke = '0'
     C                   endif

     C                   if        $ohmisce = '1'
     C                   eval      $ohmisce = '0'
     C                   endif

     C                   if        $ohpbate = '1'
     C                   eval      $ohpbate = '0'
     C                   endif

     C                   if        $ohstate = '1'
     C                   eval      $ohstate = '0'
     C                   endif

     C                   if        $ohsdtee = '1'
     C                   eval      $ohsdtee = '0'
     C                   endif

     C                   if        $ohstime = '1'
     C                   eval      $ohstime = '0'
     C                   endif

     C                   if        $ohudtee = '1'
     C                   eval      $ohudtee = '0'
     C                   endif

     C                   if        $ohutime = '1'
     C                   eval      $ohutime = '0'
     C                   endif

     *  Detail flags

     C                   other

     C                   if        $odwhsee = '1'
     C                   eval      $odwhsee = '0'
     C                   endif

     C                   if        $odoide  = '1'
     C                   eval      $odoide  = '0'
     C                   endif

     C                   if        $odseqe  = '1'
     C                   eval      $odseqe  = '0'
     C                   endif

     C                   if        $oditeme  = '1'
     C                   eval      $oditeme  = '0'
     C                   endif

     C                   if        $odqor1e  = '1'
     C                   eval      $odqor1e  = '0'
     C                   endif

     C                   if        $odqor2e  = '1'
     C                   eval      $odqor2e  = '0'
     C                   endif

     C                   if        $odqor3e  = '1'
     C                   eval      $odqor3e  = '0'
     C                   endif

     C                   if        $odwh2e   = '1'
     C                   eval      $odwh2e   = '0'
     C                   endif

     C                   if        $odor2e   = '1'
     C                   eval      $odor2e   = '0'
     C                   endif

     C                   if        $odoitme  = '1'
     C                   eval      $odoitme  = '0'
     C                   endif

     C                   if        $odspcle  = '1'
     C                   eval      $odspcle  = '0'
     C                   endif

     C                   if        $odqpk1e  = '1'
     C                   eval      $odqpk1e  = '0'
     C                   endif

     C                   if        $odqpk2e  = '1'
     C                   eval      $odqpk2e  = '0'
     C                   endif

     C                   if        $odqpk3e  = '1'
     C                   eval      $odqpk3e  = '0'
     C                   endif

     C                   if        $odstate  = '1'
     C                   eval      $odstate  = '0'
     C                   endif

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  dtladd    Add PO detail record.
     *----------------------------------------------------------------

     C     dtladd        begsr

     *  Clear slot record.

     C                   clear                   odrec

     *  Move information into slot def fields.

     C                   eval      odwhse = $odwhse
     C                   eval      odord  = $odoid
     C                   eval      odseq  = $odseq
     C                   eval      oditem = $oditem

     C                   eval      odqor1 = $odqor1
     C                   eval      odqor2 = $odqor2
     C                   eval      odqor3 = $odqor3

     C                   eval      odwh2  = $odwh2
     C                   eval      odor2  = $odor2
     C                   eval      odoitm = $odoitm
     C                   eval      odspcl = $odspcl

     C                   eval      odqpk1 = $odqpk1
     C                   eval      odqpk2 = $odqpk2
     C                   eval      odqpk3 = $odqpk3

     C                   eval      odstat = 'O'

     *  Add record

     C                   write(e)  odrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Order Detail" command '
     C                                       + '('
     C                                       + %Trim(%editc(odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + '/'
     C                                       + %trim(oditem)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      enddtladd
     C                   endif

     C     enddtladd     endsr

     *----------------------------------------------------------------
     *  dtlchg      Change order detail record.
     *----------------------------------------------------------------

     C     dtlchg        begsr

     *  Get & lock detail information.

     C                   eval      lock = *on
     C                   exsr      getordd
     C                   if        error
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $odseqe = '1'
     C                   eval      $oditeme = '1'
     C                   goto      enddtlchg
     C                   endif

     *  Move information into po detail fields.

     C                   if        $odqor1u
     C                   eval      odqor1 = $odqor1
     C                   endif

     C                   if        $odqor2u
     C                   eval      odqor2 = $odqor2
     C                   endif

     C                   if        $odqor3u
     C                   eval      odqor3 = $odqor3
     C                   endif

     C                   if        $odwh2u
     C                   eval      odwh2  = $odwh2
     C                   endif

     C                   if        $odor2u
     C                   eval      odor2  = $odor2
     C                   endif

     C                   if        $odoitmu
     C                   eval      odoitm = $odoitm
     C                   endif

     C                   if        $odspclu
     C                   eval      odspcl = $odspcl
     C                   endif

     C                   if        $odqpk1u
     C                   eval      odqpk1 = $odqpk1
     C                   endif

     C                   if        $odqpk2u
     C                   eval      odqpk2 = $odqpk2
     C                   endif

     C                   if        $odqpk3u
     C                   eval      odqpk3 = $odqpk3
     C                   endif

     C                   if        $odstatu
     C                   eval      odstat = $odstat
     C                   endif

     *  Update record

     C                   update(e) odrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Order Detail" command '
     C                                       + '('
     C                                       + %Trim(%editc(odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + '/'
     C                                       + %trim(oditem)
     C                                       + ')'
     C                                       + '-' + f1messageid

     C                   goto      enddtlchg
     C                   endif

     C     enddtlchg     endsr

     *----------------------------------------------------------------
     *  dtldel      Delete PO detail record.
     *----------------------------------------------------------------

     C     dtldel        begsr
     C                   eval      error = *off

     C*  Get and lock detail.

     C                   eval      lock = *on
     C                   exsr      getordd

     C                   if        error
     C                   goto      enddtldel
     C                   endif

      *  Delete po detail record.

     C                   delete(e) odrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Order '
     C                                       + 'Detail" command '
     C                                       + '('
     C                                       + %Trim(%editc($odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($odoid:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + '/'
     C                                       + %trim(oditem)
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid

     C                   goto      enddtldel
     C                   endif

     C     enddtldel     endsr

     *----------------------------------------------------------------
     *  dtlvfyadd  Verify PO detail information when adding.
     *----------------------------------------------------------------

     C     dtlvfyadd     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = '$odseq'
     C                   eval      vfyfld(4) = '$oditem'
     C                   eval      vfyfld(5) = ' '

     C                   exsr      vfydtlsent
     C     error         cabeq     *on           enddtlvfyadd

     *  Check that some fields have not been sent.

     C                   eval      vfyfld(1) = '$odqpk'
     C                   eval      vfyfld(2) = '$odstat'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfydtlnotsnt
     C     error         cabeq     *on           enddtlvfyadd

     *  Initialize fields that have not been sent.

     C                   exsr      inzdtlflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = 'ohexist'
     C                   eval      vfyfld(4) = 'ohopen'
     C                   eval      vfyfld(5) = '$odseq'
     C                   eval      vfyfld(6) = '$oditem'
     C                   eval      vfyfld(7) = 'odnotexist'
     C                   eval      vfyfld(8) = '$odqor'
     C                   eval      vfyfld(9) = ' '

     C                   exsr      vfydtlflds
     C     error         cabeq     *on           enddtlvfyadd

     C     enddtlvfyadd  endsr

     *----------------------------------------------------------------
     *  dtlvfychg  Verify PO detail information when changing
     *----------------------------------------------------------------

     C     dtlvfychg     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = '$odseq'
     C                   eval      vfyfld(4) = '$oditem'
     C                   eval      vfyfld(5) = ' '

     C                   exsr      vfydtlsent
     C     error         cabeq     *on           enddtlvfychg

     *  Check that some fields have not been sent.

     C                   eval      vfyfld(1) = '$odqpk'
     C                   eval      vfyfld(2) = '$odstat'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfydtlnotsnt
     C     error         cabeq     *on           enddtlvfychg

     *  Initialize fields that have not been sent.

     C                   exsr      inzdtlflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = 'ohexist'
     C                   eval      vfyfld(4) = 'ohopen'
     C                   eval      vfyfld(5) = '$odseq'
     C                   eval      vfyfld(6) = '$oditem'
     C                   eval      vfyfld(7) = 'odexist'
     C                   eval      vfyfld(8) = '$odqor'
     C                   eval      vfyfld(9) = ' '

     C                   exsr      vfydtlflds
     C     error         cabeq     *on           enddtlvfychg

     C     enddtlvfychg  endsr

     *----------------------------------------------------------------
     *  dtlvfydel  Delete Order detail verification
     *----------------------------------------------------------------

     C     dtlvfydel     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = '$odseq'
     C                   eval      vfyfld(4) = '$oditem'
     C                   eval      vfyfld(5) = ' '

     C                   exsr      vfydtlsent
     C     error         cabeq     *on           enddtlvfydel

     *  Verify fields.

     C                   eval      vfyfld(1) = 'odexist'
     C                   eval      vfyfld(2) = 'odopen'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfydtlflds
     C     error         cabeq     *on           enddtlvfydel

     C     enddtlvfydel  endsr

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
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $odwhse
     C                   eval      $ititem = $oditem

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $oditeme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

     *----------------------------------------------------------------
     *  getordd   Get order detail info.
     *----------------------------------------------------------------

     C     getordd       begsr

     C                   if        lock
     C     keyod         chain     ordd
     C                   else
     C     keyod         chain(n)  ordd
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'DTLNOTFND'
     C                   eval      $pmessage = 'Order detail not found '
     C                                       + '('
     C                                       + %Trim(%editc($odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($odoid:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + '/'
     C                                       + %trim(oditem)
     C                                       + ')'
     C                   goto      endgetordd
     C                   endif

     C     endgetordd    endsr

     *----------------------------------------------------------------
     *  getordh   Get order header info using order id.
     *----------------------------------------------------------------

     C     getordh       begsr

     C                   if        lock
     C     keyoh         chain     ordh
     C                   else
     C     keyoh         chain(n)  ordh
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'HDRNOTFND'
     C                   eval      $pmessage = 'Order header not found '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohoid:'Z'))
     C                                       + ')'
     C                   goto      endgetordh
     C                   endif

     C     endgetordh    endsr

     *----------------------------------------------------------------
     *  getordhwco  Get order header info with customer ord#
     *----------------------------------------------------------------

     C     getordhwco    begsr

     *  Open ORDH5 file.

     C                   if        not %open(ordh5)
     C                   exsr      openordh5
     C                   if        error
     C                   goto      endgetordhwco
     C                   endif
     C                   endif

     *  Get first matching record (assumes unique customer orders)

     C     keyoh5        setll     ordh5
     C     keyoh5        reade     ordh5
 2B
 2B  C                   if        %eof
     C                   eval      error = *on
     C                   eval      $preturn = 'CORDNOTFND'
     C                   eval      $pmessage = 'Customer order not found '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohcord:'Z'))
     C                                       + ')'
     C                   goto      endgetordhwco
 2E  C                   endif

     C     endgetordhwco endsr

     *----------------------------------------------------------------
     *  getrte    Get route header info.
     *----------------------------------------------------------------

     C     getrte        begsr

     C                   if        lock
     C     keyrh         chain     rtehed
     C                   else
     C     keyrh         chain(n)  rtehed
     C                   endif

     C                   if        not %found

     C                   if        check4err = *off
     C                   clear                   rhrec
     C                   else
     C                   eval      error = *on
     C                   eval      $preturn = 'RTENOTFND'
     C                   eval      $pmessage = 'Route header not found '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim($ohrid)
     C                                       + ')'
     C                   endif

     C                   goto      endgetrte
     C                   endif

     C     endgetrte     endsr

     *----------------------------------------------------------------
     *  hdradd    Add PO header record.
     *----------------------------------------------------------------

     C     hdradd        begsr

     C                   exsr      getdatetime

     *  See if new route header needs to be created.

     C                   if        $ohrid = ' '
     C                   exsr      rtecrt
     C     error         cabeq     *on           endhdradd
     C                   endif

     *  Clear slot record.

     C                   clear                   ohrec

     *  Move information into slot def fields.

     C                   eval      ohwhse = $ohwhse

     C                   call      'PIRORD#'
     C                   parm                    ohwhse
     C                   parm                    ohord

     C                   eval      ohtype = $ohtype
     C                   eval      ohorig = $ohorig
     C                   eval      ohcust = $ohcust
     C                   eval      ohcord = $ohcord
     C                   eval      ohcnam = $ohcnam
     C                   eval      ohcad1 = $ohcad1
     C                   eval      ohcad2 = $ohcad2
     C                   eval      ohccty = $ohccty
     C                   eval      ohcst  = $ohcst
     C                   eval      ohczip = $ohczip
     C                   eval      ohrte  = rhrtid
     C                   eval      ohstop = $ohstop
     C                   eval      ohtruk = $ohtruk
     C                   eval      ohmisc = $ohmisc
     C                   eval      ohpbat = $ohpbat

     C                   eval      ohstat = 'O'
     C                   eval      ohsdte = curdate
     C                   eval      ohstim = curtime

     C                   eval      ohudte = $ohudte
     C                   eval      ohutim = $ohutim

     *  Add record

     C                   write(e)  ohrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Order Header" command '
     C                                       + '('
     C                                       + %Trim(%editc(ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(ohord:'Z'))
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endhdradd
     C                   endif

     *  Move record fields back into data structure because some changed.

     C                   exsr      ordh2ds

     C     endhdradd     endsr

     *----------------------------------------------------------------
     *  hdrchg      Change Order header record.
     *----------------------------------------------------------------

     C     hdrchg        begsr

     *  Get & lock header information.

     C                   eval      lock = *on
     C                   exsr      getordh
     C                   if        error
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   goto      endhdrchg
     C                   endif

     *  Move information into po header fields.

     C                   if        $ohorigu
     C                   eval      ohorig = $ohorig
     C                   endif

     C                   if        $ohtypeu
     C                   eval      ohtype = $ohtype
     C                   endif

     C                   if        $ohcustu
     C                   eval      ohcust = $ohcust
     C                   endif

     C                   if        $ohcordu
     C                   eval      ohcord = $ohcord
     C                   endif

     C                   if        $ohcnamu
     C                   eval      ohcnam = $ohcnam
     C                   endif

     C                   if        $ohcad1u
     C                   eval      ohcad1 = $ohcad1
     C                   endif

     C                   if        $ohcad2u
     C                   eval      ohcad2 = $ohcad2
     C                   endif

     C                   if        $ohcctyu
     C                   eval      ohccty = $ohccty
     C                   endif

     C                   if        $ohcstu
     C                   eval      ohcst  = $ohcst
     C                   endif

     C                   if        $ohczipu
     C                   eval      ohczip = $ohczip
     C                   endif

     C                   if        $ohrteu
     C                   eval      ohrte  = $ohrte
     C                   endif

     C                   if        $ohstopu
     C                   eval      ohstop = $ohstop
     C                   endif

     C                   if        $ohtruku
     C                   eval      ohtruk = $ohtruk
     C                   endif

     C                   if        $ohmiscu
     C                   eval      ohmisc = $ohmisc
     C                   endif

     C                   if        $ohpbatu
     C                   eval      ohpbat = $ohpbat
     C                   endif

     C                   if        $ohstatu
     C                   eval      ohstat = $ohstat
     C                   endif

     C                   if        $ohsdteu
     C                   eval      ohsdte = curdate
     C                   endif

     C                   if        $ohstimu
     C                   eval      ohstim = curtime
     C                   endif

     C                   if        $ohudteu
     C                   eval      ohudte = $ohudte
     C                   endif

     C                   if        $ohutimu
     C                   eval      ohutim = $ohutim
     C                   endif

     *  Update record

     C                   update(e) ohrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Order Header" command '
     C                                       + '('
     C                                       + %Trim(%editc(ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(ohord:'Z'))
     C                                       + ')'
     C                                       + '-' + f2messageid

     C                   goto      endhdrchg
     C                   endif

     C     endhdrchg     endsr

     *----------------------------------------------------------------
     *  hdrdel      Delete Order header
     *----------------------------------------------------------------

     C     hdrdel        begsr
     C                   eval      error = *off

     *  Get and lock header.

     C                   eval      lock = *on
     C                   exsr      getordh

     C                   if        error
     C                   goto      endhdrdel
     C                   endif

     *  Delete order detail records.

     C     keyoh         setll     ordd

     C                   dow       forever = forever

     C     keyoh         reade     ordd                                 7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDTLLCK'
     C                   eval      $pmessage = 'Error deleting order - '
     C                                       + 'Detail record was locked '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   leave
     C                   endif

     *     Otherwise, delete record.

     C                   delete(e) odrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDTLDEL'
     C                   eval      $pmessage = 'Error deleting Order - '
     C                                       + 'Error deleting detail '
     C                                       + 'record '
     C                                       + '('
     C                                       + %Trim(%editc(odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   leave
     C                   endif

     C                   enddo

     *  If error occured, unlock header and get out.

     C                   if        error
     C                   unlock    ordh
     C                   goto      endhdrdel
     C                   endif

     *  Otherwise, delete header record.

     C                   delete(e) ohrec
     C                   if        %error
     C                   eval      $preturn = 'DELHDRERR'
     C                   eval      $pmessage = 'Error on "Delete Order '
     C                                       + 'Header" command '
     C                                       + '('
     C                                       + %Trim(%editc(ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(ohord:'Z'))
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f2messageid

     C                   goto      endhdrdel
     C                   endif

     C     endhdrdel     endsr

     *----------------------------------------------------------------
     *  hdrvfyadd  Verify Order header information when adding.
     *----------------------------------------------------------------

     C     hdrvfyadd     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohtype'
     C                   eval      vfyfld(3) = '$ohcord'
     C                   eval      vfyfld(4) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endhdrvfyadd

     *  Check that some fields have not been sent.

     C                   eval      vfyfld(1) = '$ohpbat'
     C                   eval      vfyfld(2) = '$ohstat'
     C                   eval      vfyfld(3) = '$ohsdte'
     C                   eval      vfyfld(4) = '$ohstim'
     C                   eval      vfyfld(5) = '$ohudte'
     C                   eval      vfyfld(6) = '$ohutim'
     C                   eval      vfyfld(7) = '$ohoid'
     C                   eval      vfyfld(8) = ' '

     C                   exsr      vfyhdrnotsnt
     C     error         cabeq     *on           endhdrvfyadd

     *  Initialize fields that have not been sent.

     C                   exsr      inzhdrflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohtype'
     C                   eval      vfyfld(3) = '$ohcord'
     C                   eval      vfyfld(4) = '$ohorig'
     C                   eval      vfyfld(5) = '$ohstop'
     C                   eval      vfyfld(6) = '$ohtruk'
     C                   eval      vfyfld(7) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfyadd

     *  Verify route if it was sent.

     C                   if        $ohrid <> ' '
     C                   eval      vfyfld(1) = 'rhexist'
     C                   eval      vfyfld(2) = 'rhopen'
     C                   eval      vfyfld(3) = ' '
     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfyadd
     C                   endif

     C     endhdrvfyadd  endsr

     *----------------------------------------------------------------
     *  hdrvfychg  Verify Order header information when changing.
     *----------------------------------------------------------------

     C     hdrvfychg     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohoid'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endhdrvfychg

     *  Check that some fields have not been sent.

     C                   eval      vfyfld(1) = '$ohrte'
     C                   eval      vfyfld(2) = ' '

     C                   exsr      vfyhdrnotsnt
     C     error         cabeq     *on           endhdrvfychg

     *  Initialize fields that have not been sent.

     C                   exsr      inzhdrflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = 'ohexist'
     C                   eval      vfyfld(3) = 'ohopen'
     C                   eval      vfyfld(4) = '$ohrid'
     C                   eval      vfyfld(5) = '$ohorig'
     C                   eval      vfyfld(6) = '$ohtype'
     C                   eval      vfyfld(7) = '$ohstop'
     C                   eval      vfyfld(8) = '$ohtruk'
     C                   eval      vfyfld(9) = '$ohstat'
     C                   eval      vfyfld(10) = '$ohsdte'
     C                   eval      vfyfld(11) = '$ohudte'
     C                   eval      vfyfld(12) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfychg

     *  Verify route.

     C                   if        not $ohridu
     C                   eval      $ohrid = ohrte
     C                   endif

     C                   eval      vfyfld(1) = 'rhexist'
     C                   eval      vfyfld(2) = 'rhopen'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfychg

     C     endhdrvfychg  endsr

     *----------------------------------------------------------------
     *  hdrvfydel  Delete Order verification
     *----------------------------------------------------------------

     C     hdrvfydel     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohoid'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endhdrvfydel

     *  Verify fields.

     C                   eval      vfyfld(1) = 'ohexist'
     C                   eval      vfyfld(2) = 'ohopen'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfydel

     *  Verify route.

     *    Get route for header record (ignore "sent" route id).

     C                   eval      $ohrid = ohrte
     C                   eval      lock = *off
     C                   eval      check4err = *on
     C                   exsr      getrte

     *    If route can't be found, allow deletion of order.

     C                   if        error
     C                   eval      error     = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '

     *    Otherwise, only allow if route is open.

     C                   else
     C                   eval      vfyfld(1) = 'rhopen'
     C                   eval      vfyfld(2) = ' '
     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endhdrvfydel
     C                   endif

     C     endhdrvfydel  endsr

     *----------------------------------------------------------------
     *  inzdtlflds  Initialize detail fields that weren't sent.
     *----------------------------------------------------------------

     C     inzdtlflds    begsr

     C                   if        not $odqor1u
     C                   eval      $odqor1  = 0
     C                   endif

     C                   if        not $odqor2u
     C                   eval      $odqor2  = 0
     C                   endif

     C                   if        not $odqor3u
     C                   eval      $odqor3  = 0
     C                   endif

     C                   if        not $odwh2u
     C                   eval      $odwh2   = 0
     C                   endif

     C                   if        not $odor2u
     C                   eval      $odor2   = 0
     C                   endif

     C                   if        not $odoitmu
     C                   eval      $odoitm  = ' '
     C                   endif

     C                   if        not $odspclu
     C                   eval      $odspcl  = ' '
     C                   endif

     C                   if        not $odqpk1u
     C                   eval      $odqpk1  = 0
     C                   endif

     C                   if        not $odqpk2u
     C                   eval      $odqpk2  = 0
     C                   endif

     C                   if        not $odqpk3u
     C                   eval      $odqpk3  = 0
     C                   endif

     C                   if        not $odstatu
     C                   eval      $odstat  = ' '
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  inzhdrflds  Initialize header fields that weren't sent.
     *----------------------------------------------------------------

     C     inzhdrflds    begsr

     *  Header flags

     C                   if        not $ohorigu
     C                   eval      $ohorig = ' '
     C                   endif

     C                   if        not $ohtypeu
     C                   eval      $ohtype = ' '
     C                   endif

     C                   if        not $ohcustu
     C                   eval      $ohcust = 0
     C                   endif

     C                   if        not $ohcordu
     C                   eval      $ohcord = 0
     C                   endif

     C                   if        not $ohcpou
     C                   eval      $ohcpo  = ' '
     C                   endif

     C                   if        not $ohcnamu
     C                   eval      $ohcnam = ' '
     C                   endif

     C                   if        not $ohcad1u
     C                   eval      $ohcad1 = ' '
     C                   endif

     C                   if        not $ohcad2u
     C                   eval      $ohcad2 = ' '
     C                   endif

     C                   if        not $ohcctyu
     C                   eval      $ohccty = ' '
     C                   endif

     C                   if        not $ohcstu
     C                   eval      $ohcst  = ' '
     C                   endif

     C                   if        not $ohczipu
     C                   eval      $ohczip = ' '
     C                   endif

     C                   if        not $ohrteu
     C                   eval      $ohrte  = ' '
     C                   endif

     C                   if        not $ohstopu
     C                   eval      $ohstop = 0
     C                   endif

     C                   if        not $ohtruku
     C                   eval      $ohtruk = ' '
     C                   endif

     C                   if        not $ohmiscu
     C                   eval      $ohmisc = ' '
     C                   endif

     C                   if        not $ohpbatu
     C                   eval      $ohpbat = 0
     C                   endif

     C                   if        not $ohstatu
     C                   eval      $ohstat = ' '
     C                   endif

     C                   if        not $ohsdteu
     C                   eval      $ohsdte = 0
     C                   endif

     C                   if        not $ohstimu
     C                   eval      $ohstim = 0
     C                   endif

     C                   if        not $ohudteu
     C                   eval      $ohudte = 0
     C                   endif

     C                   if        not $ohutimu
     C                   eval      $ohutim = 0
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openordh3  Open file Ordh3
416bA*----------------------------------------------------------------
416bA
416bAC     openordh3     begsr

     C                   if        not %open(ordh3)
     C                   open(e)   ordh3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRORH3'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file ORDH3 in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openordh5  Open file Ordh5
416bA*----------------------------------------------------------------
416bA
416bAC     openordh5     begsr

     C                   if        not %open(ordh5)
     C                   open(e)   ordh5
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRORH5'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file ORDH5 in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  openrtesum   Open file RteSum
416bA*----------------------------------------------------------------
416bA
416bAC     openrtesum    begsr

     C                   if        not %open(rtesum)
     C                   open(e)   rtesum
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRRTES'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                       + 'open file RTESUM in pgm '
     C                                       + #prog
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ordd2ds  Move order detail fields to data structure fields
     *----------------------------------------------------------------

     C     ordd2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $odver#
     C                   clear                   $ordd
     C                   eval      $odver# = savever#

     C* Move information to data structure.

     C                   eval      $odwhse = odwhse
     C                   eval      $odoid  = odord
     C                   eval      $odseq  = odseq
     C                   eval      $oditem = oditem
     C                   eval      $odqor1 = odqor1
     C                   eval      $odqor2 = odqor2
     C                   eval      $odqor3 = odqor3
     C                   eval      $odwh2  = odwh2
     C                   eval      $odor2  = odor2
     C                   eval      $odoitm = odoitm
     C                   eval      $odspcl = odspcl
     C                   eval      $odqpk1 = odqpk1
     C                   eval      $odqpk2 = odqpk2
     C                   eval      $odqpk3 = odqpk3
     C                   eval      $odstat = odstat

     C                   endsr

     *----------------------------------------------------------------
     *  ordy2ds  Move order header fields to data structure fields
     *----------------------------------------------------------------

     C     ordh2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $ohver#
     C                   clear                   $ordh
     C                   eval      $ohver# = savever#

     C* Move information to data structure.

     C                   eval      $ohwhse = ohwhse
     C                   eval      $ohoid  = ohord
     C                   eval      $ohorig = ohorig
     C                   eval      $ohtype = ohtype
     C                   eval      $ohcust = ohcust
     C                   eval      $ohcord = ohcord
     C                   eval      $ohcnam = ohcnam
     C                   eval      $ohcad1 = ohcad1
     C                   eval      $ohcad2 = ohcad2
     C                   eval      $ohccty = ohccty
     C                   eval      $ohcst  = ohcst
     C                   eval      $ohczip = ohczip
     C                   eval      $ohrte  = rhrte
     C                   eval      $ohrid  = ohrte
     C                   eval      $ohstop = ohstop
     C                   eval      $ohtruk = ohtruk
     C                   eval      $ohmisc = ohmisc
     C                   eval      $ohpbat = ohpbat
     C                   eval      $ohstat = ohstat
     C                   eval      $ohsdte = ohsdte
     C                   eval      $ohstim = ohstim
     C                   eval      $ohudte = ohudte
     C                   eval      $ohutim = ohutim

     C                   endsr

     *----------------------------------------------------------------
     *  rtecrt    Create new route.
     *----------------------------------------------------------------

     C     rtecrt        begsr

     C                   exsr      getdatetime

     *  Clear rtehed record.

     C                   clear                   rhrec

     *  Move information into slot def fields.

     C                   eval      rhwhse = $ohwhse

     C                   call      'PIRRTE#'
     C                   parm                    rhwhse
     C                   parm      ' '           rhrtid

     C                   if        $ohrte = ' '
     C                   eval      rhrte = rhrtid
     C                   else
     C                   eval      rhrte = $ohrte
     C                   endif

     C                   if        $ohtype = 'W' and $ohtruk = ' '
     C                   eval      rhtruk = 'WILLCALL'
     C                   else
     C                   eval      rhtruk = $ohtruk
     C                   endif

     C                   eval      rhtype = $ohtype
     C                   eval      rhstat = '1'
     C                   eval      rhstsd = curdate
     C                   eval      rhstst = curtime
     C                   eval      rhimpd = curdate
     C                   eval      rhimpt = curtime
     C                   eval      rhrptd = curdate

     *  Add record

     C                   write(e)  rhrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Route Header" command '
     C                                       + '('
     C                                       + %Trim(%editc(rhwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(rhrtid)
     C                                       + '/'
     C                                       + %Trim(rhrte)
     C                                       + ')'
     C                                       + '-' + f3messageid
     C                   goto      endrtecrt
     C                   endif

     *  Return route id

     C                   eval      $ohrid  = rhrtid
     C                   eval      $ohrte  = rhrte
     C                   eval      $ohtruk = rhtruk

     C     endrtecrt     endsr

     *----------------------------------------------------------------
     *  rtedel      Delete Route
     *----------------------------------------------------------------

     C     rtedel        begsr
     C                   eval      error = *off

     *  Open ORDH3 file.

     C                   if        not %open(ordh3)
     C                   exsr      openordh3
     C                   if        error
     C                   goto      endrtedel
     C                   endif
     C                   endif

     *  Open RTESUM file.

     C                   if        not %open(rtesum)
     C                   exsr      openrtesum
     C                   if        error
     C                   goto      endrtedel
     C                   endif
     C                   endif

     *  Get and lock route.

     C                   eval      lock = *on
     C                   exsr      getrte

     C                   if        error
     C                   goto      endrtedel
     C                   endif

     *  Delete order header and detail records.

     C     keyrh         setll     ordh3

     C                   dow       forever = forever

     C     keyrh         reade     ordh3                                7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRHDRLCK'
     C                   eval      $pmessage = 'Error deleting route - '
     C                                       + 'Header record was locked '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim($ohrid)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   leave
     C                   endif

     *     Otherwise, delete detail records then the header.

     *       Delete order detail records.

     C                   eval      $ohwhse = ohwhse
     C                   eval      $ohoid  = ohord
     C     keyoh         setll     ordd

     C                   dow       forever = forever

     C     keyoh         reade     ordd                                 7879
     C                   if        *in79
     C                   leave
     C                   endif

     *         If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDTLLCK'
     C                   eval      $pmessage = 'Error deleting route - '
     C                                       + 'Detail record was locked '
     C                                       + '('
     C                                       + %Trim(%editc(ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(ohord:'Z'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   leave
     C                   endif

     *         Delete detail record.

     C                   delete(e) odrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDTLDEL'
     C                   eval      $pmessage = 'Error deleting Route - '
     C                                       + 'Error deleting detail '
     C                                       + 'record '
     C                                       + '('
     C                                       + %Trim(%editc(odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(odseq:'Z'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   leave
     C                   endif

     C                   enddo

     *       Delete Header record.

     C                   delete(e) ohrec3
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRHDRDEL'
     C                   eval      $pmessage = 'Error deleting Route - '
     C                                       + 'Error deleting header '
     C                                       + 'record '
     C                                       + '('
     C                                       + %Trim(%editc(ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc(ohord:'Z'))
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   leave
     C                   endif

     C                   enddo

     *  Delete route summary records.

     C     keyrh         setll     rtesum

     C                   dow       forever = forever

     C     keyrh         reade     rtesum                               7879
     C                   if        *in79
     C                   leave
     C                   endif

     *     If record is locked then send message back and abort.

     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRSUMLCK'
     C                   eval      $pmessage = 'Error deleting route - '
     C                                       + 'Summary record was locked '
     C                                       + '('
     C                                       + %Trim(%editc(rswhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(rsrtid)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   leave
     C                   endif

     *       Delete Summary record.

     C                   delete(e) rsrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRSUMDEL'
     C                   eval      $pmessage = 'Error deleting Route - '
     C                                       + 'Error deleting summary '
     C                                       + 'record '
     C                                       + '('
     C                                       + %Trim(%editc(rswhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(rsrtid)
     C                                       + ')'
     C                                       + '-' + f4messageid
     C                   leave
     C                   endif

     C                   enddo

     *  If error occured, unlock router and get out.

     C                   if        error
     C                   unlock    rtehed
     C                   goto      endrtedel
     C                   endif

     *  Otherwise, delete route header record.

     C                   delete(e) rhrec
     C                   if        %error
     C                   eval      $preturn = 'DELRTEERR'
     C                   eval      $pmessage = 'Error on "Delete Route '
     C                                       + 'Header" command '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim($ohrid)
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f3messageid

     C                   goto      endrtedel
     C                   endif

     C     endrtedel     endsr

     *----------------------------------------------------------------
     *  rtevfycrt  Verify route information for creating
     *----------------------------------------------------------------

     C     rtevfycrt     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohrte'
     C                   eval      vfyfld(3) = '$ohtype'
     C                   eval      vfyfld(4) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endrtevfycrt

     *  Initialize fields that have not been sent.

     C                   exsr      inzhdrflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohrte'
     C                   eval      vfyfld(3) = '$ohtype'
     C                   eval      vfyfld(4) = '$ohtruk'
     C                   eval      vfyfld(5) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endrtevfycrt

     C     endrtevfycrt  endsr

     *----------------------------------------------------------------
     *  rtevfydel  Delete Route verification
     *----------------------------------------------------------------

     C     rtevfydel     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohrid'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endrtevfydel

     *  Verify fields.

     C                   eval      vfyfld(1) = 'rhexist'
     C                   eval      vfyfld(2) = 'rhopen'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endrtevfydel

     C     endrtevfydel  endsr

     *----------------------------------------------------------------
     *  rtvcord   Retrieve order header using customer order #
     *----------------------------------------------------------------

     C     rtvcord       begsr
     C                   eval      error = *off

     C*  See if order exists in Dakota order file.

     C                   eval      lock = *off
     C                   exsr      getordhwco

     C*  If order doesn't exist, then try and get it from Host.

     C                   if        error
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   exsr      rtvcord2
     C                   goto      endrtvcord
     C                   endif

     C*  Otherwise, when order exists ...

     C*    Order cannot be closed.

     C                   if        ohstat = 'C'
     C                   eval      error = *ON
     C                   eval      $preturn = 'ORDCLOSED'
     C                   eval      $pmessage = 'Order already closed '
     C                                       + '('
     C                                       + %Trim(%editc($ohcord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohoid:'Z'))
     C                                       + ')'

     C                   goto      endrtvcord
     C                   endif

     C*    Route cannot be closed.

     C*     Get route.

     C                   eval      check4err = *off
     C                   eval      $ohrid = ohrte
     C                   exsr      getrte

     C*       If route doesn't exist, treat it as if it wasn't closed

     C                   if        error
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   goto      endrtvcord
     C                   endif

     C*     See if it is closed or exported.

     C                   if        rhstat <> '1' and
     C                             rhstat <> '2' and
     C                             rhstat <> '3' and
     C                             rhstat <> '4'
     C                   eval      error = *ON
     C                   eval      $preturn = 'RTECLOSED'
     C                   eval      $pmessage = 'Route already closed '
     C                                       + '('
     C                                       + %Trim(rhrte)
     C                                       + '/'
     C                                       + %Trim(rhrtid)
     C                                       + '/'
     C                                       + %Trim(%editc($ohcord:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohoid:'Z'))
     C                                       + ')'

     C                   goto      endrtvcord
     C                   endif

     C     endrtvcord    endsr

     *----------------------------------------------------------------
     *  rtvcord2  Retrieve order from host
     *----------------------------------------------------------------

     C     rtvcord2      begsr
     C                   eval      error = *off

     C*  Get header from host.

     C                   eval      $drisubcmd = '*RTVCORDHD'
     C                   exsr      aaacallhost2
     C                   if        error
     C                   goto      endrtvcord2
     C                   endif

     C                   exsr      hdrvfyadd
     C                   if        error
     C                   goto      endrtvcord2
     C                   endif

     C                   exsr      hdradd
     C                   if        error
     C                   goto      endrtvcord2
     C                   endif

     C*  Get detail from host.

     C                   eval      savever# = $odver#
     C                   clear                   $ordd
     C                   eval      $odver# = savever#

     C                   eval      $odwhseu = *on
     C                   eval      $odwhse = $ohwhse
     C                   eval      $odoidu = *on
     C                   eval      $odoid  = $ohoid
     C                   eval      $odsequ = *on
     C                   eval      $oditemu = *on
     C                   eval      $odqor1u = *on
     C                   eval      $odqor2u = *on
     C                   eval      $odqor3u = *on

     C                   dow       forever = forever

     C                   eval      $drisubcmd = '*RTVCORDDT'
     C                   exsr      aaacallhost2
     C                   if        error or $drireturn = '*EOF'
     C                   leave
     C                   endif

     C                   eval      $odoidu = *on
     C                   eval      $odoid  = $ohoid

     C                   exsr      dtlvfyadd
     C                   if        error
     C                   goto      endrtvcord2
     C                   endif

     C                   exsr      dtladd
     C                   if        error
     C                   goto      endrtvcord2
     C                   endif

     C                   enddo

     C     endrtvcord2   endsr

     *----------------------------------------------------------------
     *  vfydtlflds  Verify detail fields
     *----------------------------------------------------------------

     C     vfydtlflds    begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify field ...

     C                   select

     *      Warehouse

     C                   when      vfyfld(i) = '$odwhse'

     C                   if        $odwhseu

     C                   eval      $vwhse = $odwhse

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm                    $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $odwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $odwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage

     C                   endsl

     C                   endif

     *      Order id

     C                   when      vfyfld(i) = '$odoid'

     C                   if        $odoidu

     C                   if        $odoid < 0
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $preturn = 'NEGATIVOID'
     C                   eval      $pmessage = 'Order number must be '
     C                                       + 'positive'
     C                   endif

     C                   if        $odoid = 0
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $preturn = 'ZEROOID'
     C                   eval      $pmessage = 'Order id cannot be zero'
     C                   endif

     C                   endif

     *      Sequence number

     C                   when      vfyfld(i) = '$odseq'

     C                   if        $odsequ

     C                   if        $odseq < 0
     C                   eval      error = *on
     C                   eval      $odseqe = '1'
     C                   eval      $preturn = 'NEGATIVSEQ'
     C                   eval      $pmessage = 'Seq# must be positive'
     C                   endif

     C                   endif

     *      Item number

     C                   when      vfyfld(i) = '$oditem'

     C                   if        $oditemu

     C                   if        $oditem = ' '
     C                   eval      error = *on
     C                   eval      $oditeme = '1'
     C                   eval      $preturn = 'BLANKITEM'
     C                   eval      $pmessage = 'Item number cannot be blank'
     C                   goto      endvfydtlflds
     C                   endif

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETMAIN'
     C                   exsr      getitem
     C                   if        error
     C                   eval      $oditeme = '1'
     C                   goto      endvfydtlflds
     C                   endif

     *        Get SSB item, if one exists.

     C                   eval      ssbflag = *off
     C                   if        $ittype = ' '

     C                   call(e)   'GETSSB'
     C                   parm      $itwhse       #swhse            3 0
     C                   parm                    $ititem          15
     C                   parm      ' '           #sitem           15
     C                   parm                    #sdesc           30
     C                   parm                    #spdsc           15
     C                   parm                    #swhdp            5
     C                   parm                    #sstyp            1
     C                   parm                    #sum              2
     C                   parm                    #sum2             2
     C                   parm                    #sumq2            3 0
     C                   parm                    #sum3             2
     C                   parm                    #sumq3            3 0
     C                   parm                    #srtn             8

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'GETSSB'
     C                                       + ' from ' + #prog
     C                   goto      endvfydtlflds

     C                   when      #srtn = '*FOUND'
     C                   eval      ssbflag = *on

     C                   endsl

     C                   endif

     C                   endif

     *      Quantity ordered

     C                   when      vfyfld(i) = '$odqor'

     C                   if        $odqor1u and $odqor1 < 0
     C                   eval      error = *on
     C                   eval      $odqor1e = '1'
     C                   eval      $preturn = 'NEGATIVQO1'
     C                   eval      $pmessage = 'Qty ordered 1 '
     C                                       + 'must be positive'
     C                   goto      endvfydtlflds
     C                   endif

     C                   if        $odqor2u and $odqor2 < 0
     C                   eval      error = *on
     C                   eval      $odqor2e = '1'
     C                   eval      $preturn = 'NEGATIVQO2'
     C                   eval      $pmessage = 'Qty ordered 2 '
     C                                       + 'must be positive'
     C                   goto      endvfydtlflds
     C                   endif

     C                   if        $odqor3u and $odqor3 < 0
     C                   eval      error = *on
     C                   eval      $odqor3e = '1'
     C                   eval      $preturn = 'NEGATIVQO3'
     C                   eval      $pmessage = 'Qty ordered 3 '
     C                                       + 'must be positive'
     C                   goto      endvfydtlflds
     C                   endif

     *        If breakdown quantity sent, see if it is allowed.
     *          (If item has corresponding SSB item, all qty's allowed)

     *          Breakdown 1 qty.

     C                   if        ssbflag = *off
     C                   if        $odqor2u
     C                   if        $odqor2 <> 0 and $itflg1 <> 'Y' or
     C                             $odqor2 <> 0 and $itumq2 <= 0
     C                   eval      error = *on
     C                   eval      $odqor2e = '1'
     C                   eval      $preturn = 'BRK1NOTALW'
     C                   eval      $pmessage = 'Breakdown qty 1 is not '
     C                                       + 'allowed for item'
     C                   goto      endvfydtlflds
     C                   endif
     C                   endif
     C                   endif

     *          Breakdown 2 qty.

     C                   if        ssbflag = *off
     C                   if        $odqor3u
     C                   if        $odqor3 <> 0 and $itflg2 <> 'Y' or
     C                             $odqor3 <> 0 and $itumq3 <= 0
     C                   eval      error = *on
     C                   eval      $odqor3e = '1'
     C                   eval      $preturn = 'BRK2NOTALW'
     C                   eval      $pmessage = 'Breakdown qty 2 is not '
     C                                       + 'allowed for item'
     C                   goto      endvfydtlflds
     C                   endif
     C                   endif
     C                   endif

     *      Quantity picked

     C                   when      vfyfld(i) = '$odqpk'

     C                   if        $odqpk1u and $odqpk1 < 0
     C                   eval      error = *on
     C                   eval      $odqpk1e = '1'
     C                   eval      $preturn = 'NEGATIVQP1'
     C                   eval      $pmessage = 'Qty picked 1 '
     C                                       + 'must be positive'
     C                   endif

     C                   if        $odqpk2u and $odqpk2 < 0
     C                   eval      error = *on
     C                   eval      $odqpk2e = '1'
     C                   eval      $preturn = 'NEGATIVQP2'
     C                   eval      $pmessage = 'Qty picked 2 '
     C                                       + 'must be positive'
     C                   endif

     C                   if        $odqpk3u and $odqpk3 < 0
     C                   eval      error = *on
     C                   eval      $odqpk3e = '1'
     C                   eval      $preturn = 'NEGATIVQP3'
     C                   eval      $pmessage = 'Qty picked 3 '
     C                                       + 'must be positive'
     C                   endif

     *        If breakdown quantity sent, see if it is allowed.
     *          (If item has corresponding SSB item, all qty's allowed)

     *          Breakdown 1 qty.

     C                   if        ssbflag = *off
     C                   if        $odqpk2u
     C                   if        $odqpk2 <> 0 and $itflg1 <> 'Y' or
     C                             $odqpk2 <> 0 and $itumq2 <= 0
     C                   eval      error = *on
     C                   eval      $odqpk2e = '1'
     C                   eval      $preturn = 'BRK1NOTALW'
     C                   eval      $pmessage = 'Breakdown qty 1 is not '
     C                                       + 'allowed for item'
     C                   goto      endvfydtlflds
     C                   endif
     C                   endif
     C                   endif

     *          Breakdown 2 qty.

     C                   if        ssbflag = *off
     C                   if        $odqpk3u
     C                   if        $odqpk3 <> 0 and $itflg2 <> 'Y' or
     C                             $odqpk3 <> 0 and $itumq3 <= 0
     C                   eval      error = *on
     C                   eval      $odqpk3e = '1'
     C                   eval      $preturn = 'BRK2NOTALW'
     C                   eval      $pmessage = 'Breakdown qty 2 is not '
     C                                       + 'allowed for item'
     C                   goto      endvfydtlflds
     C                   endif
     C                   endif
     C                   endif

     *      Status

     C                   when      vfyfld(i) = '$odstat'

     C                   if        $odstatu

     C                   if        $odstat <> 'O' and
     C                             $odstat <> 'P' and
     C                             $odstat <> 'C'
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $preturn = 'INVLDSTAT'
     C                   eval      $pmessage = 'Invalid status code '
     C                                       + '(' + %trim($odstat) + ')'
     C                   endif

     C                   endif

     *      Order detail not exist.

     C                   when      vfyfld(i) = 'odnotexist'

     C                   eval      lock = *off
     C                   exsr      getordd
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $odseqe = '1'
     C                   eval      $oditeme = '1'
     C                   eval      $preturn = 'DTLEXIST'
     C                   eval      $pmessage = 'Order detail already '
     C                                       + 'exists ('
     C                                       + %Trim(%editc($odwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($odoid:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($odseq:'Z'))
     C                                       + '/'
     C                                       + %Trim($oditem)
     C                                       + ')'
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *      Order detail exist.

     C                   when      vfyfld(i) = 'odexist'

     C                   eval      lock = *off
     C                   exsr      getordd
     C                   if        error
     C                   eval      $odoide = '1'
     C                   eval      $odseqe = '1'
     C                   eval      $oditeme = '1'
     C                   endif

     *      Order detail status open

     C                   when      vfyfld(i) = 'odopen'

     C                   if        odstat <> 'O'
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $odseqe = '1'
     C                   eval      $oditeme = '1'
     C                   eval      $preturn = 'DTLNOTOPN'
     C                   eval      $pmessage = 'Order detail not at '
     C                                       + 'Open status'
     C                   endif

     *      Order header exist.

     C                   when      vfyfld(i) = 'ohexist'

     C                   eval      lock = *off
     C                   eval      $ohwhse = $odwhse
     C                   eval      $ohoid  = $odoid
     C                   exsr      getordh
     C                   if        error
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $preturn = 'HDRNOTEXST'
     C                   eval      $pmessage = 'Order header does not '
     C                                       + 'exist '
     C                                       + '('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohoid:'Z'))
     C                                       + ')'
     C                   endif

     *      Order status open

     C                   when      vfyfld(i) = 'ohopen'

     C                   if        ohstat <> 'O'
     C                   eval      error = *on
     C                   eval      $preturn = 'HDRNOTOPEN'
     C                   eval      $pmessage = 'Order header not at '
     C                                       + 'Open status'
     C                   endif

     *      Unkown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYHDRFLDS'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYHDRFLDS '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C     endvfydtlflds endsr

     *----------------------------------------------------------------
     *  vfydtlnotsnt  Verify detail fields that are not allowed to be sent
     *----------------------------------------------------------------

     C     vfydtlnotsnt  begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify field was not sent ...

     C                   select

     *      Quantity picked

     C                   when      vfyfld(i) = '$odqpk'

     C                   if        $odqpk1u
     C                   eval      error = *on
     C                   eval      $odqpk1e = '1'
     C                   eval      $preturn = 'QPK1NOTALW'
     C                   eval      $pmessage = 'Quantity picked 1 '
     C                                       + 'not allowed to be sent'
     C                   goto      endvfydtlnots
     C                   endif

     C                   if        $odqpk2u
     C                   eval      error = *on
     C                   eval      $odqpk2e = '1'
     C                   eval      $preturn = 'QPK2NOTALW'
     C                   eval      $pmessage = 'Quantity picked 2 '
     C                                       + 'not allowed to be sent'
     C                   goto      endvfydtlnots
     C                   endif

     C                   if        $odqpk3u
     C                   eval      error = *on
     C                   eval      $odqpk3e = '1'
     C                   eval      $preturn = 'QPK3NOTALW'
     C                   eval      $pmessage = 'Quantity picked 3 '
     C                                       + 'not allowed to be sent'
     C                   goto      endvfydtlnots
     C                   endif

     *      Status

     C                   when      vfyfld(i) = '$odstat'
     C                   if        $odstatu
     C                   eval      error = *on
     C                   eval      $odstate = '1'
     C                   eval      $preturn = 'STATNOTALW'
     C                   eval      $pmessage = 'Status '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Unkown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYDTLNOTS'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYDTLNOTS '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C     endvfydtlnots endsr

     *----------------------------------------------------------------
     *  vfydtlsent  Verify detail fields that must be sent
     *----------------------------------------------------------------

     C     vfydtlsent    begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify if field was sent ...

     C                   select

     *      Warehouse

     C                   when      vfyfld(i) = '$odwhse'
     C                   if        not $odwhseu
     C                   eval      error = *on
     C                   eval      $odwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'
     C                   endif

     *      Order id

     C                   when      vfyfld(i) = '$odoid'
     C                   if        not $odoidu
     C                   eval      error = *on
     C                   eval      $odoide = '1'
     C                   eval      $preturn = 'OIDNOTSNT'
     C                   eval      $pmessage = 'Order id must be sent'
     C                   endif

     *      Sequence number

     C                   when      vfyfld(i) = '$odseq'
     C                   if        not $odsequ
     C                   eval      error = *on
     C                   eval      $odseqe = '1'
     C                   eval      $preturn = 'SEQNOTSNT'
     C                   eval      $pmessage = 'Seq# must be sent'
     C                   endif

     *      Item

     C                   when      vfyfld(i) = '$oditem'
     C                   if        not $oditemu
     C                   eval      error = *on
     C                   eval      $oditeme = '1'
     C                   eval      $preturn = 'ITEMNOTSNT'
     C                   eval      $pmessage = 'Item must be sent'
     C                   endif

     *      Quantity ordered

     C                   when      vfyfld(i) = '$odqor1'
     C                   if        not $odqor1u
     C                   eval      error = *on
     C                   eval      $odqor1e = '1'
     C                   eval      $preturn = 'QO1NOTSNT'
     C                   eval      $pmessage = 'Qty ordered 1 must be sent'
     C                   endif

     *      Unkown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYDTLSENT'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYDTLSENT '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  vfygetdtl   Verify for *GETDTL
     *----------------------------------------------------------------

     C     vfygetdtl     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$odwhse'
     C                   eval      vfyfld(2) = '$odoid'
     C                   eval      vfyfld(3) = '$odseq'
     C                   eval      vfyfld(4) = '$oditem'
     C                   eval      vfyfld(5) = ' '

     C                   exsr      vfydtlsent
     C     error         cabeq     *on           endvfygetdtl

     C     endvfygetdtl  endsr

     *----------------------------------------------------------------
     *  vfygethdr   Verify for *GETHDR
     *----------------------------------------------------------------

     C     vfygethdr     begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohoid'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endvfygethdr

     C     endvfygethdr  endsr

     *----------------------------------------------------------------
     *  vfygethdrwco   Verify for *GETHDRWCO
     *----------------------------------------------------------------

     C     vfygethdrwco  begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohcord'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endvfygethdrw

     C     endvfygethdrw endsr

     *----------------------------------------------------------------
     *  vfyhdrflds  Verify header fields
     *----------------------------------------------------------------

     C     vfyhdrflds    begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify field ...

     C                   select

     *      Warehouse

     C                   when      vfyfld(i) = '$ohwhse'

     C                   if        $ohwhseu

     C                   eval      $vwhse = $ohwhse

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm                    $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $ohwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $ohwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage

     C                   endsl

     C                   endif

     *      Order id

     C                   when      vfyfld(i) = '$ohoid'

     C                   if        $ohoidu

     C                   if        $ohoid < 0
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'NEGATIVOID'
     C                   eval      $pmessage = 'Order id must be '
     C                                       + 'positive'
     C                   endif

     C                   if        $ohoid = 0
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'ZEROOID'
     C                   eval      $pmessage = 'Order id cannot be zero'
     C                   endif

     C                   endif

     *      Route id

     C                   when      vfyfld(i) = '$ohrid'

     C                   if        $ohridu

     C                   if        $ohrid = ' '
     C                   eval      error = *on
     C                   eval      $ohrtee = '1'
     C                   eval      $preturn = 'BLANKRTE'
     C                   eval      $pmessage = 'Route id cannot be blank'
     C                   endif

     C                   endif

     *      Origination code

     C                   when      vfyfld(i) = '$ohorig'

     C                   if        $ohorigu
     C                   endif

     *      Type

     C                   when      vfyfld(i) = '$ohtype'

     C                   if        $ohtypeu

     C                   if        $ohtype <> ' ' and
     C                             $ohtype <> 'S' and
     C                             $ohtype <> 'T' and
     C                             $ohtype <> 'W'
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'INVLDTYPE'
     C                   eval      $pmessage = 'Invalid type code '
     C                                       + '(' + %trim($ohtype) + ')'
     C                   endif

     C                   endif

     *      Order number

     C                   when      vfyfld(i) = '$ohcord'

     C                   if        $ohcordu

     C                   if        $ohcord < 0
     C                   eval      error = *on
     C                   eval      $ohcorde = '1'
     C                   eval      $preturn = 'NEGATIVORD'
     C                   eval      $pmessage = 'Order number must be '
     C                                       + 'positive'
     C                   endif

     C                   if        $ohcord = 0
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'ZEROORD'
     C                   eval      $pmessage = 'Order number cannot be zero'
     C                   endif

     C                   endif

     *      Route

     C                   when      vfyfld(i) = '$ohrte'

     C                   if        $ohrteu

     C                   if        $ohrte = ' '
     C                   eval      error = *on
     C                   eval      $ohrtee = '1'
     C                   eval      $preturn = 'BLANKRTE'
     C                   eval      $pmessage = 'Route cannot be blank'
     C                   endif

     C                   endif

     *      Stop

     C                   when      vfyfld(i) = '$ohstop'

     C                   if        $ohstopu

     C                   if        $ohstop < 0
     C                   eval      error = *on
     C                   eval      $ohstope = '1'
     C                   eval      $preturn = 'NEGATIVSTP'
     C                   eval      $pmessage = 'Stop number must be '
     C                                       + 'positive'
     C                   endif

     C                   endif

     *      Truck

     C                   when      vfyfld(i) = '$ohtruk'

     C                   if        $ohtruku
     C                   endif

     *      Status

     C                   when      vfyfld(i) = '$ohstat'

     C                   if        $ohstatu

     C                   if        $ohstat <> 'O' and
     C                             $ohstat <> 'P' and
     C                             $ohstat <> 'C'
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'INVLDSTAT'
     C                   eval      $pmessage = 'Invalid status code '
     C                                       + '(' + %trim($ohstat) + ')'
     C                   endif

     C                   endif

     *      Status date

     C                   when      vfyfld(i) = '$ohsdte'

     C                   if        $ohsdteu

     C                   move      $ohsdte       $cvd6i
     C                   eval      $cvcmd = '*YMDEDT'
     C                   eval      $cvprg = #prog
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn <> ' '
     C                   eval      error = *on
     C                   eval      $ohsdtee = '1'
     C                   eval      $preturn = 'INVLDSDTE'
     C                   eval      $pmessage = 'Invalid status date '
     C                                       + '('
     C                                       + %Trim(%editc($ohsdte:'Z'))
     C                                       + ')'
     C                   endif

     C                   endif

     *      Upload date

     C                   when      vfyfld(i) = '$ohudte'

     C                   if        $ohudteu

     C                   move      $ohudte       $cvd6i
     C                   eval      $cvcmd = '*YMDEDT'
     C                   eval      $cvprg = #prog
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn <> ' '
     C                   eval      error = *on
     C                   eval      $ohsdtee = '1'
     C                   eval      $preturn = 'INVLDUDTE'
     C                   eval      $pmessage = 'Invalid upload date '
     C                                       + '('
     C                                       + %Trim(%editc($ohudte:'Z'))
     C                                       + ')'
     C                   endif

     C                   endif

     *      Order header not exist.

     C                   when      vfyfld(i) = 'ohnotexist'

     C                   eval      lock = *off
     C                   exsr      getordh
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'HDREXIST'
     C                   eval      $pmessage = 'Order header already '
     C                                       + 'exists ('
     C                                       + %Trim(%editc($ohwhse:'Z'))
     C                                       + '/'
     C                                       + %Trim(%editc($ohoid:'Z'))
     C                                       + ')'
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *      Order header exist.

     C                   when      vfyfld(i) = 'ohexist'

     C                   eval      lock = *off
     C                   exsr      getordh
     C                   if        error
     C                   eval      $ohoide = '1'
     C                   endif

     *      Order header status open

     C                   when      vfyfld(i) = 'ohopen'

     C                   if        ohstat <> 'O'
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'HDRNOTOPN'
     C                   eval      $pmessage = 'Order header not at '
     C                                       + 'Open status'
     C                   endif

     *      Route header exist.

     C                   when      vfyfld(i) = 'rhexist'

     C                   eval      lock = *off
     C                   eval      check4err = *on
     C                   exsr      getrte
     C                   if        error
     C                   eval      $ohride = '1'
     C                   endif

     *      Route header status open

     C                   when      vfyfld(i) = 'rhopen'

     C                   if        rhstat <> '1'
     C                   eval      error = *on
     C                   eval      $ohride = '1'
     C                   eval      $preturn = 'RTENOTOPN'
     C                   eval      $pmessage = 'Route header not at '
     C                                       + 'Open status'
     C                   endif

     *      Unknown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYHDRFLDS'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYHDRFLDS '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  vfyhdrnotsnt  Verify header fields that are not allowed to be sent
     *----------------------------------------------------------------

     C     vfyhdrnotsnt  begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify if field was not sent ...

     C                   select

     *      Order id

     C                   when      vfyfld(i) = '$ohoid'
     C                   if        $ohoidu
     C                   eval      error = *on
     C                   eval      $ohorige = '1'
     C                   eval      $preturn = 'OIDNOTALW'
     C                   eval      $pmessage = 'Order id '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Origination code

     C                   when      vfyfld(i) = '$ohorig'
     C                   if        $ohorigu
     C                   eval      error = *on
     C                   eval      $ohorige = '1'
     C                   eval      $preturn = 'ORIGNOTALW'
     C                   eval      $pmessage = 'Origination '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Type

     C                   when      vfyfld(i) = '$ohtype'
     C                   if        $ohtypeu
     C                   eval      error = *on
     C                   eval      $ohtypee = '1'
     C                   eval      $preturn = 'TYPENOTALW'
     C                   eval      $pmessage = 'Type '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Route

     C                   when      vfyfld(i) = '$ohrte'
     C                   if        $ohrteu
     C                   eval      error = *on
     C                   eval      $ohrtee = '1'
     C                   eval      $preturn = 'RTENOTALW'
     C                   eval      $pmessage = 'Route '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Stop

     C                   when      vfyfld(i) = '$ohstop'
     C                   if        $ohstopu
     C                   eval      error = *on
     C                   eval      $ohstope = '1'
     C                   eval      $preturn = 'STOPNOTALW'
     C                   eval      $pmessage = 'Stop '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Truck

     C                   when      vfyfld(i) = '$ohtruk'
     C                   if        $ohtruku
     C                   eval      error = *on
     C                   eval      $ohtruke = '1'
     C                   eval      $preturn = 'TRUKNOTALW'
     C                   eval      $pmessage = 'Truck '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Status

     C                   when      vfyfld(i) = '$ohstat'
     C                   if        $ohstatu
     C                   eval      error = *on
     C                   eval      $ohstate = '1'
     C                   eval      $preturn = 'STATNOTALW'
     C                   eval      $pmessage = 'Status '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Status date

     C                   when      vfyfld(i) = '$ohsdte'
     C                   if        $ohsdteu
     C                   eval      error = *on
     C                   eval      $ohsdtee = '1'
     C                   eval      $preturn = 'SDTENOTALW'
     C                   eval      $pmessage = 'Status date '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Status time

     C                   when      vfyfld(i) = '$ohstim'
     C                   if        $ohstimu
     C                   eval      error = *on
     C                   eval      $ohstime = '1'
     C                   eval      $preturn = 'STIMNOTALW'
     C                   eval      $pmessage = 'Status time '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Upload date

     C                   when      vfyfld(i) = '$ohudte'
     C                   if        $ohudteu
     C                   eval      error = *on
     C                   eval      $ohudtee = '1'
     C                   eval      $preturn = 'UDTENOTALW'
     C                   eval      $pmessage = 'Upload date '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Upload time

     C                   when      vfyfld(i) = '$ohutim'
     C                   if        $ohutimu
     C                   eval      error = *on
     C                   eval      $ohutime = '1'
     C                   eval      $preturn = 'UTIMNOTALW'
     C                   eval      $pmessage = 'Upload time '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Batch number

     C                   when      vfyfld(i) = '$ohpbat'
     C                   if        $ohpbatu
     C                   eval      error = *on
     C                   eval      $ohpbate = '1'
     C                   eval      $preturn = 'PBATNOTALW'
     C                   eval      $pmessage = 'Batch number '
     C                                       + 'not allowed to be sent'
     C                   endif

     *      Unkown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYHDRNOTS'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYHDRNOTS '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  vfyhdrsent  Verify header fields that must be sent
     *----------------------------------------------------------------

     C     vfyhdrsent    begsr

     *  Loop through field array.

     C                   eval      i = 0

     C                   dou       i = %elem(vfyfld)

     C                   eval      i = i + 1

     *    Get out when we run out of fields.

     C                   if        vfyfld(i) = ' '
     C                   leave
     C                   endif

     *    Verify if field was sent ...

     C                   select

     *      Warehouse

     C                   when      vfyfld(i) = '$ohwhse'
     C                   if        not $ohwhseu
     C                   eval      error = *on
     C                   eval      $ohwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'
     C                   endif

     *      Order id number

     C                   when      vfyfld(i) = '$ohoid'
     C                   if        not $ohoidu
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'OIDNOTSNT'
     C                   eval      $pmessage = 'Order id must be sent'
     C                   endif

     *      Order number

     C                   when      vfyfld(i) = '$ohcord'
     C                   if        not $ohcordu
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'ORDNOTSNT'
     C                   eval      $pmessage = 'Order number must be sent'
     C                   endif

     *      Origination code

     C                   when      vfyfld(i) = '$ohorig'
     C                   if        not $ohorigu
     C                   eval      error = *on
     C                   eval      $ohorige = '1'
     C                   eval      $preturn = 'ORIGNOTSNT'
     C                   eval      $pmessage = 'Origination must be sent'
     C                   endif

     *      Type

     C                   when      vfyfld(i) = '$ohtype'
     C                   if        not $ohtypeu
     C                   eval      error = *on
     C                   eval      $ohtypee = '1'
     C                   eval      $preturn = 'TYPENOTSNT'
     C                   eval      $pmessage = 'Type must be sent'
     C                   endif

     *      Route

     C                   when      vfyfld(i) = '$ohrte'
     C                   if        not $ohrteu
     C                   eval      error = *on
     C                   eval      $ohrtee = '1'
     C                   eval      $preturn = 'RTENOTSNT'
     C                   eval      $pmessage = 'Route must be sent'
     C                   endif

     *      Route id number

     C                   when      vfyfld(i) = '$ohrid'
     C                   if        not $ohridu
     C                   eval      error = *on
     C                   eval      $ohoide = '1'
     C                   eval      $preturn = 'RIDNOTSNT'
     C                   eval      $pmessage = 'Route id must be sent'
     C                   endif

     *      Stop

     C                   when      vfyfld(i) = '$ohstop'
     C                   if        not $ohstopu
     C                   eval      error = *on
     C                   eval      $ohstope = '1'
     C                   eval      $preturn = 'STOPNOTSNT'
     C                   eval      $pmessage = 'Stop must be sent'
     C                   endif

     *      Truck

     C                   when      vfyfld(i) = '$ohtruk'
     C                   if        not $ohtruku
     C                   eval      error = *on
     C                   eval      $ohtruke = '1'
     C                   eval      $preturn = 'TRUKNOTSNT'
     C                   eval      $pmessage = 'Truck must be sent'
     C                   endif

     *      Status

     C                   when      vfyfld(i) = '$ohstat'
     C                   if        not $ohstatu
     C                   eval      error = *on
     C                   eval      $ohstate = '1'
     C                   eval      $preturn = 'STATNOTSNT'
     C                   eval      $pmessage = 'Status must be sent'
     C                   endif

     *      Status date

     C                   when      vfyfld(i) = '$ohsdte'
     C                   if        not $ohsdteu
     C                   eval      error = *on
     C                   eval      $ohsdtee = '1'
     C                   eval      $preturn = 'SDTENOTSNT'
     C                   eval      $pmessage = 'Status date must be sent'
     C                   endif

     *      Upload date

     C                   when      vfyfld(i) = '$ohudte'
     C                   if        not $ohudteu
     C                   eval      error = *on
     C                   eval      $ohudtee = '1'
     C                   eval      $preturn = 'UDTENOTSNT'
     C                   eval      $pmessage = 'Upload date must be sent'
     C                   endif

     *      Unkown field

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'VFYHDRSENT'
     C                   eval      $pmessage = 'Unkown field sent to '
     C                                       + 'VFYHDRSENT '
     C                                       + '(' + %trim(vfyfld(i)) + ')'

     C                   endsl

     *    Get out if error found.

     C                   if        error
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  vfyrtvcord  Verify for *RTVCORD
     *----------------------------------------------------------------

     C     vfyrtvcord    begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Check that all necessary fields were sent.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohcord'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrsent
     C     error         cabeq     *on           endvfyrtvcord

     *  Initialize fields that have not been sent.

     C                   exsr      inzhdrflds

     *  Verify fields.

     C                   eval      vfyfld(1) = '$ohwhse'
     C                   eval      vfyfld(2) = '$ohcord'
     C                   eval      vfyfld(3) = ' '

     C                   exsr      vfyhdrflds
     C     error         cabeq     *on           endvfyrtvcord

     C     endvfyrtvcord endsr

     *----------------------------------------------------------------
     *  writelog    Write record to log file
     *----------------------------------------------------------------

     C     writelog      begsr

     * Only record updates.

     C                   if        $psubcmd <> '*ADDHDR'    and
     C                             $psubcmd <> '*CHGHDR'    and
     C                             $psubcmd <> '*DELORD'    and
     C                             $psubcmd <> '*ADDDTL'    and
     C                             $psubcmd <> '*CHGDTL'    and
     C                             $psubcmd <> '*DELDTL'
     C                   goto      endwritelog
     C                   endif

     * Initialize log fields.

     C                   exsr      getdatetime


     * Write log record.

     C*                  write(e)  lgporec
     C*                  if        %error
     C*                  endif

     C     endwritelog   endsr
