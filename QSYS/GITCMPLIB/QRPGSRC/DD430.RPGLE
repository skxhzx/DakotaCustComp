      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2018BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DD430      Create DD 2.0 JSON
     *  17 March 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720a *   05/19/18  DAS  7.20a
     *     - Added RBLDREPLAY
     *
740aA*   07/23/20  KDE  7.40a
     *     - Add ability to override to history files for dddetail and
     *       ddtask.  Once routes get to pick and print they are moved
     *       to history files
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     * Replay is used for replaying the drops a user took. RBLDREPLAY
     * creates a REPLAY task, which consist of the tasks for creating
     * the original truck, which comes from DDDETAIL DDDSNAP=1.
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

740aDF*dddetail1 if   e           k disk
740aDF*ddtask    uf a e           k disk
740aMFdddetail1 if   e           k disk    usropn extfile(dddfile)
740aMFddtask    uf a e           k disk    usropn extfile(ddtfile)

     *----------------------------------------------------------------
     *  Working variables
     *
740aAD cmd             s           3000    varying
740aAd inRtnCode       s             10
740aAd inRtnMsg        s             60
     D gs1item         s              1

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Global Variables
     *----------------------------------------------------------------

740 Ad dddfile         s             10
740 Ad ddtfile         s             10
     D gRtid           s              5
     D gWhse           s              3  0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d ClearDDTREC     pr

     d CreateAll       pr

     d CreateColors    pr

720aAd CreateReplay    pr

     d CreateTruck     pr

     d GetCurrStamp    pr

     d RebuildCOlors   pr

720aAd RebuildReplay   pr

     d RebuildTruck    pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     d/copy qcopysrc,p.bfcdteti
740aA /copy qcopysrc,p.dd2dtamo
740aAD/copy qcopysrc,p.qcmdexc

     *----------------------------------------------------------------
     *  Parameters
     *
     *  $pCmd    - *CRTALL,
     *  $pOutput - *DDJSON, *FILE, *RTNSTR
     *  $pwhse   - Warehouse
     *  $prtid   - Route id
     *
     *----------------------------------------------------------------

     D DD430           pr                  extpgm('DD430')
     D  pCmd                         10    const
     D  pOutput                      10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pUser                        10    const
     D  pSessId                      40    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100
     d  pRtnStr                   65535    varying

     D DD430           pi
     D  pCmd                         10    const
     D  pOutput                      10    const
     D  pWhse                         3p 0 const
     D  pRtid                         5    const
     D  pUser                        10    const
     D  pSessId                      40    const
     D  pDict                        10    const
     D  pPgm                         10    const
     D  pRtnCode                     10
     D  pRtnMsg                     100
     d  pRtnStr                   65535    varying

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       pRtnCode = '*OK';
       pRtnMsg = '';
       pRtnStr = '';

       gWhse = pwhse;
       gRtid = pRtid;

       // Get timestamp to apply to records

       GetCurrStamp();
740aA  exsr opnDDfiles;

       select;
         when pCmd = '*CRTALL';
           CreateAll();
         when pCmd = 'RBLDCOLORS';
           RebuildColors();
720aA    when pCmd = 'RBLDREPLAY';
720aA      RebuildReplay();
         when pCmd = 'RBLDTRUCK';
           RebuildTruck();
       endsl;

      /end-free
740aA
740aA*----------------------------------------------------------
740aA*  opnDDfiles - Open DD files pointed to live or history
740aA*----------------------------------------------------------
740aA
740aA /free
740aA
740aA  begsr opnDDfiles;
740aA
740aA    // get status of route in DDDETAIL and open correct file(live/history)
740aA    dd2dtamove('*DTALOCDDD': inRtnCode: inRtnMsg: pWhse: pRtid);
740aA    if inRtnCode = 'LIVE';
740aA      // will simply open without override since in live files
           dddfile='DDDETAIL1';
740aA      if not %open(dddetail1);
740aA         open dddetail1;
740aA      endif;
740aA    else;
740aA      // when not found in live we will override to history
740aA      // files and then open for use
           dddfile='DDDETAILH1';
740aA      if not %open(dddetail1);
740aA         open dddetail1;
740aA      endif;
740aA    endif;
740aA
740aA    // get status of route in DDTASK and open correct file(live/history)
740aA    dd2dtamove('*DTALOCDDT': inRtnCode: inRtnMsg: pWhse: pRtid);
740aA    if inRtnCode = 'LIVE';
740aA      // will simply open without override since in live files
           ddtfile='DDTASK';
