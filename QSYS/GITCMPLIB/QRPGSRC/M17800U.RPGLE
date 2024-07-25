      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M17800U      Gui Item Maintenance
     *  02 November  2020
     *  Lynn McMahon
     *
     *  Revisions:
     *
     *    11/02/20  LMC  7.40
     *      - Created.
750a *    08/19/21  LMC  7.50a
     *      - Moved logic from *inzsr to get options settings.
     *        The pwhse field is not populated yet at *inzsr.
     *        moved the logic after the Pwhse field is loaded.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds

DRYaA*----------------------------------------------------------------
DRYaA*  *IMPITEM  -  Import Item options.
DRYaA*----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
     *    OPNSLT  -  Non-slotted item
     *    OPXDCK  -  Crossdock item
     *    OPBNBR  -  Buyer number
     *    OPBNAM  -  Buyer name
     *    OPVNAM  -  Vendor name
     *    OPBRND  -  Brand
     *    OPLOT   -  Lot code item
     *    OPLTRK  -  Track by license
     *
     * Data structure
     *
DRY AD opdat3          ds
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhd3                 3      3
     D  opsty3                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum13                11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
     D  opnslt                37     37
     D  opxdck                38     38
     D  opbnbr                39     39
     D  opbnam                40     40
     D  opvnam                41     41
     D  opbrnd                42     42
     D  oplot                 43     43
     D  opltrk                44     44
     D  opten3               117    117
