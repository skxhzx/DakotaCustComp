      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M01500   Get build route JSON info
     *  05 April 2013
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/05/13  DAS  6.50
     *      - Created.
     *
650a *    05/07/14  DAS  6.50a
     *      - Implemented dock doors
     *
650b *    05/29/14  DAS  6.50b
     *      - Added logic for department dock doors
     *
650c *    03/12/15  DAS  6.50c
     *      - Added logic to prevent pick & print when ZZZZZZ exists.
     *      - Added logic to prevent pick & print when dock door
     *        not defined. Was commented out.
     *
650d *    03/12/15  DAS  6.50d
     *      - Added allowUndo flag, otherwise ZZZZZZ check ends up
     *        preventing undo. Needs corresponding screen change
     *        M01502 or newer.
     *
700a *    04/14/15  LMC  7.00a
     *      - Added AllowTextStg and AllowStage with the same ruls as
     *        pick and print.
700b *    04/16/15  LMC  7.00b
     *      - Added *GENPICK - currently USF uses flags from *GENPICK
     *        to determine if staging is allowed.
700c *    07/22/15  LMC  7.00c
     *      - Revised allowPckPrt  & allowStage to be 1 digit number,
     *        so it can take a value of 2 to allow these two actions
     *        without verification.
700d *    05/02/16  LMC  7.00d
     *      - Revised to ignore blank department records in RTECSUM.
720aA*    04/14/18  DAS  7.20a
     *      - Added DD2 to identify route is a DD2 route.
     *      - Added file DDDETAIL.
720bA*    09/12/18  DAS  7.20b
     *      - Revised to call GetTBType instead of reading
     *        data area dragdrop2 directly.
     *      - Replaced dd2 with tbEnhanced.
     *      - Removed DDDETAIL file since check is not needed anymore.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: USF
USFaA*    07/22/15  LMC  USFa
     *      - Revised to set allowPckPrt * allowStage to 2 instead of
     *      1 in order to bypass the verification screen.
USFbA*    04/22/16  DAS  USFb
     *      - Revised to not do ZZZZZZ check
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Frtesum    if   e           k disk
     Fordh3     if   e           k disk
     Fordh4     if   e           k disk    rename(ohrec:ohrec4)
620aAFordh10    if   e           k disk    prefix(oh_)
     Fordhm2    if   e           k disk
     Fcrossdk1  if   e           k disk
     Foptions   if   e           k disk
650aAFdocmtrx2  if   e           k disk
650bAFrtecsum1  if   e           k disk
650cAFpltsum1   if   e           k disk


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chkiuse

510  *----------------------------------------------------------------
510  *  Customer id
510  *----------------------------------------------------------------
510
510   /copy qcopysrc,id#packers
USFA  /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pRtId          s              5
     D  pRte           s              5
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700cDD*allowPckPrt     s               n
700cMD allowPckPrt     s              1  0
700cDD*allowStage      s               n
700cMD allowStage      s              1  0
     D allowText       s             50
700aAD allowTextStg    s             50
650dAD allowUndo       s               n
     D client          s             10
     D clientloc       s             10
     D cube            s                   like(rsordc)
     D hasPrePick      s               n
     D inUse           s               n
     D isPrePick       s               n
     D iuCmd           s              8
     D iuRtn           s              8
     D iuFlag          s              1  0
     D iuSubFlag       s              1  0
     D iuText10        s             10
     D iuText30        s             30
     D missingDoor     s               n
650bMD door            s            300
650bAD lastDept        s                   like(rcdrdp)
     D openPrePick     s               n
     D pieces          s                   like(rsordp)
     D shipNbr         s             11
720bAd tbEnhanced      s               n
720bAd tbPalletType    s              1
720bAd tbType          s              1
720bAd tbWhse          s              3  0
     D weight          s                   like(rsordw)
     D xdockPO         s                   like(cdpo)
650cAD zzzzzzExists    s               n

     *----------------------------------------------------------------
     *  Misc Data Structure
     *----------------------------------------------------------------

