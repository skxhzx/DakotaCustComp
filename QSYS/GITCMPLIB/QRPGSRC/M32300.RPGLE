      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2021 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M32300       Gui Item Slot - Transfer
     *  16 February  2021
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    02/16/21  LMC  7.50
     *      - Created.
     *
     *
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     *
     Hbnddir('BFCBND')
     *

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     Fplined    if   e           k disk
     FworkUsr3  uf a e           k disk
     Fadjcode   if   e           k disk
     Fkititem   if   e           k disk
     Foptiond   if   e           k disk
     FLabel     o  a e           k disk
CBIbAFlocslog   O    E           K DISK
CBIdAFtihighsnd uf a e           k disk
700aAFitemchg   if a e           k disk
415 AFitemadj   o  a e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
CPJaA*  API programs
CPJaA*
CPJa D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n
     D dpCombo         s             20
     d hldprdDisp      s             12
     D prdtfr          s               n
     D sltc            s              3  0
     d wkaisl          s              3
     D allowZrou       s              1
     D allowZero       s              1
500cAD newssbflg       s              1
     D topick          s              1
     D dfchk           s              1
     D error           s               n
     D forever         s               n
     D i               s              2  0
     D ovrrid          s              1
     D partial         s               n
     D ssbflg          s              1
     D tfroutflag      s               n
     D warn            s              1
     D  wkType         s              3    INZ('TFR')
     D logText         s            100
     D savsubcmd       s                   like($drisubcmd)
     D uxflag          s              1
     D kywhse          s                   like(pwhse)
     D  pWhse          s              3p 0
	    d  pwhdp          s              5
	    d  pFdisp         s             12
	    d  pfitem         s             15
	    d  pTdisp         s             12
	    d  ptitem         s             15
     D  pSubCmd        s             10
     D  pqty1          s              5p 0
     D  pqty2          s              3p 0
     D  pqty3          s              3p 0
	    d  padjcd         s              2
     D  pwgt           s              9p 2
	    d  pstatovr       s              1

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
     *

     D e$whse          s              3  0
     D e$emp#          s              5  0
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

     D client          s             10
     D clientloc       s             10

     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76

     D #frombasesldsp  s                   like($sldisp)

     D #fromslwhdp     s                   like($slwhdp)
     D #fromslstyp     s                   like($slstyp)
     D #fromsldisp     s                   like($sldisp)
     D #fromslaisl     s                   like($slaisl)
     D #fromslloc      s                   like($slloc)
     D #fromslpseq     s                   like($slpseq)
     D #fromslrlvl     s                   like($slrlvl)
     D #fromslhand     s                   like($slhand)
     D #fromslstat     s                   like($slstat)
     D #fromslrsrv     s                   like($slrsrv)
     D #fromslentd     s                   like($slentd)
     D #fromslexpd     s                   like($slexpd)
     D #fromslslfd     s                   like($slslfd)
     D #fromslactv     s                   like($slactv)
     D #fromslbld      s                   like($slbld)
     D #fromslpick     s                   like($slpick)
     D #fromslitem     s                   like($slitem)
     D #fromslsdef     s                   like($slsdef)
     D #fromslpos      s                   like($sdpos)
     D #fromslvirt     s                   like($sfvirt)
     D #fromslstk1     s                   like($slstk1)
     D #fromslstk2     s                   like($slstk2)
     D #fromslstk3     s                   like($slstk3)
     D*#fromslstk3     s                   like($slstk2)
     D #fromslalc1     s                   like($slalc1)
     D #fromslalc2     s                   like($slalc2)
     D #fromslalc3     s                   like($slalc3)
     D #fromsltfr1     s                   like($sltfr1)
     D #fromsltfr2     s                   like($sltfr2)
     D #fromsltfr3     s                   like($sltfr3)
     D #fromslpck1     s                   like($slpck1)
     D #fromslpck2     s                   like($slpck2)
     D #fromslpck3     s                   like($slpck3)
     D #fromslrcv1     s                   like($slrcv1)
     D #fromslrcv2     s                   like($slrcv2)
     D #fromslrcv3     s                   like($slrcv3)
     D #fromslphy1     s                   like($slphy1)
     D #fromslphy2     s                   like($slphy2)
     D #fromslphy3     s                   like($slphy3)
     D #fromslavl1     s                   like($slavl1)
     D #fromslavl2     s                   like($slavl2)
     D #fromslavl3     s                   like($slavl3)
     D #fromToLcns     s                   like($saToLcns)
     D #fromToPos      s                   like($satopos)
     D #fromOLcns      s                   like($saOLcns)

     D #toslwhdp       s                   like($slwhdp)
     D #tosldisp       s                   like($sldisp)
     D #tosldispnew    s                   like($sldisp)
     D #toslaisl       s                   like($slaisl)
     D #toslloc        s                   like($slloc)
     D #toslrlvl       s                   like($slrlvl)
     D #toslhand       s                   like($slhand)
     D #toslstat       s                   like($slstat)
     D #toslpick       s                   like($slpick)
     D #toslitem       s                   like($slitem)
     D #toslsdef       s                   like($slsdef)

     D #fromititem     s                   like($ititem)
     D #fromittype     s                   like($ittype)
     D #fromitdesc     s                   like($itdesc)
     D #fromitpdsc     s                   like($itpdsc)
     D #fromithead     s             70
     D #fromitwhdp     s                   like($itwhdp)
     D #fromitstyp     s                   like($itstyp)
     D #fromitdesg     s                   like($itdesg)
     D #fromitum1      s                   like($itum1)
     D #fromitflg1     s                   like($itflg1)
     D #fromitum2      s                   like($itum2)
     D #fromitumq2     s                   like($itumq2)
     D #fromitflg2     s                   like($itflg2)
     D #fromitum3      s                   like($itum3)
     D #fromitumq3     s                   like($itumq3)
     D #fromitnrpk     s                   like($imnrpk)
     D #fromitflgd     s                   like($itflgd)
     D #fromitcube     s                   like($itcube)
     D #fromitswgt     s                   like($itswgt)
     D #fromitcwgt     s                   like($itcwgt)
     D #fromitmitem    s                   like($itmitem)
     D #fromitsdef     s                   like($idsdef)
     D #fromittie      s                   like($idtie)
     D #fromithigh     s                   like($idhigh)
     D #fromimltrk     s                   like($imltrk)

     D #fromssbititem  s                   like($ititem)
     D #fromssbittype  s                   like($ittype)
     D #fromssbitdesc  s                   like($itdesc)
     D #fromssbitpdsc  s                   like($itpdsc)
     D #fromssbitwhdp  s                   like($itwhdp)
     D #fromssbitstyp  s                   like($itstyp)
     D #fromssbitdesg  s                   like($itdesg)
     D #fromssbitum1   s                   like($itum1)
     D #fromssbitum2   s                   like($itum2)
     D #fromssbitumq2  s                   like($itumq2)
     D #fromssbitum3   s                   like($itum3)
     D #fromssbitumq3  s                   like($itumq3)
     D #fromssbimltrk  s                   like($imltrk)

     D #newfromititem  s                   like($ititem)
     D #newfromittype  s                   like($ittype)
     D #newfromitdesc  s                   like($itdesc)
     D #newfromitpdsc  s                   like($itpdsc)
     D #newfromitwhdp  s                   like($itwhdp)
     D #newfromithead  s             70
     D #newfromitstyp  s                   like($itstyp)
     D #newfromitdesg  s                   like($itdesg)
     D #newfromitum1   s                   like($itum1)
     D #newfromitflg1  s                   like($itflg1)
     D #newfromitum2   s                   like($itum2)
     D #newfromitumq2  s                   like($itumq2)
     D #newfromitflg2  s                   like($itflg2)
     D #newfromitum3   s                   like($itum3)
     D #newfromitumq3  s                   like($itumq3)
     D #newfromitnrpk  s                   like($imnrpk)
     D #newfromitflgd  s                   like($itflgd)
     D #newfromitcube  s                   like($itcube)
     D #newfromitswgt  s                   like($itswgt)
     D #newfromitcwgt  s                   like($itcwgt)
     D #newfromitmitm  s                   like($itmitem)
     D #newfromitsdef  s                   like($idsdef)
     D #newfromittie   s                   like($idtie)
     D #newfromithigh  s                   like($idhigh)
     D #newfromimltrk  s                   like($imltrk)

     D #newssbititem   s                   like($ititem)
     D #newssbittype   s                   like($ittype)
     D #newssbitdesc   s                   like($itdesc)
     D #newssbitpdsc   s                   like($itpdsc)
     D #newssbitwhdp   s                   like($itwhdp)
     D #newssbitstyp   s                   like($itstyp)
     D #newssbitdesg   s                   like($itdesg)
     D #newssbitum1    s                   like($itum1)
     D #newssbitum2    s                   like($itum2)
     D #newssbitumq2   s                   like($itumq2)
     D #newssbitum3    s                   like($itum3)
     D #newssbitumq3   s                   like($itumq3)
     D #newssbimltrk   s                   like($imltrk)

     D ckdate          s              8  0
