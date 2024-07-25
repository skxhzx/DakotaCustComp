      /copy *libl/qcopysrc,hspecs
730 AH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DD2DROP    DragDrop 2.0 Drop
     *  06 April 2018
     *  Dave Sommerville
     *
     *  Revisions:
     *
720 A*    04/06/18  DAS  7.20
     *      - Created.
     *
730 A*    10/15/19  KDE  7.30
     *      - do not set on lr
     *
750 A*    03/25/21  KDE  7.50
     *      - Locate and return Location for Un-Merge unlike zones on pallet
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits a return variable to 2000 characters. To protect
     *   against needing more than 2000 characters, we will call this
     *   multiple times. The pCallNum field will identify the call
     *   number.
     *
     *   There is not a good way to know where we left off from a
     *   previous call, therefore we will rebuild the string from
     *   the beginning each time and return the 2000 characters that
     *   corresponds to the call number.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     F*dopts    if   e           k disk
     F*rkcomp   if   e           k disk
     F*rkcompclrif   e           k disk
     F*losess   if   e           k disk
750 Afdddetail  if   e           k disk
750 Afdddetail1 if   e           k disk    rename(dddrec: dddrec1)
750 Afpltsum2   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *
     *  Input
     *    pWhse    - Warehouse
     *    pRtid    - Route id
     *    pDropId  - Drop Id
     *    pDragIds - Id's being dragged and dropped
     *    pSessId  - GUI Session Id
     *    pUser    - GUI User
     *    pDict    - GUI Dictionary
     *    pPgm     - GUI Program
     *
     *  Output
     *    pJSON    - JSON return string (MRC limits fields to 2000 char)
     *               {"tasks":...} string will be returned if no more
     *                  than 2000 characters.
     *               {"taskgrp":"number"} returned if larger than
     *                 2000 characters. Pgm will get task from file.
     *               {"error":"msg"} returned if error occured.
     *
     *----------------------------------------------------------------

     D dd2drop         pr                  extpgm('DD2DROP')
     D  pCmd                         10    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pDropId                      20    varying
     D  pDragIds                   2000    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pJSON                      2000    varying

     D dd2drop         pi
     D  pCmd                         10    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pDropId                      20    varying
     D  pDragIds                   2000    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

750 DD*forever         s               n
     D full            s               n
750 Ad baseGrp         s                   like(dddgroup)
750 Ad baseRow         s                   like(dddrow)
750 Ad baseCol         s                   like(dddcol)
750 Ad baseTzon        s                   like(pstzon)
750 Ad basePlt         s                   like(psplid)

     D debug1          s           1000    varying
     D debug2          s           1000    varying
     D debug3          s           1000    varying
     D debug4          s           1000    varying
     D debug5          s           1000    varying
     D debug6          s           1000    varying

     D currStr         s           6000    varying
     D errStr          s             50    varying
     D largeStr        s           6000    varying
     D prvStr          s           6000    varying

     D clr             s              7    varying
     D cod             s              1    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     D dsc             s            500    varying
700cAD min             s              5    varying
700cAD max             s              5    varying
     D opt             s             40    varying
     D txt             s             50    varying
     D typ             s             10    varying
     D val             s            400    varying

     D startPos        s              5p 0
     D endPos          s              5p 0
     D outLen          s              5p 0
     D maxLen          s              5p 0
     D len             s              5p 0
     D remainLen       s              5p 0
750 DD*i               s              5p 0
750 DD*j               s              5p 0
     D count           s              5p 0
750 Ad wrkRtid         s              5
750 Ad wrkid           s             20
750 Ad wrkspin         s             10
750 AD wrkmrg          s             10
750 AD wrksnap         s              2  0
750 Ad wrkrow          s              3  0
750 Ad wrkcol          s              2  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds
750 A /copy qcopysrc,c#stdsql
750 A /copy qcopysrc,c#stdvar
750 Ad/copy qcopysrc,p.ddwrkflds

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D dd420           pr                  extpgm('DD420')
     D  pCmd                         10    varying
     D  pWhse                         3p 0
     D  pRtid                         5    varying
     D  pDropId                      20    varying
     D  pDragIds                   2000    varying
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pDict                        10    varying
     D  pPgm                         10    varying
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
730 D    // *inlr = *on;