510  *  Shipment number from Miscellaneous field
510  D                 ds
510  D  hmmsc1                 1     40
510  D  hmmshp                 4     14
510
416dA*----------------------------------------------------------------
416dA*  *DOCDOOR -  Dock Door options
416dA*----------------------------------------------------------------
416dA*
416dA* Fields
416dA*
417 M*    OPATYP  -  Dock door assignment. 0=No assigment,1=Auto,2=Manual.
416dA*    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
416dA*
416dA* Data structure
416dA*
416dAD opdata          ds
416dAD  opatyp                 1      1
416dAD  opltyp                 2      2

700bA*----------------------------------------------------------------
700bA*  *GENPICK -  General picking.
700bA*----------------------------------------------------------------
700bA*
700bA* Fields
700bA*
700bA*    OPERPT  -  Print exception (short) error report (Y,N).
700bA*    OPELBL  -  Print exception (short) labels (Y,N).
700bA*    OPRFWC  -  Using RF will call (Y,N).
700bA*    OPNRSC  -  Number of pallet sections (1-9).
700bA*    OPHPWC  -  Host pick Will Call (Y/N).
700bA*    OPMRGA  -  Merge Add-on order(s) with Open Routes.
700bA*    OPPLSQ  -  Pallet number sequence. 1=Unload seq, 2=Load seq
700bA*    OPEADJ  -  Close short labels without adjustment (Y,N).
700bA*    OPNOPK  -  Pick items without pick slot as bulk pick? (Y/N)
700bA*    OPGPK1  -  <Not Used / Available>
700bA*    OPGPK2  -  <Not Used / Available>
700bA*               task has been assigned. (Y/N)
700bA*    OPJITR  -  Create JIT Letdown or JIT Replenishment
700bA*                 0=None. No replenishments are created.
700bA*                 1=Letdowns are created during Truck Builder
700bA*                   Pick/Print processing.
700bA*                 2=Priority Replenishments are created during
700bA*                   Truck Builder Pick/Print processing.
700bA*                 3=JIT Letdowns created when transaction is
700bA*                   checked out.
700bA*                 4=JIT Priority Replenishments created when
700bA*                   transaction is checked out.
700bA*    OPPSET  -  Print separate Set sum label for each pallet (Y/N).
700bA*    OPRFUC  -  RF Pick Verify item with UPC (Y/N)
700bA*    OPRFLC  -  RF Pick Verify item with license (Y/N)
700bA*    OPRFSL  -  RF Pick Verify slot (Y/N)
700bA*    OPRBN1  -  Round robin printing compatable (Y/N)
700bA*    OPRBN2  -  Round robin Type ing compatable (Y/N)
700bA*               1=Off
700bA*               2=By route
700bA*               3=By transaction
700bA*    OPSUBT  -  Allow Customer Item Substitution (Y/N)
700bA*    OPRFQT  -  RF Pick Allow Qty Entry (Y/N)
700bA*    OPRFCS  -  RF Pick Allow Change Slot (Y/N)
700bA*    OPPMTA  -  USF Option: Allow multi-truck assignments.
700bA*    OPMAXA  -  USF Option: Staged route selection limit.
700bA*    OPDOCK  -  USF Option: Dock door prompt choice.
700bA*
700bAD opdta1          ds
700bAD  operpt                 1      1
700bAD  opelbl                 2      2
700bAD  oprfwc                 3      3
700bAD  opnrsc                 4      4  0
700bAD  ophpwc                 5      5
700bAD  opmrga                 6      6
700bAD  opplsq                 7      7
700bAD  opeadj                 8      8
700bAD  opnopk                 9      9
700bAD  opgpk1                10     10
700bAD  opgpk2                11     11
700bAD  opjitr                12     12
700bAD  oppset                13     13
700bAD  oprfuc                14     14
700bAD  oprflc                15     15
700bAD  opusf1                16     16
700bAD  oprfsl                17     17
700bAD  oprbn1                18     18
700bAD  oprbn2                19     19
700bAD  opsubt                20     20
700bAD  oprfqt                21     21
700bAD  oprfcs                22     22
700bAD  oppmta                23     23
700bAD  opmaxa                24     25  0
700bAD  opmaxab               24     25
700bAD  opdock                26     26
700bAD  optend               117    117

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

720bAd/copy qcopysrc,p.gettbtyp

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pRtId        Route Id
     *      pRte         Route
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
610aAc                   parm                    pRtId
     c                   parm                    pRte
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        // Get information

        exsr GetInUse;
        exsr GetCubeWgtPcs;
        exsr GetPrePick;
