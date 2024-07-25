     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIDESIG    Dakota realtime interface - Designation maintenance
     *  11 January 2002
     *  Dave Sommerville
     *
416  *    01/11/02  DAS  4.16
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
     *      - Revised getdesig routine to do special case handling
     *        when doing a *GET with a blank code.
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
      *      *CHANGE           Change department
      *
      *      *DELETE           Delete department
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

     Fdesig     uf a e           k disk    infds(file1ds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DESIG
     D saveVer#        s                   like($dsver#)

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

     C                   eval      $desig = $pdata
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
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      deleterec
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
     C                   exsr      getdesig
     C                   if        not error
     C                   exsr      desig2ds
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

     C                   eval      $pdata = $desig
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for DESIG file.

     C     keyds         klist
     C                   kfld                    $dscode

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
     C                   parm      '*DESIG'      $dricommand
     C                   parm      $psubcmd      $drisubcmd
     C                   parm      'H'           $drisys2upd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      $desig        $dridata

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
     *  addrec   Add record.
     *----------------------------------------------------------------

     C     addrec        begsr

     *  Clear record.

     C                   clear                   dsrec

     *  Move information into fields.

     C                   eval      dscode = $dscode

416aAC                   if        $dsdescu
416aAC                   eval      dsdesc = $dsdesc
416aAC                   endif

416aAC                   if        $dstypeu
416aAC                   eval      dstype = $dstype
416aAC                   endif

     *  Add record

     C                   write(e)  dsrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'Desig" command '
     C                                       + '('
     C                                       + %trim(dscode)
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endadd
     C                   endif

     C     endadd        endsr

     *----------------------------------------------------------------
     *  changerec    Change record.
     *----------------------------------------------------------------

     C     changerec     begsr

     *  Move information into fields.

416aAC                   if        $dsdescu
416aAC                   eval      dsdesc = $dsdesc
416aAC                   endif

416aAC                   if        $dstypeu
416aAC                   eval      dstype = $dstype
416aAC                   endif

     *  Update record

     C                   update(e) dsrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'Desig" command '
     C                                       + '('
     C                                       + %trim(dscode)
     C                                       + ')'
     C                                       + '-' + f1messageid

     C                   goto      endchange
     C                   endif

     C     endchange     endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $dscodee = '1'
     C                   eval      $dscodee = '0'
     C                   endif

     C                   if        $dstypee = '1'
     C                   eval      $dstypee = '0'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  deleterec   Delete record.
     *----------------------------------------------------------------

     C     deleterec     begsr
     C                   eval      error = *off

     *  Get and lock record.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif

     C                   exsr      getdesig

     C                   if        error
     C                   goto      enddel
     C                   endif

     *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   goto      enddel
     C                   endif

     *  Delete record.

     C                   delete(e) dsrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
     C                   eval      $pmessage = 'Error on "Delete Desig" '
     C                                       + 'command '
     C                                       + '('
     C                                       + %trim($dscode)
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid

     C                   goto      enddel
     C                   endif

     C     enddel        endsr

     *----------------------------------------------------------------
     *  desig2ds  Move designation fields to data structure fields
     *----------------------------------------------------------------

     C     desig2ds      begsr

      *  Initialize data structure

     C                   eval      savever# = $dsver#
     C                   clear                   $desig
     C                   eval      $dsver# = savever#

     C* Move information to data structure.

     C                   eval      $dscode = dscode
416aAC                   eval      $dsdesc = dsdesc
416aAC                   eval      $dstype = dstype

     C                   endsr

     *----------------------------------------------------------------
     *  getdesig  Get designation info.
     *----------------------------------------------------------------

     C     getdesig      begsr

     C                   if        $psubcmd = '*GET' and $dscode = ' '
     C                   eval      dscode = ' '
     C                   eval      dsdesc = ' '
     C                   eval      dstype = 'S'
     C                   goto      endgetdesig
     C                   endif

     C                   if        lock
     C     keyds         chain     desig
     C                   else
     C     keyds         chain(n)  desig
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $dstype = 'H'
     C                   eval      $preturn = 'INVLDDESIG'
     C                   exsr      getmsg
     C                   goto      endgetdesig
     C                   endif

     C     endgetdesig   endsr

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

     C                   when      $preturn = 'DESIGEXIST'
     C                   eval      $pmessage = 'Designation not added - '
     C                                       + 'Already exists ('
     C                                       + %trim($dscode)
     C                                       + ')'

     C                   when      $preturn = 'INVLDDESIG'
     C                   eval      $pmessage = 'Invalid designation '
     C                                       + '('
     C                                       + %trim($dscode)
     C                                       + ')'

     C                   when      $preturn = 'INVLDTYPE'
     C                   eval      $pmessage = 'Invalid designation type '
     C                                       + '('
     C                                       + %trim($dstype)
     C                                       + ')'

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify dept information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     *  Do "Before" general verificaion.

     C                   exsr      verifygen1
     C     error         cabeq     *on           endvfyadd

     *  Code cannot be blank.

     C                   if        $dscode  = ' '
     C                   eval      error = *on
     C                   eval      $dscodee = '1'
     C                   eval      $preturn = 'BLANKCODE'
     C                   exsr      getmsg
     C                   goto      endvfyadd
     C                   endif

     *  Code cannot already exist.

     C                   eval      lock = *off
     C                   exsr      getdesig
     C                   select
     C                   when      not error
     C                   eval      error = *on
     C                   eval      $dscodee = '1'
     C                   eval      $preturn = 'DESIGEXIST'
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

     *  Get & lock designation information.

     C                   if        $psubcmd = '*CHANGE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif
     C                   exsr      getdesig
     C                   if        error
     C                   eval      $dscodee = '1'
     C                   goto      endvfychg
     C                   endif

     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifygen1  General verification before add/chg verification
     *----------------------------------------------------------------

     C     verifygen1    begsr

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Code must be sent.

     C                   if        not $dscodeu
     C                   eval      error = *on
     C                   eval      $dscodee = '1'
     C                   eval      $preturn = 'CODENOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfygen1
     C                   endif

     C     endvfygen1    endsr

     *----------------------------------------------------------------
     *  verifygen2  General verification after add/chg verification
     *----------------------------------------------------------------

     C     verifygen2    begsr

     *  Verify designation type.

     C                   if        $dstypeu and
     C                             $dstype <> 'H' and $dstype <> 'S'
     C                   eval      error = *on
     C                   eval      $dstypee = '1'
     C                   eval      $preturn = 'INVLDTYPE'
     C                   exsr      getmsg
     C                   goto      endvfygen2
     C                   endif

     C     endvfygen2    endsr
