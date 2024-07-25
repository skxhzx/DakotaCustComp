     H OPTION(*NODEBUGIO)
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR340   Trax Route Completion Report
     *  05 August 2013
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *
650aA*    08/05/13  RBD  6.50a
     *      - Created.
     *
710aA*    03/24/17  RBD  7.10a
     *      - Fix: remove head2 headings from head3 output.
     *
730aA*    08/27/19  RBD  7.30a
     *      - Added report override logic.
     *
730bA*    09/25/19  RBD  7.30b
     *      - Added lower case c stop flag logic. This stop flag prompts
     *        for COD info for non-COD customer.  Unlike upper case C
     *        COD flag, driver is not forced to enter anything and there
     *        is no validation if info is entered.
     *
740aA*    03/20/20  RBD  7.40a
     *      - Fix: If check# not followed by semi colon look for a blank
     *        to determine end of check#.
     *
750aA*    07/14/21  RBD  7.50a
     *      - Add totals for cash, check and credit card amounts.
     *
750bA*    08/09/21  RBD  7.50b
     *      - If more than 9 digits sent for amount default to zero as
     *        it is clearly an invalid amount.  This will mitigate the
     *        dreaded 'target too small to hold result' error.
     *
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Fordh9     if   e           k disk
     Fpiritem   if   e           k disk
     Frtesum    if   e           k disk
     Fttrte     if   e           k disk
     Fttrtn3    if   e           k disk
     Fttstp     if   e           k disk
     Fttstpfr   if   e           k disk
     Freports   if   e           k disk
     Fwarehs    if   e           k disk
     Ftr340pr   o    e             printer oflind(*in91)
730aAF                                     usropn
     *----------------------------------------------------------------
     *  Customer id
     *
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     D ul              s              1    dim(132)
     D desc            s             60    dim(1) ctdata perrcd(1)
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Working Variables
     *
     D count           s              3  0
750aAD decimal         s              1    inz('.')
750aAD decpos          S              1s 0 inz(0)
     D error           s              1
     D first           s              1
     D forever         s              1
     d gBrkPct         s              7s 3
     D k3pick          s              1
     D k3stat          s              2
     D len             s              1  0
750aAD lendec          s              1  0
750bDD*lenwhole        s              1  0
750bMD lenwhole        s              3  0
     D linppg          s              3  0
     D pflag           s              1
     D pos             s              1  0
     D pos3            S              3s 0 inz(0)
     D pos3a           S              3s 0 inz(0)
     D whs#            s              3  0
750aAD wkamt92         S              9s 2 inz(0)
750aAD wkamt70         S              7s 0 inz(0)
     D work3a          s              3
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route Id
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     *
     * Main line
     *
     *  Header info for route
     *
     C                   exsr      zzinz1
     C                   exsr      zzrte
     *
     *  Returns
     *
     C                   exsr      zzinz2
     C                   exsr      zzrtn
     *
     *  Stop info
     *
     C                   exsr      zzinz3
     C                   exsr      zzstp
     *
     *  Print totals
     *
     C                   if        *in91 = *on
     C                   write     head1                                91
     C                   endif
     C                   write     head4                                91
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
     *
     *  Variables and constants.
     *
     C                   eval      forever = *off
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rdate = $cvd6o
     C                   time                    rtime
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ1   Program initialization. Called from main line.
     *
     C     zzinz1        begsr
     *
     *  Define key for TTRTE file.
     *
     C     keyttrte      klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

730aAC                   if        %open(tr340pr)
730aAC                   close     tr340pr
730aAC                   endif

730aA*      Retrieve report device override.
730aAC                   if        not %open(tr340pr)
     *
730aAC                   call      'GETRPT'
730aAC                   parm      '*DEVFORM'    $cmd              8
730aAC                   parm      'TR340PR'     $lrpt            10
730aAC                   parm                    $pwhse
730aAC                   parm      ' '           $styp             1
730aAC                   parm      ' '           $whdp             5
730aAC                   parm                    $desc            50
730aAC                   parm      ' '           $dev             10
730aAC                   parm      ' '           $form            10
     *
730aAC                   if        $dev = ' '
730aAC                   eval      $dev = '*JOB'
730aAC                   endif
730aAC                   if        $form = ' '
730aAC                   eval      $form = '*STD'
730aAC                   endif
     *
730aAC                   eval      qcmd = 'OVRPRTF '
730aAC                                  + 'FILE(TR340PR) '
730aAC                                  + 'OUTQ(' + %trim($dev) + ') '
730aAC                                  + 'FORMTYPE(' + %trim($form) + ') '

730aAC                   call      'QCMDEXC'
730aAC                   parm                    qcmd             80
730aAC                   parm      80            qlen             15 5

730aA*  Open printer file

730aAc                   eval      *in90 = *on
730aAC                   open(e)   tr340pr
730aAC                   if        %error
730aAC                   endif
     *
