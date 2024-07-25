     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIDEPT     Dakota realtime interface - Department maintenance
     *  09 January 2002
     *  Dave Sommerville
     *
416  *    01/09/02  DAS  4.16
     *      - Created
     *
416a *    01/21/02  DAS  4.16a
     *      - Moved getting record for change from changerec routine
     *        into verifychg routine.
     *
416b *    01/23/02  DAS  4.16b
     *      - Revised to identify if called from Dakota.
     *      - Revised to call DRIMAIN2 to update the host when called
     *        from Dakota. This allows the Dakota program to only have
     *        to make a single call to the interface.
     *
416c *    06/11/02  DAS  4.16c
     *      - Recompiled because of change to C#SLOT.
     *
640a *    04/19/12  DAS  6.40a
     *      - Added commands *ADDWEB and *DELETEWEB to be used for
     *        MRC maintenance programs.
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
      *      *ADD              Add department
      *
640aA *      *ADDWEB           Add department - MRC version.
      *
      *      *CHANGE           Change department
      *
      *      *DELETE           Delete department
      *
640aA *      *DELETEWEB        Delete department - MRC version
      *
      *      *GET              Get department information.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fwhdept    uf a e           k disk    infds(file1ds)
     Foptiond   uf a e           k disk    infds(file2ds)
     Ftaskdet   uf a e           k disk    infds(file3ds)
     Ftask      if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DEPT
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($wdver#)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(wdwhse)

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
     D kycode          s                   like(opdcod)
     D kywhdp          s                   like(opdwdp)
     D kywhse          s                   like(opdwhs)
     D lock            s               n
     D pssrflag        s               n

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80

     *   Redefine key

     D  $ltask                19     24
     D  $ltlvl                25     25

213 A*----------------------------------------------------------------
213 A*  *PICK  -  Picking options
213 A*
213 A* Fields
213 A*
213 A*    OPNXTP  -  Next pallet number.
213 A*    OPBPCK  -  Bulk pick definition.
213 A*    OPPCUB  -  Maximum cube for PIR.
213 A*    OPFPAL  -  Pallets on fixed fork lift.
213 A*    OPFCUB  -  Maximum cube per fixed pallet.
213 A*    OPFSTP  -  Maximum stops per fixed pallet.
213 A*    OPINCL  -  Include PIR in fixed cube.
213 A*    OPSRCH  -  Number of previous pallets to search for space.
213 A*    OPFBLD  -  Fixed pallet building method.
213 A*                1 = By piece without concern for splitting stop.
213 A*                2 = By stop without splitting stop between plts.
213 D*    OPPBRK  -  Break pallets by aisle (Y,N).
409 M*    OPPBRK  -  Aisle to start new pallet.
409 A*    OPMPUT  -  Manual put away (Y,N).
213 A*
213 A*----------------------------------------------------------------
213 A
213 AD opddta          ds
213 AD  opnxtp                 1      7  0 inz(1)
213 AD  oppcub                10     14  2 inz(0)
213 AD  opfpal                15     15  0 inz(1)
213 AD  opfcub                16     20  2 inz(64)
213 AD  opincl                22     22    inz('Y')
213 AD  opsrch                23     24  0 inz(0)
213 AD  opfstp                25     26  0 inz(4)
209 AD  opfbld                27     27  0 inz(1)
213 AD  opbpck                28     30  0 inz(60)
409 MD  oppbrk                31     33    inz(' ')
409 AD  opmput                34     34    inz('N')
213 AD  opdend               117    117

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

     C                   eval      $dept = $pdata
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

     C                   when      $psubcmd = '*ADD'
640aAC                             or $psubcmd = '*ADDWEB'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
640aAC                   if        $psubcmd = '*ADDWEB'
640aAC                   exsr      DeleteDeptWeb
640aAC                   endif
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      addrec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      changerec
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELETE'
640aAC                             or $psubcmd = '*DELETEWEB'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      deleterec
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      getdept
     C                   if        not error
     C                   exsr      dept2ds
     C                   endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      verifyadd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      verifychg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      deleterec
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $dept
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for WHDEPT file.

     C     keywd         klist
     C                   kfld                    $wdwhse
     C                   kfld                    $wdcode

     *  Define key for OPTIONSD file.

     C                   eval      kycode = '*PICK   '
     C     keyopd        klist
     C                   kfld                    kycode
     C                   kfld                    kywhse
     C                   kfld                    kywhdp

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
     C                   parm      $dept         $dridata

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

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      0             $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   if        %error
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  addrec   Add record.
     *----------------------------------------------------------------

     C     addrec        begsr

     *  Clear record.

     C                   clear                   wdrec

     *  Move information into fields.

     C                   eval      wdwhse = $wdwhse
     C                   eval      wdcode = $wdcode

416aAC                   if        $wddescu
416aAC                   eval      wddesc = $wddesc
416aAC                   endif

     *  Add record

     C                   write(e)  wdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Dept" command '
     C                                       + '('
     C                                       + %Trim(%editc(wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(wdcode)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endadd
     C                   endif

     *  Add task detail records.

     C     *loval        setll     task
 1B  C                   dow       forever = forever
     C                   read      task
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
     C                   eval      $ltask = tkcode
     C                   eval      $ltlvl = tktlvl
     C                   eval      $lprg = #prog
     C                   eval      $lrtn = '*OK     '
     C                   eval      $lcmd = '*ADD    '
     C                   call      'CRTTSK'
     C                   parm                    $lparm
 1E  C                   enddo

     *  Add Optiond record.

     C                   exsr      optionupd

     C     endadd        endsr

     *----------------------------------------------------------------
     *  changerec   Change record.
     *----------------------------------------------------------------

     C     changerec     begsr

     *  Move information into slot fields.

416aAC                   if        $wddescu
416aAC                   eval      wddesc = $wddesc
416aAC                   endif

     *  Update record

     C                   update(e) wdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Dept" command '
     C                                       + '('
     C                                       + %Trim(%editc(wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(wdcode)
     C                                       + ')'
     C                                       + '-' + f1messageid

     C                   goto      endchange
     C                   endif

     *  Update Optiond record.

     C                   exsr      optionupd

     C     endchange     endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $wdwhsee = '1'
     C                   eval      $wdwhsee = '0'
     C                   endif

     C                   if        $wdcodee = '1'
     C                   eval      $wdcodee = '0'
     C                   endif

     C                   if        $wdpmthe = '1'
     C                   eval      $wdpmthe = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  deleterec   Delete record.
     *----------------------------------------------------------------

     C     deleterec     begsr
     C                   eval      error = *off
640aA
640aA*  Skip slot delete for *DELETEWEB (already done by MRC)
640aA
640aAC                   if        $psubcmd = '*DELETEWEB'
640aAC                   goto      skipDelete
640aAC                   endif

     *  No slots can be defined for department.

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $wdwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $wdcode

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '

     C                   call(e)   'DRISLOT'
     C                   parm      '*NXTSLOT'    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm                    $drireturn
     C                   parm                    $drimessage
     C     $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   when      $drireturn = '*OK'
     C                   eval      error = *on
     C                   eval      $wdcodee = '1'
     C                   eval      $preturn = 'SLOTEXIST'
     C                   exsr      getmsg
     C                   goto      enddel

     C                   endsl

     *  Get and lock record.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif

     C                   exsr      getdept

     C                   if        error
     C                   goto      enddel
     C                   endif

     *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

     *  Delete record.

     C                   delete(e) wdrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Dept" '
     C                                       + 'command '
     C                                       + '('
     C                                       + %Trim(%editc($wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($wdcode)
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid

     C                   goto      enddel
     C                   endif

640aAc     skipDelete    tag

     *  Delete task detail records.

     C     *loval        setll     taskdet
 1B  C                   dow       forever = forever
     C                   read      taskdet
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
 2B  C                   if        tdwhse = $wdwhse and tdwhdp = $wdcode
     C                   delete(e) tdrec
     C                   if        %error
     C                   endif
     C                   endif
 1E  C                   enddo

     *  Delete Optiond record.

     C                   exsr      optiondel

     C     enddel        endsr

640aA*----------------------------------------------------------------
640aA*  DeleteDeptWeb  Delete slot for *ADDWEB
640aA*----------------------------------------------------------------
640aA
640aAC     DeleteDeptWeb begsr
     C                   eval      error = *off

     C                   eval      lock = *on
     C                   exsr      getdept

     C                   if        not error
     C                   delete(e) wdrec
     C                   endif

     C                   eval      error = *off

     C                   endsr

     *----------------------------------------------------------------
     *  dept2ds  Move department fields to data structure fields
     *----------------------------------------------------------------

     C     dept2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $wdver#
     C                   clear                   $dept
     C                   eval      $wdver# = savever#

     C* Move information to data structure.

     C                   eval      $wdwhse = wdwhse
     C                   eval      $wdcode = wdcode
416aAC                   eval      $wddesc = wddesc
416aAC                   if        opmput  = 'Y'
416aAC                   eval      $wdpmth = '2'
416aAC                   else
416aAC                   eval      $wdpmth = '1'
416aAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getdept   Get slot def info.
     *----------------------------------------------------------------

     C     getdept       begsr

     C                   if        lock
     C     keywd         chain     whdept
     C                   else
     C     keywd         chain(n)  whdept
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDDEPT'
     C                   exsr      getmsg
     C                   goto      endgetdept
     C                   endif

     *  Get optiond record.

     C                   exsr      getopt

     C     endgetdept    endsr

     *----------------------------------------------------------------
     *  getopt    Get OptionD info.
     *----------------------------------------------------------------

     C     getopt        begsr

     C                   eval      kycode = '*PICK'
     C                   eval      kywhse = wdwhse
     C                   eval      kywhdp = wdcode

     C     keyopd        chain(n)  optiond

     C                   if        not %found
     C                   clear                   opdrec
     C                   endif

     C     endgetopt     endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'BLANKCODE'
     C                   eval      $pmessage = 'Code cannot be blank'

     C                   when      $preturn = 'CODENOTSNT'
     C                   eval      $pmessage = 'Slot definition code '
     C                                       + 'must be sent'

     C                   when      $preturn = 'DEPTEXIST'
     C                   eval      $pmessage = 'Department not added - '
     C                                       + 'Already exists ('
     C                                       + %Trim(%editc($wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($wdcode)
     C                                       + ')'

     C                   when      $preturn = 'INVLDDEPT'
     C                   eval      $pmessage = 'Invalid department'
     C                                       + '('
     C                                       + %Trim(%editc($wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($wdcode)
     C                                       + ')'

     C                   when      $preturn = 'INVLDPMTH'
     C                   eval      $pmessage = 'Invalid picking method '
     C                                       + '('
     C                                       + %trim($wdpmth)
     C                                       + ')'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'SLOTEXIST'
     C                   eval      $pmessage = 'Department not deleted - '
     C                                       + 'Slot exists '
     C                                       + '('
     C                                       + %trim($sldisp)
     C                                       + ')'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  optiondel  Delete OptionD record.
     *----------------------------------------------------------------

     C     optiondel     begsr

     C                   eval      kycode = '*PICK'
     C                   eval      kywhse = wdwhse
     C                   eval      kywhdp = wdcode

     C     keyopd        chain     optiond

 1X  C                   if        %found
     C                   delete(e) opdrec
     C                   if        %error
     C                   endif
 1E  C                   endif

     C     endoptiondel  endsr

     *----------------------------------------------------------------
     *  optionupd  Update OptionD record. Create if it doesn't exist.
     *----------------------------------------------------------------

     C     optionupd     begsr

     C                   eval      kycode = '*PICK'
     C                   eval      kywhse = wdwhse
     C                   eval      kywhdp = wdcode

     C     keyopd        chain     optiond

 1B  C                   select
 1B  C                   when      not %found

     C                   clear                   opdrec
     C                   eval      opdcod = kycode
     C                   eval      opdwhs = kywhse
     C                   eval      opdwdp = kywhdp
 2B  C                   if        $wdpmth = '1'
     C                   eval      opmput = 'N'
 2X  C                   else
     C                   eval      opmput = 'Y'
 2E  C                   endif
     C                   write(e)  opdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDOPT'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Opt" command '
     C                                       + '('
     C                                       + %Trim(%editc(wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(wdcode)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endoptionupd
     C                   endif
 1X
 1X  C                   when      %found
 1X
 2B  C                   if        $wdpmth = '1'
     C                   eval      opmput = 'N'
 2X  C                   else
     C                   eval      opmput = 'Y'
 2E  C                   endif
     C                   update(e) opdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDOPT'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Opt" command '
     C                                       + '('
     C                                       + %Trim(%editc(wdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(wdcode)
     C                                       + ')'
     C                                       + '-' + f2messageid
     C                   goto      endoptionupd
     C                   endif

 1E  C                   endsl

     C     endoptionupd  endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify dept information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfyadd

     *  Code cannot be blank.

     C                   if        $wdcode  = ' '
     C                   eval      error = *on
     C                   eval      $wdcodee = '1'
     C                   eval      $preturn = 'BLANKCODE'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Code cannot already exist.

     C                   eval      lock = *off
     C                   exsr      getdept
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $wdcodee = '1'
     C                   eval      $preturn = 'DEPTEXIST'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   other
     C                   eval      error = *off
     C                   eval      $preturn  = '*OK'
     C                   eval      $pmessage = ' '
     C                   endsl

     *  Do "After" general verificaion.

     C                   exsr      verifygen2

     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifychg   Verfify slot information for change
     *----------------------------------------------------------------

     C     verifychg     begsr

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfychg

     *  Do "After" general verificaion.

     C                   exsr      verifygen2
     C     error         cabeq     *on           endvfychg

     *  Get & lock record

     C                   if        $psubcmd = '*CHANGE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif
     C                   exsr      getdept
     C                   if        error
     C                   eval      $wdcodee = '1'
     C                   goto      endvfychg
     C                   endif

     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifygen1  General verification before add/chg verification
     *----------------------------------------------------------------

     C     verifygen1    begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $wdwhseu
     C                   eval      error = *on
     C                   eval      $wdwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     *  Verify warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $wdwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $wdwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $wdwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen1

     C                   endsl

     *  Code must be sent.

     C                   if        not $wdcodeu
     C                   eval      error = *on
     C                   eval      $wdcodee = '1'
     C                   eval      $preturn = 'CODENOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     C     endvfygen1    endsr

     *----------------------------------------------------------------
     *  verifygen2  General verification after add/chg verification
     *----------------------------------------------------------------

     C     verifygen2    begsr

     *  Verify picking method.

     C                   if        $wdpmthu and
     C                             $wdpmth <> '1' and $wdpmth <> '2'
     C                   eval      error = *on
     C                   eval      $wdpmthe = '1'
     C                   eval      $preturn = 'INVLDPMTH'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C     endvfygen2    endsr
