      /copy qcopysrc,hspecs
640c H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W Roosevelt Rd. #8-51
     *   West Chicago, IL 60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DRILICINFO  Dakota realtime interface - License info
     *  04 May 2004
     *  Dave Sommerville
     *
416  *    05/04/03  DAS  4.17
     *      - Created
     *
500 A*    01/29/05  DAS  5.00
     *      - Added routine GETVALUES.
     *      - Revised *GET to call new GETVALUES routine.
     *
600aA*    05/18/08  DAS  6.00a
     *      - Revised GETVALUES to not abort if code not found for
     *        license. Instead, set on code error flag.
     *        Re: Not all licenses will have a *LOT code.
     *
600bA*    01/06/09  DAS  6.00b
     *      - Revised RECCHANGE to update 'changed' info.
     *
600cA*    03/06/09  DAS  6.00c
     *      - Added *RCVTS. This is not a code in the file. Instead,
     *        it returns the LNADDTS timestamp of code *PO.
     *
600dA*    06/10/09  DAS  6.00d
     *      - Revised *RCVTS to use *RCVTRN# instead of *PO because
     *        Returns were not getting a *PO record created.
640aA*    12/16/11  RH   6.40a
     *      - Renamed CVTNUM to CVTNUMB
     *
640bA*    08/10/12  JCJ  6.40b
     *      - Work in progress.  Reserving this mod mark.
640cA*    09/10/12  RH   6.40c
     *      - Fix: Add DFTACTGRP line, LICINFO and LICINFOCD files
     *        were being left open and causing data issues.
640dA*    09/10/12  DAS  6.40d
     *      - Revised to work with new single record LICINFO file.
     *
640eA*    09/13/12  LMC  6.40e
     *      - Revised field name lnusebydte to lnmfgexp.
640fA*    09/17/12  LMC  6.40f
     *      - Fix - wrong field name for ITEM in GETALL
     *      - Enh - added field LNSEQQTY
     *      - Fix - Load Lnseq for legacy code
640hA*    09/26/12  LMC  6.40h
     *      - Enh - new *REPLACE command used to replace GS1/UCI tempo
     *      temporary license created for X-dock item with the actual
     *      X-dock license created in PO236.
640iA*    10/15/12  RBD  6.40i
     *      - Added revs to rev 6.40d for codes *DTESET1 and *DTESET2.
650aA*    01/04/13  LMC  6.50a
     *      - Added commands *FIND4UCI                                o
650bA*    11/30/12  LMC  6.50b
     *      - Changed the LNRCVTYP field logic for the original licinfo
     *      to default this field to 1 = Manual quantity (original method)
     *
730aA*    12/13/19  LMC  7.30a
     *      - Added call to PO728S for real time license interface.   o
     *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *      CRTBNDRPG PGM(*) SRCFILE(*) DFTACTGRP(*NO) ACTGRP(*CALLER)
     *                TGTRLS(V5R1M0)
     *
     *         (Can use PDM option CB with prompting)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *   This data structure allows for up to 9 codes and corresponding
     *   values to be sent at once. This will help to reduce the number
     *   of times the interface must be called.
     *
     *   Also, one data value field is shared for both the character
     *   values and numeric values. This is done using the Overlay keyword.
     *   A one character field identifies the value type (A/N).
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * More Notes
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
      *      *ADD              Add license info record (legacy)
      *
640aA *      *ADDS             Add record to new LICINFO format
      *
      *      *CHANGE           Change license info record (legacy)
      *
640aA *      *CHANGES          Change record in new LICINFO format
      *
      *      *DELETE           Delete license info record (legacy)
      *
      *      *DELETEALL        Delete all records for license.
      *
650aA *      *FIND4UCI         Find LICINFO for UCI addition at selection
      *
      *      *GET              Get license info record.
      *
640hA *      *REPLACE          Replaces GS1 XDK temp license with permanent
      *
      *      *VERIFYADD        Do "*ADD" verification without update.
      *      *VERIFYADS        Do "*ADDS" verification without update.
      *      *VERIFYCHG        Do "*CHANGE" verification without update.
      *      *VERIFYCHS        Do "*CHANGES" verification without update.
      *      *VERIFYDEL        Do "*DELETE" verification without update.
      *      *VFYDELALL        Do "*DELETEALL' verify without update.
      *
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Flicinfo   uf a e           k disk    usropn
     F                                     infds(file1ds)
650aAFlicinfo4  If   e           k disk    usropn  rename(lnrec:ln4)
650aAFlicinfo5  If   e           k disk    usropn  rename(lnrec:ln5)
650aAFlicactive If   e           k disk    usropn
640aDF*icinfocd if   e           k disk    usropn
640aAFpirtran   if   e           k disk

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICINFO
     D saveVer#        s                   like($lnver#)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

100bA /copy qcopysrc,p.bfcdteti

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

     D $vwhse          s                   like(lnwhse)

     *----------------------------------------------------------------
     *  Called program flags
     *----------------------------------------------------------------

     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D DakotaCall      s               n
640iAD holdDays        s              3
     D HostCall        s               n
640aAD recFound        s               n
650aAD ucilicensecnt   s              5  0
730aAD lCommand        s             10

640aDD**ycode          s                   like(lncode)
640aDD**ycseq          s                   like(lncseq)
640aDD**ylcns          s                   like(lnlcns)
640aDD**ylnccode       s                   like(lnccode)
640aDD**ywhse          s                   like(lnwhse)

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

100bMD CurrStamploc    s               z
100bAD CurrStampsys    s               z
100bAD CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
100bAD ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

100bAD bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

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
640aAC                   parm                    $pdata2

     C                   eval      $licinfo = $pdata
640aAC                   if        %parms >= 6
640aAC                   eval      $licinfo2 = $pdata2
640aAC                   endif
640aAC                   if        %parms < 6 or $lnseq = 0
640aAC                   eval      $lnseq = 1
640aAC                   endif
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
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      vfyadd
     C                   if        not error
     C                   exsr      recadd
     C                   endif
     C                   endif
     C                   endif

640aAC                   when      $psubcmd = '*ADDS'
640aAC                   if        DakotaCall
640aAC                   exsr      aaacallhost
640aAC                   if        not error
640aAC                   exsr      vfyadds
640aAC                   if        not error
640aAC                   exsr      recadds
730aAc                   exsr      exportlcns
640aAC                   endif
640aAC                   endif
640aAC                   endif

     C                   when      $psubcmd = '*CHANGE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      vfychg
     C                   if        not error
     C                   exsr      recchange
     C                   endif
     C                   endif
     C                   endif

