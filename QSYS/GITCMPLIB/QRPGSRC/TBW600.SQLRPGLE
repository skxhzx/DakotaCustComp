     h DftActgrp(*NO) ActGrp(*Caller)

      *----------------------------------------------------------------
      *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   799 Roosevelt Rd.  Bldg 6, Suite 108
      *   Glen Ellyn, IL  60137
      *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  TBW600  Truckbuilder Wave Error Checking Process
     *  23 January 2020
     *  Kenneth Elder
     *
     *    01/23/20  KDE  7.40
     *      - Created
     *
     *----------------------------------------------------------------
     * Notes
     *
     * This program generates loops through the TBWAVED data for
     * the specific Warehouse and Waveid being passed.  This program
     * will validate door information, and then pass control to
     * RTEBUILD to confirm remaining checks.  If RTEBUILD returns with
     * pMessage empty then submit TWB601 to call OR605 for Allocate/Build
     * as well as Stage/Print
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     fdocdoor   if   e           k disk
     Fdocmtrx1  uf a e           k disk
     F                                     rename(dmrec:dmrec1)
     frtelm     uf a e           k disk
     ftbwaveh   uf   e           k disk
     ftbwaved   if   e           k disk
     ftbwerrlog if   e           k disk
     frtehed    uf   e           k disk
     Foptions   if   e           k disk
     fordh4     if   e           k disk

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
     d  #pgmmsgid             40     46
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

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D branch_id       s              2
     d cmdstring       s            256
     d cmdlength       s             15  5
     d waittime        s              3    inz('120')
     D dkdoor          s              5
     D docdpt          S              5    dim(5)
     D docdr           S              3  0 dim(5)
     D division        s              3
     d element         s              2  0
     d errmsg          s             80
     d fileName        s             30
     d forevr          s              1
     d pjobq           s              5
     d lastseq         s              2  0
     D mxpass          s              5
     d fileSeq         s              4  0
     D rem             s              3  0 inz(0)
     D result          s              3  0 inz(0)
     d savpass         s              3  0
     d splitAry        s           1000    dim(50)
     d tsdatetime      s             26
     D tt9998          s              4    inz('9998')
     D tf9999          s              4    inz('9999')
     d n               s              2  0
     d nwhse           s              3  0
     d newStat         s              5
     d cnt             s              2  0
     d numRtes         s              2  0
     d pPgm            s             20
     d pos             s              2  0
740  d multiRte        s             10
     d pJsonStr        s            999
