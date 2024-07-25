500 A /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  CK110A  Check Right FTP Status - Display
     *  22 June 2009
     *  Jeffrey Jahnke   Copied from TX110
     *
     *----------------------------------------------------------------
     *  Revisions
     *
500 A*    06/22/09  JCJ  5.20
     *      - Created.
     *
640aA*    03/20/12  JCJ  640a
     *      - Enh:  Purge TaxrData records before resending.
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *    This program has been revised to work with option '1'
     *    selections similar to how it works with option '4' selections.
     *
     *    This program uses to display subfiles to show more than one
     *    view of the record.
     *
     *    Allowed F17 and F18 for positioning to top and bottom.
     *
     *    Created a second line for commands.
     *
     *    CMD5 changed to chain and update each view seperately.
     *
     *    RECNO used for all subfiles, SFLRCDNBR not used in format member.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        Position Cursor
     *  21 - 29   Field Input Error (Reverse Display)
     *  79        Chain Indicator
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  21        Manually set subfile change flag (SFLNXTCHG)
     *  90        Protect Input Fields for Delete Display
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound Buzzer)
     *  99        Universal Record Indicator (Very Temporary Usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fck110afm  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(vw2sfl:recno)
     F                                     sfile(vw3sfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
     Fckftplog1 if   e           k disk
     F                                     rename(ckftpr:record)
     Fckftplog2 if   e           k disk
     F                                     rename(ckftpr:record2)
     Fpirtran   if   e           k disk
640aAFckrdata2  uf   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D zopt            s              2    dim(20) ctdata perrcd(20)
     D optln           s             75    dim(2) ctdata perrcd(1)
     D cmdln           s             79    dim(6) ctdata perrcd(1)
     D type            s             12    dim(1) ctdata perrcd(1)
     D stat            s             15    dim(5) ctdata perrcd(1)
510 AD desc            s             70    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Partial key redefinition
     *
     D $prtky          ds
     D  $len50                       50
     D  $kwhse                        3  0
     D  $kaddts                      26z
     D  $krte                         5
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dsfkey                       50
     D  dsukey                       50
     D                                     overlay(dsfkey:1)
     D  pfwhse                        3  0 inz(0)
     D                                     overlay(dsfkey:1)
     D  pfaddts                      26z
     D                                     overlay(dsfkey:4)
     D  pfrte                         5
     D                                     overlay(dsfkey:30)
     D  pfrtid                        5
     D                                     overlay(dsfkey:35)
     D  pftrn#                        7  0 inz(0)
     D                                     overlay(dsfkey:40)
     D  pffsts                        1
     D                                     overlay(dsfkey:47)
     D  pftype                        2
     D                                     overlay(dsfkey:48)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @chgpg          c                   const('NONE')
     D @delpg          c                   const('CK114')
     D @prtpg          c                   const('NONE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
     *----------------------------------------------------------------
     *  Date Conversion data structure
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
     D dftstamp        s               z
     D datestamp       s               d
     D timestamp       s               t
     D                 ds
     D currstamp                       z
     D  curr_date                      d   overlay(currstamp) datfmt(*iso)
     *----------------------------------------------------------------
     *  Other data structures
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Working variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forceb          s              1
     D forevr          s              1
     D frstky          s                   like($puky)
     D dsprcds         s              4    inz('*ERR')
     D F8_txt1         c                   const('All FTP routes')
     D F8_txt2         c                   const('Rte FTP errors')
     D F8_view1        c                   const('*All Routes*')
     D F8_view2        c                   const('*FTP Errors*')
     D goback          s              2  0
     D help            s              5  0
     D kyrte           s                   like(pfrte)
     D kyrtid          s                   like(pfrtid)
     D kytype          s                   like(pftype)
     D kywhse          s                   like(pfwhse)
     D maxvw           s              1  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D posrec          s              4  0
     D p1              s              1  0
     D p2              s              2  0
     D reccnt          s              4  0
     D recno           s              4  0
     D refrsh          s              1
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D stserr          s              1
     D top             s              1
     D v               s              2  0
     D view            s              1  0
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
     D $pwhse          s              3  0
     D $prtid          s              5
     D $prte           s              5
     D $rtrn           s              7  0
     D $pmbr           s             10
     D $pfile          s             30
     D $rrtn           s             10
     D $rmsg           s             30
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
     *
     D  eropt                  1     20
     D  erstat                21     40
     D  ertype                41     50
     D                 ds
     D  $ec                    1      2p 0
     *
     D Errmsg01        c                   'Invalid position-to date entered.'
     D Errmsg02        c                   'Export file name blank. File not se-
     D                                     nt for Rt-'
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
     *      - None -
     *
     *    Returned Parameters
     *      - None -
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   exsr      zzinz2
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
OP1  C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      clrsch
     C                   seton                                        lr
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
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     C                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Set display mode based on last view.
     C                   eval      *in51 = dspmode
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exsr      deldsp
     C                   endif
     C                   if        nxtscr = '03 '
     C                   exsr      deldsp
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   select
     C                   when      view = 1
     C                   read      dspsfc                                 50
     C                   when      view = 2
     C                   read      vw2sfc                                 50
     C                   when      view = 3
     C                   read      vw3sfc                                 50
     C                   endsl
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     delrec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag02
     C                   write     cmddel
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 wrap-up
     *
     C     scr02e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     *
     *   If delete was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   eval      *in90 = *on
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   write     op1rec
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag03
     C                   write     cmdop1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 wrap-up
     *
     C     scr03e        begsr
     C                   eval      nxtscr = '01 '
     C                   eval      *in90 = *off
     *
     *   If option 1 was not canceled (no errors)
     *     then reposition to record just before first deleted rec.
     *
     C                   if        cancel = *off
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = frstky
     C                   exsr      fgtway
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     C                   if        $portn = '*NOMORE '
     C                   eval      $pocmd = '*TOP    '
     C                   else
     *
     *   Otherwise, position to last record read.
     *
     C                   eval      $pocmd = '*POSTN2 '
     C                   endif
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   exsr      optns
     C                   else
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     C     status        caseq     rollup        roll02
     C     status        caseq     rolldn        roll02
     C     status        caseq     comand        cmd02
     C                   cas                     ent02
     C                   endcs
     C     endsc2        endsr
OP1  *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     C     status        caseq     rollup        roll03
     C     status        caseq     rolldn        roll03
     C     status        caseq     comand        cmd03
     C                   cas                     ent03
     C                   endcs
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10

     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
     C                   write     dspsfl                               79
     C                   write     vw2sfl                               79
     C                   write     vw3sfl                               79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  Test for Cmd3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd12 - Cancel
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      cmd01e
     C                   endif
     *
     *  Execute command keys that don't need the options verified
     *
     *     Test for Cmd5 - Refresh
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        dsplyd        x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    dspsfl
     C                   endif
     C     x             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw2sfl
     C                   endif
     C     x             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      option = '  '
     C                   update    vw3sfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Verify and save any options that were entered
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  Execute command keys that did need the options verified
     *
     *  Test for CMD6 - Add record
     *
     C                   if        *inkf
     C                   exsr      inzpar
     C                   eval      $pcmd = '*ADD    '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     C                   if        $prtn <> '*CANCEL '  and
     C                             $prtn <> '*EXIT   '
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd20 - Move record that cursor is on to top
     *
     C                   if        *inku
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Make sure cursor is on one of the displayed records
     *
     C                   if        dspmode = *on
     C                   sub       10            row#
     C                   else
     C                   sub       5             row#
     C                   endif
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     Reposition record that cursor is on to the top
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd10 - Previous view
     *
     C                   if        *inkj
     C                   if        view = 1
     C                   eval      view = maxvw
     C                   else
     C                   eval      view = view - 1
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     *
     *    Load F8 key text based on current view.
     C                   if        dsprcds = '*ERR'
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt1:cmdln1:36:14)
     C                   endif
     C                   else
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt2:cmdln1:36:14)
     C                   endif
     C                   endif
     *
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd11 - Next view
     *
     C                   if        *inkk
     C                   if        view = maxvw
     C                   eval      view = 1
     C                   else
     C                   add       1             view
     C                   endif
     C                   eval      v = view * 2
     C                   eval      cmdln2 = cmdln(v)
     C                   eval      v = v - 1
     C                   eval      cmdln1 = cmdln(v)
     *
     *    Load F8 key text based on current view.
     C                   if        dsprcds = '*ERR'
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt1:cmdln1:36:14)
     C                   endif
     C                   else
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt2:cmdln1:36:14)
     C                   endif
     C                   endif
     *
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd17 - Reposition to top of display
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   eval      $kaddts  = *hival
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  Test for Cmd18 - Reposition to bottom of display
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   eval      $kaddts  = *loval
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *   Process non-standard function keys.
     *
     C                   exsr      zzcmd
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  CMD02    Screen 2 command key routine
     *
     C     cmd02         begsr
     *
     *  Test for Cmd12 - Cancel
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr02e
     C                   goto      cmd02e
     C                   endif
     *
     C     cmd02e        endsr
     *----------------------------------------------------------------
     *
     *  CMD03    Screen 3 command key routine
     *
     C     cmd03         begsr
     *
     *  Test for Cmd12 - Cancel
     *
     C                   if        *inkl
     C                   eval      cancel = *on
     C                   exsr      scr03e
     C                   goto      cmd03e
     C                   endif
     *
     C     cmd03e        endsr
     *----------------------------------------------------------------
     *
     *  DELADD   Add record to subfile for delete display
     *
     C     deladd        begsr
     C                   if        recno < 11
     C                   add       1             recno
     C                   eval      y = recno
     *
     *  Get record info
     *
     C                   eval      $pocmd = '*GET    '
     C                   eval      $pouky = wkokyu
     C                   exsr      fgtway
     *
     *  Save key to record of first screen line
     *
     C                   if        recno = 1
     C                   eval      $wkof = wkokyf
     C                   eval      $wkou = wkokyu
     C                   endif
     *
     *  Write display line to subfile
     *
     C                   exsr      zzfill
     C                   eval      option = wkoopt
     C                   write     dspsfl
     C                   write     vw2sfl
     C                   write     vw3sfl
     C                   endif
     C     delade        endsr
     *----------------------------------------------------------------
     *
     *  DELDSP   Display subfile of records marked for deletion
     *
     C     deldsp        begsr
     *
     *  Write 'Bottom/More...' Field to display
     *
     C                   write     morrec
     *
     *  Write subfile to display
     *
     C                   eval      *in81 = *on
     C                   eval      recno = 1
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  Verify and save options
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  See if user is trying to position to a certain spot
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
     C                   if        repos = *on
     C                   eval      $pofky = dsfkey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  If not positioning then execute the entered options
     *
     C                   exsr      optns
     *
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT02    Screen 2 enter key routine
     *
     C     ent02         begsr
     *
     *  Save first delete key.
     *
     C                   eval      frstky = $puky
     *
     *  Delete the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     *
     *  Display password prompt before allowing user to proceed w/delete.
     C                   exsr      zzpwrd