640aAC                   when      $psubcmd = '*CHANGES'
640aAC                   if        DakotaCall
640aAC                   exsr      aaacallhost
640aAC                   if        not error
640aAC                   exsr      vfychgs
640aAC                   if        not error
640aAC                   exsr      recchanges
730aAc                   exsr      exportlcns
640aAC                   endif
640aAC                   endif
640aAC                   endif

     C                   when      $psubcmd = '*DELETE'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      vfydel
     C                   if        not error
     C                   exsr      recdelete
     C                   endif
     C                   endif
     C                   endif

     C                   when      $psubcmd = '*DELETEALL'
     C                   if        DakotaCall
     C                   exsr      aaacallhost
     C                   if        not error
     C                   exsr      vfydelall
     C                   if        not error
     C                   exsr      recdelall
     C                   endif
     C                   endif
     C                   endif

650aAC                   when      $psubcmd = '*FIND4UCI'
650aAC                   eval      lock = *off
650aAC                   exsr      find4UCI

     C                   when      $psubcmd = '*GET'
     C                   eval      lock = *off
500 DC**                 exsr      getlicinfo
500 AC                   exsr      getvalues
500 DC**                 if        not error
500 DC**                 exsr      file2ds
500 DC**                 endif

     C                   when      $psubcmd = '*VERIFYADD'
     C                   exsr      vfyadd
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

640aAC                   when      $psubcmd = '*VERIFYADS'
640aAC                   exsr      vfyadds
640aAC                   if        DakotaCall and not error
640aAC                   exsr      aaacallhost
640aAC                   endif

     C                   when      $psubcmd = '*VERIFYCHG'
     C                   exsr      vfychg
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

640aAC                   when      $psubcmd = '*VERIFYCHS'
640aAC                   exsr      vfychgs
640aAC                   if        DakotaCall and not error
640aAC                   exsr      aaacallhost
640aAC                   endif

     C                   when      $psubcmd = '*VERIFYDEL'
     C                   exsr      vfydel
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

     C                   when      $psubcmd = '*VFYDELALL'
     C                   exsr      vfydelall
     C                   if        DakotaCall and not error
     C                   exsr      aaacallhost
     C                   endif

640hAC                   when      $psubcmd = '*REPLACE'
640hAC                   if        DakotaCall
640hAC                   exsr      aaacallhost
640hAC                   if        not error
640hAC                   exsr      vfyreplace
640hAC                   if        not error
640hAC                   exsr      recreplace
640hAC                   endif
640hAC                   endif
640hAC                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#pgm)

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $licinfo
640aAC                   if        %parms >= 6
640aAC                   eval      $pdata2 = $licinfo2
640aAC                   endif
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Key definitions

     *  Define key for LICINFO file.

     C     keyln         klist
     C                   kfld                    $lnwhse
640aDC**                 kfld                    $lntype
     C                   kfld                    $lnlcns
640aDC**                 kfld                    kycode
640aDC**                 kfld                    kycseq
640aMC                   kfld                    $lnseq

     *  Define partial key for LICINFO file.

     C     keylnp        klist
     C                   kfld                    $lnwhse
640aDC**                 kfld                    $lntype
     C                   kfld                    $lnlcns

640aD ** Define key for LICINFOCD file.
640aD **
640aDC**   keylnc        klist
640aDC**                 kfld                    kylnccode

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
     C                   parm      $licinfo      $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = '*CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIMAIN2'
     C                                       + '/' + %trim($dricommand)
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm

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

     C                   exsr      fileclose

     C                   endsr

     *----------------------------------------------------------------
     *  callcvtnum   Call CVTNUM program
     *----------------------------------------------------------------

     C     callcvtnum    begsr

640aDC*                  call      'CVTNUM'
640aMC                   call      'CVTNUMB'
     C                   parm                    $cvcmd            8
     C                   parm                    $cvstr           30
     C                   parm                    $cvnum           15 5
     C                   parm                    $cvdec            1 0
     C                   parm                    $cvrtn            8

     C                   endsr
416bA
730aA*----------------------------------------------------------------
730aA*  exportlcns   Real time license export
730aA*----------------------------------------------------------------

730aAC     exportlcns    begsr

730aAc                   if        $LNRCVQTY <> 0
730aAc                   eval      lCommand = 'Add'
730aAC                   call      'PO728SCL'
730aAC                   parm                    $lnwhse
730aAC                   parm                    $lnlcns
730aAC                   parm                    lCommand
730aAc                   endif

730aAC                   endsr
416bA
416bA*----------------------------------------------------------------
416bA*  fileclose  Close files
416bA*----------------------------------------------------------------
416bA
416bAC     fileclose     begsr

     C                   if        %open(licinfo)
     C                   close(e)  licinfo
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRCLSLN'
     C                   eval      $pmessage = 'Error closing LICINFO file'
     C                   endif
     C                   endif

650aAC                   if        %open(licinfo4)
650aAC                   close(e)  licinfo4
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRCLSLN'
650aAC                   eval      $pmessage = 'Error closing LICINFO4 file'
650aAC                   endif
650aAC                   endif

650aAC                   if        %open(licinfo5)
650aAC                   close(e)  licinfo5
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRCLSLN'
650aAC                   eval      $pmessage = 'Error closing LICINFO5 file'
650aAc                   endif
650aAC                   endif

650aAC                   if        %open(licactive)
650aAC                   close(e)  licactive
650aAC                   if        %error
650aAC                   eval      error = *on
650aAC                   eval      $preturn = 'ERRCLSLN'
650aAC                   eval      $pmessage = 'Error closing LICACTIVE file'
650aAC                   endif
650aAC                   endif

640aDC**                 if        %open(licinfocd)
640aDC**                 close(e)  licinfocd
640aDC**                 if        %error
640aDC**                 eval      error = *on
640aDC**                 eval      $preturn = 'ERRCLSLNC'
640aDC**                 eval      $pmessage = 'Error closing LICINFOCD '
640aDC**                                     + 'file'
640aDC**                 endif
640aDC**                 endif

     C                   endsr

650aA*----------------------------------------------------------------
650aA*  fileopenla1 Open file licactive
650aA*----------------------------------------------------------------
650aA
650aAC     fileopenla1   begsr

     C                   if        not %open(licactive)
     C                   open(e)   licactive
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLN'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICACTIVE in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

650aAC                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenln  Open file licinfo
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenln    begsr

     C                   if        not %open(licinfo)
     C                   open(e)   licinfo
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLN'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICINFO in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

     C                   endsr

650aA*----------------------------------------------------------------
650aA*  fileopenln4 Open file licinfo4
650aA*----------------------------------------------------------------
650aA
650aAC     fileopenln4   begsr

     C                   if        not %open(licinfo4)
     C                   open(e)   licinfo4
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLN'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICINFO4 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

650aAC                   endsr

