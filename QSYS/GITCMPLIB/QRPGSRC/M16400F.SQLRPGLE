      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M16400F     Return and Update Production Planning Data
      *  19 Dec 2014
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    12/19/14  KDE  7.00
     *      - Created.
700aA*    10/11/16  KDE  7.00a
     *      - Changed to update Mfg Line in RM file as well
710 A*    01/23/17  KDE  7.10
     *      - Changed to pass Primal and SubPrimal to DRIPROD
     *      - Call command in DRIPROD (wheresbom) to determine if
     *        BOM is dynamic or standard BOM
720 A*    01/20/18  KDE  7.20
     *      - Include call to command autowp to change auto WIP
     *        Work ORders when quantities from calling Work
     *        Orders either change or are deleted
     *      - Remove AUTOWP with mods 7.30s
720aA*    02/06/18  KDE  7.20a
     *      - Fix: Show Yellow even when released if not all RM Available
720bA*    10/26/18  KDE  7.20b
     *      - Fix: Few changes having with Make Qty Color
730aA*    01/17/19  KDE  7.30a
     *      - Change to review Replenishments when Make Qty changes regardless
     *        of whether Release checkbox clicked or not
     *      - Do not change Working Work Order status back to "R" when
     *        quantity changes
     *      - Call command UPDLOOP to keep finished good and component
     *        work orders in sync with quantity updates
     *      - Increase PoutStr to 1512 to return updated Work Orders
     *      - Return titles for Make Quantities equal to Breakdown Qty
     *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Fpwrkord   if a e           k disk
     Fpwrkord1  if   e           k disk    rename(worec:worec1)
     fplined    if   e           k disk
     fitemprd   if   e           k disk
710 Afpwrkordps if   e           k disk
     fpiritem   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#PROD
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

      *----------------------------------------------------------
      * Begin C#PGMINFDS - Program information data structure
      *  12/20/02  DAS  4.16  Created
      *  07/12/08  DAS  6.00a
      *    - Added #curruser, #prog, #jobn
      *  03/02/11  MLB  6.40
      *    - Added #parms
700   *  08/21/11  KDE  7.00
      *    - Fixed to return error from DRIPROD for WO Replen error
      *----------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
650aA /copy qcopysrc,p.wrtsessl

710 A*----------------------------------------------------------------
710 A*  Sub-procedure prototypes
710 A*----------------------------------------------------------------

730aA***    Up Quantity through Unit of Measure structure
730aAd zzupQty         pr


      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pWo#           s             13    varying
     D  pNeed          s              4p 0
     D  pMake          s              4p 0
     D  pMake1         s             10p 0
     D  pMake2         s             10p 0
     D  pMfgNo         s              3p 0
     D  pPriorty       s              2p 0
     D  pPoint         s              1    varying
     D  pAction        s              1    varying
     D  pStat          s              1    varying
     D  pDel           s              1    varying
     D  pRel           s              1    varying
730aMD  pOutStr        s           1512    varying
     D  pButchMsg      s            200    varying
     D  pPackMsg       s            200    varying
     D  pShipMsg       s            200    varying
710 Ad  pBomFnd        s             20
     D  pCust          s             11p 0
700aAD  pCustWo        s             15    varying
     D  pCord          s              7  0
     D  pDest          s              1    varying
     D  pFgItm         s             15    varying
     D  pMakeQty       s              8p 0
     D  pMakeQty1      s              8p 0
     D  pMakeQty2      s              8p 0
     D  pMessage       s             99    varying
     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20    varying
     D  pObjLoc        s             10    varying
     D  pSubCmd        s              1

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     D bfcoffset       s              3  0 inz(0)
     d chkDriErr       s             60
730aAd hldMakeQty      s                   like(pMakeQty)
730dAd hldMakeQty1     s                   like(pMakeQty)
730dAd hldMakeQty2     s                   like(pMakeQty)
     d currentdate     s              8
     d currentdttm     s             14
     D dbgflgExists    s               n
     D debug           s               n
     d jultoDay        s             12
730aAd itmLoop         s              4  0
     D len             s              3  0
730aAd makeTitle       s             30
730aAd makeTitle1      s             30
730aAd makeTitle2      s             30
     d numrecs         s              6  0
     D Ok              c                   0
     d pDatesql        s              8  0
     D pErr            s             99
     d pMakeClr        s              1
