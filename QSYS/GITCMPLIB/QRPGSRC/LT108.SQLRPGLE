      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  LT108     RF Priority Replenishments - Create transaction
     *  11 February 2000
     *  Max Blacknik
     *
     *  Note: This program is same as OR535 except for the following:
     *         -Using file PRPLFIL instead of RPLFILE.
     *         -No labels are printed from this program.
     *         -Entered date/expiration dates not updated between
     *          from slot / to slot.
     *
     *  Revisions
     *
414aA*    07/11/00  MLB  4.14a
     *      - Revised program to no longer delete records from
     *        PRPLFIL.  This function will now be done in LT105.
414bA*    07/11/00  MLB  4.14b
     *      - Revised program to treat pick slot as empty for users
     *        configured to use Locator System.
414cA*    09/21/00  MLB  4.14c
     *      - Revised program to bypass transactions where the To slot
     *        item number no longer matches the replenishment item nbr.
     *        Add check to From Slot to make sure slot still active.
     *
415 A*    04/05/01  MLB  4.15
     *      - Revised program to remove check of PRFREE flag since
     *        this function is not used for Priority Replenishments.
415aA*    06/12/01  MLB  4.15a
     *      - Revised program to compare item number in Priority Re-
     *        plenishemnts to the item number found in the From Slot.
     *
416fA*    02/21/02  DAS  4.16f
     *      - Revised to work with DRISLOT interface.
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZD2S, ZZZCOP, ZZZISF, ZZZFS2, ZZZFS3
     *
416aA*    02/22/02  DAS  4.16a
     *      - Added to 415a change to handle Bkdn repl correctly.
     *
416bA*    06/11/02  DAS  4.16b
     *      - Changed A$LIC# from 7.0 to 15.
     *
417 A*    07/22/03  MLB  4.17
     *      - Enh: Recompiled. New fields added to PRPLFIL.
417aA*    12/09/03  MLB  4.17a
     *      - Enh: Pass in new parm. $PRPLT - Replenishment type.
     *        If replenishment type E or P and $PTRN# is zero then
     *        create new transaction, otherwise use tran# passed in
     *        to program to assign to replenishment types E and P.
     *
500 A*    10/19/04  DAS  5.00
     *      - Converted to ILE.
     *      - Changed Pusback repl to FlowRack, Eaches to Breakdown.
     *
500aA*    04/21/05  DAS  5.00a
     *      - Revised to have user work only with full cases when doing a
     *        Breakdown replenishment.
     *
510aA*    03/07/07  JCJ  5.10a
     *      - Enh: Add new Slot Status Code of 'RP' for Repacks.
     *
510bA*    12/21/07  LMC  5.10b
     *      - Enh: Added update for PIRTRAN via ADJTRAN2 for flow
     *        replenishments to accumlate the pieces pulled
     *
600 A*    07/02/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - LIC version used as base, then 500/510 changes added.
     *
600aA*    07/02/08  DAS  6.00a
     *      - This mod is merged from PIRENH510/LT108
     *        10/28/04  DAS  5.00a
     *      - If calling program ($pprg) is PR321 (Print Breakdown
     *        priority replenishments), then only create Label record.
     *        Do not update any other files. LBTYPE will be set to 'X'
     *        and LBSTAT set to 'C' so that it is not picked up in the.
     *        Item/Slot Activity report.                              .
     *
600bA*    07/02/08  DAS  6.00b
     *      - This mod is merged from PIRENH510/LT108
     *        10/29/04  DAS  5.00b
     *      - Revised to try and fill Breakdown item slot instead of just
     *        pulling 1 full case.
     *
600cA*    07/02/08  DAS  6.00c
     *      - This mod is merged from PIRENH510/LT108
     *        10/31/04  DAS  5.00c
     *      - Removed ti/hi requirement.
     *      - For a Breakdown item, if the ti/hi does not exist then
     *        use pick quantity from prplfil record.
     *      - For other items, if the ti/hi does not exist, then a full
     *        overflow pallet will be picked.
     *
600dA*    07/02/08  DAS  6.00d
     *      - This mod is merged from PIRENH510/LT108
     *        06/21/05  MLB  5.00d
     *      - Enh: Revised program to force a Priority Replenishment
     *        even if slot has qty available.
     *
600eA*    01/29/08  DAS  6.00e
     *      - Revised to work with USR slots.
     *      - Deleted most old unused code for readability.
     *
600fA*    05/14/09  DAS  6.00f
     *      - Added call to GETUSER.
     *      - Revised to send emp# to DRISLOT.
     *
600gA*    05/14/09  DAS  6.00g
     *      - Revised tfr2usr call to not send To/Frm LP's.
     *
600hA*    05/14/09  DAS  6.00h
     *      - Added DRISLOT parms to parameters
     *
600iA*    06/10/09  DAS  6.00i
     *      - Revised to use %GETCHKVX instead of %GETCHKV. %GETCHKVX
     *        will not count the slot that was sent.
     *
530 A*    03/31/10  JCJ  5.30
     *      - Revised to populate replenish quantity for replenishment
     *        type of 'R' with correct quantity.
     *
640aA*    04/13/11  RH   6.40a
     *      - Fix: Set brk repl label item to broken item #, not case
     *        item #.
     *
650aA*    04/10/13  KDE  6.50
     *      - Revised to no longer delete priorirty repak replenishmet
     *        when slot quantity is zero.  This allows for system to
     *        create full Work Oorder Replenishment request when stock
     *        is not in pick slot.  Users will be trained to do
     *        Specific Slot replenishment before processing replenmnt
650bA*    09/12/13  KDE  6.50b
     *      - Ignore Tie/High calculation for RPK slots
650cA*    06/11/14  KDE  6.50c
     *      - Create Production Replenishment using Repack Code for
     *        testing.  Will need to change once known to work
650dA*    03/25/15  KDE  6.50d
     *      - Code changes to allow breakdown 1 replenishment for
     *        Production.
700aA*    04/27/16  DLS  7.00a
     *      - Added FROM slot status 'PR' to IF statement (Production Slots)
710aA*    06/23/17  RH/LMC  7.10a
     *      - Fix: If Tie and Hi values are both 0, do not use Tie/hi Slots)
     *        Do not set FOUNDTIEHI = ON                              Slots)
710bA*    07/24/17  KDE  710b
     *     - Setup separate task code for Production Replenishments
720 A*    02/21/18  KDE  720
     *     - Setup Store Replenishment Type.  Should function as Repack
     *       and Production
     *     - Auto generate virtual dock slot to replen to for these type
     *       replenishments
730 A*    08/26/19  KDE  7.30
     *     - Change Production Replen type from 'D' to 'O'
740 A*    05/07/20  KDE  7.40
     *     - Change status from "A" to "DP" for Drop Picks
740aA*    05/13/20  KDE  7.40a
     *     - Use new file DRPRNGE to determine proper Drop Pick slot range
750aA*    08/15/21  KDE  7.50a
     *     - Create Drop Pick slot here.  The reason we do it here it to
     *       know if we run out of Drop Pick slots.  In this case we will
     *       setup the replenishment to Deleted and record an error that
     *       no available drop pick slots exist
750bA*    11/15/21  KDE  7.50b
     *     - Update getddslot call
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Line Distributors
     *
CLD A*    02/04/20  MLB  CLD
     *      - Revised program to create transaction for breaker item
     *        even if qty to replenish is less than 1 case and calling
     *        pgm is PR321.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *
414aD*PRPLFIL1UF  E           K        DISK
414aMFprplfil1  if   e           k disk
     FLabel     o  a e           k disk
     Fbatctl    o    e           k disk

640aA*----------------------------------------------------------------
640aA*  Customer id
640aA*
640aA /Copy qcopysrc,id#citylin
500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
500 A /COPY *libl/qcopysrc,C#SLOT
500 A /COPY *libl/qcopysrc,C#SLOTDEF
500 AD saveVer#        s                   like($slver#)
500 AD save$slot       s                   like($slot)

600bAD frm$Slot        ds                  likeds($slot)
600bAD frm$Slot2       ds                  likeds($slot2)

     *----------------------------------------------------------------
     *
     * Data structure
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *                                      19  210$PWHSE
     D  $pwhs                 19     21  0
     D  $pwhdp                22     26
     D  $pfail                27     29
     D  $ptail                30     32
     D  $pseq#                33     37  0
     D  $ptrn#                38     44  0
414bAD  $pfeat                45     45
417aAD  $prplt                46     46
417aAD  $pcrtt                47     47
417aAD  $pbat#                48     51p 0
417aAD  $plbl#                52     55p 0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
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
     *  Error message parameter
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
500 AD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

730 A*----------------------------------------------------------------
730 A*  Standard SQL variables and constants
730 A*----------------------------------------------------------------
730 A
730 A /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *

