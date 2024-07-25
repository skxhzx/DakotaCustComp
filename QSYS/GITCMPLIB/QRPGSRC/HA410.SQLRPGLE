      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  HA410     HACCP Question/Answer Entry
     *  Lynn McMahon
     *
     *  Revisions
     *    02/27/12  LMC  6.40
     *      - Enh: New Program
     *    08/15/12  LMC  6.40a
     *      - Fix: Super Po logic for RCVI and once per po frequency
640bA*    08/31/12  LMC  6.40b
     *      - Enh: Add logic to handle two receivers presented with
     *        the same questions before either one has entered answers.
     *        The last person to answer the questions will be the
     *        active answer record, and others will be marked obsolete.
640cA*    12/04/12  LMC  6.40c
     *      - Fix: changed zzchklog to sql instead of chain.
     *      When a po header log record already exist in the file and
     *      has been exported, the chain was finding the first record.
     *      That record was already exported, so the program was
     *      assuming it should ask the header question again. When in
     *      fact the question had already been answered for this po
     *      and that receipt of the po had not been exported. The
     *      chain was not finding that record.
650aA*    01/02/13  LMC  6.50a
     *      - Enh: Store the vendor number in haccplog field hlcust.
650bA*    03/22/13  LMC  6.50b
     *      - Enh: Added haccp cross reference file attaching the
     *      license to the haccp log records if RCVI and frequency of
     *      question is everytime.
650cA*    04/13/13  LMC  6.50c
     *      - Enh: Added REXI level for receiving exceptions.
650dA*    07/15/13  LMC  6.50d
     *      - Enh: Additional requirements for Super PO.
     *      Check for new po added to super po. If a new po exist
     *      Questions/answers need to be tied to the new PO's only.
650eA*    01/31/14  LMC  6.50e
     *      - Enh: F12 from first page should act lik F3.
650fA*    03/28/14  LMC  6.50f
     *      - Enh: Don't use vendor number in haccplog field hlcust.
     *      on user controlled questions - only PO receiving questions
     *      Use Po field in file to store equiment Id.
650gA*    08/07/14  LMC  6.50g
     *      - Fix: Warning was not displaying when multiple range
     *      questions existed and the last one passed the edits.
     *      - Enh: Reposition the cursor to the line user took F4.
650hA*    01/19015  LMC  6.50h
     *      - Fix: Change edit code to N on answer type 8 so zero is
     *      written to haccplog instead of blank.
720a *    08/22/18  LMC  7.20a
     *      - Need to init new stop field.
730aA*    04/22/19  LMC  7.30a
     *      - Added first record only. We are getting duplicates from
     *        the super po process. This is a temporary fix, until I
     *        can correct the loading program. This fix can stay it
     *        will not hurt anything.
740aA*    05/19/20  LMC  7.40a
     *      - Enh: Do Not process child questions. That feature is
     *      only available in gui. changed from using haccpq3 to
     *      new file haccpq5, which excludes reactive questions.
     *----------------------------------------------------------------
     *  Client Custom Revisions
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  51 - 92   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

650gDF*ha410fm   cf   e             workstn
650gMFha41001   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     fhaccplog1 uf a e           k disk
     fhaccplog2 if   e           k disk    rename(hlrec:hl3) prefix(h3_)
740aDF*haccpq3   if   e           k disk
740aMFhaccpq5   if   e           k disk
     Fhaccpqt   if   e           k disk
     Fhaccpv2   if   e           k disk
     Fpospo     if   e           k disk
     Fpospo1    if   e           k disk    rename(purec:spurec)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D aseq            s              5  0 dim(10)
     D atype           s              1    dim(10)
     D atype1          s             30    dim(10)
     D atype2          s              1    dim(10)
     D atype3          s             30    dim(10)
     D atype4          s             20    dim(10)
     D atype5          s              9  2 dim(10)
     D atype6          s              9  2 dim(10)
     D atype7          s              6  0 dim(10)
     D atype8          s             15  0 dim(10)
     D atype9          s             15  0 dim(10)
     D stime           s             26Z   dim(10)
650bAD stimeuc         s             26Z   dim(10)
     D stype1          s             30    dim(10)
     D stype2          s              1    dim(10)
     D stype3          s             30    dim(10)
     D stype4          s             20    dim(10)
     D stype5          s              9  2 dim(10)
     D stype6          s              9  2 dim(10)
     D stype7          s              6  0 dim(10)
     D stype8          s             15  0 dim(10)
     D stype9          s             15  0 dim(10)
     D avseq           s              5  0 dim(10)
     D desc            s             20    dim(5) ctdata perrcd(1)
     * These array hold previous page starting points for f12 processing
     D pmoreq          s              1    dim(100)
     D pmoret          s              1    dim(100)
     D pcode           s             15    dim(100)
     D psavet          s              3    dim(100)
     D psaveh          s              5  0 dim(100)
     D psavep          s              1    dim(100)
     D plevel          s              4    dim(100)
     D ptype           s              3    dim(100)
     D ppge#           s              5  0 dim(100)
     D ppgsq           s              2  0 dim(100)
     * These hold warning message information
     D ws2qstn         s             45    dim(10)
     D ws2answ         s             20    dim(10)
     D ws2valu         s             35    dim(10)
     D ws2warn         s             30    dim(10)
     D ws2ovrd         s              1    dim(10)
      *
650bAD $parms1         s             48    dim(20)
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
     D  $plevel               22     25
     D  $license              26     40
     D  $ppo                  41     49
     D  $pposeq               50     54  0
     D  $ptype                55     57
     D  $pspo                 58     61
     *
650bAD $p1parms1       ds
650bAD  $p1whse                1      3
650bAD  $p1po                  4     12
650bAD  $p1poseq              13     17
650bAD  $p1qstseq             18     22
650bAD  $p1uctime                      z
     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $ltbldata             19     38
     D  $lwhse                19     21  0
     D  $litem                22     36
     *
     D* $lldcn                19     20
     D  $lprda                19     23
     D  $lprdt                19     23
     *
     d  $llevl                22     25
     D  $ltype                26     28
     D  $lcode                29     43
     D  $lseq#                44     48  0
     d
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  eritem                 1     15
     *
     D  erpo                   1      9
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     * Get Category return status message
     *
     D nfound          c                   const('*NOTFOUND*')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  File field data structure.
     *----------------------------------------------------------------

     D haccplog      e ds
640bAD haccplogck    e ds                  extname(haccplog) prefix(ck_)
     D haccps        e ds
     D itemfld       e ds
     D licactive     e ds
     D piritem       e ds
     D pohdr         e ds
     D haccpq        e ds                  prefix(s_)