CBIeAD w3zero          s              1
500cAD verifyzero      s               n
     D todisp          s             12
     D toitem          s             15
     D toslup          s              1
     D totype          s              1
     D toumq2          s              5  0
     D towhdp          s              5
600bAD tocwgt          s                   like($itcwgt)
     D svtrn1          s                   like(pttrn#)
     D svtrn2          s                   like(pttrn#)
     D svtrn3          s                   like(pttrn#)
     D newtrn          s              4
500iAD fmcube          s                   like(lbcube)
600bAD fmcwgt          s                   like($itcwgt)
500iAD fmdisp          s                   like(lbdisp)
     D fmitem          s             15
     D fmpick          s              1
     D fmqmq2          s              5  0
500iAD fmswgt          s                   like($itswgt)
     D fmtype          s              1
500cMD fmumq2          s                   like($itumq2)
500iMD fmumq3          s                   like($itumq3)
     D fmwhdp          s              5
600bAD exwgfm          s                   like(iacwta)
     D $ptrn#          s              7  0
     D curlic#         s             15
500cAD curtrn#         s              7  0
     D today           s              8  0
     D toqty1          s              5  0
610eAD Ypickslot       s               n
650aAD tfr2usrDate     s              8  0
650aAD tfr2usrTime     s              6  0
     D  $tslotpos      s              3  0
     D rtnToOrig       s               n
     D  $tlic#         s             15
     D  $tinlic#       s             15
     D  $toutlic#      s             15
640iAD $uDiffItem      s              1
640iAD $uCube          s              9  3
640iAD $uDisp          s             12
640iAD $uItem          s             15
640iAD $uPieces        s              5  0
640iAD $uRecs          s              3  0
640iAD $uRsrv          s              1
640iAD $uWhdp          s              5
640iAD $uWhse          s              3  0
640iAD $uEntDte        s              8  0
640iAD $uExpDte        s              8  0
640iAD $uDiffEntd      s              1
640iAD $uDiffExpd      s              1

     D #fromNewslavl1  s                   like($slavl1)
     D #fromNewslavl2  s                   like($slavl2)
     D #fromNewslavl3  s                   like($slavl3)
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
600fA*----------------------------------------------------------------
600fA*  Time variables
600fA*----------------------------------------------------------------
600fA
600fAD CurrStamploc    s               z
600fAD CurrStampsys    s               z
600fAD CurrStampuc     s               z
600fA
600fAD bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pSubCmd      DRI subcommand without '%'.
     *      pObjLoc      External object location called from.
     *      pparmstr1    Parm String
     *      pparmstr2    parm string
     *      pparmstr3    parm string
     *
     *    Returned Parameters
     *      pmessage     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pDict          s             10
     D  pPgm           s             10
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.getuser
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien
600fA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D prdslt          S              3    dim(100)
     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#cpj
      /copy qcopysrc,id#westsid
      /COPY QCOPYSRC,ID#CITYWHO
CBIeA /COPY QCOPYSRC,Id#CHENEY
MRTaA /copy qcopysrc,id#mrt
EFCaA /COPY QCOPYSRC,id#eastlan
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#SLOTDEF
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pSessId
     C                   parm                    pUser
     C                   parm                    pDict
     C                   parm                    pPgm
     C                   parm                    pObjLoc
     C                   parm                    pparmStr1
     C                   parm                    pparmStr2
     C                   parm                    pparmStr3
      /free

        if dbgflgExists;
          chain(e) (#pgm) bfcdbgflg;
          if %found(bfcdbgflg);
            debug = (bdfflag = 1);
          else;
            debug = *off;
          endif;
        endif;

        // Combine dictionary/program

        dpCombo = %trim(pDict) + '.' + pPgm;

        *inlr = *on;
        pMessage= ' ';

        // Extract parameters from delimited string

        ExtractParms();

	       pfitem = %xlate(xlower: xupper: pfitem);
	       ptitem = %xlate(xlower: xupper: ptitem);
	       puser = %xlate(xlower: xupper: puser);
	       ptdisp = %xlate(xlower: xupper: ptdisp);
	       pfdisp = %xlate(xlower: xupper: pfdisp);

        exsr zzedit;
        if pMessage = ' ';
          exsr zzupd;
        endif;


         // Write debug record if flag is on.

         if debug;
           exsr wrtDebugParms;
         endif;

         // If an error occurs outside of FLDVALID,
         //   write a record to the debug log, regardless of flag.
         // We don't do this for FLDVALID because the calling program
         // will catch it and display the error.


         if pObjLoc <> 'FLDVALID' and pMessage<> ' ';
           if not debug;
             exsr wrtDebugParms;
           endif;
           exsr wrtDebugError;
         endif;

         $drisubcmd = '%CLOSE';
         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);
         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;

         getclient(client: clientLoc);
         open(e) bfcdbgflg;
         if %error;
           dbgflgExists = *off;
         else;
           dbgflgExists = *on;
         endif;


         dfchk = '0';
         tfroutflag = *off;

      /end-free
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
417cAC                   eval      ckdate = $cvd8o
     *
415cAC                   eval      newtrn = '*NO '
415gAC                   eval      toslup = *off
      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  prodslot       Setup array to verify production slots
     *----------------------------------------------------------------

      /free
       begsr prodslot;
650eA   // setup array to verify production slots for WIP and Lines
650eA /free
650eA                    sltc = 1;
650eA                    dow sltc < 101;
650eA                       prdslt(sltc) = '   ';
650eA                       sltc = sltc +1;
650eA                    enddo;
650eA
650eA                    setll (*zeros:*zeros) plined;
650eA                    read plined;
650eA                    dow not %eof(plined);
650eA
650eA                       sltc = 1;
650eA                       // look for raw material aisle location
650eA                       dow sltc < 101;
650eA                          if prdslt(sltc) = '   '
650eA                              or prdslt(sltc) = inRcvAisl;
650eA                             leave;
650eA                          endif;
650eA                          sltc = sltc +1;
650eA                       enddo;
650eA                       // if comes out blank it means we should
650eA                       // add to the array of prod slot aisles
650eA                       if prdslt(sltc) = '   ';
650eA                          prdslt(sltc) = inRcvAisl;
650eA                       endif;
650eA
650eA                       sltc = 1;
650eA                       // look for WIP Stock aisle location
650eA                       dow sltc < 101;
650eA                          if prdslt(sltc) = '   '
650eA                              or prdslt(sltc) = inWipAisl;
650eA                             leave;
650eA                          endif;
650eA                          sltc = sltc +1;
650eA                       enddo;
650eA                       // if comes out blank it means we should
650eA                       // add to the array of prod slot aisles
650eA                       if prdslt(sltc) = '   ';
650eA                          prdslt(sltc) = inWipAisl;
650eA                       endif;
650eA
650eA                       read plined;
650eA                    enddo;
650eA /end-free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = 'pSessId:' + %trimr(pSessId) + ', '
                  + 'pUser:' + %trimr(pUser) + ', '
                  + 'pDict:' + %trimr(pDict) + ', '
                  + 'pPgm:' + %trimr(pPgm) + ', '
                  + 'pWhse:' + %char(pWhse) + ', '
                  + 'pObjLoc:' + %trimr(pObjLoc) + ', '
                  + 'pSubCmd:' + %trimr(pSubCmd) + ', '
                  + 'pWhdp:' + %trimr(pWhdp) + ', '
                  + 'pfdisp:' + %trimr(pfdisp) + ', '
                  + 'ptdisp:' + %trimr(ptdisp) + ', '
                  + 'pfItem:' + %trimr(pfItem) + ', '
                  + 'ptItem:' + %trimr(ptItem) + ', '
                  + 'pstatovr:' + %trimr(pstatovr) + ', '
                  + 'pMessage:' + %trimr(pMessage);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = puser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = pMessage;

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = puser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzedit         Do Edits
     *----------------------------------------------------------------

      /free
       begsr zzedit;

         pMessage = ' ';

     *
     *    Get User's employee number
     *
        // get user employee number
        e$whse = 0;
        e$emp# = 0;
        e$fnam = ' ';
        e$init = ' ';
        e$lnam = ' ';
        e$whdp = ' ';
        e$styp = ' ';
        e$shft = ' ';
        e$crew = ' ';
        e$nhrs = 0;
        e$rtn  = ' ';
        e$lng  = ' ';
        e$bpu  = ' ';
        getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        exsr prodslot;
        exsr zzwrkinz;

        //Do not allow the transfer from a RCV/STG slot.
        // except for *CHANGEX

        if psubcmd = '*CHANGEX';
          psubcmd = '*CHANGE';
        else;
          if %subst(pfdisp:1:3) = 'RCV'
           or %subst(pfdisp:1:3) = 'STG'
           or %subst(pfdisp:1:3) = 'RTN'
           or %subst(pfdisp:1:3) = 'RWO';
            error = *on;
            pMessage = 'RCV/STG/RTN/RWO slot not '
                     + 'allowed - use Putaway';
            leavesr;
          endif;
        endif;
        //must send item
        if ptitem = ' ';
          error = *on;
          pMessage = 'Item must be entered';
          leavesr;
        endif;

        //to slot must be sent
        if ptdisp = ' ';
          error = *on;
          pMessage = 'To Slot must be entered';
          leavesr;
        endif;

        // get from slot
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $saemp#U = *on;
        $saemp# = e$emp#;

        $slwhseu = *on;
        $slwhse  = pwhse;
        $slwhdpu = *on;
        $slwhdp  = pwhdp;
        $sldispu = *on;
        $sldisp  = pfdisp;

        $dricommand = '*SLOT';
        $drisubcmd  = '%GETCHKV';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;

        #fromslwhdp = $slwhdp;
        #fromslstyp = $slstyp;
        #fromsldisp = $sldisp;
        #fromslaisl = $slaisl;
        #fromslloc  = $slloc;
        #fromslpseq = $slpseq;
        #fromslrlvl = $slrlvl;
        #fromslhand = $slhand;
        #fromslstat = $slstat;
        #fromslrsrv = $slrsrv;
        #fromslentd = $slentd;
        #fromslexpd = $slexpd;
        #fromslslfd = $slslfd;
        #fromslactv = $slactv;
        #fromslbld  = $slbld;
        #fromslpick = $slpick;
        #fromslitem = $slitem;
        #fromslsdef = $slsdef;
        #fromslvirt = $sfvirt;
        #fromslstk1 = $slstk1;
        #fromslstk2 = $slstk2;
        #fromslstk3 = $slstk3;
        #fromslalc1 = $slalc1;
        #fromslalc2 = $slalc2;
        #fromslalc3 = $slalc3;
        #fromsltfr1 = $sltfr1;
        #fromsltfr2 = $sltfr2;
        #fromsltfr3 = $sltfr3;
        #fromslpck1 = $slpck1;
        #fromslpck2 = $slpck2;
        #fromslpck3 = $slpck3;
        #fromslrcv1 = $slrcv1;
        #fromslrcv2 = $slrcv2;
        #fromslrcv3 = $slrcv3;
        #fromslphy1 = $slphy1;
        #fromslphy2 = $slphy2;
        #fromslphy3 = $slphy3;
        #fromslavl1 = $slavl1;
        #fromslavl2 = $slavl2;
        #fromslavl3 = $slavl3;
        #fromToLcns = $saToLcns;
600eA   curlic# = #fromToLcns;
        #fromToPos  = $saToPos;
        #fromOLcns = $saOLcns;
        #frombasesldsp = $sacdsp;
600eA   $tlic# = #fromToLcns;
600eA   $tinlic# = #fromToLcns;
600eA   $toutlic# = #fromToLcns;

        // Slot does not contain an item.
        if $slitem = *blanks;
          error = *on;
          pMessage = 'Slot does not contain '
                   + 'an item.';
          leavesr;
        endif;


        // from slot has no item
        if $slitem = ' ';
          pMessage = 'Cannot change slot - '
                   + 'Slot does not contain item';
          leavesr;
        endif;

        // get slot definition

        savever# = $slver#;
        clear $slotdef;
        $sdver# = savever#;

        $sdwhse  = $slwhse;
        $sdcode  = $slsdef;

        $dricommand = '*SLOTDEF';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slotdef;
        clear $dridata2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slotdef = $dridata;
        if $sdpos > 0;
          #fromslpos = $sdpos;
        else;
          #fromslpos = 1;
        endif;

        // get item for uci tracking edit
        if ptitem <> $slitem;
          savever# = $slver#;
          clear $item;
          clear $item2;
          $itver# = savever#;

          $itwhse  = pwhse;
          $ititem  = ptitem;
          $dricommand = '*ITEM';
          $drisubcmd  = '%GETALL';
          $drisys2upd = 'D';
          $driprogram = #pgm;
          $dridata = $item;
          $dridata2 = $item2;
          // Call DRI program.
          driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                 $drireturn: $drimessage: $dridata: $dridata2);
          $item = $dridata;
          $item2 = $dridata2;

          #newfromititem = $ititem;
          #newfromittype = $ittype;
          #newfromitdesc = $itdesc;
          #newfromitpdsc = $itpdsc;
          #newfromitwhdp = $itwhdp;
          #newfromitstyp = $itstyp;
          #newfromitdesg = $itdesg;
          #newfromitum1  = $itum1;
          #newfromitflg1 = $itflg1;
          #newfromitum2  = $itum2;
          #newfromitumq2 = $itumq2;
          #newfromitflg2 = $itflg2;
          #newfromitum3  = $itum3;
          #newfromitumq3 = $itumq3;
          #newfromitnrpk = $imnrpk;
          #newfromitflgd = $itflgd;
          #newfromitcube = $itcube;
          #newfromitswgt = $itswgt;
          #newfromitcwgt = $itcwgt;
          #newfromitmitm = $itmitem;
          #newfromimltrk = $imltrk;
          // UCI TRACKING items are not allowed to be transferred from
          // item slot maintenance
          if $imltrk = 'U';
            error = *on;
            pMessage = 'Transfer not allowed on UCI Tracked Item';
            leavesr;
          endif;
        endif;
        // get item

        savever# = $slver#;
        clear $item;
        clear $item2;
        $itver# = savever#;

        $itwhse  = $slwhse;
        $ititem  = $slitem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETALL';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $item;
        $dridata2 = $item2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $item = $dridata;
        $item2 = $dridata2;

        // UCI TRACKING items are not allowed to be transferred from
        // item slot maintenance
        if $imltrk = 'U';
          error = *on;
          pMessage = 'Transfer not allowed on UCI Tracked Item';
          leavesr;
        endif;

        #fromititem = $ititem;
        #fromittype = $ittype;
        #fromitdesc = $itdesc;
        #fromitpdsc = $itpdsc;
        #fromitwhdp = $itwhdp;
        #fromitstyp = $itstyp;
        #fromitdesg = $itdesg;
        #fromitum1  = $itum1;
        #fromitflg1 = $itflg1;
        #fromitum2  = $itum2;
        #fromitumq2 = $itumq2;
        #fromitflg2 = $itflg2;
        #fromitum3  = $itum3;
        #fromitumq3 = $itumq3;
        #fromitnrpk = $imnrpk;
        #fromitflgd = $itflgd;
        #fromitcube = $itcube;
        #fromitswgt = $itswgt;
        #fromitcwgt = $itcwgt;
        #fromitmitem = $itmitem;
        #fromimltrk = $imltrk;
        #fromitsdef = ' ';
        #fromittie  = 0;
        #fromithigh = 0;

        //               call      'FRMTIT'
        //               parm                    #fromititem
        //               parm                    #fromitdesc
        //               parm                    #fromitpdsc
        //               parm      ' '           #fromithead
      /end-free
500cA
500cA*  Save tie/high info if defined for item.
500cA
     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
      /free
        // Use DRI interface to get corresponding SSB item, if any.
        savever# = $slver#;
        clear $item;
        clear $item2;
        $itver# = savever#;

        $itwhse  = $slwhse;
        $ititem  = $slitem;

        $dricommand = '*ITEM';
        $drisubcmd  = '%GETSSB';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $item;
        $dridata2 = $item2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $item = $dridata;
        $item2 = $dridata2;

        if $drireturn = 'SSBNOTFND';
          ssbflg  = *off;
          #fromssbititem = ' ';
          #fromssbittype = ' ';
          #fromssbitdesc = ' ';
          #fromssbitpdsc = ' ';
          #fromssbitwhdp = ' ';
          #fromssbitstyp = ' ';
          #fromssbitdesg = ' ';
          #fromssbitum1  = ' ';
          #fromssbitum2  = ' ';
          #fromssbitumq2 = 0;
          #fromssbitum3  = ' ';
          #fromssbitumq3 = 0;
          #fromssbimltrk = 'L';
        else;
          ssbflg  = *on;
          #fromssbititem = $ititem;
          #fromssbittype = $ittype;
          #fromssbitdesc = $itdesc;
          #fromssbitpdsc = $itpdsc;
          #fromssbitwhdp = $itwhdp;
          #fromssbitstyp = $itstyp;
          #fromssbitdesg = $itdesg;
          #fromssbitum1  = $itum1;
          #fromssbitum2  = $itum2;
          #fromssbitumq2 = $itumq2;
          #fromssbitum3  = $itum3;
          #fromssbitumq3 = $itumq3;
          #fromssbimltrk = $imltrk;
        endif;

        if pfitem = ptitem;
          #newfromititem = #fromititem;
          #newfromittype = #fromittype;
          #newfromitdesc = #fromitdesc;
          #newfromitpdsc = #fromitpdsc;
          #newfromithead = #fromithead;
          #newfromitwhdp = #fromitwhdp;
          #newfromitstyp = #fromitstyp;
          #newfromitdesg = #fromitdesg;
          #newfromitum1  = #fromitum1;
          #newfromitflg1 = #fromitflg1;
          #newfromitum2  = #fromitum2;
          #newfromitumq2 = #fromitumq2;
          #newfromitflg2 = #fromitflg2;
          #newfromitum3  = #fromitum3;
          #newfromitumq3 = #fromitumq3;
          #newfromitnrpk = #fromitnrpk;
          #newfromitflgd = #fromitflgd;
          #newfromitcube = #fromitcube;
          #newfromitswgt = #fromitswgt;
          #newfromitcwgt = #fromitcwgt;
          #newfromitmitm = #fromitmitem;
          #newfromitsdef = #fromitsdef;
          #newfromittie  = #fromittie;
          #newfromithigh = #fromithigh;
          newssbflg  = ssbflg;
          #newssbititem = #fromssbititem;
          #newssbittype = #fromssbittype;
          #newssbitdesc = #fromssbitdesc;
          #newssbitpdsc = #fromssbitpdsc;
          #newssbitwhdp = #fromssbitwhdp;
          #newssbitstyp = #fromssbitstyp;
          #newssbitdesg = #fromssbitdesg;
          #newssbitum1  = #fromssbitum1;
          #newssbitum2  = #fromssbitum2;
          #newssbitumq2 = #fromssbitumq2;
          #newssbitum3  = #fromssbitum3;
          #newssbitumq3 = #fromssbitumq3;
        endif;
        // edits from IT352 zzchk1
        error = *off;
        //  If zero qty entered, all slot buckets are zero, and
        //  item did not change, set allowZero flags to *on.

        allowZrou = *off;
        allowZero = 'N';
        if (pqty1=0 and pqty2=0 and pqty3=0)
            and #fromslalc1 = 0
            and #fromslalc2 = 0
            and #fromslalc3 = 0
            and #fromslrcv1 = 0
            and #fromslrcv2 = 0
            and #fromslrcv3 = 0
            and #fromsltfr1 = 0
            and #fromsltfr2 = 0
            and #fromsltfr3 = 0
            and #fromslstk1 = 0
            and #fromslstk2 = 0
            and #fromslstk3 = 0
            and ptitem = #fromslitem;
          allowZrou = *on;
          allowZero = 'Y';
        endif;

        // Verify quantity is greater than zero.

        if allowZrou = *off;
          if (pqty1 =0 and pqty2 =0 and pqty3 =0);
            error = *on;
            pMessage = 'Quantity cannot be zero';
            leavesr;
          endif;
          // If non-zero transfer, quantity must not be negative
          if pqty1 < 0
             or pqty2  < 0
             or pqty3  < 0;
            error = *on;
            pMessage = 'Qty cannot be less than zero';
            leavesr;
          endif;
        else;
          //if zero transfer, make sure quantity is not negative
          if pqty1 < 0
             or pqty2 < 0
             or pqty3 < 0;
            error = *on;
            pMessage = 'Quantity cannot be negative'
                     + ' for a zero transfer';
            leavesr;
          endif;
        endif;

        // When transfering from a USR slot, qty entered must
        // match USR slot qty.
        if #fromslaisl = 'USR';
          if pqty1 <> #fromslavl1
             or pqty2 <> #fromslavl2
             or pqty3 <> #fromslavl3;
            error = *on;
            pMessage = 'Entire qty must be taken '
                     + 'for a USR slot';
            leavesr;
          endif;
        endif;

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $saemp#U = *on;
        $saemp# = e$emp#;

        $slwhseu  = *on;
        $slwhse   = pwhse;
        $slwhdpu  = *on;
        $slwhdp   = #fromslwhdp;
        $sldispu  = *on;
        $sldisp   = #fromsldisp;
        $saitemu  = *on;
        $saitem   = #fromslitem;
        $saqtyu   = *on;
        $saqty1   = pqty1;
        $saqty2   = pqty2;
        $saqty3   = pqty3;
        $sacitemu = *on;
        $sacitem  = ptitem;
        $saAllowZrou = allowZrou;
        $saAllowZero = allowZero;
        $saAllowZrou = allowZrou;
        $saAllowZero = allowZero;

        $dricommand = '*SLOT';
        $drisubcmd  = '%VFYTFOCHG';
        $drisys2upd = 'D';
        $dridata = $slot;
        $dridata2 = $slot2;
        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drimessage <> ' ';
          pMessage = $drimessage;
          error = *on;
          leavesr;
        endif;
        // NEED TO SAVE $SLAVL FIELDS FOR SETTING PARTIAL
        #fromNewslavl1 = $slavl1;
        #fromNewslavl2 = $slavl2;
        #fromNewslavl3 = $slavl3;

        //Item changed, display warning.
        if ovrrid = *off;
          If ptitem <> #fromslitem;
            error = *on;
            warn = *on;
            pMessage = 'Warning Item changed, click override';
            leavesr;
          endif;
        endif;

        // edits from IT352 zzchk2
      /end-free
CPJaAC                   if        client = CPJ
CPJaAC                   call      @apics
CPJaAC                   parm                    ptdisp
CPJaAC                   parm                    row#              2
CPJaAC                   parm                    col#              4 0
CPJaAC                   parm                    @artn             8
CPJaAC                   endif
      /free
        // if production slot ensure virtual is created for to slot
        prdtfr = *off;
        sltc = 0;
        wkaisl = %subst(ptdisp:1:3);
        sltc = %lookup(wkaisl:prdslt:1);
        if (sltc <> 0 and wkaisl <> ' ') or wkaisl='RP                 K';
          prdtfr = *on;
          savever# = $slver#;
          clear $slot;
          clear $slot2;
          $slver# = savever#;
          $saemp#U = *on;
          $saemp# = e$emp#;

          $slwhseu = *on;
          $slwhse  = pWhse;
          $slwhdpu = *on;
          $slwhdp  = #newfromitwhdp;
          $slitemu = *on;
          $slitem  = ptitem;
          $sldispu = *on;
          $sldisp  = ptdisp;
          $slstatu = *on;
          $slstat  = 'PR';

          $dricommand = '*SLOT';
          if wkaisl = 'RPK';
            $slstat  = 'RP';
            $drisubcmd  = '%CRTREPAKP';
          else;
            $drisubcmd  = '%CRTPROD';
          endif;
          $drisys2upd = 'D';
          $driprogram = #pgm;
          $dridata = $slot;
          $dridata2 = $slot2;

          // Call DRI program.
          driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                 $drireturn: $drimessage: $dridata: $dridata2);

          $slot = $dridata;
          $slot2 = $dridata2;
          hldprdDisp = $sldisp;
          error = *off;
        endif;

        // Item changed, verify adjustment code
        if pfitem <> ptitem;
          chain (padjcd) adjcode;
          if not %found(adjcode);
            error = *on;
            pMessage = 'Invalid adjustment code';
            leavesr;
          endif;
        endif;

        // If transfer to represents a Repack Item
        // verify on-demand slot exists
        if #newfromitType = 'R';
          chain (pWhse:ptitem) kititem;
          if not %error and %found;
            if kidisp <> ' ';
              savever# = $slver#;
              clear $slot;
              clear $slot2;
              $slver# = savever#;
              $saemp#U = *on;
              $saemp# = e$emp#;

              $slwhseu = *on;
              $slwhse  = pWhse;
              $slwhdpu = *on;
              $slwhdp  = #newfromitwhdp;
              $slitemu = *on;
              $slitem  = ptitem;
              $sldispu = *on;
              $sldisp  = kidisp;

              $dricommand = '*SLOT';
              $drisubcmd  = '%CRTREPAKD';
              $drisys2upd = 'D';
              //chk4err = *on;
              $dridata = $slot;
              $dridata2 = $slot2;

              // Call DRI program.
              driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                     $drireturn: $drimessage: $dridata: $dridata2);

              $slot = $dridata;
              $slot2 = $dridata2;
              //odrSlot = $sldisp;
              error = *off;
            endif;
          endif;
        endif;

        // Verify "To Slot" number.
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $saemp#U = *on;
        $saemp# = e$emp#;
        $slwhseu  = *on;
        $slwhse   = pwhse;
        $slwhdpu  = *on;
        $slwhdp   = #newfromitwhdp;
        $sldispu  = *on;
        if prdtfr;
          $sldisp   = hldprdDisp;
        else;
          $sldisp   = ptdisp;
        endif;
        $slexpdu  = *on;
        $slexpd   = #fromslexpd;
        $saitemu  = *on;
        $saitem   = ptitem;
        $saqtyu   = *on;
        $saqty1   = pqty1;
        $saqty2   = pqty2;
        $saqty3   = pqty3;
        $sacitemu = *on;
        $sacitem  = #fromslitem;
        $sacdspu  = *on;
        $sacdsp   = #fromsldisp;
        $saAllowZrou = allowZrou;
        $saAllowZero = allowZero;

        $saActionU = *on;
        $saAction = 'TFR';

        $dricommand = '*SLOT';
        $drisubcmd  = '%VFYTFICHG';
        $drisys2upd = 'D';
        //chk4err = *on;
        //zmsflag = *off;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        if $drimessage <> ' ';
          error = *on;
          pMessage = $drimessage;
          leavesr;
        endif;

        #toslwhdp = $slwhdp;
        #tosldisp = $sldisp;
        #toslaisl = $slaisl;
        #toslloc  = $slloc;
        #toslrlvl = $slrlvl;
        #toslhand = $slhand;
        #toslpick = $slpick;
        #toslsdef = $slsdef;
        #toslstat = $slstat;

        // check usage only on directed putaway
        chain ('*PICK':pwhse:#toslwhdp) optiond;
        if not %found(optiond);
          opmput = 'N';
        endif;
        // See if something alread in slot location.
      /end-free
     C                   if        opmput = 'N'
     C                   call      'CHKUSAGE'
     C                   parm      $slwhse       $uWhse
     C                   parm      $slwhdp       $uWhdp
     C                   parm      $sldisp       $uDisp
     C                   parm      $slrsrv       $uRsrv
     C                   parm      $saitem       $uItem
     C                   parm      $slentd       $uEntDte
     C                   parm      $slexpd       $uExpDte
     C                   parm      0             $uPieces
     C                   parm      0             $uRecs
     C                   parm      ' '           $uDiffItem
     C                   parm      ' '           $uDiffEntd
     C                   parm      ' '           $uDiffExpd
      /free
        // For directed putaway, To slot cannot have different item.
          select;
            when client = westside;
              if $uDiffItem = 'Y';
                error = *on;
                pMessage = 'To slot contains a different item.';
                leavesr;
              endif;
          endsl;
        endif;



        // Save tie/high info if defined for item.
        #newfromitsdef = ' ';
        #newfromittie  = 0;
        #newfromithigh = 0;
      /end-free
     c     1             do        5             i
     c                   if        $idsdef(i) = #toslsdef
     c                   eval      #newfromitsdef = $idsdef(i)
     c                   eval      #newfromittie  = $idtie(i)
     c                   eval      #newfromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
      /free

        topick = $slpick;
        // Verify record exists in itemdef (tie/high) file.
        // If no record is found, display warning message.
        if ovrrid = *off
           and client <> 'CITYWHO';
          if #toslpick = 'Y' and #newfromitsdef = ' ';
            error = *on;
            warn = *on;
            pMessage = 'No record exists in Tie/High def. file.';
            leavesr;
          endif;
        endif;

        //Set override to check slot status change (to / from inactive)
        if dfchk  = '0' and
           ovrrid = *on;
          ovrrid = *off;
        endif;

        if dfchk  = '2' and
           ovrrid = *on;
          dfchk  = '1';
        endif;
        // Warning if transfer is to different slot status.
        if pstatovr <> 'Y';
          if #toslstat <> 'V' and #toslstat <> 'Z';
            if #toslstat <> #fromslstat;
              error = *on;
              pMessage = 'Warning: From/To slot status do not match';
              leavesr;
            endif;
          endif;
        endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzupd          update slots
     *----------------------------------------------------------------

      /free
       begsr zzupd;

500cA   lbwhdp = #fromslwhdp;
500cA   lbstyp = #fromslstyp;
500cA   exsr zztrnstart;
        // from zzupd1 it352
        //Item changed, set flag for adjustment code entry.
        if #fromslitem <> ptitem;
          *in59 = *on;
        else;
          *in59 = *off;
          *in60 = *off;
        endif;

        // Set partial quantity flag.

        // These values were recalculated and sent back from
        // the VFYTFOCHG command. If all of the original #FROM
        // buckets were zero and the new Avail quantities are
        // zero, then the entire quantity is being taken.

        if #fromNewslavl1 = 0 and
           #fromNewslavl2 = 0 and
           #fromNewslavl3 = 0 and
           #fromslalc1 = 0 and
           #fromslalc2 = 0 and
           #fromslalc3 = 0 and
           #fromslrcv1 = 0 and
           #fromslrcv2 = 0 and
           #fromslrcv3 = 0 and
           #fromslpck1 = 0 and
           #fromslpck2 = 0 and
           #fromslpck3 = 0 and
           #fromsltfr1 = 0 and
           #fromsltfr2 = 0 and
           #fromsltfr3 = 0;
          partial = *off;
        else;
          partial = *on;
        endif;

        select;
          when partial = *on;
            curlic# = '*SP';
          when $satolcns = '*MULTIPLE';
            curlic# = '*NA';
          other;
            curlic# = $tinlic#;
        endsl;
        // Use DRI interface to update From slot.
        // Note: The $sl info that was retrieved in ZZGET1.
        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $saemp#U = *on;
        $saemp# = e$emp#;

        $slwhseu  = *on;
        $slwhse   = pwhse;
        $slwhdpu  = *on;
        $slwhdp   = #fromslwhdp;
        $sldispu  = *on;
        $sldisp   = #fromsldisp;
        $saitemu  = *on;
        $saitem   = #fromslitem;
        $saqtyu   = *on;
        $saqty1   = pqty1;
        $saqty2   = pqty2;
        $saqty3   = pqty3;
        $sacitemu = *on;
        $sacitem  = #fromslitem;

        $satasku = *on;
        $satask  = 'TFRMOV';

        $saActionU = *on;
        $saAction = 'TFR';
        $saTrn#U = *on;
        $saTrn# = curtrn#;
        $saETrn#U = *on;
        $saETrn# = 0;
        $saToLcnsU = *on;
        $saToLcns = curlic#;
        $saToPosU = *on;
        $saToPos = $tslotpos;
        $saToVrfyU = *on;
        $saToVrfy = 'N';
        $saToCodeu = *on;
        $saToCode = 'U';
        $saToAreaU = *on;
        $saToArea = 'User';
        $saFrmLcnsU = *on;
        $saFrmLcns = $toutlic#;
        $saOLcnsU = *on;
        $saOLcns = wuPulolcns;

        // Set item change flag
        if #fromslitem <> ptitem;
          $saItmChgU = *on;
          $saItmChg = 'Y';
        endif;

        $dricommand = '*SLOT';

        //  Do Reverse transfer if Pick slot and item didn't change.
        if #fromslpick = 'Y'
           and #fromslitem = ptitem;
          Ypickslot   = *on;
          $saAllowZrou = allowZrou;
          $saAllowZero = allowZero;
          $drisubcmd  = '%TFR2USRR';
        else;
          $drisubcmd  = '%TFR2USR';
        endif;

        $drisys2upd = 'D';
        // chk4err = *on
        // zmsflag = *off
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
        tfr2usrDate = today;
        tfroutflag = *on;
        curlic# = $saToLcns;
        $tinlic# = $saToLcns;
      /end-free
650aAC                   time                    tfr2usrTime
      /free

        // Override $saFrmEmpty for an empty Pick slot.
        //Re:We want to ask a user if the slot is empty just in case he is
        //moving the item to another Pick slot and we are allow to autoverify.

        if client = cheney;
          if Ypickslot = *on
             and partial = *off;
            $saFrmEmpty = 'Y';
          endif;
        endif;

        exsr zzwrkadd;

        //  Check if slot can be verified after transfer complete.
        if client = cheney;
          exsr zzchkzrovfy;
        else;
          verifyzero = *off;
        endif;
        if verifyzero;
          w3zero = 'Y';
        else;
          w3zero = 'N';
        endif;

        //Change quantity to breakdown quantity if needed.
        if #fromslitem <> ptitem;
          if #fromittype = ' ';
            if #newfromittype = 'S'  or
               #newfromittype = 'B'  and
               #fromitumq2 <> 0;
              toqty1 = pqty1 * #fromitumq2;
            else;
              toqty1 = pqty1;
            endif;
          endif;
          if #fromittype = 'S'  or
             #fromittype = 'B';
            if #newfromittype = ' '  and
               #newfromitumq2 <> 0;
              toqty1 = pqty1 / #newfromitumq2;
            else;
              toqty1 = pqty1;
            endif;
          endif;
        else;
          toqty1 = pqty1;
        endif;

        // Determine if we are returning qty to original slot.
        // (If this logic is changed, also change in ZZUPD2)
        if #toslwhdp = wuPulWhdp
           and #tosldisp = wuPulDisp
           and ptitem = wuPulItem;
          rtnToOrig = *on;
        else;
          rtnToOrig = *off;
        endif;

        // Use DRI interface to tfr qty from USR slot to To slot.

        savever# = $slver#;
        clear $slot;
        clear $slot2;
        $slver# = savever#;
        $saemp#U = *on;
        $saemp# = e$emp#;
        $slwhseu  = *on;
        $slwhse   = pwhse;
        $slwhdpu  = *on;
        $slwhdp   = #toslwhdp;
        $sldispu  = *on;
        if prdtfr;
          $slstatu  = *on;
          $slstat   = 'PR';
          $sldisp   = hldprdDisp;
        else;
          $sldisp   = #tosldisp;
        endif;
        $slentdu  = *on;
        $slentd   = #fromslentd;
        $slexpdu  = *on;
        $slexpd   = #fromslexpd;
        $saitemu  = *on;
        $saitem   = ptitem;
        $saqtyu   = *on;
        $saqty1   = pqty1;
        $saqty2   = pqty2;
        $saqty3   = pqty3;
        $sacitemu = *on;
        $sacitem  = #fromslitem;
        $sacwhdu = *on;
        $sacwhd  = wuUsrWhdp;
        $sacdspu  = *on;
        $sacdsp   = wuUsrDisp;
        $saToposu = *on;
        $saTopos  = $tslotpos;

        $saActionU = *on;
        $saAction = 'TFR';
        $saTrn#U = *on;
        $saTrn# = curtrn#;
        $saETrn#U = *on;
        $saETrn# = 0;
        $saToLcnsU = *on;
        if partial = *on;
          $saToLcns = '*NA';
        else;
          $saToLcns = $tinlic#;
        endif;
        $saToPosU = *on;
        $saToPos = $tslotpos;
        $saToVrfyU = *on;
        $saToVrfy = 'N';
        $saToCodeu = *on;
        $saToCode = 'S';
        $saToAreaU = *on;
        $saToArea = 'Slot';
        $saFrmLcnsU = *on;
        if partial = *on;
        $saFrmLcns = $tinlic#;
        else;
        $saFrmLcns = $toutlic#;
        endif;
        $saOLcnsU = *on;
        $saOLcns = wuPulolcns;
        $sapullwhdpu = *on;
        $sapullwhdp  = wuPulWhdp;
        $sapulldispu = *on;
        $sapulldisp  = wuPulDisp;
        $sapullbaseu = *on;
        $sapullbase  = wuPulBase;
        $sapulllcnsu = *on;
        $sapulllcns  = wuPulLcns;
        $saAllowZrou = allowZrou;
        $saAllowZero = allowZero;

        //  Set changed item flag if necessary.

        if #fromslitem <> ptitem;
          $saItmChgU = *on;
          $saItmChg = 'Y';
        endif;

        if rtnToOrig = *on;
          $saexcdU = *on;
          $saexcd  = 'RTNORIG';
        endif;
        // you cant do uci in here, so this can probably be removed
        //if $tpartial = *on;
          //$saUCIts = $tpartime;
          //$saUCItsU = *on;
        //endif;

        $dricommand = '*SLOT';
        $drisubcmd  = '%USR2PUT';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;


        //Update #TO slot info in case item was put into a virtual slot
        #toslhand = $slhand;
        #tosldisp = $sldisp;
        if prdtfr;
          #toslstat = 'PR';
        else;
          #toslstat = $slstat;
        endif;

        // Use DRI interface to update From slot.
        if Ypickslot = *on
           and $slpick = 'Y'
           and $slstat <> 'RP'
           and $slstyp = 'F';
          savever# = $slver#;
          clear $slot;
          clear $slot2;
          $slver# = savever#;
          $saemp#U = *on;
          $saemp# = e$emp#;
          $slwhseu  = *on;
          $slwhse   = pwhse;
          $slwhdpu  = *on;
          $slwhdp   = #fromslwhdp;
          $sldispu  = *on;
          $sldisp   = #fromsldisp;
          $slitemu  = *on;
          $slitem   = #fromslitem;
          $slstat   = *off;
          $slstat   = #fromslstat;
          $dricommand = '*SLOT';
          $drisubcmd  = '%SETSTAT  ';
          $drisys2upd = 'D';
          $driprogram = #pgm;
          $dridata = $slot;
          $dridata2 = $slot2;

          // Call DRI program.
          driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                 $drireturn: $drimessage: $dridata: $dridata2);

          $slot = $dridata;
          $slot2 = $dridata2;

          Ypickslot = *off;
          if $drireturn = 'NOTZROSTAT';
            error = *off;
          endif;
        endif;
        Ypickslot = *off;

        // Create label(s), create extra trans, close trans.
        exsr zzcrtl;

        // Delete work record
        exsr zzwrkdel;

        // Use DRI interface to zero verify From slot if needed.

        if verifyzero and w3zero = 'Y';
          savever# = $slver#;
          clear $slot;
          clear $slot2;
          $slver# = savever#;
          $saemp#U = *on;
          $saemp# = e$emp#;

          $slwhseu = *on;
          $slwhse  = pwhse;
          $slwhdpu = *on;
          $slwhdp  = #fromslwhdp;
          $sldispu = *on;
          $sldisp  = #fromsldisp;

          $dricommand = '*SLOT';
          $drisubcmd  = '%ZEROVFY';
          $drisys2upd = 'D';
          $driprogram = #pgm;
          $dridata = $slot;
          $dridata2 = $slot2;

          // Call DRI program.
          driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                 $drireturn: $drimessage: $dridata: $dridata2);

          $slot = $dridata;
          $slot2 = $dridata2;
        endif;

        // Start idle tran.

        exsr zztrnidle;
        exsr zzlog;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  zzwrkinz   Delete existing work records for user.
     *             Don't try to put anything back.
     *----------------------------------------------------------------

     C     zzwrkinz      begsr
     *
      /free
        setll (wktype: e$emp#) workusr3;
        dow forever = forever;
          reade (wktype: e$emp#) workusr3;
          if %eof(workUsr3);
            leave;
          endif;
          delete wuRec;
        enddo;
      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  zzwrkadd   Add record to work file for user.
     *----------------------------------------------------------------

     C     zzwrkadd      begsr


     C                   exsr      zzgetcurrstamp

     C                   clear                   wuRec
      *
     C                   eval      wutrn# = curtrn#
     C                   eval      wuwhse = pwhse
     C                   eval      wuscannbr = #fromToLcns
     C                   eval      wuscantype = 'P'
     C                   eval      wupulwhdp = #fromslwhdp
     C                   eval      wupulbase = #frombasesldsp
     C                   eval      wupuldisp = #fromsldisp
     C                   eval      wupulitem = #fromslitem
     C                   eval      wupullcns = #fromToLcns
     C                   eval      wupulolcns = #fromOLcns
     C                   eval      wupulvfy   = $saFrmEmpty

     C                   eval      wuUsrWhdp = $slwhdp
     C                   eval      wuUsrDisp = $sldisp
     C                   eval      wuNewItem = ptitem

     C                   eval      wuRemQty1 = pqty1
     C                   eval      wuRemQty2 = pqty2
     C                   eval      wuRemQty3 = pqty3

     C                   eval      wuUsrLcns = $tinlic#
     C                   eval      wuRecType = wkType
     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = e$emp#
     C                   eval      wuaddeusr = puser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr
     c*
     C                   write     wuRec

     C                   endsr

600eA*----------------------------------------------------------------
600eA*  zzwrkdel   Delete work file record
600eA*----------------------------------------------------------------
600eA
600eAC     zzwrkdel      begsr
      /free
          chain (wktype: e$emp#:pwhse:pwhdp:pfdisp) workusr3;
          if %found(workusr3);
600fA       delete wuRec;
          endif;
      /end-free

     C                   endsr
600eA
CBIeA*----------------------------------------------------------------
CBIeA*  ZZCHKZROVFY   See if we should ask user to zero verify slot.
CBIeA*----------------------------------------------------------------
CBIeA
CBIeAC     zzchkzrovfy   begsr

     *  See if zero verify flag should be set.

     C                   eval      verifyzero = *off
     C                   dow       forever = forever

     *      Ask the user to zero verify slot if ...

     *      ... the slot only has 1 pallet position.

700jD *                  if        #fromslpos > 1
700jD *                  leave
700jD *                  endif

     *      ... the slot doesn't have a virtual slot associated with it.

     C                   if        #fromslvirt = 'Y'
     C                   leave
     C                   endif

     *      ... %TFR2USR, which is called just before calling this
     *          routine, says the slot is empty.

     C                   if        wuPulVfy <> 'Y'
     C                   leave
     C                   endif

     *      ... slot is either not a virtual slot or
     *          it is the only virtual and the base slot is empty.

     C                   if        #fromslrsrv = 'V'

     *            Get base slot info.

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #frombasesldsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
      /free
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
      /end-free

     *            Status must be 'Z' or 'V'

     C                   if        $slstat <> 'V' and $slstat <> 'Z'
     C                   leave
     C                   endif

     *            See if any other virtuals are associated with slot.

     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp = $sldisp
     C                   eval      $sldisp = ' '
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTVSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   dow       forever = forever
      /free
        $driprogram = #pgm;
        $dridata = $slot;
        $dridata2 = $slot2;

        // Call DRI program.
        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2);

        $slot = $dridata;
        $slot2 = $dridata2;
      /end-free
     C                   if        error or $drireturn = 'EOF'
     C                   eval      error = *off
     C                   leave
     C                   endif
     C                   if        $sldisp = #fromsldisp
     C                   iter
     C                   endif
     C                   leave
     C                   enddo
     C                   if        $drireturn <> 'EOF'
     C                   leave
     C                   endif

     C                   endif

     *      Whew! We have finally determined that we can have the user
     *         verify if the slot is physically empty.

     C                   eval      verifyzero = *on

     C                   leave
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *  ZZTRNSTART  Start a transaction
     *----------------------------------------------------------------

     C     zztrnstart    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'TFRMOV'      @ptask            6
     C                   parm      pwhse         @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'T'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      puser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNIDLE   Start and IDLE transaction.
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnidle     begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      pwhse         @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnupdate   begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      puser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNCLOSE  Close a transaction
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnclose    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      puser         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCRTL   Create Label records.
     *
     C     zzcrtl        begsr
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = pwhse
     C                   eval      lbwhdp = pwhdp
600bAC                   eval      exwgfm = *zeros
     *
     *  FROM Slot.
     *
500cMC                   eval      lbaisl = #fromslaisl
500cMC                   eval      lbloc = #fromslloc
500cMC                   eval      lbrlvl = #fromslrlvl
500cMC                   eval      lbhand = #fromslhand
500cMC                   eval      lbpseq = #fromslpseq
500cMC                   eval      lbstyp = #fromslstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
500cMC                   eval      fmwhdp = #fromslwhdp
500cMC                   eval      fmdisp = #fromsldisp
500cMC                   eval      fmitem = #fromslitem
     *
     * FROM ITEM
     *
600bAC                   eval      fmcwgt = #fromitcwgt
MRTaAc                   if        client = merit
MRTaAC                   eval      fmcwgt = 'Y'
MRTaAc                   endif
500iAC                   eval      fmcube = #fromitcube
500iAC                   eval      fmswgt = #fromitswgt
500iAC                   eval      fmumq2 = #fromitumq2
500iAC                   eval      fmumq3 = #fromitumq3
500cMC                   if        #fromslitem <> ptitem
500cMC                   if        #fromitumq2 <> 0
416e C                   endif
416c C                   endif
415cA*
415cA*    Create label records for case transfer.
415cA*
415cAC                   select
415cAC                   when      pqty1  <> 0
500cMC                   eval      lbucod = #fromitum1
     C                   eval      lbqalc = pqty1
     C                   eval      lbqpck = pqty1
500cMC                   eval      lbucub = #fromitcube
     C     lbucub        mult      pqty1         lbcube
500cMC                   eval      lbuwgt = #fromitswgt
     C     lbuwgt        mult      pqty1         lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
     *
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
600bAC                   eval      tocwgt = #newfromitcwgt
     *
500cMC                   eval      lbwhs2 = pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
     *
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
     C                   eval      lbrte = *blanks
     C                   eval      toitem = ptitem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = 'N'
500cMC                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbitem = fmitem
     C                   eval      lbdisp = fmdisp
     C                   eval      lbdsp2 = todisp
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = '1'
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbitem = toitem
416bAC                   eval      lbwhdp = towhdp
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
500cMC                   eval      lbucod = #newfromitum1
416j C                   z-add     toqty1        lbqalc
416j C                   z-add     toqty1        lbqpck
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = '1'
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
500cMC                   eval      svtrn1 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
415cA*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 1 qty.
415cA*
415cAC                   select
415cAC                   when      pqty2  <> 0
500cMC                   eval      lbucod = #fromitum2
415cAC                   eval      lbqalc = pqty2
415cAC                   eval      lbqpck = pqty2
500cMC                   if        #fromitumq2 > 0
500cMC     #fromitcube   div(h)    #fromitumq2   lbucub
500cMC     #fromitswgt   div(h)    #fromitumq2   lbuwgt
415cAC                   else
500cMC                   eval      lbuwgt = #fromitswgt
500cMC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      pqty2         lbcube
415cAC     lbuwgt        mult      pqty2         lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650cAC                   eval      tocwgt = #newfromitcwgt
650cA*
500cMC                   eval      lbwhs2 = pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
415cA*
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   eval      toitem = ptitem
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = *on
415cAC                   if        newtrn = '*YES'
500cAC                   exsr      zztrnclose
500cAC                   exsr      zztrnstart
500cAC                   endif
415cA*
500cMC                   eval      lbtrn# = $ptrn#
500 AC                   eval      svtrn2 = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
600aAC                   eval      lbwhdp = fmwhdp
415cAC                   eval      lbitem = fmitem
415cAC                   eval      lbdisp = fmdisp
415cAC                   eval      lbdsp2 = todisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
600aAC                   eval      lbwhdp = towhdp
415cAC                   eval      lbitem = toitem
415cAC                   eval      lbdisp = todisp
415cAC                   eval      lbdsp2 = fmdisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500cMC                   eval      svtrn2 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
500cA*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 2 qty.
415cA*
415cAC                   select
415cAC                   when      pqty3  <> 0
500cMC                   eval      lbucod = #fromitum3
415cAC                   eval      lbqalc = pqty3
415cAC                   eval      lbqpck = pqty3
500cMC                   if        #fromitumq3 > 0
500cMC     #fromitcube   div(h)    #fromitumq3   lbucub
500cMC     #fromitswgt   div(h)    #fromitumq3   lbuwgt
415cAC                   else
500cMC                   eval      lbuwgt = #fromitswgt
500cMC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      pqty3         lbcube
415cAC     lbuwgt        mult      pqty3         lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650cAC                   eval      tocwgt = #newfromitcwgt
650cA*
500cMC                   eval      lbwhs2 = pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
415cA*
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   eval      toitem = ptitem
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = '2'
415cAC                   if        newtrn = '*YES'
500cAC                   exsr      zztrnclose
500cAC                   exsr      zztrnstart
500cAC                   endif
415cA*
500cMC                   eval      lbtrn# = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   eval      lbitem = fmitem
415cAC                   eval      lbdisp = fmdisp
415cAC                   eval      lbdsp2 = todisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   eval      lbitem = toitem
415cAC                   eval      lbdisp = todisp
415cAC                   eval      lbdsp2 = fmdisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500cMC                   eval      svtrn3 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
500cA*
415cAC                   endsl
500cA*
500cA*  Close current transaction.
500cA*
500cAC                   exsr      zztrnclose
     *
414 AC                   if        fmitem <> toitem
     *  Create adjustment record for "From" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = pwhse
415 AC                   eval      iaitem = fmitem
650aDC**                 eval      iadate = today
650aDC**                 time                    iatime
650aMC                   eval      iadate = tfr2usrDate
650aMC                   eval      iatime = tfr2usrTime
600eMC                   eval      iaby = puser
415 AC                   eval      iawhdp = fmwhdp
415 AC                   eval      iadisp = fmdisp
600bA*    Catchweight item, update extended weight transferred.
600bAC                   if        fmcwgt = 'Y'
MRTbAc                             or client = merit
MRTbAc                             and pwgt  <> 0
530aAC                   if        pwgt  = 0
600bAC                   eval      iacwta = -(exwgfm)
530aAC                   else
530aAC                   eval      iacwta = -(pwgt)
530aAC                   endif
600bAC                   else
415 AC                   eval      iacwta = 0
600bAC                   endif
415 AC                   eval      iaqty1 = -(pqty1)
415 AC                   eval      iaqty2 = -(pqty2)
415 AC                   eval      iaqty3 = -(pqty3)
416cMC                   eval      iacode = padjcd
415 AC     'To'          cat       toitem:1      iamemo

EFCaA*    Add slot status to end of memo for some clients.
EFCaA
EFCaAC                   if        client = eastland
EFCaAC                   eval      %subst(iamemo:28:3) = '-' + #toslstat
EFCaAC                   endif

415 AC                   write     iarec
     *  Create adjustment record for "To" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = pwhse
415 AC                   eval      iaitem = toitem
415 AC                   eval      iadate = today
415 AC                   time                    iatime
600eMC                   eval      iaby = puser
415 AC                   eval      iawhdp = towhdp
415 AC                   eval      iadisp = todisp
600bA*    Catchweight item, update extended weight transferred.
600bAC                   if        tocwgt = 'Y'
MRTbAc                             or client = merit
MRTbAc                             and pwgt  <> 0
530aAC                   if        pwgt  = 0
600bAC                   eval      iacwta = exwgfm
530aAC                   else
530aAC                   eval      iacwta = pwgt
530aAC                   endif
600bAC                   else
415 AC                   eval      iacwta = 0
600bAC                   endif
416jAC                   z-add     toqty1        iaqty1
415 AC                   eval      iaqty2 = pqty2
415 AC                   eval      iaqty3 = pqty3
416cMC                   eval      iacode = padjcd
415 AC     'From'        cat       fmitem:1      iamemo

EFCaA*    Add slot status to end of memo for some clients.
EFCaA
EFCaAC                   if        client = eastland
EFCaAC                   eval      %subst(iamemo:28:3) = '-' + #fromslstat
EFCaAC                   endif

415 AC                   write     iarec
     *
414 AC                   endif
     *
700aA /free
700aA   if fmitem <> toitem;
700aA     // write change item record
700aA     icwhse = pwhse;
700aA     icfitm = fmitem;
700aA     ictitm = toitem;
700aA     chain (icwhse: icfitm: ictitm) itemchg;
700aA     if %found(itemchg);
700aA     else;
700aA       write icrec;
700aA     endif;
700aA   endif;
700aA /end-free
     C     endcrl        endsr
CBIbAC*----------------------------------------------------------------
CBIbAC*
CBIbAC*  ZZLOG  Log the info of the item location change being done.
CBIbAC*
CBIbAC     zzlog         begsr
CBIbAC*
CBIbAC                   clear                   locrec
CBIbAC                   z-add     $slwhse       locwhs
CBIbAC                   move      $slwhdp       locdpt
CBIbDC                   move      #fromslitem   locitm
CBIbMC                   move      pfdisp        locfrm
CBIbAC                   move      #tosldisp     locto
CBIbAC*    Get todays date.
CBIbAC                   move      '*CURCMD '    $cvcmd
     C                   call      @cvtdt
     C                   parm                    $cvtdt
CBIbAC                   z-add     $cvd8o        locdte
CBIbAC                   time                    loctim
CBIbAC                   move      puser         locusr
CBIbAC                   z-add     e$emp#        locemp
CBIbAC*
CBIbAC                   write     locrec
CBIbAC*
      /free
        chain ($slwhse:$slitem) tihighsnd;
CBIdA   snwhse = $slwhse;
CBIdM   snitem = #fromslitem;
CBIdA   sntie  = *zeros;
CBIdA   snhigh = *zeros;
CBIdA   snsdef = *blanks;
CBIdA   snsend = 'N';
CBIdA   if %found(tihighsnd);
CBIdA     update sndrec;
CBIdA   else;
CBIdA     write sndrec;
CBIdA   endif;
      /end-free
CBIbAC*
CBIbAC     endlog        endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'MODE';
             pSubCmd = %xlate(xlower: xupper: parmValue);

           when parmName = 'CALCULA005';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA008';
             pfitem = %trim(parmValue);

           when parmName = 'CALCULA006';
             pwhdp = %trim(parmValue);

           when parmName = 'GFA12_01';
             ptdisp = %trim(parmValue);

           when parmName = 'CALCULA007';
             pfdisp = %trim(parmValue);

           when parmName = 'GFA15_01';
             ptitem = %trim(parmValue);

           when parmName = 'GFN050_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             pqty1 =  %dec(parmValue: 5: 0);

           when parmName = 'GFN030_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             pqty2 =  %dec(parmValue: 3: 0);

           when parmName = 'GFN030_02';
             if parmValue = '';
               parmValue = '0';
             endif;
             pqty3 =  %dec(parmValue: 3: 0);

           when parmName = 'GFA02_01';
             padjcd = %trim(parmValue);

           when parmName = 'GFN092_01';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwgt  =  %dec(parmValue: 9: 2);

           when parmName = 'GFA01_01';
             pstatovr = %trim(parmValue);

         endsl;

       on-error;

         pMessage = 'Error extracting parameter '
                  + %char(parmCount) + ' '
                  + parmName + ' '
                  + '(' + parmValue + ')'
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';

       endmon;

       return;

      /end-free

     p                 e
     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pMessage = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 2

         parmStr = %trim(pParmStr2);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

         // Extract parms for string 3

         parmStr = %trim(pParmStr3);
         ExtractParmStr(parmStr);

         if pMessage <> '';
           return;
         endif;

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pMessage = 'Error: Invalid parameter group '
                    + %char(parmCount) + ' '
                    + '(' + parmGroup + ')'
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if pMessage <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

     p                 e