500 AD #fromitwhse     s                   like($itwhse)
500 AD #fromititem     s                   like($ititem)
500 AD #fromittype     s                   like($ittype)
500 AD #fromitdesc     s                   like($itdesc)
500 AD #fromitpdsc     s                   like($itpdsc)
500 AD #fromithead     s             70
500 AD #fromitwhdp     s                   like($itwhdp)
500 AD #fromitstyp     s                   like($itstyp)
500 AD #fromitdesg     s                   like($itdesg)
500 AD #fromitum1      s                   like($itum1)
500 AD #fromitflg1     s                   like($itflg1)
500 AD #fromitum2      s                   like($itum2)
500 AD #fromitumq2     s                   like($itumq2)
500 AD #fromitflg2     s                   like($itflg2)
500 AD #fromitum3      s                   like($itum3)
500 AD #fromitumq3     s                   like($itumq3)
500 AD #fromitnrpk     s                   like($imnrpk)
500 AD #fromitflgd     s                   like($itflgd)
500 AD #fromitcube     s                   like($itcube)
500 AD #fromitswgt     s                   like($itswgt)
500 AD #fromitcwgt     s                   like($itcwgt)
500 AD #fromitmitem    s                   like($itmitem)
500 AD #fromitsdef     s                   like($idsdef)
500 AD #fromittie      s                   like($idtie)
500 AD #fromithigh     s                   like($idhigh)
600eAD #fromimltrk     s                   like($imltrk)

500 AD #fromssbflag    s               n
500 AD #fromssbititem  s                   like($ititem)
500 AD #fromssbittype  s                   like($ittype)
500 AD #fromssbitdesc  s                   like($itdesc)
500 AD #fromssbitpdsc  s                   like($itpdsc)
500 AD #fromssbitwhdp  s                   like($itwhdp)
500 AD #fromssbitstyp  s                   like($itstyp)
500 AD #fromssbitdesg  s                   like($itdesg)
500 AD #fromssbitum1   s                   like($itum1)
500 AD #fromssbitum2   s                   like($itum2)
500 AD #fromssbitumq2  s                   like($itumq2)
500 AD #fromssbitum3   s                   like($itum3)
500 AD #fromssbitumq3  s                   like($itumq3)

500 AD #fromslwhse     s                   like($slwhse)
500 AD #fromslwhdp     s                   like($slwhdp)
500 AD #fromslstyp     s                   like($slstyp)
500 AD #fromsldisp     s                   like($sldisp)
500 AD #fromslaisl     s                   like($slaisl)
500 AD #fromslloc      s                   like($slloc)
500 AD #fromslpseq     s                   like($slpseq)
500 AD #fromslrlvl     s                   like($slrlvl)
500 AD #fromslhand     s                   like($slhand)
500 AD #fromslstat     s                   like($slstat)
500 AD #fromslrsrv     s                   like($slrsrv)
500 AD #fromslentd     s                   like($slentd)
500 AD #fromslexpd     s                   like($slexpd)
500 AD #fromslslfd     s                   like($slslfd)
500 AD #fromslactv     s                   like($slactv)
500 AD #fromslbld      s                   like($slbld)
500 AD #fromslpick     s                   like($slpick)
500 AD #fromslitem     s                   like($slitem)
500 AD #fromslsdef     s                   like($slsdef)
500 AD #fromslpos      s                   like($sdpos)
500 AD #fromslvirt     s                   like($sfvirt)
500 AD #fromslstk1     s                   like($slstk1)
500 AD #fromslstk2     s                   like($slstk2)
500 AD #fromslstk3     s                   like($slstk2)
500 AD #fromslalc1     s                   like($slalc1)
500 AD #fromslalc2     s                   like($slalc2)
500 AD #fromslalc3     s                   like($slalc3)
500 AD #fromsltfr1     s                   like($sltfr1)
500 AD #fromsltfr2     s                   like($sltfr2)
500 AD #fromsltfr3     s                   like($sltfr3)
500 AD #fromslpck1     s                   like($slpck1)
500 AD #fromslpck2     s                   like($slpck2)
500 AD #fromslpck3     s                   like($slpck3)
500 AD #fromslrcv1     s                   like($slrcv1)
500 AD #fromslrcv2     s                   like($slrcv2)
500 AD #fromslrcv3     s                   like($slrcv3)
500 AD #fromslphy1     s                   like($slphy1)
500 AD #fromslphy2     s                   like($slphy2)
500 AD #fromslphy3     s                   like($slphy3)
500 AD #fromslavl1     s                   like($slavl1)
500 AD #fromslavl2     s                   like($slavl2)
500 AD #fromslavl3     s                   like($slavl3)
500 AD #frombasesldsp  s                   like($sldisp)
600eAD #fromToLcns     s                   like($saToLcns)
600eAD #fromToPos      s                   like($saToPos)
600eAD #fromOLcns      s                   like($saOLcns)

500 AD #ovrfslwhse     s                   like($slwhse)
500 AD #ovrfslwhdp     s                   like($slwhdp)
500 AD #ovrfslstyp     s                   like($slstyp)
500 AD #ovrfsldisp     s                   like($sldisp)
500 AD #ovrfslaisl     s                   like($slaisl)
500 AD #ovrfslloc      s                   like($slloc)
500 AD #ovrfslpseq     s                   like($slpseq)
500 AD #ovrfslrlvl     s                   like($slrlvl)
500 AD #ovrfslhand     s                   like($slhand)
500 AD #ovrfslstat     s                   like($slstat)
500 AD #ovrfslrsrv     s                   like($slrsrv)
500 AD #ovrfslentd     s                   like($slentd)
500 AD #ovrfslexpd     s                   like($slexpd)
500 AD #ovrfslslfd     s                   like($slslfd)
500 AD #ovrfslactv     s                   like($slactv)
500 AD #ovrfslbld      s                   like($slbld)
500 AD #ovrfslpick     s                   like($slpick)
500 AD #ovrfslitem     s                   like($slitem)
500 AD #ovrfslsdef     s                   like($slsdef)
500 AD #ovrfslpos      s                   like($sdpos)
500 AD #ovrfslvirt     s                   like($sfvirt)
500 AD #ovrfslstk1     s                   like($slstk1)
500 AD #ovrfslstk2     s                   like($slstk2)
500 AD #ovrfslstk3     s                   like($slstk2)
500 AD #ovrfslalc1     s                   like($slalc1)
500 AD #ovrfslalc2     s                   like($slalc2)
500 AD #ovrfslalc3     s                   like($slalc3)
500 AD #ovrfsltfr1     s                   like($sltfr1)
500 AD #ovrfsltfr2     s                   like($sltfr2)
500 AD #ovrfsltfr3     s                   like($sltfr3)
500 AD #ovrfslpck1     s                   like($slpck1)
500 AD #ovrfslpck2     s                   like($slpck2)
500 AD #ovrfslpck3     s                   like($slpck3)
500 AD #ovrfslrcv1     s                   like($slrcv1)
500 AD #ovrfslrcv2     s                   like($slrcv2)
500 AD #ovrfslrcv3     s                   like($slrcv3)
500 AD #ovrfslphy1     s                   like($slphy1)
500 AD #ovrfslphy2     s                   like($slphy2)
500 AD #ovrfslphy3     s                   like($slphy3)
500 AD #ovrfslavl1     s                   like($slavl1)
500 AD #ovrfslavl2     s                   like($slavl2)
500 AD #ovrfslavl3     s                   like($slavl3)
500 AD #ovrfbasesldsp  s                   like($sldisp)
600eAD #ovrToLcns      s                   like($saToLcns)
600eAD #ovrToPos       s                   like($saToPos)
600eAD #ovrOLcns       s                   like($saOLcns)

500 AD #pickitwhse     s                   like($itwhse)
500 AD #pickititem     s                   like($ititem)
500 AD #pickittype     s                   like($ittype)
500 AD #pickitdesc     s                   like($itdesc)
500 AD #pickitpdsc     s                   like($itpdsc)
500 AD #pickithead     s             70
500 AD #pickitwhdp     s                   like($itwhdp)
500 AD #pickitstyp     s                   like($itstyp)
500 AD #pickitdesg     s                   like($itdesg)
500 AD #pickitum1      s                   like($itum1)
500 AD #pickitflg1     s                   like($itflg1)
500 AD #pickitum2      s                   like($itum2)
500 AD #pickitumq2     s                   like($itumq2)
500 AD #pickitflg2     s                   like($itflg2)
500 AD #pickitum3      s                   like($itum3)
500 AD #pickitumq3     s                   like($itumq3)
500 AD #pickitnrpk     s                   like($imnrpk)
500 AD #pickitflgd     s                   like($itflgd)
500 AD #pickitcube     s                   like($itcube)
500 AD #pickitswgt     s                   like($itswgt)
500 AD #pickitcwgt     s                   like($itcwgt)
500 AD #pickitmitem    s                   like($itmitem)
500 AD #pickitsdef     s                   like($idsdef)
500 AD #pickittie      s                   like($idtie)
500 AD #pickithigh     s                   like($idhigh)
600eAD #pickimltrk     s                   like($imltrk)

500 AD #pickparititem  s                   like($ititem)
500 AD #pickparittype  s                   like($ittype)
500 AD #pickparitdesc  s                   like($itdesc)
500 AD #pickparitpdsc  s                   like($itpdsc)
500 AD #pickparitwhdp  s                   like($itwhdp)
500 AD #pickparitstyp  s                   like($itstyp)
500 AD #pickparitdesg  s                   like($itdesg)
500 AD #pickparitum1   s                   like($itum1)
500 AD #pickparitum2   s                   like($itum2)
500 AD #pickparitumq2  s                   like($itumq2)
500 AD #pickparitum3   s                   like($itum3)
500 AD #pickparitumq3  s                   like($itumq3)
600aAD #pickparimltrk  s                   like($imltrk)