DRYaA*----------------------------------------------------------------
DRYaA*  *ITEMMNT  -  Item Maintenance options.
DRYaA*----------------------------------------------------------------
     *
     D opdat2          ds
     D  opstyp                 1      1
     D  opwhdp                 2      6
     D  opum1                  7      8
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n
     D dpCombo         s             20
     D logText         s            100
     D savsubcmd       s                   like($drisubcmd)
     D uxflag          s              1
     D kywhse          s                   like(pwhse)
     D  pWhse          s              3p 0
	    d  pitem          s             15
	    d  pType          s              1
	    d  pdesc          s             30
	    d  pedesc         s             80
	    d  pdsc3          s             40
	    d  pWhdp          s              5
	    d  pStyp          s              1
	    d  pDesg          s              5
	    d  pActv          s              2
	    d  pBld           s              2
	    d  pCat           s             10
	    d  pLtrk          s              1
	    d  pFlgd          s              1
	    d  poday          s              3p 0
	    d  pMflg          s              1
	    d  pMday          s              3p 0
	    d  pDday          s              3p 0
	    d  pUday          s              3p 0
	    d  pSlif          s              3p 0
	    d  pNday          s              3p 0
	    d  pPdsc          s             15
	    d  pUm1           s              2
	    d  pUm2           s              2
	    d  pUmq2          s              3p 0
	    d  pFlg1          s              1
	    d  pUm3           s              2
	    d  pUmq3          s              3p 0
	    d  pFlg2          s              1
	    d  pUlen          s              5p 2
	    d  pUwdt          s              5p 2
	    d  pUhgt          s              5p 2
	    d  pCube          s              7p 3
	    d  pSwgt          s              7p 2
	    d  pCwgt          s              1
	    d  pRg1c          s              3p 1
	    d  pRg2c          s              3p 1
	    d  puci           s              1
	    d  prcv           s              1
	    d  psel           s              1
	    d  pVen#          s             10p 0
	    d  pVenn          s             40
	    d  pVit#          s             15
	    d  pBuyr          s              3p 0
	    d  pBuyn          s             40
	    d  pLot           s              1
	    d  pBrdf          s              1
	    d  pBrnd          s             10
	    d  pFlgb          s              1
	    d  pCovr          s              1
	    d  pNrpk          s              3p 0
	    d  pRepl          s              5p 0
	    d  pMtie          s              4p 0
	    d  pMhi           s              2p 0
	    d  pmitem         s             15
	    d  pcitem         s             15
     D  pSubCmd        s             10
     d  pkirptp        s              1
     d  pkidisp        s             12
     d  pkiqty1        s              3p 0
     D*-- Field Indicators
     D* pSessIdInd                    5i 0
     D* pUserInd                      5i 0
     D* pDictInd                      5i 0
     D* pPgmInd                       5i 0
     D* pObjLocInd                    5i 0
     D* pSubCmdInd                    5i 0
     D* pWhseInd                      5i 0
	    d* pitemInd                      5i 0
	    d* pTypeInd                      5i 0
	    d* pdescInd                      5i 0
	    d* pdsc2Ind                      5i 0
	    d* pdsc3Ind                      5i 0
	    d* pWhdpInd                      5i 0
	    d* pStypInd                      5i 0
	    d* pDesgInd                      5i 0
	    d* pActvInd                      5i 0
	    d* pBldInd                       5i 0
	    d* pCatInd                       5i 0
	    d* pLtrkInd                      5i 0
	    d* pFlgdInd                      5i 0
	    d* podayInd                      5i 0
	    d* pMflgInd                      5i 0
	    d* pMdayInd                      5i 0
	    d* pDdayInd                      5i 0
	    d* pUdayInd                      5i 0
	    d* pSlifInd                      5i 0
	    d* pNdayInd                      5i 0
	    d* pPdscInd                      5i 0
	    d* pUm1Ind                       5i 0
	    d* pUm2Ind                       5i 0
	    d* pUmq2Ind                      5i 0
	    d* pFlg1Ind                      5i 0
	    d* pUm3Ind                       5i 0
	    d* pUmq3Ind                      5i 0
	    d* pFlg2Ind                      5i 0
	    d* pUlenInd                      5i 0
	    d* pUwdtInd                      5i 0
	    d* pUhgtInd                      5i 0
	    d* pCubeInd                      5i 0
	    d* pSwgtInd                      5i 0
	    d* pCwgtInd                      5i 0
	    d* pRg1cInd                      5i 0
	    d* pRg2cInd                      5i 0
	    d* puciInd                       5i 0
	    d* prcvInd                       5i 0
	    d* pselInd                       5i 0
	    d* pVen#Ind                      5i 0
	    d* pVennInd                      5i 0
	    d* pVit#Ind                      5i 0
	    d* pBuyrInd                      5i 0
	    d* pBuynInd                      5i 0
	    d* pLotInd                       5i 0
	    d* pBrdfInd                      5i 0
	    d* pBrndInd                      5i 0
	    d* pFlgbInd                      5i 0
	    d* pCovrInd                      5i 0
	    d* pNrpkInd                      5i 0
	    d* pReplInd                      5i 0
	    d* pMtieInd                      5i 0
	    d* pMhiInd                       5i 0
	    d* pMitemInd                     5i 0
	    d* pCitemInd                     5i 0


     D client          s             10
     D clientloc       s             10
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
     *      pWhse        Warehouse
     *      pCode        Department code
     *      pDesc        Description
     *      pMethod      Putaway method
     *
     *    Returned Parameters
     *      pmessage     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