510 AC                   if        error = *on
510 AC                   eval      errmsg = desc(1)
510 AC                   exsr      zm0105
510 AC                   goto      ent02e
510 AC                   endif

     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   eval      *in21 = *off
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 4'
     *
     *  Call delete program
     *
     C                   exsr      inzpar
     C                   eval      $pcmd = '*DELETE '
     C                   eval      $puky = wkokyu
     C                   eval      dsfkey = wkokyu
     *
     *     If Export File Name or Member name is blank, sent error.
     C                   if           pfexpf = ' '
     C                             or pfmbr  = ' '
     C                   endif
     *
     C                   call      @delpg
     C                   parm                    $parms
     *
     *     Error occured - Error message sent back
     *
     C                   if        $prtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $prtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Delete canceled
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   else
     *
     *     Delete was successful.
     *
     C                   if        $prtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     *
     *    If ERROR flag is on due to one or more routes no
     *    longer at 'open' status, set on CANCEL.
     *
     C                   if        error = *on
     C                   eval      cancel = error
     C                   endif
     C                   exsr      scr02e
     *
     C     ent02e        endsr
     *----------------------------------------------------------------
     *
     *  ENT03    Screen 3 enter key routine
     *
     C     ent03         begsr
     *
     *  Save first option 1 key.
     *
     C                   eval      frstky = $puky
     *
     *  Perform option 1 on the records that have been selected
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     C                   eval      *in21 = *off
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     *
     C                   if        wkoopt = ' 1'
     *
     *  Call option 1 FTP program
     *
     C                   eval      $puky = wkokyu
     C                   eval      dsukey = $puky
     *
     C                   select
     *    FTP file to Check Right
     C                   when      PFFSTS = '1'