500 AD #pickslwhse     s                   like($slwhse)
500 AD #pickslwhdp     s                   like($slwhdp)
500 AD #pickslstyp     s                   like($slstyp)
500 AD #picksldisp     s                   like($sldisp)
500 AD #pickslaisl     s                   like($slaisl)
500 AD #pickslloc      s                   like($slloc)
500 AD #pickslpseq     s                   like($slpseq)
500 AD #pickslrlvl     s                   like($slrlvl)
500 AD #pickslhand     s                   like($slhand)
500 AD #pickslstat     s                   like($slstat)
500 AD #pickslrsrv     s                   like($slrsrv)
500 AD #pickslentd     s                   like($slentd)
500 AD #pickslexpd     s                   like($slexpd)
500 AD #pickslslfd     s                   like($slslfd)
500 AD #pickslactv     s                   like($slactv)
500 AD #pickslbld      s                   like($slbld)
500 AD #pickslpick     s                   like($slpick)
500 AD #pickslitem     s                   like($slitem)
500 AD #pickslsdef     s                   like($slsdef)
500 AD #pickslpos      s                   like($sdpos)
500 AD #pickslvirt     s                   like($sfvirt)
500 AD #pickslstk1     s                   like($slstk1)
500 AD #pickslstk2     s                   like($slstk2)
500 AD #pickslstk3     s                   like($slstk2)
500 AD #pickslalc1     s                   like($slalc1)
500 AD #pickslalc2     s                   like($slalc2)
500 AD #pickslalc3     s                   like($slalc3)
500 AD #picksltfr1     s                   like($sltfr1)
500 AD #picksltfr2     s                   like($sltfr2)
500 AD #picksltfr3     s                   like($sltfr3)
500 AD #pickslpck1     s                   like($slpck1)
500 AD #pickslpck2     s                   like($slpck2)
500 AD #pickslpck3     s                   like($slpck3)
500 AD #pickslrcv1     s                   like($slrcv1)
500 AD #pickslrcv2     s                   like($slrcv2)
500 AD #pickslrcv3     s                   like($slrcv3)
500 AD #pickslphy1     s                   like($slphy1)
500 AD #pickslphy2     s                   like($slphy2)
500 AD #pickslphy3     s                   like($slphy3)
500 AD #pickslavl1     s                   like($slavl1)
500 AD #pickslavl2     s                   like($slavl2)
500 AD #pickslavl3     s                   like($slavl3)
500 AD #pickbasesldsp  s                   like($sldisp)
600eAD #pickToLcns     s                   like($saToLcns)
600eAD #pickToPos      s                   like($saToPos)
600eAD #pickOLcns      s                   like($saOLcns)

     D $pwhse          s              3  0
500 AD chk4err         s               n
     D ck4err          s              1
     D curtrn#         s              7  0
730 AD ddslot          s               n
500 MD drierr          s               n
     D drizm           s              1
     D dspqty          s              5  0
     D dstqty          s              7  0
600bAD emptyfullq      s              7  0
     D emptyq          s              7  0
500 MD error           s               n
500 DD*fmhand          s                   like(slhand)
500 DD*fmloc           s                   like(slloc)
500 DD*fmpseq          s                   like(slpseq)
500 DD*fmrlvl          s                   like(slrlvl)
600cAD foundtihi       s               n
     D i               s              3  0
     D n               s              5  0
     D pallet          s              5  0
     D rplqty          s                   like($itumq2)
500 DD*savhgh          s                   like(idhigh)
500 DD*savtie          s                   like(idtie)
     D today           s              8  0
500 DD*tohand          s                   like(slhand)
500 DD*toloc           s                   like(slloc)
     D topick          s              5  0
500 DD*torlvl          s                   like(slrlvl)
500 DD*tostyp          s                   like(slstyp)
     D wrkqty          s                   like(lbqpck)
500 AD zmsflag         s               n

600eA*----------------------------------------------------------------
600eA*  LT210 parameters
600eA*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse number.
     *      $PWHDP  Department
     *      $PSEQ#  Sequence number
414bA*      $PFEAT  FS-WMS installed feature
414bA*        1 =     - Locator System.
414bA*        2 =     - Full System.
500 M*      $PRPLT  Replenishment type: ' '=Regular, B=Breakdown,F=FlowRack
417aA*      $PCRTT  Create new transaction, Y=Yes, N=No.
417aA*      $PBAT#  Batch number
     *
     *    Returned Parameters
     *      $PTRN#  Transaction number of replenishment created.
417aA*      $PBAT#  Batch number assigned to transaction.
417aA*      $PLBL#  Label number
     *      $PRTN   Return code.
     *        *OK     - Replenishment created.
     *        *NONE   - Replenishment not created.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
600hAC                   parm                    frm$slot
600hAC                   parm                    frm$slot2
     *----------------------------------------------------------------
     *  Main line
     *
     C                   exsr      zzinz2
     *
     C     fileky        chain     prplfil1                           79
     C                   if        *in79
     C                   eval      $prtn = '*NONE   '
     C                   goto      out
     C                   endif
500 A
500 A*  Get To (Pick) Slot.
500 A
720 Ac                   if        prrplt = 'S'
720 Ac                   exsr      zzcrtVrtRPA
720 Ac                   endif
730 Ac                   eval      ddslot=*off
750aDc*                  if        prtdis = '*DDSLOT'
750aAc                   if        prtdis = '*DDSLOT' or prrplt='D'
730 Ac                   eval      ddslot=*on
730 Ac                   exsr      zzLoadToSlt
750aDc*                  if        prtdis='*DDSLOT'
750aMc                   if        preturn<>'*OK'
730 AC                   eval      $prtn = '*NONE   '
730 AC                   goto      out
730 Ac                   else
730 Ac                   eval      $slitem=pritem
730 Ac                   endif
730 Ac                   endif
500 AC                   exsr      zzgetpicksl
730 Ac                   if        ddslot
730 Ac                   eval      $slitem=pritem
730 Ac                   eval      #pickslitem=pritem
730 Ac                   endif
500 DC                   if        error  or
500 MC                             $slstat <> 'A ' and
650cDC*                            $slstat <> 'RP'  or
730 DC*                            ($slstat<>'RP' and $slstat<>'PR') or
730 AC                             ($slstat<>'RP' and $slstat<>'PR' and
730 Ac                              $sldesg<>'*DROP') or
500 MC                             $slitem <> pritem
500 AC                   eval      $prtn = '*NONE   '
500 AC                   goto      out
500 AC                   endif
720 Ac                   eval      error=*off
500 A
500 A*  Get To (Pick) Item.
500 A
500 AC                   exsr      zzgetpickit
500 Dc                   if        error
500 MC                             or #pickittype = 'B' and
500 MC                                #pickparitumq2 <= 0
500 AC                   eval      $prtn = '*NONE   '
500 AC                   goto      out
500 AC                   endif
720 Ac                   eval      error=*off
500 A
500 A*  Set replenish quantity.
500 A
510aAC                   select
530 AC                   when      prrplt = 'R'
530 AC                   eval      rplqty = prqty
730 MC                   when      prrplt = 'D'
730 AC                   eval      rplqty = prqty
730 AC                   when      prrplt = 'O'
650cAC                   eval      rplqty = prqty
720 AC                   when      prrplt = 'S'
720 AC                   eval      rplqty = prqty
510aDC**                 if        #pickittype = 'B'
510aMC                   when      #pickittype = 'B'
500 AC                   eval      rplqty = #pickparitumq2
510aAC                   when      #pickittype = 'R'
510aAC                   eval      rplqty = prqty
510aDC**                 else
510aMC                   other
500 AC                   eval      rplqty = 0
510aDC**                 endif
510aMC                   endsl
     *
     *  For breakdown item:
     *  If the replenishment item does not have the breakdown qty 1
     *  defined, then skip this record.
     *
500 DC**                 if        prtype = 'B'
500 DC**   itkey         chain     itemlnk                            79
500 DC**                 if        *in79
500 DC**                 eval      $prtn = '*NONE   '
500 DC**                 goto      out
500 DC**                 endif
     *
500 DC**   ilkey         chain     piritem                            79
500 DC**                 if        not *in79  and
500 DC**                           itumq2 <= 0
500 DC**                 eval      $prtn = '*NONE   '
500 DC**                 goto      out
500 DC**                 else
500 DC**                 eval      rplqty = itumq2
500 DC**                 endif
500 DC**                 else
500 DC**                 eval      rplqty = 0
500 DC**                 endif
     *
     *  Get item.
     *
500 DC**   itkey         chain     piritem                            79
500 DC**                 if        *in79
500 DC**                 eval      $prtn = '*NONE   '
500 DC**                 goto      out
500 DC**                 endif
     *
     *  Get picking slot for item.(TO Slot)
     *
416fD**         SLTKEY    CHAINSLOT2               N79
416fA*
500 DC**                 exsr      zzzisf
500 DC**                 exsr      zzzfs3
500 DC**                 eval      s$whse = $pwhse
500 DC**                 eval      s$whdp = prwhdp
500 DC**                 eval      s$disp = prtdis
500 DC**                 eval      $drisubcmd = '%GET'
500 DC**                 eval      drirtn = *blanks
500 DC**                 eval      chk4err = *on
500 DC**                 exsr      zzzcop
500 DC**                 exsr      zzzd2s
500 DC**                 eval      *in79 = drierr
416fA*
500 DC**                 if        *in79  or
500 DC**                           $slstat <> 'A '  or
500 DC**                           $slitem <> pritem
500 DC**                 eval      $prtn = '*NONE   '
500 DC**                 goto      out
500 DC**                 endif
     *
