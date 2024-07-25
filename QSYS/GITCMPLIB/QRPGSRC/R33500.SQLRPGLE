      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR33500      PO Receiving - Print GS1 Labels - Canopy
     *  05 August   2019
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
730 A*    08/05/19  LMC  7.30
     *      - Created.
730aA*    08/21/19  LMC  7.30a
     *      - changed the label set to $plset = 'ZBRDR2';
     *      - do to a different dpi on the printer.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pItem       Item (optional)
     *      pSEQ        Item (optional)
     *      pSession    Session
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdebug  o    e           k disk
     Fuciwork   uf   e           k disk
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Convert Barcode Parms
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#BARCODE
     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.qcmdexc

     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   MsgInfo                  32766A   options(*varsize)
     D   MsgInfoLen                  10I 0 const
     D   Format                       8A   const
     D   StackEntry                  10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   MsgAction                   10A   const
     D   ErrorCode                32766A   options(*varsize)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D SubmitJob       PR            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)


     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D rprec         E Ds                  Extname(reports)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D pWhse           s              3
     D pPo             s              9
     D  pOutStr        s           1024    varying

     D client          s             10
     D clientloc       s             10

     D $prtn           s              8
     D $pdev           s             10
     D $pform          s             10
     D exp6            s              6  0
     D mfg6            s              6  0
     D wkwhse          s              3  0
     D wkpseq          s              5  0
     D $pitem          s             15

     D ck4err          s              1


     D jobq            s               n
     D bfcjobq         s             10
     D sbmCmd          s           3000    varying
     D sbmJob          s             10A
     D sbmUser         s             10A
     D sbmJobNbr       s              6A
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Called Programs
     *----------------------------------------------------------------
740bMd @lblpg          c                   const('BFCPRTLBL')
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pOutStr
     C                   parm                    pJobq             5
     C                   parm                    pItem            15
     C                   parm                    pseq              5
     c                   parm                    pSession         40

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
        $pform = '*STD';
        $pdev = '*JOB';
        // do we have printer overrides?
        exec sql select * into :rprec
             from reports
             where rpprtf = 'CANGS1 ';

        If sqlstt = sqlSuccess;
          $pform = rpform;
          $pdev = rpdev;
        endif;

         // Set jobq flag

         if %parms >= 4 and pJobq = '*JOBQ';
           jobq = *on;
         else;
           jobq = *off;
         endif;

         // When not running from Jobq ...

         if not jobq;

           // Submit this program to Jobq

           exsr SubmitProgram;
           return;

         endif;
      /end-free

      /free
        // Let's process the weight records entered
        wkwhse = %dec(pwhse:3:0);
        setll (psession: wkwhse) uciwork;
        dow forever = forever;
          reade (psession: wkwhse) uciwork;
          if %eof(uciwork);
            leave;
          endif;
          if uiwpo <> ppo;
            iter;
          endif;
          wkpseq = %dec(pseq:5:0);
          if uiwposeq <> wkpseq;
            iter;
          endif;
          if uiwitem <> pitem;
            iter;
          endif;
          if uiwprint = 'Y';
            iter;
          endif;
          if uiwload = 'Y';
            iter;
          endif;

          exsr clr$item;
          $itwhse  = wkwhse;
          $ititem  = pitem;

          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          ck4err = *on;
          exsr zzzdricop;
          if error;
          endif;

          if client = dairyland;