750 A    // process pltmrg from DD2 here instead of DD420
750 A    // This will actually un-merge labels associated
750 A    // to either a stopid or palletid where un-merge
750 A    // icon was associated
750 A    if pCmd = 'PLTMRG';
750 A       exsr getMrgLoc;
750 A       return;
750 A    endif;

         // Call DD420 to do heavy lifting

         monitor;
           dd420 (pCmd: pWhse: pRtid: pDropId: pDragIds:
                  pSessId: pUser: pDict: pPgm: pJSON);
           if %len(pJSON) = 0;
             pJSON = '{"error":"Call to DD420 returned empty string"}';
           endif;
         on-error;
           if %len(pJSON) = 0;
             pJSON = '{"error":"Call to DD420 failed"}';
           endif;
         endmon;

       return;

750 A    // Pull together a list of item only to drag to undo a merge unlike zones
750 A    // This is only executed when a user clicks the undo Merge icon in M268xx.
750 A    // That clikc will execute function bfcUnMerge in M268xx which sends id
750 A    // associated to that click along with command PLTMRG which executes this
750 A    // routine.  It sets pDragIds to the items contained in what was clicked,
750 A    // whether that be a stop or pallet.
750 A    begsr getMrgLoc;
750 A
750 A      wrkid = pDragIds;
750 A      exsr getlocationId;
750 A      wrkid = pDragIds;
750 A      pDragIds=*blanks;
750 A
750 A      // get Truck Zone for
750 A      setll (pWhse:pRtid:0:baseGrp:5:baseRow:baseCol) dddetail1;
750 A      dow forever = forever;
750 A
750 A        reade(n) (pWhse:pRtid:0:baseGrp:5:baseRow:baseCol) dddetail1;
750 A        if %eof(dddetail1);
750 A          leave;
750 A        endif;
750 A
750 A        // add only items with different Truck Zone from Base
750 A        // and either match the stop we are undoing or they are
750 A        // undoing a complete pallet
750 A        if dddorgzon <> baseTzon and dddplid = basePlt and
750 A                      (dddpid=wrkId or %subst(wrkId:1:2)='pl');
750 A          if pDragIds <>*blanks;
750 A            pDragIds = %trim(pDragIds) + '|';
750 A          endif;
750 A          pDragIds = %trim(pDragIds) + dddid;
750 A        endif;
750 A
750 A      enddo;
750 A
750 A      pJson = %trim(pjson) + '"dragIds":"' + %trim(pDragIds) + '"}';
750 A
750 A    endsr;

750 A    // Retrieve the pllet id associated with the dragid
750 A    // sent in from M268xx from clicking the un-merge icon.
750 A    // This id will either be a stop or pallet since those are
750 A    // the only two id's the un-merge will show.  When it reads
750 A    // the associated pallet for that dragid it will exit with
750 A    // the information needed and returned the actual row/column
750 A    // id as dropid in json string.  the calling routine will
750 A    // append the dragids to the same json string and return to
750 A    // M268xx to complete the un-merge by calling dodrop for these
750 A    // dragids and dropid.
750 A    begsr getLocationId;
750 A      setll (pWhse:pRtid:0:wrkid) dddetail;
750 A      dow forever = forever;
750 A        reade (pWhse:pRtid:0:wrkid) dddetail;
750 A        if %eof(dddetail) or not %equal(dddetail);
750 A          return;
750 A        endif;
750 A
750 A        if dddlevel = 2;
750 A          chain (pWhse: pRtid: 'O':
750 A                 dddgen: dddrow: dddcol) pltsum2;
750 A          pJson = '{"dropId":"' + %trim(dddpid) + '",';
750 A          baseTzon = pstzon;
750 A          baseGrp  = dddgroup;
750 A          baseRow  = dddrow;
750 A          baseCol  = dddcol;
750 A          basePlt  = dddplid;
750 A          leave;
750 A        endif;
750 A
750 A        wrkid = dddpid;
750 A        setll (pWhse:pRtid:0:wrkid) dddetail;
750 A      enddo;
750 A    endsr;

