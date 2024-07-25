      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OR627     Truck build - Renumber Pallet Numbers PLTSUM DRAGDROP2
     *  13 April 2018
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720 A*    04/13/18  KDE  7.20
     *      - Created
     *
720aA*    05/01/18  KDE  7.20a
     *      - Changed sequencing to be by row, column
     *
720bA*    05/08/18  DAS  7.20b
     *     - Changed subroutine PalletbyUnload to be PalletbyLoad
     *       and vice versa. Reason: PalletbyLoad shoudl be in
     *       row/col order because row 1 is in the nose of the truck,
     *       and PalletbyUnload should be in descending row/col order.
     *     - Revised to update corresspondin DDDETAIL pallet record
     *
720cA*    05/09/18  DAS  7.20c
     *      - Revised PalletByUnload to use PSUNLD, instead of using
     *        reverse Load sequence.
     *
740aA*    08/24/20  DAS  7.40a
     *      - Added PalletByLoc. This is how DD1 worked. It allows
     *        duplicate pallet numbers to be assigned. For example,
     *        2 bulk picks in the same location will have the same
     *        pallet number.
     *      - Made PalletByLoc the norm.
     *
740bA*    09/08/20  KDE  7.40b
     *      - Routine PalletByLoc was passing an empty variable for
     *        pallet number to DD410 and therefore all pallets were
     *        being updated with zero.  Changed to pass in pspal# from
     *        pltsum
     *
750 A*    12/14/21  KDE  7.50
     *      - Do not execute particular query if route has no Bulk
     *        picks
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQSaA*    08/24/20  DAS  MQSa
     *      - Revised to use PalletByLoad/Unload because that is what
     *        they originally started with.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Anderson DuBose
     *
ADCaA*    08/24/20  DAS  ADCa
     *      - Revised to use PalletByLoad/Unload because that is what
     *        they originally started with.
     *
     *----------------------------------------------------------------
     * Notes:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Foptions   if   e           k disk
740aAFbfcdebug  o    e           k disk

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
     D client          s             10
     D clientloc       s             10
ADCaA /copy qcopysrc,id#adc
MQSaA /copy qcopysrc,id#mqs

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D psrec         E Ds                  Extname(PLTSUM)
     D dddrec        E Ds                  Extname(DDDETAIL)


     *----------------------------------------------------------------
     *  *GENPICK -  General picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPPLSQ  -  Load Sequence
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  opplsq                 7      7
     D  optend               117    117

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D pltnum          s                   like(pspal#)
     D id              s                   like(dddid)
     D pRtnCode        s             10
     D pRtnMsg         s            100
750 Ad bulkCnt         s              5  0

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.dd410

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

ADCaA   if client = andersondubose
MQSaA     or client = Marques;

            select;

              when opplsq = '1';      // Unload Sequence
                exsr PalletbyUnload;

              when opplsq = '2';      // Load Sequence
                exsr PalletbyLoad;

            endsl;

740aA   else;
740aA
740aA     exsr PalletbyLoc;
740aA
740aA   endif;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
     C     *inzsr        begsr

      /free

         getclient(client: clientLoc);

         chain ($pWhse:'*GENPICK') options;
         if not %found(options);
           opplsq = '1';
         endif;

      /end-free

     C                   endsr

740aA* ----------------------------------------------------------------------------------*
740aA*  PalletbyLoc   -  Renumber Pallet Number by Location pallet number                *
740aA* ----------------------------------------------------------------------------------*
740aAC     PalletbyLoc   begsr
      /free

        // Update 'P' records with corresponding 'O' rec pallet number

        monitor;

          exec sql
            update pltsum sp
              set sp.pspal# = (select max(so.pspal#) from pltsum so
                               where so.pswhse=sp.pswhse
                                 and so.psrtid=sp.psrtid
                                 and so.psgen=sp.psgen
                                 and so.psrow=sp.psrow
                                 and so.pscol=sp.pscol
                                 and so.pstype='O'
                              )
            where sp.pswhse = :$pWhse
              and sp.psrtid = :$pRtid
              and sp.pstype='P' ;

          if sqlstt <> sqlSuccess;
            bdvalues = 'PalletByLoc P rec update SQL error. SQLSTT=' + sqlstt;
            exsr wrtDebugError;
          endif;

        on-error;

          bdvalues = 'PalletByLoc P rec update Monitor error';
          exsr wrtDebugError;

        endmon;

        // Update 'B' records with corresponding 'P' rec pallet number
        // This has to get the WORKLBL 'B' record
        // then the WORKLBL 'M' record
        // then the PLTSUM 'P' record

750 A   // If the route id has no Bulk Picks then skip the following update SQL
750 A   bulkCnt=0;
750 A   exec sql select count(*) into :bulkCnt
750 A          from pltsum
750 A     where pswhse = :$pWhse  and
750 A           psrtid = :$pRtid and pstype='B';