730aAC                   endif
     *
     *  Get report heading.
     *
     C                   eval      w1head = *blanks
     C                   movel     'TR340PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = desc(1)
     C                   endif
     C                   eval      $plen = 60
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      $pwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   if        pos = 0
     C                   eval      pos = 1
     C                   endif
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      34            $clen             3 0
     C                   movel     $cstr         whhead
     *
     C                   eval      ul = '_'
     C                   movea     ul            unline
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define key for piritem.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    ttitem
     *
     *   Write headings
     *
     C                   write     head2
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ3   Program initialization. Called from main line.
     *
     C     zzinz3        begsr
     *
     *  Define key for order header and stop flags response file.
     *
     C     keywhrtst     klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    ttpstp
     *
     *   Write headings
     *
     C                   write     head3
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRTE    Get header info for route.
     *
     C     zzrte         begsr
     *
     C     keyttrte      chain     ttrte
     *
     *  Convert delivery start date
     *
     C                   if        ttrsrd <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ttrsrd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      strmdy = $cvd6o
     C                   endif
     *
     *  Convert delivery finish date
     *
     C                   if        ttrfid <> 0
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ttrfid        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      finmdy = $cvd6o
     C                   endif
     *
     *  Get total pieces
     *
     C     keyttrte      setll     rtesum
     C                   dow       forever = forever
     C     keyttrte      reade     rtesum
     C                   if        %eof
     C                   leave
     C                   endif
     C                   add       rsordp        w1tpcs
     C                   enddo
     *
     *  Calculate total pieces delivered
     *
     C                   eval      w1dpcs = ttrqs1 + ttrqs2 + ttrqs3
     C                                    + ttrqn1 + ttrqn2 + ttrqn3
     *
     *  Get pieces returned
     *
     C                   eval      w1rpcs = ttrqc1 + ttrqc2 + ttrqc3
     C                                    + ttrqp1 + ttrqp2 + ttrqp3
     *
     C                   write     head1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRTN    Look for and print route returns, if any.
     *
     C     zzrtn         begsr
     *
     C     keyttrte      setll     ttrtn3
     C                   dow       forever = forever
     *
     C     keyttrte      reade     ttrtn3
     C                   if        %eof(ttrtn3)
     C                   leave
     C                   endif
     *
     *  Get item description
     *
     C     keyit         chain     piritem
     C                   if        not %found(piritem)
     C                   eval      itdesc = *blanks
     C                   endif
     *
     *  Write return detail
     *
     C                   if        *in91 = '1'
     C                   write     head1                                91
     C                   write     head2                                91
     C                   endif
     C                   write     detl2                                91
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSTP    Get and print stop info.
     *
     C     zzstp         begsr
     *
     C     keyttrte      setll     ttstp
     C                   dow       forever = forever
     *
     C     keyttrte      reade     ttstp
     C                   if        %eof(ttstp)
     C                   leave
     C                   endif
     *
     *  Get customer name
     *
     C     keywhrtst     chain     ordh9
     C                   if        not %found(ordh9)
     C                   eval      ohcnam = *blanks
     C                   endif
     *
     *  Calculate total pieces delivered for stop
     *
     C                   eval      w3dpcs = ttpqs1 + ttpqs2 + ttpqs3
     C                                    + ttpqn1 + ttpqn2 + ttpqn3
     *
     *  Get pieces returned
     *
     C                   eval      w3rpcs = ttpqc1 + ttpqc2 + ttpqc3 +
     C                                      ttpqp1 + ttpqp2 + ttpqp3
     *
     *  Look for stop flag responses for cash, check, check#, and credit
     *
     C                   eval      w3cash = *blanks
     C                   eval      w3chek = *blanks
     C                   eval      w3chk# = *blanks
     C                   eval      w3cred = *blanks
     *
     C     keywhrtst     setll     ttstpfr
     C                   dow       forever = forever
     *
     C     keywhrtst     reade     ttstpfr
     *
     C                   if        %eof(ttstpfr)
     C                   leave
     C                   endif
     *
     C                   if        ttfrch <> '$' and
730bMC                             ttfrch <> 'C' and
730bAC                             ttfrch <> 'c'
     C                   iter
     C                   endif
     *
     *    Look for cash
     *
     C                   eval      pos3 = %scan('$:':ttfrre)
     C                   if        pos3 = 0
     C                   goto      nocash
     C                   endif
     C                   eval      pos3a = %scan(';':ttfrre:pos3)
     C                   if        pos3a = 0
     C                   eval      pos3a = %scan(']':ttfrre:pos3)
     C                   endif
     C                   if        pos3a = 0
     C                   goto      nocash
     C                   endif
     C                   eval      w3cash = %subst(ttfrre:(pos3+2):(pos3a) +
     C                                      -(pos3+2))
750aAC                   if        w3cash = *blanks
750aAC                   goto      nocash
750aAC                   endif

750aA /free