740  d singleJson      s            999
740  d multiJson       s            999
     d pSession        s             40
     d wkatyp          s              1
     d wrkdoor         s              3  0
     d wrkTruk         s             10
     d wrkdpt          s              5
     d wrkdcmp         s              1
     d wrkddpt         s              5
     d wrkdcnt         s              2  0
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
740  *  Check for Multi Route or Single Route
740  D chkmtaflg       pr                  extpgm('CHKMTAFLG')
740  D  iWhse                         3  0
740  d  iTruck                       10
740  d  iReturn                      10
     *  Convert Dates
     D cvtdt           pr                  extpgm('CVTDTE')
     D  $ucvtdt                     184
     *  Return Route to Open Status
     D rh134           pr                  extpgm('RH134')
     D  $iparms                      80
     *  Move Routes along within Wave
     D tbw601          pr                  extpgm('TBW601')
     D  $upWhse                       3
     d  $upWaveId                    15
     d  $upRtid                       5
     D stgPrint        pr                  extpgm('STGPRINT')
     D  $upMessage                   80
     d  $upSession                   40
     d  $upUser                      10
     d  $upPgm                       20
     d  $upWhse                       3
     d  $upJson                     999
     d  $upjobq                       5

     ***    Used to Split delimited values into an Array   ***
     d Split           pr            50    dim(50)
     D  strToSplit                 1000    const
     D  delimiter                     3    const

     *----------------------------------------------------------------
     * Prototype for QCMDEXC
     *----------------------------------------------------------------
     D Exc_Cmd         PR                  extpgm('QCMDEXC')
     D  command                     200A   const
     D  length                       15P 5 const

     c     *entry        plist
     c                   parm                    pwhse             3
     c                   parm                    pWaveid          15
     c*  used delay to confirm my check job api was working since this job
     c*  runs so quickly
     c                   eval      cmdstring = 'dlyjob ' + waittime
     c                   eval      cmdlength = %len(%trim(cmdstring))
      *
      * do your program stuff here
      *
     c*                  call(e)   'QCMDEXC'
     c*                  parm                    cmdstring
     c*                  parm                    cmdlength
      /free
          monitor;
            exsr zzinz;
          on-error;
            // This error ends the job after sending message since an unexpected
            // error occurred in the ZZINZ routine.  Should be able to correct
            // error and rerun with warehouse and proper pWaveId that was present
            // in the message since no updates occured
            piMsg = 'Unexpected error in TBW600-' + %trim(#pgmmsg) +
                  ' in job ' + %trim(#jobn) + '/' + %trim(#user) +
                  '/' + #job + ', at statement ' + %char(#stmt);
            piWaveId = pWaveId;
            piRte=*blanks;
            piRtid=*blanks;
            piTruk='*blanks';
            piDoor=*zeros;
            piDrDpt=*blanks;
            piRmsg=*blanks;
            piPgmRtn='TBW600 - ZZINZ';
            tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:piDrDpt:
                     #prog:piPgmRtn:piRmsg);
            newstat='IZ600';
            exsr setstatus;
            *inlr=*on;
            return;
          endmon;

           // Loop thru Warehouse/Waveid passed in and process
           // the respective routes all the way through staging
           setll (nWhse:pWaveId) tbWaved;
           dow forevr=forevr;

             monitor;
               reade (nWhse:pWaveId) tbWaved;
               if not %equal(tbWaved) or %eof(tbWaved);
                 leave;
               endif;
               if twdsts > '1';
                 iter;
               endif;
               // remove any previous error log record for this route/rtid
               exec sql delete from tbwerrlog where tewhse=:nWhse
                           and tewid=:twdid and terte=:twdrte
                           and tertid=:twdrtid;
               exsr zzvfyDoor;
               if not error;
                 // No errors found verifying dept and door
                 // Verify Route as failing with Error
                 newstat='VFYDR';
                 exsr setstatus;
                 exsr zzvfyRoute;
               else;
                 // Update Route as failing with Error
                 newstat='F-DR';
                 exsr setstatus;
                 // Message already sent in routine zzVFYDOOR
                 iter;
               endif;
               if not error;
                 // No errors found verifying route
                 // Route verification failed
                 newstat='VFYRT';
                 exsr setstatus;
                 // Submit Allocate/Build, then Staging process for the route
                 monitor;
                   tbw601(pWhse:twdId:twdrtid);
                   // see if any errors written
                   setll (nWhse:twdid:twdrte:twdrtid) tbwerrlog;
                   reade (nWhse:twdid:twdrte:twdrtid) tbwerrlog;
                   if %equal(tbwerrlog);
                     // Update Route as erroring out during TBW601
                     // Detail message was sent and written during TBW601
                     newstat='M-601';
                     exsr setstatus;
                     exsr flgRteSts9;
                     iter;
                   else;
                   // Update Route as passing initial verification
                     newstat='VFYRT';
                     exsr setstatus;
                   endif;
                 on-error;
                   // Error occurred while taking route to completion
                   // in TBW601
                   exsr flgRteSts9;
                   iter;
                 endmon;
               else;
                  // Route verification failed
                  newstat='F-RTV';
                  exsr setstatus;
                  exsr flgRteSts9;
                  iter;
               endif;

               //  When it falls to here it was a good Wave.  Add to
               // a json string used to call.  Add this route to the
               // json String that will call STGPRINT when complete
740            select;
 |             when multiRte = '*ALLOW';
 |              if %trim(multijson)<>'{';
 |                multijson=%trim(multijson) + ',';
 |              endif;
 |              numRtes=numRtes+1;
 |              multijson = %trim(multijson) + '"Rte' + %char(numRtes) + '":"' +
 |                         %trim(twdrte) + '","Routeid' + %char(numRtes) + '":"'
 |                         + %trim(twdrtid) + '"';
 |             other;
 |              if %trim(singlejson)<>'{';
 |                singlejson=%trim(singlejson) + ',';
 |              endif;
 |              numRtes=numRtes+1;
 |              singlejson=%trim(singlejson) + '"Rte' + %char(numRtes) + '":"' +
 |                         %trim(twdrte) + '","Routeid' + %char(numRtes) + '":"'
 |                         + %trim(twdrtid) + '"';
740            endsl;
             on-error;
               // Update Route as erroring out during IFS File Creation
               newstat='M-600';
               exsr setstatus;
               piMsg = 'Unexpected error in TBW600-' + %trim(#pgmmsg) +
                     ' in job ' + %trim(#job) + '/' + %trim(#user) +
                     '/' + #jobn + ', at statement ' + %char(#stmt);
              piWaveId = pWaveId;
              piRte=twdrte;
              piRtid=twdrtid;
              piTruk='*blanks';
              piDoor=*zeros;
              piDrDpt=*blanks;
              piRmsg=*blanks;
              piPgmRtn='TBW600 Mainline';
              tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:piDrDpt:
                       #prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
             endmon;
740          // if not processing multi routes together then call processRte after
 |           // each individual route
 |           if multiRte <> '*ALLOW' and singlejSon <> '{';
 |             pjsonStr = singlejSon;
 |             exsr processRte;
 |             singleJson='{';
740          endif;
           enddo;
740        // If multi route then process now after all routes
 |         if multiRte = '*ALLOW' and multijSon <> '{';
 |           pjsonStr = multijSon;
 |           exsr processRte;
740        endif;

           *inlr = *on;
           return;

      /end-free

740  *----------------------------------------------------------------
     *  processRte - Call routines to process route and return data
     *----------------------------------------------------------------
     *
     C     processRte    BEGSR
     c*
      /free
           if %trim(pjSonStr)<>'{';
             // if routes were successful then close routes json string
             // and call STGPRINT to process to Pick and Print and send
             // Wave back as IFS data file
             pjsonStr=%trim(pjsonStr) + '}';
             errmsg=*blanks;
             pSession = 'TBW600' + %char(%timestamp());
             ppgm=#prog;
             pjobq=*blanks;
             monitor;
               stgprint(errmsg:pSession:#user:ppgm:pWhse:pJsonStr:pjobq);
               if errmsg<>*blanks;
                 // Update Route as app specific error from STGPRINT
                 newstat='S-ERR';
                 exsr setstatus;
                 piMsg = %trim(errmsg);
                 piWaveId = twdid;
                 piRte=twdrte;
                 piRtid=twdrtid;
                 if ohtruk<>*blanks;
                   piTruk=rhtruk;
                 else;
                   piTruk='*blanks';
                 endif;
                 piDoor=*zeros;
                 piDrDpt=*blanks;
                 piRmsg=*blanks;
                 piPgmRtn='TBW600-STGPRINT err';
                 tbwavemsg(nwhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                           piDrDpt:#prog:piPgmRtn:piRmsg);
                 exsr flgRteSts9;
               else;
                 // Update All routes for this Wave as Complete before ending
                 setll (nWhse:pWaveId) tbwaved;
                 dow forevr=forevr;
                   reade (nWhse:pWaveid) tbwaved;
                   if not %equal(tbwaved) or %eof(tbwaved);
                     leave;
                   endif;
                   chain(n) (twdwhs:twdrtid) rtehed;
                   if rhstat<>'9';
                     newstat='CMPLT';
                     exsr setstatus;
                   endif;
                 enddo;
               endif;
             on-error;
               // Update Route as error calling STGPRINT
               newstat='E-CSP';
               exsr setstatus;
               piMsg = 'Error calling STGPRINT';
               piWaveId = twdid;
               piRte=twdrte;
               piRtid=twdrtid;
               if ohtruk<>*blanks;
                 piTruk=rhtruk;
               else;
                 piTruk='*blanks';
               endif;
               piDoor=*zeros;
               piDrDpt=*blanks;
               piRmsg=*blanks;
               piPgmRtn='TBW600-CALL STGPRINT';
               tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                         piDrDpt:#prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
             endmon;
           endif;
      /end-free
     c*
740  c                   endsr

     *----------------------------------------------------------------
     *  setStatus - Set TBWAVED status
     *----------------------------------------------------------------
     *
     C     setStatus     BEGSR
     c*
      /free
            exec sql update tbwaved set twdsts=:newStat
                      where twdwhs=:pWhse and twdrtid=:twdrtid
                        and twdrte=:twdrte;
      /end-free
     c*
     c                   endsr

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
                $dpwhse=900;
                $dprte=twdrte;
                $dprtid=twdrtid;
                $dptruk=*blanks;
                rh134($dparms);
             endif;

             exec sql update rtehed set rhstat='9'
                     where rhwhse=:twdwhs and rhrtid=:twdrtid
                     and rhstat='1';
      /end-free
     c*
     c                   endsr

     *----------------------------------------------------------------
     *  ZZCKDR   Check if this is odd/even dock door.
     *----------------------------------------------------------------
     *
     C     ZZCKDR        BEGSR
     *
     C     wrkdoor       div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      dkdoor = '*ODD '
     C                   else
     C                   eval      dkdoor = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZCKPS   Check if this is odd/even dock door assignment pass.
     *----------------------------------------------------------------
     *
     C     ZZCKPS        BEGSR
     *
     C     dmpass        div       2             result
     C                   mvr                     rem
     *
     C                   if        rem > 0
     C                   eval      mxpass = '*ODD '
     C                   else
     C                   eval      mxpass = '*EVEN'
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRADD  Add new pass / dock door.
     *----------------------------------------------------------------

     C     ZZDRADD       BEGSR
     *
     *      Increment matrix pass if zero.
     C                   if        dmpass = 0
     C                   eval      dmpass = dmpass + 1
     C                   endif
     *
     C                   exsr      zzckps
     C                   exsr      zzckdr
     C                   exsr      zzgtdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor or
     C                             mxpass = dkdoor and (dmstat = '2' or
     C                             dmstat = '4')
     C                   eval      dmpass = dmpass + 1
     C                   exsr      zzckps
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     C                   endif
     *
     C                   eval      dmwhse = $pwhse
     C                   eval      dmhdte = $phdte
     C                   eval      dmhtim = $phtim
     C                   eval      dmwhdp = wrkdpt
     *
     C                   eval      dmdoor = wrkdoor
     C                   eval      dmrtid = twdrtid
     C                   eval      dmmaxc = ddmaxc
     C                   eval      dmrtec = ddmaxc
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
     c                   select
     c                   when      opatyp = '2'
     C                   eval      dmatyp = 'M'
     c                   when      opatyp = '1'
     C                   eval      dmatyp = 'A'
     c                   other
     C                   eval      dmatyp = ' '
     c                   endsl
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   callp     cvtdt($cvtdt)
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     C                   write     dmrec1
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZDRUPD  Update pass / dock door info.
     *----------------------------------------------------------------

     C     ZZDRUPD       BEGSR
     *
     C                   exsr      zzckps
     C                   exsr      zzckdr
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Increment pass to match door selected by user.
     C                   if        mxpass <> dkdoor
     C                   eval      dmpass = dmpass + 1
     C                   endif
     *
     C                   eval      dmdoor = wrkdoor
     C                   eval      dmrtid = twdrtid
     C                   eval      dmrtec = dmmaxc
     C                   eval      dmstat = '2'
     C                   eval      dmovrf = 'N'
     C                   eval      dmskpr = ' '
     c                   select
     c                   when      opatyp = '2'
     C                   eval      dmatyp = 'M'
     c                   when      opatyp = '1'
     C                   eval      dmatyp = 'A'
     c                   other
     C                   eval      dmatyp = ' '
     c                   endsl
     C                   eval      dmaby  = #user
     C                   eval      $cvcmd = '*CURCMD '
     *    Retrieve current date.
     C                   callp     cvtdt($cvtdt)
     C                   eval      dmadte = $cvd8o
     C                   time                    dmatim
     *
     *    Dock matrix pass and dock door not both even/odd.
     *    Add record to match door selected by user.
     C                   if        mxpass <> dkdoor
     C                   write     dmrec1
     C                   else
     C                   update    dmrec1
     C                   endif
     *
     C                   ENDSR

     *----------------------------------------------------------------
     *  ZZGTDR  Get dock door master.
     *----------------------------------------------------------------

     C     ZZGTDR        BEGSR
     *
      /free
                         chain (twdwhs:wrkdoor:wrkdpt) docdoor;
      /end-free
     C                   if        not %found
     C                   eval      ddmaxc = 0
     C                   endif
     *
     C                   ENDSR

      /free

         // Verify Dock Door sent with Route

           begsr zzVfyDoor;

              // if override for Dock Door Location exists pull that in
740 A         chain (twdwhs:twdRtid) rtelm;
740 A         if %found(rtelm);
740 A           opltyp = rltype;
740 A         endif;

             select;
               when opatyp = '2';
                 wkatyp = 'M';
               when opatyp = '1';
                 wkatyp = 'A';
               other;
                 wkatyp = ' ';
             endsl;

             chain(n) (twdwhs:twdrtid) rtehed;
             if not %found(rtehed);
               rhrte='NF';
               rhrtid='NF';
             //else;
             //  wrktruk=rhtruk;
             endif;
             // find Truck Code associated to Route
             wrkTruk=*blanks;
             exec sql select thtruk into :wrkTruk
                         from ordh,truckh
                       where ohwhse=:twdwhs and ohrte=:twdrtid
                             and ohtruk<>' ' and thwhse=ohwhse
                             and thtruk=ohtruk
                          fetch first row only;
             if sqlstt<>'00000' or wrkTruk=*Blanks;
             // Send Invalid Truck Message
               error=*on;
               piMsg = 'Invalid Truck';
               piWaveId = pWaveId;
               piRte=rhrte;
               piRtid=rhrtid;
               if ohtruk<>*blanks;
                 piTruk=ohtruk;
               else;
                 piTruk='*blanks';
               endif;
               piDoor=*zeros;
               piDrDpt=*blanks;
               piRmsg=*blanks;
               piPgmRtn='zzVfyDoor';
               tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                         piDrDpt:#prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
               leavesr;
            endif;

             // determine whether we should stage multiple routes
             // and send back combined assignments or process each
             // route in wave individually
740          multiRte=*blanks;
740          chkmtaflg (twdwhs:wrktruk:multiRte);
             // find first order header for route with
             // dock door information
             error=*off;
             setll (twdwhs:twdrtid) ordh4;
             dow forevr=forevr;
               reade (twdwhs:twdrtid) ordh4;
               if not %equal(ordh4) or %eof(ordh4);
                 leave;
               endif;
               if %subst(%trim(ohcad2):6:5)='DOORS';
                 leave;
               endif;
             enddo;

             // Now confirm Door(s) are valid
             if ohrte<>twdrtid or %subst(%trim(ohcad2):6:5)<>'DOORS';
               error=*on;
               // Address Two not populated with Door Information
               piMsg = 'Door Information not sent in Address two of Ord Hdr';
               piWaveId = pWaveId;
               piRte=rhrte;
               piRtid=rhrtid;
               piTruk='*blanks';
               piDoor=*zeros;
               piDrDpt=*blanks;
               piRmsg=*blanks;
               piPgmRtn='zzVfyDoor';
               tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                         piDrDpt:#prog:piPgmRtn:piRmsg);
               exsr flgRteSts9;
               leavesr;
             endif;

             // Setup department and door arrays based
             // on data passed in and then verify below
             clear splitAry;
             // call procedure that splits door definition between commas
             splitAry = Split(%subst(%trim(ohcad2):12:%len(%trim(ohcad2))-11)
                                  :',');
             clear docdpt;
             clear docdr;
             cnt = 1;
             element=0;
             dow cnt < 6;
                if splitAry(cnt) <> *blanks;
                  pos = %scan('=':%trim(splitAry(cnt)));
                  if pos=0;
                    error=*on;
                    // Address Two not populated with Door Information
                    piMsg = 'Door Information formatted incorrectly in ' +
                              'Order Header Address 2(' +
                              %trim(ohcad2) + ')';
                    piWaveId = pWaveId;
                    piRte=rhrte;
                    piRtid=rhrtid;
                    piTruk='*blanks';
                    piDoor=*zeros;
                    piDrDpt=*blanks;
                    piRmsg=*blanks;
                    piPgmRtn='zzVfyDoor';
                    tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                              piDrDpt:#prog:piPgmRtn:piRmsg);
                    exsr flgRteSts9;
                    leavesr;
                  else;
                    if pos < 2;
                      // Address Two not populated with Door Information
                      error=*on;
                      piMsg = 'Door Information formatted incorrectly in ' +
                                'Order Header Address 2(' +
                                %trim(ohcad2) + ')';
                      piWaveId = pWaveId;
                      piRte=rhrte;
                      piRtid=rhrtid;
                      piTruk='*blanks';
                      piDoor=*zeros;
                      piDrDpt=*blanks;
                      piRmsg=*blanks;
                      piPgmRtn='zzVfyDoor';
                      tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                                piDrDpt:#prog:piPgmRtn:piRmsg);
                      exsr flgRteSts9;
                      leavesr;
                    else;
                       //  03/17/20  Add code to prevent adding same dept door twice
                      // now add to arrays for Department and respective doors
                      element=element+1;
                      docdpt(element)=%trim(%subst(splitAry(cnt):1:pos-1));
                      docdr(element)=%dec(%trim(%subst(splitAry(cnt):pos+1:
                                    %len(%trimr(splitAry(cnt)))-(pos))):3:0);
                    endif;
                  endif;
                endif;
                cnt = cnt + 1;
             enddo;

             // Verify dock door(s) are active
             element=1;
             dow element<6;
               if docdpt(element) = *blanks or docdr(element)=0;
                 leave;
               endif;
               if docdpt(element) <> 'ROUTE';
                 $lcmd = '*VFYSTAT';
                 $lwhse = twdwhs;
                 $lwhdp = docdpt(element);
                 $ldoor = docdr(element);
                 chain (twdwhs:docdr(element):docdpt(element)) docdoor;
                 if not %found(docdoor) or ddstat<>'A';
                   error = *on;
                   // Address Two not populated with Door Information
                   piMsg = 'Dock Door Department and/or Dock Door ' +
                             'is not an active combination(' +
                      %trim(docdpt(element)) + '/' + %char(docdr(element)) +
                      ')';
                   piWaveId = pWaveId;
                   piRte=rhrte;
                   piRtid=rhrtid;
                   piTruk='*blanks';
                   piDoor=docdr(element);
                   piDrDpt=docdpt(element);
                   piRmsg=*blanks;
                   piPgmRtn='zzVfyDoor';
                   tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                             piDrDpt:#prog:piPgmRtn:piRmsg);
                   exsr flgRteSts9;
                   leavesr;
                 else;
                   wrkdoor=dddoor;
                   wrkdpt=ddwhdp;
                 endif;
               endif;
               // no errors to this point so we will do the checks
               // and updates that DH122 do here.  With the message
               // requirements for US Foods it is rather messy to try
               // and call DH122.  Just replicate code in here and it
               // will need to be managed outside of DH122

               // If Route is sent as Department then blank
               // and ensure door is valid.  Otherwise it
               // represents an error
               if docdpt(element)='ROUTE';
                  wrkdoor=docdr(element);
                  exec sql select ddwhdp into :wrkdpt
                    from docdoor
                   where ddwhse=:nWhse and dddoor=:wrkdoor;
                  if sqlstt <> '00000';
                    error=*on;
                    // Dock Door not found
                    piMsg = 'Dock Door sent as Single Door ' +
                              'is invalid(' +
                              %char(docdr(element)) +
                              ')';
                    piWaveId = pWaveId;
                    piRte=rhrte;
                    piRtid=rhrtid;
                    piTruk='*blanks';
                    piDoor=docdr(element);
                    piDrDpt=*blanks;
                    piRmsg=*blanks;
                    piPgmRtn='zzVfyDoor';
                    tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                              piDrDpt:#prog:piPgmRtn:piRmsg);
                    exsr flgRteSts9;
                    leavesr;
                  endif;
               endif;

               // Make sure that Dock Door Department exist in Truck Compartment
               // Maintenance
               exec sql select tpdrdp into :wrkdpt
                        from trkcomp
                      where tpdrdp=:wrkdpt
                      fetch first row only;
               if sqlstt<>'00000';
                 error=*on;
                 // Dock Door not found
                 piMsg = 'Dock Door Department(' + %trim(wrkdpt) + ') is not '
                       + 'present in Truck Compartment Maintenance';
                 piWaveId = pWaveId;
                 piRte=rhrte;
                 piRtid=rhrtid;
                 piTruk='*blanks';
                 piDoor=docdr(element);
                 piDrDpt=wrkdpt;
                 piRmsg=*blanks;
                 piPgmRtn='zzVfyDoor';
                 tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                           piDrDpt:#prog:piPgmRtn:piRmsg);
                 exsr flgRteSts9;
                 leavesr;
               endif;
               // Now Update/Assign Route with proper door(s)
               // Find last pass.  See if dock door is available.
               // Force assignment type to manual for add and update.
               setgt (twdwhs:$phdte:$phtim:wkatyp:wrkdpt:*loval:wrkdoor)
                                              docmtrx1;
               readpe (twdwhs:$phdte:$phtim:wkatyp:wrkdpt) docmtrx1;
               if %eof(docmtrx1);
                  savpass = *hival;
               else;
                  savpass = dmpass;
               endif;
               setgt (twdwhs:$phdte:$phtim:wkatyp:wrkdpt:savpass:wrkdoor)
                          docmtrx1;
               readpe (twdwhs:$phdte:$phtim:wkatyp:wrkdpt) docmtrx1;

               // Pass read is less than previous pass. Get very last pass.
               if dmpass < savpass;
                 setgt (twdwhs:$phdte:$phtim:wkatyp:wrkdpt:dmpass:wrkdoor)
                                  docmtrx1;
                 readpe (twdwhs:$phdte:$phtim:wkatyp:wrkdpt) docmtrx1;
               endif;
               select;

               // Pass found and door ok to use.
                 when not %eof and
                      (dmstat = '1' or dmstat = '3') and
                       wrkdoor = dmdoor;
                    exsr zzdrupd;

               // Pass not found or door at wrong status. Create new pass
               // update door with new info.
                 when %eof or
                    not %eof and (dmstat = '2' or dmstat = '4')
                    or not %eof and (dmstat = '1' or dmstat = '3'
                    and (wrkdoor <> dmdoor));
                    exsr zzdradd;
               endsl;

               unlock docmtrx1;

               // Move key values to parameters

               $pwhdp = wrkdpt;
               $pdoor = wrkdoor;
               element=element+1;

             enddo;

             // Confirm that RTELM record is setup to handle dock doors correctly
             chain (twdwhs:twdrtid) rtelm;
             select;
               when docdpt(3) <> *blanks;
                 // setup Route Load Method override record
                 if %found(rtelm);
                   rltype='2';
                 else;
                   rlwhse=twdwhs;
                   rlrtid=twdrtid;
                   rltype='2';
                 endif;
               when docdpt(2) <> *blanks;
                 if %found(rtelm);
                   rltype='2';
                 else;
                   rlwhse=twdwhs;
                   rlrtid=twdrtid;
                   rltype='2';
                 endif;
               other;
                 // Only comes here if user sends one dept instead of using route=door
                 if %found(rtelm);
                   rltype='1';
                 else;
                   rlwhse=twdwhs;
                   rlrtid=twdrtid;
                   rltype='1';
                 endif;
             endsl;
             if %found(rtelm);
               update rlrec;
             else;
               write rlrec;
             endif;

           endsr;

         // Verify Route information before calling OR605

           begsr zzVfyRoute;

                         pSessId = 'TBW600' + %char(%timestamp());
      /end-free
     c                   eval      pGrpid=1
     C                   call(e)   'RTEBUILD'
     C                   parm                    ErrMsg
     C                   parm                    pSessId          40
     C                   parm                    #user
     C                   parm      'TBW600'      dpCombo          20
     C                   parm                    pWhse
     C                   parm                    twdRtid
     C                   parm                    twdrte
     C                   parm      *blanks       tjobq             5
     C                   parm      '*ALOCSTG'    pSubGrp          12
     C                   parm                    pGrpId           15 5

     C                   if        %error
     c                   eval      error=*on
     C                   eval      ErrMsg  = 'Error occured calling '
     C                                      + 'RTEBUILD ('
     C                                      + %trimr(#job) + '/'
     C                                      + %trimr(#jobnbr) + '/'
     C                                      + %trimr(#user) + ')'
      /free
                 error=*on;
                 // Error calling RTEBUILD
                 piMsg = %trim(errmsg);
                 piWaveId = pWaveId;
                 piRte=rhrte;
                 piRtid=rhrtid;
                 piTruk='*blanks';
                 piDoor=0;
                 piDrDpt=*blanks;
                 piRmsg=*blanks;
                 piPgmRtn='zzVfyRoute';
                 tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                           piDrDpt:#prog:piPgmRtn:piRmsg);
                 exsr flgRteSts9;
                 leavesr;
      /end-free
     C                   endif
      /free
              // Falling to here means call was successful but RTEBUILD
              // Edits returned an error
               if errmsg<>*blanks;
                 error=*on;
                 // Error returned from RTEBUILD
                 piMsg = %trim(errmsg);
                 piWaveId = pWaveId;
                 piRte=rhrte;
                 piRtid=rhrtid;
                 piTruk='*blanks';
                 piDoor=0;
                 piDrDpt=*blanks;
                 piRmsg=*blanks;
                 piPgmRtn='zzVfyRoute';
                 tbwavemsg(nWhse:piMsg:piWaveId:piRte:piRtid:piTruk:pidoor:
                           piDrDpt:#prog:piPgmRtn:piRmsg);
                 exsr flgRteSts9;
                 leavesr;
               endif;
           endsr;

         // Setup initial values

         begsr zzinz;

          // Convert warehouse to numeric
          monitor;
            nWhse=%dec(pWhse:3:0);
          on-error;
            nWhse=1;
          endmon;


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
     c                   else
     c                   eval      opatyp='2'
     C                   endif
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

             pjsonStr = '{';
740          singleJson = '{';
740          multiJson = '{';

           endsr;


         // Create json string for Routes included in Wave

         begsr bldRtejSon;
         endsr;

      /end-free
      *
      *  Procedure Split..............
      *
      *  Split Procedure that work like SPLIT in javascript.  It expects an input
      *  string up to 1000 characters long, a delimiter 3 character long, and passes
      *  back an array with 50 elements 50 character each.  The delmiter could
      *  be increased if need be and the code (%len) takes care of it.  You could
      *  also change the array size and element count.  If you do you should change
      *  split and returnarray here and you procedure definition in main program
      *  as well as the array defined in the main program that receives the return
      *  from this procedure.  When you return simply loop through array looking for
      *  non blanks and do what you need to given your data.
      *
     P split           b
     D split           pi            50    dim(50)
     D  data                       1000    const
     D  delimiter                     3    const

     D returnArray     s             50    dim(50)

     D startPos        s             10i 0
     D foundPos        s             10i 0
     D increment       s             10i 0
     D index           s              5i 0 inz(1)
      /free
       if data <> *blanks;
          increment = %len(%trim(delimiter));
          startPos = 1;
          dou foundPos = %len(data) + 1;
             foundPos = %scan(%trim(delimiter):data:startPos);
             if foundPos = 0;
                foundPos = %len(data) + 1;
             endif;
             returnArray(index) = %subst(data:startPos:foundPos - startPos);
             index += 1;
             startPos = foundPos + increment;
          enddo;
       endif;

       return returnArray;
      /end-free
     P split           e