650aA*----------------------------------------------------------------
650aA*  fileopenln5 Open file licinfo5
650aA*----------------------------------------------------------------
650aA
650aAC     fileopenln5   begsr

     C                   if        not %open(licinfo5)
     C                   open(e)   licinfo5
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'OPNERRLN'
     C                   eval      $pmessage = 'Error occured trying to '
     C                                      + 'open file LICINFO5 in pgm '
     C                                      + #pgm
     C                   endif
     C                   endif

650aAC                   endsr

416bA*----------------------------------------------------------------
416bA*  fileopenlnc  Open file licinfocd
416bA*----------------------------------------------------------------
416bA
416bAC     fileopenlnc   begsr

640aDC**                 if        not %open(licinfocd)
640aDC**                 open(e)   licinfocd
640aDC**                 if        %error
640aDC**                 eval      error = *on
640aDC**                 eval      $preturn  = 'OPNERRLNC'
640aDC**                 eval      $pmessage = 'Error occured trying to '
640aDC**                                    + 'open file LICINFOCD in pgm '
640aDC**                                    + #pgm
640aDC**                 endif
640aDC**                 endif

     C                   endsr

     *----------------------------------------------------------------
     *  file2ds  Move file fields to data structure fields
     *----------------------------------------------------------------

     C     file2ds       begsr

     * Initialize data structure.

     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     * Move information to data structure.

     C                   eval      $lnwhsee = $driok
416aAC                   eval      $lnwhse = lnwhse

     C                   eval      $lntypee = $driok
640aDC**                 eval      $lntype = lntype

     C                   eval      $lnlcnse = $driok
416aAC                   eval      $lnlcns = lnlcns

     C                   eval      $lncodee = $driok
640aDC**                 eval      $lncode = lncode

640aDC**                 eval      $lncseq = lncseq

416aAC**********         eval      $lnvalue = lnvalue

     C                   endsr

650aA*----------------------------------------------------------------
650aA*  find4UCI      - find licinfo for uci
650aA*----------------------------------------------------------------
650aA
650aAC     find4UCI      begsr

      /free
        exsr inzchkflds;
        // determine which file to open
        select;
          when $lnmfgdate > 0;
            exsr fileopenln4;
            if error;
              leavesr;
            endif;
            exsr fileopenla1;
            if error;
              leavesr;
            endif;

            // see if record exists, or multiple records exist
            ucilicensecnt = 0;
            setll ($lnwhse: $lnitem: $lnmfgdate: $lnlot) licinfo4;
            dow forever = forever;
              reade ($lnwhse: $lnitem: $lnmfgdate: $lnlot) licinfo4;
                if %eof(licinfo4);
                  leave;
                endif;
              ucilicensecnt = ucilicensecnt + 1;
              // do I have a licactive record for this license
              chain (lnwhse: lnlcns) licactive;
              if %found(licactive);
                leave;
              endif;
            enddo;

            // found only one licinfo use it
            if ucilicensecnt > 0;
              $lnlcns = lnlcns;
              lock = *off;
              exsr getlicinfo;
              if error;
                leavesr;
              endif;
              // Get Individual fields
              exsr GetAll;
            endif;

            // Did not find licinfo will need to create
            if ucilicensecnt = 0;
            endif;


          when $lnmfgexp > 0;
            exsr fileopenln5;
            if error;
              leavesr;
            endif;
            exsr fileopenla1;
            if error;
              leavesr;
            endif;
          other;
        endsl;

      /end-free

650aAC                   endsr

100bA*----------------------------------------------------------------
100bA*  getcurrstamp  Get current timestamps
100bA*----------------------------------------------------------------
100bA
100bAC     getcurrstamp  begsr

100bMC                   callp     getmicrotime(currstampuc:currstampsys)
100bAC     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr

     *----------------------------------------------------------------
     *  getlicinfo   Get license info record.
     *----------------------------------------------------------------

     C     getlicinfo    begsr

     C* Open licinfo file.

     C                   if        not %open(licinfo)
     C                   exsr      fileopenln
     C                   if        error
     C                   goto      endgetlicinfo
     C                   endif
     C                   endif

     C* Get licinfo record

     C                   if        lock
     C     keyln         chain     licinfo
     C                   else
     C     keyln         chain(n)  licinfo
     C                   endif

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDLICIN'
     C                   eval      $pmessage = 'Invalid lic info'
     C                                       + '('
     C                                       + %trim(%editc($lnwhse:'Z'))
640aDC**                                     + '/'
640aDC**                                     + %trim($lntype)
     C                                       + '/'
     C                                       + %trim($lnlcns)
     C                                       + '/'
640aDC**                                     + %trim(kycode)
640aDC**                                     + '/'
640aDC**                                     + %trim(%editc(kycseq:'P'))
640aMC                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                   goto      endgetlicinfo
     C                   endif

     C     endgetlicinfo endsr

640aD **---------------------------------------------------------------
640aD ** getlicinfocd  Get license info code record.
640aD **---------------------------------------------------------------
640aD **
640aDC**   getlicinfocd  begsr
640aD **
640aDC**Open licinfocd file.
640aD **
640aDC**                 if        not %open(licinfocd)
640aDC**                 exsr      fileopenlnc
640aDC**                 if        error
640aDC**                 goto      endgetlnc
640aDC**                 endif
640aDC**                 endif
640aD **
640aDC**Get licinfocd record
640aD **
640aDC**   keylnc        chain     licinfocd
640aD **
640aDC**                 if        not %found
640aDC**                 eval      error = *on
640aDC**                 eval      $preturn = 'INVLDLCN'
640aDC**                 eval      $pmessage = 'Invalid lic info code '
640aDC**                                     + '('
640aDC**                                     + %trim(kylnccode)
640aDC**                                     + ')'
640aDC**                 goto      endgetlnc
640aDC**                 endif
640aD **
640aDC**   endgetlnc     endsr

640aA*----------------------------------------------------------------
640aA*  GetAll      Get all fields
640aA*----------------------------------------------------------------
640aA
640aAC     GetAll        begsr

     c                   eval      $lnseq      = lnseq
640fAc                   eval      $lnseqqty   = lnseqqty
640fDc*                  eval      $lnitem     = $lnitem
640fMc                   eval      $lnitem     = lnitem
     c                   eval      $lnpo       = lnpo
     c                   eval      $lnposeq    = lnposeq
     c                   eval      $lnrcvtyp   = lnrcvtyp
     c                   eval      $lnrcvtrn#  = lnrcvtrn#
     c                   eval      $lnrcvlbl#  = lnrcvlbl#
     c                   eval      $lnrcvqty   = lnrcvqty
     c                   eval      $lnentdate  = lnentdate
     c                   eval      $lnenttype  = lnenttype
     c                   eval      $lnmfgdate  = lnmfgdate