700bA   exsr ChkStaging;
        exsr ChkDockDoors;
        exsr GetXDockPO;
650cA   exsr ChkZZZZZZ;
720aA   exsr chkDD2;

        // See if allowed to Pick/Print based on information.

        select;
          when inUse;
700cD       //allowPckPrt = false;
700cM       allowPckPrt = 0;
700bD       //allowStage = false;
650dA       allowUndo = false;
            allowText = 'Pick & Print not allowed - '
                      + 'Route In-Use';
700bD       //allowTextStg = 'Staging not allowed - '
700bD                    //+ 'Route In-Use';
          when zzzzzzExists;
700cD       //allowPckPrt = false;
700cM       allowPckPrt = 0;
700bD       //allowStage  = false;
650dA       allowUndo = true;
            allowText = 'Pick & Print not allowed - '
                      + 'ZZZZZZ Zone exists';
700bD       //allowTextStg = 'Staging not allowed - '
700bD                    //+ 'ZZZZZZ Zone exists';
650cM     when missingDoor;
700cD       //allowPckPrt = false;
700cM       allowPckPrt = 0;
700bD       //allowStage  = false;
650dA       allowUndo = true;
650cM       allowText = 'Pick & Print not allowed - '
650cM                 + 'Door Not Assigned';
700bD       //allowTextStg = 'Staging not allowed - '
700bD                    //+ 'Door Not Assigned';
          when openPrePick;
700cD       //allowPckPrt = false;
700cM       allowPckPrt = 0;
700bD       //allowStage  = false;
650dA       allowUndo = true;
            allowText = 'Pick & Print not allowed - '
                      + 'PrePick Route ('
                      + %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
                      + ') not Printed';
700bD       //allowTextStg = 'Staging not allowed - '
700bD                    //+ 'PrePick Route ('
700bD                    //+ %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
700bD                    //+ ') not Printed';
          other;
700cD       //allowPckPrt = true;
700cM       allowPckPrt = 1;
USFaA       if client = usfcorp;
USFaA         allowPckPrt = 2;
USFaA       endif;
700bD       //allowStage  = true;
650dA       allowUndo = true;
            allowText = 'Pick & Print';
700bD       //allowTextStg = 'Stage';
        endsl;

700bB   // See if allowed to Stage based on information.

700bB   select;
700bB     when oppmta <> 'Y';
700cD       //allowStage = false;
700cM       allowStage = 0;
700bB       allowTextStg = 'Staging not allowed ';
700bB     when inUse;
700cD       //allowStage = false;
700cM       allowStage = 0;
700bB       allowTextStg = 'Staging not allowed - '
700bB                    + 'Route In-Use';
700bB     when zzzzzzExists;
700cD       //allowStage  = false;
700cM       allowStage  = 0;
700bB       allowTextStg = 'Staging not allowed - '
700bB                    + 'ZZZZZZ Zone exists';
700bB     when missingDoor AND opdock = '1';
700cD       //allowStage  = false;
700cM       allowStage  = 0;
700bB       if opdock = '1';
700bA         allowTextStg = 'Staging not allowed - '
700bA                      + 'Door Not Assigned';
700bA       endif;
700bA     when openPrePick;
700cD       //allowStage  = false;
700cM       allowStage  = 0;
700bA       allowTextStg = 'Staging not allowed - '
700bA                    + 'PrePick Route ('
700bA                    + %trim(oh_rhrte) + '/' + %trim(oh_rhrtid)
700bA                    + ') not Printed';
700bA     other;
700cD       //allowStage  = true;
700cM       allowStage  = 1;
USFaA       if client = usfcorp;
USFaA         allowStage = 2;
USFaA       endif;
700bA       allowTextStg = 'Stage';
700bA   endsl;


        // Build JSON string to return

        pOutStr = '{'
700cM           +  '"alwpick":'   + %char(allowPckPrt) + ','
650dA           +  '"alwundo":'   + allowUndo + ','
                +  '"alwtxt":"'   + %trimr(allowText) + '",'
700cM           +  '"alwstg":'   + %char(allowStage) + ','
700aA           +  '"alwtxtstg":"'   + %trimr(allowTextStg) + '",'
                +  '"cube":"'   + %trim(%editc(cube:'A')) + '",'
                +  '"wgt":"'   + %trim(%editc(weight:'A')) + '",'
                +  '"pcs":"'   + %trim(%editc(pieces:'A')) + '",'
                +  '"dooropt":"'  + opatyp + '",'
