      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Copyright (C) 2010 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UI800   Utility - Delete UCI's by License - session failure
     *  10 March 2014
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTSQLRPGI OBJ(*) SRCFILE(*) TGTRLS(V5R3M0)
     *               COMMMIT(*NONE) DLYPRP(*YES)
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
650 A*    03/10/14  LMC  6.50
     *      - Created.
     *
650a *    02/21/15  LMC  6.50a
     *      - Added ability to remove UCI's once license is putaway
     *      We were doing this manually for the client.
     *
710a *    12/22/17  MR   7.10a
     *      - Added email and pics parms to GETEMPL.
720aA*    08/15/16  LMC  7.20a  reserved
     *      - Enh: UCI Tracking.
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fui800fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   if   e           k disk
     Fpiruser1  if   e           k disk    rename(usrec:usrec1)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     *  Program parameters
     *
     D $uparm          ds
     D  $ucmd                  1      8
     D  $uprg                  9     18
     D  $uuky                 19     68
     D  $urtn                 69     76
     D  $uerm                 77    136
     D  $umsg                 77     80
     *
     *   Redefine key
     *
     D  $uusr                 19     28
     D  $ucrew                29     34
     *
     D $wparm          ds
     D  $wcmd                  1      8
     D  $wprg                  9     18
     D  $wuky                 19     68
     D  $wrtn                 69     76
     D  $werm                 77    136
     D  $wmsg                 77     80
     *
     *   Redefine key
     *
     D  $wwhse                19     21  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem#                1     15
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
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#UCIINFO
     D saveVer#        s                   like($uIver#)

     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#citylin
      /COPY QCOPYSRC,Id#sgc
      /COPY QCOPYSRC,Id#kfs

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Key definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $plen           s              3  0
     D $pstr           s             60
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D @plcmd          S              8
     D @plset          S              6
     D ck4err          s               n
     D cmdtkn          s              1
     D e               s              2  0
     D erm             s             60
     D error           s              1
     D logflag         s              1
650aAD licensefound    s              1
     D msgk            s              4  0
650aAd Newpddwgt       s                   like(pddwgt)
650aAd Newpdqrc1       s                   like(pdqrc1)
     D nxtscr          s              3
     D sclear          s              1
     D warn            s              1
     D work1a          s              1
     D w1usr#          s              5  0
     D w1whse          s              3  0
     D forevr          s               n
     *----------------------------------------------------------------
     *  Global Variables

     D gEmp#           s              5  0
     D gUser           s             10
     D gWhse           s              3  0

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D/copy qcopysrc,p.getempl

     *----------------------------------------------------------------
     *  File data data structure

     D license       E ds
650aAD ptrec         e ds                  extname(pirtran)
650aAD pdrec         e ds                  extname(podtl)
650aAD porrec        e ds                  extname(porcv2)
     *----------------------------------------------------------------
     *  Sub-procedure prototypes

     D VfyEmployee     pr
     D VfyLicense      pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010809
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     *  Get default values.
     *
     C                   exsr      zzdft1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input.
     *
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1

     C                   exsr      zzupd1

     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   move      *on           forevr
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110 - Starting number
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $wcmd = '*VERIFY '
     C                   eval      $wprg = #prog
     C                   eval      $wwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $wparm
     C                   if        $wrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $werm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $wrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $wmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *

      /free

650aM   erm = ' ';
        // do nothing if a license is not entered
        if w1lcns = ' ';
          error = *on;
        endif;

650aA   // Check to see if any UCIINFO records exist for this license
650aA   exsr clr$uciinfo;
650aA   $uiWhse = w1whse;
650aA   $uiLcns = w1lcns;

650aA   $dricommand = '*UCIINFO';
650aA   $drisubcmd  = '%GETLICREC';
650aA   $drisys2upd = 'D';
650aA   ck4err = *on;
650aA   exsr zzzdricop;
650aA   if $drireturn = '*NONE';
650aA     error = *on;
650aA     erm = 'No UCIs exist for this license';
650aA     *in28 = *on;
650aA     *in08 = *on;
650aA     errmsg = erm;
650aA     exsr zm0105;
650aA     leavesr;
650aA   endif;

        // Verify that we don't have a transaction attached to the license
        // if transaction - don't allow uci delete.

        VfyLicense();
        if erm <> ' ';
          error = *on;
          *in28 = *on;
          *in08 = *on;
          errmsg = erm;
          exsr zm0105;
        endif;

      /end-free

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse
     *
     C                   when      row# = 07
     C                   eval      $wcmd = '*LOOKUP '
     C                   eval      $wprg = #prog
     C                   eval      $wwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $wparm
     C                   if        $wrtn = '*SELECT '
     C                   eval      w1whse = $wwhse
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values.
     *
     C     zzdft1        begsr

     c                   eval      w1lcns = ' '

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr

     C*                  eval      $rtncd = '*OK     '

     C                   eval      $pstr  = 'Delete Uci By License'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr


     *      Get warehouse for user if not passed in.

     C                   if        w1whse = 0
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     *
     *  Get current date & time
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
      /free
650aA   // if we have a found license - do not delete the licinfo record
650aA   // we are providing the ability to delete uci's after the license
650aA   // has been putaway. We use to do this manually for the client
650aA   if licensefound = ' ';
          // Delete LICINFO Records
          exsr zzlicinfocan;