640aAC                   exsr      purgeTaxrdata

     C                   eval      $pcmd = '*SNDTRN'
     *    Call FTP program to re-send file to Check Right.
     C                   call      'CKR '
     C                   parm      pfwhse        $pwhse
     C                   parm                    $pcmd
     C                   parm      pfrtid        $prtid
     C                   parm      pfrte         $prte
     C                   parm      pftrn#        $rtrn

     C                   when      PFFSTS = '2' or
     C                             PFFSTS = '3'
     C                   eval      $pcmd = '*RESEND'
     *
     *    Call FTP program to re-send file to Check Right.
     C                   call      'CKRFTP '
     C                   parm                    $pcmd
     C                   parm      pfwhse        $pwhse
     C                   parm      pfrtid        $prtid
     C                   parm      pfrte         $prte
     C                   parm      pftrn#        $rtrn
     C                   parm      pfmbr         $pmbr
     C                   parm      pfexpf        $pfile
     C                   parm      *blanks       $rrtn
     C                   parm      *blanks       $rmsg
     C                   endsl
     *
     *     Error occured - Error message sent to program msgq
     *
     C                   if        $rrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   eval      stop = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   else
     *
     *     Option 1 was successful.
     *
     C                   if        $rrtn = '*OK     '
     C                   eval      #msgk = $pmsg
     C                   endif
     C                   endif
     C                   if        cancel = '0'
     C                   delete    wkorec
     C                   else
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   endif
     *
     C                   endif
     C                   enddo
     *
     *    If ERROR flag is on due to one or more routes no
     *    longer at 'open' status, set on CANCEL.
     *
     C                   if        error = *on
     C                   eval      cancel = error
     C                   endif
     C                   exsr      scr03e
     C     ent03e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dsukey = $pouky
     C                   exsr      zzfget
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dsfkey = $pofky
     C                   if        dsprcds = '*ERR'
     C     fileky        setll     record2
     C                   else
     C     fileky        setll     record
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INZPAR   Initialize parameters for calling add/chg/del program
     *
     C     inzpar        begsr
     C                   clear                   $parms
     C                   eval      $pprg = #prog
     C                   eval      $puky = $prtky
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     C                   eval      otaken = *off
     *
     *     Do all option 1's together.
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 1'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 1'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr03i
     C                   goto      optnse
     C                   endif
     *
     *     Do all Deletes First (Option 4)
     *
     C     wkoprt        setll     workopt
     C                   eval      stop = *off
     C     wkoprt        reade     workopt                                79
     C                   dow       not *in79  and
     C                             wkoopt <> ' 4'
     C     wkoprt        reade     workopt                                79
     C                   enddo
     C                   if        not *in79  and
     C                             wkoopt = ' 4'
     C                   eval      otaken = *on
     C                   eval      $puky = wkokyu
     C                   exsr      scr02i
     C                   goto      optnse
     C                   endif
     *
     *  Then do the other options in the order they were entered
     *     Stop when no more options or user enters Cmd12
     *
     C     wkoprt        setll     workopt
     C                   eval      cancel = *off
     C                   eval      stop = *off
     C                   dou       stop = '1'  or
     C                             cancel = '1'
     C     wkoprt        reade     workopt                                79
     C                   if        *in79
     C                   eval      stop = *on
     C                   else
     C                   if        wkoopt <> '  '
     C                   eval      otaken = *on
     C                   exsr      optns2
     C     wkounq        chain     workopt                            78
     C                   eval      refrsh = *on
     C                   if        error = '0'
     C                   delete    wkorec
     C                   endif
     C                   if        cancel = '1'
     C                   eval      stop = *on
     C                   if        error = '1'
     C                   eval      wkoerr = *on
     C                   update    wkorec
     C                   endif
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = $puky
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C                   endif
     C                   endif
     C                   enddo
     C                   if        refrsh = '1'
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   eval      refrsh = *off
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  OPTNS2   Execute individual options
     *
     C     optns2        begsr
     C                   exsr      inzpar
     C                   eval      $puky = wkokyu
     *
     *   Change
     *
     C                   if        wkoopt = ' 2'
     C                   eval      *in21 = *off
     C                   eval      dsukey = $puky
     C                   eval      $pcmd = '*CHANGE '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   View
     *
     C                   if        wkoopt = ' 5'
     C                   eval      $pcmd = '*VIEW   '
     C                   call      @chgpg
     C                   parm                    $parms
     C                   else
     *
     *   Print
     *
     C                   if        wkoopt = ' 6'
     C                   eval      $pcmd = '*PRINT  '
     C                   call      @prtpg
     C                   parm                    $parms
     C                   else
     C                   exsr      zzopt
     C                   endif
     C                   endif
     C                   endif
     *
     C     opts2e        tag
     *
     C                   if        $prtn = '*CANCEL '
     C                   eval      cancel = *on
     C                   else
     C                   if        $prtn = '*ERROR  '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   movel     $perm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $prtn = '*PGMQ   '
     C                   eval      cancel = *on
     C                   eval      error = *on
     C                   eval      #msgk = $pmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG02    Screen 2 page routines
     *
     C     pag02         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag2fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag2bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag2fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag02e        endsr
     *----------------------------------------------------------------
     *
     *  PAG03    Screen 3 page routines
     *
     C     pag03         begsr
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag3fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag3bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C     deltop        setll     workopt
     C                   eval      bot = *off
     C                   exsr      pag3fw
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
     C     pag03e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  Get 5 or 10 records to display depending on display mode.
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  Record read - Stop after 10 good records
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
     C                             and dspmode = *on
     C                             or p >= 5
     C                             and dspmode = *off
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   if        dspmode = *on
     C                   eval      goback = dsplyd + 10
     C                   else
     C                   eval      goback = dsplyd + 5
     C                   endif
     C                   if        bot = '1'
     C                   if        goback = 10
     C                             and dspmode = *on
     C                             or goback = 5
     C                             and dspmode = *off
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   eval      $kaddts=*loval
     C                   exsr      fgtway
     C                   eval      $kaddts=*hival
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  Hit top of file
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  Record read - Stop after reading 'GoBack' number of good recs
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * If the top was reached then position pointer to top of file
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  PAG2FW   Let's see that next page of delete records
     *
     C     pag2fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf2
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  Get 5 or 10 records to display based on Display Mode.
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw2
     C                   endif
     *
     *  Record read - Stop after 10 good records
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                             and dspmode = *on
     C                             or p >= 5
     C                             and dspmode = *off
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw2        tag
     C                   enddo
     *
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf2         endsr
     *----------------------------------------------------------------
     *
     *  PAG2BK   Let's see the previous page of delete records
     *
     C     pag2bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     '1'           endb2
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   if        dspmode = *on
     C                   eval      goback = dsplyd + 10
     C                   else
     C                   eval      goback = dsplyd + 5
     C                   endif
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  Hit top of file
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk2
     C                   endif
     *
     *  Record read - Stop after reading 'GoBack' number of good recs
     *
     C                   if        wkoopt = ' 4'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk2        tag
     C                   enddo
     *
     * If we hit the top Reposition pointer to top of file
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag2fw
     C     endb2         endsr
     *----------------------------------------------------------------
     *
     *  PAG3FW   Let's see that next page of delete records
     *
     C     pag3fw        begsr
     *
     *  If we are at the bottom then do nothing
     *
     C     bot           cabeq     '1'           endf3
     *
     *  Initialize variables for lookup
     *
     C                   exsr      sflclr
     C                   move      *loval        $wkof
     C                   move      *loval        $wkou
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  Get 5 or 10 records to display based on Display Mode.
     *
     C                   dou       stop = '1'
     C     wkoprt        reade     workopt                                79
     *
     *  Out of records - Inform user and set flag
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfw3
     C                   endif
     *
     *  Record read - Stop after 10 good records
     *
     C                   if        wkoopt = ' 1'
     C                   add       1             p
     C                   exsr      deladd
     C                   if        p >= 10
     C                             and dspmode = *on
     C                             or p>= 5
     C                             and dspmode = *off
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C                   endif
     C     endfw3        tag
     C                   enddo
     *
     *  Save number of records that have been displayed
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf3         endsr
     *----------------------------------------------------------------
     *
     *  PAG3BK   Let's see the previous page of delete records
     *
     C     pag3bk        begsr
     *
     *  If we are at the top then do nothing
     *
     C     top           cabeq     '1'           endb3
     C                   eval      forceb = *off
     *
     *  Calculate how many records to go backwards
     *
     C                   if        dspmode = *on
     C                   eval      goback = dsplyd + 10
     C                   else
     C                   eval      goback = dsplyd + 5
     C                   endif
     C                   if        bot = '1'
     C     wkoprt        setgt     workopt
     C                   add       1             goback
     C                   endif
     *
     *  Initialize variables for lookup
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  Read specified flitches file
     *
     C                   dou       stop = '1'
     C     wkoprt        readpe    workopt                                79
     *
     *  Hit top of file
     *
     C                   if        *in79
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk3
     C                   endif
     *
     *  Record read - Stop after reading 'GoBack' number of good recs
     *
     C                   if        wkoopt = ' 1'
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C                   endif
     C     endbk3        tag
     C                   enddo
     *
     * If we hit the top Reposition pointer to top of file
     *
     C                   if        top = '1'
     C     wkoprt        setll     workopt
     C                   endif
     C                   exsr      pag3fw
     C     endb3         endsr