650bAD  pSessId        s             40
650bAD  pUser          s             10
730aAD  pDict          s             10
650bAD  pPgm           s             20
     D  pObjLoc        s             10
     D  pparmStr1      s            999
     D  pparmStr2      s            999
     D  pparmStr3      s            999

     D*pditem1         pr                  extpgm('PDITEM1')
     D*-- Fields
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pObjLoc                      10
     D*-- SQL fields
     D* SQLState                      5
     D* FuncName                    139    varying
     D* SecificName                 128    varying
     D* MsgText                      70    varying

     D*pditem1         pi
     D*-- Fields
     D* pSessId                      40
     D* pUser                        10
     D* pDict                        10
     D* pPgm                         10
     D* pObjLoc                      10
     D* pSubCmd                      10
     D* pWhse                         3p 0
	    d* pitem                        15
	    d* pType                         1
	    d* pdesc                        30
	    d* pedesc                       80
	    d* pdsc3                        40
	    d* pWhdp                         5
	    d* pStyp                         1
	    d* pDesg                         5
	    d* pActv                         2
	    d* pBld                          2
	    d* pCat                         10
	    d* pLtrk                         1
	    d* pFlgd                         1
	    d* poday                         3p 0
	    d* pMflg                         1
	    d* pMday                         3p 0
	    d* pDday                         3p 0
	    d* pUday                         3p 0
	    d* pSlif                         3p 0
	    d* pNday                         3p 0
	    d* pPdsc                        15
	    d* pUm1                          2
	    d* pUm2                          2
	    d* pUmq2                         3p 0
	    d* pFlg1                         1
	    d* pUm3                          2
	    d* pUmq3                         3p 0
	    d* pFlg2                         1
	    d* pUlen                         5p 2
	    d* pUwdt                         5p 2
	    d* pUhgt                         5p 2
	    d* pCube                         7p 3
	    d* pSwgt                         7p 2
	    d* pCwgt                         1
	    d* pRg1c                         3p 1
	    d* pRg2c                         3p 1
	    d* puci                          1
	    d* prcv                          1
	    d* psel                          1
	    d* pVen#                        10p 0
	    d* pVenn                        40
	    d* pVit#                        15
	    d* pBuyr                         3p 0
	    d* pBuyn                        40
	    d* pLot                          1
	    d* pBrdf                         1
	    d* pBrnd                        10
	    d* pFlgb                         1
	    d* pCovr                         1
	    d* pNrpk                         3p 0
	    d* pRepl                         5p 0
	    d* pMtie                         4p 0
	    d* pMhi                          2p 0
	    d* pmitem                       15
	    d* pcitem                       15
     D*-- Field Indicators
     D* pSessIdInd                    5i 0
     D* pUserInd                      5i 0
     D* pDictInd                      5i 0
     D* pPgmInd                       5i 0
     D* pObjLocInd                    5i 0
     D* pSubCmdInd                    5i 0
     D* pWhseInd                      5i 0
	    d* pitemInd                      5i 0
	    d* pTypeInd                      5i 0
	    d* pdescInd                      5i 0
	    d* pdsc2Ind                      5i 0
	    d* pdsc3Ind                      5i 0
	    d* pWhdpInd                      5i 0
	    d* pStypInd                      5i 0
	    d* pDesgInd                      5i 0
	    d* pActvInd                      5i 0
	    d* pBldInd                       5i 0
	    d* pCatInd                       5i 0
	    d* pLtrkInd                      5i 0
	    d* pFlgdInd                      5i 0
	    d* podayInd                      5i 0
	    d* pMflgInd                      5i 0
	    d* pMdayInd                      5i 0
	    d* pDdayInd                      5i 0
	    d* pUdayInd                      5i 0
	    d* pSlifInd                      5i 0
	    d* pNdayInd                      5i 0
	    d* pPdscInd                      5i 0
	    d* pUm1Ind                       5i 0
	    d* pUm2Ind                       5i 0
	    d* pUmq2Ind                      5i 0
	    d* pFlg1Ind                      5i 0
	    d* pUm3Ind                       5i 0
	    d* pUmq3Ind                      5i 0
	    d* pFlg2Ind                      5i 0
	    d* pUlenInd                      5i 0
	    d* pUwdtInd                      5i 0
	    d* pUhgtInd                      5i 0
	    d* pCubeInd                      5i 0
	    d* pSwgtInd                      5i 0
	    d* pCwgtInd                      5i 0
	    d* pRg1cInd                      5i 0
	    d* pRg2cInd                      5i 0
	    d* puciInd                       5i 0
	    d* prcvInd                       5i 0
	    d* pselInd                       5i 0
	    d* pVen#Ind                      5i 0
	    d* pVennInd                      5i 0
	    d* pVit#Ind                      5i 0
	    d* pBuyrInd                      5i 0
	    d* pBuynInd                      5i 0
	    d* pLotInd                       5i 0
	    d* pBrdfInd                      5i 0
	    d* pBrndInd                      5i 0
	    d* pFlgbInd                      5i 0
	    d* pCovrInd                      5i 0
	    d* pNrpkInd                      5i 0
	    d* pReplInd                      5i 0
	    d* pMtieInd                      5i 0
	    d* pMhiInd                       5i 0
	    d* pMitemInd                     5i 0
	    d* pCitemInd                     5i 0
     D*-- SQL fields
     D* SQLState                      5
     D* FuncName                    139    varying
     D* SecificName                 128    varying
     D* MsgText                      70    varying

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.wrtsessl
      /copy qcopysrc,p.getclien

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