750 A   if bulkCnt > 0;
        monitor;

          exec sql
            update pltsum sb
              set sb.pspal# = (select max(sp.pspal#)
                               from worklbl wb
                                 left outer join worklbl wm
                                   on wm.lwwhse = wb.lwwhse
                                      and wm.lwctr#=wb.lwlbl#
                                      and wm.lwtype='M'
                                 left outer join pltsum sp
                                   on sp.pswhse=wm.lwwhse
                                      and sp.psrtid=wm.lwrte
                                      and sp.psplid=wm.lwpal#
                               where wb.lwwhse=sb.pswhse
                                 and wb.lwlbl#=sb.pslbl#
                              )
            where sb.pswhse = :$pWhse
              and sb.psrtid = :$pRtid
              and sb.pstype='B';

          if sqlstt <> sqlSuccess;
            bdvalues = 'PalletByLoc B rec update SQL error. SQLSTT=' + sqlstt;
            exsr wrtDebugError;
          endif;

        on-error;

          bdvalues = 'PalletByLoc B rec update Monitor error';
          exsr wrtDebugError;

        endmon;
750 A   endif;

        // Update DDDETAIL records with new pallet numbers

        sqlStmt = 'select * '
                + 'from pltsum '
                + 'where pswhse =' + %char($pWhse) + ' '
                +   'and psrtid =' + sq + %trim($pRtid) + sq + ' '
                +   'and ((pstype =' + sq + 'B' + sq + ' and psgen = 7) '
                +        'or '
                +        '(pstype =' + sq + 'P' + sq + ' and psgen = 1)) ';

        exec sql PREPARE byLocSel FROM :SqlStmt;
        exec sql DECLARE byLocCsr SCROLL CURSOR FOR byLocSel;
        exec sql OPEN byLocCsr;

        dow forever = forever;

          exec sql fetch next from byLocCsr into :psrec;

          if sqlstt <> sqlSuccess;
            bdvalues = 'PalletByLoc DDDETAIL update SQL error. SQLSTT='
                     + sqlstt;
            exsr wrtDebugError;
            leave;
          endif;

          dd410('*UPDPLTNUM': psWhse: psRtid: '': 0: 0:
                #curruser: '': '': #pgm: pRtnCode: pRtnMsg:
740bD           //psplid: pltnum);
740bM           psplid: pspal#);

        enddo;
        exec sql close byLocCsr;

      /end-free
     C                   endsr

720bM* ----------------------------------------------------------------------------------*
720bM*  PalletbyLoad  -  Renumber Pallet Number by Load Sequence                         *
720bM* ----------------------------------------------------------------------------------*
720bMC     PalletbyLoad  begsr
      /free

        pltnum = 0;

        sqlStmt = 'select * '
                + 'from pltsum1 '
                + 'where pswhse =' + %char($pWhse) + ' '
                +   'and psrtid =' + sq + %trim($pRtid) + sq + ' '
                +   'and pstype =' + sq + 'P' + sq + ' '
                +   'and psgen = 1 '
                + 'order by psrow,pscol '
                + 'for update of pspal#';

        exec sql PREPARE byLoadSel FROM :SqlStmt;
        exec sql DECLARE byLoadCsr SCROLL CURSOR FOR byLoadSel;
        exec sql OPEN byLoadCsr;

        dow forever = forever;

          exec sql fetch next from byLoadCsr into :psrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Increment pallet number

          pltnum += 1;

          // Only update if necessary

          if pspal# = pltnum;
            iter;
          endif;

          // Update PLTSUM record with new pallet number

          exec sql update pltsum
                   set pspal# = :pltnum
                   where current of byLoadCsr;

          // Update DDDETAIL record with new pallet number

         dd410('*UPDPLTNUM': psWhse: psRtid: '': 0: 0:
               #curruser: '': '': #pgm: pRtnCode: pRtnMsg:
               psplid: pltnum);

        enddo;
        exec sql close byLoadCsr;

      /end-free
     C                   endsr

720bM* ----------------------------------------------------------------------------------*
720bM*  PalletbyUnload  -  Renumber Pallet Number by Unload Sequence                     *
720bM* ----------------------------------------------------------------------------------*
720bMC     PalletbyUnloadbegsr
      /free

        pltnum = 0;

        // First do truck pallets (rows 1 - 70)

        sqlStmt = 'select * '
                + 'from pltsum1 '
                + 'where pswhse =' + %char($pWhse) + ' '
                +   'and psrtid =' + sq + %trim($pRtid) + sq + ' '
                +   'and pstype =' + sq + 'P' + sq + ' '
                +   'and psgen = 1 '
720cD           //+   'and psunld < 71 '
720cD           //+ 'order by psrow desc, pscol desc '
720cM           + 'order by psunld, pscomp, pstzon '
                + 'for update of pspal#';

        exec sql PREPARE byUnloadSel FROM :SqlStmt;
        exec sql DECLARE byUnloadCsr SCROLL CURSOR FOR byUnloadSel;
        exec sql OPEN byUnloadCsr;

        dow forever = forever;

          exec sql fetch next from byUnloadCsr into :psrec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Increment pallet number

          pltnum += 1;

          // Update PLTSUM record with new pallet number

          exec sql update pltsum
                   set pspal# = :pltnum
                   where current of byUnloadCsr;

          // Update DDDETAIL record with new pallet number

          dd410('*UPDPLTNUM': psWhse: psRtid: '': 0: 0:
                #curruser: '': '': #pgm: pRtnCode: pRtnMsg:
                psplid: pltnum);

        enddo;
        exec sql close byUnloadCsr;


      /end-free
     C                   endsr
740aA
740aA *----------------------------------------------------------
740aA *  wrtDebugError  Write out debug error
740aA *----------------------------------------------------------
740aMC     wrtDebugError begsr

      /free

         bdtype = 'ERROR';

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

      /end-free
     C                   endsr