650bA           +  '"doorltyp":"'  + opltyp + '",'
                +  '"missdoor":'   + missingDoor + ','
650aA           +  '"door":"'  + %trim(door) + '",'
                +  '"ispre":'   + isPrePick + ','
                +  '"haspre":'   + hasPrePick + ','
                +  '"opnpre":'   + openPrePick + ','
                +  '"iu":'   + inUse + ','
                +  '"iutxt":"'   + %trimr(iutext10) + '",'
720bA           +  '"dd2":' + tbEnhanced + ','
                +  '"xpo":"'  + %trimr(xdockPO) + '"';

        // Add custom client fields

        if client = packers;
          exsr GetShipNbr;
          pOutStr = %trimr(pOutStr) + ','
                  +  '"shnbr":"'  + %trimr(shipNbr) + '"';
        endif;

        // Close it off

        pOutStr = %trimr(pOutStr) + '}';

        return;
      /end-free

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetCubeWgtPcs   Get cube, weight and pieces
     *----------------------------------------------------------------

      /free
       begsr GetCubeWgtPcs;

600nA    cube = 0;
600nA    weight = 0;
600nA    pieces = 0;

         setll (pWhse: pRtId) rtesum;

         dow forever = forever;

           reade (pWhse: pRtId) rtesum;
           if %eof(rtesum);
             leave;
           endif;

           cube   += rsordc;
           weight += rsordw;
           pieces += rsordp;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetInUse   Get In-Use flag
     *----------------------------------------------------------------

      /free
       begsr GetInUse;

         iuCmd = '*GETIUSE';

         monitor;
           ChkIUse(iuCmd: pwhse: pRtId: iuRtn:
                   iuFlag: iuSubFlag: iuText10: iuText30);
         on-error;
           iuRtn = '*ERROR';
           iuText10 = 'GETIUSE NF';
           iuText30 = 'Error calling GETIUSE program';
         endmon;

        if iuRtn = '*ERROR' or iuFlag <> 0;
          inUse = true;
        else;
          inUse = false;
        endif;

       endsr;
      /end-free

720aA*----------------------------------------------------------------
720aA*  ChkDD2     Check if route is a DD2 route
720aA*----------------------------------------------------------------
720aA
720aA /free
720aA  begsr ChkDD2;

720bA    // Determine if using TruckBUilder Enhanced
720bA
720bA      tbWhse = pwhse;
720bA      GetTBType(tbWhse: prtid: tbType);
720bA      if tbType = 'E';
720bA        tbEnhanced = *on;
720bA        tbPalletType = 'P';
720bA      else;
720bA        tbEnhanced = *off;
720bA        tbPalletType = 'O';
720bA      endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChkDockDoors  Check for dock doors
     *----------------------------------------------------------------

      /free
       begsr ChkDockDoors;

         missingDoor = false;
650aA    door = '';

         chain (pWhse: '*DOCDOOR') options;
         if not %found(options);
           opatyp = '0';
         endif;

         // Get out if not manually assigning dock doors.
         // Either dock doors are not being used or they are
         // assigned automatically which won't happen until
         // Pick & Print.

         if opatyp <> '2';
           leavesr;
         endif;

         // See if door has been assigned

650bA    if opltyp = '2';
650bA      exsr ChkDockDoors2;
650bA    else;
650bA      exsr ChkDockDoors1;
650bA    endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  ChkDockDoors1  Check for dock doors - Single
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr ChkDockDoors1;

650aA    setll (pWhse: pRtId) docmtrx2;
650aA    reade (pWhse: pRtId) docmtrx2;

         if %eof(docmtrx2);
           dmdoor = 0;
         endif;

         if dmdoor = 0;
           missingDoor = true;
650aA      door = 'Not Assigned<br />';
         else;
650bM      door = %char(dmdoor) + ' - '
650bM             + %trim(dmwhdp) + ' '
650bM             + '(' + dmatyp + ')<br />';
         endif;

       endsr;
      /end-free