640aA*----------------------------------------------------------------
640aA*  PURGETAXRDATA  Delete Taxrdata Records
640aA*
640aAC     purgetaxrdata begsr

     C     filetx        setll     ckrdata2
     C                   dou       %eof(ckrdata2)
     C     filetx        reade     ckrdata2
     C                   if        not %eof(ckrdata2)
     C                   delete    ckrrec
     C                   endif
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL02   Screen 2 roll up/down routine
     *
     C     roll02        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag02
     C                   goto      rol02e
     C                   endif
     C     rol02e        endsr
     *----------------------------------------------------------------
     *
     *  ROLL03   Screen 3 roll up/down routine
     *
     C     roll03        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag03
     C                   goto      rol03e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag03
     C                   goto      rol03e
     C                   endif
     C     rol03e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the changed options
     *
     C                   eval      nomore = *off
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   select
     C                   when      view = 1
     C                   readc     dspsfl                                 79
     C                   when      view = 2
     C                   readc     vw2sfl                                 79
     C                   when      view = 3
     C                   readc     vw3sfl                                 79
     C                   endsl
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid
     *
     C                   if        option <> *blanks
     C                   movea     option        a2
     C                   if        a2(2) = ' '
     C                   eval      a2(2) = a2(1)
     C                   eval      a2(1) = ' '
     C                   movea     a2            option
     C                   endif
     *
     *    Look up option in profile - Error if not found
     *
     C     option        lookup    zopt                                   50
     C                   if        not *in50
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     C                   endif
     *
     *  Save option
     *
     C                   select
     C                   when      view = 1
     C                   eval      y = recno
     C                   when      view = 2