640eDc*                  eval      $lnusebydte = lnusebydte
640eMc                   eval      $lnmfgexp   = lnmfgexp
     c                   eval      $lnfifodate = lnfifodate
     c                   eval      $lnexpdate  = lnexpdate
     c                   eval      $lndateflag = lndateflag
     c                   eval      $lnmfgflag  = lnmfgflag
     c                   eval      $lnmfgdays  = lnmfgdays
     c                   eval      $lnusrdays  = lnusrdays
     c                   eval      $lndstdays  = lndstdays
     c                   eval      $lnmfgcode  = lnmfgcode
     c                   eval      $lnttllbs   = lnttllbs
     c                   eval      $lnavglbs   = lnavglbs
     c                   eval      $lnlot      = lnlot
     c                   eval      $lnlotpti2  = lnlotpti2
     c                   eval      $lnlotpti4  = lnlotpti4
     c                   eval      $lnhrvcert  = lnhrvcert
     c                   eval      $lnhrvdate  = lnhrvdate
     c                   eval      $lnhrvloc   = lnhrvloc
     c                   eval      $lnbrand    = lnbrand
     c                   eval      $lnaddts    = lnaddts

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  GetOne          Get one field value
640aA*----------------------------------------------------------------
640aA
640aAC     GetOne        begsr

      /free

        $lnvalnum(i) = 0;
        $lnvalchr(i) = ' ';

        select;

          when $lncode(i) = '*AVGWGT';
            $lnvalnum(i) = lnavglbs;

          when $lncode(i) = '*DATEIN';
            $lnvalnum(i) = lnentdate;

          when $lncode(i) = '*DATETYP';
            $lnvalchr(i) = lnenttype;

          when $lncode(i) = '*DTESET1';
640iA       %subst($lnvalchr(i): 7: 1) = lndateflag;
640iA       %subst($lnvalchr(i): 15: 1) = lnmfgflag;

          when $lncode(i) = '*DTESET2';
640iA       %subst($lnvalchr(i): 7: 3) = %char(lnmfgdays);
640iA       %subst($lnvalchr(i): 17: 3) = %char(lnusrdays);
640iA       %subst($lnvalchr(i): 27: 3) = %char(lndstdays);

          when $lncode(i) = '*EXPDTE';
            $lnvalnum(i) = lnexpdate;

          when $lncode(i) = '*FIFODTE';
            $lnvalnum(i) = lnfifodate;

          when $lncode(i) = '*HRVCERT';
            $lnvalchr(i) = lnhrvcert;

          when $lncode(i) = '*HRVDATE';
            $lnvalnum(i) = lnhrvdate;

          when $lncode(i) = '*HRVLOC';
            $lnvalchr(i) = lnhrvloc;

          when $lncode(i) = '*ITEM';
            $lnvalchr(i) = lnitem;

          when $lncode(i) = '*LOT';
            $lnvalchr(i) = lnlot;

          when $lncode(i) = '*MFGDTE';
            $lnvalnum(i) = lnmfgdate;

          when $lncode(i) = '*PO';
            $lnvalchr(i) = lnpo;

          when $lncode(i) = '*POSEQ';
            $lnvalnum(i) = lnposeq;

          when $lncode(i) = '*RCVJOB';
            // not used

          when $lncode(i) = '*RCVLBL#';
            $lnvalnum(i) = lnrcvlbl#;

          when $lncode(i) = '*RCVLQTY';
            $lnvalnum(i) = lnrcvqty;

          when $lncode(i) = '*RCVTRN#';
            $lnvalnum(i) = lnrcvtrn#;

          when $lncode(i) = '*RCVTS';
            $lnvalchr(i) = %char(lnaddts);

          when $lncode(i) = '*TTLWGT';
            $lnvalnum(i) = lnttllbs;

        endsl;

      /end-free

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  getvalues    Get values for *GET codes sent in.
500 A*----------------------------------------------------------------
500 A
500 AC     getvalues     begsr

600aAC                   exsr      inzchkflds

640aA*  Make sure file is open.
640aA
640aAC                   exsr      fileopenln
640aAC                   if        error
640aAC                   leavesr
640aAC                   endif
640aA
640aA*  See if record exists.
640aA
640aAC                   eval      lock = *off
640aAC                   exsr      getlicinfo
640aA
640aA*  Error if record does not exist
640aA
640aAC                   if        error
640aAC                   leavesr
640aAC                   endif
640aA
640aA*  Get individual fields
640aA
640aAC                   exsr      GetAll
640aA
640aA*  Get any legacy codes that the program is looking for.

     C* Loop through parameter array.

     C                   eval      loopmax = %elem($lncode)
     C     1             do        loopmax       i

     C                   if        not $lncodeu(i)
     C                   iter
     C                   endif
640aA
640aAC                   exsr      GetOne
640aA
640aAC                   enddo

640aD **  Get license info code.
640aD **
640aDC**                 if        $lncode(i) <> '*RCVTS'
640aDC**                 eval      kylnccode = $lncode(i)
640aDC**                 exsr      getlicinfocd
640aDC**                 if        error
600aDC**                 leave
640aDC**                 eval      error = *off
640aDC**                 eval      $preturn  = '*OK'
640aDC**                 eval      $pmessage = ' '
640aDC**                 eval      $lncodee(i) = $drierror
640aDC**                 iter
640aDC**                 endif
640aDC**                 endif
640aD **
640aDC**  Get licinfo record
640aD **
640aDC**                 if        $lncode(i) = '*RCVTS'
600dDC**                 eval      kycode = '*PO'
640aDC**                 eval      kycode = '*RCVTRN#'
640aDC**                 else
640aDC**                 eval      kycode = $lncode(i)
640aDC**                 endif
640aDC**                 eval      kycseq = $lncseq(i)
640aDC**                 eval      lock = *off
640aDC**                 exsr      getlicinfo
640aDC**                 if        error
600aDC**                 leave
640aDC**                 eval      error = *off
640aDC**                 eval      $preturn  = '*OK'
640aDC**                 eval      $pmessage = ' '
640aDC**                 eval      $lncodee(i) = $drierror
640aDC**                 iter
640aDC**                 endif
640aD **
640aDC**                 eval      $lnvaltyp(i) = lnctype
640aD **
640aDC**                 select
640aD **
640aDC**                 when      $lncode(i) = '*RCVTS'
640aDC**                 eval      $lnvalchr(i) = %char(lnaddts)
640aDC**                 eval      $lnvalnum(i) = 0
640aD **
640aDC**                 when      lnctype = 'N'
640aDC**                 eval      $cvcmd = '*STR2NUM'
640aDC**                 eval      $cvstr = lnvalue
640aDC**                 eval      $cvdec = lncdec
640aDC**                 eval      $cvnum = 0
640aDC**                 exsr      callcvtnum
640aDC**                 eval      $lnvalnum(i) = $cvnum
640aDC**                 eval      $lnvalchr(i) = ' '
640aD **
640aDC**                 other
640aDC**                 eval      $lnvalchr(i) = lnvalue
640aDC**                 eval      $lnvalnum(i) = 0
640aD **
640aDC**                 endsl
640aD **
640aDC**                 enddo

     C     endgetvalues  endsr

     *----------------------------------------------------------------
     *  inzchkflds  Initialize check fields.
     *----------------------------------------------------------------

     C     inzchkflds    begsr

     C                   eval      $lnwhsee = $driok
     C                   eval      $lntypee = $driok
     C                   eval      $lnlcnse = $driok
     C                   eval      $lncodee = $driok

     C                   endsr

     *----------------------------------------------------------------
     *  recadd   Add record.
