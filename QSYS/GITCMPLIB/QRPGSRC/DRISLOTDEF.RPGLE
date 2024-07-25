     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRISLOTDEF  Dakota realtime interface - Slot def maintenance
     *  07 November 2001
     *  Dave Sommerville
     *
416  *    11/07/01  DAS  4.16
     *      - Created
     *
416aA*    11/12/01  DAS  4.16a
     *      - Revised to include description.
     *
416bA*    01/21/02  DAS  4.16b
     *      - Moved getting record for change from changerec routine
     *        into verifychg routine.
     *
416c *    01/23/02  DAS  4.16c
     *      - Revised to identify if called from Dakota.
     *      - Revised to call DRIMAIN2 to update the host when called
     *        from Dakota. This allows the Dakota program to only have
     *        to make a single call to the interface.
     *
530 A*    04/01/10  JCJ  5.30 A
     *      - Revised invalid slot definition error to use field
     *        $sdcode instead of sdcode.
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
      *      *ADD              Add slot def.
      *
      *      *CHANGE           Change slot def.
      *
      *      *DELETE           Delete slot def.
      *
      *      *GET              Get slot def information.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fslotdef   uf a e           k disk    infds(file1ds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#SLOTDEF
     D saveVer#        s                   like($sdver#)

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

     D $vpal           s                   like(sdpal)
     D $vwhse          s                   like(sdwhse)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D HostCall        s               n

     D error           s               n
     D forever         s               n   inz(*on)
     D lock            s               n
     D pssrflag        s               n

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

     C                   eval      $slotdef = $pdata
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
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

     C                   when      $psubcmd = '*ADD'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      addsdef
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      changesdef
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      deletesdef
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      getsdef
     C                   if        not error
     C                   exsr      sdef2ds
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
     C                   exsr      deletesdef
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

     C                   eval      $pdata = $slotdef
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for SLOT1 file.

     C     keysd         klist
     C                   kfld                    $sdwhse
     C                   kfld                    $sdcode

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
     C                   parm      '*SLOTDEF'    $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      $slotdef      $dridata

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
     *  addsdef  Add slot def record.
     *----------------------------------------------------------------

     C     addsdef       begsr

     *  Clear slot record.

     C                   clear                   sdrec

     *  Move information into slot def fields.

     C                   eval      sdwhse = $sdwhse
     C                   eval      sdcode = $sdcode

416aAC                   if        $sddescu
416aAC                   eval      sddesc = $sddesc
416aAC                   endif

     C                   if        $sdlenu
     C                   eval      sdlen = $sdlen
     C                   endif

     C                   if        $sdwdthu
     C                   eval      sdwdth = $sdwdth
     C                   endif

     C                   if        $sdhgtu
     C                   eval      sdhgt  = $sdhgt
     C                   endif

     C                   if        $sdposu
     C                   eval      sdpos = $sdpos
     C                   else
     C                   eval      sdpos = 1
     C                   endif

     C                   if        $sdpalu
     C                   eval      sdpal = $sdpal
     C                   else
     C                   eval      sdpal = '*NONE'
     C                   endif

     *  Add record

     C                   write(e)  sdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Slot Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(sdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(sdcode)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endaddsdef
     C                   endif

     C     endaddsdef    endsr

     *----------------------------------------------------------------
     *  changesdef  Change slot def record.
     *----------------------------------------------------------------

     C     changesdef    begsr

     *  Move information into slot fields.

416aAC                   if        $sddescu
416aAC                   eval      sddesc = $sddesc
416aAC                   endif

     C                   if        $sdlenu
     C                   eval      sdlen = $sdlen
     C                   endif

     C                   if        $sdwdthu
     C                   eval      sdwdth = $sdwdth
     C                   endif

     C                   if        $sdhgtu
     C                   eval      sdhgt  = $sdhgt
     C                   endif

     C                   if        $sdposu
     C                   eval      sdpos = $sdpos
     C                   else
     C                   eval      sdpos = 1
     C                   endif

     C                   if        $sdpalu
     C                   eval      sdpal = $sdpal
     C                   else
     C                   eval      sdpal = '*NONE'
     C                   endif

     *  Update record

     C                   update(e) sdrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Slot Def" command '
     C                                       + '('
     C                                       + %Trim(%editc(sdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(sdcode)
     C                                       + ')'
     C                                       + '-' + f1messageid

     C                   goto      endchangesdef
     C                   endif

     C     endchangesdef endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $sdwhsee = '1'
     C                   eval      $sdwhsee = '0'
     C                   endif

     C                   if        $sdcodee = '1'
     C                   eval      $sdcodee = '0'
     C                   endif

     C                   if        $sdlene = '1'
     C                   eval      $sdlene = '0'
     C                   endif

     C                   if        $sdwdthe = '1'
     C                   eval      $sdwdthe = '0'
     C                   endif

     C                   if        $sdhgte = '1'
     C                   eval      $sdhgte = '0'
     C                   endif

     C                   if        $sdpale = '1'
     C                   eval      $sdpale = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  deletesdef  Delete slot def record.
     *----------------------------------------------------------------

     C     deletesdef    begsr
     C                   eval      error = *off

     C*  Get and lock slot def.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif

     C                   exsr      getsdef

     C                   if        error
     C                   goto      enddel
     C                   endif

      *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

      *  Delete slot record.

     C                   delete(e) sdrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Slot '
     C                                       + 'Def" command '
     C                                       + '('
     C                                       + %Trim(%editc($sdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($sdcode)
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid

     C                   goto      enddel
     C                   endif

     C     enddel        endsr

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

     C                   when      $preturn = 'INVLDPOS'
     C                   eval      $pmessage = 'Pallet positions must be '
     C                                       + 'greater than or equal to 1 '
     C                                       + '('
     C                                       + %Trim(%editc(sdpos:'L'))
     C                                       + ')'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'INVLDSDEF'
     C                   eval      $pmessage = 'Invalid slot def '
     C                                       + '('
     C                                       + %Trim(%editc(sdwhse:'Z'))
     C                                       + '/'
530 D ***                                    + %trim(sdcode)
530 MC                                       + %trim($sdcode)
     C                                       + ')'

     C                   when      $preturn = 'NEGATIVHGT'
     C                   eval      $pmessage = 'Height must be positive'

     C                   when      $preturn = 'NEGATIVLEN'
     C                   eval      $pmessage = 'Length must be positive'

     C                   when      $preturn = 'NEGATIVWID'
     C                   eval      $pmessage = 'Width must be positive'

     C                   when      $preturn = 'SDEFEXIST'
     C                   eval      $pmessage = 'Slot def not added - '
     C                                       + 'Already exists ('
     C                                       + %Trim(%editc(sdwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(sdcode)
     C                                       + ')'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  getsdef   Get slot def info.
     *----------------------------------------------------------------

     C     getsdef       begsr

     C                   if        lock
     C     keysd         chain     slotdef
     C                   else
     C     keysd         chain(n)  slotdef
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSDEF'
     C                   exsr      getmsg
     C                   goto      endgetsdef
     C                   endif

     C     endgetsdef    endsr

     *----------------------------------------------------------------
     *  sdef2ds  Move slot def fields to data structure fields
     *----------------------------------------------------------------

     C     sdef2ds       begsr

      *  Initialize data structure

     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#

     C* Move information to data structure.

     C                   eval      $sdwhse = sdwhse
     C                   eval      $sdcode = sdcode
416aAC                   eval      $sddesc = sddesc
     C                   eval      $sdlen  = sdlen
     C                   eval      $sdwdth = sdwdth
     C                   eval      $sdhgt  = sdhgt
     C                   eval      $sdpal  = sdpal
     C                   eval      $sdpos  = sdpos

     C                   endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify slot information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfyadd

     *  Code cannot be blank.

     C                   if        $sdcode  = ' '
     C                   eval      error = *on
     C                   eval      $sdcodee = '1'
     C                   eval      $preturn = 'BLANKCODE'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Code cannot already exist.

     C                   eval      lock = *off
     C                   exsr      getsdef
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $sdcodee = '1'
     C                   eval      $preturn = 'SDEFEXIST'
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

     *  Get & lock slot def information.

     C                   if        $psubcmd = '*CHANGE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif
     C                   exsr      getsdef
     C                   if        error
     C                   eval      error = *on
     C                   eval      $sdcodee = '1'
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

     C                   if        not $sdwhseu
     C                   eval      error = *on
     C                   eval      $sdwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     *  Verify warehouse.

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $sdwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $sdwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen1

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $sdwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen1

     C                   endsl

     *  Code must be sent.

     C                   if        not $sdcodeu
     C                   eval      error = *on
     C                   eval      $sdcodee = '1'
     C                   eval      $preturn = 'CODENOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     C     endvfygen1    endsr

     *----------------------------------------------------------------
     *  verifygen2  General verification after add/chg verification
     *----------------------------------------------------------------

     C     verifygen2    begsr

     *  Length can't be negative.

     C                   if        $sdlenu and $sdlen < 0
     C                   eval      error = *on
     C                   eval      $sdlene = '1'
     C                   eval      $preturn = 'NEGATIVLEN'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Width can't be negative.

     C                   if        $sdwdthu and $sdwdth < 0
     C                   eval      error = *on
     C                   eval      $sdwdthe = '1'
     C                   eval      $preturn = 'NEGATIVWID'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Height can't be negative.

     C                   if        $sdhgtu and $sdhgt < 0
     C                   eval      error = *on
     C                   eval      $sdhgte = '1'
     C                   eval      $preturn = 'NEGATIVHGT'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Pallet positions must be >= 1

     C                   if        $sdposu and $sdpos < 1
     C                   eval      error = *on
     C                   eval      $sdpose = '1'
     C                   eval      $preturn = 'INVLDPOS'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     *  Verify pallet code if sent.

     C                   if        $sdpalu
     C                   call(e)   'VFYPALLET'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $sdpal        $vpal
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $sdpale = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYPALLET'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   goto      endvfygen2

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $sdpale = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfygen2

     C                   endsl

     C                   endif

     C     endvfygen2    endsr
