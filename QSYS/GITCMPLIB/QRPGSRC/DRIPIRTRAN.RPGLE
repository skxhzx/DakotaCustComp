500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  DRIPIRTRAN    Dakota realtime interface - PIRTRAN
     *  14 November 2008
     *  Dave Sommerville
     *
600  *    11/14/08  DAS  6.00
     *      - Created
     *
     *----------------------------------------------------------------
     * Notes
     *
     *  - Because the Sys2Upd parameter is not being sent into this
     *    program, another method needed to be created to determine
     *    if the call to this program was initiated by Dakota or by
     *    the Host system. Therefore, the first character of the
     *    subcommand is used to make this determination. If the
     *    character is a '%', then we assume that Dakota initiated
     *    the call. Otherwise, we assume that the Host system
     *    initiated the call.
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
      *      *GET              Get transaction information
      *
      *      *GETCUR           Get current tran for user.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpirtran   if   e           k disk    infds(file1ds)
     Fpirtran1  if   e           k disk
     F                                     rename(ptrec:ptrec1)
     Fpirtran2  if   e           k disk
     F                                     rename(ptrec:ptrec2)
     Ftask      if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PIRTRAN
     D saveVer#        s                   like($ptver#)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D error           s               n
     D forever         s               n   inz(*on)
     D lock            s               n

     D kydate          s                   like(ptsdte)
     D kystat          s                   like(ptstat)
     D kytime          s                   like(ptstim)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

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
      *      $pmessage  Return code
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

     C                   eval      $pirtran = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See which system is calling the program.

     C                   if        %subst($psubcmd:1:1) = '%'
     C                   eval      DakotaCall = *on
     C                   eval      HostCall   = *off
     C                   eval      %subst($psubcmd:1:1) = '*'
     C                   else
     C                   eval      HostCall   = *on
     C                   eval      DakotaCall = *off
     C                   endif

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

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      gettran
     C                   if        not error
     C                   exsr      tran2ds
     C                   endif

     C                   when      $psubcmd = '*GETCUR'
     C                   eval      lock = *off
     C                   exsr      vfygetcur
     C                   if        not error
     C                   exsr      getcur
     C                   if        not error
     C                   exsr      tran2ds
     C                   endif
     C                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $pirtran
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for PIRTRAN file.

     C     keypt         klist
     C                   kfld                    $pttrn#

     *  Define key for PIRTRAN1 file.

     C     keypt1        klist
     C                   kfld                    $ptemp#
     C                   kfld                    kystat

     *  Define key for PIRTRAN2 file.

     C     keypt2        klist
     C                   kfld                    $ptemp#
     C                   kfld                    kydate
     C                   kfld                    kytime

     *  Define employee # partial key

     C     keyptEmp#     klist
     C                   kfld                    $ptemp#

     *  Define key for TASK file.

     C     keytk         klist
     C                   kfld                    pttask

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
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  aaacallhost   Call host program.
     *----------------------------------------------------------------

     C     aaacallhost   begsr

     C                   call(e)   'DRIMAIN2'
     C                   parm      '*DEPT'       $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      $pirtran      $dridata

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
     *  aaaclose   Close called programs
     *----------------------------------------------------------------

     C     aaaclose      begsr
     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $pttrn#E = '1'
     C                   eval      $pttrn#E = '0'
     C                   endif

     C                   if        $ptstatE = '1'
     C                   eval      $ptstatE = '0'
     C                   endif

     C                   if        $pttaskE = '1'
     C                   eval      $pttaskE = '0'
     C                   endif

     C                   if        $ptcatE = '1'
     C                   eval      $ptcatE = '0'
     C                   endif

     C                   if        $ptsubE = '1'
     C                   eval      $ptsubE = '0'
     C                   endif

     C                   if        $ptwhseE = '1'
     C                   eval      $ptwhseE = '0'
     C                   endif

     C                   if        $ptwhdpE = '1'
     C                   eval      $ptwhdpE = '0'
     C                   endif

     C                   if        $ptstypE = '1'
     C                   eval      $ptstypE = '0'
     C                   endif

     C                   if        $ptshftE = '1'
     C                   eval      $ptshftE = '0'
     C                   endif

     C                   if        $ptcrewE = '1'
     C                   eval      $ptcrewE = '0'
     C                   endif

     C                   if        $ptemp#E = '1'
     C                   eval      $ptemp#E = '0'
     C                   endif

     C                   if        $ptcubeE = '1'
     C                   eval      $ptcubeE = '0'
     C                   endif

     C                   if        $ptswgtE = '1'
     C                   eval      $ptswgtE = '0'
     C                   endif

     C                   if        $ptpcsE = '1'
     C                   eval      $ptpcsE = '0'
     C                   endif

     C                   if        $ptaislE = '1'
     C                   eval      $ptaislE = '0'
     C                   endif

     C                   if        $ptqty1E = '1'
     C                   eval      $ptqty1E = '0'
     C                   endif

     C                   if        $ptqty2E = '1'
     C                   eval      $ptqty2E = '0'
     C                   endif

     C                   if        $ptqty3E = '1'
     C                   eval      $ptqty3E = '0'
     C                   endif

     C                   if        $ptgdteE = '1'
     C                   eval      $ptgdteE = '0'
     C                   endif

     C                   if        $ptgtimE = '1'
     C                   eval      $ptgtimE = '0'
     C                   endif

     C                   if        $ptsdteE = '1'
     C                   eval      $ptsdteE = '0'
     C                   endif

     C                   if        $ptstimE = '1'
     C                   eval      $ptstimE = '0'
     C                   endif

     C                   if        $ptedteE = '1'
     C                   eval      $ptedteE = '0'
     C                   endif

     C                   if        $ptetimE = '1'
     C                   eval      $ptetimE = '0'
     C                   endif

     C                   if        $ptcdteE = '1'
     C                   eval      $ptcdteE = '0'
     C                   endif

     C                   if        $ptctimE = '1'
     C                   eval      $ptctimE = '0'
     C                   endif

     C                   if        $ptrdteE = '1'
     C                   eval      $ptrdteE = '0'
     C                   endif

     C                   if        $ptdminE = '1'
     C                   eval      $ptdminE = '0'
     C                   endif

     C                   if        $ptiminE = '1'
     C                   eval      $ptiminE = '0'
     C                   endif

     C                   if        $ptrtpoE = '1'
     C                   eval      $ptrtpoE = '0'
     C                   endif

     C                   if        $ptgrp1E = '1'
     C                   eval      $ptgrp1E = '0'
     C                   endif

     C                   if        $ptgrp2E = '1'
     C                   eval      $ptgrp2E = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  tran2ds  Move transaction fields to data structure fields
     *----------------------------------------------------------------

     C     tran2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $ptver#
     C                   clear                   $pirtran
     C                   eval      $ptver# = savever#

     C* Move information to data structure.

     C                   eval      $pttrn# = pttrn#
     C                   eval      $ptstat = ptstat
     C                   eval      $pttask = pttask
     C                   eval      $ptcat  = ptcat
     C                   eval      $ptsub  = ptsub
     C                   eval      $ptwhse = ptwhse
     C                   eval      $ptwhdp = ptwhdp
     C                   eval      $ptstyp = ptstyp
     C                   eval      $ptshft = ptshft
     C                   eval      $ptcrew = ptcrew
     C                   eval      $ptemp# = ptemp#
     C                   eval      $ptcube = ptcube
     C                   eval      $ptswgt = ptswgt
     C                   eval      $ptpcs  = ptpcs
     C                   eval      $ptaisl = ptaisl
     C                   eval      $ptqty1 = ptqty1
     C                   eval      $ptqty2 = ptqty2
     C                   eval      $ptqty3 = ptqty3
     C                   eval      $ptgdte = ptgdte
     C                   eval      $ptgtim = ptgtim
     C                   eval      $ptsdte = ptsdte
     C                   eval      $ptstim = ptstim
     C                   eval      $ptedte = ptedte
     C                   eval      $ptetim = ptetim
     C                   eval      $ptcdte = ptcdte
     C                   eval      $ptctim = ptctim
     C                   eval      $ptrdte = ptrdte
     C                   eval      $ptdmin = ptdmin
     C                   eval      $ptimin = ptimin
     C                   eval      $ptrtpo = ptrtpo
     C                   eval      $ptgrp1 = ptgrp1
     C                   eval      $ptgrp2 = ptgrp2

     C                   endsr

     *----------------------------------------------------------------
     *  getcur    Get current transaction for employee
     *----------------------------------------------------------------

     C     getcur        begsr

     C                   eval      kydate = *hival
     C                   eval      kytime = *hival

     C                   move      '2'           kystat
     C     keypt1        setll     pirtran1
     C     keypt1        reade     pirtran1

     C                   if        %eof(pirtran1)
     C                   eval      error = *on

     C                   else

     C     keypt2        setll     pirtran2
     C                   dow       forever = forever
     C     keyptEmp#     reade     pirtran2
     C                   if        %eof(pirtran2)
     C                   eval      error = *on
     C                   leave
     C                   endif
     C                   if        ptstat = '2'
     C                   leave
     C                   endif
     C                   enddo

     C                   endif

     C                   if        error
     C                   eval      $preturn = 'NOCURTRAN'
     C                   exsr      getmsg
     C                   endif

     C     endgetcur     endsr

     *----------------------------------------------------------------
     *  gettask   Get task info.
     *----------------------------------------------------------------

     C     gettask       begsr

     C                   if        lock
     C     keytk         chain     task
     C                   else
     C     keytk         chain(n)  task
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDTASK'
     C                   exsr      getmsg
     C                   goto      endgettask
     C                   endif

     C     endgettask    endsr

     *----------------------------------------------------------------
     *  gettran   Get transaction info.
     *----------------------------------------------------------------

     C     gettran       begsr

     C                   if        lock
     C     keypt         chain     pirtran
     C                   else
     C     keypt         chain(n)  pirtran
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDTRN#'
     C                   exsr      getmsg
     C                   goto      endgettran
     C                   endif

     C     endgettran    endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'INVLDTASK'
     C                   eval      $pmessage = 'Invalid Task Code'
     C                                       + '('
     C                                       + %Trim(pttask)
     C                                       + ')'

     C                   when      $preturn = 'INVLDTRN#'
     C                   eval      $pmessage = 'Invalid Transaction '
     C                                       + '('
     C                                       + %Trim(%editc($pttrn#:'Z'))
     C                                       + ')'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'NOCURTRAN'
     C                   eval      $pmessage = 'No current Tran for Emp# '
     C                                       + '('
     C                                       + %Trim(%editc($ptemp#:'Z'))
     C                                       + ')'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  vfygetcur   Verification for *GETCUR
     *----------------------------------------------------------------

     C     vfygetcur     begsr
     C                   eval      error = *off

     *  Employee number must be sent.

     C                   if        not $ptemp#u
     C                   eval      error = *on
     C                   eval      $ptemp#e = '1'
     C                   eval      $preturn = 'EMP#NOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygetcur
     C                   endif

     C     endvfygetcur  endsr