640aA*           Retrofitted legacy version
     *----------------------------------------------------------------

     C     recadd        begsr
     C                   eval      error = *off
100bMC                   exsr      getcurrstamp

640aA*    If only verifying, nothing to do, so get out.
640aA
640aAC                   if        $psubcmd = '*VERIFYADD'
640aAC                   leavesr
640aAC                   endif

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   goto      endadd
     C                   endif

640aA*  See if record exists.
640aA*    To stay compatible with legacy coding, the record may already
640aA*    exist, in which case we will be updating it.

640aAC                   eval      lock = *on
     C                   exsr      getlicinfo

     *  Clear record.
640aA*    - Only if record doesn't exist

640aAC                   if        not error
640aA
640aAC                   eval      recFound = *on
640aA
640aAC                   else
640aA
640aAC                   eval      recFound = *off
640aAC                   eval      error = *off
640aAC                   eval      $preturn = '*OK'
640aAC                   eval      $pmessage = ' '
     C                   clear                   lnrec

     *     Move main information into fields.

     C                   eval      lnwhse = $lnwhse
640aDC**                 eval      lntype = $lntype
     C                   eval      lnlcns = $lnlcns
640fAC                   eval      lnseq  = $lnseq

100bMC                   eval      lnaddts  = currstampsys
100bAC                   eval      lnadduc  = currstampuc
     C                   eval      lnaddpgm = $lnpgm
     C                   eval      lnaddemp = $lnemp#
     C                   eval      lnaddusr = $lnuser
     C                   eval      lnaddjob = $lnjob
     C                   eval      lnaddnbr = $lnjobnbr

640aAC                   eval      lnchgts  = lnaddts
640aAC                   eval      lnchguc  = lnadduc
640aAC                   eval      lnchgpgm = lnaddpgm
640aAC                   eval      lnchgemp = lnaddemp
640aAC                   eval      lnchgusr = lnaddusr
640aAC                   eval      lnchgjob = lnaddjob
640aAC                   eval      lnchgnbr = lnaddnbr
640aA
640aAC                   endif

     *  Loop through codes that were sent.

416aAC                   eval      loopmax = %elem($lncode)
416aAC     1             do        loopmax       i

416aAC                   if        not $lncodeu(i)
416aAC                   iter
416aAC                   endif

640aA*    Move value into appropriate field.
640aA
640aAC                   exsr      RecFillValue
640aA
640aAC                   enddo

640aD **   Get license info code.
640aD **
640aDC**                 eval      kylnccode = $lncode(i)
640aDC**                 exsr      getlicinfocd
640aDC**                 if        error
640aDC**                 leave
640aDC**                 endif
640aD **
640aD **   If only verifying, then move on to next code.
640aD **
640aDC**                 if        $psubcmd = '*VERIFYADD'
640aDC**                 iter
640aDC**                 endif
640aD **
640aD **   Otherwise, add record.
640aD **
640aDC**                 eval      lncode = $lncode(i)
640aDC**                 eval      lncseq = $lncseq(i)
640aDC**                 select
640aDC**                 when      $lnvaltyp(i)='N'
640aDC**                 eval      $cvcmd = '*NUM2STR'
640aDC**                 eval      $cvnum = $lnvalnum(i)
640aDC**                 eval      $cvdec = lncdec
640aDC**                 eval      $cvstr = ' '
640aDC**                 exsr      callcvtnum
640aDC**                 eval      lnvalue = $cvstr
640aDC**                 other
640aDC**                 eval      lnvalue = $lnvalchr(i)
640aDC**                 endsl

640aA*  Add/Update record

640aAC                   select
640aAC                   when      not recFound
640aA
     C                   write(e)  lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC'
640aMC                   eval      $pmessage = 'Error on Add '
640aDC**                                     + %trim(%editc(i:'Z'))
640aDC**                                     + ' Lic Info" command '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
640aDC**                                     + %trim($lncode(i))
640aDC**                                     + '/'
640aDC**                                     + %trim(%editc($lncseq(i):'P'))
640aMC                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
640aDC**                 eval      $lntypee = '1'
     C                   eval      $lnlcnse = '1'
640aDC**                 eval      $lncodee(i) = '1'
640aDC**                 leave
     C                   endif
640aA
640aAC                   other
640aA
640aAC                   update(e) lnrec
640aAC                   if        %error
640aAC                   eval      error = *on
640aAC                   eval      $preturn = 'ERRADDREC2'
640aAC                   eval      $pmessage = 'Error on Add2 '
640aAC                                       + '('
640aAC                                       + %trim(%editc(lnwhse:'Z'))
640aAC                                       + '/'
640aAC                                       + %trim(lnlcns)
640aAC                                       + '/'
640aAC                                       + %trim(%editc($lnseq:'P'))
640aAC                                       + ')'
640aAC                                       + '-' + f1messageid
640aAC                   eval      $lnwhsee = '1'
640aAC                   eval      $lnlcnse = '1'
640aAC                   endif

640aAC                   endsl

640aDC**                 enddo

     C     endadd        endsr

640aA*----------------------------------------------------------------
640aA*  recadds  Add record - New single record version
640aA*----------------------------------------------------------------
640aA
640aAC     recadds       begsr
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   leavesr
     C                   endif

     *  See if record exists.

     C                   eval      lock = *off
     C                   exsr      getlicinfo

     *  Error if record already exists

     C                   if        not error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC3'
     C                   eval      $pmessage = 'Rec already exists '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   leavesr
     C                   endif

