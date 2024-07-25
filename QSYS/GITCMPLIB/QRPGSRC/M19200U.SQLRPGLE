      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  M19200U    Receiving Catch Weight entry/update
     *  08 December 2015
     *  Lynn McMahon
     *
     *
     *  Revisions
     *    12/08/15  LMC  7.00
     *      - Created
700aA*    04/20/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
700bA*    06/07/16  LMC  7.00b
     *      - CW ovr filds were move to pirhold record. Remove D specs
720aA*    07/26/16  MR/LMC   7.20a
     *      - Enh: Populate parm values in DRIUICINFO
     *             for new UCIINFO file format.
     *      This program is using the UCIINFO file to store detail
     *      weights from receiving. These are not true UCI records
     *      NO tracking is done on UCIINFO records that are created
     *      by this program.
750a *    02/11/21  RTR  7.50a
     *      - Fix: Trap duplicate key error writing to PIRHOLD.
750b *    03/26/21  LMC  7.50b
     *      - Enh: Add logic to trap large weight so it doesn't
     *        error at 80400.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpirhold   uf a e           k disk
     Fpocwtmp   uf a e           k disk
     F                                     rename(pcwrec:record2)
     Fwarehs    if   e           k disk
     Foptions   if   e           k disk
     Fitemmsc   if   e           k disk
     Fpiritem   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS
     *----------------------------------------------------------------
     *  pirhold structures
     *----------------------------------------------------------------
      /copy qcopysrc,C#PIRHLDPO
      /copy qcopysrc,C#PIRHLDCW
      /copy qcopysrc,C#PIRHLDCT

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#UCIINFO
     D savever#        s                   like($uiver#)

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Called program parameters
     *
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *****OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPWRNC  -  Check CW variance during selection closing (N,M,C,B)
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *****OPICW   -  Individual catch weight entry (Y,N).
     *    OPICW   -  Check CW count during selection closing (N,M,C,B)
     *    OPWRNCR -  Check CW variance during Rcv inividual entry(Y,N)
     *    OPICWR  -  Check CW count during Rcv individual entry (Y,N)
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  opuci                 36     36
     D  opwrncr               37     37
     D  opicwr                38     38
     D  optend               117    117
     *
     *----------------------------------------------------------------
     *  Name constants
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS
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
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erfld1                 1     20
     D  erfld2                21     40
     D  erflvl                41     42p 0
     D  erclvl                43     44p 0
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte
700aA /copy qcopysrc,p.getimuom
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D ucilic#         pr                  extpgm('UCILIC#')
      * Input
     D   unext                       13  0 const
     D   uwhse                        3  0 const

     *----------------------------------------------------------------
     *  Variables
     *

     D currtimestamp   s               z

     D client          s             10
     D clientloc       s             10

     D pMessage        s             99
     D psessid         s             40
     D puser           s             10
     D ppgm            s             10
     D pwhse           s              3  0
     D ppo             s              9
     D pposeq          s              5  0
     D ppoitem         s             15
     D w1endry         s            100
     D ppqty1          s              5  0
     D ppqty2          s              5  0
     D ppqty3          s              5  0
     D pndcwtck        s              1
     D pcwtckw         s              1
     D pndcweck        s              1
     D pcweckw         s              1
     D pndtwtck        s              1
     D ptwtckw         s              1
     D paction         s              1
700aAD pkilolbsSent    s              1
     D psvtcw          s              9  2
     D w1entry         s             50
     D Pkey            s             50
     D pokey           s             50

     D forever         s               n

     D $msgf           s             10
     D $unext          s             13  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D ck4err          s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D*cweck           s              1
     D*cwtck           s              1
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D extwg2          s                   like(exwgt)
     D extwg3          s                   like(exwgt)
700bDD*exwgt           s              9  2
     D help            s              5  0
700bDD*hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D lstseq          s                   like(pcwsq2)
     D lvskp           s              1
700bDD*lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D olywg2          s                   like(itswgt)
     D olywg3          s                   like(itswgt)
