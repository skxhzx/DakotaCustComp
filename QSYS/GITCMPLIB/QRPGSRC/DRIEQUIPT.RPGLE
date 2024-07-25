     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2002')

     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIEQUIPT   Dakota realtime interface - Equipment transaction
     *  20 December 2002
     *  Dave Sommerville
     *
416  *    12/02/02  DAS  4.16
     *      - Created
417a *    05/19/03  RH   4.17a
     *      FIX: Set check out date/user/job to check in values if
     *      equip is being checked in but was never checked out.
417a *    04/29/04  RH   4.17b
     *      ENH: Equip code inreased from 6 to 8 - recompile
     *
500 A*    03/06/05  DAS  5.00
     *      ENH: Added command *GETCHKOUT.
     *
730aA*    10/14/19  LMC  7.30a
     *      ENH: Added P2P check - based on description containing P2P
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
      *      *ADD              Add transaction
      *
      *      *CHANGE           Change transaction
      *
      *      *CHKIN            Record check "In" transaction.
      *
      *      *CHKOUT           Record check "Out" transaction.
      *
      *      *DELETE           Delete transaction
      *
500 A *      *GETCHKOUT        Get equipment checked out to user.
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fequipt1   uf a e           k disk    usropn
     F                                     rename(etrec:etrec1)
     F                                     infds(file1ds)

     Fequipt2   uf a e           k disk    usropn
     F                                     rename(etrec:etrec2)
     F                                     infds(file3ds)

500 AFequipt5   if   e           k disk    usropn
500 AF                                     rename(etrec:etrec5)

