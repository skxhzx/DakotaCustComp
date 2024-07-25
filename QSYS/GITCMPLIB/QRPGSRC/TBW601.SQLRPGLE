     h DftActgrp(*NO) ActGrp(*Caller)

      *----------------------------------------------------------------
      *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TBW601  Truckbuilder Wave Allocate/Build and Print/Stage
     *  29 January 2020
     *  Kenneth Elder
     *
     *    01/29/20  KDE  7.40
     *      - Created
     *
     *----------------------------------------------------------------
     * Notes
     *
     * This program Calls OR605 for both *ALOCBLD and *STGPRNT for
     * Wave processing.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Foptions   if   e           k disk
     frtehed    if   e           k disk
     frtelm     if   e           k disk
     ftbwaved   if   e           k disk

     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 1=Auto, 2=Manual.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D OPDATA          DS
     D  OPATYP                 1      1
     D  OPLTYP                 2      2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#usfcrp
      /copy qcopysrc,id#usfasys
      /copy qcopysrc,id#usfpsys

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     d                sds
     d  #prog            *proc
     d  #status               11     15
     d  #stmt                 21     28  0
     d  #pgmmsg               91    170
     d  #job                 244    253
     d  #user                254    263
     d  #jobn                264    269
     d  #jobnbr              264    269
     d  #jobdt               276    281  0
     d  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Called program parameters - Only using redefined parms
     *----------------------------------------------------------------

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
     D  $lwhdp                22     26
     D  $ldoor                27     29  0
     *
     D  $lhdte                22     29  0
     D  $lhtim                30     35  0
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
     D  $phdte                22     29  0
     D  $phtim                30     35  0
     D  $ppass                36     38  0
     D  $pdoor                39     41  0
     D  $pwhdp                42     46
     D  $prtid                47     51
     D  $prtec                52     56P 3