650bA*----------------------------------------------------------------
650bA*  ChkDockDoors2  Check for dock doors - Department
650bA*----------------------------------------------------------------
650bA
650bA /free
650bA  begsr ChkDockDoors2;

         // Loop through RTECSUM records

         lastDept = 'a';
         setll (pWhse: pRtId) rtecsum1;

         dow forever = forever;

           reade (pWhse: pRtId) rtecsum1;

           if %eof(rtecsum1);
             leave;
           endif;

           // Skip duplicate compartment records

           if rcdrdp = lastDept;
             iter;
           endif;

700dA      // Skip blank Department records

700dA      if rcdrdp = ' ';
700dA        iter;
700dA      endif;

           lastDept = rcdrdp;

           // See if door has been assigned

           setll (pWhse: pRtId: rcdrdp) docmtrx2;
           reade (pWhse: pRtId: rcdrdp) docmtrx2;

           if %eof(docmtrx2);
             dmdoor = 0;
           endif;

           if dmdoor = 0;
             missingDoor = true;
             door = %trimr(door)
                  + %trim(rcdrdp) + ' - Not Assigned<br />';
           else;
             door = %trimr(door)
                  + %trim(rcdrdp) + ' - '
                  + %char(dmdoor) + ' (' + dmatyp + ')<br />';
           endif;

         enddo;

       endsr;
      /end-free

700bA*----------------------------------------------------------------
700bA*  ChkStaging    Check for staging
700bA*----------------------------------------------------------------

700bA /free
700bA  begsr ChkStaging;

700bA    chain (pWhse: '*GENPICK') options;
700bA    if not %found(options);
700bA      oppmta = 'N';
700bA      opdock = '2';
700bA    else;
700bA      opdta1 = opdata;
700bA    endif;

700bA  endsr;
700bA /end-free
700bA
650cA*----------------------------------------------------------------
650cA*  ChkZZZZZZ     Check for ZZZZZZ Zone
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA  begsr ChkZZZZZZ;

         zzzzzzExists = false;

USFbA    if client = usfcorp;
USFbA      leavesr;
USFbA    endif;

         setll (pWhse: pRtId) pltsum1;

         dow forever = forever;

           reade (pWhse: pRtId) pltsum1;
           if %eof(pltsum1);
             leave;
           endif;

           if pstzon = 'ZZZZZZ'
              or pspzon = 'ZZZZZZ'
              or psszon = 'ZZZZZZ';
                zzzzzzExists = true;
                leave;
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetPrePick   Get PrePick info
     *----------------------------------------------------------------

      /free
       begsr GetPrePick;

         isPrePick = false;
         hasPrePick = false;
         openPrePick = false;

         setll (pWhse: pRtId) ordh4;

         dow forever = forever;

           reade (pWhse: pRtId) ordh4;
           if %eof(ordh4);
             leavesr;
           endif;

           // Get out if sent route is a PrePick route

           if %subst(ohmisc:17:1) = 'Y';
             isPrePick = true;
             leavesr;
           endif;

           // Look for PrePick items on route

           setll (ohwhse: ohcord) ordh10;

           dow forever = forever;

             reade (ohwhse: ohcord) ordh10;
             if %eof(ordh10);
               leave;
             endif;

             if %subst(oh_ohmisc:17:1) <> 'Y';
               iter;
             endif;

             // Item associated with a PrePick order

             hasPrePick = true;

             // See if PrePick route is only Open or Built.

             if prte = oh_rhrte and oh_rhstat < '4';
               openPrePick = true;
               leavesr;
             endif;

           enddo;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetShipNbr   Get Packers shipment number
     *----------------------------------------------------------------

      /free
       begsr GetShipNbr;

600nA    shipNbr = '';

         chain (pWhse: pRtId) ordhm2;
         if %found(ordhm2);
           shipNbr = hmmshp;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetXDockPO   Get crossdock PO
     *----------------------------------------------------------------

      /free
       begsr GetXDockPO;

600nA    xdockPO = '';

         setll (pWhse: pRtId) ordh3;

         dow forever = forever;

           reade (pWhse: pRtId) ordh3;
           if %eof(ordh3);
             leave;
           endif;

           chain (ohwhse: ohord) crossdk1;
           if %found(crossdk1);
             xdockPO = cdpo;
             leave;
           endif;

         enddo;

       endsr;
      /end-free