640aAC                   eval      error = *off
640aAC                   eval      $preturn = '*OK'
640aAC                   eval      $pmessage = ' '

     *    If only verifying, get out.

     C                   if        $psubcmd = '*VERIFYADS'
     C                   leavesr
     C                   endif

     *    Initialize fields

     C                   clear                   lnrec
     C                   exsr      RecFill

     C                   eval      lnaddts  = currstampsys
     C                   eval      lnadduc  = currstampuc
     C                   eval      lnaddpgm = $lnpgm
     C                   eval      lnaddemp = $lnemp#
     C                   eval      lnaddusr = $lnuser
     C                   eval      lnaddjob = $lnjob
     C                   eval      lnaddnbr = $lnjobnbr

     C                   eval      lnchgts  = lnaddts
     C                   eval      lnchguc  = lnadduc
     C                   eval      lnchgpgm = lnaddpgm
     C                   eval      lnchgemp = lnaddemp
     C                   eval      lnchgusr = lnaddusr
     C                   eval      lnchgjob = lnaddjob
     C                   eval      lnchgnbr = lnaddnbr

     *  Add record

     C                   write(e)  lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRADDREC4'
     C                   eval      $pmessage = 'Error Adding rec '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   endif

     C     endadds       endsr

     *----------------------------------------------------------------
     *  recchange   Change record.
640aA*           Retrofitted legacy version
     *----------------------------------------------------------------

     C     recchange     begsr
     C                   eval      error = *off
100bMC                   exsr      getcurrstamp

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   goto      endchange
     C                   endif

640aA*  See if record exists.
640aA
640aAC                   if        $psubcmd = '*VERIFYCHG'
640aAC                   eval      lock = *off
640aAC                   else
640aAC                   eval      lock = *on
640aAC                   endif
640aAC                   exsr      getlicinfo
640aA
640aA*  Error if record does not exist
640aA
640aAC                   if        error
640aAC                   eval      $preturn = 'ERRCHGREC2'
640aAC                   eval      $pmessage = 'Rec does not exist '
640aAC                                       + '('
640aAC                                       + %trim(%editc($lnwhse:'Z'))
640aAC                                       + '/'
640aAC                                       + %trim($lnlcns)
640aAC                                       + '/'
640aAC                                       + %trim(%editc($lnseq:'P'))
640aAC                                       + ')'
640aAC                                       + '-' + f1messageid
640aAC                   eval      $lnwhsee = '1'
640aAC                   eval      $lnlcnse = '1'
640aAC                   leavesr
640aAC                   endif
640aA
640aA*    If only verifying, get out.
640aA
640aAC                   if        $psubcmd = '*VERIFYCHG'
640aAC                   leavesr
640aAC                   endif

     *  Loop through codes that were sent.

416aAC                   eval      loopmax = %elem($lncode)
416aAC     1             do        loopmax       i

416aAC                   if        not $lncodeu(i)
416aAC                   iter
416aAC                   endif

640aA*    Move value into appropriate field.
640aA
640aAC                   exsr      RecFillValue
640aA
640aAC                   enddo

640aD **   Get license info code.
640aD **
640aDC**                 eval      kylnccode = $lncode(i)
640aDC**                 exsr      getlicinfocd
640aDC**                 if        error
640aDC**                 leave
640aDC**                 endif
640aD **
640aD **   Get license info record.
640aD **
640aDC**                 if        $psubcmd = '*CHANGE'
640aDC**                 eval      lock = *on
640aDC**                 else
640aDC**                 eval      lock = *off
640aDC**                 endif
640aDC**                 eval      kycode = $lncode(i)
640aDC**                 eval      kycseq = $lncseq(i)
640aDC**                 exsr      getlicinfo
640aDC**                 if        error
640aDC**                 leave
640aDC**                 endif
640aD **
640aD **   If only verifying, then move on to next code.
640aD **
640aDC**                 if        $psubcmd = '*VERIFYCHG'
640aDC**                 iter
640aDC**                 endif
640aD **
640aD **   Otherwise, update record.
640aD **
640aDC**                 eval      lncode = $lncode(i)
640aDC**                 eval      lncseq = $lncseq(i)
640aDC**                 select
640aDC**                 when      $lnvaltyp(i)='N'
640aDC**                 eval      $cvcmd = '*NUM2STR'
640aDC**                 eval      $cvnum = $lnvalnum(i)
640aDC**                 eval      $cvdec = lncdec
640aDC**                 eval      $cvstr = ' '
640aDC**                 exsr      callcvtnum
640aDC**                 eval      lnvalue = $cvstr
640aDC**                 other
640aDC**                 eval      lnvalue = $lnvalchr(i)
640aDC**                 endsl
640aA
640aA*  Update record
600bA
600bAC                   eval      lnchgts  = currstampsys
600bAC                   eval      lnchguc  = currstampuc
600bAC                   eval      lnchgpgm = $lnpgm
600bAC                   eval      lnchgemp = $lnemp#
600bAC                   eval      lnchgusr = $lnuser
600bAC                   eval      lnchgjob = $lnjob
600bAC                   eval      lnchgnbr = $lnjobnbr

     C                   update(e) lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC'
640aMC                   eval      $pmessage = 'Error on Upd '
640aDC**                                     + %trim(%editc(i:'Z'))
640aDC**                                     + ' Lic Info" command '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
640aDC**                                     + %trim($lncode(i))
640aDC**                                     + '/'
640aDC**                                     + %trim(%editc($lncseq(i):'P'))
640aMC                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
640aDC**                 eval      $lntypee = '1'
     C                   eval      $lnlcnse = '1'
640aDC**                 eval      $lncodee(i) = '1'
640aDC**                 leave
     C                   endif

640aDC**                 enddo

     C     endchange     endsr

