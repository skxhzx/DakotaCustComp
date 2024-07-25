      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  FR31100      PO Receiving - Box Labeler
     *  22 October 2018
     *  Lynn McMahon
     *
     *  Revisions:
     *
720 A*    10/22/18  LMC  7.20
     *      - Created.
740aA*    02/04/20  LMC  7.40a
     *      - Enh: Retrieve label set name from LBLFMTH
740bA*    02/05/20  LMC  7.40b
     *      - Enh: Added ability to control printers for different
     *        departments and different UOM.
     *      - Enh: Close label spool file when done with each uom.
740cA*    02/20/20  LMC  7.40c
     *      - Enh: Added the UOM to the parms for the print. This was
     *        added to PO250 for the program called from green screen.
     *        Was not added to this program which is called from Gui.
740dA*    07/03/20  MLB  7.40d  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pPO         Purchase Order
     *      pqty        Qty to print
     *      pprint      printer
     *      puom        uom
     *      pPOItem     Purchase Order Item
     *      pPgm        Program
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------
     fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

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


     D pirgtin#        pr                  extpgm('PIRGTIN#')
      * Input
     D   unext                       14    const
     D   uwhse                        3  0 const

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
740dMD @prtpg          c                   const('BFCPRTLBL')
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtdte

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
     *  Variables
     *----------------------------------------------------------------

     D ppgm            s             20
     D pWhse           s              3
     D pPo             s              9
     D pprint          s             10
     D puom            s              2
     D pqty            s              5
     D pPOItem         s             15
     D  pOutStr        s            512    varying

     D client          s             10
     D clientloc       s             10

     D chk4err         s               n
     D gtin            s             14
     D jobq            s               n
     D bfcjobq         s             10
     D sbmCmd          s           3000    varying
     D sbmJob          s             10A
     D sbmUser         s             10A
     D sbmJobNbr       s              6A
     D wrkwhse         s              3p 0
     D wrkqty          s              5p 0
740bAD wkprtf          s             10
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,id#dairyla
      *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#ITEM
     D savever#        s                   like($itver#)
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D uprec         e ds                  extname(upc) inz(*EXTDFT)
     D whrec         e ds                  extname(warehs) inz(*EXTDFT)
     D rprec         E Ds                  Extname(reports)
740aAD lfhrec        e ds                  extname(lblfmth) inz(*EXTDFT)

     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pqty
     c                   parm                    pprint
     c                   parm                    puom
     c                   parm                    pPOItem
     c                   parm                    pPgm
     c                   parm                    pOutStr
     C                   parm                    pJobq             5

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;
        pOutStr = ' ';
740bA   // need to get the department for the new override
740bA   exsr clr$item;
740bA   wrkwhse = %dec(pwhse:3:0);
740bA   wrkqty  = %dec(pqty:5:0);
740bA   $itwhse  = wrkwhse;
740bA   $ititem = ppoitem;
740bA   $dricommand = '*ITEM';
740bA   $drisubcmd  = '%GETMAIN';
740bA   $drisys2upd = 'D';
740bA   chk4err = *on;
740bA   exsr zzzdricop;
740bA   if $pdev='*JOB' or $pdev=*blanks;
740bA     wkprtf = 'BOX' + %trimr($itwhdp)
740bA            + puom;
          // do we have printer overrides?
          exec sql select * into :rprec
               from reports
740bD          //where rpprtf = 'PRODUCE';
740bM          where rpprtf = :wkprtf;

          If sqlstt = sqlSuccess;
            $pform = rpform;
            $pdev = rpdev;
          endif;