720 Ad MyfieldNull     s              5i 0
730aAd newQtyn         s              5  0
730aAd newQty1         s             10  0
730aAd newQty2         s             10  0
     d pmQty           s              5  0
     d pMfgLneClr      s              1
     d pPriClr         s              1
     d prdslot         s             12
     d prvQty          s              5  0
     d opnCount        s              5  0
     D rc              s              3  0 inz(0)
     DreturnStatus     S             10I 0
     d rightStr        s           1024
     D saveVer#        s                   like($ppver#)
     D SkipFirstRead   s               n
     D SqlStmt         s           2000    inz(' ')
     D sqlSuccess      c                   '00000'
     d TodayJul        s              5
     d TotalAdj        s              5  0
     d TotalOH         s              5  0
     D wherelabel      s            300
     d wkError         s               n
     d wkRerr2         s             50
     d wrkIso          s               d   Inz(*sys)

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------

     Ddqkey            ds            15
     D dqwhse                         3p 0
     D dqScale                       13

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

     D wrrec         E Ds                  Extname(pWrkOrdr)
720 A
720 A *----------------------------------------------------------------
720 A *  Query used to tally demand for WIP item Array
720 A *----------------------------------------------------------------
720 AD WoHdr           ds            31
720 AD  w_wowhse                      3  0
720 Ad  w_woitem                     15
720 Ad  w_wowo#                      13

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pWo#         Work Order Number
     *      pNeed        Need Quantity
     *      pMake        Make Quantity
     *      pMfgNo       Manufacuting Line
     *      pPriorty     Priority
     *      pPoint       Point of Enty.  Load time or Edit Time
     *      pAction      Edit or Update
     *      pStat        Status
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pWhse
610aAc                   parm                    pWo#
     c                   parm                    pNeed
     c                   parm                    pMake
     c                   parm                    pMfgNo
     c                   parm                    pPriorty
     c                   parm                    pPoint
     c                   parm                    pAction
     c                   parm                    pStat
     c                   parm                    pDel
     c                   parm                    pRel
     c                   parm                    pCust
     c                   parm                    pDest
     c                   parm                    pCustWo
     c                   parm                    pCord
     c                   parm                    pMake1
     c                   parm                    pMake2
     c                   parm                    pOutStr

      /free

          *inlr = *on;
          exsr init;
          exsr getWoInfo;
          if pPoint = 'L';
            exsr chkForDate;
710 A       exsr chkforbom;
730aA       if pAction = 'R';    // Look/Process any necessary replens
               exsr ReplenRel;
            endif;
          endif;
          select;
             when pPoint = 'L';
             when pPoint = 'P' and pAction = 'E';
                exsr loadData;
                if pErr <> 'NODATE';
                   exsr errorCheck;
                endif;
             when pPoint = 'P' and pAction = 'U' and pErr <> 'NODATE';
                exsr errorCheck;
                if not error;
720bA              // only do call updates if something changed
730MA              if ((pMake*woumq2*woumq3)+(pMake*woumq3)+pMake2)<>
730aA                  ((woMake*woumq2*woumq3)+(woMake1*woumq3)+woMAke2)
730aM                   or pPriorty<>woprio or pDel='Y'
730aA                   or wormavl='N';
730MA                 if ((pMake*woumq2*woumq3)+(pMake*woumq3)+pMake2)<>
730aA                     ((woMake*woumq2*woumq3)+(woMake1*woumq3)+woMAke2)
730aA                       or wormavl='N';
730aA                   if wostat='R' or wostat='W' and wormavl='N';
730aA                      // if quantity changes and Work Order already in work
730aA                      // review Raw Materials to see if more stock required
730aA                      pRel = 'Y';
730aA                   endif;
730aA                endif;
730MA                if ((pMake*woumq2*woumq3)+(pMake1*woumq3)+pMake2)<>
730aA                    ((woMake*woumq2*woumq3)+(woMake1*woumq3)+woMAke2)
730aA                       or pPriorty<>woprio or pDel='Y';
                        exsr updProdWO;
730aA                endif;
720bA              endif;
720bA              if pRel='Y';
                     exsr prdRePlen;