500 AFequip     if   e           k disk    usropn

     Fpiret#    uf a e           k disk    usropn
     F                                     infds(file9ds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#EQUIPT
     D saveVer#        s                   like($etver#)

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhse          s                   like(etwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
     D first           s               n
     D HostCall        s               n
     D Pos1            s              2  0

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds
      /copy qcopysrc,c#file3ds
      /copy qcopysrc,c#file4ds
      /copy qcopysrc,c#file9ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamp       s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

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

     C                   eval      $equipt = $pdata
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
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '
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
     C                   exsr      verifyadd
     C                   if        not error
     C                   exsr      recadd
     C                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   exsr      verifychg
     C                   if        not error
     C                   exsr      recchange
     C                   endif

     C                   when      $psubcmd = '*CHKIN'
     C                   exsr      verifychkin
     C                   if        not error
     C                   exsr      checkin
     C                   endif

     C                   when      $psubcmd = '*CHKOUT'
     C                   exsr      verifychkout
     C                   if        not error
     C                   exsr      checkout
     C                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   exsr      verifydel
     C                   if        not error
     C                   exsr      recdelete
     C                   endif

500 AC                   when      $psubcmd = '*GETCHKOUT'
500 AC                   exsr      vfygetchkout
500 AC                   if        not error
500 AC                   exsr      getchkout
500 AC                   endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      verifyadd

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      verifychg

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      verifydel

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                      + '(' + %trim($psubcmd) + ') '
     C                                      + 'sent to ' + %trim(#pgm)

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $equipt
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     C     *like         define    etwhse        kywhse
     C     *like         define    ettrn#        kytrn#
     C     *like         define    etactv        kyactv
     C     *like         define    etcode        kycode
500 AC     *like         define    etemp#        kyemp#
500 A
500 A*  Define key for EQUIP file.
500 A
500 AC     keyeq         klist
500 AC                   kfld                    kywhse
500 AC                   kfld                    kycode

     *  Define key for WHDEPT file.

     C     keyet1        klist
     C                   kfld                    kywhse
     C                   kfld                    kytrn#

     C     keyet2        klist
     C                   kfld                    kywhse
     C                   kfld                    kyactv
     C                   kfld                    kycode

500 AC     keyet5        klist
500 AC                   kfld                    kywhse
500 AC                   kfld                    kyemp#
500 AC                   kfld                    kyactv

     C     keyet#        klist
     C                   kfld                    kywhse

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
     C                                       + %trim(#pgm)
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
     *  calcdur   Calculate duration.
     *----------------------------------------------------------------

     C     calcdur       begsr

     C     tostamp       subdur    99999:*MN     oldeststamp

     C                   select
     C                   when      fromstamp >= tostamp
     C                   eval      duration = 0
     C                   when      fromstamp <= oldeststamp
     C                   eval      duration = 99999
     C                   other
     C     tostamp       subdur    fromstamp     ttlsec:*S
     C     tostamp       subdur    fromstamp     ttlmin:*MN
     C                   eval      ttlminsec = ttlmin * 60
     C                   eval      remSec = ttlSec - ttlminsec
     C                   if        remSec = 0
     C                   eval      duration = ttlMin
     C                   else
     C                   eval      duration = ttlMin + (remsec/60)
     C                   endif
     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  checkin  Check In equipment.
     *----------------------------------------------------------------

     C     checkin       begsr
416aAC                   time                    currstamp
416aAC                   eval      lock1 = *off
416aAC                   eval      lock2 = *off

     *  See if there is an active record for equipment for diff employee.
     *    If so, unactivate the record.

416aAC                   eval      lock2 = *on
416aAC                   exsr      recget2x
     C                   if        found
416aAC                   exsr      recunactivate
416aAC                   endif
416aAC                   eval      lock2 = *off

     *  See if there is an active record for equipment for the employee.
     *    If so, update record.
     *    Otherwise create In record.

416aAC                   eval      lock2 = *on
416aAC                   exsr      recget2e
     C                   if        found
416aAC                   exsr      recchkin
416aAC                   else
416aAC                   exsr      reccrtin
416aAC                   endif

     *  Initialize datastructure fields.

416aAC                   exsr      file2ds

     C     endchkin      endsr

     *----------------------------------------------------------------
     *  checkout   Check Out equipment.
     *----------------------------------------------------------------

     C     checkout      begsr
     C                   time                    currstamp
416aAC                   eval      lock1 = *off
416aAC                   eval      lock2 = *off

     *  See if there is an active record for equipment.
     *    If so, unactivate the record.

416aAC                   eval      lock2 = *on
416aAC                   exsr      recget2
     C                   if        found
416aAC                   exsr      recunactivate
416aAC                   endif
416aAC                   eval      lock2 = *off

     *  Now create active Out record ...

416aAC                   exsr      reccrtout

     *  Initialize datastructure fields.

416aAC                   exsr      file2ds

     C     endchkout     endsr
416bA
416bA*----------------------------------------------------------------
416bA*  fileclose  Close file btswhse
416bA*----------------------------------------------------------------
416bA
416bAC     fileclose     begsr

     C                   if        %open(equipt1)
     C                   close(e)  equipt1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSET1'
     C                   eval      $pmessage = 'Error closing EQUIPT1 file'
     C                   endif
     C                   endif

     C                   if        %open(equipt2)
     C                   close(e)  equipt2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSET2'
     C                   eval      $pmessage = 'Error closing EQUIPT2 file'
     C                   endif
     C                   endif

500 AC                   if        %open(equipt5)
500 AC                   close(e)  equipt5
500 AC                   if        %error
500 AC                   eval      error = *on
500 AC                   eval      $preturn = 'ERRCLSET5'
500 AC                   eval      $pmessage = 'Error closing EQUIPT5 file'
500 AC                   endif
500 AC                   endif

     C                   if        %open(piret#)
     C                   close(e)  piret#
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSET#'
     C                   eval      $pmessage = 'Error closing PIRET# file'
     C                   endif
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  fileopenequip  Open file equip
500 A*----------------------------------------------------------------
500 A
500 AC     fileopenequip begsr

     C                   if        not %open(equip)
     C                   open(e)   equip
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERREQ'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file EQUIP in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen1 Open file equipt1
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen1     begsr

     C                   if        not %open(equipt1)
     C                   open(e)   equipt1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRET1'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file EQUIPT1 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopen2 Open file equipt2
416bA*----------------------------------------------------------------
416bA
416bAC     fileopen2     begsr

     C                   if        not %open(equipt2)
     C                   open(e)   equipt2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRET2'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file EQUIPT2 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  fileopen5 Open file equipt5
500 A*----------------------------------------------------------------
500 A
500 AC     fileopen5     begsr

     C                   if        not %open(equipt5)
     C                   open(e)   equipt5
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRET5'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file EQUIPT5 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenet#    Open file piret#
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenet#   begsr

     C                   if        not %open(piret#)
     C                   open(e)   piret#
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRET#'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file PIRET# in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  file2ds  Move file fields to data structure fields
     *----------------------------------------------------------------

     C     file2ds       begsr

     * Initialize data structure.

     C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#

     * Move information to data structure.

     C                   eval      $etwhsee = $driok
416aAC                   eval      $etwhse = etwhse

     C                   eval      $ettrn#e = $driok
416aAC                   eval      $ettrn# = ettrn#

     C                   eval      $etcodee = $driok
416aAC                   eval      $etcode = etcode

     C                   eval      $etemp#e = $driok
416aAC                   eval      $etemp# = etemp#

     C                   eval      $etactve = $driok
416aAC                   eval      $etactv = etactv

     C                   eval      $etotrne = $driok
416aAC                   eval      $etotrn = etotrn

     C                   eval      $etoqfle = $driok
416aAC                   eval      $etoqfl = etoqfl

     C                   eval      $etoxfle = $driok
416aAC                   eval      $etoxfl = etoxfl

     C                   eval      $etodtse = $driok
416aAC                   eval      $etodts = etodts

     C                   eval      $etousre = $driok
416aAC                   eval      $etousr = etousr

     C                   eval      $etojobe = $driok
416aAC                   eval      $etojob = etojob

     C                   eval      $etonbre = $driok
416aAC                   eval      $etonbr = etonbr

     C                   eval      $etitrne = $driok
416aAC                   eval      $etotrn = etotrn

     C                   eval      $etiqfle = $driok
416aAC                   eval      $etiqfl = etiqfl

     C                   eval      $etixfle = $driok
416aAC                   eval      $etixfl = etixfl

     C                   eval      $etidtse = $driok
416aAC                   eval      $etidts = etidts

     C                   eval      $etiusre = $driok
416aAC                   eval      $etiusr = etiusr

     C                   eval      $etijobe = $driok
416aAC                   eval      $etijob = etijob

     C                   eval      $etinbre = $driok
416aAC                   eval      $etinbr = etinbr

     C                   eval      $etmine = $driok
416aAC                   eval      $etmin = etmin

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  getchkout  Get equipment that is checked out to employee.
500 A*
500 A*  Notes:
500 A*
500 A*    - Checking for a specific equipment type.
500 A*    - Equipment type is sent via the equipment code field.
500 A*
500 A*----------------------------------------------------------------
500 A
500 AC     getchkout     begsr

     C                   eval      first = *on

     C                   dow       forever = forever

     *  Get an active record for employee.

     C                   if        first
     C                   exsr      recget5
     C                   eval      first = *off
     C                   else
     C                   exsr      recget5nxt
     C                   endif

     *  If none found, then throw error and get out.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $preturn  = '*NOTFOUND'
     C                   eval      $pmessage = 'Equipment type '
     C                                       + %trim($etcode)
     C                                       + ' not checked out to user'
     C                   leave
     C                   endif

     *  Otherwise, active record found. Now see if it is the right type.

     C                   eval      kywhse = etwhse
     C                   eval      kycode = etcode
     C                   exsr      recgetequip

     *    Not the correct type ... Loop for next active record.

     C                   if        not found or eqtype <> $etcode
     C                   iter
     C                   endif

     *    Correct type ... Send it back to user.

     C                   eval      $etcode = eqcode
730aA /free
730aA   pos1 = 0;
730aA   pos1 = %scan('P2P':eqdesc:1);
730aA   if pos1 >= 1;
730aA     $etp2p= *on;
730aA   endif;
730aA /end-free
     C                   leave

     C                   enddo

     C     endgetchkout  endsr

     *----------------------------------------------------------------
     *  getnewtrn#  Get new transaction number
     *----------------------------------------------------------------

     C     getnewtrn#    begsr

     C     *like         define    ettrn#        maxid
     C                   eval      maxid = *hival
     C                   eval      filebeg = *off

     *  Open file

     C                   exsr      fileopenet#
     C     error         cabeq     *on           endgetnew

     *  Get next number to be used.

     C                   eval      kywhse = $etwhse

     C     1             do        2             i

     C     keyet#        chain     piret#
     C                   if        %found
     C                   leave
     C                   endif

     C                   if        i = 2
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRGETET#'
     C                   eval      $pmessage = 'Error getting PIRET# record'
     C                                      + ' ('
     C                                      + %trim(%editc($etwhse:'P'))
     C                                      + ')'
     C                   goto      endgetnew
     C                   endif

     C                   eval      nxewhs = $etwhse
     C                   eval      nxenum = 0
     C                   write(e)  nxerec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDET#'
     C                   eval      $pmessage = 'Error on "Write '
     C                                      + 'PIRET#" command '
     C                                      + '('
     C                                      + %trim(%editc($etwhse:'P'))
     C                                      + ')'
     C                                      + '-' + f9messageid
     C                   goto      endgetnew
     C                   endif

     C                   enddo

     C                   if        nxenum < 2 or nxenum > maxid
     C                   eval      nxenum = 1
     C                   eval      filebeg = *on
     C                   endif

     *  Loop until we find a number that doesn't exist.

     C                   dow       forever = forever

     *    See if number exists in file.

     C                   eval      $ettrn# = nxenum
     C                   eval      lock1 = *off
     C                   exsr      recget1

     *    If record not found, leave.

     C                   if        not found
     C                   eval      error = *off
     C                   leave
     C                   endif

     *    Otherwise, increment number and try again.

     C                   if        nxenum = maxid
     C                   if        filebeg
     C                   eval      error = *on
     C                   leave
     C                   else
     C                   eval      filebeg = *on
     C                   eval      nxenum = 1
     C                   iter
     C                   endif
     C                   endif

     C                   eval      nxenum = nxenum + 1
     C                   iter

     C                   enddo

     *  Update dataarea with next number to be used.

     C                   eval      nxenum = nxenum + 1
     C                   update(e) nxerec
     C                   if        %error
     C                   endif

     C     endgetnew     endsr

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

     C     inzchkflds    begsr

     C                   eval      $etwhsee = $driok
     C                   eval      $ettrn#e = $driok
     C                   eval      $etcodee = $driok
     C                   eval      $etemp#e = $driok
     C                   eval      $etactve = $driok
     C                   eval      $etotrne = $driok
     C                   eval      $etoqfle = $driok
     C                   eval      $etoxfle = $driok
     C                   eval      $etodtse = $driok
     C                   eval      $etousre = $driok
     C                   eval      $etojobe = $driok
     C                   eval      $etonbre = $driok
     C                   eval      $etitrne = $driok
     C                   eval      $etiqfle = $driok
     C                   eval      $etixfle = $driok
     C                   eval      $etidtse = $driok
     C                   eval      $etiusre = $driok
     C                   eval      $etijobe = $driok
     C                   eval      $etinbre = $driok
     C                   eval      $etmine  = $driok

     C                   endsr

     *----------------------------------------------------------------
     *  recadd   Add record.
     *----------------------------------------------------------------

     C     recadd        begsr
     C                   time                    currstamp

     *  Clear record.

     C                   clear                   etrec1

     *  Get transaction number to use if tran# sent is zero.

416aAC                   if        $ettrn# = 0
416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn  = 'NOAVLTRN#'
     C                   eval      $pmessage = 'No availalbe Tran # found'
     C                   goto      endadd
     C                   endif
     C                   endif

     *  Move information into fields.

     C                   eval      etwhse = $etwhse
     C                   eval      etcode = $etcode

416aAC                   if        $etemp#u
416aAC                   eval      etemp# = $etemp#
416aAC                   endif

416aAC                   if        $etactvu
416aAC                   eval      etactv = $etactv
416aAC                   else
416aAC                   eval      etactv = '0'
416aAC                   endif

416aAC                   if        $etotrnu
416aAC                   eval      etotrn = $etotrn
416aAC                   endif

416aAC                   if        $etoqflu
416aAC                   eval      etoqfl = $etoqfl
416aAC                   else
416aAC                   eval      etoqfl = '0'
416aAC                   endif

416aAC                   if        $etoxflu
416aAC                   eval      etoxfl = $etoxfl
416aAC                   else
416aAC                   eval      etoxfl = '0'
416aAC                   endif

416aAC                   if        $etodtsu
416aAC                   eval      etodts = $etodts
416aAC                   else
416aAC                   eval      etodts = currstamp
416aAC                   endif

416aAC                   if        $etousru
416aAC                   eval      etousr = $etousr
416aAC                   endif

416aAC                   if        $etojobu
416aAC                   eval      etojob = $etojob
416aAC                   endif

416aAC                   if        $etonbru
416aAC                   eval      etonbr = $etonbr
416aAC                   endif

416aAC                   if        $etitrnu
416aAC                   eval      etitrn = $etitrn
416aAC                   endif

416aAC                   if        $etiqflu
416aAC                   eval      etiqfl = $etiqfl
416aAC                   else
416aAC                   eval      etiqfl = '0'
416aAC                   endif

416aAC                   if        $etixflu
416aAC                   eval      etixfl = $etixfl
416aAC                   else
416aAC                   eval      etixfl = '0'
416aAC                   endif

416aAC                   if        $etidtsu
416aAC                   eval      etidts = $etidts
416aAC                   else
416aAC                   eval      etidts = currstamp
416aAC                   endif

416aAC                   if        $etiusru
416aAC                   eval      etiusr = $etiusr
416aAC                   endif

416aAC                   if        $etijobu
416aAC                   eval      etijob = $etijob
416aAC                   endif

416aAC                   if        $etinbru
416aAC                   eval      etinbr = $etinbr
416aAC                   endif

416aAC                   if        $etminu
416aAC                   eval      etmin = $etmin
416aAC                   endif

     *  Add record

     C                   write(e)  etrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                       + 'EquipT1" command '
     C                                       + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endadd
     C                   endif

     C     endadd        endsr

     *----------------------------------------------------------------
     *  recchange  Change record.
     *----------------------------------------------------------------

     C     recchange     begsr

     *  Move information into fields.

416aAC                   if        $etcodeu
     C                   eval      etcode = $etcode
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etemp#u
416aAC                   eval      etemp# = $etemp#
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etactvu
416aAC                   eval      etactv = $etactv
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etotrnu
416aAC                   eval      etotrn = $etotrn
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etoqflu
416aAC                   eval      etoqfl = $etoqfl
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etoxflu
416aAC                   eval      etoxfl = $etoxfl
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etodtsu
416aAC                   eval      etodts = $etodts
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etousru
416aAC                   eval      etousr = $etousr
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etojobu
416aAC                   eval      etojob = $etojob
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etonbru
416aAC                   eval      etonbr = $etonbr
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etitrnu
416aAC                   eval      etitrn = $etitrn
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etiqflu
416aAC                   eval      etiqfl = $etiqfl
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etixflu
416aAC                   eval      etixfl = $etixfl
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etidtsu
416aAC                   eval      etidts = $etidts
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etiusru
416aAC                   eval      etiusr = $etiusr
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etijobu
416aAC                   eval      etijob = $etijob
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etinbru
416aAC                   eval      etinbr = $etinbr
     C                   eval      changed = *on
416aAC                   endif

416aAC                   if        $etodtsu or $etidtsu
416aAC                   eval      fromstamp = etodts
416aAC                   eval      tostamp   = etidts
416aAC                   exsr      calcdur
416aAC                   eval      etmin = duration
     C                   eval      changed = *on
416aAC                   endif

     *  If nothing changed, then unlock record and get out.

     C                   if        not changed
     C                   unlock    equipt1
     C                   goto      endchange
     C                   endif

     *  Something change, update record.

     C                   update(e) etrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
     C                   eval      $pmessage = 'Error on "Update '
     C                                       + 'EquipT1" command '
     C                                       + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   goto      endchange
     C                   endif

     C     endchange     endsr

     *----------------------------------------------------------------
     *  recchkin     Update Out record with In information.
     *----------------------------------------------------------------

     C     recchkin      begsr

     *  Move information into fields.

416aAC                   eval      etactv = '0'

416aAC                   if        $etitrnu
416aAC                   eval      etitrn = $etitrn
416aAC                   endif

416aAC                   if        $etiqflu
416aAC                   eval      etiqfl = $etiqfl
416aAC                   else
416aAC                   eval      etiqfl = '0'
416aAC                   endif

416aAC                   if        $etixflu
416aAC                   eval      etixfl = $etixfl
416aAC                   else
416aAC                   eval      etixfl = '0'
416aAC                   endif

416aAC                   if        $etidtsu
416aAC                   eval      etidts = $etidts
416aAC                   else
416aAC                   eval      etidts = currstamp
416aAC                   endif

416aAC                   eval      fromstamp = etodts
416aAC                   eval      tostamp   = etidts
416aAC                   exsr      calcdur
416aAC                   eval      etmin = duration

416aAC                   if        $etiusru
416aAC                   eval      etiusr = $etiusr
416aAC                   endif

416aAC                   if        $etijobu
416aAC                   eval      etijob = $etijob
416aAC                   endif

416aAC                   if        $etinbru
416aAC                   eval      etinbr = $etinbr
416aAC                   endif

     *  Update record

     C                   update(e) etrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC2'
     C                   eval      $pmessage = 'Error on "Update '
     C                                      + 'EQUIPT2" command '
     C                                      + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                      + ')'
     C                                      + '-' + f3messageid
     C                   goto      endin
     C                   endif

     C     endin         endsr

     *----------------------------------------------------------------
     *  reccrtin    Create In record.
     *----------------------------------------------------------------

     C     reccrtin      begsr
     C                   time                    currstamp

     *  Clear record.

     C                   clear                   etrec1

     *  Get transaction number to use.

416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn  = 'NOAVLTRN#'
     C                   eval      $pmessage = 'No availalbe Tran # found'
     C                   goto      endcrtin
     C                   endif

     *  Move information into fields.

     C                   eval      etwhse = $etwhse
     C                   eval      ettrn# = $ettrn#
     C                   eval      etcode = $etcode

416aAC                   if        $etemp#u
416aAC                   eval      etemp# = $etemp#
416aAC                   endif

416aAC                   eval      etactv = '0'

416aAC                   eval      etoqfl = '0'
416aAC                   eval      etoxfl = '0'
416aAC                   eval      etodts = *loval

416aAC                   if        $etitrnu
416aAC                   eval      etitrn = $etitrn
416aAC                   endif

416aAC                   if        $etiqflu
416aAC                   eval      etiqfl = $etiqfl
416aAC                   else
416aAC                   eval      etiqfl = '0'
416aAC                   endif

416aAC                   if        $etixflu
416aAC                   eval      etixfl = $etixfl
416aAC                   else
416aAC                   eval      etixfl = '0'
416aAC                   endif

416aAC                   if        $etidtsu
416aAC                   eval      etidts = $etidts
416aAC                   else
416aAC                   eval      etidts = currstamp
416aAC                   endif
417a *  If checking in without being checked out, set check out
417a *  date/user/job to check in values.
417aAC                   if        etotrn = 0
417aAC                   eval      etodts = etidts
417aAC                   eval      etousr = $etiusr
417aAC                   eval      etojob = $etijob
417aAC                   endif

416aAC                   if        $etiusru
416aAC                   eval      etiusr = $etiusr
416aAC                   eval      etousr = $etiusr
416aAC                   endif

416aAC                   if        $etijobu
416aAC                   eval      etijob = $etijob
416aAC                   eval      etojob = $etijob
416aAC                   endif

416aAC                   if        $etinbru
416aAC                   eval      etinbr = $etinbr
416aAC                   eval      etonbr = $etinbr
416aAC                   endif

     *  Add record

     C                   write(e)  etrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                      + 'EQUIPT1" command '
     C                                      + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endcrtin
     C                   endif

     C     endcrtin      endsr

     *----------------------------------------------------------------
     *  reccrtout   Create Out record.
     *----------------------------------------------------------------

     C     reccrtout     begsr
     C                   time                    currstamp

     *  Clear record.

     C                   clear                   etrec1

     *  Get transaction number to use.

416aAC                   exsr      getnewtrn#
     C                   if        error
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn  = 'NOAVLTRN#'
     C                   eval      $pmessage = 'No availalbe Tran # found'
     C                   goto      endcrtout
     C                   endif

     *  Move information into fields.

     C                   eval      etwhse = $etwhse
     C                   eval      ettrn# = $ettrn#
     C                   eval      etcode = $etcode

416aAC                   if        $etemp#u
416aAC                   eval      etemp# = $etemp#
416aAC                   endif

416aAC                   eval      etactv = '1'

416aAC                   if        $etotrnu
416aAC                   eval      etotrn = $etotrn
416aAC                   endif

416aAC                   if        $etoqflu
416aAC                   eval      etoqfl = $etoqfl
416aAC                   else
416aAC                   eval      etoqfl = '0'
416aAC                   endif

416aAC                   if        $etoxflu
416aAC                   eval      etoxfl = $etoxfl
416aAC                   else
416aAC                   eval      etoxfl = '0'
416aAC                   endif

416aAC                   if        $etodtsu
416aAC                   eval      etodts = $etodts
416aAC                   else
416aAC                   eval      etodts = currstamp
416aAC                   endif

416aAC                   if        $etousru
416aAC                   eval      etousr = $etousr
416aAC                   endif

416aAC                   if        $etojobu
416aAC                   eval      etojob = $etojob
416aAC                   endif

416aAC                   if        $etonbru
416aAC                   eval      etonbr = $etonbr
416aAC                   endif

416aAC                   eval      etidts = *loval

     *  Add record

     C                   write(e)  etrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
     C                   eval      $pmessage = 'Error on "Write '
     C                                      + 'EQUIPT1" command '
     C                                      + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid
     C                   goto      endcrtout
     C                   endif

     C     endcrtout     endsr

     *----------------------------------------------------------------
     *  recdelete   Delete record.
     *----------------------------------------------------------------

     C     recdelete     begsr
     C                   eval      error = *off

     C                   delete(e) etrec1
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELREC'
     C                   eval      $pmessage = 'Error on "Delete '
     C                                      + 'EQUIPT1" command '
     C                                      + '('
     C                                       + %Trim(%editc($etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc($ettrn#:'P'))
     C                                      + ')'
     C                                      + '-' + f1messageid

     C                   goto      enddel
     C                   endif

     C     enddel        endsr

500 A*----------------------------------------------------------------
500 A*  recgetequip   Get EQUIP record.
500 A*----------------------------------------------------------------

     C     recgetequip   begsr

     *  Open file.

     C                   exsr      fileopenequip
     C     error         cabeq     *on           endgetequip

     *  Get record.

     C     keyeq         chain     equip

     C                   if        %found
     C                   eval      found = *on
     C                   else
     C                   eval      found = *off
     C                   endif

     C     endgetequip   endsr

     *----------------------------------------------------------------
     *  recget1   Get EQUIPT1 record.
     *----------------------------------------------------------------

     C     recget1       begsr

     *  Open file.

     C                   exsr      fileopen1
     C     error         cabeq     *on           endget1

     *  Get record.

     C                   eval      kywhse  = $etwhse
     C                   eval      kytrn#  = $ettrn#

     C                   if        lock1
     C     keyet1        chain     equipt1
     C                   else
     C     keyet1        chain(n)  equipt1
     C                   endif

     C                   if        %found
     C                   eval      found = *on
     C                   else
     C                   eval      found = *off
     C                   endif

     C     endget1       endsr

     *----------------------------------------------------------------
     *  recget2   Get EQUIPT2 record.
     *----------------------------------------------------------------

     C     recget2       begsr

     *  Open file.

     C                   exsr      fileopen2
     C     error         cabeq     *on           endget2

     *  In theory, equipment should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kywhse = $etwhse
     C                   eval      kycode = $etcode
     C                   eval      kyactv = '1'
     C     keyet2        setgt     equipt2

     C                   if        lock2
     C     keyet2        readpe    equipt2
     C                   else
     C     keyet2        readpe(n) equipt2
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget2       endsr

     *----------------------------------------------------------------
     *  recget2e  Get EQUIPT2 record for specific employee.
     *----------------------------------------------------------------

     C     recget2e      begsr

     *  Open file.

     C                   exsr      fileopen2
     C     error         cabeq     *on           endget2e

     *  In theory, equipment should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kywhse = $etwhse
     C                   eval      kycode = $etcode
     C                   eval      kyactv = '1'
     C     keyet2        setgt     equipt2

     C                   dow       forever = forever

     C                   if        lock2
     C     keyet2        readpe    equipt2
     C                   else
     C     keyet2        readpe(n) equipt2
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   leave
     C                   endif

     C                   if        etemp# <> $etemp#
     C                   iter
     C                   endif

     C                   eval      found = *on
     C                   leave

     C                   enddo

     C     endget2e      endsr

     *----------------------------------------------------------------
     *  recget2x  Get EQUIPT2 record that doesn't match employee.
     *----------------------------------------------------------------

     C     recget2x      begsr

     *  Open file.

     C                   exsr      fileopen2
     C     error         cabeq     *on           endget2x

     *  In theory, equipment should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kywhse = $etwhse
     C                   eval      kycode = $etcode
     C                   eval      kyactv = '1'
     C     keyet2        setgt     equipt2

     C                   dow       forever = forever

     C                   if        lock2
     C     keyet2        readpe    equipt2
     C                   else
     C     keyet2        readpe(n) equipt2
     C                   endif

     C                   if        %eof
     C                   eval      found = *off
     C                   leave
     C                   endif

     C                   if        etemp# = $etemp#
     C                   iter
     C                   endif

     C                   eval      found = *on
     C                   leave

     C                   enddo

     C     endget2x      endsr

500 A*----------------------------------------------------------------
500 A*  recget5   Get EQUIPT5 record.
500 A*----------------------------------------------------------------
500 A
500 AC     recget5       begsr

     *  Open file.

     C                   exsr      fileopen5
     C     error         cabeq     *on           endget5

     *  In theory, equipment should only have one active tran record.
     *  However, to protect against multiples, this routine does a setgt
     *  and then reads backwards to get the most recent active record.

     C                   eval      kywhse = $etwhse
     C                   eval      kyemp# = $etemp#
     C                   eval      kyactv = '1'
     C     keyet5        setgt     equipt5

     C     keyet5        readpe    equipt5

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C     endget5       endsr

500 A*----------------------------------------------------------------
500 A*  recget5nxt   Get next EQUIPT5 record.
500 A*----------------------------------------------------------------
500 A
500 AC     recget5nxt    begsr

     *  Open file.

     C     keyet5        readpe    equipt5

     C                   if        %eof
     C                   eval      found = *off
     C                   else
     C                   eval      found = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  recunactivate   Unactive record.
     *----------------------------------------------------------------

     C     recunactivate begsr

     *  Move information into fields.

416aAC                   eval      etactv = '0'

416aAC                   eval      etidts = currstamp

416aAC                   eval      fromstamp = etodts
416aAC                   eval      tostamp   = etidts
416aAC                   exsr      calcdur
416aAC                   eval      etmin = duration

416aAC                   if        $etousru and $psubcmd = '*OUT'
416aAC                   eval      etiusr = $etousr
416aAC                   endif

416aAC                   if        $etojobu and $psubcmd = '*OUT'
416aAC                   eval      etijob = $etojob
416aAC                   endif

416aAC                   if        $etonbru and $psubcmd = '*OUT'
416aAC                   eval      etinbr = $etonbr
416aAC                   endif

416aAC                   if        $etiusru and $psubcmd = '*IN'
416aAC                   eval      etiusr = $etiusr
416aAC                   endif

416aAC                   if        $etijobu and $psubcmd = '*IN'
416aAC                   eval      etijob = $etijob
416aAC                   endif

416aAC                   if        $etinbru and $psubcmd = '*IN'
416aAC                   eval      etinbr = $etinbr
416aAC                   endif


     *  Update record

     C                   update(e) etrec2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC2'
     C                   eval      $pmessage = 'Error on "Update '
     C                                      + 'EQUIPT2" command '
     C                                      + '('
     C                                       + %Trim(%editc(etwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(%editc(ettrn#:'P'))
     C                                      + ')'
     C                                      + '-' + f3messageid
     C                   goto      endunact
     C                   endif

     C     endunact      endsr

     *----------------------------------------------------------------
     *  verifyadd  Verify information when adding.
     *----------------------------------------------------------------

     C     verifyadd     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfyadd

     C                   exsr      vfytrn#sent
     C     error         cabeq     *on           endvfyadd

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfyadd

     *  Validate warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $etwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $etwhsee = $drierror
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #pgm
     C                   goto      endvfyadd

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $etwhsee = $drierror
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfyadd

     C                   endsl

     *  Code cannot be blank.

     C                   if        $etcode  = ' '
     C                   eval      error = *on
     C                   eval      $etcodee = '1'
     C                   eval      $preturn = 'BLANKCODE'
     C                   goto      endvfyadd
     C                   endif

     *  Get record if transaction number sent.

     C                   if        $ettrn# > 0
     C                   eval      lock1 = *off
     C                   exsr      recget1

     *  Error if record found.

     C                   if        found
     C                   eval      error = *on
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn = 'TRN1EXIST'
     C                   eval      $pmessage = 'Transaction already exists '
     C                                       + '('
     C                                       + %trim(%editc($ettrn#:'P'))
     C                                       + ')'
     C                   goto      endvfyadd
     C                   endif
     C                   endif

     C     endvfyadd     endsr

     *----------------------------------------------------------------
     *  verifychg   Verify information for change
     *----------------------------------------------------------------

     C     verifychg     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfychg

     C                   exsr      vfytrn#sent
     C     error         cabeq     *on           endvfychg

     *  Code cannot be blank.

     C                   if        $etcodeu
     C                   if        $etcode  = ' '
     C                   eval      error = *on
     C                   eval      $etcodee = '1'
     C                   eval      $preturn = 'BLANKCODE'
     C                   goto      endvfychg
     C                   endif
     C                   endif

     *  Get & lock record.

     C                   if        $psubcmd = '*CHANGE'
     C                   eval      lock1 = *on
     C                   else
     C                   eval      lock1 = *off
     C                   endif
     C                   exsr      recget1

     *  Error if record not found.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn = 'TRN1NOTFND'
     C                   eval      $pmessage = 'Transaction # not found '
     C                                       + '('
     C                                       + %trim(%editc($etwhse:'P'))
     C                                       + '/'
     C                                       + %trim(%editc($ettrn#:'P'))
     C                                       + ')'
     C                   goto      endvfychg
     C                   endif

     C     endvfychg     endsr

     *----------------------------------------------------------------
     *  verifychkin  Verify information  for check In
     *----------------------------------------------------------------

     C     verifychkin   begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfychkin

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfychkin

     C                   exsr      vfyemp#sent
     C     error         cabeq     *on           endvfychkin

     C     endvfychkin   endsr

     *----------------------------------------------------------------
     *  verifychkout  Verify information for check Out
     *----------------------------------------------------------------

     C     verifychkout  begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfychkout

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfychkout

     C                   exsr      vfyemp#sent
     C     error         cabeq     *on           endvfychkout

     C     endvfychkout  endsr

     *----------------------------------------------------------------
     *  verifydel   Delete verification.
     *----------------------------------------------------------------

     C     verifydel     begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfydel

     C                   exsr      vfytrn#sent
     C     error         cabeq     *on           endvfydel

     *  Get & lock record.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock1 = *on
     C                   else
     C                   eval      lock1 = *off
     C                   endif
     C                   exsr      recget1
     C                   if        not found
     C                   eval      error = *on
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn = 'TRN1NOTFND'
     C                   eval      $pmessage = 'Transaction # not found '
     C                                       + '('
     C                                       + %trim(%editc($etwhse:'P'))
     C                                       + '/'
     C                                       + %trim(%editc($ettrn#:'P'))
     C                                       + ')'
     C                   goto      endvfydel
     C                   endif

     C     endvfydel     endsr

     *----------------------------------------------------------------
     *  vfycodesent  Verify that code was sent
     *----------------------------------------------------------------

     C     vfycodesent   begsr

     C                   if        not $etcodeu
     C                   eval      error = *on
     C                   eval      $etcodee = $drierror
     C                   eval      $preturn  = 'CODENOTSNT'
     C                   eval      $pmessage = 'Equipment code must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfyemp#sent  Verify that employee number was sent
     *----------------------------------------------------------------

     C     vfyemp#sent   begsr

     C                   if        not $etemp#u
     C                   eval      error = *on
     C                   eval      $etemp#e = $drierror
     C                   eval      $preturn  = 'EMP#NOTSNT'
     C                   eval      $pmessage = 'Employee # must be sent'
     C                   endif

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  vfygetchkout  Verify information for *GETCHKOUT
500 A*----------------------------------------------------------------
500 A
500 AC     vfygetchkout  begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfywhsesent
     C     error         cabeq     *on           endvfygetout

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfygetout

     C                   exsr      vfyemp#sent
     C     error         cabeq     *on           endvfygetout

     C     endvfygetout  endsr

     *----------------------------------------------------------------
     *  vfytrn#sent  Verify that transaction was sent
     *----------------------------------------------------------------

     C     vfytrn#sent   begsr

     C                   if        not $ettrn#u
     C                   eval      error = *on
     C                   eval      $ettrn#e = $drierror
     C                   eval      $preturn  = 'TRN#NOTSNT'
     C                   eval      $pmessage = 'Tran# must be sent'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  vfywhsesent  Verify that warehouse was sent
     *----------------------------------------------------------------

     C     vfywhsesent   begsr

     C                   if        not $etwhseu
     C                   eval      error = *on
     C                   eval      $etwhsee = $drierror
     C                   eval      $preturn  = 'WHSENOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'
     C                   endif

     C                   endsr