740aA      if not %open(ddtask);
740aA         open ddtask;
740aA      endif;
740aA    else;
740aA      // when not found in live we will override to history
740aA      // files and then open for use
           ddtfile='DDTASKH';
740aA      if not %open(ddtask);
740aA         open ddtask;
740aA      endif;
740aA    endif;
740aA  endsr;
740aA
740aA /end-free
740aA
     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

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

         pRtnCode = '*ERROR';
         pRtnStr = 'PSSR: ' + %trim(#pgm) + ' (' + %char(#stmt) + ') '
                 + #status + ' - ' + %trim(#pgmmsg);

         *inlr = *on;
         return;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ClearDDTREC     Clear DDTREC Fields
     *----------------------------------------------------------------

     p ClearDDTREC     b

      /free

       clear ddtrec;

       ddtaddpgm = #pgm;
       ddtaddts = currstampsys;
       ddtadduc = currstampuc;
       if pUser = '';
         ddtaddusr = #user;
       else;
         ddtaddusr = pUser;
       endif;
       ddtaddusrj = #user;
       ddtaddjob = #job;
       ddtaddnbr = #jobnbr;
       ddtsessid = pSessId;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CreateAll    Create everything
     *----------------------------------------------------------------

     p CreateAll       b
     d CreateAll       pi

      /free

       // Delete DDTASK records for colors

       setll (gWhse: '': 'COLORS') ddtask;
       dow forever;
         reade (gWhse: '': 'COLORS') ddtask;
         if %eof(ddtask);
           leave;
         endif;
         delete ddtrec;
       enddo;

       // Create Color Task

       CreateColors();

       // Delete DDTASK records for route

       setll (gWhse: gRtid) ddtask;
       dow forever;
         reade (gWhse: gRtid) ddtask;
         if %eof(ddtask);
           leave;
         endif;
         delete ddtrec;
       enddo;

       // Create Truck Task

       CreateTruck();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CreateColors  Create color tasks
     *----------------------------------------------------------------

     p CreateColors    b
     d CreateColors    pi

      /free

       // Start task array for colors

       ClearDDTREC();

       ddtwhse = gWhse;
       ddtrtid = '';
       ddttype = 'COLORS';
       ddtsubtype = 'START';
       ddtseq = 1;
       ddtstr = '{"tasks":[';
       write ddtrec;

       // Write out color tasks

       ddtStr = '';
       ddtsubtype = 'ADD';

       setll (gWhse: '*CLRS': 0) dddetail1;

       dow forever;

         reade (gWhse: '*CLRS': 0) dddetail1;
         if %eof(dddetail1);
           leave;
         endif;

         // Always writting after-the-fact to determine if comma is needed

         if dddjson > '';
           if ddtStr > '';
             ddtstr += ',';
             write ddtrec;
           endif;
           ddtseq += 1;
           ddtStr = '{"addcolor":' + dddjson + '}';
         endif;

       enddo;

       // Write out last task

       if ddtStr > '';
         write ddtrec;
       endif;

       // Close tasks

       ddtsubtype = 'END';
       ddtseq += 1;
       ddtstr = ']}';
       write ddtrec;

      /end-free

     p                 e

720aA*----------------------------------------------------------------
720aA*  CreateReplay   Create truck replay tasks
720aA*----------------------------------------------------------------
720aA
720aAp CreateReplay    b
720aAd CreateReplay    pi

     * Local Variables

     d  saveSeq        s                   like(ddtseq)

      /free

       // Start task array for truck

       ClearDDTREC();

       ddtwhse = gWhse;
       ddtrtid = gRtid;
       ddttype = 'REPLAY';
       ddtsubtype = 'START';
       ddtseq = 1;
       ddtstr = '{"tasks":[';
       write ddtrec;

       // Write out truck tasks

       ddtsubtype = 'ADD';
       ddtstr = '';

       setll (gWhse: gRtid: 1) dddetail1;

       dow forever;

         reade (gWhse: gRtid: 1) dddetail1;
         if %eof(dddetail1);
           leave;
         endif;

         // Always writing after-the-fact to determine if comma is needed

         if dddjson > '';

           if ddtstr > '';
             ddtstr += ',';
             write ddtrec;
           endif;

           ddtseq += 1;
           ddtid = dddid;
           ddtsnap = dddsnap;
           ddtgroup = dddgroup;
           ddtlevel = dddlevel;
           ddtrow = dddrow;
           ddtcol = dddcol;
           ddtplid = dddplid;
           ddtpltsct = dddpltsct;
           ddtstop = dddstop;
           ddtitmtyp = ddditmtyp;
           ddtlbltot = dddlbltot;
           ddtlblitm = dddlblitm;
           ddtstr = '{"add":' + dddjson + '}';

         endif;

       enddo;

       // Write out last task

       if ddtstr > '';
         write ddtrec;
       endif;

       // Close tasks

       saveSeq = ddtseq;
       ClearDDTREC();
       ddtwhse = gWhse;
       ddtrtid = gRtid;
       ddttype = 'REPLAY';
       ddtsubtype = 'END';
       ddtseq = saveSeq + 1;
       ddtstr = ']}';
       write ddtrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CreateTruck  Create truck tasks
     *----------------------------------------------------------------

     p CreateTruck     b
     d CreateTruck     pi

     * Local Variables

     d  saveSeq        s                   like(ddtseq)

      /free

       // Start task array for truck

       ClearDDTREC();

       ddtwhse = gWhse;
       ddtrtid = gRtid;
       ddttype = 'TRUCK';
       ddtsubtype = 'START';
       ddtseq = 1;
       ddtstr = '{"tasks":[';
       write ddtrec;

       // Write out truck tasks

       ddtsubtype = 'ADD';
       ddtstr = '';

       setll (gWhse: gRtid: 0) dddetail1;

       dow forever;

         reade (gWhse: gRtid: 0) dddetail1;
         if %eof(dddetail1);
           leave;
         endif;

         // Always writing after-the-fact to determine if comma is needed

         if dddjson > '';

           if ddtstr > '';
             ddtstr += ',';
             write ddtrec;
           endif;

           ddtseq += 1;
           ddtid = dddid;
           ddtsnap = dddsnap;
           ddtgroup = dddgroup;
           ddtlevel = dddlevel;
           ddtrow = dddrow;
           ddtcol = dddcol;
           ddtplid = dddplid;
           ddtpltsct = dddpltsct;
           ddtstop = dddstop;
           ddtitmtyp = ddditmtyp;
           ddtlbltot = dddlbltot;
           ddtlblitm = dddlblitm;
           ddtstr = '{"add":' + dddjson + '}';

         endif;

       enddo;

       // Write out last task

       if ddtstr > '';
         write ddtrec;
       endif;

       // Close tasks

       saveSeq = ddtseq;
       ClearDDTREC();
       ddtwhse = gWhse;
       ddtrtid = gRtid;
       ddttype = 'TRUCK';
       ddtsubtype = 'END';
       ddtseq = saveSeq + 1;
       ddtstr = ']}';
       write ddtrec;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  RebuildColors    Delete and Rebuild task group zero for colors
     *----------------------------------------------------------------

     p RebuildColors   b
     d RebuildColors   pi

      /free

       // Delete DDTASK records for colors

       setll (gWhse: '': 'COLORS') ddtask;
       dow forever;
         reade (gWhse: '': 'COLORS') ddtask;
         if %eof(ddtask);
           leave;
         endif;
         delete ddtrec;
       enddo;

       // Create Color Task

       CreateColors();

      /end-free

     p                 e

720aA*----------------------------------------------------------------
720aA*  RebuildReplay  Delete and Rebuild task group zero for replay
720aA*----------------------------------------------------------------
720aA
720aAp RebuildReplay   b
720aAd RebuildReplay   pi

      /free

       // Delete DDTASK group zero records for route

       setll (gWhse: gRtid: 'REPLAY': 0) ddtask;
       dow forever;
         reade (gWhse: gRtid: 'REPLAY': 0) ddtask;
         if %eof(ddtask);
           leave;
         endif;
         delete ddtrec;
       enddo;

       // Create Replay task

       CreateReplay();

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  RebuildTruck   Delete and Rebuild task group zero for truck
     *----------------------------------------------------------------

     p RebuildTruck    b
     d RebuildTruck    pi

      /free

       // Delete DDTASK group zero records for route

       setll (gWhse: gRtid: 'TRUCK': 0) ddtask;
       dow forever;
         reade (gWhse: gRtid: 'TRUCK': 0) ddtask;
         if %eof(ddtask);
           leave;
         endif;
         delete ddtrec;
       enddo;

       // Create Truck Task

       CreateTruck();

      /end-free

     p                 e