222 MC                   eval      y = recno
     C                   when      view = 3
222 MC                   eval      y = recno
     C                   endsl
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   eval      wkoopt = option
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   if        reccnt < 11
     C                             and dspmode = *on
     C                             or reccnt < 6
     C                             and dspmode = *off
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   eval      y = reccnt
     *
     *  Save file and unique keys
     *
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
     *
     *  Write display line to subfile
     *
     C                   exsr      zzfill
     C                   write     dspsfl
     C                   write     vw2sfl
     C                   write     vw3sfl
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  Clear display subfile
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     *
     C                   write     dspsfc
     C                   write     vw2sfc
     C                   write     vw3sfc
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     C                   eval      recno = 0
     *
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  Write option and command lines to display
     *
501 DC**                 write     optrec
     C                   write     cmdrec
     *
     *  Write 'Bottom/More...' field to display
     *
     C                   write     morrec
     *
     *  Write Position To field to display
     *
501 DC**                 write     postnrec
     *
     *  Get any existing values for the options
     *
     C                   exsr      sflopt
     *
     *  Position cursor to first option when no errors exist
     *
     C                   if        error <> '1'
     C                   select
     C                   when      view = 1
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   when      view = 2
     C     1             chain     vw2sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    vw2sfl
     C                   endif
     C                   when      view = 3
     C     1             chain     vw3sfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    vw3sfl
     C                   endif
     C                   endsl
     C                   endif
     *
     *  Write subfile to display
     *
     C                   eval      *in81 = *on
     C                   eval      recno = posrec
     C                   select
     C                   when      view = 1
     C                   write     dspsfc
     C                   when      view = 2
     C                   write     vw2sfc
     C                   when      view = 3
     C                   write     vw3sfc
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
     C     1             do        dsplyd        x
     C                   select
     C                   when      view = 1
     C     x             chain     dspsfl                             79
     C                   when      view = 2
     C     x             chain     vw2sfl                             79
     C                   when      view = 3
     C     x             chain     vw3sfl                             79
     C                   endsl
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   eval      option = wkoopt
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   select
     C                   when      view = 1
     C                   update    dspsfl
     C                   when      view = 2
     C                   update    vw2sfl
     C                   when      view = 3
     C                   update    vw3sfl
     C                   endsl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   write     msgclr
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
     C                   parm      #prog         #pgmq
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
     *R                   WRITECLRSCR
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      '*PREV'       #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0001  Option under construction.
     *
     C     zm0001        begsr
     C                   eval      #msgid = 'PIR0001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0101  Program not found.
     *
     C     zm0101        begsr
     C                   eval      #msgid = 'PIR0101'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0102  Program not found.
     *
     C     zm0102        begsr
     C                   eval      #msgid = 'PIR0102'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0103  Program not found while exec. subroutine.
     *
     C     zm0103        begsr
     C                   eval      #msgid = 'PIR0103'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *
     *  ZZCMD    Process non-standard function keys
     *
     C     zzcmd         begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Warehouse number.
     *
     C                   if        row# = 4  and
     C                             col# >= 48
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      ptinp1 = $lwhse
     C                   endif
     C                   else
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endif
     C                   goto      endcm1
     C                   endif
     *
     *  Test for CMD8 - Switch FTP Status views
     *
     C                   if        *inkh
     *
     C                   if        dsprcds = '*ERR'
     C                   eval      dsprcds = '*ALL'
     C                   eval      curview = f8_view1
     C                   eval      $kaddts  = *hival
     C                   eval      pfaddts  = *hival
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt2:cmdln1:36:14)
     C                   endif
     C                   else
     C                   eval      dsprcds = '*ERR'
     C                   eval      curview = f8_view2
     C                   eval      $kaddts  = *hival
     C                   eval      pfaddts  = *hival
     C                   if        %subst(cmdln1:33:3) = 'F8='
     C                   eval      cmdln1 = %Replace(f8_txt1:cmdln1:36:14)
     C                   endif
     C                   endif
     *    Reposition display to Top.
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      $kaddts= *hival
     C                   eval      $krte  = *blanks
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     *
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFGET   Get record with unique key.
     *
     C     zzfget        begsr
     *
     *    Code to use when file key and unique key are the same.
     *
     C                   if        dsprcds = '*ERR'
     C     fileky        chain     record2                            79
     C                   else
     C     fileky        chain     record                             79
     C                   endif
     *
     *    Code to use when file key and unique key are different.
     *
     *R         FILUKY    CHAINRECORDU              79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        dsprcds = '*ERR'
     C     partky2       reade     record2                                79
     C                   else
     C     partky2       reade     record                                 79
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        dsprcds = '*ERR'
     C     partky2       readpe    record2                                79
     C                   else
     C     partky2       readpe    record                                 79
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
     *
     *   FTP Status description
     *
     C                   move      pffsts        p1
     C                   eval      w1stat = stat(p1)
     *
     *   FTP Type description
     *
     C*                  move      pftype        p2
     C                   eval      w1type = type(1)
     *
     *   FTP Error message. Split to fit on two lines.
     *
     C                   eval      w1fmsg1 = %subst(pffmsg:1:40)
     C                   eval      w1fmsg2 = %subst(pffmsg:41:25)
     *
     *   Created date
     *
     C                   If        pfaddts <> dftstamp
     *     Convert datestamp to date/time output fields.
     C                   move      pfaddts       datestamp
     C                   move      pfaddts       timestamp
     C     *mdy          move      datestamp     w2crtd
     C                   eval      w2crtt = timestamp
     C                   Else
     C                   eval      w2crtd = 0
     C                   eval      w2crtt = *loval
     C                   Endif
     *
     *   Exported date
     *
     C                   If        pfexpts <> dftstamp
     *     Convert datestamp to date/time output fields.
     C                   move      pfexpts       datestamp
     C                   move      pfexpts       timestamp
     C     *mdy          move      datestamp     w2expd
     C                   eval      w2expt = timestamp
     C                   Else
     C                   eval      w2expd = 0
     C                   eval      w2expt = *loval
     C                   Endif
     *
     *   Last exported date
     *
     C                   If        pflexts <> dftstamp
     *     Convert datestamp to date/time output fields.
     C                   move      pflexts       datestamp
     C                   move      pflexts       timestamp
     C     *mdy          move      datestamp     w2lstd
     C                   eval      w2lstt = timestamp
     C                   Else
     C                   eval      w2lstd = 0
     C                   eval      w2lstt = *loval
     C                   Endif
     *