520 AD  $patyp                57     57
     *
     D $dparms         ds
     D  $dpcmd                 1      8
     D  $dpprg                 9     18
     D  $dpuky                19     68
     D  $dprtn                69     76
     D  $dperm                77    136
     D  $dpmsg                77     80
     *
     *   Redefine key
     *
     D  $dpwhse               19     21  0
     D  $dprte                22     26
     D  $dprtid               27     31
     D  $dptruk               32     41
     D  $dpstat               42     42
     D  $dptype               43     43
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
     D  $cvdr1               133    140
     D  $cvvl1               141    145  0
     D  $cvdr2               146    153
     D  $cvvl2               154    158  0
     D  $cvdr3               159    166
     D  $cvvl3               167    171  0
     D  $cvdr4               172    179
     D  $cvvl4               180    184  0

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D branch_id       s              2
     d division        s              3
     d error           s               n
     d nWhse           s              3  0
     D iucmd           s              8
     d iucmd2          s              8
     d iutype          s              8
     d iujtyp          s              1
     d iuwhse          s             15  5
     d iubat           s              7  0
     d iustat          s              1
     d iuRtid          s              5
     d iuRte           s              5
     d iuord           s              7  0
     d iurwhs          s              3  0
     d iutrte          s              5
     d iurtn           s              8
     d iumsg           s              4
     d iuprg           s             10
     d piMsg           s            200
     d piWaveId        s             15
     d piRte           s              5
     d piRtid          s              5
     d piTruk          s             10
     d piDoor          s              3  0
     d piDrDpt         s              5
     d piPgmRtn        s             20
     d piRmsg          s             50

     *----------------------------------------------------------------
     *  Internal Prototype calls
     *----------------------------------------------------------------
     *  Send error messages to QSYSOPR for Waves
     d TBWAVEMSG       pr                  extpgm('TBWAVEMSG')
     d  iWhse                         3  0
     d  iMsg                        200
     d  iWaveId                      15
     d  iRte                          5
     d  iRtid                         5
     d  iTruk                        10
     d  iDoor                         3  0
     d  iDrDpt                        5
     d  ifromPgm                     10
     d  iPgmRtn                      20
     d  iRmsg                        50
     *  Return Route to Open Status
     D rh134           pr                  extpgm('RH134')
     D  $iparms                      80
     *  Call Route update Traffic Cop
     D or605           pr                  extpgm('OR605')
     D  $ucmd                         8
     d  $ucmd2                        8
     d  $utype                        8
     d  $ujtyp                        1
     d  $uwhse                       15  5
     d  $ubat                         7  0
     d  $ustat                        1
     d  $uRtid                        5
     d  $uord                         7  0
     d  $urwhs                        3  0
     d  $utrte                        5
     d  $urtn                         8
     d  $umsg                         4
     d  $uprg                        10

     *----------------------------------------------------------------
     * Prototype for QCMDEXC
     *----------------------------------------------------------------
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     c     *entry        plist
     c                   parm                    pwhse             3
     c                   parm                    pWaveId          15
     c                   parm                    pRtid             5

      /free
           exsr zzinz;

         monitor;
           chain (nWhse:pWaveId:pRtid) tbwaved;
           if not %found(tbwaved);
             pirte='NF';
             piRtid='NF';
           else;
             pirte=twdrte;
             piRtid=twdrtid;
           endif;
           iucmd='*PICK';
           iucmd2='*ALOCBLD';
           iutype='*PICK1';
           iujtyp='0';
           iuwhse=nWhse;
           iubat=0;
           iustat=*blanks;
           iuRte=piRte;
           iuRtid=piRtid;
           iuord=0;
           iurwhs=*zeros;
           iurtn=*blanks;
           iutrte=*blanks;
           iumsg=*blanks;
           iuprg=*blanks;
           // Call Allocate and Build from OR605 for passed Route
           if rhstat='1';
           monitor;
             or605(iucmd:iucmd2:iutype:iujtyp:iuWhse:iubat:iustat:iuRtid:
                   iuord:iurwhs:iutrte:iurtn:iumsg:iuprg);
             chain (iuWhse:iuRtid) rtehed;
             if %trim(iurtn)='*PGMQ' or %trim(iurtn)='*ERROR' or rhstat<>'3';
               error=*on;
               piMsg = 'Error returned from OR605 when calling ' +
                     ' command ALOCBLD.  Run as a single route to ' +
                     'determine the fix';
               piWaveId = pWaveId;
               piRtid=iuRtid;
               piTruk='*blanks';
               piDoor=*zeros;
               piDrDpt=*blanks;
               piRmsg=*blanks;
               piPgmRtn='TBW601-Call *ALOCBLD';
               tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                         piDrDpt:#prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
               return;
             else;
               // Update Route as Allocate and Build
               exec sql update tbwaved set twdsts='A'
                         where twdwhs=:pWhse and twdrtid=:iuRtid and
                               twdrte=:twdrte;
             endif;
           on-error;
             error=*on;
             piMsg = 'Unexpected error - ' + %trim(#pgmmsg) +
                   ' in job ' + %trim(#jobn) + '/' + %trim(#user) +
                   '/' + #job + ', at statement ' + %char(#stmt);
             piWaveId = pWaveId;
             piRtid=iuRtid;
             piTruk='*blanks';
             piDoor=*zeros;
             piDrDpt=*blanks;
             piRmsg=*blanks;
             piPgmRtn='TBW601-Call *ALOCBLD';
             tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:piDrDpt:
                       #prog:piPgmRtn:piRmsg);
             exsr flgRteSts9;
             return;
           endmon;
           endif;    // RHSTAT='1'

           iucmd='*PICK';
           iucmd2='*STGPRNT';
           iutype='*PICK1';
           iujtyp='0';
           iuwhse=nWhse;
           iubat=0;
           iustat=*blanks;
           iuRtid=pRtid;
           iuRte=piRte;
           iuRtid=piRtid;
           iuord=0;
           iurwhs=*zeros;
           iurtn=*blanks;
           iutrte=*blanks;
           iumsg=*blanks;
           iuprg=*blanks;
           // Call Staging and Print from OR605 for passed Route
             // Update Route as Staged
           if rhstat='3';
           monitor;
             // Call Allocate and Build from OR605 for passed Route
             or605(iucmd:iucmd2:iutype:iujtyp:iuWhse:iubat:iustat:iuRtid:
                   iuord:iurwhs:iutrte:iurtn:iumsg:iuprg);
             chain (iuWhse:iuRtid) rtehed;
             if %trim(iurtn)='*PGMQ' or %trim(iurtn)='*ERROR' or rhstat<>'S';
               error=*on;
               piMsg = 'Error returned from OR605 when calling ' +
                     ' command STGPRNT.  Run as a single route to ' +
                     'determine the fix';
               piWaveId = pWaveId;
               piRtid=iuRtid;
               piTruk='*blanks';
               piDoor=*zeros;
               piDrDpt=*blanks;
               piRmsg=*blanks;
               piPgmRtn='TBW601-Call*STGPRNT';
               tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                         piDrDpt:#prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
               return;
             else;
               // Update Route as Allocate and Build
               exec sql update tbwaved set twdsts='S'
                         where twdwhs=:pWhse and twdrtid=:iuRtid and
                               twdrte=:twdrte;
             endif;
           on-error;
             error=*on;
             piMsg = 'Unexpected error - ' + %trim(#pgmmsg) +
                   ' in job ' + %trim(#jobn) + '/' + %trim(#user) +
                   '/' + #job + ', at statement ' + %char(#stmt);
             piWaveId = pWaveId;
             piRtid=iuRtid;
             piTruk='*blanks';
             piDoor=*zeros;
             piDrDpt=*blanks;
             piRmsg=*blanks;
             piPgmRtn='TBW601-Call*STGPRNT';
             tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:piDrDpt:
                       #prog:piPgmRtn:piRmsg);
             exsr flgRteSts9;
             return;
           endmon;
           endif;      // RHSTAT='3'
         on-error;
           // Update Route as erroring out during IFS File Creation
           piMsg = 'Unexpected error in TBW601-' + %trim(#pgmmsg) +
                   ' in job ' + %trim(#job) + '/' + %trim(#user) +
                   '/' + #jobn + ', at statement ' + %char(#stmt);
           piWaveId = pWaveId;
           piRte=twdrte;
           piRtid=twdrtid;
           piTruk='*blanks';
           piDoor=*zeros;
           piDrDpt=*blanks;
           piRmsg=*blanks;
           piPgmRtn='TBW601 Mainline';
           tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:piDrDpt:
                    #prog:piPgmRtn:piRmsg);
            exsr flgRteSts9;
         endmon;

           *inlr = *on;
           return;

      /end-free
     *----------------------------------------------------------------
     *  flgRteSts9 - Flag Wave Route in error to Status 9
     *----------------------------------------------------------------
     *
     C     flgRteSts9    BEGSR
     c*
      /free
             // if route above status 1 and below 5 then
             // call RH134 with *UNDO to return to open and
             // then update to status 9
             if rhstat>'1' and rhstat<'5';
                $dparms=$lparm;
                $dpcmd='*UNDO  ';
                $dpprg=#prog;
                $dpwhse=nWhse;
                $dprte=rhrte;
                $dprtid=prtid;
                $dptruk=*blanks;
                rh134($dparms);
             endif;

             exec sql update rtehed set rhstat='9'
                     where rhwhse=:nWhse and rhrtid=:prtid
                     and rhstat='1';
      /end-free
     c*
     c                   endsr
      /free

         // ---------------------------------------------------------------------
         // Setup initial values
         // ---------------------------------------------------------------------

         begsr zzinz;

          // Convert warehouse to numeric
          monitor;
            nWhse=%dec(pWhse:3:0);
          on-error;
            nWhse=1;
          endmon;

          // get route
          chain (nWhse:pRtid) rtehed;

        // get client id.

             branch_id = *blanks;
             division = *blanks;
      /end-free
     c                   call      'GETCLIENT'
     c                   parm                    client           10
     c                   if        client=usfcrp
     c*    get Branch code
     c                   call      'GETBRANCH'
     c                   parm                    $ubid             2
     c                   parm                    $ubdesc          30
     c                   parm                    $ubhost           1
     c                   parm                    $ubredp           1
     c                   parm                    $ubiiuf           1
     c                   parm                    $ubeiuf           1
     c                   parm                    $ubrobn           1
     c                   parm                    $ublbls           1
     c                   parm                    $ubdiv            3
     *
     *  Get Dock Door Options.
     *
      /free
                         opcode = '*DOCDOOR';
                         chain (nwhse:opcode) options;
      /end-free
     *
     *    If options record not found:
     *      Default to auto assign dock doors &
     *      use single door for loading route.
     *
     C                   if        not %found(options)
     C                   eval      opatyp = '2'
     C                   eval      opltyp = '1'
     C                   endif
      /free
                         // if override for Dock Door Location exists pull that in
740 A                    chain (nwhse:pRtid) rtelm;
740 A                    if %found(rtelm);
740 A                      opltyp = rltype;
740 A                    endif;
      /end-free
     *
     *    Retrieve last dock matrix history record.
     C                   eval      $lwhse = nwhse
     c                   eval      $lhdte=*zeros
     c                   eval      $lhtim=*zeros
     C                   eval      $lprg = #prog
     C                   call      'DH910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*OK     '
     C                   eval      $phdte = $lhdte
     C                   eval      $phtim = $lhtim
     C                   endif
      /free

             branch_id = $ubid;
             if $ubdiv<>*blanks;
               division=$ubdiv;
             else;
               division=$ubid;
             endif;
                         endif;

             $parms = $lparm;

           endsr;

      /end-free
