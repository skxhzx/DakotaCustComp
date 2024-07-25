417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RH155ST     Stage - Route export - Transaction
     *  09 February 2011
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
640 A*    02/09/11  DAS  6.40
     *      - Created.
640aA*    09/18/12  MLB  6.40a
     *      - Enh: File EXPSORDD changed, fields added. Pgm recompiled.
     *
650aA*    09/05/13  DAS  6.50a
     *      - Revised to do nothing if transaction already found
     *        in EXPSORDT file. Situation occured where voice wrote
     *        transaction to EXPS files. At the same time a user was
     *        working with the Route in TruckBuilder and closed the
     *        same transaction, thus creatint a second batch of
     *        records for the transaction in the EXPS file. This
     *        change should prevent this situation.
     *
650bA*    12/04/13  DAS  6.50b
     *      - Moved call to OR633 from WriteORDL to WriteORDP.
     *
650cA*    01/14/14  DAS  6.50c
     *      - 650a changes wasn't good enough and a dup still slipped
     *        through.
     *      - Created data area RH155ST (7.0).
     *      - Revised to grab data area. If data area trn# matches
     *        sent trn# then get out. Otherwise, write sent trn#
     *        to data area.
     *
650dA*    06/10/14  DAS  6.50d
     *      - Revised to update data area only after it is determined
     *        the transaction will be processed by this program.
     *
650eA*    12/15/14  DAS  6.50e
     *      - Added BFCLOG logic
     *
720aA*    08/24/18  DAS  7.20a
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Custom Revisions - Cheney Brothers
     *
CBIcA*    01/07/09  DAS  CBIc
     *      - Revised to send the special pallet id that is barcoded
     *        on the BIGPALCB label in the OEPDSP field in the
     *        expfordp file.
     *
CBIdA*    03/11/11  DAS  CBId
     *      - Revised to set OELBOX to 1 if that ord/seq/item is not
     *        on any open (1,2,3,8) transactions.
     *
CBIeA*    03/24/11  DAS  CBIe
     *      - Revised to only send 'O' and 'B' records in EXPSORDL.
     *
CBIfA*    10/22/11  DAS  CBIf
     *      - Revised to call writeORDC from within writeORDL.
     *      - Revised writeORDC to use key based on label#.
     *      - These changes have been made because writeORDC grabbed
     *        all the ORDC records for the transaction. But at Cheney
     *        some of the ORDC records could be tied to 'M' records
     *        that are not written to the EXPSORDL file.
     *      - Added parm $pCmd to be used by RH155S
     *      - Revised to only process gen 2 transactions that have
     *        catchweights when command *GEN2CW is sent in. Because
     *        of timing issues, capturing catchweights with 'M'
     *        records and not exporting 'M' records, we wait to
     *        export gen 2 cw transactions at the very end when
     *        RH155S is run.
     *
CBI1A*    04/26/12  CBI1-JGD (This change applies to RIV only)
     *      - Added logic to process "BRAKERS" routes which is
     *        created differently than the rest of the Truck
     *        Builder routes. "BREAKERS" route processing is
     *        conformed of several routes with the same route
     *        number, but different route ids. Unlike the rest
     *        of the routes that are one route number and one
     *        route id only. Without this change SAP would'nt
     *        be able to process "BRAKERS" routes, now these
     *        routes are all grouped into a single batch id
     *        like the rest of the routes. Before each of the
     *        "BREAKERS" routes had its own unique batch id.
     *        making it a non SAP proccessable. NOTE: SOME
     *        OF THIS LOGIC WAS COMMENTED OUT LATER (See
     *        Comment "The logic below was commented out on 6/01/12")
     *
CBIgA*    06/05/13  DAS  CBIg
     *      - Needed to change one of the above 'commented out'
     *        comments needed to be switched to a /free comment.
      *
CBI2A *    08/15/13  CBI2-JGD
      *      - Modify the logic that builds up the pallet # into
      *        file Expsordp/oepdsp field.
     *
CBIhA*    12/12/14  DAS  CBIh
     *      - Reversed CBIe change, now writing 'M' recs to EXPSORDL.
CBI5A*    01/12/16  MLB  CBI5
     *      - Revised pgm to send route id + pallet id in OEPDSP fld.
     *        Needed for Punta Gorda, Ocala, Riviera.
     *
CBI7A*    10/31/17  MLB  CBI7
     *      - Revised pgm to send route id + pallet id in OEPDSP fld.
     *        Needed for NC & MLK.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