510 AC                   eval      ptstat = *blanks
510 AC     pftrn#        chain     pirtran
510 AC                   if        %found(pirtran)
510 AC                   eval      w2stat = ptstat
510 AC                   endif
510 A*
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      forevr = *on
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    pfwhse
     C                   kfld                    pfaddts
     C                   kfld                    pfrte
     C                   kfld                    pfrtid
510 AC                   kfld                    pftrn#
     C                   kfld                    pftype
     *
     *  Define UNIQ key for main file.
     *
     C     filuky        klist
     C                   kfld                    pfwhse
     C                   kfld                    pfaddts
     C                   kfld                    pfrte
     C                   kfld                    pfrtid
510 AC                   kfld                    pftrn#
     C                   kfld                    pftype
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kaddts
     C                   kfld                    $krte
     C     partky2       klist
     C                   kfld                    $kwhse
640aA*
640aA*  Define key for ckrdata.
640aA*
640aAC     filetx        klist
640aAC                   kfld                    pfwhse
640aAC                   kfld                    pfrte
640aAC                   kfld                    pftrn#
     *
     *  Setup option and command display lines.
     *
     C                   eval      view = 1
     C                   eval      maxvw = 3
     C                   eval      optln1 = optln(1)
     C                   eval      optln2 = optln(2)
     C                   eval      cmdln1 = cmdln(1)
     C                   eval      cmdln2 = cmdln(2)
     C                   eval      cmdln1 = %Replace(f8_txt1:cmdln1:36:14)
     C                   eval      curview = f8_view2
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Extra program initialization. Called from *INZSR.
     *
     C     zzinz2        begsr
     C                   eval      $kaddts  = *hival
     C                   eval      pfaddts  = *hival
     C                   eval      pfexpts  = *loval
     C                   eval      pflexts  = *loval
     C                   eval      dftstamp = *loval
     *
     *   Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     pfwhse        parm      0             #whse             3 0
     *
     *   Verify warehouse and get description.
     *
     C                   eval      whcode = pfwhse
     C                   eval      whdesc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = pfwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     C                   eval      $kwhse = pfwhse
     C                   eval      whcode = pfwhse
     C                   movel     $lerm         whdesc
     C                   endif
     C                   endif
     *
     C                   exsr      clrsch
     C                   eval      dspmode = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dsfkey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dsukey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPWRD   Get password
     *
     C     zzpwrd        begsr
     C                   eval      w1pwrd = ' '
     *
     C                   exfmt     paswrd
     C                   if        w1pwrd <> '*DELETE'
     C                   eval      stop = *on
     C                   eval      error = *on
     C                   eval      cancel = *on
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPT    Process non-standard options.
     *              Note: Error handling is done in routine OPTNS2.
     *
     C     zzopt         begsr
     C                   select
     *
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to change warehouse.
     *
     C                   if        ptinp1 <> 0
     *
     *      Verify warehouse entry.
     *
     C                   eval      whcode = ptinp1
     C
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = ptinp1
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   goto      endzps
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   goto      endzps
     C                   else
     C                   eval      pfwhse = ptinp1
     C                   eval      $kwhse = pfwhse
     C                   eval      $kaddts= *hival
     C                   eval      pfaddts= *hival
     C                   eval      pfrte = *blanks
     C                   eval      pfrtid = *blanks