640aA*----------------------------------------------------------------
640aA*  recchanges  Change record - New single record version
640aA*----------------------------------------------------------------
640aA
640aAC     recchanges    begsr
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   leavesr
     C                   endif

     *  See if record exists.

     C                   if        $psubcmd = '*VERIFYCHS'
     C                   eval      lock = *off
     C                   else
     C                   eval      lock = *on
     C                   endif
     C                   exsr      getlicinfo

     *  Error if record does not exist

     C                   if        error
     C                   eval      $preturn = 'ERRCHGREC3'
     C                   eval      $pmessage = 'Rec does not exist '
     C                                       + '('
     C                                       + %trim(%editc($lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   leavesr
     C                   endif

     *    If only verifying, get out.

     C                   if        $psubcmd = '*VERIFYCHS'
     C                   leavesr
     C                   endif

     *    Initialize fields

     C                   exsr      RecFill

     C                   eval      lnchgts  = lnaddts
     C                   eval      lnchguc  = lnadduc
     C                   eval      lnchgpgm = lnaddpgm
     C                   eval      lnchgemp = lnaddemp
     C                   eval      lnchgusr = lnaddusr
     C                   eval      lnchgjob = lnaddjob
     C                   eval      lnchgnbr = lnaddnbr

     *  Update record

     C                   eval      lnchgts  = currstampsys
     C                   eval      lnchguc  = currstampuc
     C                   eval      lnchgpgm = $lnpgm
     C                   eval      lnchgemp = $lnemp#
     C                   eval      lnchgusr = $lnuser
     C                   eval      lnchgjob = $lnjob
     C                   eval      lnchgnbr = $lnjobnbr

     C                   update(e) lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRUPDREC4'
     C                   eval      $pmessage = 'Error on Upd '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  recdelall   Delete all records for license
     *----------------------------------------------------------------

     C     recdelall     begsr
     C                   eval      error = *off

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   goto      enddelall
     C                   endif

     *  Skip actual delete for *VERIFY.

     C                   if        $psubcmd = '*VFYDELALL'
     C                   goto      enddelall
     C                   endif

     *  Delete all records for license.

     C     keylnp        setll     licinfo
 1B  C                   dow       forever = forever
     C     keylnp        reade     licinfo
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
     C                   delete(e) lnrec
     C                   if        %error
     C                   eval      $preturn = 'DELERROR'
640aDC**                 eval      $pmessage = 'Error on "Delete Lic '
640aMC                   eval      $pmessage = 'Error on "Delete All '
640aDC**                                     + 'Info All" command '
     C                                       + '('
     C                                       + %Trim(%editc(lnwhse:'Z'))
640aDC**                                     + '/'
640aDC**                                     + %trim(lntype)
     C                                       + '/'
     C                                       + %trim(lnlcns)
640aDC**                                     + '/'
640aDC**                                     + %trim(lncode)
     C                                       + '/'
640aDC**                                     + %Trim(%editc(lncseq:'P'))
640aMC                                       + %Trim(%editc(lnseq:'P'))
     C                                       + ')'
     C                   eval      $pmessage = %trim($pmessage)
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
640aDC**                 eval      $lntypee = '1'
     C                   eval      $lnlcnse = '1'
     C                   goto      enddelall
     C                   endif
 1E  C                   enddo

     C     enddelall     endsr

     *----------------------------------------------------------------
     *  recdelete   Delete license info record.
     *----------------------------------------------------------------

     C     recdelete     begsr
     C                   eval      error = *off

640aA*  Shouldn't be used with new record format, so get out.
640aA
640aAC                   leavesr

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   goto      enddelete
     C                   endif

     *  Loop through codes that were sent.

416aAC                   eval      loopmax = %elem($lncode)
416aAC     1             do        loopmax       i

416aAC                   if        not $lncodeu(i)
416aAC                   iter
416aAC                   endif

     *    Get license info record.

     C                   if        $psubcmd = '*DELETE'
     C                   eval      lock = *on
     C                   else
     C                   eval      lock = *off
     C                   endif
640aDC**                 eval      kycode = $lncode(i)
640aDC**                 eval      kycseq = $lncseq(i)
640aDC**                 exsr      getlicinfo
     C                   if        error
     C                   leave
     C                   endif

     *    If only verifying, then move on to next code.

     C                   if        $psubcmd = '*VERIFYDEL'
     C                   iter
     C                   endif

     *    Otherwise, delete record.

     C                   delete(e) lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRDELREC'
     C                   eval      $pmessage = 'Error on "Del '
     C                                       + %trim(%editc(i:'Z'))
     C                                       + ' Lic Info" command '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
640aDC**                                     + %trim(lncode)
     C                                       + '/'
640aDC**                                     + %trim(%editc(lncseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
640aDC**                 eval      $lntypee = '1'
     C                   eval      $lnlcnse = '1'
640aDC**                 eval      $lncodee(i) = '1'
     C                   leave
     C                   endif

     C                   enddo


     C     enddelete     endsr

640aA*----------------------------------------------------------------
640aA*  RecFill     Fill record fields
640aA*----------------------------------------------------------------
640aA
640aAC     RecFill       begsr

     C                   eval      lnwhse     = $lnwhse
     C                   eval      lnlcns     = $lnlcns
     c                   eval      lnseq      = $lnseq
640fAc                   eval      lnseqqty   = $lnseqqty
     c                   eval      lnitem     = $lnitem
     c                   eval      lnpo       = $lnpo
     c                   eval      lnposeq    = $lnposeq
     c                   eval      lnrcvtyp   = $lnrcvtyp
     c                   eval      lnrcvtrn#  = $lnrcvtrn#
     c                   eval      lnrcvlbl#  = $lnrcvlbl#
     c                   eval      lnrcvqty   = $lnrcvqty
     c                   eval      lnentdate  = $lnentdate
     c                   eval      lnenttype  = $lnenttype
     c                   eval      lnmfgdate  = $lnmfgdate
640eDc*                  eval      lnusebydte = $lnusebydte
640eMc                   eval      lnmfgexp   = $lnmfgexp
     c                   eval      lnfifodate = $lnfifodate
     c                   eval      lnexpdate  = $lnexpdate
     c                   eval      lndateflag = $lndateflag
     c                   eval      lnmfgflag  = $lnmfgflag
     c                   eval      lnmfgdays  = $lnmfgdays
     c                   eval      lnusrdays  = $lnusrdays
     c                   eval      lndstdays  = $lndstdays
     c                   eval      lnmfgcode  = $lnmfgcode
     c                   eval      lnttllbs   = $lnttllbs
     c                   eval      lnavglbs   = $lnavglbs
     c                   eval      lnlot      = $lnlot
     c                   eval      lnlotpti2  = $lnlotpti2
     c                   eval      lnlotpti4  = $lnlotpti4
     c                   eval      lnhrvcert  = $lnhrvcert
     c                   eval      lnhrvdate  = $lnhrvdate
     c                   eval      lnhrvloc   = $lnhrvloc
     c                   eval      lnbrand    = $lnbrand

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  RecFillValue    Fill record field with value
640aA*----------------------------------------------------------------
640aA
640aAC     RecFillValue  begsr

      /free

        select;

          when $lncode(i) = '*AVGWGT';
            lnavglbs = $lnvalnum(i);

          when $lncode(i) = '*DATEIN';
            lnentdate = $lnvalnum(i);

          when $lncode(i) = '*DATETYP';
            lnenttype = $lnvalchr(i);

          when $lncode(i) = '*DTESET1';
            lndateflag = %subst($lnvalchr(i): 7: 1);
            lnmfgflag  = %subst($lnvalchr(i): 15: 1);

          when $lncode(i) = '*DTESET2';
640iD    // lnmfgdays = $lnvalnum(i);
640iD    // lnusrdays = $lnvalnum(i);
640iD    // lndstdays = $lnvalnum(i);
640iA       holdDays  = %subst($lnvalchr(i): 7: 3);
640iA       lnmfgdays = %dec(holdDays:3:0);
640iA       holdDays  = %subst($lnvalchr(i): 17: 3);
640iA       lnusrdays = %dec(holdDays:3:0);
640iA       holdDays  = %subst($lnvalchr(i): 27: 3);
640iA       lndstdays = %dec(holdDays:3:0);

          when $lncode(i) = '*EXPDTE';
            lnexpdate = $lnvalnum(i);

          when $lncode(i) = '*FIFODTE';
            lnfifodate = $lnvalnum(i);

          when $lncode(i) = '*HRVCERT';
            lnhrvcert = $lnvalchr(i);

          when $lncode(i) = '*HRVDATE';
            lnhrvdate = $lnvalnum(i);

          when $lncode(i) = '*HRVLOC';
            lnhrvloc = $lnvalchr(i);

          when $lncode(i) = '*ITEM';
            lnitem = $lnvalchr(i);

          when $lncode(i) = '*LOT';
            lnlot = $lnvalchr(i);

          when $lncode(i) = '*MFGDTE';
            lnmfgdate = $lnvalnum(i);

          when $lncode(i) = '*PO';
            lnpo = $lnvalchr(i);

          when $lncode(i) = '*POSEQ';
            lnposeq = $lnvalnum(i);

          when $lncode(i) = '*RCVJOB';
            // not used

          when $lncode(i) = '*RCVLBL#';
            lnrcvlbl# = $lnvalnum(i);

          when $lncode(i) = '*RCVLQTY';
            lnrcvqty = $lnvalnum(i);

          when $lncode(i) = '*RCVTRN#';
            lnrcvtrn# = $lnvalnum(i);
            chain (lnrcvtrn#) pirtran;
650bD       //if %found and pttask = 'PUTRTN';
650bD         //lnrcvtyp = '2';
650bD       //else;
              lnrcvtyp = '1';
650bD       //endif;

          when $lncode(i) = '*RCVTS';
            // not used

          when $lncode(i) = '*TTLWGT';
            lnttllbs = $lnvalnum(i);

        endsl;

      /end-free

     C                   endsr

64haA*----------------------------------------------------------------
64haA*  recreplace  Replace record - GS1 with X-dock - temp to permanent
64haA*----------------------------------------------------------------
64haA
64haAC     recreplace    begsr
     C                   eval      error = *off
     C                   exsr      getcurrstamp

     *  Make sure file is open.

     C                   exsr      fileopenln
     C                   if        error
     C                   leavesr
     C                   endif

     *  See if record exists.

     C                   if        $psubcmd = '*VERIFYCHS'
     C                   eval      lock = *off
     C                   else
     C                   eval      lock = *on
     C                   endif
     C                   exsr      getlicinfo

     *  Error if record does not exist

     C                   if        not error
     C                   eval      $preturn = 'ERRREPREC3'
     C                   eval      $pmessage = 'Rec already exist '
     C                                       + '('
     C                                       + %trim(%editc($lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   leavesr
     C                   endif

     *    If only verifying, get out.

     C                   if        $psubcmd = '*VERIFYCHS'
     C                   leavesr
     C                   endif

     *    Initialize fields

     C                   exsr      RecFill

     C                   eval      lnchgts  = lnaddts
     C                   eval      lnchguc  = lnadduc
     C                   eval      lnchgpgm = lnaddpgm
     C                   eval      lnchgemp = lnaddemp
     C                   eval      lnchgusr = lnaddusr
     C                   eval      lnchgjob = lnaddjob
     C                   eval      lnchgnbr = lnaddnbr

     *  Update record

     C                   eval      lnchgts  = currstampsys
     C                   eval      lnchguc  = currstampuc
     C                   eval      lnchgpgm = $lnpgm
     C                   eval      lnchgemp = $lnemp#
     C                   eval      lnchgusr = $lnuser
     C                   eval      lnchgjob = $lnjob
     C                   eval      lnchgnbr = $lnjobnbr

     C                   write(e)  lnrec
     C                   if        %error
     C                   eval      error = *on
     C                   eval      $preturn = 'ERRREPREC4'
     C                   eval      $pmessage = 'Error on Replace '
     C                                       + '('
     C                                       + %trim(%editc(lnwhse:'Z'))
     C                                       + '/'
     C                                       + %trim(lnlcns)
     C                                       + '/'
     C                                       + %trim(%editc($lnseq:'P'))
     C                                       + ')'
     C                                       + '-' + f1messageid
     C                   eval      $lnwhsee = '1'
     C                   eval      $lnlcnse = '1'
     C                   endif

640hAC                   endsr

     *----------------------------------------------------------------
     *  vfyadd   Verify information for add
     *----------------------------------------------------------------

     C     vfyadd        begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfyadd

     *  Validate warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $lnwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $lnwhsee = $drierror
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #pgm
     C                   goto      endvfyadd

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $lnwhsee = $drierror
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   goto      endvfyadd

     C                   endsl

     *  Note, code validation done in routine recadd.

     C     endvfyadd     endsr

640aA*----------------------------------------------------------------
640aA*  vfyadds  Verify information for adds
640aA*----------------------------------------------------------------
640aA
640aAC     vfyadds       begsr

     C                   exsr      inzchkflds

     *  Validate warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $lnwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $lnwhsee = $drierror
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #pgm
     C                   leavesr

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $lnwhsee = $drierror
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   leavesr

     C                   endsl

     C                   endsr

     *----------------------------------------------------------------
     *  vfychg    Verfify information for change
     *----------------------------------------------------------------

     C     vfychg        begsr

     *  Verify that necessary fields were sent.

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfychg

     *  Note, code validation done in routine recchg.

     C     endvfychg     endsr

640aA*----------------------------------------------------------------
640aA*  vfychgs   Verfify information for changes
640aA*----------------------------------------------------------------
640aA
640aAC     vfychgs       begsr
     C                   endsr

     *----------------------------------------------------------------
     *  vfydel   Verify information for delete
     *----------------------------------------------------------------

     C     vfydel        begsr

     C                   exsr      inzchkflds

     *  Verify that necessary fields were sent.

     C                   exsr      vfycodesent
     C     error         cabeq     *on           endvfydel

     C     endvfydel     endsr

     *----------------------------------------------------------------
     *  vfydelall   Verify information for deleteall
     *----------------------------------------------------------------

     C     vfydelall     begsr

     C                   exsr      inzchkflds

     C     endvfydelall  endsr

     *----------------------------------------------------------------
     *  vfycodesent  Verify that at least one code was sent
     *----------------------------------------------------------------

     C     vfycodesent   begsr

     C                   if        not $lncodeu(1)
     C                   eval      error = *on
     C                   eval      $lncodee(1) = $drierror
     C                   eval      $preturn  = 'CODENOTSNT'
     C                   eval      $pmessage = 'Code must be sent'
     C                   endif

     C                   endsr
640hA*----------------------------------------------------------------
640hA*  vfyreplace Verfify information for gs1 xdk temp license replacement
640hA*----------------------------------------------------------------
640hA
640hAC     vfyreplace    begsr
     C                   endsr