CBIfAFordc      if   e           k disk    rename(ocrec:ocrec1)
     Fordc2     if   e           k disk
     Fordd      if   e           k disk
     Fordh      if   e           k disk
     Fordexpdte1if   e           k disk
     Fordp5     if   e           k disk
     Fordt1     uf   e           k disk
     Flabel90   if   e           k disk
CBIfAFlabel7    if   e           k disk
CBIfAFlabel11   if   e           k disk    rename(lbrec:lbrec11)
     Fpirtran   if   e           k disk
     Frtehed    if   e           k disk
CBI1AFordh3     if   e           k disk    rename(ohrec:ohrec2)
     Fexpsordc  o    e           k disk
     Fexpsorde  o    e           k disk
     Fexpsordl  o    e           k disk
     Fexpsordp  o    e           k disk
     Fexpsordt  o    e           k disk
650aAFexpsordt1 if   e           k disk    rename(oetrec:oetrec1)
650aAF                                     prefix(t1_)
650eAFbfclog    o    e           k disk

     *----------------------------------------------------------------
     *  Client id's
     *----------------------------------------------------------------

CBIcA /copy qcopysrc,id#cheney
CBIcA /COPY QCOPYSRC,ID#cheneyo
CBIcA /COPY QCOPYSRC,ID#cheneyr
CBI5A /COPY QCOPYSRC,ID#cheneyp

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D $pwhse3S        s              3s 0
     D batId           s             11
CBI1AD batchid         s             11
     D client          s             10
     D clientLoc       s             10
CBIfAD cmdGen2cw       s               n
CBIdAD count           s              9  0
     D first           s               n
     D forevr          s               n