740bA   endif;

        // Set jobq flag

        if %parms >= 9 and pJobq = '*JOBQ';
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

        exsr clr$item;
        wrkwhse = %dec(pwhse:3:0);
        wrkqty  = %dec(pqty:5:0);
        $itwhse  = wrkwhse;
        $ititem = ppoitem;
        $dricommand = '*ITEM';
        $drisubcmd  = '%GETMAIN';
        $drisys2upd = 'D';
        chk4err = *on;
        exsr zzzdricop;
      /end-free

      /free

        // do we have a gtin already for this item and uom.
        exec sql select * into :uprec
                 from upc
                 where upwhse = :wrkwhse
                   and upitem = :ppoitem
                   and upuom = :puom;

        if sqlstt <> sqlSuccess;
          // need to create a GTIN
          gtin = ' ';
          pirgtin#(gtin: wrkwhse);
          // now I need to load the upc file
          upwhse = wrkwhse;
          upitem = $ititem;
          upupc = '      ' + gtin;
          upven = 0;
          upvnam = ' ';
          upvitm = ' ';
          upbran = ' ';
          upuom = puom;
          Select;
            when puom = $itum1;
              uputyp = 'N';
            when puom = $itum2;
              uputyp = '1';
            when puom = $itum3;
              uputyp = '2';
          endsl;
          upctyp = '3';
          exec sql insert into upc  values(:uprec);

        else;
          gtin = %triml(upupc);
        endif;
        // load up all the fields to send to print program
        select;
          when uputyp = 'N';
              $pLfmt = 'BOXLBLC';
          when uputyp = '1';
              $pLfmt = 'BOXLBLE';
          when uputyp = '2';
              $pLfmt = 'BOXLBLE';
        endsl;
        $gs1fmt = '01' + gtin;
        $pindta = %editc($cvd6o:'Y');

        // get warehouse description
        exec sql select * into :whrec
                 from warehs
                 where whcode = :wrkwhse;

        // call the print program   ***
740aA   // Get the label set name from LBLFMTH.
740aA   exec sql select * into :lfhrec
740aA            from lblfmth;
740aA   if sqlstt = sqlSuccess;
740aA     $plset = lfhset;
740aA   else;
740aA     $plset = 'PLBL40';
740aA   endif;
      /end-free

740aDc*                  select
740aDC*                  when      client = dairyland
740aDC*                  eval      $plset = 'ZBRDRY'
740aDC*                  other
740aDC*                  eval      $plset = 'PLBL40'
740aDC*                  endSL
     C                   for       i = 1 to wrkqty
     C                   call      @prtpg
     C                   parm      '*BOXLBL '    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      wrkwhse       $plwhse           3 0
     C                   parm      whdesc        $pwhsd           30
     C                   parm                    $slwhdp           5
     C                   parm                    $sldisp          12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
740cDC*                  parm                    $pchkd1           3
740cMC                   parm      puom          $pchkd1           3
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
740bDC*                  parm      pprint        $pdev            10
740bMC                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   parm                    $gs1fmt          40
740bAC                   call      @prtpg
740bAC                   parm      '*BOXEND '    $pcmd             8
740bAC                   parm                    $plset            6
740bAC                   parm                    $plfmt            8
740bAC                   parm      wrkwhse       $plwhse           3 0
740bAC                   parm      whdesc        $pwhsd           30
740bAC                   parm                    $slwhdp           5
740bAC                   parm                    $sldisp          12
740bAC                   parm                    $pdispa           1
740bAC                   parm                    $pdispb          11
740bAC                   parm                    $pchkd1           3
740bAC                   parm                    $pchkd2           3
740bAC                   parm                    $pchkd3           3
740bAC                   parm                    wklic            15
740bAC                   parm                    $plcn2           15
740bAC                   parm      $ititem       $pditem          15
740bAC                   parm                    $pbrnd           10
740bAC                   parm      $itpdsc       $ppdesc          15
740bAC                   parm      $itdesc       $itdesc          30
740bAC                   parm      ppo           $ptxt1           30
740bAC                   parm                    $ptxt2           30
740bAC                   parm                    $ptxt3           30
740bAC                   parm                    $ptrailr          8
740bAC                   parm                    $psize            3
740bAC                   parm                    $pdev            10
740bAC                   parm                    $pform           10
740bAC                   parm                    $pexpda           8
740bAC                   parm                    $pindta           8
740bAC                   parm                    $gs1fmt          40
     C                   endfor

      /free

         pOutStr = '{'
                +  '"gtin":"'  + %trimr(gtin) + '"';

         // Close off the JSON string
         pOutStr += '}';

      /end-free

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

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C     enddricop     endsr
     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);
         // get todays date
         $cvcmd = '*CURMDY ';
         cvtdte ($cvtdt);

       endsr;

      /end-free

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
                  +      sq + pqty  + sq + ' '
                  +      sq + pprint  + sq + ' '
                  +      sq + puom    + sq + ' '
                  +      sq + ppoItem + sq + ' '
                  +      sq + ppgm    + sq + ' '
                  +      sq + pOutstr + sq + ' '
                  +      sq + '*JOBQ' + sq
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