DRYa  /copy qcopysrc,id#dairyla
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

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

	        pitem = %xlate(xlower: xupper: pitem);
	        pmitem = %xlate(xlower: xupper: pmitem);
	        pcitem = %xlate(xlower: xupper: pcitem);
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

         // Determine DRI subcommand to use.

         $drisubcmd = ' ';
         pSubCmd = %xlate(xlower: xupper: pSubCmd);
         select;
           when pSubCmd = 'A';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYADD';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%ADD';
             endsl;
           when pSubCmd = 'C' or pSubCmd = 'U';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYCHG';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%CHANGE';
             endsl;
           when pSubCmd = 'D';
             select;
               when pObjLoc = 'FLDVALID';
                 $drisubcmd = '%VERIFYDEL';
               when pObjLoc = 'AFTERACT';
                 $drisubcmd = '%DELETE';
             endsl;
           other;
             $drisubcmd = '%' + pSubCmd;
         endsl;

750aA    // Moved from *INZSR - PWHSE is not populated at *INZSR
         // Get Item Maintenance options
         uxflag = *off;
         opcode = '*ITEMMNT';
         chain (pwhse: opcode) options;
         if %found(options);
DRYa       opdat2 = opdata;
           if opxdsc = 'Y';
             uxflag = *on;
           endif;
         endif;

         // Get Item Import field options
DRYaA    if client = dairyl;
DRYa       kywhse = *zeros;
DRYa       opcode = '*IMPITEM';
           chain (kywhse: opcode) options;
           if not %found(options);
DRYa       else;
DRYa         opdat3 = opdata;
DRYa       endif;
DRYa     endif;
750aA    // Moved above from *INZSR - PWHSE is not populated at *INZSR
         savsubcmd = $drisubcmd;

         // Initialize DRI fields.

         savever# = $itver#;
         clear $item;
         clear $item2;
         $itver# = savever#;

         //$slWhseu = *on;
         // Main entry form
         $itWhse = pWhse;
	        $ititem = %xlate(xlower: xupper: pitem);
         $iSession = pSessId;

         // item type
         if client = dairyl and
            opityp = 'Y';
           $ittypeu  = *off;
         else;
           $ittypeu  = *on;
	          $ittype = %xlate(xlower: xupper: ptype);
         endif;

         // alias and ssb only send a few fields
740aA    // breakdown needs to populate this also.
         if $ittype = 'A' or
