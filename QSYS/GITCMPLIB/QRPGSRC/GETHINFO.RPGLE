     *----------------------------------------------------------------
     *   Copyright (C) 2005 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  GETHINFO   Get Host Information
     *  27 September 2005
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
500 A*    09/27/05  MLB  5.00
     *      - Created.
500aA*    09/27/05  MLB  5.00a
     *      - Enh: Revised program to add support for Client id
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
     *
BIR A*    01/20/05  MLB  BIR
     *      - Created pgm to retrieve information from FFJITMBL0
     *        file.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fffjitmbl0 if   e           k disk    usropn
     Fhwlink1   if   e           k disk    usropn
     *
     *----------------------------------------------------------------
     *  Table and array definitions
     *
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
500aAD @getcl          c                   const('GETCLIENT')
500aA*
BIR A /COPY QCOPYSRC,ID#BIRITE
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
     D  $plsld                37     42  0
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
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
     *
     *----------------------------------------------------------------
     *  Working variables.
     *
     D $msgf           s             10
     D $rtncd          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D msgk            s              4  0
     D lastwhs         s              3  0 inz(0)
     D openffj         s              1    inz('0')
     D openhw          s              1    inz('0')
     D today           s              8  0 inz(0)
     *
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *LSTSOLD - Get date last sold for item
     *              *CLOSE   - Close all open files
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   *OK      - Information found.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz2
     *
     C                   select
     C                   when      $pcmd = '*LSTSOLD'
     C                   exsr      lastsold
     C*
     C                   when      $pcmd = '*CLOSE'
     C                   exsr      closefile
     C                   eval      *inlr = *on
     C                   endsl
     *
     *   Do some clean up before leaving.
     *
     C                   return
     *
     *----------------------------------------------------------------
     *
     *          Subroutines in Alpabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
500aA*
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define Host file keys.
     *
     C     *like         define    ffjitmn       kyitmn
     C     ffjkey        klist
     C                   kfld                    hwcmpn
     C                   kfld                    hwdivn
     C                   kfld                    hwdptn
     C                   kfld                    hwwhsn
     C                   kfld                    kyitmn
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvtdt
     C                   eval      today  = $cvd8o
     *
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Open files needed to retrieve information.
     *
     C                   select
     C                   when      $pcmd = '*LSTSOLD'
     *
     C                   eval      $plsld = 0
     *
     *    Open Host item balance file.
     C                   if        not openffj
     C                   open      ffjitmbl0
     C                   eval      openffj = *on
     C                   endif
     *
     *    Open Dakota / Host Cross-Reference file.
     C                   if        not openhw
     C                   open      hwlink1
     C                   eval      openhw = *on
     C                   endif
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Closefile   Close files opened by program.
     *
     C     Closefile     begsr
     *
     *   Close open files.
     *
     C                   if        openffj
     C                   close     ffjitmbl0
     C                   endif
     *
     C                   if        openhw
     C                   close     hwlink1
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  Lastsold    Get Date Last Sold from Host file.
     *
     C     Lastsold      begsr
     *
     C                   eval      $prtn  = '*error  '
     C                   eval      kyitmn = ' '
     C                   evalr     kyitmn = %trimr($pitem)
     *
     *   Get Host cross-reference file.
     *
     C                   if        $pwhse <> lastwhs
     C     $pwhse        chain     hwlink1
     C                   eval      lastwhs = $pwhse
     C                   endif
     *
     C                   if        %found(hwlink1)
     *
     C     ffjkey        chain     ffjitmbl0
     C                   if        %found(ffjitmbl0)
     C                   move      ffjdtez       $cvd8i
     C                   eval      $cvcmd = '*CMDMDY '
     C                   exsr      zzcvtdt
     C                   eval      $plsld = $cvd6o
     C                   eval      $prtn  = '*ok     '
     C                   endif
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  zzcvtdt     Convert date
     *
     C     Zzcvtdt       begsr
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C                   endsr
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