500 DC**                 eval      toloc = slloc
500 DC**                 eval      torlvl = slrlvl
500 DC**                 eval      tohand = slhand
500 DC**                 eval      tostyp = slstyp
     *
500 DC**   keyid2        chain     itemdef2                           79
500 DC**                 if        *in79
500 DC**                 eval      idtie = *zeros
500 DC**                 eval      idhigh = *zeros
500 DC**                 endif
     *
500 DC**                 eval      savtie = idtie
500 DC**                 eval      savhgh = idhigh
     *
600bM*  Non-broken case items. All items as of revision 5.00b (6.00b)
     *
600bDC**                 if        prtype <> 'B'
     *
     *  Ignore slot if no matching tie/high definition. (To slot)
     *
500 DC**                 if        *in79
600cDC**                 if        #pickittie = 0
600cDC**                           and #pickithigh = 0
600cDC**                 eval      $prtn = '*NONE   '
600cDC**                 goto      out
600cDC**                 endif
     *
     *  Calculate total quantity that can fit in slot.
     *
     C                   select
500 MC                   when      #pickittie = 0
500 MC                   eval      dspqty = #pickithigh
500 MC                   when      #pickithigh = 0
500 MC                   eval      dspqty = #pickittie
     C                   other
500 MC     #pickittie    mult      #pickithigh   dspqty
     C                   endsl
     *
500 MC                   eval      dstqty = dspqty * #pickslpos
     C                   eval      emptyq = dstqty