CBIfAD gen2cw          s               n
720aAD gGen            s              1  0
720aAD gGenTruck       s               n
720aAD gGenMerge       s               n
720aAD gGenOverflow    s               n
720aAD gGenTruckExt    s               n
720aAD gPltId          s                   like(lbpal#)
     D kyord           s                   like(ohord)
650eAD logging         s               n
     D rtnCode         s             10
     D rtnMessage      s            200
CBIfAD saveLbl#        s                   like(lblbl#)
     D stamp           s               z
     D stampUC         s               z
     D temp2a          s              2
CBI2AD temp4a          s              4
     D temp7a          s              7

     *----------------------------------------------------------------
     * Data areas
     *----------------------------------------------------------------

     D cbiPrefix       s              2    dtaara(PREFIX)
650cAD lastTrn#        s              7  0 dtaara(RH155ST)

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

640aAD or633           pr                  extpgm('OR633')
      * Input
     D   pWhse                        3p 0
     D   pRteId                       5
     D   pLbl#                        7p 0

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pTrn#       Transaction number
CBIfA*      pCmd        *GEN2CW  -  Export Gen 2 tran w/catchweights.
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $ptrn#            7 0
CBIfAC                   parm                    $pCmd            10

     c                   eval      $pwhse3S = $pwhse

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

650eAc                   eval      logging = *on

CBI1A
CBI1A*  Find if BREAKERS batch id has been already picked.
CBI1A
      * The logic below was commented out on 6/01/12

CBI1AC*    $ptrn#        chain     pirtran                            79
CBI1AC*                  if        *in79 = *off
CBI1AC*                  movel     ptrtpo        rteid#            5
CBI1AC*    keyoh         chain     ordh3                              79
CBI1AC*                  if        *in79 = *off
CBI1AC*                  if        ohtruk = 'BREAKERS' or
CBI1AC*                            %subst(rhrte:3:2) = '75'
CBI1AC*                  goto      define
CBI1AC*                  endif
CBI1AC*                  endif

CBI1AC*    keyoh         chain     rtehed                             79
CBI1AC*>                 if        *in79 = *off and
CBI1AC*>                           %subst(rhrte:3:2) = '75'
CBI!A
CBI1AC*                  if        *in79 = *on
CBI1AC*                  goto      bypassdefine
CBI1AC*                  if        %subst(rhrte:3:2) <> '75'
CBI1AC*                  goto      bypassdefine
CBI1AC*                  endif
CBI1AC*                  endif

CBI1AC*    define        tag
CBI1AC*    *DTAARA       define    breakers      batchid
CBI1AC*    *lock         in        batchid
CBI1AC*                  endif
CBI1AC     bypassdefine  tag

      /free

         *inlr = *on;

650aA    // Protect against creating duplicate batch for tran.
650aA    // If tran found in EXPSORDT, get out.
650aA
650aA    chain ($pwhse: $ptrn#) expsordt1;
650aA    if %found(expsordt1);
650eA      blgtext = 'Tran found in EXPSORDTL';
650eA      exsr WrtLogSkip;
650aA      return;
650aA    endif;

650cA    // More protection. If sent trn# matches data area trn#
650cA    // then get out.
650cA
650dD    //in(e) *lock lastTrn#;
650dM    in(e) lastTrn#;
650cA    if %error;
650eA      blgtext = 'Error getting RH155ST data area';
650eA      exsr WrtLogSkip;
650cA      return;
650cA    endif;
650cA    if lastTrn# = $ptrn#;
650dD      //out lastTrn#;
650eA      blgtext = 'Tran matches RH155ST data area tran';
650eA      exsr WrtLogSkip;
650cA      return;
650cA    endif;
650dD    //lastTrn# = $ptrn#;
650dD    //out lastTrn#;

CBIfA    cmdGen2cw = *off;
CBIfA    if %parms >=3;
CBIfA      if $pCmd = '*GEN2CW';
CBIfA        cmdGen2cw = *on;
CBIfA      endif;
CBIfA    endif;

         // Get client id

         getclient(client: clientLoc);
CBIfA
CBIfA    // For Cheney, only process gen 2 trans that have catchweights
CBIfA    // when command *GEN2CW has been sent from RH155S.
CBIfA
CBIfA    if client = cheney;
CBIfA      exsr GetGen;
CBIfA      select;
CBIfA        when cmdGen2CW and not gen2cw;
650eA          blgtext = 'cmdGen2CW and not gen2cw';
650eA          exsr WrtLogSkip;
CBIfA          return;
CBIfA        when not cmdGen2CW and gen2cw;
650eA          blgtext = 'not cmdGen2CW and gen2cw';
650eA          exsr WrtLogSkip;
CBIfA          return;
CBIfA      endsl;
CBIfA    endif;

650dA    // Update last transaction data area
650dA
650dA    in(e) *lock lastTrn#;
650dA    if not %error;
650dA      lastTrn# = $ptrn#;
650dA      out lastTrn#;
650dA    endif;

CBI1M /end-free

CBI1AC*>                 if        ohtruk = '$REAKERS' and
CBI1AC*>                           batchid <> *blanks
CBI1AC*>                 eval      batid = batchid
CBI1AC*>                 goto      bypassbatchid
CBI1AC*>                 endif

CBI1M /free

         // Get batch id

         monitor;
           GetBatId($pWhse: 'EXPSELTRAN': 'W':
                    batId: rtnCode: rtnMessage);
         on-error;
           rtnCode = '*ERROR';
         endmon;

         if rtnCode <> '*OK';
650eA      blgtext = 'Error getting batid ('
650eA              + %trim(rtnCode) + ' - ' + %trim(rtnMessage)
650eA              + ')';
650eA      exsr WrtLogSkip;
           return;
         endif;
CBI1M /end-free

CBI1AC     bypassbatchid tag

CBI1M /free

         // Get employee number for transaction.

         chain ($ptrn#) pirtran;
         if  not %found(pirtran);
            ptemp# = 0;
            ptrtpo = ' ';
         endif;

         // Get customer route number for transaction.

         chain ($pwhse: ptrtpo) rtehed;
         if  not %found(rtehed);
            rhrte = ' ';
         endif;

CBIcA    // For Cheney, get pallet id prefix characters.
CBIcA
CBIcA    if client = cheney;
CBIcA      in(e) cbiPrefix;
CBIcA      if %error;
CBIcA        cbiPrefix = '@@';
CBIcA      endif;
CBIcA    endif;

         // Write records for transaction to export files.
         // Note, ORDH/D are not included in this program.
         // They are done separately in RH155SH.

         exsr writeORDT;
         exsr writeORDL;
CBIfA    if client <> cheney;
           exsr writeORDC;
CBIfA    endif;
         exsr writeORDE;
         exsr writeORDP;

         // Set batch record to Ready status

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

CBIgM   // The logic below was commented out on 6/01/12

CBI1A    // if ohtruk  = 'BREAKERS' or
CBI1A    //              %subst(rhrte:3:2) = '75';
CBI1A    // if batchid = *blanks;
CBI1A    //    batchid = batid;
CBI1A    //    out       batchid;
CBI1A    //    else;
CBI1A    //    out       batchid;
CBI1A    //    endif;
CBI1A    //    endif;

         return;
      /end-free


     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *   Define partial key for Label90 file.

     C     keylb90       klist
     C                   kfld                    $pwhse3S
     C                   kfld                    $ptrn#
CBIfA*
CBIfA*   Define key for Label7
CBIfA*
CBIfAC     keylb7        klist
CBIfAC                   kfld                    $ptrn#
CBIfA*
CBIfA*   Define key for ORDC2
CBIfA*
CBIfAC     keyoc         klist
CBIfAC                   kfld                    oelwhs
CBIfAC                   kfld                    oelordid
CBIfAC                   kfld                    oelseq
CBIfAC                   kfld                    oelitm
CBIfAC                   kfld                    oellbl
500aA*
500aA*   Define full key for ORDD file.
500aA*
500aAC     keyoe         klist
500aAC                   kfld                    oewhse
500aAC                   kfld                    oeord
500aAC                   kfld                    oeseq#
500aAC                   kfld                    oeitem

     *   Define partial key for ORDP5 file

     C     keyorp5       klist
     C                   kfld                    lbrte
     C                   kfld                    lblbl#

     *   Define partial key for ORDT1 file

     C     keyot1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptrn#

     *   Define key for RteHed file.

     C     keyrh         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
JGAaA*
CBI1A*   Define key for Ordh3 file.
CBI1A*
      * The logic below was commented out on 6/01/12

CBI1AC*    keyoh         klist
CBI1AC*                  kfld                    $pwhse
CBI1AC*                  kfld                    rteid#

     C                   endsr

CBIfA*----------------------------------------------------------------
CBIfA*  GetGen       See if transaction is for generation 2
CBIfA*               and if it has any catchweights
CBIfA*----------------------------------------------------------------
CBIfA
CBIfAC     GetGen        begsr

     C                   eval      gen2cw = *off

     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7
     C                   if        %eof(label7)
     C                   leave
     C                   endif

720aAC                   eval      gPltId = lbpal#
720aAC                   exsr      GetGenInfo

720aDC**                 if        lbpal# < 20000
720aMC                   if        not gGenTruck
     C                   leave
     C                   endif

     C                   if        itcwgt = 'Y'
     C                   eval      gen2cw = *on
     C                   leave
     C                   endif

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  WriteORDC    Write ORDC records
     *               Code taken from RH155 with minor changes
     *----------------------------------------------------------------

     C     WriteORDC     begsr

CBIfAC                   if        client = cheney
CBIfAC     keyoc         setll     ordc
CBIfAC                   else
640aMC     keylb90       setll     ordc2
CBIfAC                   endif
     C                   dou       forevr <> forevr
CBIfAC                   if        client = cheney
CBIfAC     keyoc         reade     ordc                                   78
CBIfAC                   else
640aMC     keylb90       reade     ordc2                                  78
CBIfAC                   endif
     C                   if        *in78
     C                   leave
     C                   endif

     C                   clear                   oecrec

640aAC                   eval      oecrteid = ptrtpo
640aAC                   eval      oecrte   = rhrte
640aAC                   eval      kyord = ocord
640aAC                   exsr      zzzGetORDH
640aAC                   eval      oecordid = ocord
640aAC                   eval      oecord   = ohcord

     C                   eval      oecwhs = ocwhse
     C                   eval      oecosq = ocseq#
     C                   eval      oecitm = ocitem
     C                   eval      oecseq = ocseq
409 AC                   eval      oeclbl = oclbl#
409 AC                   eval      oectrn = octran
     C                   eval      oecwgt = occwgt

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oecbatid = batId
640aAC                   eval      oecstatus = 'R'
640aAC                   eval      oecststs = stamp
640aAC                   eval      oecstsuc = stampuc
640aAC                   eval      oecaddts = stamp
640aAC                   eval      oecadduc = stampuc

     C                   write     oecrec

     C                   enddo

     C                   endsr

CBIfA*----------------------------------------------------------------
CBIfA*  WriteORDC2   Write ORDC records for corresponding label #.
CBIfA*----------------------------------------------------------------
CBIfA
CBIfAC     WriteORDC2    begsr

     C                   eval      saveLbl# = oellbl

     C     saveLbl#      setll     label11
     C                   dou       forevr <> forevr
     C     saveLbl#      reade     label11
     C                   if        %eof(label11)
     C                   leave
     C                   endif

     C                   if        lbrte <> oelrteid
     C                   iter
     C                   endif

     C                   eval      oellbl = lblbl#
     C                   exsr      writeORDC

     C                   enddo

     C                   eval      oellbl = saveLbl#

     C                   endsr

     *----------------------------------------------------------------
     *  WriteORDE    Write ORDE records
     *               Code taken from RH155 with minor changes
     *----------------------------------------------------------------

     C     WriteORDE     begsr

640aMC     keylb90       setll     ordexpdte1
500 AC                   dou       forevr <> forevr
640aMC     keylb90       reade     ordexpdte1
640aMC                   if        %eof(ordexpdte1)
500 AC                   leave
640aMC                   endif

500aAC     keyoe         chain     ordd
500aAC                   if        not %found(ordd)
500aAC                   eval      odor2 = 0
500aAC                   endif

500 AC                   clear                   oeerec

640aAC                   eval      oeerteid = ptrtpo
640aAC                   eval      oeerte   = rhrte
640aAC                   eval      kyord = oeord
640aAC                   exsr      zzzGetORDH
640aAC                   eval      oeeordid = oeord
640aAC                   eval      oeeord   = ohcord

500 AC                   eval      oeewhs = oewhse
500aA*
500aA*    Send Host actual sequence number if sent.
500aAC                   if        odor2 > 0
500aAC                   eval      oeeseq = odor2
500aAC                   else
500 AC                   eval      oeeseq = oeseq#
500aAC                   endif
580 AC                   eval      oeeitm = oeitem
500 AC                   eval      oeetrn = oetran
500 AC                   eval      oeelbl = oelbl#
500 AC                   eval      oeedte = oedate

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oeebatid = batId
640aAC                   eval      oeestatus = 'R'
640aAC                   eval      oeeststs = stamp
640aAC                   eval      oeestsuc = stampuc
640aAC                   eval      oeeaddts = stamp
640aAC                   eval      oeeadduc = stampuc

500 AC                   write     oeerec

500 AC                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  WriteORDL    Write ORDL records
     *               Code taken from RH155 with minor changes
     *----------------------------------------------------------------

     C     WriteORDL     begsr

640aMC     keylb90       setll     label90
510cAC                   dou       forevr <> forevr
640aMC     keylb90       reade     label90
640aMC                   if        %eof(label90)
510cAC                   leave
640aAC                   endif
CBIeA
CBIeA*  For Cheney, only write O and B records.
CBIhA*  and M records.
CBIeA
CBIeMC                   if        client = cheney
CBIeMC                   if        lbtype <> 'O' and lbtype <> 'B'
CBIhAC                             and lbtype <> 'M'
CBIeAC                   iter
CBIeAC                   endif
CBIeAC                   endif

650bD ** Call OR633 to synch ORDP with qty picked.
650bD **
650bDC**                 call      'OR633'
650bDC**                 parm      lbwhse        oWhse             3 0
650bDC**                 parm      lbrte         oRtid             5
650bDC**                 parm      lblbl#        oLbl#             7 0

510cAC                   clear                   oelrec

640aAC                   eval      oelrteid = lbrte
640aAC                   eval      oelrte   = rhrte
640aAC                   eval      kyord = lbord
640aAC                   exsr      zzzGetORDH
640aAC                   eval      oelordid = lbord
640aAC                   eval      oelord   = ohcord

510cAC                   eval      oelwhs = lbwhse
640aMC                   eval      oelseq = lbseq
510cAC                   eval      oelitm = lbitem
510cAC                   eval      oellbl = lblbl#
510cAC                   eval      oeltyp = lbtype
510dAC                   eval      oeldsp = lbdisp
510cAC                   eval      oeltrn = lbtrn#
510cAC                   eval      oelumt = lbutyp
510cAC                   eval      oelalc = lbqalc
640aAC                   select
640aAC                   when      lbutyp = 'N'
640aMC                   eval      oelqp1 = lbqpck
640aAC                   when      lbutyp = '1'
640aAC                   eval      oelqp2 = lbqpck
640aAC                   when      lbutyp = '2'
640aAC                   eval      oelqp3 = lbqpck
640aAC                   endsl
510dA*
510dAC                   call      'GETPALLET'
510dAC                   parm      lbwhse        $gwhse            3 0
510dAC                   parm      lbrte         $grtid            5
510dAC                   parm      'O'           $gtype            1
510dAC                   parm      lbpal#        $gplid            7 0
510dAC                   parm                    $gpal#            7 0
510dAC                   parm                    $gtzon            6
510dAC                   parm                    $gpzon            6
510dAC                   parm                    $gszon            6
510dAC                   parm                    $gcomp            1
510dAC                   parm                    $ggen             1 0
510dAC                   parm                    $gtruk           10
510dAC                   parm                    $gunld            2 0
510dAC                   parm                    $grow             2 0
510dAC                   parm                    $gcol             1 0
510dAC                   parm                    $gstp1            2 0
510dAC                   parm                    $gstp2            2 0
510dAC                   parm                    $gpcs             5 0
510dAC                   parm                    $gcube            7 3
510dAC                   parm                    $gswgt            9 2
510dAC                   parm                    $gbcnt            1 0
510dAC                   parm                    $gflag            1
510dAC                   parm                    $glbl#            7 0
510dAC                   parm                    $gtrn#            7 0
510dAC                   parm                    $greturn          8
510dA*
510dAC                   eval      oelpal = $gpal#

CBIdAC                   if        client = cheney
CBIdAC                   exsr      zzzSetBox
CBIdAC                   else
640aAC                   eval      oelbox = 0
CBIdAC                   endif

640aAC                   eval      oelemp = ptemp#

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oelbatid = batId
640aAC                   eval      oelstatus = 'R'
640aAC                   eval      oelststs = stamp
640aAC                   eval      oelstsuc = stampuc
640aAC                   eval      oeladdts = stamp
640aAC                   eval      oeladduc = stampuc

510cAC                   write     oelrec

CBIfA*   For Cheney, we grab ORDC recs by label number, not tran#.
CBIfA
CBIfAC                   if        client = cheney
CBIfAC                   exsr      writeORDC
CBIfAC                   endif
CBIfA
CBIfA*   For Cheney, when working with a gen 2 CW tran we do an
CBIfA*   extra step of getting any ORDC recs associated with a
CBIfA*   corresponding 'M' record.
CBIfA
CBIfAC                   if        client = cheney and cmdGen2CW
CBIfAC                   exsr      writeORDC2
CBIfAC                   endif

510cAC                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  WriteORDP    Write ORDP records
     *               Code taken from RH155 with minor changes
     *----------------------------------------------------------------

     C     WriteORDP     begsr
640aAC                   eval      first = *on

640aA*  ORDP doesn't have tran#, so we read through the label records.

640aMC     keylb90       setll     label90
510hAC                   dou       forevr <> forevr
640aMC     keylb90       reade     label90
640aMC                   if        %eof(label90)
510hAC                   leave
640aMC                   endif

650bA*  Call OR633 to synch ORDP with qty picked.
650bA
650bAC                   call      'OR633'
650bAC                   parm      lbwhse        oWhse             3 0
650bAC                   parm      lbrte         oRtid             5
650bAC                   parm      lblbl#        oLbl#             7 0

640aA*    Then we read the ORDP record for the label.

640aAC     keyorp5       setll     ordp5
640aAC                   dou       forevr <> forevr
640aAC     keyorp5       reade     ordp5
640aAC                   if        %eof(ordp5)
640aAC                   leave
640aAC                   endif
510gA*
510gA*      Initialize record
510gA*
510gAC                   clear                   oeprec
510gA*
510gA*      Move fields from label file to export file.
510gA*

640aAC                   eval      oeprteid = ptrtpo
640aAC                   eval      oeprte   = rhrte
640aAC                   eval      kyord = orpord
640aAC                   exsr      zzzGetORDH
640aAC                   eval      oepordid = orpord
640aAC                   eval      oepord   = ohcord

510gAC                   eval      oepwhs = orpwhs
640aMC                   eval      oeposq = orpsq#
510gAC                   eval      oepitm = orpitm
640aMC                   eval      oepupn = orpup#
510gAC                   eval      oeplbl = orplbl
640aMC                   eval      oeptyp = lbtype
640aMC                   eval      oepdsp = lbdisp
640aMC                   eval      oeptrn = lbtrn#
640aMC                   eval      oepumt = lbutyp
510gAC                   eval      oepseq = orpseq
510gAC                   eval      oepwgt = orpwgt
510iAC                   eval      oepcnt = orpcnt
510iAC                   eval      oepttl = orpttl
510iAC                   eval      oepscn = orpscn
510gA*
510gAC                   call      'GETPALLET'
510gAC                   parm      orpwhs        $gwhse            3 0
510gAC                   parm      orprid        $grtid            5
510gAC                   parm      'O'           $gtype            1
640aMC                   parm      lbpal#        $gplid            7 0
510gAC                   parm                    $gpal#            7 0
510gAC                   parm                    $gtzon            6
510gAC                   parm                    $gpzon            6
510gAC                   parm                    $gszon            6
510gAC                   parm                    $gcomp            1
510gAC                   parm                    $ggen             1 0
510gAC                   parm                    $gtruk           10
510gAC                   parm                    $gunld            2 0
510gAC                   parm                    $grow             2 0
510gAC                   parm                    $gcol             1 0
510gAC                   parm                    $gstp1            2 0
510gAC                   parm                    $gstp2            2 0
510gAC                   parm                    $gpcs             5 0
510gAC                   parm                    $gcube            7 3
510gAC                   parm                    $gswgt            9 2
510gAC                   parm                    $gbcnt            1 0
510gAC                   parm                    $gflag            1
510gAC                   parm                    $glbl#            7 0
510gAC                   parm                    $gtrn#            7 0
510gAC                   parm                    $greturn          8
510gA*
510gAC                   eval      oeppal = $gpal#
CBIcA
CBIcA*      For Cheney, put the special BIGPALCB barcode into oepdsp.
CBIcA
CBIcAC                   if        client = cheney
640aAC                   if        first
640aAC     keyrh         chain     rtehed
640aAC                   if        not %found(rtehed)
640aAC                   eval      rhrte = ' '
640aAC                   endif
640aAC                   eval      first = *off
640aAC                   endif
640aMC                   move      lbpal#        temp7a
CBI2MC                   movel     rhrte         temp4a
CBI2MC                   move      temp4a        temp2a
CBIcAC                   movel     temp2a        temp7a
CBI5AC                   select
CBI5D ***                when      clientloc = cbiocl
CBI5D ***                eval      oepdsp = temp7a
CBI5A*
CBI5MC                   when      clientloc = cbiocl
CBI5AC                             or clientloc = cbiriv
CBI5AC                             or clientloc = cbipntgr
CBI7AC                             or clientloc = cbigr
CBI7AC                             or clientloc = cbigo
CBI7AC                             or clientloc = cbist
CBI7AC                             or clientloc = cbimlk
CBI5AC                   eval      oepdsp = rhrtid
CBI5AC                                      + %trim(%editc(lbpal#: '4'))
CBI5A*
CBI5MC                   other
CBIcAC                   eval      oepdsp = cbiPrefix + temp7a
CBI5MC                   endsl
CBI5A*
CBIcAC                   endif

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oepbatid = batId
640aAC                   eval      oepstatus = 'R'
640aAC                   eval      oepststs = stamp
640aAC                   eval      oepstsuc = stampuc
640aAC                   eval      oepaddts = stamp
640aAC                   eval      oepadduc = stampuc

510hAC                   write     oeprec

640aAC                   enddo

510hAC                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  WriteORDT    Write ORDT records
     *               Code taken from RH155 with minor changes
     *----------------------------------------------------------------

     C     WriteORDT     begsr
213 A*
213 A*  Add order detail transaction recs to export file.
213 A*
640aMC     keyot1        setll     ordt1
213 AC                   dou       forevr <> forevr
640aMC     keyot1        reade     ordt1                                  78
213 AC                   if        *in78
213 AC                   leave
213 AC                   endif
640aD ** Get employee # for ORDT and export file.
640aDC**   $ptrn#        chain     pirtran                            77
640aDC**                 if        not *in77
640aDC**                 eval      otemp# = ptemp#
640aDC**                 endif
417aA*  Get quantity for ORDT and export file.
     *
640aMC     keylb90       setll     label90
417bAC                   dow       forevr = forevr
640aMC     keylb90       reade     label90                                77
     *
417bAC                   if        *in77
417bAC                   leave
417bAC                   endif
     *
417bAC                   if        lbtype <> 'O'  and
417bAC                             lbtype <> 'M'
417bAC                   iter
417bAC                   endif
     *
417bAC                   if        lbitem <> otitem  or
417bAC                             lbord <> otord  or
417bAC                             lbseq <> otseq
417bAC                   iter
417bAC                   endif
     *
417aAC                   if        lbutyp = 'N'
417bMC                   add       lbqpck        otpck1
417aAC                   endif
417aAC                   if        lbutyp = '1'
417bMC                   add       lbqpck        otpck2
417aAC                   endif
417aAC                   if        lbutyp = '2'
417bMC                   add       lbqpck        otpck3
417aAC                   endif
     *
417bAC                   enddo
640aAC                   eval      otemp# = ptemp#
417aAC                   update    otrec
PAK A*
213 AC                   clear                   oetrec

640aAC                   eval      oetrteid = ptrtpo
640aAC                   eval      oetrte   = rhrte
640aAC                   eval      kyord = otord
640aAC                   exsr      zzzGetORDH
640aAC                   eval      oetordid = otord
640aAC                   eval      oetord   = ohcord

213 AC                   eval      oetwhs = otwhse
213 AC                   eval      oetseq = otseq
213 AC                   eval      oetitm = otitem
213 AC                   eval      oettrn = ottrn#
417aAC                   eval      oetemp = otemp#
417aAC                   eval      oetpk1 = otpck1
417aAC                   eval      oetpk2 = otpck2
417aAC                   eval      oetpk3 = otpck3

640aAC                   exsr      zzzGetStamps
640aAC                   eval      oetbatid = batId
640aAC                   eval      oetstatus = 'R'
640aAC                   eval      oetststs = stamp
640aAC                   eval      oetstsuc = stampuc
640aAC                   eval      oetaddts = stamp
640aAC                   eval      oetadduc = stampuc

213 AC                   write     oetrec
PAK A*
213 AC                   enddo

     C                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetORDH     Get ORDH record
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetORDH    begsr
      /free

        if ohord <> kyord;
          chain ($pwhse: kyord) ordh;
          if not %found (ordh);
            clear ohcord;
          endif;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

CBIdA*----------------------------------------------------------------
CBIdA*  zzzSetBox      Set OELBOX value
CBIdA*                   0 = Detail line exists in open tran
CBIdA*                   1 = Detail line does exist in open tran
CBIdA*----------------------------------------------------------------
CBIdA
CBIdAc     zzzSetBox     begsr
      /free

        exec sql
          select count(*) into :count
          from label, pirtran
          where lbwhse = :oelwhs
            and lbrte  = :oelrteid
            and lbord  = :oelordid
            and lbseq  = :oelseq
            and lbitem = :oelitm
            and pttrn# = lbtrn#
            and ptstat in ('1','2','3','8');

        // If no open transactions found, set flag to 1.
        // Otherwise, set to 0.

        if sqlstt = sqlSuccess and count = 0;
          oelbox = 1;
        else;
          oelbox = 0;
        endif;

      /end-free
     c                   endsr

650eA*----------------------------------------------------------------
650eA*  wrtLogSkip    Write out skip log record
650eA*----------------------------------------------------------------
650eA
650eA /free
650eA  begsr wrtLogSkip;

         if not logging;
           leavesr;
         endif;

         blgaddpgm = #pgm;
         blgtype = 'SKIP';
         blgcallpgm = '';
         if %parms >=3;
           blgcallcmd = $pCmd;
         else;
           blgcallcmd = 'NotSent';
         endif;
         blgwhse = $pwhse;
         blgtrn# = $ptrn#;
         blglbl# = 0;
         blgrtid = '';

         blgaddts = %timestamp();
         blgstrts = blgaddts;
         blgsec = 0;

         blgtext = 'msg:' + blgtext;

         blgaddcusr = #curruser;
         blgaddjusr = #user;
         blgaddjob = #job;
         blgaddnbr = #jobnbr;

         write(e) blgrec;

       endsr;
      /end-free


720aA*----------------------------------------------------------------
720aA*  GetGenInfo    Get pallet generation info
720aA*----------------------------------------------------------------
720aAC     GetGenInfo    begsr
      /free

        gGen = 1;
        gGenTruck = *off;
        gGenMerge = *off;
        gGenOverflow = *off;
        gGenTruckExt = *off;

        select;

          when gPltId < 20000;
            gGen = 1;
            gGenTruck = *on;

          when gPltId < 30000;
            gGen = 2;
            gGenMerge = *on;

          when gPltId < 40000;
            gGen = 3;
            gGenMerge = *on;

          when gPltId < 50000;
            gGen = 4;

          when gPltId < 60000;
            gGen = 5;
            gGenTruck = *on;
            gGenOverflow = *on;

          when gPltId < 70000;
            gGen = 6;
            gGenTruck = *on;
            gGenTruckExt = *on;

        endsl;
      /end-free
     C                   endsr