720bA              endif;
                endif;
             other;
                if pErr <> 'NODATE';
                   exsr errorcheck;
                endif;
           endsl;

         // if make quantity zero, send back O(Orange) to easily identify
          if woMake = 0 and woMake1=0 and woMake2=0;
             pMakeClr = 'O';
          endif;

         // if Status is Working or Released make green
730aD    // if woStat='R' or woStat='W';
730aD    //    pMakeClr = 'G';
730dA    // endif;

          // Return godd data or an error if an error exists
          if pErr = ' ' or pErr = 'NODATE';
             pOutStr = '{'
              +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
              +  '"pWoNo":"'  + %trim(WoWo#) + '",'
              +  '"pNeed":"'  + %trim(%char(woneed)) + '",'
              +  '"pMake":"'  + %trim(%char(pmake)) + '",'
              +  '"pMake1":"'  + %trim(%char(pmake1)) + '",'
              +  '"pMake2":"'  + %trim(%char(pmake2)) + '",'
710 A         +  '"pbomfnd":"'  + %trim(pbomfnd) + '",'
              +  '"pType":"'  + %trim(wotype) + '",'
              +  '"pMfgNo":"'  + %trim(%char(woMfgNo)) + '",'
              +  '"pPriority":"'  + %trim(%char(woprio)) + '",'
              +  '"pStat":"'  + %trim(woStat) + '",'
              +  '"pMakeClr":"'  + %trim(pMakeClr) + '",'
              +  '"pMfgLneClr":"'  + %trim(pMfgLneClr) + '",'
              +  '"pPriClr":"'  + %trim(pPriClr) + '",'
              +  '"makeTitle":"'  + %trim(makeTitle) + '",'
              +  '"makeTitle1":"'  + %trim(makeTitle1) + '",'
              +  '"makeTitle2":"'  + %trim(makeTitle2) + '",'
              +  '"ReplenCmp":"' + '",'
              +  '"pErr":"'  + %trim(pErr) + '"}';
          else;
             // error returned when something fails checks
             pOutStr = '{'
              +  '"pWhse":"'  + %trim(%char(pWhse)) + '",'
              +  '"pWoNo":"'  + %trim(pWo#) + '",'
              +  '"pNeed":"'  + %trim(%char(pNeed)) + '",'
              +  '"pMake":"'  + %trim(%char(pMake)) + '",'
              +  '"pMake1":"'  + %trim(%char(pMake1)) + '",'
              +  '"pMake2":"'  + %trim(%char(pMake2)) + '",'
              +  '"pType":"'  + %trim(wotype) + '",'
              +  '"pMfgNo":"'  + %trim(%char(pMfgNo)) + '",'
              +  '"pPriority":"'  + %trim(%char(pPriorty)) + '",'
              +  '"pStat":"'  + %trim(pStat) + '",'
              +  '"pMakeClr":"'  + %trim(pMakeClr) + '",'
              +  '"pMfgLneClr":"'  + %trim(pMfgLneClr) + '",'
              +  '"pPriClr":"'  + %trim(pPriClr) + '",'
              +  '"pmQty":"'  + %char(pmQty) + '",'
              +  '"ReplenCmp":"' + '",'
              +  '"makeTitle":"'  + %trim(makeTitle) + '",'
              +  '"makeTitle1":"'  + %trim(makeTitle1) + '",'
              +  '"makeTitle2":"'  + %trim(makeTitle2) + '",'
              +  '"pErr":"'  + %trim(pErr) + '"}';
          endif;

       //---------------------------------------------------------
       // chkforBom  Check to see where BOM is defined
       //---------------------------------------------------------

          begsr chkforBom;

              // get type bom used (either normal, dynamic or sub
710 A         savever# = $ppver#;
710 A         clear $pprod;
710 A         clear $pprod2;
710 A         $ppver# = savever#;
710 A         $ppSessIdu = *on;
710 A         $ppSessid  = pSessId;
710 A         $ppwhseu = *on;
710 A         $ppwhse  = pwhse;
710 A         $pplnenou = *on;
710 A         $pplneno = pmfgno;
710 A         $ppuser = #User;
710 A         $ppuseru = *on;
710 A         $ppwo# = pWo#;
710 A         $ppwo#u = *on;
710 A         $ppcustWo = *blanks;
710 A         $ppcustWou = *off;
710 A         $dricommand = '*PROD';
710 A         $drisys2upd = 'D';
710 A         $drisubcmd = '%wheresbom';
710 A         exsr zzDriCop;
710 A         pbomfnd = $ppcustwo;
710 A         if pbomfnd = 'PBOM';
710 A            pbomfnd = 'Standard';
710 A         else;
710 A           pbomfnd = 'Non-Standard';
710 A         endif;

          endsr;

       //---------------------------------------------------------
       // chkforDate  Check for open date for passed in Mfg Line
       //---------------------------------------------------------

          begsr chkforDate;

          // during a load force wo to passed mfg line
          if pMfgNo =0;
             pMfgno = womfgno;
          endif;

          opnCount = 0;
          exec sql
           select count(*)
            into :opncount
             from prdDate
              where pdwhse = :pwhse and pdline = :pMfgno
                    and pdstat = 'O';

          if Sqlstt = sqlSuccess;
             select;
             when opncount = 1;
                pErr = ' ';
                exec sql               // select valid date to return
                  select pdDate
                    into :pdatesql
                     from prdDate
                       where pdwhse = :pwhse and pdline = :pMfgno
                             and pdstat = 'O';
             when opncount > 1;
                pErr = 'NODATE';
             other;
             pErr = 'NODATE';
             endsl;
          else;
             pErr = 'NODATE';
          endif;

          endsr;
      /end-free

     *----------------------------------------------------------------
     *  delWorkOrder  Delete Work Order header and Requirements
     *----------------------------------------------------------------

      /free
       begsr delWorkOrder;

                savever# = $ppver#;
                $ppver# = savever#;

        // Call Delete Work Order from DRIPROD

                 $dricommand = '*PROD';
                 $drisubcmd = '%DELWO';
                 $drisys2upd = 'D';
                 exsr zzDriCop;
                 if wkerror or $driReturn <> '*OK';
                    pErr = $driMessage;
                 endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Check screen entry for errors
     *----------------------------------------------------------------

      /free
       begsr errorCheck;


         // if closing work order skip remaining checks
         if pDel <> 'X';
         // Ensure that entered manufacturing line is valid

         chain(n) (pwhse: pMfgNo) plined;
         if not %found(plined);
           pErr = 'Manufacturing Line ('
                 +  %trim(%char(pMfgNo)) + ') is invalid';
           pMfgLneClr = 'R';
           error = *on;
           leavesr;
         endif;

         // Make quantity must be positive

         if (pMake < 0 or pMake1<0 or pMake2<0) and pDel='N';
           pErr = 'Make Quantity must either be ZERO '
                  + ' or greater';
           pMakeClr = 'R';
           error = *on;
           leavesr;
         endif;

         // Priority code must be between 1 and 99

         if pPriorty > 99 or pPriorty < 1;
            pErr = 'Priority must be between 1 and 99';
            error = *on;
            pPriClr = 'R';
            leavesr;
         endif;

         // Both the delete checkbox and Release checkbox are not valid

         if pDel = 'Y' and pRel = 'Y';
            pErr = 'You cannot check both the Delete and Release boxes';
            error = *on;
            pPriClr = 'R';
            leavesr;
         endif;

         // If Work Order has been released you can only increase
         // Make Quantity since quantity may have already been
         // produced and raw materials already taken to line

         if woStat <> 'S' and woStat <> 'P' and
730MA       ((pMake*woumq2*woumq3)+(pMake1*woumq3)+pMake2)<
730aA        ((woMake*woumq2*woumq3)+(woMake1*woumq3)+woMAke2);
            pErr = 'You cannot reduce quantity for a Released Work Order' +
                   '.  You can close short';
            error = *on;
            pMakeClr = 'R';
            leavesr;
         endif;

         // If Work Order has been released you cannot change
         // the Manufacturing line.  Production may have already
         // started and raw materials may have been delivered

         if woStat <> 'S' and woStat <> 'P' and womfgno <> pMfgno;
            pErr = 'You cannot change the MFG  Line once WO released';
            error = *on;
            pMfgLneClr = 'R';
            leavesr;
         endif;
         endif;  // pDel = 'X'...Closing Work Order..Several chks in MRC

       endsr;

       //---------------------------------------------------------
       // getWoInfo  Get Work Order Production Information
       //---------------------------------------------------------

          begsr getWoInfo;

          if pPoint = 'P' and pAction = 'U';
             chain (pWhse:pWo#) pWrkOrd;
             if %found(pWrkOrd);
                prvQty = woMake;
             endif;
          endif;

          // force changed mfg line on file
          if pMfgNo <> 0;
             if pPoint = 'P' and pAction = 'U';
                exec sql
                update pwrkord
                 set womfgno = :pMfgNo,
                     woprio = :pPriorty
                 where wowo# = :pWo#;
700aA           exec sql
700aA           update pWrkOrdr
700aA            set wrMfgNo = :pMfgNo
700aA            where wrwhse = :pWhse
700aA                  and wrwo# = :pWo#;
             else;
                exec sql
                update pwrkord
                 set womfgno = :pMfgNo,
                     woprio = :pPriorty,
                     womake = :pmake,
                     womake1 = :pmake1,
                     womake2 = :pmake2
                 where wowo# = :pWo#;
700aA           exec sql
700aA           update pWrkOrdr
700aA            set wrMfgNo = :pMfgNo
700aA            where wrwhse = :pWhse
700aA                  and wrwo# = :pWo#;
             endif;
          endif;

              chain (pWhse:pWo#) pWrkOrd;
              if %found(pWrkOrd);
730aA            pFgItm = woitem;
720aM            if wormavl = 'N';
720aD     //          and (wostat = 'P' or wostat='S');
                    pMakeClr = 'Y';
                 endif;
                 if woumq2=0;
                    woumq2=1;
                 endif;
                 if woumq3=0;
                    woumq3=1;
                 endif;
730aA            select;
730aA              when woumq2>1;
730aA                newQty2=((pMAke*woumq2*woumq3)+(pmake1*woumq3)+pMake2)-
730aA                        ((womake*woumq2*woumq3)+(womake1*woumq3)+womake2);
730aA                newQty1=0;
730aA                newQtyn=0;
730aA              when woumq3>1;
730aA                newQty1=((pMAke*woumq2)+pmake1)-
730aA                        ((womake*woumq2)+womake1);
730aA                newQty2=0;
730aA                newQtyn=0;
730aA              other;
730aA                newQtyn=pMake-woMAke;
730aA                newQty1=0;
730aA                newQty2=0;
730aA            endsl;
730aA            zzupQty();
730aA            pMakeQty=newQtyn;
730aA            pMAkeQty1=newQty1;
730aA            pMAkeQty2=newQty2;

730aA            if woum2<>*blanks;
730aA               makeTitle = %char(woMake) + ' ' + %trim(woum1) + ' equals '
730aA                           + %char(woMake*woumq2) + ' ' + %trim(woum2);
                 else;
                    makeTitle = %char(woMake) + ' ' + %trim(woum1) +
                                ', no breakdown 1 defined';
730aA            endif;
730aA            if woum3<>*blanks;
730aA               makeTitle1=%char(woMake1) + ' ' + %trim(woum2) + ' equals '
730aA                + %char(woMake1*woumq3) + ' ' + %trim(woum3);
                 else;
                    makeTitle1 = %char(woMake1) + ' ' + %trim(woum2) +
                                ', no breakdown 2 defined';
730aA            endif;
                 makeTitle2 = %char(woMake2) + ' ' + %trim(woum3);

              else;
                 pErr = '** Work Order Record Not Found **';
              endif;

          endsr;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

             pErr = ' ';
             error = *off;

            if pPoint='L';
             //  exec sql select womfgno
             //       into :pMfgNo :MyFieldNull
             //      from pwrkord where
             //       wowhse=:pWhse and wowo#=:pWo#;
             //  if MyFieldNull = -1;
             //     pMfgno = 1;
             //  endif;
             chain (pWhse:pWo#) pWrkOrd;
             if pmake=0;
                pmake=womake;
             endif;
             if pmake1=0;
                pmake1=womake1;
             endif;
             if pmake2=0;
                pmake2=womake2;
             endif;
720aA            exec sql delete from PRMSUM
720aA              where smSessid = :pSessId;
                 exsr upRmSum;
            endif;

        endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  ReplenRel  Process any unprocessed Replens with stock for Released Work Orders
730aA*----------------------------------------------------------------

      /free
       begsr ReplenRel;

            // loop through work orders not closed, deleted and either released or
            // working and check to see if any additional replenishments should be
            // processed since system allows you to released without all raw and
            // components being available

            setll (*loval) pwrkord1;
            dow 1=1;
               read pwrkord1;
               if %eof(pwrkord1);
                  leave;
               endif;

               // only review work orders either in "released" or Working status
               if wostat<>'R' and wostat<>'W';
                  iter;
               endif;

               // send to routine that calls process in DRIPROD to check if replens
               // unprocessed and stock available to generate require replenishments
               pmfgno=womfgno;
               pwo#=wowo#;
               pcust=wocust;
               pcustwo=wocustwo;
               pcord=wocord;
               pRel='Y';
               exsr prdReplen;

            enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  upRmSum    Update RmSum and work order header for qty status
     *----------------------------------------------------------------

      /free
       begsr upRmSum;

720aA     //exec sql delete from PRMSUM
720aA     //        where smSessid = :pSessId;
          // on initial load of screen call DRIPROD process to properly
          // set flags with latest raw material availability.  IF any items
          // are short on a BOM it marks show Work order line shows with
          // yellow MAke Qty on M164xx
          //

730aA     makeTitle = *blanks;
730aA     makeTitle1 = *blanks;

          savever# = $ppver#;
          clear $pprod;
          clear $pprod2;
          $ppver# = savever#;

          $ppwhseu = *on;
          $ppwhse  = pwhse;
          $ppSessId = pSessId;
          $ppSessIdu = *on;
          $ppItem = *blanks;
          $ppItemu = *off;
730aA     $ppLneNo = pMfgno;
730aA     if itmLoop = 1;
730aA       $ppMAkeu=*on;
730aA       select;
730aA         when woumq2>1;
730aA           newQty2=((pMAke*woumq2*woumq3)+(womake1*woumq3)+woumq3)-
730aA                   ((womake*woumq2*woumq3)+(womake1*woumq3)+womake2);
730aA           newQty1=0;
730aA           newQtyn=0;
730aA         when woumq3>1;
730aA           newQty1=((pMAke*woumq2)+womake1)-
730aA                   ((womake*woumq2)+womake1);
730aA           newQty2=0;
730aA           newQtyn=0;
730aA         other;
730aA           newQtyn=pMake-woMAke;
730aA           newQty1=0;
730aA           newQty2=0;
730aA       endsl;
730aA       zzupQty();
730aA       $ppMAke=newQtyn;
730aA       $ppMAke1=newQty1;
730aA       $ppMAke2=newQty2;
730aA     else;
730aA       $ppMAkeu=*off;
730aA       $ppMake=0;
730aA       $ppMake1=0;
730aA       $ppMake2=0;
730aA     endif;
          $ppLneNou = *on;
          $ppRmAvl = *blanks;
          $ppRmAvlu = *off;
          $ppWo# = pWo#;
          $ppWo#u = *off;

          $dricommand = '*PROD';
          $drisubcmd = '%RMQTYEXT';
          $drisys2upd = 'D';
          exsr zzDriCop;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  loadData    Load passed values to data record
     *----------------------------------------------------------------

      /free
       begsr loadData;

          woWo# = pWo#;
          woNeed = pNeed;
          womfgno = pMfgNo;
          woMake = pMake;
          woMake1 = pMake1;
          woMake2 = pMake2;
          woPrio = pPriorty;
          woStat = pStat;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  prdReplen   Process Replenishment for selected Work Order
     *----------------------------------------------------------------

      /free
       begsr prdReplen;

        if pRel = 'Y';  // if selected to release call DRIPROD
          savever# = $ppver#;
          $ppver# = savever#;

          if pmfgNo <> 0;
             chain (pwhse:pmfgno) plined;
             if %found(plined);
                prdSlot = ' ';
                $ppdesc = indesc;
                $pprcvau = *on;
                $pprcva = inrcvaisl;
             endif;
          endif;

          // reading item master for finished good associated to wo
          chain (pwhse:woitem) piritem;
          if %found(piritem);
             $ppwhdpu = *on;
             $ppwhdp  = itwhdp;
             $ppitemu = *on;
             $ppitem  = ititem;
          endif;

          $ppSessIdu = *on;
          $ppSessid  = pSessId;
          $ppwhseu = *on;
          $ppwhse  = pwhse;
          $pplnenou = *on;
          $pplneno = pmfgno;
          $ppuser = #User;
          $ppuseru = *on;
          $ppwo# = pWo#;
          $ppwo#u = *on;
          $ppRmAvl = ' ';
          $ppRmAvlu = *on;
          $ppcustWo = pcustWo;
          $ppcustWou = *on;
          $ppcord = pcord;
          $ppcordu = *on;

          $dricommand = '*PROD';
          $drisubcmd = '%CRTWORPL';
          $drisys2upd = 'D';
          exsr zzDriCop;

720 A     // if no full cases returned as error for WIP Work ORder
720 A     // reset since stock will be supplied through WIP
720 A     if $driMessage = 'No full cases available';
720 A        exec sql select count(*) into :numrecs :MyFieldNull
720 A             from pwrkordr as h
720 A            where wrwhse=:pwhse and wrwo#=:pWo#
730aA                  and (select count(*) from itemprd as i
730aA                        where h.wrwhse=i.ipwhse and
730aA                        h.writem=i.ipitem and i.ipprdflg=
730aA                        'C')=0;
720 A     endif;
720 A
730aD     //if MyFieldNull = -1;
730aD     //   numrecs = 0;
730aD     //endif;
720 A
730aD     //if numrecs = 0;
730aA     //if numrecs = 0 and wostat<>'W' and wostat<>'R';
730aD     //   $driMessage = *blanks;
730aD      //  $driReturn = '*OK';
730aD      //  wkerror = *off;
730aD      //  exec sql update pwrkord
730aD      //    set wostat = 'R'
730aD      //    where wowhse = :$ppwhse and wowo# = :$ppwo#;
730aD      //  $ppstat = 'R';
730aD     //endif;

730aD     //if wkerror or $driReturn <> '*OK';
730aA     if wkerror or $driReturn <> '*OK' and woStat<>'W' and woStat<>'R';
             pErr = $driMessage;
             // flip Work Order status back to planning if error
             exec sql update pwrkord
               set wostat = 'P'
               where wowhse = :$ppwhse and wowo# = :$ppwo#;
             $ppstat = 'P';
          endif;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  updProdWO  Update Production Work Order calling DRIPROD
     *----------------------------------------------------------------

     C     updProdWO     begsr
      /free
           savever# = $ppver#;
           clear $pprod;
           clear $pprod2;
           $ppver# = savever#;

730aA      // Calculate net change Quantity
           $ppQty1 = pMake;
           $ppMake = woMake;
           $ppQty2 = pMake1;
           $ppMake1= woMake1;
           $ppQty3 = pMake2;
           hldMAkeQty = pMake;
           hldMAkeQty1 = pMake1;
           hldMAkeQty2 = pMake2;
730MA      if ((pMake*woumq2*woumq3)+(pMake*woumq3)+pMake2)<>
730aA          ((woMake*woumq2*woumq3)+(woMake1*woumq3)+woMAke2);
730aA         select;
730aA           when woumq2>1;
730aA             newQty2=((pMAke*woumq2*woumq3)+(womake1*woumq3)+woumq3)-
730aA                     ((womake*woumq2*woumq3)+(womake1*woumq3)+womake2);
730aA             newQty1=0;
730aA             newQtyn=0;
730aA           when woumq3>1;
730aA             newQty1=((pMAke*woumq2)+womake1)-
730aA                     ((womake*woumq2)+womake1);
730aA             newQty2=0;
730aA             newQtyn=0;
730aA           other;
730aA             newQtyn=pMake-woMAke;
730aA             newQty1=0;
730aA             newQty2=0;
730aA         endsl;
730aA         zzupQty();
730aA         pMakeQty=newQtyn;
730aA         pMAkeQty1=newQty1;
730aA         pMAkeQty2=newQty2;
           else;
              pMakeQty = pMake;
              pMakeQty1 = pMake1;
              pMakeQty2 = pMake2;
           endif;

           $ppSessIdu = *on;
           $ppSessid  = pSessId;
           $ppwhseu = *on;
           $ppwhse  = pwhse;
           $ppwo#u = *on;
           $ppwo#  = pWo#;
           $ppitemu = *on;
           $ppitem  = pFgItm;
           $ppuser = #User;
           $ppuseru = *on;
           $ppdest = pdest;
           $ppdestu = *off;
           $ppcust = pcust;
           $ppcustu = *on;
           $ppcustWo = pcustWo;
           $ppcustWou = *on;
           $ppcord = pcord;
           $ppcordu = *on;
           $ppmake = pMake;
           $ppmakeu = *on;
           $ppmake1 = pMake1;
           $ppmake1u = *on;
           $ppmake2 = pMake2;
           $ppmake2u = *on;
           $pplneno = pMfgNo;
           $pplnenou = *on;
730aA      if pDel = 'Y' or pDel='X';
730aA         $ppDel='Y';
730aA      endif;
           $ppprio = pPriorty;
           $pppriou = *on;
710 A      // setup PRimal and SubPRimal fields
710 A      if not %eof(pWrkordps);
710 A         $ppPrim = pspcde;
710 A         $ppPrimu = *on;
710 A         $ppSubPrim = psscde;
710 A         $ppSubPrimu = *on;
710 A         $ppPrimary = %char(psseq);
710 A         $ppPrimaryu = *on;
710 A      else;
710 A         $ppPrim = *blanks;
710 A         $ppPrimu = *off;
710 A         $ppSubPrim = *blanks;
710 A         $ppSubPrimu = *off;
710 A         $ppPrimary = *blanks;
710 A         $ppPrimaryu = *off;
710 A      endif;

           // calls command in DRIPROD that loops through and adds/updates/deletes
           // not only the work order being changed but also any component work orders
           // associated to this item
           $dricommand = '*PROD';
           $drisubcmd = '%UPDLOOP';
           $drisys2upd = 'D';
           exsr zzDriCop;
           if wkerror or $driReturn <> '*OK';
              pErr = $driMessage;
730aA      endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   eval      $dridata = $pprod
     c                   eval      $dridata2 = $pprod2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*PROD'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*PROD'
     c                   eval      $pprod = $dridata
     c                   eval      $pprod2 = $dridata2
     c                   endsl

     c                   endsr
     *----------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------

      /free
       begsr wrtDebugParm;

         bdtype = 'PARMS';

         bdvalues = '&pWoNo = ' + pWo#
                  + '&pUser=' + %trimr(pUser)
                  + '&pNeed=' + %trimr(%char(pNeed))
                  + '&pMake =' + %trimr(%char(pMake))
                  + '&pMake1 =' + %trimr(%char(pMake1))
                  + '&pMake2 =' + %trimr(%char(pMake2))
                  + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  *PSSR  Unexpected error handler
      *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

730aA*----------------------------------------------------------------
730aA*  zzUpQty  Up Quantity through Unit of Measure structure
730aA*           Setup as subprocedure to call from either subroutine or procedure
730aA*----------------------------------------------------------------
730aAP zzupQty         b
730aAD zzupQty         pi
730aA
730aA /free
730aA       // check for negative quantities
700bA       *in49=*off;
700bA       if newqtyn<0;
700bA          *in49=*on;
700bA          newqtyn = %abs(newqtyn);
700bA       endif;
700bA       if newqty1<0;
700bA          *in49=*on;
730aA          newqty1 = %abs(newqty1);
730aA       endif;
730aA       if newqty2<0;
730aA          *in49=*on;
730aA          newqty2 = %abs(newqty2);
730aA       endif;
730aA
730aA       dow woumq3 > 1 and +
730aA           newqty2 >= woumq3;
730aA          newqty2 -= woumq3;
730aA          newqty1 += 1;
730aA       enddo;
730aA
730aA       dow woumq2 > 1 and +
730aA           newqty1 >= woumq2;
730aA          newqty1 -= woumq2;
730aA          newqtyn += 1;
730aA       enddo;
730aA
730aA       if *in49;
730aA          newqtyn = newqtyn * -1;
730aA          newqty1 = newqty1 * -1;
730aA          newqty2 = newqty2 * -1;
730aA       endif;
730aA /end-free
730aA
730aAP zzupQty         e