600cA*
600cA*  If ti/hi not found, set quantities to 9999.
600cA*
600cAC                   if        not foundtihi
650bAc                             or %subst(#picksldisp:1:3)='RPK'
650cAc                             or #pickslstat='PR'
600cAC                   eval      dstqty = 9999
600cAC                   eval      emptyq = 9999
600cAC                   endif
     *
     *  Get stock quantity in pick slot.
     *
500 DC**                 call      'SLOTQTY'
500 DC**                 parm                    slstk1
500 DC**                 parm                    slstk2
500 DC**                 parm                    slstk3
     *
500 DC**                 parm                    slalc1
500 DC**                 parm                    slalc2
500 DC**                 parm                    slalc3
     *
500 DC**                 parm                    sltfr1
500 DC**                 parm                    sltfr2
500 DC**                 parm                    sltfr3
     *
500 DC**                 parm                    slpck1
500 DC**                 parm                    slpck2
500 DC**                 parm                    slpck3
     *
500 DC**                 parm                    slrcv1
500 DC**                 parm                    slrcv2
500 DC**                 parm                    slrcv3
     *
500 DC**                 parm                    stock1            5 0
500 DC**                 parm                    stock2            3 0
500 DC**                 parm                    stock3            3 0
     *
500 DC**                 parm                    avail1            5 0
500 DC**                 parm                    avail2            3 0
500 DC**                 parm                    avail3            3 0
     *
     *  Calculate empty quantity in pick slot.
414bA*    If user is configured as Locator System, then treat pick
414bA*    slot as empty.
     *
500 MC                   if        #pickslavl1 >= 0  and
414bAC                             $pfeat = '2'
500 MC                   eval      emptyq = dstqty - #pickslavl1
CLD A*
CLD AC                   if            client = CityLine
CLD AC                             and $pprg = 'PR321'
CLD A*    More qty in slot than ti/hi, but more needed.
CLD AC                   if        emptyq < 0
CLD AC                   eval      emptyq = emptyq * -1
CLD AC                   endif
CLD A*
CLD AC                   if        praqs > #pickslavl1
CLD AC                             and emptyq = 0
CLD AC                   eval      emptyq = 1
CLD AC                   endif
CLD AC                   endif
CLD A*
600dAC*
600dAC*    Forced Priority Replenishment. Create replenishment
600dAC*    even if slot has qty available.
600d C                   if        prseq# < 0
600d C*
600d C                   if        emptyq < 0
600d C     emptyq        mult      -1            emptyq
600d C                   endif
600d C*
600dAC*    Set empty qty to no more than 1 pallet.
600d C                   if        emptyq = 0  or
600d C                             emptyq > dspqty
600d C                   eval      dspqty = 0
600d C                   endif
600d C*
600d C                   endif
600d C*
     C                   else
     C                   eval      emptyq = dstqty
     C                   endif
     *
     *  Get out if there is no empty space in the pick slot.
     *
     C                   if        emptyq <= 0
     C                   eval      $prtn = '*NONE   '
     C                   goto      out
     C                   endif

600bDC**                 endif
600bA
600bA*  For a Breakdown item ...
600bA
600bAC                   if        prtype = 'B'
600bA
600bA*    Get out if not enough room for 1 full case from parent.
600bA
600bAC                   if        rplqty <= 0
600bAC                   eval      emptyfullq = 0
600bAC                   else
CLD A*
600bAC     emptyq        div       rplqty        emptyfullq
CLD A*
CLD AC                   if            client = CityLine
CLD AC                             and $pprg = 'PR321'
CLD AC                   if        emptyfullq = 0
CLD AC                   eval      emptyfullq = 1
CLD AC                   endif
CLD AC                   endif
CLD A*
600bAC                   endif
600bAC                   if        emptyfullq <= 0
600bAC                   eval      $prtn = '*NONE   '
600bAC                   goto      out
600bAC                   endif
600cA
600cA*    Force replenishing only 1 case if ti/hi not found.
600cA
600cAC                   if        not foundtihi
600cAC                   eval      emptyfullq = 1
600cAC                   endif
600cA
600bAC                   endif

510aA*  For a Repack item ...

510aAC                   if        prrplt = 'R'
730 MC                               or prrplt = 'D'
730 MC                               or prrplt = 'O'
720 AC                               or prrplt = 'S'

510aA*    Force replenishing only 1 case if ti/hi not found.

510aAC                   eval      emptyfullq = rplqty
510aAC                   if        not foundtihi
510aAC                   eval      emptyfullq = 1
510aAC                   endif

510aAC                   endif
     *
     *  FROM Slot.
     *
500 DC**   slfkey        chain     slot2                              79
500 DC**                 if        *in79  or
500 MC                   exsr      zzgetfromsl
500 MC                   if        error  or
700aAC                             #fromslstat <> 'PR' and
414cAC                             #fromslstat <> 'A '  or
415aAC                             #fromslitem <> pritem  and
416aAC                             prtype <> 'B'  or
500 DC**                           #fromslitem <> ilitm2  and
500 MC                             #fromslitem <> #pickitmitem  and
416aAC                             prtype = 'B'
     C                   eval      $prtn = '*NONE   '
     C                   goto      out
     C                   endif
     *
500 DC**                 eval      fmloc = slloc
500 DC**                 eval      fmrlvl = slrlvl
500 DC**                 eval      fmhand = slhand
500 DC**                 eval      fmpseq = slpseq
     *
     *     Ignore slot if no normal stock or past expiration date.
     *
650aAc                   if        prrplt<>'R'
730 Mc                              and prrplt<>'D'
730 Mc                              and prrplt<>'O'
720 Ac                              and prrplt<>'S'
500 MC                   if        #fromslstk1 <= 0  or
500 MC                             #fromslexpd <> 0  and
500 MC                             #fromslexpd < today
     C                   eval      $prtn = '*NONE   '
     C                   goto      out
     C                   endif
650aAC                   endif
     *
600cM*     If nothing available then get out.
     *
500 DC**                 call      'SLOTQTY'
500 DC**                 parm                    slstk1
500 DC**                 parm                    slstk2
500 DC**                 parm                    slstk3
     *
500 DC**                 parm                    slalc1
500 DC**                 parm                    slalc2
500 DC**                 parm                    slalc3
     *
500 DC**                 parm                    sltfr1
500 DC**                 parm                    sltfr2
500 DC**                 parm                    sltfr3
     *
500 DC**                 parm                    slpck1
500 DC**                 parm                    slpck2
500 DC**                 parm                    slpck3
     *
500 DC**                 parm                    slrcv1
500 DC**                 parm                    slrcv2
500 DC**                 parm                    slrcv3
     *
500 DC**                 parm                    stock1
500 DC**                 parm                    stock2
500 DC**                 parm                    stock3
     *
500 DC**                 parm                    avail1
500 DC**                 parm                    avail2
500 DC**                 parm                    avail3
     *
500 MC                   if        #fromslavl1 <= 0
650aAc                               and prrplt <> 'R'
730 Mc                               and prrplt <> 'D'
730 Mc                               and prrplt <> 'O'
720 Ac                               and prrplt <> 'S'
     C                   eval      $prtn = '*NONE   '
     C                   goto      out
     C                   endif
600bD**
600bD** For broken case item, qty picked is always 1.
600bD**   (Not true as of version 6.00b)
600bD**
600bDC**                 if        prtype = 'B'
600bDC**                 eval      topick = 1
600bDC**                 else
     *
     *  Get tie/high for FROM slot.
     *
500 DC**   keyid2        chain     itemdef2                           79
500 DC**                 if        *in79
500 DC**                 eval      idtie = 0
500 DC**                 eval      idhigh = 0
500 DC**                 endif
     *
     *     Grab one pallet or less.
     *
     C                   select
500 MC                   when      #fromittie = 0
500 MC                   eval      pallet = #fromithigh
500 MC                   when      #fromithigh = 0
500 MC                   eval      pallet = #fromittie
     C                   other
500 MC     #fromittie    mult      #fromithigh   pallet
     C                   endsl
500 MC                   if        pallet <= #fromslavl1  and
     C                             pallet > 0
     C                   eval      topick = pallet
     C                   else
500 MC                   eval      topick = #fromslavl1
     C                   endif
510aAC                   if        prrplt = 'R'
730 MC                               or prrplt = 'D'
730 MC                               or prrplt = 'O'
720 AC                               or prrplt = 'S'
510aAC                   eval      topick = rplqty
510aAC                   endif
     *
     *  Make sure quantity will fit in slot.
     *
600bDC**                 if        topick > emptyq
600bDC**                 z-add     emptyq        topick
600bDC**                 endif

600bAC                   select
600bAC                   when      prtype = 'B' and topick > emptyfullq
600bAC                   z-add     emptyfullq    topick
600bAC                   when      prtype <> 'B' and topick > emptyq
600bAC                   z-add     emptyq        topick
600bAC                   endsl

600bDC**                 endif
415 D*
415 D*  Check to see if replenishment will free up a slot?
415 D*
415 D*          TOPICK    IFNE AVAIL1
415 D*          PRFREE    ANDEQ'Y'
415 D*                    MOVE '*NONE   '$PRTN
415 D*                    GOTO OUT
415 D*                    ENDIF
     *
417aA*    Only when directed, create new transaction number.
417aA*
500 DC**                 if        $pcrtt = 'Y'
417aA*
     *  Create transaction record.
     *
500 DC**                 call      'PIRTRN#'
500 DC**                 parm                    pttrn#            7 0
500 DC**                 eval      $ptrn# = pttrn#
500 DC**                 eval      $pbat# = batch#
417aA*
417aA*    Creating Pushback/Eaches replenishments. Use existing
417aA*    Batch and Transaction#.
417aA*
500 DC**                 else
500 DC**                 eval      pttrn# = $ptrn#
417aA*
500 DC**                 endif
     *
500 DC**                 if        prtype = 'B'
500 DC**                 eval      @ptask = 'REPLBK'
500 DC**                 else
500 DC**                 eval      @ptask = 'REPL  '
500 DC**                 endif
     *
417aA*    Only when directed, create new transaction number.
417aA*
417aAC                   if        $pcrtt = 'Y'
600aAC                             and $pprg <> 'PR321'
500 AC                   exsr      zztrncrt
417aA*
500 DC**   itcube        mult      topick        @pcube
500 DC**   itswgt        mult      topick        @pswgt
500 DC**                 call      @addtr
500 DC**                 parm      '*CREATE '    @pcmd             8
500 DC**                 parm                    #job
500 DC**                 parm      pttrn#        @ptrn#            7 0
500 DC**                 parm                    @ptask            6
500 DC**                 parm      $pwhse        @pwhse            3 0
500 DC**                 parm      prwhdp        @pwhdp            5
500 DC**                 parm      slstyp        @pstyp            1
500 DC**                 parm                    @pcube            9 3
500 DC**                 parm                    @pswgt            9 2
500 DC**                 parm      topick        @ppcs             5 0
500 DC**                 parm      1             @paisl            5 0
500 DC**                 parm      0             @pqty1            5 0
500 DC**                 parm      0             @pqty2            5 0
500 DC**                 parm      0             @pqty3            5 0
500 DC**                 parm      '0'           @prte             5
500 DC**                 parm      ' '           @ppo              9
500 DC**                 parm      'L'           @pgrp1            1
500 DC**                 parm      ' '           @pgrp2            1
500 DC**                 parm      ' '           @prtn             8
500 DC**                 parm      ' '           @pmsg             4
417aA*
417aAC                   else
417aA*    Insert code to update existing transaction.
417aA*
500 AC                   eval      curtrn# = $ptrn#
510bAc                   if        prrplt = 'F'
510bAc                   exsr      zztrnupdf
510bAC                   endif
417aAC                   endif
500xA*
500xA*  Get From item information for Breakdown replenishment.
500xA*
500xAC                   if        prtype = 'B'
500xAC                   exsr      zzgetfromit
500xAC                   endif
     *
     *  Create label record.
     *
     C                   clear                   lbrec
     *  FROM Slot.
500 MC                   eval      lbwhse = #fromslwhse
500 MC                   eval      lbwhdp = #fromslwhdp
500 MC                   eval      lbaisl = #fromslaisl
500 MC                   eval      lbloc =  #fromslloc
500 MC                   eval      lbrlvl = #fromslrlvl
500 MC                   eval      lbhand = #fromslhand
500 MC                   eval      lbpseq = #fromslpseq
500 MC                   eval      lbdisp = #fromsldisp
500 MC                   eval      lbqavl = #fromslavl1
     * TO Slot.
500 MC                   eval      lbwhs2 = #pickslwhse
500 MC                   eval      lbwhd2 = #pickslwhdp
500 MC                   eval      lbstyp = #pickslstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
500 MC                   eval      lbasl2 = #pickslaisl
500 MC                   eval      lbloc2 = #pickslloc
500 MC                   eval      lblvl2 = #pickslrlvl
500 MC                   eval      lbhnd2 = #pickslhand
500 MC                   eval      lbdsp2 = #picksldisp
     C                   eval      lbrte = *blanks
     *
500xAC                   if        prtype = 'B'
640aAC                   if        client = cityline
640aMC                   eval      lbitem = #pickititem
640aAC                   else
640aDC                   eval      lbitem = #fromititem
640aAC                   endif
500xAC                   else
500 DC**                 eval      lbitem = pritem
500 MC                   eval      lbitem = #pickititem
500xAC                   endif
     C                   eval      lbpbat = batch#
650dAc*  if breakdown replenishment for production item then create
650dAc*  label record with breakdown quantity instead of normal qty
650dAc                   if        prtype = 'E'
650dAc                   eval      lbutyp = '1'
650dAc                   else
     C                   eval      lbutyp = 'N'
650dAc                   endif
500xAC                   if        prtype = 'B'
500xAC                   eval      lbucub = #fromitcube
500xAC                   eval      lbuwgt = #fromitswgt
500xAC                   else
500 MC                   eval      lbucub = #pickitcube
500 MC                   eval      lbuwgt = #pickitswgt
500xAC                   endif
     C                   eval      lbqalc = topick
     *
     *  Quantity remaining field is used to contain break down
     *  quantity for broken case item.
     *
510aAC                   select
510aDC**                 if        prtype = 'B'
510aMC                   when      prtype = 'B'
600bDC**                 eval      lbqrmn = rplqty
600bMC                   eval      lbqrmn = rplqty * topick
510aAC                   when      prrplt = 'R'
510aAC                   eval      lbqrmn = topick
730 MC                   when      prrplt = 'D'
730 AC                   eval      lbqrmn = topick
730 MC                   when      prrplt = 'O'
650cAC                   eval      lbqrmn = topick
720 AC                   when      prrplt = 'S'
720 AC                   eval      lbqrmn = topick
510aDC**                 else
510aAC                   other
     C                   eval      lbqrmn = 0
510aDC**                 endif
510aAC                   endsl
     C                   eval      lbqpck = topick
     C                   eval      lbcube = topick * lbucub
     C                   eval      lbswgt = topick * lbuwgt
650dAc*  if breakdown replenishment for production item then create
650dAc*  label record with breakdown 1 unit of measure
650dAc                   if        prtype = 'E'
650dAC                   eval      lbucod = #pickitum2
650dAc                   else
500 MC                   eval      lbucod = #pickitum1
650dAc                   endif
500 DC**                 eval      lbtie = savtie
500 DC**                 eval      lbhigh = savhgh
500 MC                   eval      lbtie = #pickittie
500 MC                   eval      lbhigh = #pickithigh
500 DC**                 eval      lbtrn# = pttrn#
500 MC                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
417aAC                   eval      $plbl# = lblbl#
     C                   eval      lbgrp1 = 'L'
     C                   eval      lbgrp2 = ' '
600aAC                   if        $pprg = 'PR321'
600aAC                   eval      lbtype = 'X'
600aAC                   eval      lbstat = 'C'
600aAC                   else
     C                   eval      lbtype = 'R'
     C                   eval      lbstat = 'P'
600aAC                   endif
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
600aA*
600aA*     See if we should skip the rest of the updates.
600aA*
600aAC                   if        $pprg = 'PR321'
600aAC***                unlock    slot2
600aAC                   goto      skipupdate
600aAC                   endif
     *
     *     Update slot.(FROM Slot)
     *
500 DC**                 add       topick        sltfr1
500 DC**                 update    slrec
416fA*
500 DC**                 exsr      zzzisf
500 DC**                 exsr      zzzs2d
500 DC**                 exsr      zzzfs2
500 AC                   exsr      clr$slot
416fAC                   eval      $slwhseu = *on
416fAC                   eval      $slwhse = #fromslwhse
416fAC                   eval      $slwhdpu = *on
416fAC                   eval      $slwhdp = #fromslwhdp
416fAC                   eval      $sldispu = *on
416fAC                   eval      $sldisp = #fromsldisp
416fAC                   eval      $saitemu = *on
416fAC                   eval      $saitem = #fromslitem
500xAC                   eval      $sacitemu = *on
500xAC                   eval      $sacitem = #pickslitem
416fAC                   eval      $satrn#u = *on
416fAC                   eval      $satrn# = curtrn#
416fAC                   eval      $satasku = *on
416fAC                   eval      $satask = @ptask
416fAC                   eval      $saqtyu = *on
650dAc*  if breakdown replenishment for production item then create
650dAc*  send quantity as breakdown quantity to DRISLOT for stock move
650dAc                   if        prtype = 'E'
650dDC*                  eval      $saqty1 = topick
650dDc*                  eval      $saqty2 = 0
650dAC                   eval      $saqty1 = 0
650dAc                   eval      $saqty2 = topick
650dAc                   else
650dAC                   eval      $saqty1 = topick
650dAc                   eval      $saqty2 = 0
650dAc                   endif
416fAC                   eval      $saqty3 = 0
600eA
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'RPL'
600eAC                   eval      $saETrn#U = *on
600eAC                   eval      $saETrn# = 0
600eAC**                 eval      $saLbl#U = *on
600eAC**                 eval      $saLbl# = lblbl#
600eAC                   eval      $saToLcnsU = *on
600gDC                   eval      $saToLcns = $tinlic#
600gDC                   eval      $saToPosU = *on
600gDC                   eval      $saToPos = $tslotpos
600gDC                   eval      $saToVrfyU = *on
600eAC                   eval      $saToVrfy = 'N'
600eAC                   eval      $saToCodeu = *on
600eAC                   eval      $saToCode = 'U'
600eAC                   eval      $saToAreaU = *on
600eAC                   eval      $saToArea = 'User'
600gDC                   eval      $saFrmLcnsU = *on
600gDC                   eval      $saFrmLcns = $toutlic#
600eAC                   eval      $saOLcnsU = *on
600eAC                   eval      $saOLcns = #fromOLcns

416fAC                   eval      $dricommand = '*SLOT'
500xDC**                 eval      $drisubcmd = '%PROUT'
600eDC**                 eval      $drisubcmd = '%PROUTCHG'
600eMC                   eval      $drisubcmd = '%TFR2USR'
416fAC                   eval      chk4err = *off
416fAC                   eval      zmsflag = *off
600hDC***********        exsr      zzzdricop
     *
     *     Update slot.(TO Slot)
     *
600eDC**                 exsr      clr$slot
600eDC**                 eval      $slwhseu = *on
600eDC**                 eval      $slwhse = #pickslwhse
600eDC**                 eval      $slwhdpu = *on
600eDC**                 eval      $slwhdp = #pickslwhdp
600eDC**                 eval      $sldispu = *on
600eDC**                 eval      $sldisp = #picksldisp
600eDC**                 eval      $saitemu = *on
600eDC**                 if        prrplt = 'R'
600eDC**                 eval      $saitem = pritem
600eDC**                 else
600eDC**                 eval      $saitem = #pickslitem
600eDC**                 endif
600eDC**                 eval      $sacitemu = *on
600eDC**                 eval      $sacitem = #fromslitem
600eDC**                 eval      $satrn#u = *on
600eDC**                 eval      $satrn# = curtrn#
600eDC**                 eval      $satasku = *on
600eDC**                 eval      $satask = @ptask
600eDC**                 eval      $saqtyu = *on
500aDC**                 if        prtype = 'B'
500aDC**                 eval      $saqty1 = rplqty
500aDC**                 else
600eDC**                 eval      $saqty1 = topick
500aDC**                 endif
600eDC**                 eval      $saqty2 = 0
600eDC**                 eval      $saqty3 = 0
600eDC**                 eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd = '%PRINCHG'
500 DC**                 eval      $drireturn = @noupd
600eDC**                 eval      chk4err = *off
600eDC**                 eval      zmsflag = *off
600eDC**                 exsr      zzzdricop
416fA*
500 DC**                 endif
     *
     *  Adjust warehouse quantity for broken case item.
     *
500 DC**                 if        prtype = 'B'
     *
     *  Allocate stock.(Full case item) Qty will be reduced in
     *  close program.
     *
500 DC**                 eval      $acmd = '*ALLOC  '
500 DC**                 eval      $aprg = #prog
500 DC**                 eval      $atype = '*BATCH  '
500 DC**                 eval      $awhse = $pwhse
500 DC**                 eval      $aitem = ilitm2
500 DC**                 eval      $aqty1 = 1
500 DC**                 eval      $aqty2 = 0
500 DC**                 eval      $aqty3 = 0
500 DC**                 call      'ADJQTY'
500 DC**                 parm                    $acmd             8
500 DC**                 parm                    $aprg            10
500 DC**                 parm                    $atype            8
500 DC**                 parm                    $awhse            3 0
500 DC**                 parm                    $aitem           15
500 DC**                 parm                    $aqty1            7 0
500 DC**                 parm                    $aqty2            7 0
500 DC**                 parm                    $aqty3            7 0
500 DC**                 parm                    $artq1            7 0
500 DC**                 parm                    $artq2            7 0
500 DC**                 parm                    $artq3            7 0
500 DC**                 parm                    $artn             8
500 DC**                 parm                    $aerm
     *
     *  Add stock.(Broken case item)
     *
500 DC**                 eval      $acmd = '*STOCK  '
500 DC**                 eval      $aprg = #prog
500 DC**                 eval      $atype = '*BATCH  '
500 DC**                 eval      $awhse = $pwhse
500 DC**                 eval      $aitem = pritem
500 DC**                 eval      $aqty1 = rplqty
500 DC**                 eval      $aqty2 = 0
500 DC**                 eval      $aqty3 = 0
500 DC**                 call      'ADJQTY'
500 DC**                 parm                    $acmd
500 DC**                 parm                    $aprg
500 DC**                 parm                    $atype
500 DC**                 parm                    $awhse
500 DC**                 parm                    $aitem
500 DC**                 parm                    $aqty1
500 DC**                 parm                    $aqty2
500 DC**                 parm                    $aqty3
500 DC**                 parm                    $artq1
500 DC**                 parm                    $artq2
500 DC**                 parm                    $artq3
500 DC**                 parm                    $artn
500 DC**                 parm                    $aerm
500 DC**                 endif
     *
600aAC     skipupdate    tag
     *
     *  Indicate to calling program, successful replenishment created.
     *
     C                   eval      $prtn = '*OK     '
     *
     C     out           tag
     C                   if        $prtn = '*NONE   '
     C                   eval      $ptrn# = *zeros
500 AC                   else
500 AC                   eval      $ptrn# = curtrn#
     C                   endif
     *
     *  Done with this replenishment (Delete this work record).
     *
414aD*                    DELETPRREC
     *
     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
640aA*
640aA* Get client id.
640aA*
640aAC                   call      'GETCLIENT'
640aAC                   parm                    client           10
     *
     *  Define key for PRPLFIL1 file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pseq#
     *
     *  Define key for PIRITEM file. (For item to be replenished)
     *
500 DC**   itkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    pritem
     *
     *  Define key for PIRITEM file. (For link item)
     *
500 DC**   ilkey         klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    ilitm2
     *
     *  Define key for SLOT2 file. (From slot)
     *
500 DC**   slfkey        klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    prwhdp
500 DC**                 kfld                    prfdis
     *
     *  Define key for SLOT2 file. (To slot)
     *
500 DC**   sltkey        klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    prwhdp
500 DC**                 kfld                    prtdis
     *
     *  Define key for ITEMDEF2 file.
     *
500 DC**   keyid2        klist
500 DC**                 kfld                    $pwhse
500 DC**                 kfld                    pritem
500 DC**                 kfld                    slsdef
     *
     *
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZTRNCRT  Create transaction
500 A*----------------------------------------------------------------
500 A
500 AC     zztrncrt      begsr

510aDC**                 if        prtype = 'B'
510aDC**                 eval      @ptask = 'REPLBK'
510aDC**                 else
510aDC**                 eval      @ptask = 'REPL  '
510aDC**                 endif
510aAC                   select
510aAC                   when      prtype = 'B'
510aAC                   eval      @ptask = 'REPLBK'
510aAC                   when      prrplt = 'R'
510aAC                   eval      @ptask = 'REPLRP'
730 MC                   when      prrplt = 'D'
730 AC                   eval      @ptask = 'REPLPD'
730 MC                   when      prrplt = 'O'
710bAC                   eval      @ptask = 'REPLPD'
720 AC                   when      prrplt = 'S'
720 AC                   eval      @ptask = 'REPLRS'
510aAC                   other
510aAC                   eval      @ptask = 'REPL  '
510aAC                   endsl

     C                   eval      @pcube = topick * #fromitcube
     C                   eval      @pswgt = topick * #fromitswgt

     C                   call      'ADJTRAN2'
     C                   parm      '*CREATE'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      #fromslwhse   @pwhse            3 0
     C                   parm      #fromslwhdp   @pwhdp            5
     C                   parm      #fromslstyp   @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      topick        @ppcs             5 0
     C                   parm      1             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #user         @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

510bA*----------------------------------------------------------------
510bA*  ZZTRNUPDF  Update transaction for flow replenishments
510bA*----------------------------------------------------------------
510bA
510bAC     zztrnupdf     begsr

     C                   eval      @pcube = topick * #fromitcube
     C                   eval      @pswgt = topick * #fromitswgt

     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL   '  @lcmd            10
     C                   parm                    #prog
     C                   parm      '*INTER'      $ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      #fromslwhse   @pwhse            3 0
     C                   parm      prwhdp        @pwhdp            5
     C                   parm      #fromslstyp   @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      topick        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'L'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             $pdate            8 0
     C                   parm      0             $ptime            6 0
     C                   parm      ' '           $puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  ZZGETFROMIT   Get From item being replenished.
500 A*----------------------------------------------------------------
500 A
500 AC     zzgetfromit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #fromslwhse
     C                   eval      $ititem  = #fromslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endgetfromit
     C                   endif

     C                   eval      #fromitwhse = $itwhse
     C                   eval      #fromititem = $ititem
     C                   eval      #fromittype = $ittype
     C                   eval      #fromitdesc = $itdesc
     C                   eval      #fromitpdsc = $itpdsc
     C                   eval      #fromitwhdp = $itwhdp
     C                   eval      #fromitstyp = $itstyp
     C                   eval      #fromitdesg = $itdesg
     C                   eval      #fromitum1  = $itum1
     C                   eval      #fromitflg1 = $itflg1
     C                   eval      #fromitum2  = $itum2
     C                   eval      #fromitumq2 = $itumq2
     C                   eval      #fromitflg2 = $itflg2
     C                   eval      #fromitum3  = $itum3
     C                   eval      #fromitumq3 = $itumq3
     C                   eval      #fromitnrpk = $imnrpk
     C                   eval      #fromitflgd = $itflgd
     C                   eval      #fromitcube = $itcube
     C                   eval      #fromitswgt = $itswgt
     C                   eval      #fromitcwgt = $itcwgt
     C                   eval      #fromitmitem = $itmitem
     C                   eval      #fromitsdef = ' '
     C                   eval      #fromittie  = 0
     C                   eval      #fromithigh = 0
600eAC                   eval      #fromimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo

     C     endgetfromit  endsr
500 A
500 A*----------------------------------------------------------------
500 A*  ZZGETFROMSL   Get From slot.
500 A*----------------------------------------------------------------
500 A
500 AC     zzgetfromsl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = prwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = prwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = prfdis

     C                   eval      $dricommand = '*SLOT'
600iDC**                 eval      $drisubcmd  = '%GETCHKV'
600iMC                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endgetfromsl
     C                   endif

     C                   eval      #fromslwhse = $slwhse
     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslstat = $slstat
     C                   eval      #fromslrsrv = $slrsrv
     C                   eval      #fromslentd = $slentd
     C                   eval      #fromslexpd = $slexpd
     C                   eval      #fromslslfd = $slslfd
     C                   eval      #fromslactv = $slactv
     C                   eval      #fromslbld  = $slbld
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslsdef = $slsdef
     C                   eval      #fromslvirt = $sfvirt
     C                   eval      #fromslstk1 = $slstk1
     C                   eval      #fromslstk2 = $slstk2
     C                   eval      #fromslstk3 = $slstk3
     C                   eval      #fromslalc1 = $slalc1
     C                   eval      #fromslalc2 = $slalc2
     C                   eval      #fromslalc3 = $slalc3
     C                   eval      #fromsltfr1 = $sltfr1
     C                   eval      #fromsltfr2 = $sltfr2
     C                   eval      #fromsltfr3 = $sltfr3
     C                   eval      #fromslpck1 = $slpck1
     C                   eval      #fromslpck2 = $slpck2
     C                   eval      #fromslpck3 = $slpck3
     C                   eval      #fromslrcv1 = $slrcv1
     C                   eval      #fromslrcv2 = $slrcv2
     C                   eval      #fromslrcv3 = $slrcv3
     C                   eval      #fromslphy1 = $slphy1
     C                   eval      #fromslphy2 = $slphy2
     C                   eval      #fromslphy3 = $slphy3
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
     C                   eval      #fromslavl3 = $slavl3

     C                   eval      #frombasesldsp = $sacdsp
600eAC                   eval      #fromToLcns = $saToLcns
600eAC                   eval      #fromToPos = $saToPos
600eAC                   eval      #fromOLcns = $saOLcns

     *  Get slot definition for From slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #fromslpos = $sdpos

600hAC                   eval      frm$slot = $slot
600hAC                   eval      frm$slot2 = $slot2

     C     endgetfromsl  endsr
500 A
500 A*----------------------------------------------------------------
500 A*  ZZGETPICKIT   Get pick slot item being replenished.
500 A*----------------------------------------------------------------
500 A
500 AC     zzgetpickit   begsr

     *  Get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickslwhse
     C                   eval      $ititem  = #pickslitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #pickitwhse = $itwhse
     C                   eval      #pickititem = $ititem
     C                   eval      #pickittype = $ittype
     C                   eval      #pickitdesc = $itdesc
     C                   eval      #pickitpdsc = $itpdsc
     C                   eval      #pickitwhdp = $itwhdp
     C                   eval      #pickitstyp = $itstyp
     C                   eval      #pickitdesg = $itdesg
     C                   eval      #pickitum1  = $itum1
     C                   eval      #pickitflg1 = $itflg1
     C                   eval      #pickitum2  = $itum2
     C                   eval      #pickitumq2 = $itumq2
     C                   eval      #pickitflg2 = $itflg2
     C                   eval      #pickitum3  = $itum3
     C                   eval      #pickitumq3 = $itumq3
     C                   eval      #pickitnrpk = $imnrpk
     C                   eval      #pickitflgd = $itflgd
     C                   eval      #pickitcube = $itcube
     C                   eval      #pickitswgt = $itswgt
     C                   eval      #pickitcwgt = $itcwgt
     C                   eval      #pickitmitem = $itmitem
     C                   eval      #pickitsdef = ' '
     C                   eval      #pickittie  = 0
     C                   eval      #pickithigh = 0
600eAC                   eval      #pickimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #pickititem
     C                   parm                    #pickitdesc
     C                   parm                    #pickitpdsc
     C                   parm      ' '           #pickithead

     *  Save tie/high info if defined for item.

600cAC                   eval      foundtihi = *off
     C     1             do        5             i
     C                   if        $idsdef(i) = #pickslsdef
     C                   eval      #pickitsdef = $idsdef(i)
     C                   eval      #pickittie  = $idtie(i)
     C                   eval      #pickithigh = $idhigh(i)
710aAC                   if        $idtie(i) = 0 and
710aAC                             $idhigh(i)= 0
710aAC                   else
600cAC                   eval      foundtihi = *on
710aAC                   endif
     C                   leave
     C                   endif
     C                   enddo

     *  Get Parent item if necessary.

     C     #pickittype   cabne     'B'           endgetpickit

     C                   exsr      clr$item
     C                   eval      $itwhse  = #pickitwhse
     C                   eval      $ititem  = #pickitmitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endgetpickit
     C                   endif

     C                   eval      #pickparititem = $ititem
     C                   eval      #pickparittype = $ittype
     C                   eval      #pickparitdesc = $itdesc
     C                   eval      #pickparitpdsc = $itpdsc
     C                   eval      #pickparitwhdp = $itwhdp
     C                   eval      #pickparitstyp = $itstyp
     C                   eval      #pickparitdesg = $itdesg
     C                   eval      #pickparitum1  = $itum1
     C                   eval      #pickparitum2  = $itum2
     C                   eval      #pickparitumq2 = $itumq2
     C                   eval      #pickparitum3  = $itum3
     C                   eval      #pickparitumq3 = $itumq3
600eAC                   eval      #pickparimltrk = $imltrk

     C     endgetpickit  endsr
500 A
500 A*----------------------------------------------------------------
500 A*  ZZGETPICKSL   Get Pick slot.
500 A*----------------------------------------------------------------
500 A
500 AC     zzgetpicksl   begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = prwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = prwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = prtdis

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *on
     C                   goto      endgetpicksl
     C                   endif

     C                   eval      #pickslwhse = $slwhse
     C                   eval      #pickslwhdp = $slwhdp
     C                   eval      #pickslstyp = $slstyp
     C                   eval      #picksldisp = $sldisp
     C                   eval      #pickslaisl = $slaisl
     C                   eval      #pickslloc  = $slloc
     C                   eval      #pickslpseq = $slpseq
     C                   eval      #pickslrlvl = $slrlvl
     C                   eval      #pickslhand = $slhand
     C                   eval      #pickslstat = $slstat
     C                   eval      #pickslrsrv = $slrsrv
     C                   eval      #pickslentd = $slentd
     C                   eval      #pickslexpd = $slexpd
     C                   eval      #pickslslfd = $slslfd
     C                   eval      #pickslactv = $slactv
     C                   eval      #pickslbld  = $slbld
     C                   eval      #pickslpick = $slpick
     C                   eval      #pickslitem = $slitem
     C                   eval      #pickslsdef = $slsdef
     C                   eval      #pickslvirt = $sfvirt
     C                   eval      #pickslstk1 = $slstk1
     C                   eval      #pickslstk2 = $slstk2
     C                   eval      #pickslstk3 = $slstk3
     C                   eval      #pickslalc1 = $slalc1
     C                   eval      #pickslalc2 = $slalc2
     C                   eval      #pickslalc3 = $slalc3
     C                   eval      #picksltfr1 = $sltfr1
     C                   eval      #picksltfr2 = $sltfr2
     C                   eval      #picksltfr3 = $sltfr3
     C                   eval      #pickslpck1 = $slpck1
     C                   eval      #pickslpck2 = $slpck2
     C                   eval      #pickslpck3 = $slpck3
     C                   eval      #pickslrcv1 = $slrcv1
     C                   eval      #pickslrcv2 = $slrcv2
     C                   eval      #pickslrcv3 = $slrcv3
     C                   eval      #pickslphy1 = $slphy1
     C                   eval      #pickslphy2 = $slphy2
     C                   eval      #pickslphy3 = $slphy3
     C                   eval      #pickslavl1 = $slavl1
     C                   eval      #pickslavl2 = $slavl2
     C                   eval      #pickslavl3 = $slavl3

     C                   eval      #pickbasesldsp = $sacdsp
600eAC                   eval      #pickToLcns = $saToLcns
600eAC                   eval      #pickToPos = $saToPos
600eAC                   eval      #pickOLcns = $saOLcns

     *  Get slot definition for To slot.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        drierr
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #pickslpos = $sdpos

     C     endgetpicksl  endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2  Program initialization. Called from mainline.
     *
     C     zzinz2        begsr
     *
     C                   eval      $pwhse = $pwhs
     C                   eval      n = 0
     C                   eval      error = *off
     *
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
600fA*
600fA*    - Get default values for the user.
600fA*
600fAC                   call      'GETUSER'
600fAC                   parm                    #user
600fAC                   parm      0             #whse             3 0
600fAC                   parm      0             #emp#             5 0
600fAC                   parm                    #fnam            15
600fAC                   parm                    #init             1
600fAC                   parm                    #lnam            20
600fAC                   parm                    #whdp             5
600fAC                   parm                    #styp             1
600fAC                   parm                    #shft             6
600fAC                   parm                    #crew             6
600fAC                   parm      0             #nhrs             3 1
600fAC                   parm                    #rtn              8
600fAC                   parm                    e$bpu             1
600fAC                   parm                    e$lng             2
600fAC                   if        #rtn <> '*OK'
600fAC                   eval      e$lng = 'EN'
600fAC                   endif
     *
     *     - Get new batch number.
417aA*    Only when directed to create new transaction number.
     *
417aAC                   if        $pcrtt = 'Y'
417aA*
     C                   call      'PIRBAT#'
     C                   parm                    batch#            7 0
     *
     *     - Create batch control record.
     *
     C                   eval      btbat# = batch#
     C                   eval      btwhse = $pwhse
     C                   eval      bttype = '*REPLEN '
     C                   eval      btstat = *blanks
     C                   eval      btrte = *blanks
     C                   eval      btstrd = today
     C                   time                    btstrt
     C                   eval      btstrb = #user
     C                   write     btrec
500 AC                   eval      $pbat# = batch#
417aA*
417aA*    Creating Pushback/Eaches replenishments. Use existing
417aA*    Batch and Transaction#.
417aA*
417aAC                   else
417aAC                   eval      btbat# = $pbat#
417aAC                   eval      batch# = $pbat#
417aA*
417aAC                   endif
     *
     C                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
600fAC                   eval      $saemp#U = *on
600fAC                   eval      $saemp# = #emp#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slotdef  Clear $slotdef data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
720 A
720 A*----------------------------------------------------------------
720 A*  zzzcrtVrtRPA   Create Virtual slot for Replenishment Stage Area
720 A*----------------------------------------------------------------
720 A
720 AC     zzcrtVrtRPA   begsr
720 A
720 A*    Create Virtual Replenishment Area Staging Slot
720 A
720 AC                   exsr      clr$slot
720 A
720 AC                   eval      $slwhseu = *on
720 AC                   eval      $slwhse  = prwhse
720 AC                   eval      $slwhdpu = *on
720 AC                   eval      $slwhdp  = prwhdp
720 AC                   eval      $saitemu = *on
720 AC                   eval      $saitem  = pritem
720 AC                   eval      $saToArea = *on
720 AC                   eval      $saToArea = 'DOCK'
720 A
720 AC                   eval      $dricommand = '*SLOT'
720 AC                   eval      $drisubcmd  = '%CRTRPA'
720 AC                   eval      $drisys2upd = 'D'
720 AC                   eval      chk4err = *on
720 AC                   eval      zmsflag = *off
720 AC                   exsr      zzzdricop
720 AC                   if        drierr
720 Ac                   else
720 Ac**  Return RPADOCK Slot for Staging Replenishments
720 Ac                   eval      prtdis = $sldisp
720 Ac                   eval      prtail = $slaisl
720 Ac                   eval      prtloc = $slloc
720 Ac                   eval      prtlvl = $slrlvl
720 Ac                   eval      prthnd = $slhand
720 A /free
720 A       // Update Priority Replenishment record with Virtual RPADOCK location
720 A             exec sql update prplfil
720 A                  set prtdis=:$sldisp, prtail=:$slaisl, prtloc=:$slloc,
720 A                      prtlvl=:$slrlvl, prthnd=:$slhand
720 A                  where prwhse=:prwhse and pritem=:pritem and
720 A                        prflag='A' and prqty=:prqty and prfdis=:prfdis;
720 A /end-free
720 AC                   endif
720 AC                   endsr
740aA*----------------------------------------------------------------
740aA*  zzzLoadToSlt   Load To Slot for Drop Pick when one is not already
740aA*                 Defined
740aA*----------------------------------------------------------------
740aA
740aAC     zzLoadToSlt   begsr
740a
740a  *  Call GETDDSLOT to determine if Drop Pick Slot defined
750aA *  We now call at this point to determine if valid Drop Pick
750aA *  is defined as well as whether one is available.  We have
750aA *  added a new option which limits the number of items
750aA *  that can exist for a Drop Pick.  This is opddmax in
750aA *  Replen options.
740a
750bAc                   if        prtdis<>'*DDSLOT'
750bAc                   eval      pdddis=prtdis
750bAc                   else
750bAc                   eval      pdddis=*blanks
750bAc                   endif
750bA
740a c                   call      'GETDDSLOT'
740a c                   parm                    $pWhse
750aDc*                  parm                    prwhdp
750aMc                   parm      prwhdp        pofwhdp           5
750aDc*                  parm                    pritem
750aMc                   parm      pritem        pofitem          15
750aDc*                  parm                    prfdis
750aMc                   parm      prfdis        pofdis           12
750aDc*                  parm                    prfail
750aMc                   parm      prfail        pofail            3
750aDc*                  parm                    prfloc
750aMc                   parm      prfloc        pofloc            3 0
750aDc*                  parm                    prtdis
750bDc*                  parm      *blanks       pdddis           12
750bMc                   parm                    pdddis           12
750aDc*                  parm                    prtail
750aMc                   parm      *blanks       pddail            3
750aDc*                  parm                    prtloc
750aMc                   parm      *zeros        pddloc            3 0
750aDc*                  parm                    prtlvl
750aMc                   parm      *zeros        pddlvl            2 0
750aDc*                  parm                    prthnd
750aMc                   parm      *blanks       pddhnd            2
750aAc                   parm      prqty         pddqty1           3 0
750aAc                   parm      prtype        pddtype           1
750aAc                   parm      'RPL'         ptrntype          3
740a c                   parm                    pReturn          10
750aA /free
750aA         // If GETDDSLOT returns *OK it means a drop pick was assigned,
750aA         // otherwise either no drop picks were found, or none or available
750aA         if pReturn = '*OK';
750aA           prtdis=pdddis;
750aA           prtail=pddail;
750aA           prtloc=pddloc;
750aA           prtlvl=pddlvl;
750aA           prthnd=pddhnd;
750aA
750aA           // Create overflow Drop Pick virtual based on what GETDDSLOT
750aA           // returns.  If that slot already exist this function will
750aA           // not not add
750aA           exsr clr$slot;
750aA           $slwhseu = *on;
750aM           $slwhse  = $pwhse;
750aA           $slwhdpu = *on;
750aM           $slwhdp  = prwhdp;
750aA           $sldispu = *on;
750aM           $sldisp  = pdddis;
750aA           $slitemu = *on;
750aM           $slitem  = pritem;
750aA           $dricommand = '*SLOT';
750aA           $drisubcmd = '%CRTVOFLW';
750aA           $drisys2upd = 'D';
750aA           exsr zzzdricop;
750aA         endif;
750aA
750aA /end-free
740aAC                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdriclose   Close any open files or programs.
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600eAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600eAC                             or $dricommand = '*SLOT'
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

     C                   when      chk4err and %error
     C                   eval      drierr = *on
     C**                 eval      errmsg    = 'Error occured on call to '
     C**                                     + 'DRICOP'
     C**                                     + '/' + %trim($drisubcmd)
     C**                                     + ' from ' + #prog
     C**                 if        zmsflag
     C**                 exsr      zm0105s
     C**                 else
     C**                 exsr      zm0105
     C**                 endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      drierr = *on
     C**                 if        zmsflag
     C**                 exsr      zm0001s
     C**                 else
     C**                 exsr      zm0001
     C***                exsr      zzerrind
     C**                 endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
