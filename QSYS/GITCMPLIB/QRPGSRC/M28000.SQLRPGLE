      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M28000     Options - Report Scheduling
     *  23 August 2018
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    08/23/18  KDE  7.20
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D oprec         E ds                  extname(options) inz(*EXTDFT)
     D  optionCode     s             10    inz('*MRCRPT')


     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D forevr          s               n
     d n               s             18  0

     d psubcmd         s              1    inz('A')
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
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             20
     D  pwhse          s              3  0
     D  pIP            s             15
     D  pIPPort        s              5  0
     D  pdPrnt         s             10
     d  pgsdev         s              9
     d  prtuser        s             10
     d  pcustp         s              3
     d  pjobd          s             10
     d  pdbsrc         s             30
730 Ad  pincldd        s              1
730 Ad  pincldt        s              1
730 Ad  prptdir        s              1

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *MRCRPT  -  MRC Report Scheduling Options
     *
     * Fields
     *
     *    OPIP    -  IP address for Tomcat Server
     *    OPPORT  -  IP Port for Tomcat Server
     *    OPDPRT  -  Default Printer (Used when one not supplied)
     *    OPGSDV  -  Ghostscript Device
     *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
     *    OPDBSRC -  MRC Datasource for Report Calling to Use
     *    OPINCLDD-  Include Date in IFS filename
     *    OPINCLDT-  Include time in IFS filename
     *    OPRTDIR -  Include report name in IFS directory Structure
     *
     *----------------------------------------------------------------
     *
     * Data structure
     *

     D optionRec       ds
     D  opip                   1     15
     D  opport                16     20  0
     D  opdprt                21     30
     D  opgsdv                31     39
     D  opmusr                40     49
     d  opcpre                50     52
     d  opjobd                53     62
     d  opdbsrc               63     92
730 Ad  opincldd              93     93
730 Ad  opincldt              94     94
730 Ad  oprptdir              95     95

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pIP         Tomcat IP
     *      pIPPOrt     Tomcat Port
     *      pdPrnt      Default Printer
     *      pgsdev      Ghostscript Device
     *      prtuser     Runtime User
     *      pCustp      Customer Prefix
     *      pJobd       Runtime Jobd
     *      pdbSrc      Runtime Datasource
730 A*      pINCLDD     Include Date in IFS filename
730 A*      pINCLDT     Include time in IFS filename
730 A*      pRTDIR      Include report name in IFS directory Structure
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pIP
     C                   parm                    pIPPort
     C                   parm                    pDPrnt
     C                   parm                    pgsDev
     C                   parm                    pRTUser
     C                   parm                    pCustP
     C                   parm                    pJobd
     C                   parm                    pdbSrc
     C                   parm                    pincldd
     C                   parm                    pincldt
     C                   parm                    prptdir
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        exsr Afteract;

        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         pdprnt  = %xlate(xlower: xupper: pdprnt);
         prtuser  = %xlate(xlower: xupper: prtuser);
         pcustp  = %xlate(xlower: xupper: pcustp);
         pjobd  = %xlate(xlower: xupper: pjobd);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec    Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         error = *off;

         exsr FillRec;
         opdata = optionRec;

         exec sql insert into options values(:oprec);

         if sqlstt <> sqlSuccess;
           pMessage = 'Error adding record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AfterAct     After action update
     *----------------------------------------------------------------

      /free
       begsr AfterAct;

       error = *off;
       exsr errorCheck;
       if not error;

         exsr GetRec;

         if found;
            exsr UpdRec;
         else;
            exsr AddRec;
         endif;

       endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Error Checking Routine
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

          // Do not allow Time in filename if date is not checked
          if pincldd<>'Y' and pincldt='Y';
             pMessage = 'You must include date in filename to include time';
             error = *on;
          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  FillRec   Fill record fields
     *----------------------------------------------------------------

      /free
       begsr FillRec;

         opcode = optionCode;
         opwhse = pWhse;

	        opip   = pip;
	        opport = pipport;
	        opdprt = pdprnt;
	        opgsdv = pgsdev;
	        opmusr = prtuser;
	        opcpre = pcustp;
	        opjobd = pjobd;
	        opdbsrc= pdbsrc;
730 A    opincldd= pincldd;
730 A    opincldt= pincldt;
730 A    oprptdir= prptdir;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetRec    Get record
     *----------------------------------------------------------------

      /free
       begsr GetRec;

         found = *off;

         exec sql select * into :oprec
                  from options
                  where opcode = :optionCode
                    and opwhse = :pWhse;

         if sqlstt = sqlSuccess;
           found = *on;
         endif;

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  UpdRec    Update record
     *----------------------------------------------------------------

      /free
       begsr UpdRec;

         error = *off;
         exsr FillRec;
         opdata = optionRec;

         exec sql update options
                  set opdata = :opdata
                  where opcode = :opcode
                    and opwhse = :pWhse;

         if sqlstt <> sqlSuccess;
           pMessage = 'Error Updating record: '
                    + 'Sqlstt(' + sqlstt + ') '
                    + 'Code(' + %trim(opcode) + ') '
                    + 'Whse(' + %char(pWhse) + ') '
                    + 'Pgm(' + %trim(#pgm) +')';
         endif;

       endsr;
      /end-free
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