700bDD*prg1c           s              4  3
700bDD*prg2c           s              4  3
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D taddw           s              7  2
     D totrcv          s              5  0
     D uciexists       s               n
     D unexta          s             13
     D warn            s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D wttcw           s              7  2
     D w1addw          s              7  0
     D zmflag          s               n
     D zmsflag         s               n

     D WOCW#           s              7  0
     D WOTCW           s              9  2
     D W1SEQ           s              4  0
     D W1WGT           s             50
     D W1CWGT          s              7  0
     D Workwgt         s              7  2
     *----------------------------------------------------------------
     *  CVTDTE constant and parameter data structure.
     *----------------------------------------------------------------

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
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist

     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pPgm
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pPOSeq
     c                   parm                    pPOItem
     c                   parm                    w1entry
     c                   parm                    pkey
     c                   parm                    pPqty1
     c                   parm                    pPqty2
     c                   parm                    pPqty3
     c                   parm                    pndcwtck
     c                   parm                    pcwtckw
     c                   parm                    pndcweck
     c                   parm                    pcweckw
     c                   parm                    pndtwtck
     c                   parm                    ptwtckw
     c                   parm                    psvtcw
     c                   parm                    paction
700aAc                   parm                    pkilolbsSent
     *
     *----------------------------------------------------------------
     *  Main line
     *
      /free
        *inlr = *on;
        puser = %xlate(xlower: xupper: puser);
        // Get hold data for item being received
        hotype = 'PODTL';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X')) + %trim(pPOItem);
        chain(n) (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          pirhldpods = hodata;
        else;
        endif;

        error = *off;

          select;
            when paction = 'F';
              exsr zzfinalize;
            other;
              exsr zzinz2;

              if error = *on;
                return;
              endif;
              exsr edit;
          endsl;


      /end-free
     *
     *
     *   Do some clean up before leaving.
     *
     C                   return
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  Edit -  Edit
     *
     C     edit          begsr
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endedit
     C                   exsr      zzupd3
     C     error         cabeq     *on           endedit
     *
     *
     *
     *  Everything went fine so get out of program.
     *
     *
     C     endedit       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     C                   endsr

     *
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = 0
     C                   eval      $uiaddusr = puser
     C                   eval      $uiaddpgm  = #pgm
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobnbr
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
720aAC                             or $dricommand = '*UCIINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C                   when      zmflag
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization.
     *
     C     zzinz         begsr
     *
      /free
         // seq 000 is used for the current record editing.
         // it is removed once edits are passed and cw is updated
         hotype = 'PODTLCW';
           pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                 + %trim(pPOItem) + '0000';
         chain(N) (psessid: hotype: pokey) pirhold;
         if %found(pirhold);
           pirhldcwds = hodata;
         endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
      /free
        chain (wkwhse: wkcode) options;
      /end-free
     c                   if        not %found(options)
     C                   eval      opcapc = 'Y'
     C                   eval      opwrncr = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicwr = 'N'
     C                   endif
     *
     *
     *    Define working variables.
     *
     *    Compute total qty received.
      /free
        totrcv = ppqty1 + ppqty2 + ppqty3;
      /end-free
     *
     *   Initialize counter and total fields.
     C                   eval      wocw# = 0
     C                   eval      wotcw = 0
     C                   eval      lstseq = 0
     C                   eval      w1addw = *zeros
     C                   eval      cwtck = *off
     C                   eval      cweck = *off
     C                   eval      twtck = *off
     C                   exsr      scr03i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C*                  eval      ovrrid = *off
     *
     *
     *  Get field defaults if this is an add.
     *
     C                   if        paction = 'A'
     C                   exsr      zzdft3
     C                   exsr      zzfil3
     c                   exsr      zzinz
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   exsr      zzfil3
     c                   exsr      zzinz
     C                   endif
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     C                   eval      w1addw = 0
     C                   eval      lstseq = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *    Compute total qty received.
     C*    $pqyr1        add       $pqyr2        wopqty
     C*                  add       $pqyr3        wopqty
     C*                  eval      wopo = ppo
     *
      /free
        itumq2 = 0;
        itumq3 = 0;
        chain (pwhse: ppoitem) piritem;
      /end-free
     *
     *    Convert weight for break-down 2 qty.
     C                   if        itumq2 > *zeros
     C     itswgt        div(h)    itumq2        olywg2
     C                   else
     C                   eval      olywg2 = *zeros
     C                   endif
     *
     *    Convert weight for break-down 3 qty.
     C                   if        itumq3 > *zeros
     C     itswgt        div(h)    itumq3        olywg3
     C                   else
     C                   eval      olywg3 = *zeros
     C                   endif
     *
     *
     *   If verify catch weight = yes,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        opwrncr = 'Y'
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C                   eval      ilvar = 0
     C                   eval      ihvar = 0
     C                   eval      ilrng = 0
     C                   eval      ihrng = 0
     *
     *    Extend weight for case qty.
     C     ppqty1        mult      itswgt        exwgt
     *
     *    Extend weight for break-down 2 qty.
     C                   if        ppqty2 > *zeros
     C                   if        olywg2 > *zeros
     C     ppqty2        mult      olywg2        extwg2
     C                   else
     C                   eval      extwg2 = *zeros
     C                   endif
     C                   add       extwg2        exwgt
     C                   endif
     *
     *    Extend weight for break-down 3 qty.
     C                   if        ppqty3 > *zeros
     C                   if        olywg3 > *zeros
     C     ppqty3        mult      olywg3        extwg3
     C                   else
     C                   eval      extwg3 = *zeros
     C                   endif
     C                   add       extwg3        exwgt
     C                   endif
     *
     **   Iniz. flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     **   Use item variance % if it exists
      /free
        chain (pwhse: ppoitem) itemmsc;
      /end-free
     C                   if        %found(itemmsc)
     *
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C                   eval      ilvar = itswgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   eval      ilrng = itswgt - ilvar
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C                   eval      ihvar = itswgt * prg2c
     C                   endif
     C     exwgt         add       hivar         hirng
     C     itswgt        add       ihvar         ihrng
     *
     C                   endif
     *
     C                   eval      w1addw = *zeros
     *
      /free
        // use pirhold instead of pocwtmp
        hotype = 'PODTLCW';
        setll (psessid: hotype) pirhold;
        stop = *off;
        dou stop = *on;
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            stop = *on;
          else;
            pirhldcwds = hodata;
            if cwseq# <> 0;
              wotcw = wotcw + weightd;
              wocw# = wocw# + 1;
              eval w1seq = pcwsq2;
            endif;
          endif;
          enddo;
        setll (pwhse: ppo: pposeq) pocwtmp;
        stop = *off;
        dou stop = *on;
          reade(n) (pwhse: ppo: pposeq) pocwtmp;
          if %eof(pocwtmp);
            stop = *on;
          else;
            wotcw = wotcw + pcwwgt;
            wocw# = wocw# + 1;
            eval w1seq = pcwsq2;
      /end-free
     *
     *    Move decimal point 2 places to the right for display.
     C                   move      pcwwgt        w1cwgt
      *this need to be loaded from uci if we are doing update
      * this changes with gui can come from the pirhold
     C*                  eval      w1ent = w1entry
     C*                  exsr      sfladd
     C                   eval      lstseq = pcwsq2
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     *   CWTCK Flags are used to force F20 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
      /free
        // if user is deleting skip all the edits
        if paction = 'D';
          leavesr;
        endif;
      /end-free
     c
     *
     C                   eval      $cbbar = w1entry
     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm      *zeros        $cbcod            3 0
     C                   parm      *zeros        $cbdec            1 0
     C                   parm      *blanks       $cbdsc           30
     C                   parm      *zeros        $cbpos            3 0
     C                   parm      *zeros        $cbtyp            1 0
     C                   parm      *zeros        $cbv1            11 3
     C                   parm      *blanks       $cbv2            50
     C                   parm      *blanks       $cbrtn            8
     C                   parm      *blanks       $cberm           60
700aAC                   parm      0             $cbven           10 0
700aAC                   parm                    $cvtdata        256
700aAC                   parm                    $cvtdata2       256
700aAC                   parm      pwhse         $cbwhse           3 0
700aAC                   parm      pkilolbsSent  $cbsent           1
     *
     *    Weight converted successfully.
     C                   select
750bDC*                  when      $cbrtn = '*OK'
7505Mc                   when      $cbrtn = '*OK' and $cbv1 <= 99999.99
     C     $cbv1         mult      100           w1addw
     *
     *    Error occured while converting weight.
     C                   other
     C                   eval      error = *on
     c                   eval      pmessage = 'Error converting weight'
     C                   goto      endck3
     C                   endsl
     *
     *   Verify catch weight add.
     *
     C                   if        w1addw <> *zero
     *
     C                   if        svaddw <> w1addw
     C                   eval      cwtck = *off
     C                   endif
     *
     C                   if        cwtck = '2'  and
     C                             pcwtckw = 'Y'
     C                   eval      cwtck = *on
     C                   endif
     *
     C                   if        cwtck <> '1'
     C                   eval      cwtck = *on
     *
     *     Verify catch weight is within range.
     *
     C                   if        w1addw < 0  or
     C                             w1addw > 9999999
     C                   eval      error = *on
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     'Weight'      erfld
     C                   movel     '0'           erfrom
     C                   movel     '9999999'     erto
     C                   exsr      zm0112
     C                   endif
     *
     *     Check individual CW if variance check = Y.
     *
     C                   if        opwrncr = 'Y'
     C                             and opicwr = 'Y'
     C     w1addw        div       100           taddw
     *
     C                   if        lvskp = *off  and
     C                             taddw < ilrng
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      pndcwtck = 'N'
     C                   eval      cwtck = '2'
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   eval      erlrng = ilrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = ihrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
      /free
        pmessage = 'Warning: Catch weight of ' +
                     %char(ertcwt) + ' is not within -/+ ' +
                    'range of ' +%char(erlrng) + '-' + %char(erhrng);
      /end-free
     C*                  exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             taddw > ihrng
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      pndcwtck = 'N'
     C                   eval      cwtck = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = taddw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = ilrng
     C                   endif
     C                   eval      erhrng = ihrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
      /free
        pmessage = 'Warning: Catch weight of ' +
                     %char(ertcwt) + ' is not within -/+ ' +
                    'range of ' +%char(erlrng) + '-' + %char(erhrng);
      /end-free
     C                   endif
     *
     *
     C                   endif
     *
     C                   endif
     C                   endif
     *
     *   Save screen fields.
     C                   exsr      zzsave
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Screen 3 error check totals  - this is no longer needed
     *
     C     zzchkt        begsr
     *   CWECK, TWTCK Flags are used to force F20 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     *
     *     Check # of entrys if individual catchweight entry = Y
     *
     C                   if        opicwr = 'Y'
     *
     C                   if        svcw# <> wocw#
     C                   eval      cweck = *off
     C                   endif
     *
     C                   if        cweck = '2'  and
     C*                            ovrrid = *on
     C                             pcweckw = 'Y'
     C                   eval      cweck = *on
     C                   endif
     *
     C                   if        cweck <> '1'
     C                   eval      cweck = *on
     *
     C                   if        wocw# <> totrcv
     C                   eval      error = *on
     *    Nbr catchwgts entered cannot exceed quantity received.
     C                   if        wocw# > totrcv
     C                   eval      cweck = *off
     C                   else
     C                   eval      cweck = '2'
     C                   eval      pndcweck = 'N'
     C                   endif
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     wocw#         ertcw#
     C                   eval      erqpck = totrcv
     C                   exsr      zm20
     C                   endif
     C     error         cabeq     *on           enderr
     C                   endif
     C                   endif
     *
     *
     *
     *     Compare total catchweight to expected catchweight
     *
     C                   if        opwrncr = 'Y'
     *
     C                   if        svtcw <> wotcw
     C                   eval      twtck = *off
     C                   endif
     *
     C                   if        twtck = '2'  and
     C*                            ovrrid = *on
     C                             ptwtckw = 'Y'
     C                   eval      twtck = *on
     C                   endif
     *
     C                   if        twtck <> '1'
     C                   eval      twtck = *on
     *
     *
     C                   if        lvskp = *off  and
     C                             wotcw < lwrng
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      pndtwtck = 'N'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   eval      erlrng = lwrng
     C                   if        hvskp = *on
     C                   eval      erhrng = 0
     C                   else
     C                   eval      erhrng = hirng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     C                   if        hvskp = *off  and
     C                             wotcw > hirng
     C                   eval      error = *on
     C                   eval      twtck = '2'
     C                   eval      warn = *on
     C                   eval      pndtwtck = 'N'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = wotcw
     C                   if        lvskp = *on
     C                   eval      erlrng = 0
     C                   else
     C                   eval      erlrng = lwrng
     C                   endif
     C                   eval      erhrng = hirng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   exsr      zm19
     C                   endif
     *
     C     error         cabeq     *on           enderr
     C                   endif
     *
     C                   endif
     C     enderr        tag
     *   Save screen fields.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     *
     *  If user is adding a detail record ...
     *    - add it to pirhold
     *
      /free
        // if user is deleting a record.
        // just delete and get out of this subroutine
        if paction = 'D';
          hosess = pSessId;
          hotype = 'PODTLCW';
          hokey = pkey;
          chain (hosess: hotype: hokey) pirhold;
          if %found(pirhold);
            delete horec;
          endif;
          exsr zzsavetotals;
          leavesr;
        endif;
        if w1addw <> *zero;
          select;
            when paction = 'A';
              // first need to get the last used seq#
              hosess = pSessId;
              hotype = 'PODTLCW';
              setgt (hosess: hotype) pirhold;
              readpe (hosess: hotype) pirhold;
              if %eof(pirhold);
                w1seq = 1;
              else;
                pirhldcwds = hodata;
                w1seq = cwseq# + 1;
              endif;

              // reset pokey for add
              pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                    + %trim(pPOItem) + %trim(%editc(w1seq:'X'));
              cwseq# = w1seq;
              cwentered = w1entry;
              weight = w1addw;
              workwgt = w1addw / 100;
              weighta =  %editc(workwgt:'3');
              // these two fields are not needed in actual cw record
              // only used in the seq 0000 for edit purpose
              svaddw = 0;
              cwtck = ' ';
              exsr getcurrstamp;
              hoaddts = currstampsys;
              hoadduc = currstampuc;
              hokey = pokey;
              hodata = pirhldcwds;
750aD       //write horec;
750aM         write(e) horec;
              // now delete the temp record used for editting
              pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
              + %trim(pPOItem) + '0000';
              chain (hosess: hotype: pokey) pirhold;
              if %found(pirhold);
                delete horec;
              endif;

            when paction = 'U';

              hosess = pSessId;
              hotype = 'PODTLCW';
              hokey = pkey;
              chain (hosess: hotype: hokey) pirhold;
              if %found(pirhold);
                pirhldcwds = hodata;
                cwentered = w1entry;
                weight = w1addw;
                workwgt = w1addw / 100;
                weighta =  %editc(workwgt:'3');
                exsr getcurrstamp;
                hoaddts = currstampsys;
                hoadduc = currstampuc;
                hodata = pirhldcwds;
                update horec;
              endif;
              // now delete the temp record used for editting
              pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
              + %trim(pPOItem) + '0000';
              chain (hosess: hotype: pokey) pirhold;
              if %found(pirhold);
                delete horec;
              endif;
          endsl;
          exsr zzsavetotals;
      /end-free
     *
     C                   goto      endup3
     C                   endif
      * this would be when user presses done
     *
     *  Update detail first.
     *
     C*                  exsr      zzusub
     C     error         cabeq     *on           endup3
     *
     *
     C     endup3        endsr
     *
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C*                  exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13020  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
      /free
        pmessage = 'Warning: Total catch weight of ' +
                     %char(wotcw) + ' is not within -/+ ' +
                    'range of ' +%char(erlrng) + '-' + %char(erhrng);
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *   PT13019  # of catch weights entered must = Quantity picked.
     *
     C     zm20          begsr
      /free
        pmessage = '# of catch weights entered is not equal to  +
                    the quantity received';
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZTOTL   Recalculate total cw and entered cw.
     *
     C     zztotl        begsr
     C                   eval      error = *off
     C                   eval      wotcw = 0
     C                   eval      wocw# = 0
     *
     *   Loop through subfile records and recaluclate.
     C                   if        reccnt > 0
     C                   eval      *in85 = *on
     C                   eval      *in79 = *off
     C                   dou       *in79
     C*                  readc     detail1                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in85 = *on
     C*                  update    detail1
     *
     C     w1cwgt        div       100           wttcw
     C                   add       wttcw         wotcw
     C                   if        wttcw > 0
     C                   add       1             wocw#
     C                   endif
     C                   enddo
     C                   eval      *in85 = *off
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFINALIZE   Update using PIRHOLD records. - WAS ZZUSUB IN CW122
     *
     C     zzfinalize    begsr
      /free

        // first we delete everything that was previously loaded
        setll (pwhse: ppo: pposeq) pocwtmp;
        dow forever = forever;
          reade (pwhse: ppo: pposeq) pocwtmp;
          if %eof(pocwtmp);
            leave;
          endif;
          delete record2;
        enddo;

        // still need to delete uciinfo records
        exsr zzucicancel;

        // get the pirhold records
        hotype = 'PODTLCW';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
              + %trim(pPOItem) + '0000';
        setll (psessid: hotype: pokey) pirhold;
        dow forever = forever;
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
          // got a record in pirhold
           pirhldcwds = hodata;
           // exclude seq 0000 - these are temporary and should be gone
           if cwseq# <0;
             iter;
           endif;
           // begin the finalize process
           pcwwhs = pwhse;
           pcwpo = ppo;
           pcwseq = pPOSeq;
           pcwitm = ppoitem;
           pcwsq2 = cwseq#;
           pcwwgt = weightd;
           write record2;
           exsr zzuciadd;
        enddo;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUCIADD Add weight record to uciinfo.
     *
     C     zzuciadd      begsr
      /free
        exsr clr$uciinfo;
        $uiWhse = pwhse;
        $uiItem = ppoitem;
        $uiuci = cwentered;
        ucilic#($unext: pwhse);
        unexta = %editc($unext:'X');
        $uiuciLcns = 'U:' + unexta;
        $uiLcns = 'T' + ppo + %editc(pPOSeq:'X');
720aA   $uiaLcns = 'T' + ppo + %editc(pPOSeq:'X');
720aA   $uiaoLcns = 'T' + ppo + %editc(pPOSeq:'X');
        $uiseq = 1;
        $uiselcseq  = cwseq#;
        $uiSerial = ' ';
        $uiwgtlbs = pcwwgt;
        $uiWgtKgs = 0;
        $uiSelTrn# = 0;
        $uiSelLbl# = 0;
        $uiSelOrd = 0;
        $uiSelSeq = 0;
        $uiSelTrax = ' ';
        $uiCrtBy = '6';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADD';
        $drisys2upd = 'D';
        ck4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUCICANCEL Removes all records with the temporary license.
     *
     C     zzucicancel   begsr
      /free
        exsr clr$uciinfo;
        $uiWhse = pwhse;
        // This is a temporary catch weight license
        $uiLcns = 'T' + ppo + %editc(pPOSeq:'X');

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%CANCEL';
        $drisys2upd = 'D';
        ck4err = *on;
        zmflag  = *off;
        exsr zzzdricop;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZsave   Save all the data in pirhold
     *
     C     zzsave        begsr
     *
     *   Save screen fields.
      /free
        svaddw = w1addw;
        cwseq# = 0;
        cwentered = w1entry;
        weight = w1addw;
        workwgt = w1addw / 100;
        weighta =  %editc(workwgt:'3');
        hotype = 'PODTLCW';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
              + %trim(pPOItem) + '0000';
        chain (psessid: hotype: pokey) pirhold;
        hodata = pirhldcwds;
        if %found(pirhold);
          update horec;
        else;
          exsr getcurrstamp;
          hoaddts = currstampsys;
          hoadduc = currstampuc;
          hosess = psessid;
          hokey = pokey;
          write horec;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZsaveTotals Saves total info.
     *
     C     zzsavetotals  begsr
      /free
        // first I need to get my totals from the PODTLCW records
        wotcw = 0;
        wocw# = 0;
        hotype = 'PODTLCW';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
                 + %trim(pPOItem) + '0000';
        setll (psessid: hotype: pokey) pirhold;
        dow forever = forever;
          reade (psessid: hotype) pirhold;
          if %eof(pirhold);
            leave;
          endif;
          pirhldcwds = hodata;
          if cwseq# <> 0;
            wotcw = wotcw + weightd;
            wocw# = wocw# + 1;
          endif;
        enddo;
        //
        hotype = 'PODTLCT';
        pokey = %trim(pPO) + %trim(%editc(pPOSeq:'X'))
              + %trim(pPOItem);
        chain (psessid: hotype: pokey) pirhold;
        if %found(pirhold);
          // determine if flags need to be reset
          pirhldctds = hodata;
          // if the counts change the cntflag needs reset
          if wocw# <> svcw#;
            select;
              when wocw# = (ppqty1 + ppqty2 + ppqty3);
                cntflag = ' ';
              when wocw# = 0;
                cntflag = '1';
              other;
                cntflag = '2';
            endsl;
          endif;
          // if the weights have changed the varflag needs reset
          if wotcw <> svtcw;
            select;
              when wotcw >= lwrng and wotcw <= hirng;
                varflag = ' ';
              when wotcw = 0;
                varflag = ' ';
              other;
                varflag = '2';
            endsl;
          endif;
          svcw# = wocw#;
          svtcw = wotcw;
          hodata = pirhldctds;
          update horec;
        else;
          svcw# = wocw#;
          svtcw = wotcw;
          if wocw# < (ppqty1 + ppqty2 + ppqty3);
            cntflag = '2';
          endif;
          if wotcw < lwrng or  wotcw >  hirng;
            varflag = '2';
          endif;
          hodata = pirhldctds;
          exsr getcurrstamp;
          hoaddts = currstampsys;
          hoadduc = currstampuc;
          hosess = psessid;
          hokey = pokey;
          write horec;
        endif;
      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C*                  movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C*                  exsr      zmpmsg
     C                   endsr