650bAD haccpxrf      e ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

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
     *
     *----------------------------------------------------------------
     *  Variables
     *
     D w1hdtec         s              8  0
     D $keyseq         s              5  0
     D $phdte          s              8  0
     D $code           s             15
     D comand          s              5  0
     D currstamp       s               z
     D rolldn          s              5  0
     D rollup          s              5  0
     D help            s              5  0
     D $pseq           s              5  0
     D msgk            s              4  0
     D e               s              2  0
     D $phloc          s             20
     D $pcert          s             20
     D $msgf           s             10
     D #pgmq           s             10
     D $pprt           s             10
     D $pform          s             10
     D $type           s              3
     D cmdchk          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D $pwhsa          s              3
     D nxtscr          s              3
     D edtq            s              2  0
     D first           s              1
     D forevr          s              1
     D foundvalue      s              1
     D hldspecdesc     s                   like(#lvdsc1)
     D morelicense     s              1
     D moretypes       s              1
     D morequestions   s              1
650dAD newpo           s              1
     D off8190         s             10    inz('0000000000')
650dAD poadded         s              1
     D prvscn          s              1
     D qstnseq#        s                   like(hiseq#)
     D savehipge#      s              5  0
     D savelicense     s                   like(w1lcns)
     D savepage        s              1
     D savetime        s               z
650bAD savetimeuc      s               z
     D savetype        s              3
     D sclear          s              1
     D t3parm          s             30
     D t5parm1         s              9  2
     D t5parm2         s              9  2
     D t8parm1         s             15  0
     D t8parm2         s             15  0
     D today           s              1
     D w               s              2  0
     D warnmore        s              1
     D whdesc          s                   like(#whdesc)
     D wodesc          s                   like(#wodesc)
     D work1a          s              1
     D worktype5       s              9  2
     D wrtq            s              2  0
     D whpg            s              3  0
     D holdwhpg        s              3  0
     D cmdtkn          s              1
     D seq0            s                   like($pseq)
     D xedit           s              2  0
650bAD xx              s              2  0
600fA*----------------------------------------------------------------
600fA*  Time variables
600fA*----------------------------------------------------------------
600fA
600fAD CurrStamploc    s               z
600fAD CurrStampsys    s               z
600fAD CurrStampuc     s               z
600fA
600fAD bfcoffset       s              3  0 inz(0)
600fA*----------------------------------------------------------------
600fA* Function prototypes.
600fA*----------------------------------------------------------------
600fA
600fA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D cktabl          pr                  extpgm(S_HITABL)
      * Input
     D   pparm                       80

     D hv900           pr                  extpgm('HV900')
      * Input
     D   pparm                       80
     D   pt3parm                           like(t3parm)
     D   pt5parm1                          like(t5parm1)
     D   pt5parm2                          like(t5parm2)
     D   pt8parm1                          like(t8parm1)
     D   pt8parm2                          like(t8parm2)

     C/EXEC SQL SET OPTION DatFmt = *ISO
     C/End-Exec
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ITEM    - Capture HACCP info at item number lvl
     *      $PPRG   Program to send messages back to.
     *
     *    Returned Parameters
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
650bAC                   parm                    $parms1
     *----------------------------------------------------------------
     *  Main line
     *
      /free

        *in97 = *on;
        error = *off;
        warn = *off;
        $prtn = ' ';
        $perm = ' ';
        exsr zzinz2;
        if  error = '1';
          nxtscr = 'EOJ';
        endif;

        dow nxtscr <> 'EOJ';
          exsr dspscr;
          select;
            when nxtscr = '01';
             exsr sc1;
            when nxtscr = '02';
             exsr sc2;
          endsl;
        enddo;
        // Do some clean up before leaving
        exsr zsclr;
        eval *inlr = *on;
      /end-free
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
      /free
       begsr dspscr;

         // Set ON alarm indicator if error occured

         if error = '1';
           *in98 = *on ;
         endif;

         // Set ON Heading indicator

         if $plevel = 'RCVH';
           *in93 = *on ;
         endif;

         // Overlay screen with error messages

         exsr zmdmsg;

         // Overlay screen screen to be processed.

         if nxtscr = '01 ';
           if #q1 <> ' ';
             exfmt screen1;
             savepage = *off;
           endif;
         endif;
         if nxtscr = '02 ';
             // need to load up first warning screen
             for W = 1 to 10;
               if ws2qstn(W) <> ' ' and ws2ovrd(w) <> 'Y';
                 exsr loadwarning;
                 leave;
               endif;
             endfor;
             exfmt screen2;
         endif;

         // Initialize error indicators and fields

         error = *off;
         cmdtkn = *off;
         e = 0;

         // Initialize error subfile

         exsr zmcmsg;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

      /free
       begsr scr01i;
         nxtscr = '01 ';

         // Get field defaults if this is an add.

         if $pcmd = '*ADD    ';
           exsr zzdft1;
         else;

           // Otherwise get exsiting record(s).

           *in91 = *on;
           exsr zzget1;
           exsr zzclr1;
           exsr zzfil1;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1 - Entry screen for questions
     *----------------------------------------------------------------

      /free
        begsr sc1;

          // test for F3 - Exist

          if *inkc  and $plevel <> 'RCVL';
            nxtscr = 'EOJ';
            $prtn = '*EXIT   ';
            leavesr;
          endif;

          if *inkc  and $plevel = 'RCVL';
            leavesr;
          endif;

          // test for F4 - prompt

          if *inkd;
            exsr zzclrerr;
            cmdtkn = *on;
            row# = 0;
            row = rowin;
            col# = 0;
            col = colin;
            $lcmd = ' ';
            s_hitabl = ' ';
            s_hiatyp = ' ';
650gA       *in71 = *off;
650gA       *in72 = *off;
650gA       *in73 = *off;
650gA       *in74 = *off;
650gA       *in75 = *off;
650gA       *in76 = *off;
650gA       *in77 = *off;
650gA       *in78 = *off;
650gA       *in79 = *off;
650gA       *in80 = *off;
            select;
              when row# = 10;
                qstnseq# = aseq(1);
650gA           *in71 = *on;
              when row# = 11;
                qstnseq# = aseq(2);
650gA           *in72 = *on;
              when row# = 12;
                qstnseq# = aseq(3);
650gA           *in73 = *on;
              when row# = 13;
                qstnseq# = aseq(4);
650gA           *in74 = *on;
              when row# = 14;
                qstnseq# = aseq(5);
650gA           *in75 = *on;
              when row# = 15;
                qstnseq# = aseq(6);
650gA           *in76 = *on;
              when row# = 16;
                qstnseq# = aseq(7);
650gA           *in77 = *on;
              when row# = 17;
                qstnseq# = aseq(8);
650gA           *in78 = *on;
              when row# = 18;
                qstnseq# = aseq(9);
650gA           *in79 = *on;
              when row# = 19;
                qstnseq# = aseq(10);
650gA           *in80 = *on;
              other;
            endsl;
            exec sql select * into :haccpq
                     from haccpq
                     where hiwhse = :$pwhse
                       and hiseq# = :qstnseq#;
            if sqlstt = sqlSuccess;
              $lcmd = '*SELECT ';
            endif;
            if s_hiatyp = '4';
              ckTABL($lparm);
              if $lrtn = '*SELECT ';
                select;
                  when row# = 10;
                    #a103 = $ltbldata;
                  when row# = 11;
                    #a203 = $ltbldata;
                  when row# = 12;
                    #a303 = $ltbldata;
                  when row# = 13;
                    #a403 = $ltbldata;
                  when row# = 14;
                    #a503 = $ltbldata;
                  when row# = 15;
                    #a603 = $ltbldata;
                  when row# = 16;
                    #a703 = $ltbldata;
                  when row# = 17;
                    #a803 = $ltbldata;
                  when row# = 18;
                    #a903 = $ltbldata;
                  when row# = 19;
                    #a003 = $ltbldata;
                  other;
                endsl;
              endif;
            endif;
            if s_hiatyp = '3';
              $lwhse = s_hiwhse;
              $llevl = s_hilevl;
              $ltype = s_hitype;
              $lcode = s_hicode;
              $lseq# = s_hiseq#;
              t5parm1 = 0;
              t5parm2 = 0;
              t8parm1 = 0;
              t8parm2 = 0;
              hv900($lparm :t3parm :t5parm1 :t5parm2 :t8parm1 :t8parm2);
              if $lrtn = '*SELECT ';
                select;
                  when row# = 10;
                    #a101 = t3parm;
                  when row# = 11;
                    #a201 = t3parm;
                  when row# = 12;
                    #a301 = t3parm;
                  when row# = 13;
                    #a401 = t3parm;
                  when row# = 14;
                    #a501 = t3parm;
                  when row# = 15;
                    #a601 = t3parm;
                  when row# = 16;
                    #a701 = t3parm;
                  when row# = 17;
                    #a801 = t3parm;
                  when row# = 18;
                    #a901 = t3parm;
                  when row# = 19;
                    #a001 = t3parm;
                  other;
                endsl;
              endif;
            endif;

            if s_hiatyp = '5';
              $lwhse = s_hiwhse;
              $llevl = s_hilevl;
              $ltype = s_hitype;
              $lcode = s_hicode;
              $lseq# = s_hiseq#;
              t3parm = ' ';
              t5parm1 = 0;
              t5parm2 = 0;
              t8parm1 = 0;
              t8parm2 = 0;
              hv900($lparm :t3parm :t5parm1 :t5parm2 :t8parm1 :t8parm2);
              if $lrtn = '*SELECT ';
                if t5parm2 = 0;
                  select;
                    when row# = 10;
                      #a104 = t5parm1;
                    when row# = 11;
                      #a204 = t5parm1;
                    when row# = 12;
                      #a304 = t5parm1;
                    when row# = 13;
                      #a404 = t5parm1;
                    when row# = 14;
                      #a504 = t5parm1;
                    when row# = 15;
                      #a604 = t5parm1;
                    when row# = 16;
                      #a704 = t5parm1;
                    when row# = 17;
                      #a804 = t5parm1;
                    when row# = 18;
                      #a904 = t5parm1;
                    when row# = 19;
                      #a004 = t5parm1;
                    other;
                  endsl;
                endif;
              endif;
            endif;

            if s_hiatyp = '8';
              $lwhse = s_hiwhse;
              $llevl = s_hilevl;
              $ltype = s_hitype;
              $lcode = s_hicode;
              $lseq# = s_hiseq#;
              t3parm = ' ';
              t5parm1 = 0;
              t5parm2 = 0;
              t8parm1 = 0;
              t8parm2 = 0;
              hv900($lparm :t3parm :t5parm1 :t5parm2 :t8parm1 :t8parm2);
              if $lrtn = '*SELECT ';
                if t8parm2 = 0;
                  select;
                    when row# = 10;
                      #a106 = t8parm1;
                    when row# = 11;
                      #a206 = t8parm1;
                    when row# = 12;
                      #a306 = t8parm1;
                    when row# = 13;
                      #a406 = t8parm1;
                    when row# = 14;
                      #a506 = t8parm1;
                    when row# = 15;
                      #a606 = t8parm1;
                    when row# = 16;
                      #a706 = t8parm1;
                    when row# = 17;
                      #a806 = t8parm1;
                    when row# = 18;
                      #a906 = t8parm1;
                    when row# = 19;
                      #a006 = t8parm1;
                    other;
                  endsl;
                endif;
              endif;
            endif;
            leavesr;
          endif;

        // Test for F5 - Refresh

        if *inke;
          if $pcmd <> '*VIEW   ';
            exsr scr01i;
          endif;
          leavesr;
        endif;

        // Test for F12 - Previous

650eA   if *inkl  and $plevel <> 'RCVL' and whpg <=1;
650eA     nxtscr = 'EOJ';
650eA     $prtn = '*EXIT   ';
650eA     leavesr;
650eA   endif;

        if *inkl;
          exsr rstpageinfo;
          exsr scr01i;
          $prtn = '*CANCEL ';
          leavesr;
        endif;

        exsr zzchk1;
        if error = '1';
          leavesr;
        endif;
        if warn = *on;
          nxtscr = '02 ';
          leavesr;
        endif;
        exsr zzupd1;
        if error = '1';
          leavesr;
        endif;

        // If more questions or types, load screen again
        if moretypes = 'Y' or morequestions = 'Y'
           or holdwhpg <> whpg and prvscn = 'Y';
          exsr scr01i;
          leavesr;
        endif;

        // If *podtlch and morelicense = 'Y'
        if $pcmd = '*PODTLCH' and morelicense = 'Y';
          exsr zzinz2;
          if morelicense = 'Y';
            leavesr;
          endif;
        endif;

        // Everything went fine so get our of the program.
        nxtscr = 'EOJ';
        endsr;
      /end-free

     *----------------------------------------------------------------
     *  SC2  -  Screen 2 - Warning screen process
     *----------------------------------------------------------------

      /free
        begsr sc2;

          // Test for F3 - Exit

          // Test for F4 - Prompt

          // Test for F5 - Refresh

          // Test for F12 - Previous
          if *inkl;
            nxtscr = '01';
            leavesr;
          endif;

          // Test for F10 - Override
          if *inkj;
            exsr zzchk2;
            if warnmore = '1';
              leavesr;
            endif;
            exsr zzupd1;
            if error = '1';
              leavesr;
            endif;
            // If more questions or types, load screen again
            if moretypes = 'Y' or morequestions = 'Y'
               or  holdwhpg <> whpg and prvscn = 'Y';
              exsr scr01i;
              leavesr;
            endif;
            // If *podtlch and morelicense = 'Y'
            if $pcmd = '*PODTLCH' and morelicense = 'Y';
              exsr zzinz2;
              if morelicense = 'Y';
                leavesr;
              endif;
            endif;

            nxtscr = 'EOJ';
          endif;
        endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     *----------------------------------------------------------------
      /free
        begsr *inzsr;
          // Initialize special keys
          comand = 2;
          rollup = 01122;
          rolldn = 01123;
          help = 01125;
          // Initialize message handling
          exsr zmimsg;
          // Call user added initialization routine.
          exsr zzinz;
        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     *---------------------------------------------------------------
      /free
        begsr zmcmsg;
          *in97 = *off;
          write msgctl;
          msgk = 0;
          write msgclr;
          #msgid = '*CLEAR ';
          #msgtp = '*NULL  ';
          exsr zmpmsg;
        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZMDMSG  Display message record subfile
     *
     *---------------------------------------------------------------
      /free
        begsr zmdmsg;
          *in97 = *on;
          if msgk > 0;
            write msgctl;
            msgk = 0;
          endif;
        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     *---------------------------------------------------------------
      /free
        begsr zmimsg;
          #pgmq = #prog;
          exsr zmcmsg;
        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZMPMSG  Add message record to subfile
     *
     *---------------------------------------------------------------
      /free
        begsr zmpmsg;
          if $msgf = ' ';
            $msgf = #msgf;
          endif;
      /end-free
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm                    #pgmq
     c                   parm                    #msgk
      /free
          if #msgid <> '*CLEAR ';
            msgk = msgk + 1;
            write msgrec;
          endif;
          #msgdt = ' ';
          $msgf = ' ';
        endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     *---------------------------------------------------------------
      /free
         begsr zmqmsg;
           msgk = msgk + 1;
           write msgrec;
         endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     *---------------------------------------------------------------
      /free
         begsr zsclr;
           write clrscr;
           sclear = *on;
         endsr;
      /end-free
     *---------------------------------------------------------------
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     *---------------------------------------------------------------
      /free
         begsr zmsmsg;
           if $msgf = ' ';
             $msgf = #msgf;
           endif;
      /end-free
     c
     c                   call      'PUTMSG'
     c                   parm                    $msgf
     c                   parm                    #msgid
     c                   parm                    #msgtp
     c                   parm                    #msgdt
     c                   parm      $pprg         #pgmq2           10
     c                   parm                    #msgk             4
      /free
           #msgdt = ' ';
           $msgf = ' ';
         endsr;
      /end-free
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *   PIR9905  Cursor not in correct position for lookup.
     *
      /free
       begsr zm9905;
         #msgid = 'PIR9905';
         #msgtp = '*DIAG  ';
         $md = ' ';
         exsr zmpmsg;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *   PIR1001  Invalid option entered.
     *
      /free
       begsr zm1001;
         #msgid = 'PIR1001';
         #msgtp = '*DIAG  ';
         $md = errmsg;
         exsr zmpmsg;
       endsr;
      /end-free
500 A*----------------------------------------------------------------
500 A*   PIR0203  Field can not be blank
500 A*
500 AC     zm0203        begsr
500 AC                   eval      #msgid = 'PIR0203'
500 AC                   eval      #msgtp = '*DIAG  '
500 AC                   movea     errmsg        $md
500 AC                   exsr      zmpmsg
500 AC                   endsr

     *----------------------------------------------------------------
     *  Loadnewpolog  Loads new po log records
     *----------------------------------------------------------------
      /free
       begsr loadnewpolog;
         // Now write the new log record
         hlwhse = $pwhse;
         hlseq# = aseq(wrtq);
         hlpcmd = $pcmd;
         hllevl = s_hilevl;
         hltype = s_hitype;
         hlobsolete = ' ';
         hlchgts = *loval;
         hlchguc = *loval;
         hlchgcpgm = ' ';
         hlchgjpgm = ' ';
         hlchgeusr = ' ';
         hlexpts = *loval;
         hlexpuc = *loval;
         hlexpjusr = ' ';
         exsr zzgettime;
         hladdts = currstampsys;
         hladduc = currstampuc;
         hladdcpgm = $pprg;
         hladdjpgm = #prog;
         hladdeusr = #user;
         if $pcmd = '*POHDRCH';
         else;
           hlsid = hpsid;
         endif;
         hlpo = $ppo;
         hlspo = ' ';
         if $pspo = '*YES' and $plevel = 'RCVH';
           hlpo = pupo;
           hlspo = $ppo;
           exsr zzgetvendor;
         endif;
640aA    if $pspo = '*YES' and $plevel <> 'RCVH' and s_hifreq = '2';
640aA      hlpo = pupo;
640aA      hlspo = puspo;
640aA      exsr zzgetvendor;
640aA    endif;
640aD    //if $pspo = '*YES' and $plevel = 'RCVI';
640aD      // $plevel = 'RCVL';
640aD      //exsr zzgetsuperpo;
640aD      //hlspo = puspo;
640aD    //endif;
         hlname = PHVNAM;
         hllcns = w1lcns;
         // don't store item if question are once for po or session at the
         // CAT,DPT or ALL types.
         select;
           when s_hifreq = '2' and s_hitype = 'CAT' and s_hilevl = 'RCVI' or
                s_hifreq = '3' and s_hitype = 'CAT' and s_hilevl = 'RCVI' or
                s_hifreq = '2' and s_hitype = 'DPT' and s_hilevl = 'RCVI' or
                s_hifreq = '3' and s_hitype = 'DPT' and s_hilevl = 'RCVI' or
                s_hifreq = '2' and s_hitype = 'ALL' and s_hilevl = 'RCVI' or
                s_hifreq = '3' and s_hitype = 'ALL' and s_hilevl = 'RCVI';
             hlitem = ' ';
             hlposeq = 0;
           other;
             hlitem = w1item;
             hlposeq = $pposeq;
         endsl;
         hlrte = ' ';
         hlord = 0;
650aD    //hlcust = 0;
650aM    hlcust = phven;
         hlcord = 0;
         hloseq = 0;
         // check for warning override
         if ws2qstn(wrtq) <> ' ' and ws2ovrd(wrtq) = 'Y';
           hlwarn = ws2ovrd(wrtq);
         else;
           hlwarn = ' ';
         endif;
         exsr zzloadanswer;
         // load up value sequence if used
         if avseq(wrtq) <> 0;
           hlvsq# = avseq(wrtq);
         else;
           hlvsq# = 0;
         endif;
640bA    // Check to see if questions have been answered by someone else
640bA    // this was added to handle multiple people receiving the same po
640bA    // at the same time, if they both get the question presented before
640bA    // one person has answered the question, the last person to answer
640bA    // is considered the current information.
640bA    // Need to mark previous answers obsolete.
640bA    exsr zzchklog2;
         //  Add Record
650dA    // Before we add - see if log record already exist if super PO
650dA    // and poadded flag = 'Y'. If so do not add the record. Only want
650dA    // to add for the new Po that was added to the super po.
650dA    if poadded = 'Y';
650dA      exsr zzchklog3;
650dA    endif;
650dA    if NewPo = 'Y' or
650dA       poadded = ' ';
720aA      hlstop = 0;
           write hlrec;
650bA      // new xref information to be passed back to po receiving
650cD      //if s_hifreq = '4' and s_hilevl = 'RCVI';
650cM      if s_hifreq = '4' and s_hilevl = 'RCVI' or
650cA         s_hifreq = '4' and s_hilevl = 'REXI';
650bA        if savetimeuc = *loval;
650bA          $p1whse = %editc(hlwhse:'X');
650bA          $p1po   = hlpo;
650bA          $p1poseq = %editc(hlposeq:'X');
650bA          $p1qstseq = %editc(hlseq#:'X');
650bA          //$p1uctime = %char(hladduc);
650bA          $p1uctime = hladduc;
650bA          xx = xx + 1;
650bA          $parms1(xx) = $p1parms1;
650bA        else;
650bA          // update xref with new time
650bA          exec sql update haccpxrf
650bA                   set hxadduc = :hladduc
650bA                   where hxwhse =:hlwhse
650bA                     and hxpo = :hlpo
650bA                     and hxposeq = :hlposeq
650bA                     and hxseq# = :hlseq#
650bA                     and hxadduc = :savetimeuc;
650bA        endif;
650ba      endif;
650dA    endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  Loadnewrandom Loads new random log records
     *----------------------------------------------------------------
      /free
       begsr loadnewrandom;
         // Now write the new random log record
         hlwhse = $pwhse;
         hlseq# = aseq(wrtq);
         hlpcmd = $pcmd;
         hllevl = hilevl;
         hltype = hitype;
         hlobsolete = ' ';
         hlchgts = *loval;
         hlchguc = *loval;
         hlchgcpgm = ' ';
         hlchgjpgm = ' ';
         hlchgeusr = ' ';
         exsr zzgettime;
         hladdts = currstampsys;
         hladduc = currstampuc;
         hladdcpgm = $pprg;
         hladdjpgm = #prog;
         hladdeusr = #user;
         hlexpts = *loval;
         hlexpuc = *loval;
         hlexpjusr = ' ';
650fD    //hlpo = ' ';
650fM    hlpo = $ppo;
         hlspo = ' ';
         hlname = ' ';
         hlposeq = 0;
         hllcns = ' ';
         hlitem = ' ';
         hlrte = ' ';
         hlord = 0;
650fM    hlcust = 0;
650fD    //hlcust = phven;
         hlcord = 0;
         hloseq = 0;
         exsr zzloadanswer;
         // check for warning override
         if ws2qstn(wrtq) <> ' ' and ws2ovrd(wrtq) = 'Y';
           hlwarn = ws2ovrd(wrtq);
         else;
           hlwarn = ' ';
         endif;
         // load up value sequence if used
         if avseq(wrtq) <> 0;
           hlvsq# = avseq(wrtq);
         else;
           hlvsq# = 0;
         endif;
         hlsid = hpsid;
         //  Add Record
720aA    hlstop = 0;
         write hlrec;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  Loadquestions Loads questions to the screen
     *----------------------------------------------------------------
      /free
       begsr loadquestions;
        Select;
          when #q1 = ' ';

            // save information to allow use to f12 to previous sc     reens
            exsr savepageinfo;
            savehipge# = hipge#;
            savetype = hitype;
            savepage = *on;
            #q1 = hiqstn;
            aseq(1) = hiseq#;
            atype(1) = hiatyp;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in01 = *on;
              when hiatyp = '2';
                *in02 = *on;
              when hiatyp = '3';
                *in01 = *on;
                *in61 = *on;
              when hiatyp = '4';
                *in03 = *on;
                *in61 = *on;
              when hiatyp = '5';
                *in04 = *on;
                *in61 = *on;
              when hiatyp = '6';
                *in04 = *on;
              when hiatyp = '7';
                *in05 = *on;
              when hiatyp = '8';
                *in06 = *on;
                *in61 = *on;
              when hiatyp = '9';
                *in06 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(1) = hladdts;
650bA         stimeuc(1) = hladduc;
              select;
                when hiatyp = '1';
                  #a101 = hldata;
                  stype1(1) = hldata;
                when hiatyp = '2';
                  #a102 = hldata;
                  stype2(1) = hldata;
                when hiatyp = '3';
                  #a101 = hldata;
                  stype3(1) = hldata;
                when hiatyp = '4';
                  #a103 = hldata;
                  stype4(1) = hldata;
                when hiatyp = '5';
                  #a104 = %dec(hldata:9:2);
                  stype5(1) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a104 = %dec(hldata:9:2);
                  stype6(1) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a105 = %dec(hldata:6:0);
                  stype7(1) = %dec(hldata:6:0);
                when hiatyp = '8' or hiatyp = '9';
                  #a106 = %dec(hldata:15:0);
                  stype8(1) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a106 = %dec(hldata:15:0);
                  stype9(1) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q2 = ' ';
            #q2 = hiqstn;
            aseq(2) = hiseq#;
            atype(2) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in07 = *on;
              when hiatyp = '2';
                *in08 = *on;
              when hiatyp = '3';
                *in07 = *on;
                *in62 = *on;
              when hiatyp = '4';
                *in09 = *on;
                *in62 = *on;
              when hiatyp = '5';
                *in10 = *on;
                *in62 = *on;
              when hiatyp = '6';
                *in10 = *on;
              when hiatyp = '7';
                 *in11 = *on;
              when hiatyp = '8';
                 *in12 = *on;
                *in62 = *on;
              when hiatyp = '9';
                 *in12 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(2) = hladdts;
650bA         stimeuc(2) = hladduc;
              select;
                when hiatyp = '1';
                  #a201 = hldata;
                  stype1(2) = hldata;
                when hiatyp = '2';
                  #a202 = hldata;
                  stype2(2) = hldata;
                when hiatyp = '3';
                  #a201 = hldata;
                  stype3(2) = hldata;
                when hiatyp = '4';
                  #a203 = hldata;
                  stype4(2) = hldata;
                when hiatyp = '5';
                  #a204 = %dec(hldata:9:2);
                  stype5(2)=  %dec(hldata:9:2);
                when hiatyp = '6';
                  #a204 = %dec(hldata:9:2);
                  stype6(2) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a205 = %dec(hldata:6:0);
                  stype7(2) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a206 = %dec(hldata:15:0);
                  stype8(2) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a206 = %dec(hldata:15:0);
                  stype9(2) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q3 = ' ';
            #q3 = hiqstn;
            aseq(3) = hiseq#;
            atype(3) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in13 = *on;
              when hiatyp = '2';
                *in14 = *on;
              when hiatyp = '3';
                *in13 = *on;
                *in63 = *on;
              when hiatyp = '4';
                *in15 = *on;
                *in63 = *on;
              when hiatyp = '5';
                *in16 = *on;
                *in63 = *on;
              when hiatyp = '6';
                *in16 = *on;
              when hiatyp = '7';
                *in17 = *on;
              when hiatyp = '8';
                *in18 = *on;
                *in63 = *on;
              when hiatyp = '9';
                *in18 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(3) = hladdts;
650bA         stimeuc(3) = hladduc;
              select;
                when hiatyp = '1';
                  #a301 = hldata;
                  stype1(3) = hldata;
                when hiatyp = '2';
                  #a302 = hldata;
                  stype2(3) = hldata;
                when hiatyp = '3';
                  #a301 = hldata;
                  stype3(3) = hldata;
                when hiatyp = '4';
                  #a303 = hldata;
                  stype4(3) = hldata;
                when hiatyp = '5';
                  #a304 = %dec(hldata:9:2);
                  stype5(3) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a304 = %dec(hldata:9:2);
                  stype6(3) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a305 = %dec(hldata:6:0);
                  stype7(3) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a306 = %dec(hldata:15:0);
                  stype8(3) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a306 = %dec(hldata:15:0);
                  stype9(3) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q4 = ' ';
            #q4 = hiqstn;
            aseq(4) = hiseq#;
            atype(4) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in19 = *on;
              when hiatyp = '2';
                *in20 = *on;
              when hiatyp = '3';
                *in19 = *on;
                *in64 = *on;
              when hiatyp = '4';
                *in21 = *on;
                *in64 = *on;
              when hiatyp = '5';
                *in22 = *on;
                *in64 = *on;
              when hiatyp = '6';
                *in22 = *on;
              when hiatyp = '7';
                *in23 = *on;
              when hiatyp = '8';
                *in24 = *on;
                *in64 = *on;
              when hiatyp = '9';
                *in24 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(4) = hladdts;
650bA         stimeuc(4) = hladduc;
              select;
                when hiatyp = '1';
                  #a401 = hldata;
                  stype1(4) = hldata;
                when hiatyp = '2';
                  #a402 = hldata;
                  stype2(4) = hldata;
                when hiatyp = '3';
                  #a401 = hldata;
                  stype3(4) = hldata;
                when hiatyp = '4';
                  #a403 = hldata;
                  stype4(4) = hldata;
                when hiatyp = '5';
                  #a404 = %dec(hldata:9:2);
                  stype5(4) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a404 = %dec(hldata:9:2);
                  stype6(4) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a405 = %dec(hldata:6:0);
                  stype7(4) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a406 = %dec(hldata:15:0);
                  stype8(4) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a406 = %dec(hldata:15:0);
                  stype9(4) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q5 = ' ';
            #q5 = hiqstn;
            aseq(5) = hiseq#;
            atype(5) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in25 = *on;
              when hiatyp = '2';
                *in26 = *on;
              when hiatyp = '3';
                *in25 = *on;
                *in65 = *on;
              when hiatyp = '4';
                *in27 = *on;
                *in65 = *on;
              when hiatyp = '5';
                *in28 = *on;
                *in65 = *on;
              when hiatyp = '6';
                *in28 = *on;
              when hiatyp = '7';
                *in29 = *on;
              when hiatyp = '8';
                *in30 = *on;
                *in65 = *on;
              when hiatyp = '9';
                *in30 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(5) = hladdts;
650bA         stimeuc(5) = hladduc;
              select;
                when hiatyp = '1';
                  #a501 = hldata;
                  stype1(5) = hldata;
                when hiatyp = '2';
                  #a502 = hldata;
                  stype2(5) = hldata;
                when hiatyp = '3';
                  #a501 = hldata;
                  stype3(5) = hldata;
                when hiatyp = '4';
                  #a503 = hldata;
                  stype4(5) = hldata;
                when hiatyp = '5';
                  #a504 = %dec(hldata:9:2);
                  stype5(5) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a504 = %dec(hldata:9:2);
                  stype6(5) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a505 = %dec(hldata:6:0);
                  stype7(5) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a506 = %dec(hldata:15:0);
                  stype8(5) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a506 = %dec(hldata:15:0);
                  stype9(5) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q6 = ' ';
            #q6 = hiqstn;
            aseq(6) = hiseq#;
            atype(6) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in31 = *on;
              when hiatyp = '2';
                *in32 = *on;
              when hiatyp = '3';
                *in31 = *on;
                *in66 = *on;
              when hiatyp = '4';
                *in33 = *on;
                *in66 = *on;
              when hiatyp = '5';
                *in34 = *on;
                *in66 = *on;
              when hiatyp = '6';
                *in34 = *on;
              when hiatyp = '7';
                *in35 = *on;
              when hiatyp = '8';
                *in36 = *on;
                *in66 = *on;
              when hiatyp = '9';
                *in36 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(6) = hladdts;
650bA         stimeuc(6) = hladduc;
              select;
                when hiatyp = '1';
                  #a601 = hldata;
                  stype1(6) = hldata;
                when hiatyp = '2';
                  #a602 = hldata;
                  stype2(6) = hldata;
                when hiatyp = '3';
                  #a601 = hldata;
                  stype3(6) = hldata;
                when hiatyp = '4';
                  #a603 = hldata;
                  stype4(6) = hldata;
                when hiatyp = '5';
                  #a604 = %dec(hldata:9:2);
                  stype5(6) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a604 = %dec(hldata:9:2);
                  stype6(6) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a605 = %dec(hldata:6:0);
                  stype7(6) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a606 = %dec(hldata:15:0);
                  stype8(6) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a606 = %dec(hldata:15:0);
                  stype9(6) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q7 = ' ';
            #q7 = hiqstn;
            aseq(7) = hiseq#;
            atype(7) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in37 = *on;
              when hiatyp = '2';
                *in38 = *on;
              when hiatyp = '3';
                *in37 = *on;
                *in67 = *on;
              when hiatyp = '4';
                *in39 = *on;
                *in67 = *on;
              when hiatyp = '5';
                *in40 = *on;
                *in67 = *on;
              when hiatyp = '6';
                *in40 = *on;
              when hiatyp = '7';
                *in41 = *on;
              when hiatyp = '8';
                *in42 = *on;
                *in67 = *on;
              when hiatyp = '9';
                *in42 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(7) = hladdts;
650bA         stimeuc(7) = hladduc;
              select;
                when hiatyp = '1';
                  #a701 = hldata;
                  stype1(7) = hldata;
                when hiatyp = '2';
                  #a702 = hldata;
                  stype2(7) = hldata;
                when hiatyp = '3';
                  #a701 = hldata;
                  stype3(7) = hldata;
                when hiatyp = '4';
                  #a703 = hldata;
                  stype4(7) = hldata;
                when hiatyp = '5';
                  #a704 = %dec(hldata:9:2);
                  stype5(7) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a704 = %dec(hldata:9:2);
                  stype6(7) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a705 = %dec(hldata:6:0);
                  stype7(7) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a706 = %dec(hldata:15:0);
                  stype8(7) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a706 = %dec(hldata:15:0);
                  stype9(7) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q8 = ' ';
            #q8 = hiqstn;
            aseq(8) = hiseq#;
            atype(8) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in43 = *on;
              when hiatyp = '2';
                *in44 = *on;
              when hiatyp = '3';
                *in43 = *on;
                *in68 = *on;
              when hiatyp = '4';
                *in45 = *on;
                *in68 = *on;
              when hiatyp = '5';
                *in46 = *on;
                *in68 = *on;
              when hiatyp = '6';
                *in46 = *on;
              when hiatyp = '7';
                *in47 = *on;
              when hiatyp = '8';
                *in48 = *on;
                *in68 = *on;
              when hiatyp = '9';
                *in48 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(8) = hladdts;
650bA         stimeuc(8) = hladduc;
              select;
                when hiatyp = '1';
                  #a801 = hldata;
                  stype1(8) = hldata;
                when hiatyp = '2';
                  #a802 = hldata;
                  stype2(8) = hldata;
                when hiatyp = '3';
                  #a801 = hldata;
                  stype3(8) = hldata;
                when hiatyp = '4';
                  #a803 = hldata;
                  stype4(8) = hldata;
                when hiatyp = '5';
                  #a804 = %dec(hldata:9:2);
                  stype5(8) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a804 = %dec(hldata:9:2);
                  stype6(8) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a805 = %dec(hldata:6:0);
                  stype7(8) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a806 = %dec(hldata:15:0);
                  stype8(8) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a806 = %dec(hldata:15:0);
                  stype9(8) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q9 = ' ';
            #q9 = hiqstn;
            aseq(9) = hiseq#;
            atype(9) = hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in49 = *on;
              when hiatyp = '2';
                *in50 = *on;
              when hiatyp = '3';
                *in49 = *on;
                *in69 = *on;
              when hiatyp = '4';
                *in51 = *on;
                *in69 = *on;
              when hiatyp = '5';
                *in52 = *on;
                *in69 = *on;
              when hiatyp = '6';
                *in52 = *on;
              when hiatyp = '7';
                *in53 = *on;
              when hiatyp = '8';
                *in54 = *on;
                *in69 = *on;
              when hiatyp = '9';
                *in54 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(9) = hladdts;
650bA         stimeuc(9) = hladduc;
              select;
                when hiatyp = '1';
                  #a901 = hldata;
                  stype1(9) = hldata;
                when hiatyp = '2';
                  #a902 = hldata;
                  stype2(9) = hldata;
                when hiatyp = '3';
                  #a901 = hldata;
                  stype3(9) = hldata;
                when hiatyp = '4';
                  #a903 = hldata;
                  stype4(9) = hldata;
                when hiatyp = '5';
                  #a904 = %dec(hldata:9:2);
                  stype5(9) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a904 = %dec(hldata:9:2);
                  stype6(9) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a905 = %dec(hldata:6:0);
                  stype7(9) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a906 = %dec(hldata:15:0);
                  stype8(9) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a906 = %dec(hldata:15:0);
                  stype9(9) = %dec(hldata:15:0);
              endsl;
            endif;

          when #q0 = ' ';
            #q0 = hiqstn;
            aseq(10) = hiseq#;
            atype(10)= hiatyp;
            savetype = hitype;

            // turn on field indicator based on answer type of que     stion
            select;
              when hiatyp = '1';
                *in55 = *on;
              when hiatyp = '2';
                *in56 = *on;
              when hiatyp = '3';
                *in55 = *on;
                *in70 = *on;
              when hiatyp = '4';
                *in57 = *on;
                *in70 = *on;
              when hiatyp = '5';
                *in58 = *on;
                *in70 = *on;
              when hiatyp = '6';
                *in58 = *on;
              when hiatyp = '7';
                *in59 = *on;
              when hiatyp = '8';
                *in60 = *on;
                *in70 = *on;
              when hiatyp = '9';
                *in60 = *on;
            endsl;

            // load previous logged answers to screen fields
            if $pcmd = '*POHDRCH' and today = 'Y' or
               $pcmd = '*PODTLCH' and Today = 'Y' or
               $pcmd = '*RANDOMC' and Today = 'Y' or
               prvscn = 'Y' and today = 'Y';
              stime(10)= hladdts;
650bA         stimeuc(10)= hladduc;
              select;
                when hiatyp = '1';
                  #a001 = hldata;
                  stype1(10) = hldata;
                when hiatyp = '2';
                  #a002 = hldata;
                  stype2(10) = hldata;
                when hiatyp = '3';
                  #a001 = hldata;
                  stype3(10) = hldata;
                when hiatyp = '4';
                  #a003 = hldata;
                  stype4(10) = hldata;
                when hiatyp = '5';
                  #a004 = %dec(hldata:9:2);
                  stype5(10) = %dec(hldata:9:2);
                when hiatyp = '6';
                  #a004 = %dec(hldata:9:2);
                  stype6(10) = %dec(hldata:9:2);
                when hiatyp = '7';
                  #a005 = %dec(hldata:6:0);
                  stype7(10) = %dec(hldata:6:0);
                when hiatyp = '8';
                  #a006 = %dec(hldata:15:0);
                  stype8(10) = %dec(hldata:15:0);
                when hiatyp = '9';
                  #a006 = %dec(hldata:15:0);
                  stype9(10) = %dec(hldata:15:0);
              endsl;
            endif;
            morequestions = 'Y';
            leavesr;

        endsl;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  Loadwarning   Loads fields for warning screen
     *----------------------------------------------------------------
      /free
       begsr loadwarning;
         s2qstn = ws2qstn(W);
         s2answ = ws2answ(W);
         s2valu = ws2valu(W);
         s2warn = ws2warn(W);
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  markoldrandom mark old random as exported when new is entered
     *----------------------------------------------------------------
      /free
       begsr markoldrandom;
         if $pcmd = '*RANDOM ';
           exsr zzgettime;
           // mark the previous answer exported for same question
           exec sql update haccplog
                    set hlexpts = :CurrStampsys,
                        hlexpuc = :Currstampuc,
                        hlexpjusr = :#user
                    where hlexpjusr = ' '
                      and hlseq# = :$keyseq;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  RSTPAGEINFO Restore page starting information when f12
     *----------------------------------------------------------------

      /free
       begsr rstpageinfo;
         if whpg > 1;
           holdwhpg = whpg;
           pmoreq(whpg) = ' ';
           pmoret(whpg) = ' ';
           pcode(whpg) = ' ';
           psavet(whpg) = ' ';
           psaveh(whpg) = 0;
           psavep(whpg) = ' ';
           plevel(whpg) = ' ';
           ptype(whpg) = ' ';
           ppge#(whpg) = 0;
           ppgsq(whpg) = 0;
           whpg = whpg - 1;
         endif;
         morequestions = pmoreq(whpg);
         moretypes = pmoret(whpg);
         $code = pcode(whpg);
         savetype = psavet(whpg);
         savehipge# = psaveh(whpg);
         savepage = psavep(whpg);
         hblevl = plevel(whpg);
         hbtype = ptype(whpg);
         hipge# = ppge#(whpg);
         hipgsq = ppgsq(whpg);
         aseq = 0;
         exsr zzclrarray;
         whpg = whpg - 1;
         prvscn = 'Y';
         setll ($pwhse: hblevl: hbtype) haccpqt;
         if morequestions = 'Y';
             hilevl = hblevl;
             hitype = hbtype;
740aD      //setll ($pwhse: hilevl: hitype: $code: hipge#: hipgsq) haccpq3;
740aM        setll ($pwhse: hilevl: hitype: $code: hipge#: hipgsq) haccpq5;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  SAVEPAGEINFO Save page starting information to allow f12
     *----------------------------------------------------------------

      /free
       begsr savepageinfo;
         whpg = whpg + 1;
         pmoreq(whpg) = morequestions;
         pmoret(whpg) = moretypes;
         pcode(whpg) = $code;
         psavet(whpg) = savetype;
         psaveh(whpg) = savehipge#;
         psavep(whpg) = savepage;
         plevel(whpg) = hblevl;
         ptype(whpg) = hbtype;
         ppge#(whpg) = hipge#;
         ppgsq(whpg) = hipgsq;
         if holdwhpg < whpg;
           prvscn = ' ';
         endif;
         if not %eof(haccpqt);
           moretypes = 'Y';
         endif;
740aD    //if not %eof(haccpq3);
740aM    if not %eof(haccpq5);
           morequestions = 'Y';
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZCLR1   Clear screen 1 fields
     *----------------------------------------------------------------

      /free
       begsr zzclr1;

         clear screen1;

         // display appropriate headings on the screen
         select;
           when $plevel = 'RCVH';
           when $plevel = 'RCVI';
650cA      when $plevel = 'REXI';
           when $plevel = 'RCVL';
           other;
           *in92 = *on;
           #lvdsc2 = hldspecdesc;
         endsl;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZCLRARRAY Clears Answer arrays
     *----------------------------------------------------------------

      /free
       begsr zzclrarray;

         atype1 = ' ';
         atype2 = ' ';
         atype3 = ' ';
         atype4 = ' ';
         atype5 = 0;
         atype6 = 0;
         atype7 = 0;
         atype8 = 0;
         atype9 = 0;

         stype1 = ' ';
         stype2 = ' ';
         stype3 = ' ';
         stype4 = ' ';
         stype5 = 0;
         stype6 = 0;
         stype7 = 0;
         stype8 = 0;
         stype9 = 0;
         // clear warning array
         ws2qstn = ' ';
         ws2answ = ' ';
         ws2valu = ' ';
         ws2warn = ' ';
         ws2ovrd = ' ';
         avseq   = 0;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *  ZZCLRerr Clear screen 1 error indicator fields
     *----------------------------------------------------------------

      /free
       begsr zzclrerr;

         x = 80;
         for w = 1 to 10;
           x = x +1;
           *in(x) = *off;
         endfor;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------
      /free
       begsr zzchk1;

         error = *off;
650gA    warn  = *off;
         edtq = 0;
         exsr zzclrerr;
         // verify entered data
         // First step is to identify what the edits are for each specific
         // question use the aseq field to get the haccpq record where
         // the validation information is stored

         dow edtq < 9;
           edtq = edtq + 1;
           // Lets process the questions
           if aseq(edtq) > 0;
             $keyseq = aseq(edtq);
             exec sql select * into :haccpq
                      from haccpq
                      where hiwhse = :$pwhse
                        and hiseq# = :$keyseq;
             if sqlstt = sqlSuccess;
             else;
               error = *on;
               leavesr;
             endif;
             // answer type
             select;
               when s_hiatyp = '1';
                 exsr zzchktype1;
               when s_hiatyp = '2';
                 exsr zzchktype2;
               when s_hiatyp = '3';
                 exsr zzchktype3;
               when s_hiatyp = '4';
                 exsr zzchktype4;
               when s_hiatyp = '5';
                 exsr zzchktype5;
               when s_hiatyp = '6';
                 exsr zzchktype6;
               when s_hiatyp = '7';
                 exsr zzchktype7;
               when s_hiatyp = '8';
                 exsr zzchktype8;
               when s_hiatyp = '9';
                 exsr zzchktype9;
             endsl;
           endif;
         enddo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZCHK2   Screen 2 error checking.
     *----------------------------------------------------------------
      /free
       begsr zzchk2;
         // update data structure when warning if overridden
         ws2ovrd(w) = 'Y';
         for W = 1 to 10;
           if ws2qstn(W) <> ' ' and ws2ovrd(w) <> 'Y';
             warnmore = *on;
             leave;
           endif;
           warnmore = *off;
         endfor;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHKLOG   Check for po receipt already done today
     *
     *----------------------------------------------------------------
      /free
       begsr zzchklog;
         today = ' ';
         select;
         // don't check on everytime question hifreq = 4  unless *PODTLCH
         when hifreq = '4' and $pcmd = '*PODTLCH';
           setgt  ($pwhse: $ppo: $pposeq: $license: hiseq#) haccplog1;
           readpe ($pwhse: $ppo: $pposeq: $license: hiseq#) haccplog1;
           if not %eof(haccplog1);
             if hlexpts = *loval;
               today = 'Y';
             endif;
           endif;

         when hifreq = '4';

         // once per po check
         when $plevel = 'RCVI' and hifreq = '2' and hitype = 'CAT' or
              $plevel = 'RCVI' and hifreq = '2' and hitype = 'DPT' or
              $plevel = 'RCVI' and hifreq = '2' and hitype = 'ALL';
           exec sql select * into :haccplog
                    from haccplog
                    where hlwhse = :$pwhse
                    and hlpo   = :$ppo
                    and hlseq# = :hiseq#
                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM               and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
650cA    // once per po check - exceptions
650cA    when $plevel = 'REXI' and hifreq = '2' and hitype = 'CAT' or
650cA         $plevel = 'REXI' and hifreq = '2' and hitype = 'DPT' or
650cA         $plevel = 'REXI' and hifreq = '2' and hitype = 'ALL';
650cA      exec sql select * into :haccplog
650cA               from haccplog
650cA               where hlwhse = :$pwhse
650cA               and hlpo   = :$ppo
650cA               and hlseq# = :hiseq#
650cA               and hlexpts = '0001-01-01-00.00.00.000000'
730aM               and hlobsolete <> 'Y'
730aA             fetch first row only;
650cA      if sqlstt = sqlSuccess;
650cA          today = 'Y';
650cA      endif;

         // once per po session check
         when $plevel = 'RCVI' and hifreq = '3' and hitype = 'CAT' or
              $plevel = 'RCVI' and hifreq = '3' and hitype = 'DPT' or
              $plevel = 'RCVI' and hifreq = '3' and hitype = 'ALL';
           exec sql select * into :haccplog
                    from haccplog
                    where hlwhse = :$pwhse
                    and hlpo   = :$ppo
                    and hlseq# = :hiseq#
                     and hlsid = :hpsid
                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM               and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
650cA    // once per po session check exceptions
650cA    when $plevel = 'REXI' and hifreq = '3' and hitype = 'CAT' or
650cA         $plevel = 'REXI' and hifreq = '3' and hitype = 'DPT' or
650cA         $plevel = 'REXI' and hifreq = '3' and hitype = 'ALL';
650cA      exec sql select * into :haccplog
650cA               from haccplog
650cA               where hlwhse = :$pwhse
650cA               and hlpo   = :$ppo
650cA               and hlseq# = :hiseq#
650cA                and hlsid = :hpsid
650cA               and hlexpts = '0001-01-01-00.00.00.000000'
650cA               and hlobsolete <> 'Y';
650cA      if sqlstt = sqlSuccess;
650cA          today = 'Y';
650cA      endif;

         when $plevel = 'RCVI' and hifreq = '3' and hitype = 'ITM';
           exec sql select * into :haccplog
                    from haccplog
                    where hlwhse = :$pwhse
                        and hlpo = :$ppo
                     and hlposeq = :$pposeq
                     and hllcns  = :$license
                      and hlseq# = :hiseq#
                       and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
650cA    when $plevel = 'REXI' and hifreq = '3' and hitype = 'ITM';
650cA      exec sql select * into :haccplog
650cA               from haccplog
650cA               where hlwhse = :$pwhse
650cA                   and hlpo = :$ppo
650cA                and hlposeq = :$pposeq
650cA                and hllcns  = :$license
650cA                 and hlseq# = :hiseq#
650cA                  and hlsid = :hpsid
650cA                and hlexpts = '0001-01-01-00.00.00.000000'
650cA             and hlobsolete <> 'Y';
650cA      if sqlstt = sqlSuccess;
650cA          today = 'Y';
650cA      endif;

         // once per item per po
         when $pspo = '*NO ' or
              $plevel = 'RCVI' and hifreq = '1' or
              $plevel = 'RCVI' and hifreq = '2' and hitype = 'ITM' or
650cD         //$plevel = 'RCVL';
650cM         $plevel = 'RCVL' or
650cA         $plevel = 'REXI' and hifreq = '1' or
650cA         $plevel = 'REXI' and hifreq = '2' and hitype = 'ITM';
640cA      exec sql select * into :haccplog
640cA               from haccplog
640cA               where hlwhse = :$pwhse
640cA                   and hlpo = :$ppo
640cA                and hlposeq = :$pposeq
640cA                and hllcns  = :$license
640cA                 and hlseq# = :hiseq#
640cA                and hlexpts = '0001-01-01-00.00.00.000000'
730aM             and hlobsolete <> 'Y'
730aA             fetch first row only;
640cA      if sqlstt = sqlSuccess;
640cA          today = 'Y';
640cA      endif;
640cD      //chain(n) ($pwhse: $ppo: $pposeq: $license: hiseq#) haccplog1;
640cD      //if %found(haccplog1);
640cD        //if hlexpts = *loval;
640cD          //today = 'Y';
640cD        //endif;
640cD      //endif;

         when $pcmd = '*RANDOMC';
           exec sql select * into :haccplog
                    from haccplog
                    where hlwhse = :$pwhse
                      and hlseq# = :hiseq#
                       //and hlsid = :hpsid
                     and hlexpts = '0001-01-01-00.00.00.000000'
                  and hlobsolete <> 'Y';
           if sqlstt = sqlSuccess;
               today = 'Y';
           endif;
         other;
           // this will do super po check for the existence
           exec sql select * into :haccplog
                    from haccplog
                    where hlwhse = :$pwhse
                       and hlspo = :$ppo
                     and hlposeq = :$pposeq
                      and hllcns = :$license
                      and hlseq# = :hiseq#
                     and hlexpts = '0001-01-01-00.00.00.000000'
730aM             and hlobsolete <> 'Y'
730aA             fetch first row only;
           if sqlstt = sqlSuccess or
              sqlstt = '21000';
               today = 'Y';
650dA        // Now check to see if all po's linked to super po exist
650dA        // in HACCPLOG need to ask questions for any po's linked
650dA        // to super po after receipt has started.
650dA        // Need to ask questons if new po was added.
650dA        setll ($pwhse: $ppo) pospo;
650dA        dow not %eof(pospo);
650dA          reade ($pwhse: $ppo) pospo;
650dA          if %eof(pospo);
650dA            leave;
650dA          endif;
650dA          exec sql select * into :haccplog
650dA                   from haccplog
650dA                   where hlwhse = :$pwhse
650dA                       and hlpo = :pupo
650dA                      and hlspo = :$ppo
650dA                    and hlposeq = :$pposeq
650dA                     and hllcns = :$license
650dA                     and hlseq# = :hiseq#
650dA                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM                 and hlobsolete <> 'Y'
730aA             fetch first row only;
650dA          // already asked for this po.
650dA          if sqlstt = sqlSuccess or
650dA            sqlstt = '21000';
650dA          else;
650dA          // needs to be asked for at least one po added.
650dA            today = 'N';
650dA            poadded = 'Y';
650dA          endif;
650dA        enddo;
           endif;
         endsl;
       endsr;
      /end-free
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZCHKLOG2  Check for po receipt already done today - extra
640bA*             check for multiple receivers same time same po
640bA*
640bA*----------------------------------------------------------------
640bA /free
640bA   begsr zzchklog2;
640bA     today = ' ';
640bA     select;
640bA
640bA       when s_hifreq = '4';
640bA
640bA       // once per po check
640bA       when s_hilevl = 'RCVI' and s_hifreq = '2' and s_hitype = 'CAT' or
640bA            s_hilevl = 'RCVI' and s_hifreq = '2' and s_hitype = 'DPT' or
640bA            s_hilevl = 'RCVI' and s_hifreq = '2' and s_hitype = 'ALL';
640bA         exec sql select * into :haccplogck
640bA                  from haccplog
640bA                  where hlwhse = :hlwhse
640bA                    and hlpo   = :hlpo
640bA                    and hlseq# = :hlseq#
640bA                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM                    and hlobsolete <> 'Y'
730aA             fetch first row only;
640bA         if sqlstt = sqlSuccess;
640bA           exsr zzgettime;
640bA           exec sql update haccplog
640bA                    set hlchgts = :CurrStampsys,
640bA                        hlchguc = :Currstampuc,
640bA                        hlchgcpgm = :$pprg,
640bA                        hlchgjpgm = :#prog,
640bA                        hlchgeusr = :#user,
640bA                        hlobsolete = 'Y'
640bA                    where hlwhse = :ck_hlwhse
640bA                        and hlpo = :ck_hlpo
640bA                        and hlposeq = :ck_hlposeq
640bA                        and hllcns = :ck_hllcns
640bA                        and hlseq# = :ck_hlseq#;
640bA         endif;
640bA
650cA       // once per po check exception
650cA       when s_hilevl = 'REXI' and s_hifreq = '2' and s_hitype = 'CAT' or
650cA            s_hilevl = 'REXI' and s_hifreq = '2' and s_hitype = 'DPT' or
650cA            s_hilevl = 'REXI' and s_hifreq = '2' and s_hitype = 'ALL';
650cA         exec sql select * into :haccplogck
650cA                  from haccplog
650cA                  where hlwhse = :hlwhse
650cA                    and hlpo   = :hlpo
650cA                    and hlseq# = :hlseq#
650cA                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM                    and hlobsolete <> 'Y'
730aA             fetch first row only;
650cA         if sqlstt = sqlSuccess;
650cA           exsr zzgettime;
650cA           exec sql update haccplog
650cA                    set hlchgts = :CurrStampsys,
650cA                        hlchguc = :Currstampuc,
650cA                        hlchgcpgm = :$pprg,
650cA                        hlchgjpgm = :#prog,
650cA                        hlchgeusr = :#user,
650cA                        hlobsolete = 'Y'
650cA                    where hlwhse = :ck_hlwhse
650cA                        and hlpo = :ck_hlpo
650cA                        and hlposeq = :ck_hlposeq
650cA                        and hllcns = :ck_hllcns
650cA                        and hlseq# = :ck_hlseq#;
650cA         endif;
650cA
640bA       // once per po session check
640bA       when s_hilevl = 'RCVI' and s_hifreq = '3' and s_hitype = 'CAT' or
640bA            s_hilevl = 'RCVI' and s_hifreq = '3' and s_hitype = 'DPT' or
640bA            s_hilevl = 'RCVI' and s_hifreq = '3' and s_hitype = 'ALL';
640bA         exec sql select * into :haccplogck
640bA                  from haccplog
640bA                  where hlwhse = :hlwhse
640bA                    and hlpo   = :hlpo
640bA                    and hlseq# = :hlseq#
640bA                    and hlsid = :hlsid
640bA                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM                    and hlobsolete <> 'Y'
730aA             fetch first row only;
640bA         if sqlstt = sqlSuccess;
640bA           exsr zzgettime;
640bA           exec sql update haccplog
640bA                    set hlchgts = :CurrStampsys,
640bA                        hlchguc = :Currstampuc,
640bA                        hlchgcpgm = :$pprg,
640bA                        hlchgjpgm = :#prog,
640bA                        hlchgeusr = :#user,
640bA                        hlobsolete = 'Y'
640bA                    where hlwhse = :ck_hlwhse
640bA                      and hlpo = :ck_hlpo
640bA                      and hlposeq = :ck_hlposeq
640bA                      and hllcns = :ck_hllcns
640bA                      and hlseq# = :ck_hlseq#;
640bA         endif;
640bA
650cA       // once per po session check exception
650cA       when s_hilevl = 'REXI' and s_hifreq = '3' and s_hitype = 'CAT' or
650cA            s_hilevl = 'REXI' and s_hifreq = '3' and s_hitype = 'DPT' or
650cA            s_hilevl = 'REXI' and s_hifreq = '3' and s_hitype = 'ALL';
650cA         exec sql select * into :haccplogck
650cA                  from haccplog
650cA                  where hlwhse = :hlwhse
650cA                    and hlpo   = :hlpo
650cA                    and hlseq# = :hlseq#
650cA                    and hlsid = :hlsid
650cA                    and hlexpts = '0001-01-01-00.00.00.000000'
650cA                    and hlobsolete <> 'Y';
650cA         if sqlstt = sqlSuccess;
650cA           exsr zzgettime;
650cA           exec sql update haccplog
650cA                    set hlchgts = :CurrStampsys,
650cA                        hlchguc = :Currstampuc,
650cA                        hlchgcpgm = :$pprg,
650cA                        hlchgjpgm = :#prog,
650cA                        hlchgeusr = :#user,
650cA                        hlobsolete = 'Y'
650cA                    where hlwhse = :ck_hlwhse
650cA                      and hlpo = :ck_hlpo
650cA                      and hlposeq = :ck_hlposeq
650cA                      and hllcns = :ck_hllcns
650cA                      and hlseq# = :ck_hlseq#;
650cA         endif;
650cA
640bA       when s_hilevl = 'RCVI' and s_hifreq = '3' and s_hitype = 'ITM';
640bA         exec sql select * into :haccplogck
640bA                  from haccplog
640bA                  where hlwhse = :hlwhse
640bA                    and hlpo = :hlpo
640bA                    and hlposeq = :hlposeq
640bA                    and hllcns  = :hllcns
640bA                    and hlseq# = :hlseq#
640bA                    and hlsid = :hlsid
640bA                    and hlexpts = '0001-01-01-00.00.00.000000'
640bA                    and hlobsolete <> 'Y';
640bA         if sqlstt = sqlSuccess;
640bA           exsr zzgettime;
640bA           exec sql update haccplog
640bA                    set hlchgts = :CurrStampsys,
640bA                        hlchguc = :Currstampuc,
640bA                        hlchgcpgm = :$pprg,
640bA                        hlchgjpgm = :#prog,
640bA                        hlchgeusr = :#user,
640bA                        hlobsolete = 'Y'
640bA                    where hlwhse = :ck_hlwhse
640bA                      and hlpo = :ck_hlpo
640bA                      and hlposeq = :ck_hlposeq
640bA                      and hllcns = :ck_hllcns
640bA                      and hlseq# = :ck_hlseq#;
640bA         endif;
640bA
650cA       when s_hilevl = 'REXI' and s_hifreq = '3' and s_hitype = 'ITM';
650cA         exec sql select * into :haccplogck
650cA                  from haccplog
650cA                  where hlwhse = :hlwhse
650cA                    and hlpo = :hlpo
650cA                    and hlposeq = :hlposeq
650cA                    and hllcns  = :hllcns
650cA                    and hlseq# = :hlseq#
650cA                    and hlsid = :hlsid
650cA                    and hlexpts = '0001-01-01-00.00.00.000000'
650cA                    and hlobsolete <> 'Y';
650cA         if sqlstt = sqlSuccess;
650cA           exsr zzgettime;
650cA           exec sql update haccplog
650cA                    set hlchgts = :CurrStampsys,
650cA                        hlchguc = :Currstampuc,
650cA                        hlchgcpgm = :$pprg,
650cA                        hlchgjpgm = :#prog,
650cA                        hlchgeusr = :#user,
650cA                        hlobsolete = 'Y'
650cA                    where hlwhse = :ck_hlwhse
650cA                      and hlpo = :ck_hlpo
650cA                      and hlposeq = :ck_hlposeq
650cA                      and hllcns = :ck_hllcns
650cA                      and hlseq# = :ck_hlseq#;
650cA         endif;
650cA
640bA       // once per item per po
640bA       when $pspo = '*NO ' or
640bA         s_hilevl = 'RCVI' and s_hifreq = '1' or
640bA         s_hilevl = 'RCVI' and s_hifreq = '2' and s_hitype = 'ITM' or
650cD         //s_hilevl = 'RCVL';
650cM         s_hilevl = 'RCVL' or
650cA         s_hilevl = 'REXI' and s_hifreq = '1' or
650cA         s_hilevl = 'REXI' and s_hifreq = '2' and s_hitype = 'ITM';
640bA         exec sql select * into :haccplogck
640bA                  from haccplog
640bA                  where hlwhse = :hlwhse
640bA                    and hlpo = :hlpo
640bA                    and hlposeq = :hlposeq
640bA                    and hllcns  = :hllcns
640bA                    and hlseq# = :hlseq#
640bA                    and hlexpts = '0001-01-01-00.00.00.000000'
730aM                    and hlobsolete <> 'Y'
730aA             fetch first row only;
640bA         if sqlstt = sqlSuccess;
640bA           exsr zzgettime;
640bA           exec sql update haccplog
640bA                    set hlchgts = :CurrStampsys,
640bA                        hlchguc = :Currstampuc,
640bA                        hlchgcpgm = :$pprg,
640bA                        hlchgjpgm = :#prog,
640bA                        hlchgeusr = :#user,
640bA                        hlobsolete = 'Y'
640bA                    where hlwhse = :ck_hlwhse
640bA                      and hlpo = :ck_hlpo
640bA                      and hlposeq = :ck_hlposeq
640bA                      and hllcns = :ck_hllcns
640bA                      and hlseq# = :ck_hlseq#;
640bA         endif;
640bA
640bA       when $pcmd = '*RANDOMC';
640bA         exec sql select * into :haccplogck
640bA                  from haccplog
640bA                  where hlwhse = :hlwhse
640bA                    and hlseq# = :hlseq#
640bA                    and hlexpts = '0001-01-01-00.00.00.000000'
640bA                    and hlobsolete <> 'Y';
640bA         if sqlstt = sqlSuccess;
640bA           exsr zzgettime;
640bA           exec sql update haccplog
640bA                    set hlchgts = :CurrStampsys,
640bA                        hlchguc = :Currstampuc,
640bA                        hlchgcpgm = :$pprg,
640bA                        hlchgjpgm = :#prog,
640bA                        hlchgeusr = :#user,
640bA                        hlobsolete = 'Y'
640bA                    where hlwhse = :ck_hlwhse
640bA                      and hlpo = :ck_hlpo
640bA                      and hlposeq = :ck_hlposeq
640bA                      and hllcns = :ck_hllcns
640bA                      and hlseq# = :ck_hlseq#;
640bA         endif;
640bA       other;
650dA         if poadded <> 'Y';
640bA           // this will do super po check for the existence
640bA           exec sql select * into :haccplogck
640bA                    from haccplog
640bA                    where hlwhse = :hlwhse
640bA                      and hlspo = :hlpo
640bA                      and hlposeq = :hlposeq
640bA                      and hllcns = :hllcns
640bA                      and hlseq# = :hlseq#
640bA                      and hlexpts = '0001-01-01-00.00.00.000000'
730aM                      and hlobsolete <> 'Y'
730aA             fetch first row only;
640bA           if sqlstt = sqlSuccess or
640bA              sqlstt = '21000';
640bA             exsr zzgettime;
640bA             exec sql update haccplog
640bA                      set hlchgts = :CurrStampsys,
640bA                          hlchguc = :Currstampuc,
640bA                          hlchgcpgm = :$pprg,
640bA                          hlchgjpgm = :#prog,
640bA                          hlchgeusr = :#user,
640bA                          hlobsolete = 'Y'
640bA                      where hlwhse = :ck_hlwhse
640bA                        and hlpo = :ck_hlpo
640bA                        and hlposeq = :ck_hlposeq
640bA                        and hllcns = :ck_hllcns
640bA                        and hlseq# = :ck_hlseq#;
640bA           endif;
650dA         endif;
640bA     endsl;
640bA   endsr;
640bA /end-free
650dA*----------------------------------------------------------------
650dA*
650dA*  ZZCHKLOG3  Check for po receipt already done today if poadded
650dA*             for super po.
650dA*
650dA*----------------------------------------------------------------
650dA /free
650dA   begsr zzchklog3;
650dA     // this will do super po check for the existence for new po
650dA     exec sql select * into :haccplogck
650dA              from haccplog
650dA              where hlwhse = :hlwhse
650dA                and hlpo = :hlpo
650dA                and hlspo = :hlspo
650dA                and hlposeq = :hlposeq
650dA                and hllcns = :hllcns
650dA                and hlseq# = :hlseq#
650dA                and hlexpts = '0001-01-01-00.00.00.000000'
730aM                and hlobsolete <> 'Y'
730aA             fetch first row only;
650dA     if sqlstt = sqlSuccess or
650dA        sqlstt = '21000';
650dA       NewPo = ' ';
650dA     else;
650dA       NewPo = 'Y';
650dA     endif;
650dA   endsr;
650dA /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE1 Check data for answer type 1 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype1;
         atype1(1) = #a101;
         atype1(2) = #a201;
         atype1(3) = #a301;
         atype1(4) = #a401;
         atype1(5) = #a501;
         atype1(6) = #a601;
         atype1(7) = #a701;
         atype1(8) = #a801;
         atype1(9) = #a901;
         atype1(10) = #a001;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         if s_hireqd = 'Y'  and atype1(edtq) = ' ';
           error = *on;
           *in(xedit) = *on;

           if error = '1';
             errmsg = desc(2);
             exsr zm0203;
           endif;
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE2 Check data for answer type 2 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype2;

         // Load up answers to the array
         atype2(1) = #a102;
         atype2(2) = #a202;
         atype2(3) = #a302;
         atype2(4) = #a402;
         atype2(5) = #a502;
         atype2(6) = #a602;
         atype2(7) = #a702;
         atype2(8) = #a802;
         atype2(9) = #a902;
         atype2(10) = #a002;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         //if  s_hireqd = 'Y' and atype2(edtq) = ' ';
         if  s_hireqd = 'Y';
           if atype2(edtq) = ' ';
             error = *on;
             *in(xedit) = *on;
           endif;

           if error = *on;
             errmsg = desc(2);
             exsr zm0203;
           endif;

           // validate answer entered
           if atype2(edtq) <> 'Y' and atype2(edtq) <> 'N';
             error = *on;
             *in(xedit) = *on;
           endif;

           if error = *on;
             errmsg = desc(1);
             exsr zm0105;
           endif;
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE3 Check data for answer type 3 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype3;

         atype3(1) = #a101;
         atype3(2) = #a201;
         atype3(3) = #a301;
         atype3(4) = #a401;
         atype3(5) = #a501;
         atype3(6) = #a601;
         atype3(7) = #a701;
         atype3(8) = #a801;
         atype3(9) = #a901;
         atype3(10) = #a001;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         if s_hireqd = 'Y' and atype3(edtq) = ' ';
           error = *on;
           *in(xedit) = *on;

           if error = *on;
             errmsg = desc(2);
             exsr zm0203;
           endif;
         endif;
         if s_hireqd = 'Y' or atype3(edtq) <> ' ';
           // validate values entered for question
           foundvalue = ' ';
           setll (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
           dou %eof(haccpv2);
             reade (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
             if %eof(haccpv2);
               leave;
             endif;
             if hvt3vl = atype3(edtq);
               foundvalue = 'Y';
               avseq(edtq) = hvvsq#;
               leave;
             endif;
           enddo;
           if foundvalue = ' ';
           error = *on;
           *in(xedit) = *on;
           endif;
           if error = *on;
             errmsg = desc(1);
             exsr zm0105;
           endif;
         endif;
       endsr;

      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE4 Check data for answer type 4 fields
     *
      /free
       begsr zzchktype4;
         atype4 = ' ';
         atype4(1) = #a103;
         atype4(2) = #a203;
         atype4(3) = #a303;
         atype4(4) = #a403;
         atype4(5) = #a503;
         atype4(6) = #a603;
         atype4(7) = #a703;
         atype4(8) = #a803;
         atype4(9) = #a903;
         atype4(10) = #a003;
         xedit = 80 + edtq;
         *in(xedit) = *off;
         // answer required
         if s_hireqd = 'Y' and atype4(edtq) = ' ';
           error = *on;
           *in(xedit) = *on;

           if error = *on;
             errmsg = desc(2);
             exsr zm0203;
           endif;
         endif;
         // answer type allows for a validation using a program
         if s_hitabl <> ' ';
           $lcmd = '*VERIFY ';
           $ltbldata = atype4(edtq);
           cktabl($lparm);
           if $lrtn <> '*OK';
             error = *on;
             *in(xedit) = *on;
           endif;
         endif;
         #a103 = atype4(1);
         #a203 = atype4(2);
         #a303 = atype4(3);
         #a403 = atype4(4);
         #a503 = atype4(5);
         #a603 = atype4(6);
         #a703 = atype4(7);
         #a803 = atype4(8);
         #a903 = atype4(9);
         #a003 = atype4(10);
       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE5 Check data for answer type 5 fields  no validation
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype5;
         atype5(1) = #a104;
         atype5(2) = #a204;
         atype5(3) = #a304;
         atype5(4) = #a404;
         atype5(5) = #a504;
         atype5(6) = #a604;
         atype5(7) = #a704;
         atype5(8) = #a804;
         atype5(9) = #a904;
         atype5(10) = #a004;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         //if s_hireqd = 'Y' and atype5(edtq) = 0;
           //error = *on;
           //*in(xedit) = *on;

             //if error = *on;
               //errmsg = desc(2);
               //exsr zm0203;
             //endif;
         //endif;

         if s_hireqd = 'Y';
           // validate values entered for question
           foundvalue = ' ';
           setll (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
           dou %eof(haccpv2);
             reade (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
             if %eof(haccpv2);
               leave;
             endif;
             // no range, validate value only
             if hvt5rg = 0;
               if hvt5vl = atype5(edtq);
                 foundvalue = 'Y';
                 avseq(edtq) = hvvsq#;
                 leave;
               endif;
             endif;
             // range validation
             if hvt5rg <> 0;
               if hvt5vl <= atype5(edtq) and hvt5rg >= atype5(edtq);
                 foundvalue = 'Y';
                 ws2qstn(edtq) = ' ';
                 ws2answ(edtq) = ' ';
                 ws2valu(edtq) = ' ';
                 ws2warn(edtq) = ' ';
                 ws2ovrd(edtq) = ' ';
                 leave;
               endif;
             endif;
           enddo;
           // if entry is outside of range and no warning - hard error
           if foundvalue = ' ' and hvwarn = ' ';
             error = *on;
             *in(xedit) = *on;
           endif;
           // if entry is outside of range and warning exist - warning
650gD      //warn = *off;
           if foundvalue = ' ' and hvwarn <> ' ';
             warn = *on;
             // if question has already been overriden, don't reload
             // unless answer has been changed
             if ws2ovrd(edtq) <> 'Y'or ws2answ(edtq) <> %char(atype5(  edtq));
               ws2qstn(edtq) = s_hiqstn;
               ws2answ(edtq) = %char(atype5(edtq));
               ws2valu(edtq) =  %char(hvt5vl) + ' to ' + %char(hvt5rg  );
               ws2warn(edtq) = hvwarn;
               ws2ovrd(edtq) = 'N';
             endif;
           endif;
           if error = *on;
             errmsg = desc(1);
             exsr zm0105;
           endif;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE6 Check data for answer type 6 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype6;
         atype6(1) = #a104;
         atype6(2) = #a204;
         atype6(3) = #a304;
         atype6(4) = #a404;
         atype6(5) = #a504;
         atype6(6) = #a604;
         atype6(7) = #a704;
         atype6(8) = #a804;
         atype6(9) = #a904;
         atype6(10) = #a004;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         if s_hireqd = 'Y' and atype6(edtq) = 0;
           error = *on;
           *in(xedit) = *on;

             if error = *on;
               errmsg = desc(2);
               exsr zm0203;
             endif;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE7 Check data for answer type 7 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype7;

         atype7(1) = #a105;
         atype7(2) = #a205;
         atype7(3) = #a305;
         atype7(4) = #a405;
         atype7(5) = #a505;
         atype7(6) = #a605;
         atype7(7) = #a705;
         atype7(8) = #a805;
         atype7(9) = #a905;
         atype7(10) = #a005;
         xedit = 80 + edtq;
         *in(xedit) = *off;
         if s_hireqd = 'Y';
           $cvcmd = '*MDYEDT ';
      /end-free
     c                   move      atype7(edtq)  $cvd6i
     c                   call      @cvtdt
     c                   parm                    $cvtdt
      /free
           if $cvrtn = '*PGMQ   ';
             error = *on;
             *in(xedit) = *on;
             errmsg = Desc(3);
             exsr zm0105;
           endif;

         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE8 Check data for answer type 8 fields
     *
     *----------------------------------------------------------------
      /free
       begsr zzchktype8;

         atype8(1) = #a106;
         atype8(2) = #a206;
         atype8(3) = #a306;
         atype8(4) = #a406;
         atype8(5) = #a506;
         atype8(6) = #a606;
         atype8(7) = #a706;
         atype8(8) = #a806;
         atype8(9) = #a906;
         atype8(10) = #a006;
         xedit = 80 + edtq;
         *in(xedit) = *off;

         if s_hireqd = 'Y' and atype8(edtq) = 0;
           error = *on;
           *in(xedit) = *on;

           if error = *on;
             errmsg = desc(2);
             exsr zm0203;
           endif;
         endif;

         if s_hireqd = 'Y';
           // validate values entered for question
           foundvalue = ' ';
           setll (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
           dou %eof(haccpv2);
             reade (s_hiwhse: s_hilevl: s_hitype: s_hicode:
                  s_hiseq#) haccpv2;
             if %eof(haccpv2);
               leave;
             endif;
             // check value if no range
             if hvvalr = 0;
               if hvvalu = atype8(edtq);
                 foundvalue = 'Y';
                 avseq(edtq) = hvvsq#;
                 leave;
               endif;
             endif;
             // check range if it exist
             if hvvalr <> 0;
               if hvvalu <= atype8(edtq) and hvvalr >= atype8(edtq);
                 foundvalue = 'Y';
                 leave;
               endif;
             endif;
           enddo;
           if foundvalue = ' ';
           error = *on;
           *in(xedit) = *on;
           endif;
           if error = *on;
             errmsg = desc(1);
             exsr zm0105;
           endif;
         endif;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCHKTYPE9 Check data for answer type 9 fields
     *
     *----------------------------------------------------------------
     C     zzchktype9    begsr
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLOADANSWER Loads the answer into the file field.
     *
     *----------------------------------------------------------------
      /free
       begsr zzloadanswer;
         select;
           when s_hiatyp = '1';
             hldata = atype1(wrtq);
           when s_hiatyp = '2';
             hldata = atype2(wrtq);
           when s_hiatyp = '3';
             hldata = atype3(wrtq);
           when s_hiatyp = '4';
             hldata = atype4(wrtq);
           when s_hiatyp = '5';
             hldata = %char(atype5(wrtq));
           when s_hiatyp = '6';
             hldata = %char(atype6(wrtq));
           when s_hiatyp = '7';
             hldata = %trimr(%editc(atype7(wrtq):'X'));
           when s_hiatyp = '8';
650hD        //hldata = %trim(%editc(atype8(wrtq):'M'));
650hM        hldata = %trim(%editc(atype8(wrtq):'N'));
           when s_hiatyp = '9';
             hldata = %trim(%editc(atype9(wrtq):'X'));
         endsl;
       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
      /free
       begsr zzcmd1;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
      /free
       begsr zzcmd2;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
      /free
       begsr zzdft1;
         #pwhse = $pwhse;
         #ppo = $ppo;
         #phvnam = phvnam;
         #whdesc = whdesc;
         #wodesc = wodesc;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

      /free
       begsr zzfil1;

         #pwhse = $pwhse;
         #ppo = $ppo;
         #phvnam = phvnam;
         #whdesc = whdesc;
         #wodesc = wodesc;
         if  $plevel = 'RCVI';
           w1item = laitem;
           w1lcns = ' ';
         endif;
650cA    if  $plevel = 'REXI';
650cA      w1item = laitem;
650cA      w1lcns = ' ';
650cA    endif;
         if  $plevel = 'RCVL';
           w1item = laitem;
           w1lcns = $license;
         endif;

         select;
           when prvscn = 'Y' and holdwhpg > whpg;
             setll ($pwhse: hblevl: hbtype) haccpqt;
           when morequestions = 'Y';
           when moretypes = 'Y';
           when $ptype = ' ';
             setll ($pwhse: hblevl) haccpqt;
           when $ptype <> ' ';
             setll ($pwhse: hblevl: hbtype) haccpqt;
         endsl;

         dow forevr = forevr;
           select;
             when prvscn = 'Y' and holdwhpg > whpg;
               reade ($pwhse: hblevl) haccpqt;
             when morequestions = 'Y';
             when $ptype = ' ';
               reade ($pwhse: hblevl) haccpqt;
             when $ptype <> ' ';
               reade ($pwhse: hblevl: hbtype) haccpqt;
           endsl;

           if %eof(haccpqt);
             moretypes = ' ';
             leave;
           endif;

           if morequestions = ' ';
             $code = ' ';
           endif;

           select;
             when morequestions = 'Y';
             when hbtype = 'CAT';
               $code = ifcat;
             when hbtype = 'ITM';
               $code = ititem;
             when hbtype = 'DPT';
               $code = itwhdp;
             when hbtype = 'VEN';
               $code = %trim(%editc(phven:'Z'));
           endsl;

           if morequestions = ' ' and prvscn = ' ' or
              morequestions = ' ' and whpg = 0 or
              morequestions = ' ' and moretypes = 'Y' and prvscn = 'Y';
             hilevl = hblevl;
             hitype = hbtype;
740aD        //setll ($pwhse: hilevl: hitype: $code) haccpq3;
740aM        setll ($pwhse: hilevl: hitype: $code) haccpq5;
           endif;

           // read question file for question type
740aD      //dou %eof(haccpq3);
740aD        //reade ($pwhse: hilevl: hitype: $code) haccpq3;
740aD        //if %eof(haccpq3);
740aM      dou %eof(haccpq5);
740aM        reade ($pwhse: hilevl: hitype: $code) haccpq5;
740aM        if %eof(haccpq5);
               morequestions = ' ';
               leave;
             endif;

             // page controls
             if hipge# <> savehipge# and savepage = *on;
               morequestions = 'Y';
740aD          //readpe ($pwhse: hilevl: hitype: $code) haccpq3;
740aD          //if %eof (haccpq3);
740aD            //setll ($pwhse: hilevl: hitype: $code) haccpq3;
740aM          readpe ($pwhse: hilevl: hitype: $code) haccpq5;
740aM          if %eof (haccpq5);
740aM            setll ($pwhse: hilevl: hitype: $code) haccpq5;
               endif;
               leavesr;
             endif;

             select;
               // previous screen is requested, need to check for answers
               // that have already been logged.
               when prvscn = 'Y';
                 exsr zzchklog;

               // *POHDR check to see if header questions have been
               // answered already for this po today don't ask again
               when $pcmd = '*POHDR  ';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

               // if *POHDRCH check to see if header question have been
               // answered for this po today, allow change to answers
               when $pcmd = '*POHDRCH';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

               // *PODTL check to see if detail questions have been
               // answered already for this po today don't ask again
               when $pcmd = '*PODTL  ' and $plevel = 'RCVI';
                 $license = ' ';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

650cA          // *PODTL check to see if detail questions have been
650cA          // answered already for this po today don't ask again
650cA          when $pcmd = '*PODTL  ' and $plevel = 'REXI';
650cA            $license = ' ';
650cA            exsr zzchklog;
650cA            if today = 'Y';
650cA              savetype = hitype;
650cA              iter;
650cA            endif;


               // if *PODTLCH check to see if detail question have been
               // answered for this po today, allow change to answers
               when $pcmd = '*PODTLCH' and $plevel = 'RCVI';
                 $license = ' ';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

650cA          // if *PODTLCH check to see if detail question have been
650cA          // answered for this po today, allow change to answers
650cA          when $pcmd = '*PODTLCH' and $plevel = 'REXI';
650cA            $license = ' ';
650cA            exsr zzchklog;
650cA            if today = ' ';
650cA              savetype = hitype;
650cA              iter;
650cA            endif;


               // *PODTL check to see if detail questions have been
               // answered already for this po today don't ask again
               when $pcmd = '*PODTL  ' and $plevel = 'RCVL';
                 exsr zzchklog;
                 if today = 'Y';
                   savetype = hitype;
                   iter;
                 endif;

               // if *PODTLCH check to see if detail question have been
               // answered for this po today, allow change to answers
               when $pcmd = '*PODTLCH' and $plevel = 'RCVL';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;

               // if *RANDOMC check to see if random question have been
               // answered for this user type today, allow change to answers
               when $pcmd = '*RANDOMC';
                 exsr zzchklog;
                 if today = ' ';
                   savetype = hitype;
                   iter;
                 endif;
             endsl;
             w1levl = hilevl;


             // Load questions to screen fields
             exsr loadquestions;
           enddo;
         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     *----------------------------------------------------------------
      /free
       begsr zzget1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETTIME Get Timestamp information.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgettime;
         getmicrotime(currstampuc:currstampsys);
       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETSUPERPO Get super po number for detail po log
     *
     *----------------------------------------------------------------
      /free
       begsr zzgetsuperpo;
         chain ($pwhse:$ppo) pospo1;
         if not %found(pospo1);
           puspo = ' ';
         endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZGETVENDOR Get Vendor information for super po.
     *
     *----------------------------------------------------------------
      /free
       begsr zzgetvendor;
         exec sql select * into :pohdr
                  from pohdr
                  where phwhse = :$pwhse
640aM               and phpo   = :hlpo;
640aD               //and phpo   = :pupo;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
      /free
       begsr zzinz;

         // Define Key for main file.
         $lprg = #prog;
         $cvprg = #prog;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
      /free
       begsr zzinz2;

         forevr = *off;
         first  = 'Y';
         whpg   = 0;
         hbtype = $ptype;
         hblevl = $plevel;
650dA    poadded = ' ';
650dA    newpo = ' ';
         // Verify warehouse and get description
         whdesc = *blanks;
         $lcmd = '*VERIFY ';
         $lwhse = $pwhse;
      /end-free
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   movel     $lerm         errmsg
     C                   else
     C                   movel     $lerm         whdesc
     C                   endif
      /free
         // get vendor name
         exec sql select * into :pohdr
                  from pohdr
                  where phwhse = :$pwhse
                    and phpo   = :$ppo;
         if sqlstt = sqlSuccess;
         else;
           phvnam = *blanks;
         endif;
         // Get License if *PODTLCH and no license passed in.
         if $pcmd = '*PODTLCH' and $plevel = 'RCVL';
           if $license = ' ';
             setll ($pwhse: $ppo: $pposeq) haccplog2;
             morelicense = 'Y';
           endif;
           if morelicense = 'Y';
             h3_hllcns = ' ';
             dou savelicense <> h3_hllcns or
                 morelicense = ' ';
               reade ($pwhse: $ppo: $pposeq) haccplog2;
               if %eof(haccplog2);
                 morelicense = ' ';
               else;
                 $license = h3_hllcns;
               endif;
             enddo;
               savelicense = h3_hllcns;
           endif;
         endif;

         // Get Item Number if license is passed in on RCVL
         // Load item if item passed in on RCVI
         laitem = *blanks;
         if $plevel = 'RCVI';
           laitem = $license;
         endif;
650cA    if $plevel = 'REXI';
650cA      laitem = $license;
650cA    endif;
         if $plevel = 'RCVL';
           exec sql select * into :licactive
                    from licactive
                    where lawhse = :$pwhse
                      and lalcns = :$license;
         endif;

         // Get item description to display.
         exec sql select * into :piritem
                  from piritem
                  where itwhse = :$pwhse
                    and ititem = :laitem;
         if sqlstt = sqlSuccess;
           wodesc = %trimr(itpdsc) + ' ' + itdesc;
         else;
           wodesc = *blanks;
         endif;
         ifcat = ' ';
         exec sql select * into :itemfld
                  from itemfld
                  where ifwhse = :$pwhse
                    and ifitem = :laitem;
         // get heading for special user type selection
         select;
           when $plevel = 'RCVH';
           when $plevel = 'RCVI';
650cA      when $plevel = 'REXI';
           when $plevel = 'RCVL';
           other;
             chain ($pwhse: $plevel: $ptype) haccpqt;
             if %found(haccpqt);
               hldspecdesc = hbdesc;
             else;
               hldspecdesc = ' ';
             endif;
         endsl;

         // get session id
         exec sql select * into :haccps
                  from haccps
                  where hpuser = :#user
                    and hpjob = :#job
                    and hpjobn = :#jobn;
         exsr scr01i;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ZZUPD1   Update record 1.
     *----------------------------------------------------------------

      /free
       begsr zzupd1;
         error = *off;
         warn = *off;
         wrtq = 0;

         // process all the answers.
         for wrtq = 1 to 10;
           if aseq(wrtq) > 0;
             $keyseq = aseq(wrtq);
             savetime = stime(wrtq);
650bA        savetimeuc = stimeuc(wrtq);
             exec sql select * into :haccpq
                      from haccpq
                      where hiwhse = :$pwhse
                        and hiseq# = :$keyseq;
             if sqlstt = sqlSuccess;
             else;
               error = *on;
               leavesr;
             endif;
             // Check saved array for changes to previous logged answers.
             // This allows me to mark the old answer obsolete.
             select;
               when $pcmd = '*RANDOMC' OR
                    prvscn = 'Y' and $pcmd = '*RANDOM ';
                 // a change was made
                 if atype1(wrtq) <> stype1(wrtq) and s_hiatyp = '1' or
                    atype2(wrtq) <> stype2(wrtq) and s_hiatyp = '2' or
                    atype3(wrtq) <> stype3(wrtq) and s_hiatyp = '3' or
                    atype4(wrtq) <> stype4(wrtq) and s_hiatyp = '4' or
                    atype5(wrtq) <> stype5(wrtq) and s_hiatyp = '5' or
                    atype6(wrtq) <> stype6(wrtq) and s_hiatyp = '6' or
                    atype7(wrtq) <> stype7(wrtq) and s_hiatyp = '7' or
                    atype8(wrtq) <> stype8(wrtq) and s_hiatyp = '8' or
                    atype9(wrtq) <> stype9(wrtq) and s_hiatyp = '9';
                   exsr zzgettime;
                       exec sql update haccplog
                          set hlchgts = :CurrStampsys,
                              hlchguc = :Currstampuc,
                              hlchgcpgm = :$pprg,
                              hlchgjpgm = :#prog,
                              hlchgeusr = :#user,
                              hlobsolete = 'Y'
                          where hladdts = :savetime
                              and hlseq# = :$keyseq;

                   exsr loadnewrandom;
                 else;
                   // no change was made but new question was answered
                   // make sure log record does not already exist
                       exec sql select * into :haccplog
                            from haccplog
                            where hlwhse = :$pwhse
                              and hlexpjusr  = ' '
                              and hlseq# = :$keyseq
                              and hlobsolete <> 'Y';
                   if sqlstt = sqlNoData;
                     exsr loadnewrandom;
                   endif;
                 endif;
               when $pcmd = '*POHDRCH' and $pspo = '*NO ' or
640aD            //$pcmd = '*PODTLCH'  or
640aM            $pcmd = '*PODTLCH'  and $pspo = '*NO ' or
                 prvscn = 'Y' and $pspo = '*NO ';
                 // a change was made
                 if atype1(wrtq) <> stype1(wrtq) and s_hiatyp = '1' or
                    atype2(wrtq) <> stype2(wrtq) and s_hiatyp = '2' or
                    atype3(wrtq) <> stype3(wrtq) and s_hiatyp = '3' or
                    atype4(wrtq) <> stype4(wrtq) and s_hiatyp = '4' or
                    atype5(wrtq) <> stype5(wrtq) and s_hiatyp = '5' or
                    atype6(wrtq) <> stype6(wrtq) and s_hiatyp = '6' or
                    atype7(wrtq) <> stype7(wrtq) and s_hiatyp = '7' or
                    atype8(wrtq) <> stype8(wrtq) and s_hiatyp = '8' or
                    atype9(wrtq) <> stype9(wrtq) and s_hiatyp = '9';
                   exsr zzgettime;
                   exec sql update haccplog
                      set hlchgts = :CurrStampsys,
                          hlchguc = :Currstampuc,
                          hlchgcpgm = :$pprg,
                          hlchgjpgm = :#prog,
                          hlchgeusr = :#user,
                          hlobsolete = 'Y'
                          where hladdts = :savetime
                             and hlseq# = :$keyseq;

                   exsr loadnewpolog;
                 else;
                   // no change was made but new question was answered
                   // make sure log record does not already exist
                   select;
                     when s_hifreq = '2' and s_hitype = 'CAT' or
                          s_hifreq = '2' and s_hitype = 'DPT' or
                          s_hifreq = '2' and s_hitype = 'ALL' or
                          s_hifreq = '3' and s_hitype = 'CAT' or
                          s_hifreq = '3' and s_hitype = 'DPT' or
                          s_hifreq = '3' and s_hitype = 'ALL';
                       exec sql select * into :haccplog
                            from haccplog
                            where hlwhse = :$pwhse
                              and hlpo   = :$ppo
                              and hlposeq = 0
                              and hllcns  = ' '
                              and hlseq# = :$keyseq
                              and hlobsolete <> 'Y';
                     other;
                       exec sql select * into :haccplog
                            from haccplog
                            where hlwhse = :$pwhse
                              and hlpo   = :$ppo
                              and hlposeq = :$pposeq
                              and hllcns  = :w1lcns
                              and hlseq# = :$keyseq
                              and hlobsolete <> 'Y';
                   endsl;
                   if sqlstt = sqlNoData;
                     exsr loadnewpolog;
                   endif;
                 endif;
               when $pcmd = '*POHDRCH' and $pspo = '*YES' or
640aA               $pcmd = '*PODTLCH' and $pspo = '*YES' or
                    //$pcmd = '*PODTLCH' and $pspo = '*YES' or
                    prvscn = 'Y' and $pspo = '*YES' and $plevel = 'RCVH';
                 if atype1(wrtq) <> stype1(wrtq) and s_hiatyp = '1' or
                    atype2(wrtq) <> stype2(wrtq) and s_hiatyp = '2' or
                    atype3(wrtq) <> stype3(wrtq) and s_hiatyp = '3' or
                    atype4(wrtq) <> stype4(wrtq) and s_hiatyp = '4' or
                    atype5(wrtq) <> stype5(wrtq) and s_hiatyp = '5' or
                    atype6(wrtq) <> stype6(wrtq) and s_hiatyp = '6' or
                    atype7(wrtq) <> stype7(wrtq) and s_hiatyp = '7' or
                    atype8(wrtq) <> stype8(wrtq) and s_hiatyp = '8' or
                    atype9(wrtq) <> stype9(wrtq) and s_hiatyp = '9';
                   // get all po's for the super po
640aA              if $pcmd = '*PODTLCH';
640aA                exsr zzgetsuperpo;
640aA                setll ($pwhse: puspo) pospo;
640aA              else;
640aA                setll ($pwhse: $ppo) pospo;
640aA              endif;
                   dow not %eof(pospo);
640aA                if $pcmd = '*PODTLCH';
640bA                  if s_hitype <> 'ITM' and s_hilevl <> 'RCVL';
640aA                    reade ($pwhse: puspo) pospo;
640bA                  endif;
640aA                else;
                       reade ($pwhse: $ppo) pospo;
640aA                endif;
                     if %eof(pospo);
                       leave;
                     endif;
                     exsr zzgettime;
640aA                select;
640aA                  when s_hifreq = '2' and s_hitype = 'CAT' or
640aA                       s_hifreq = '2' and s_hitype = 'DPT' or
640aA                       s_hifreq = '2' and s_hitype = 'ALL' or
640aA                       s_hifreq = '3' and s_hitype = 'CAT' or
640aA                       s_hifreq = '3' and s_hitype = 'DPT' or
640aA                       s_hifreq = '3' and s_hitype = 'ALL';
640aA                    exec sql update haccplog
640aA                       set hlchgts = :CurrStampsys,
640aA                           hlchguc = :Currstampuc,
640aA                         hlchgcpgm = :$pprg,
640aA                         hlchgjpgm = :#prog,
640aA                         hlchgeusr = :#user,
640aA                         hlobsolete = 'Y'
640aA                       where hlwhse = :$pwhse
640aA                           and hlpo = :pupo
640aA                           and hlposeq = 0
640aA                           and hllcns = :w1lcns
640aA                           and hlseq# = :$keyseq;
640aA                  other;
                         exec sql update haccplog
                            set hlchgts = :CurrStampsys,
                                hlchguc = :Currstampuc,
                                hlchgcpgm = :$pprg,
                                hlchgjpgm = :#prog,
                                hlchgeusr = :#user,
                                hlobsolete = 'Y'
                            where hlwhse = :$pwhse
                                and hlpo = :pupo
                                and hlposeq = :$pposeq
                                and hllcns = :w1lcns
                                and hlseq# = :$keyseq;
640aA                endsl;
                     exsr loadnewpolog;
640aA                if $pcmd = '*PODTLCH' and
640bA                     s_hitype = 'ITM' or
                        $pcmd = '*PODTLCH' and s_hilevl = 'RCVL';
                          leave;
                     endif;
                   enddo;
                 else;
                   // get all po's for the super po
640aA              if $pcmd = '*PODTLCH';
640aA                exsr zzgetsuperpo;
640aA                setll ($pwhse: puspo) pospo;
640aA              else;
                     setll ($pwhse: $ppo) pospo;
640aA              endif;
                   dow not %eof(pospo);
640aA                if $pcmd = '*PODTLCH';
640bA                  if s_hitype <> 'ITM' and s_hilevl <> 'RCVL';
640aA                    reade ($pwhse: puspo) pospo;
640bA                  endif;
640aA                else;
                       reade ($pwhse: $ppo) pospo;
640aA                endif;
                     if %eof(pospo);
                       leave;
                     endif;
                     // no change was made but new question answered
                     // make sure log record does not already exist
                     select;
                       when s_hifreq = '2' and s_hitype = 'CAT' or
                            s_hifreq = '2' and s_hitype = 'DPT' or
                            s_hifreq = '2' and s_hitype = 'ALL' or
                            s_hifreq = '3' and s_hitype = 'CAT' or
                            s_hifreq = '3' and s_hitype = 'DPT' or
                            s_hifreq = '3' and s_hitype = 'ALL';
                         exec sql select * into :haccplog
                              from haccplog
                              where hlwhse = :$pwhse
                                and hlpo   = :pupo
                                and hlposeq = 0
                                and hllcns  = ' '
                                and hlseq# = :$keyseq
                                and hlobsolete <> 'Y';
                       other;
                         exec sql select * into :haccplog
                              from haccplog
                              where hlwhse = :$pwhse
                                and hlpo   = :pupo
                                and hlposeq = :$pposeq
                                and hllcns  = :w1lcns
                                and hlseq# = :$keyseq
                                and hlobsolete <> 'Y';
                     endsl;
                     if sqlstt = sqlNoData;
                       exsr loadnewpolog;
                     endif;
640aA                if $pcmd = '*PODTLCH' and
640bA                     s_hitype = 'ITM' or
640aA                   $pcmd = '*PODTLCH' and s_hilevl = 'RCVL';
                          leave;
                     endif;
                   enddo;
                 endif;
             endsl;

             select;
               when $pcmd = '*POHDRCH'  or
                    $pcmd = '*RANDOMC'  or
                    $pcmd = '*PODTLCH';
               when prvscn = 'Y';
               when $pcmd = '*POHDR  ';
                 if $pspo = '*YES';
                   // get all po's for the super po
                   setll ($pwhse: $ppo) pospo;
                   dow not %eof(pospo);
                     reade ($pwhse: $ppo) pospo;
                     if %eof(pospo);
                       leave;
                     endif;
                     exsr loadnewpolog;
                   enddo;
                 else;
                   exsr loadnewpolog;
                 endif;
               when $pcmd = '*PODTL  ';
640bA            select;
640bA              when $pspo = '*YES' and s_hifreq = '2' and s_hitype = 'ITM';
640bA                // get the super po
640bA                exsr zzgetsuperpo;
640bA                exsr loadnewpolog;

640bM              when $pspo = '*YES' and s_hifreq = '2';
640bD            //if $pspo = '*YES' and s_hifreq = '2';
640aA              // get the super po
640aA              exsr zzgetsuperpo;
640aA              // get all po's for the super po
640aA              setll ($pwhse: puspo) pospo;
640aA              dow not %eof(pospo);
640aA                reade ($pwhse: puspo) pospo;
640aA                if %eof(pospo);
640aA                  leave;
640aA                endif;
640aA                exsr loadnewpolog;
640aA              enddo;
640bD            //else;
640aA              other;
640aA              exsr loadnewpolog;
640bA            endsl;
640bD            //endif;
640aD            //exsr loadnewpolog;
               other;
                 exsr markoldrandom;
                 exsr loadnewrandom;
             endsl;


           else;
             leave;
           endif;
         endfor;
         // clear fields

         aseq = 0;
         //prvscn = ' ';
         atype = ' ';
         clear stime;
650bA    clear stimeuc;
         clear savetime;
650bA    clear savetimeuc;
         exsr zzclrarray;

       endsr;
      /end-free
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
** desc **
Invalid Answer
Answer
Invalid Date
Date
Outside of Range