740aA       $ittype = 'B' or
740aA       $ittype = 'R' or
            $ittype = 'S';
           $itmitemu = *on;
           $itmitem  = pmitem;
           if client = dairyl and
              opcitm = 'Y';
             $itcitemu  = *off;
           else;
             $itcitemu = *on;
             $itcitem  = pcitem;
           endif;

         endif;

         // pack description
         if client = dairyl and
            oppdsc = 'Y';
           $itpdscu  = *off;
         else;
           $itpdscu  = *on;
           $itpdsc  = ppdsc;
         endif;

         // description
         if client = dairyl and
            opdesc = 'Y';
           $itdescu  = *off;
           $ixdsc1u  = *off;
           $ixdsc2u  = *off;
         else;
           Select;
             when uxflag = '0';
               $itdescu  = *on;
               $itdesc  = pdesc;
             when uxflag = '1';
               $itdescu  = *on;
               $itdesc  = %subst(pedesc:1:30);
               $ixdsc1u  = *on;
               //$ixdsc1  = %trimr(pdsc2);
               $ixdsc1  = %subst(pedesc:1:40);
               $ixdsc2u  = *on;
               //$ixdsc2  = %trimr(pdsc3);
               $ixdsc2  = %subst(pedesc:41:40);
           endsl;
         endif;
         // alias and ssb don't load the following fields
         select;
           when $ittype = 'A';
           when $ittype = 'S';
           when $ittype = 'C';
           other;
             // department
             if client = dairyl and
                opwhd3 = 'Y';
               $itwhdpu  = *off;
             else;
	              $itWhdpu = *on;
	              $itWhdp = %xlate(xlower: xupper: pWhdp);
             endif;
             // Section
	            $itstypu = *on;
	            $itstyp = %xlate(xlower: xupper: pstyp);
             // Designation
             if client = dairyl and
                opdesg = 'Y';
               $itdesgu  = *off;
             else;
               $itdesgu  = *on;
	              $itdesg = %xlate(xlower: xupper: pdesg);
             endif;
             // Activity
             if client = dairyl and
                opactv = 'Y';
               $itactvu  = *off;
             else;
               $itactvu  = *on;
	              $itactv = %xlate(xlower: xupper: pactv);
             endif;
             // build code
             if client = dairyl and
                opbld = 'Y';
               $itbldu  = *off;
             else;
               $itbldu   = *on;
               $itbld   = pbld;
             endif;
             // Category
             $ifcatu  = *on;
	            $ifcat = %xlate(xlower: xupper: pcat);
             // tracking
             if client = dairyl and
                opltrk = 'Y';
               $imltrku  = *off;
             else;
               $imltrku  = *on;
               $imltrk  = pltrk;
             endif;

             // Date Information Tab
             // Date Sensitive
             if client = dairyl and
                opflgd = 'Y';
               $itflgdu  = *off;
             else;
               $itflgdu  = *on;
               $itflgd  = pflgd;
             endif;
             // days out
             $imodayu  = *on;
             $imoday  = poday;
             // Mfg Date flag
             if client = dairyl and
                opmflg = 'Y';
               $immflgu  = *off;
             else;
               $immflgu  = *on;
               $immflg  = pmflg;
             endif;
             // mfr days
             if client = dairyl and
                opmday = 'Y';
               $immdayu  = *off;
             else;
               $immdayu  = *on;
               $immday  = pmday;
             endif;
             // Dist Days
             if client = dairyl and
                opdday = 'Y';
               $imddayu  = *off;
             else;
               $imddayu  = *on;
               $imdday  = pdday;
             endif;
             // user Days
             if client = dairyl and
                opuday = 'Y';
               $imudayu  = *off;
             else;
               $imudayu  = *on;
               $imuday  = puday;
             endif;
             // shelf life days
             if client = dairyl and
                opslif = 'Y';
               $itslifu  = *off;
             else;
               $itslifu  = *on;
               $itslif  = pslif;
             endif;
             // notify days
             if client = dairyl and
                opnday = 'Y';
               $itndayu  = *off;
             else;
               $itndayu  = *on;
               $itnday  = pnday;
             endif;

             // physical information tab
             // pack description
             if client = dairyl and
                oppdsc = 'Y';
               $itpdscu  = *off;
             else;
               $itpdscu  = *on;
               $itpdsc  = ppdsc;
             endif;
             // normal UOM
             if client = dairyl and
                opum13 = 'Y';
               $itum1u  = *off;
             else;
               $itum1u   = *on;
	              $itum1 = %xlate(xlower: xupper: pum1);
             endif;
             // breaKdown 1 uom
             if client = dairyl and
                opum2 = 'Y';
               $itum2u  = *off;
             else;
               $itum2u   = *on;
	              $itum2 = %xlate(xlower: xupper: pum2);
             endif;
             // breaKdown 1 qty
             if client = dairyl and
                opumq2 = 'Y';
               $itumq2u  = *off;
             else;
               $itumq2u  = *on;
               $itumq2  = pumq2;
             endif;
             // breaKdown 1 entry allowed
             if client = dairyl and
                opflg1 = 'Y';
               $itflg1u  = *off;
             else;
               $itflg1u  = *on;
               $itflg1  = pflg1;
             endif;
             // breaKdown 2 uom
             if client = dairyl and
                opum3 = 'Y';
               $itum3u  = *off;
             else;
               $itum3u   = *on;
	              $itum3 = %xlate(xlower: xupper: pum3);
             endif;
             // breaKdown 2 qty
             if client = dairyl and
                opumq3 = 'Y';
               $itumq3u  = *off;
             else;
               $itumq3u  = *on;
               $itumq3  = pumq3;
             endif;
             // breaKdown 2 entry allowed
             if client = dairyl and
                opflg2 = 'Y';
               $itflg2u  = *off;
             else;
               $itflg2u  = *on;
               $itflg2  = pflg2;
             endif;
             // length
             if client = dairyl and
                opulen = 'Y';
               $itulenu  = *off;
             else;
               $itulenu  = *on;
               $itulen  = pulen;
             endif;
             // width
             if client = dairyl and
                opuwdt = 'Y';
               $ituwdtu  = *off;
             else;
               $ituwdtu  = *on;
               $ituwdt  = puwdt;
             endif;
             // height
             if client = dairyl and
                opuhgt = 'Y';
               $ituhgtu  = *off;
             else;
               $ituhgtu  = *on;
               $ituhgt  = puhgt;
             endif;
             // cube
             if client = dairyl and
                opcube = 'Y';
               $itcubeu  = *off;
             else;
               $itcubeu  = *on;
               $itcube  = pcube;
             endif;
             // shipping weight
             if client = dairyl and
                opswgt = 'Y';
               $itswgtu  = *off;
             else;
               $itswgtu  = *on;
               $itswgt  = pswgt;
             endif;
             // catch weight item
             if client = dairyl and
                opcwgt = 'Y';
               $itcwgtu  = *off;
             else;
               $itcwgtu  = *on;
               $itcwgt  = pcwgt;
             endif;
             // catch weight variances
             $imrg1cu  = *on;
             $imrg1c  = prg1c;
             $imrg2cu  = *on;
             $imrg2c  = prg2c;

             // UCI Information Tab
             // UCI endoding
             $ifucicdeu  = *on;
             $ifucicde   = puci;
             // UCI receiving method
             $ifrcvmthu  = *on;
             $ifrcvmth   = prcv;
             // UCI selection method
             $ifsltmthu  = *on;
             $ifsltmth   = psel;

             // Vendor/Buyer Information Tab
             // Vendor Number
             if client = dairyl and
                opven# = 'Y';
               $itven#u  = *off;
             else;
               $itven#u  = *on;
               $itven#  = pven#;
             endif;
             // Vendor name
             $imvnamu   = *on;
             $imvnam    = pvenn;
             // Vendor Item Number
             if client = dairyl and
                opvit# = 'Y';
               $itvit#u  = *off;
             else;
               $itvit#u  = *on;
	              $itvit# = %xlate(xlower: xupper: pvit#);
             endif;
             // buyer number
             $imbnbru   = *on;
             $imbnbr    = pbuyr;
             // buyer name
             $imbnamu   = *on;
             $imbnam    = pbuyn;
             // lot
             if client = dairyl and
                oplot = 'Y';
               $imlotu  = *off;
             else;
               $imlotu  = *on;
               $imlot   = plot;
             endif;
             // brand
             $ifbrdflgu  = *on;
             $ifbrdflg   = pbrdf;
             $imbrndu  = *on;
             $imbrnd   = pbrnd;

             // Selection Information Tab
             // Bulk Picks allowed
             if client = dairyl and
                opflgb = 'Y';
               $itflgbu  = *off;
             else;
               $itflgbu  = *on;
               $itflgb  = pflgb;
             endif;
             // Case overflow
             $ifcaseovfu  = *on;
             $ifcaseovf   = pcovr;
             // number of pick slots
             $imnrpku  = *on;
             $imnrpk  = pnrpk;
             // Repl Level
             if client = dairyl and
                oprepl = 'Y';
               $itreplu  = *off;
             else;
               $itreplu  = *on;
               $itrepl  = prepl;
             endif;


             // still need to figure out what to do with these
             // ODR slot - done in a different program
             $ifodrslotu  = *off;
             // repack stuff
             if ptype = 'R';
               //$kcdispu = *on;
               //$kcqty1u = *on;
               // get quantities from array created in IT116
               //$kcqty2u = *on;
               //$kcqty3u = *on;
               $kidispu = *on;
               $kidisp = pkidisp;
               $kirptpu = *on;
               $kirptp = pkirptp;
               $kiqty1u = *on;
               $kiqty1 = pkiqty1;
               $kiqty2u = *off;
               $kiqty3u = *off;
             endif;
             // tie - mfg tie - this may change
             if client = dairyl and
                optie = 'Y';
               $imtieu  = *off;
             else;
               $imtieu   = *on;
               $imtie   = pmtie;
             endif;
             // tie - mfg high- this may change
             if client = dairyl and
                ophigh = 'Y';
               $imhighu  = *off;
             else;
               $imhighu  = *on;
               $imhigh  = pmhi;
             endif;
         endsl;

         $dricommand = '*ITEM';
         $drisys2upd = 'D';
         $driprogram = #pgm;
         $dridata = $item;
         $dridata2 = $item2;

         // Call DRI program.

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata: $dridata2);

         $item = $dridata;
         $item2 = $dridata2;

         select;
           when %error;
             pMessage= 'Error occured calling DRIITEM '
                     + '('
                     + %trimr(#Job) + '/'
                     + %trimr(#JobNbr) + '/'
                     + %trimr(#user)
                     + ')';
           when $drireturn <> '*OK';
             pMessage= 'Error: ' + %trim($drireturn) + ' - ' + $drimessage;
           other;
             if %subst($drisubcmd:2:1) <> 'V';
               logText = 'dricmd:' + %trimr($dricommand) + ','
                       + 'drisub:' + %trimr(savsubcmd) + ','
                       + 'itwhse:' + %char($itwhse) + ','
                       + 'ititem:' + %trimr($ititem);
               wrtsesslog(pSessId: #pgm: dpCombo: pUser: logText);
             endif;
         endsl;

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

750aA    // Moved getting the options value because pwhse is not
750aA    // populated at this point.


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
                  + 'pItem:' + %trimr(pItem) + ', '
                  + 'pMessage:' + %trimr(pMessage);

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
     *  wrtDebugError  Write out debug error
     *----------------------------------------------------------------

      /free
       begsr wrtDebugError;

         bdtype = 'ERROR';

         bdvalues = pMessage;

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

           when parmName = 'ITWHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'ITITEM';
             pitem = %trim(parmValue);

           when parmName = 'ITTYPE';
             ptype = %trim(parmValue);

           when parmName = 'ITDESC';
             pdesc = %trim(parmValue);

           when parmName = 'CALCULA006';
             pedesc = %trim(parmValue);

           when parmName = 'ITWHDP';
             pwhdp = %trim(parmValue);

           when parmName = 'ITSTYP';
             pstyp = %trim(parmValue);

           when parmName = 'ITDESG';
             pdesg = %trim(parmValue);

           when parmName = 'ITACTV';
             pactv =  parmValue;

           when parmName = 'ITBLD';
             pbld =  parmValue;

           when parmName = 'CALCULA033';
             pcat   = %trim(parmValue);

           when parmName = 'CALCULA053';
             pltrk  = %trim(parmValue);

           when parmName = 'ITFLGD';
             pflgd =  parmValue;

           when parmName = 'CALCULA054';
             if parmValue = '';
               parmValue = '0';
             endif;
             poday =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA041';
             pmflg =  parmValue;

           when parmName = 'CALCULA044';
             if parmValue = '';
               parmValue = '0';
             endif;
             pmday =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA042';
             if parmValue = '';
               parmValue = '0';
             endif;
             pdday =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA043';
             if parmValue = '';
               parmValue = '0';
             endif;
             puday =  %dec(parmValue: 3: 0);

           when parmName = 'ITSLIF';
             if parmValue = '';
               parmValue = '0';
             endif;
             pslif =  %dec(parmValue: 3: 0);

           when parmName = 'ITNDAY';
             if parmValue = '';
               parmValue = '0';
             endif;
             pnday =  %dec(parmValue: 3: 0);

           when parmName = 'ITPDSC';
             ppdsc  = %trim(parmValue);

           when parmName = 'ITUM1';
             pum1   = %trim(parmValue);

           when parmName = 'ITUM2';
             pum2   = %trim(parmValue);

           when parmName = 'ITUMQ2';
             if parmValue = '';
               parmValue = '0';
             endif;
             pumq2 =  %dec(parmValue: 3: 0);

           when parmName = 'ITFLG1';
             pflg1  = %trim(parmValue);

           when parmName = 'ITUM3';
             pum3   = %trim(parmValue);

           when parmName = 'ITUMQ3';
             if parmValue = '';
               parmValue = '0';
             endif;
             pumq3 =  %dec(parmValue: 3: 0);

           when parmName = 'ITFLG2';
             pflg2  = %trim(parmValue);

           when parmName = 'ITULEN';
             if parmValue = '';
               parmValue = '0';
             endif;
             pulen =  %dec(parmValue: 5: 2);

           when parmName = 'ITUWDT';
             if parmValue = '';
               parmValue = '0';
             endif;
             puwdt =  %dec(parmValue: 5: 2);

           when parmName = 'ITUHGT';
             if parmValue = '';
               parmValue = '0';
             endif;
             puhgt =  %dec(parmValue: 5: 2);

           when parmName = 'ITCUBE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pcube =  %dec(parmValue: 7: 3);

           when parmName = 'ITSWGT';
             if parmValue = '';
               parmValue = '0';
             endif;
             pswgt =  %dec(parmValue: 7: 2);

           when parmName = 'ITCWGT';
             pcwgt  = %trim(parmValue);

           when parmName = 'CALCULA045';
             if parmValue = '';
               parmValue = '0';
             endif;
             prg1c =  %dec(parmValue: 3: 1);

           when parmName = 'CALCULA046';
             if parmValue = '';
               parmValue = '0';
             endif;
             prg2c =  %dec(parmValue: 3: 1);

           when parmName = 'CALCULA035';
             puci   = %trim(parmValue);

           when parmName = 'CALCULA036';
             prcv   = %trim(parmValue);

           when parmName = 'CALCULA037';
             psel   = %trim(parmValue);

           when parmName = 'ITVEN#';
             if parmValue = '';
               parmValue = '0';
             endif;
             pven# =  %dec(parmValue: 10: 0);

           when parmName = 'CALCULA050';
             pvenn  = %trim(parmValue);

           when parmName = 'ITVIT#';
             pvit#  = %trim(parmValue);

           when parmName = 'CALCULA048';
             if parmValue = '';
               parmValue = '0';
             endif;
             pbuyr =  %dec(parmValue: 3: 0);

           when parmName = 'CALCULA049';
             pbuyn  = %trim(parmValue);

           when parmName = 'CALCULA052';
             plot   = %trim(parmValue);

           when parmName = 'CALCULA038';
             pbrdf  = %trim(parmValue);

           when parmName = 'CALCULA051';
             pbrnd  = %trim(parmValue);

           when parmName = 'ITFLGB';
             pflgb  = %trim(parmValue);

           when parmName = 'CALCULA034';
             pcovr  = %trim(parmValue);

           when parmName = 'CALCULA047';
             if parmValue = '';
               parmValue = '0';
             endif;
             pnrpk =  %dec(parmValue: 3: 0);

           when parmName = 'ITREPL';
             if parmValue = '';
               parmValue = '0';
             endif;
             prepl =  %dec(parmValue: 5: 0);

           when parmName = 'CALCULA039';
             if parmValue = '';
               parmValue = '0';
             endif;
             pmtie =  %dec(parmValue: 4: 0);

           when parmName = 'CALCULA040';
             if parmValue = '';
               parmValue = '0';
             endif;
             pmhi  =  %dec(parmValue: 2: 0);

           when parmName = 'CALCULA031';
             pmitem = %trim(parmValue);

           when parmName = 'CALCULA032';
             pcitem = %trim(parmValue);

           when parmName = 'CALCULA056';
             pkirptp= %trim(parmValue);

           when parmName = 'CALCULA057';
             pkidisp= %trim(parmValue);

           when parmName = 'CALCULA058';
             if parmValue = '';
               parmValue = '0';
             endif;
             pkiqty1= %dec(parmValue: 3: 0);

           //when parmName = 'OPRFWC';
             //puhgt = %trim(parmValue);

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