650aA   endif;

        exsr clr$uciinfo;

        // warehouse
        $uiWhse = w1whse;

        // License
        $uiLcns = w1lcns;

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%CANCEL';
        $drisys2upd = 'D';
        ck4err = *on;
        exsr zzzdricop;

650aA   // we need to cleanup the podtl file
650aA   // get the licinfo qty and weight in order to reduce the podtl
650aA   exsr clr$licinfo;
650aA   $lnwhse  = w1whse;
650aA   $lnlcns  = w1Lcns;
650aA   $lnseq = 1;
650aA   $dricommand = '*LICINFO';
650aA   $drisubcmd  = '%GET';
650aA   $drisys2upd = 'D';
650aA   ck4err = *on;
650aA   exsr zzzdricop;
650aA   if error = *on;
650aA     // no license found?
650aA   else;
650aA     // reduce qty and weight from PODTL
650aA     exec sql select * into :pdrec
650aA              from podtl
650aA              where pdwhse = :$lnwhse
650aA                and pdpo   = :$lnpo
650aA                and pdseq  = :$lnposeq
650aA                and pditem = :$lnitem;
650aA     If sqlstt = sqlSuccess;
650aA       Newpdqrc1 = pdqrc1 - $lnrcvqty;
650aA       Newpddwgt = pddwgt - $lnttllbs;
650aA       exec sql update podtl set
650aA                pddwgt = :Newpddwgt,
650aA                pdqrc1 = :Newpdqrc1
650aA                where pdwhse = :$lnwhse
650aA                  and pdpo   = :$lnpo
650aA                  and pdseq  = :$lnposeq
650aA                  and pditem = :$lnitem;
650aA       If sqlstt = sqlSuccess;
650aA       endif;

650aA     endif;
650aA   endif;
      /end-free
     *
     C                   exsr      zzdft1
     *
     C     endupd        endsr
     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = gemp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = gemp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr

     *----------------------------------------------------------------
     *  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
     *----------------------------------------------------------------

      /free
        begsr zzlicinfocan;

          exsr clr$licinfo;

          $lnwhse  = w1whse;
          $lnlcns  = w1lcns;

          $dricommand = '*LICINFO';
          $drisubcmd  = '%DELETEALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;

        endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720aMC                   eval      $dridata2 = $uciinfo2
     C                   endsl


     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #PROG         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2

     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

640dDC*                  when      chk4err and %error
640dMC                   when      ck4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog

     C                   select
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

640dDC*                  eval      chk4err = *off
640dMC                   eval      ck4err = *off
     C     enddricop     endsr
     *----------------------------------------------------------------
     *  VfyEmployee  Verify employee number
     *----------------------------------------------------------------

     p VfyEmployee     b
     d VfyEmployee     pi

     * Local variables

     d e$whse          s              3  0
     d e$user          s             10
     d e$fnam          s             15
     d e$init          s              1
     d e$lnam          s             20
     d e$whdp          s              5
     d e$styp          s              1
     d e$shft          s              6
     d e$crew          s              6
     d e$nhrs          s              3  1
     d e$rtn           s              8
     d e$bpu           s              1
     d e$lng           s              2
     d e$email         s              1
     d e$pics          s              1

      /free

         // Get employee info

         eval usemp# = 0;

         monitor;
           getEmpl(gEmp#: gWhse: gUser: e$fnam: e$init: e$lnam:
                   e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
710aD        //    e$bpu: e$lng);
710aM              e$bpu: e$lng: e$email: e$pics);
         on-error;
           erm   = 'Error calling getEmpl';
           return;
         endmon;

         if e$rtn = '*ERROR';
           erm   = 'User not found for emp#';
           return;
         endif;

       return;
      /end-free

     p VfyEmployee     e

     *----------------------------------------------------------------
     *  VfyLicense Verify UCI exist for this license
     *----------------------------------------------------------------

     p VfyLicense      b
     d VfyLicense      pi

     * Local variables

      /free


         // Verify No Transaction exist for this license

650aA    licensefound = ' ';
         exec sql select * into :license
                from license
                where liwhse = :w1whse and lilcns = :w1lcns;
         If sqlstt = sqlSuccess;
650aA      licensefound = 'Y';
650aA      // we found a license record
650aA      // is the transaction still open if so user should unreceive
650aA      exec sql select * into :ptrec
650aA             from pirtran
650aA             where ptwhse = :liwhse
650aA               and pttrn# = :litrn#
650aA               and ptstat <> '4';
650aA      If sqlstt = sqlSuccess;
650aA        erm = 'Open Receipt, Delete the transaction from the PO';
650aA        return;
650aA      endif;
650aA      // We found a license - Can't delete UCI if Po has been exported
650aA      exec sql select * into :porrec
650aA             from porcv2
650aA             where porwhs = :liwhse
650aA               and portrn = :litrn#
650aA               and porlic = :lilcns
650aA               and poredt <> 0;
650aA      If sqlstt = sqlSuccess;
650aA        erm = 'Already Exported - Cannot remove UCI information';
650aA        return;
650aA      endif;
650aD      //erm   = 'License found ('
650aD               //+ %trim(w1lcns) + ')';
         endif;

       return;
      /end-free

     p VfyLicense      e

     *----------------------------------------------------------------*********