730aD       //$plset = 'ZBRDRY';
730aM       $plset = 'ZBRDR2';
          endif;

          select;
            when uiwexpdt <> 0;
              exp6 = %DEC(uiwexpdt:6:0);
              $pindta = %editc(exp6:'Y');
            when uiwmfgdt <> 0;
              mfg6 = %DEC(uiwmfgdt:6:0);
              $pindta = %editc(mfg6:'Y');
          endsl;
          select;
            when uiwwgtlbs <> 0;
              $gs1wgt = %editc(uiwwgtlbs:'3');
            other;
              $gs1wgt = '.00';
          endsl;
      /end-free

     c                   call      @lblpg
     C                   parm      '*CANGS1 '    $pcmd             8
     C                   parm                    $plset            6
     C                   parm      'CANGS1'      $plfmt            8
     C                   parm      wkwhse        $plwhse           3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $slwhdp           5
     C                   parm                    $sldisp          12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm      $ititem       $pditem          15
     C                   parm                    $pbrnd           10
     C                   parm      $itpdsc       $ppdesc          15
     C                   parm      $itdesc       $itdesc          30
     C                   parm      ppo           $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   parm      uiwuci        $gs199           48
     C                   parm                    $gs1wgt           7

      /free
        uiwprint = 'Y';
        update uiwrec;
        enddo;
      /end-free
     c                   call      @lblpg
     C                   parm      '*CANEND '    $pcmd             8
     C                   parm                    $plset            6
     C                   parm      'CANGS1'      $plfmt            8
     C                   parm      wkwhse        $plwhse           3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      *blanks       $slwhdp           5
     C                   parm                    $sldisp          12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    wklic            15
     C                   parm                    $plcn2           15
     C                   parm      $ititem       $pditem          15
     C                   parm                    $pbrnd           10
     C                   parm      $itpdsc       $ppdesc          15
     C                   parm      $itdesc       $itdesc          30
     C                   parm      ppo           $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   parm      uiwuci        $gs199           48
     C                   parm                    $gs1wgt           7
     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  SubmitProgram   Submit Program
     *----------------------------------------------------------------

      /free
       begsr SubmitProgram;

           sbmCmd = 'CALL  '
                  +   'PGM(' + %trimr(#pgm) + ') '
                  +   'PARM('
                  +      sq + pwhse + sq + ' '
                  +      sq + pPO + sq + ' '
                  +      sq + pOutstr + sq + ' '
                  +      sq + '*JOBQ' + sq + ' '
                  +      sq + pItem + sq + ' '
                  +      sq + pSEQ  + sq + ' '
                  +      sq + pSESSION + sq
                  +   ')';

         bfcjobq = 'BFCJOBQ';

         if SubmitJob(#pgm: bfcjobq:
                      sbmCmd: sbmJob: sbmUser: sbmJobNbr) < 0;

           bdtype = 'ERROR';
           bdvalues = 'sbmcmd:' + %trimr(sbmcmd);
           exsr WrtDebug;
           //pMessage = 'Error submitting command ' + #pgm;
           return;

         endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebug       Write out debug record
     *----------------------------------------------------------------

      /free
       begsr wrtDebug;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
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

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      ck4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);

       endsr;

      /end-free

     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SubmitJob   Submit job to job queue
     *
     *     peName    = name of job to submit
     *     peJobQ    = Queue to submit to
     *     peCmd     = Command to submit
     *     peSbmName = name returned by the submit job command
     *     peSbmUser = user returned by the submit job command
     *     peSbmNbr  = job number returned by the submit job command
     *
     *  Returns 0 if successful, or -1 if it failed
     *----------------------------------------------------------------
     P SubmitJob       B                   export
     D SubmitJob       PI            10I 0
     D   peName                      10A   const varying
     D   peJobQ                      10A   const varying
     D   peCmd                     3000A   const varying
     D   peSbmName                   10A   options(*nopass)
     D   peSbmUser                   10A   options(*nopass)
     D   peSbmNbr                     6A   options(*nopass)

     *  Local Variables

     D cmd             s           3000    varying

     D dsM1            DS
     D  dsM1_BytRtn                  10I 0
     D  dsM1_BytAvl                  10I 0
     D  dsM1_MsgSev                  10I 0
     D  dsM1_MsgID                    7A
     D  dsM1_MsgType                  2A
     D  dsM1_MsgKey                   4A
     D  dsM1_Reserv1                  7A
     D  dsM1_CCSID_st                10I 0
     D  dsM1_CCSID                   10I 0
     D  dsM1_DtaLen                  10I 0
     D  dsM1_DtaAvl                  10I 0
     D  dsM1_Dta                    256A

     D dsEC            DS
     D  dsECBytesP             1      4I 0 INZ(%size(dsEC))
     D  dsECBytesA             5      8I 0 INZ(0)
     D  dsECMsgID              9     15
     D  dsECReserv            16     16
     D  dsECMsgDta            17    256

     D wwMsgKey        S              4A
     D wwJobNo         S             26A

      /free

         // Submit job

         cmd = 'SBMJOB CMD(' + peCmd + ') ' +
               'JOBQ(' + peJobQ +') ' +
               'JOB(' + peName+ ')';

         monitor;
           qcmdexc(%trim(cmd): %len(%trim(cmd)));
         on-error *all;
           return -1;
         endmon;

         // Look for a success message

         wwMsgKey = *ALLx'00';
         dou dsECBytesA>0 or dsM1_MsgID='CPC1221';
           QMHRCVPM(dsM1: %size(dsM1): 'RCVM0100':
                    '*': 0: '*PRV': wwMsgKey: 0: '*SAME':
                    dsEC);
           wwMsgKey = dsM1_MsgKey;
         enddo;

         if dsECBytesA>0;
           return -1;
         endif;

         // Grab the job info from the response

         if dsM1_DtaAvl >= 26;
           wwJobNo = %subst(dsM1_Dta:1:26);
         else;
           wwJobNo = *blanks;
         endif;

         if %parms >= 4;
           peSbmName = %subst(wwJobNo:1:10);
         endif;

         if %parms >= 5;
           peSbmUser = %subst(wwJobNo:11:10);
         endif;

         if %parms >= 6;
           peSbmNbr = %subst(wwJobNo:21:6);
         endif;

         return 0;

      /end-free

     P                 E