750aA    decpos = 0;
750aA    lendec = 0;
750aA    lenwhole = 0;
750aA    wkamt70 = 0;
750aA    wkamt92 = 0;
750aA    decpos = %scan(decimal: w3cash);
750aA    lenwhole = %len(%triml(w3cash)) - (decpos);
750bA    if lenwhole <= 7;
750aA      if decpos = 0;
750aA        wkamt92 = (%dec(w3cash:9:2)) / 100;
750aA      else;
750aA        wkamt70 = %dec(%subst(w3cash:1:lenwhole):7:0);
750aA        lendec = %len(w3cash) - (decpos);
750aA        wkamt92 = (%dec(%subst(w3cash:(decpos+1):lendec):9:2)) / 100;
750aA      endif;
750bA    endif;
750aA    lrcash = lrcash + wkamt70 +wkamt92;

750aA /end-free

     C     nocash        tag
     *
     *    Look for check ... to differentiate from CC (credit), look for [C:
     *    and ;C:
     *
     C                   eval      pos3 = %scan('[C:':ttfrre)
     C                   if        pos3 = 0
     C                   eval      pos3 = %scan(';C:':ttfrre)
     C                   if        pos3 = 0
     C                   goto      nochek
     C                   endif
     C                   endif
     C                   eval      pos3a = %scan(';':ttfrre:pos3+1)
     C                   if        pos3a = 0
     C                   eval      pos3a = %scan(']':ttfrre:pos3+1)
     C                   endif
     C                   if        pos3a = 0
     C                   goto      nochek
     C                   endif
     C                   eval      w3chek = %subst(ttfrre:(pos3+3):(pos3a) +
     C                                      -(pos3+3))
750aAC                   if        w3chek = *blanks
750aAC                   goto      nochek
750aAC                   endif

750aA /free

750aA    decpos = 0;
750aA    lendec = 0;
750aA    lenwhole = 0;
750aA    wkamt70 = 0;
750aA    wkamt92 = 0;
750aA    decpos = %scan(decimal: w3chek);
750aA    lenwhole = %len(%triml(w3chek)) - (decpos);
750bA    if lenwhole <= 7;
750aA      if decpos = 0;
750aA        wkamt92 = (%dec(w3chek:9:2)) / 100;
750aA      else;
750aA        wkamt70 = %dec(%subst(w3chek:1:lenwhole):7:0);
750aA        lendec = %len(w3chek) - (decpos);
750aA        wkamt92 = (%dec(%subst(w3chek:(decpos+1):lendec):9:2)) / 100;
750aA      endif;
750bA    endif;
750aA    lrchek = lrchek + wkamt70 +wkamt92;

750aA /end-free

     C     nochek        tag
     *
     *    Look for check #
     *
     C                   eval      pos3 = %scan('CN:':ttfrre)
     C                   if        pos3 = 0
     C                   goto      nochk#
     C                   endif
     C                   eval      pos3a = %scan(';':ttfrre:pos3)
     C                   if        pos3a = 0
740aDC**                 eval      pos3a = %scan(']':ttfrre:pos3)
740aMC                   eval      pos3a = %scan(' ':ttfrre:pos3)
     C                   endif
     C                   if        pos3a = 0
     C                   goto      nochk#
     C                   endif
     C                   eval      w3chk# = %subst(ttfrre:(pos3+3):(pos3a) +
     C                                      -(pos3+3))
     C     nochk#        tag
     *
     *    Look for credit
     *
     C                   eval      pos3 = %scan('CC:':ttfrre)
     C                   if        pos3 = 0
     C                   goto      nocred
     C                   endif
     C                   eval      pos3a = %scan(';':ttfrre:pos3)
     C                   if        pos3a = 0
     C                   eval      pos3a = %scan(']':ttfrre:pos3)
     C                   endif
     C                   if        pos3a = 0
     C                   goto      nocred
     C                   endif
     C                   eval      w3cred = %subst(ttfrre:(pos3+3):(pos3a) +
     C                                      -(pos3+3))
750aAC                   if        w3cred = *blanks
750aAC                   goto      nocred
750aAC                   endif

750aA /free

750aA    decpos = 0;
750aA    lendec = 0;
750aA    lenwhole = 0;
750aA    wkamt70 = 0;
750aA    wkamt92 = 0;
750aA    decpos = %scan(decimal: w3cred);
750aA    lenwhole = %len(%triml(w3cred)) - (decpos);
750bA    if lenwhole <= 7;
750aA      if decpos = 0;
750aA        wkamt92 = (%dec(w3cred:9:2)) / 100;
750aA      else;
750aA        wkamt70 = %dec(%subst(w3cred:1:lenwhole):7:0);
750aA        lendec = %len(w3cred) - (decpos);
750aA        wkamt92 = (%dec(%subst(w3cred:(decpos+1):lendec):9:2)) / 100;
750aA      endif;
750bA    endif;
750aA    lrcred = lrcred + wkamt70 +wkamt92;

750aA /end-free

     C     nocred        tag
     *
     C                   enddo
     *
     *  Write stop detail
     *
     C                   if        *in91 = '1'
     C                   write     head1                                91
710aDC**                 write     head2                                91
     C                   endif
     C                   write     detl3                                91
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile Time Tables
     *
**
TRAX ROUTE COMPLETION REPORT