510 AC                   eval      pftrn# = *zeros
     C                   eval      whcode = ptinp1
     C                   movel     $lerm         whdesc
     C                   eval      ptinp1 = 0
     C                   eval      repos = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to Created Date.
     *
     C                   if        ptinp2 <> *zeros
     C     *mdy          test (de)               ptinp2
     C                   if        %error
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = errmsg01
     C                   exsr      zm0105
     C                   else
     C                   eval      currstamp= *hival
     C     *mdy          move      ptinp2        curr_date
     C                   eval      pfaddts  = currstamp
     C                   eval      $kaddts  = currstamp
     C                   eval      $krte    = *blanks
     C                   eval      pfrte    = *blanks
     C                   eval      pfrtid   = *blanks
510 AC                   eval      pftrn#   = *zeros
     C                   eval      ptinp2   = *zeros
     C                   eval      repos   = *on
     C                   endif
     C                   endif
     *
     *  See if user is trying to position to Route Number
     *
     C                   if        ptinp3 <> *blanks
     C                   eval      $krte = ptinp3
     C                   eval      pfrte = ptinp3
     C                   eval      pfrtid = *blanks
     C                   eval      ptinp3 = *blanks
     C                   eval      repos = *on
     C                   endif
     C     endzps        endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   select
     C                   when      $pocmd = '*TOP'
     C                   if        dsprcds = '*ERR'
     C     partky        setgt     record2
     C                   else
     C     partky        setgt     record
     C                   endif
     *
     C                   when      $pocmd = '*BOTTOM'
     C                   if        dsprcds = '*ERR'
     C     partky        setll     record2
     C                   else
     C     partky        setll     record
     C                   endif
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**  ZOPT - Valid options
 1 4
**  OPTLN - Option display line
  1=Resend FTP file  4=Clear FTP error

**  CMDLN - Command display line
F3=Exit  F4=Prompt  F5=Refresh  F8=                F9=Fold  F12=Cancel
F10=View 3  F11=View 2  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=                F9=Fold  F12=Cancel
F10=View 1  F11=View 3  F17=Top  F18=Bottom  F20=Move to top
F3=Exit  F4=Prompt  F5=Refresh  F8=                F9=Fold  F12=Cancel
F10=View 2  F11=View 1  F17=Top  F18=Bottom  F20=Move to top
**  Type - FTP Host Type Code
Check Right
**  STAT - FTP status codes
FTP not started
FTP in progress
FTP failed
FTP complete
Deleted
**  Error messages
Invalid password
