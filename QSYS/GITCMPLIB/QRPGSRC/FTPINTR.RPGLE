     h/COPY *libl/qcopysrc,hspecs
     hDFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  FTPINTR      FTP Interface - Retrieval Program
     *  January 29, 2020
     *  Rod Roller
     *
740  *    01/29/19  RTR  7.40
     *      - Created from Aspen/Target versions.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *   - This program is intended to process FTP interface files
     *     to/from a remote FTP server.
     *   - Process Summary:
     *     1) Connect to server defined in OPTIONS *FTPIMP rec.
     *     2) For each import type, if flag is set in OPTIONINT,
     *        a) Get list of files for that interface.
     *        b) Ftp 'get' file into Dakota file/member for type.
     *        c) Ftp 'del' file from ftp server.
     *        d) Submit interface program using PIRFTPIMP.
     *        e) Repeat for files in list.
     *     3) For each export type, if flag is set in OPTIONINT,
     *        a) Call Dakota export program for that interface.
     *
     *  Assumptions
     *
     *   - This program creates a new activation group to run in so
     *     that the ftp session value can be retained and not shared
     *     with other programs.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     h bnddir('BFCFTPBND')

     *----------------------------------------------------------------
     *  Files
     foptions   if   e           k disk
     foptionint if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Program info data structure
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes.
      /copy qcopysrc,p.ftpapi
      /copy *libl/qcopysrc,p.getopint
      /copy *libl/qcopysrc,p.wrtlog

     *----------------------------------------------------------------
     *  *FTPIMP   -  FTP Import options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPIFTP  -  Use FTP for importing (Y,N)
     *    OPISRV  -  FTP Import Server name
     *    OPIUSR  -  FTP Import User id
     *    OPIPWD  -  FTP Import Password
     *    OPIPTH  -  Path for remote file
     *
     * Data structure
     *
     d opdataf         ds
     d  opiftp                 1      1
     d  opisrv                 2     33
     d  opiusr                34     48
     d  opipwd                49     63
     d  opipth                64     95
     d  opiend               117    117

     *----------------------------------------------------------------
     *  *FTPINT   -  FTP Interface Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTINTO  -  Use Interfaces (Y,N)
     *    OPTIIT  -  Import Items
     *    OPTIPO  -  Import Purchase Orders
     *    OPTIPQ  -  Import Picked Qtys
     *    OPTIOR  -  Import Orders
     *    OPTICQ  -  Import Qty for Compare Rpt
     *    OPTIOQ  -  Import Ordered Qty for Replen
     *    OPTIWC  -  Import Will Calls
     *    OPTEPO  -  Export Purchase Orders
     *    OPTEAD  -  Export Adjustments
     *    OPTEOR  -  Export Orders
     *    OPTLIB  -  File Library
     *    OPTJBD  -  Job Description
     *    OPTDLY  -  Delay Seconds
     *    OPTJQI  -  Job Queue for Imports
     *    OPTJQE  -  Job Queue for Exports
     *    OPTOQ   -  Report Outque
     *
     * Data structure
     *
     d opdatat         ds
     d  optinto                1      1
     d  optiit                 2      2
     d  optipo                 3      3
     d  optipq                 4      4
     d  optior                 5      5
     d  opticq                 6      6
     d  optioq                 7      7
     d  optiwc                 8      8
     d  optepo                10     10
     d  optead                11     11
     d  opteor                12     12
     d  optlib                20     29
     d  optjbd                30     39
     d  optdly                40     42
     d  optjqi                43     52
     d  optjqe                53     62
     d  optnep                63     72
     d  optoq                 73     82
     d  optend               117    117

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     d cmdstr          S            250a
     d cmdlen          S             15p 5
     d DebugFlag       s               n   inz('0')
     d ftp             S             10i 0
     d ftpreturn       S             10i 0
     d ftppwd          s             30a
     d ftppath         s             32a
     d ftppathlen      s              3s 0
     d ftpport         s             10i 0
     d ftpserver       s             30a
     d ftptimeout      s             10i 0
     d ftpuser         s             30a
     d getpath         s            200a
     d mbrbak          s             10a
     d mbrnam          s             10a
     d msgtxt          s           1024a
     d pathlen         s              3i 0
     d putbak          s            200a
     d putbak2         s            200a
     d putstr          s            200a
     d sbmoutq         s             10a
     d sbmuser         s             10a

     d filelist        S            256a   dim(9999)
     d num_files       S             10i 0
     d fileno          S             10i 0
     d rc              S             10i 0
     d ErrNum          S             10i 0
     d gotfiles        S             10i 0

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
     d RunCmd          pr                  extpgm('QCMDEXC')
     d  parmcmd                     250
     d  parmlen                      15  5

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *      pReturn    - *OK, *ERROR.
     *      pMessage   - Message
     *
     *----------------------------------------------------------------
     d main            pr                  extpgm('FTPINTR')
     d   pReturn                     10
     d   pMessage                   200

     d main            pi
     d   pReturn                     10
     d   pMessage                   200

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------
      /free
        exsr zzConnect;

        if pReturn = '*OK';

          exsr zzImpItems;
          exsr zzImpPOs;
          exsr zzImpPckQty;
          exsr zzImpQtyCmp;
          exsr zzImpOrd;
          exsr zzImpOrdQty;
          exsr zzImpWill;
          exsr zzExpPOs;
          exsr zzExpAdj;
          exsr zzClose;

        endif;

        // Log program end
        if debugflag;
          log.pgm = #pgm;
          log.type = 'End      ';
          log.text = 'FTP Interface ending normally.';
          WrtLog(log.pgm: log.type: log.text);
        endif;

        *inlr = *on;
        return;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *  *INZSR   Initialization Subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

          // Retrieve FTP info from OPTIONS
          pReturn = '*OK';
          opwhse = 0;
          opcode = '*FTPIMP';

          chain (opwhse: opcode) options;
          if %found;
            opdataf = opdata;
            ftpserver = opisrv;
            ftpuser = opiusr;
            ftppwd = opipwd;
            ftppath = opipth;
            ftppathlen = %len(%trim(opipth));
          endif;

          // If FTP Import not configured, set error
          if opiftp <> 'Y';
            pReturn = '*ERROR';
            pMessage = 'FTP Import not configured in OPTIONS.';
            leavesr;
          endif;

          // Retrieve interface options
          chain ('Interface': 'General Options': 'Warehouse Number') optionint;
          if %found;
            opwhse = opivaln;
          else;
            opwhse = 1;
          endif;

          opcode = '*FTPINT';
          chain (opwhse: opcode) options;
          if %found;
            opdatat = opdata;
            if optinto <> 'Y'
              or optlib = *blanks
              or optjbd = *blanks
              or optjqi = *blanks
              or optjqe = *blanks;
                log.pgm = #pgm;
                log.type = '*ERROR';
                log.text = 'FTP Interface not configured in OPTIONS for '
                         + %trim(optlib) + '.';
                WrtLog(log.pgm: log.type: log.text);
                leavesr;
            endif;

          // Get options from OPTIONINT
          chain ('Interface': 'FTP Interface': 'FTP Port') optionint;
          if %found;
            ftpport = opivaln;
          else;
            ftpport = 21;
          endif;
          chain ('Interface': 'FTP Interface': 'FTP Timeout') optionint;
          if %found;
            ftptimeout = opivaln;
          else;
            ftptimeout = 15;
          endif;
          chain ('Interface': 'General Options': 'Submit Batch User') optionint;
          if %found;
            sbmuser = opivala;
          else;
            sbmuser = '*CURRENT';
          endif;
          chain ('Interface': 'General Options': 'Interface Outque ') optionint;
          if %found;
            sbmoutq = opivala;
          else;
            sbmoutq = '*CURRENT';
          endif;

          // If FTP Import not configured, set error
          else;
            log.pgm = #pgm;
            log.type = 'Error';
            log.text = 'FTP Interface not configured in OPTIONS for '
                     + %trim(optlib) + '.';
            WrtLog(log.pgm: log.type: log.text);
            leavesr;
          endif;

          // Get debug flag
          optint.type = 'Interface   ';
          optint.cat  = 'General Options     ';
          optint.name = 'Debug Flag          ';
          GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                    optint.valn: optint.vala: optint.return);
          if optint.return = '*OK'
           and optint.vala = 'Y';
            debugflag = *on;
          else;
            debugflag = *off;
          endif;

          // Log program start
          if debugflag;
            log.pgm = #pgm;
            log.type = 'Start    ';
            log.text = 'FTP Interface Starting for ' + %trim(optlib) + '.';
            WrtLog(log.pgm: log.type: log.text);
          endif;

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzClose      Close FTP server
     *----------------------------------------------------------------
      /free
        begsr zzClose;

          ftp_quit(ftp);

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzConnect    Connects to FTP server
     *----------------------------------------------------------------
      /free
        begsr zzConnect;

          // Log FTP to joblog
          ftp_log(*On);

          // Connect to server
          ftp = ftp_conn(%trim(ftpserver) :%trim(ftpuser) :%trim(ftppwd)
                :ftpport :ftptimeout);
          if ftp < 0;
            // return error
            pReturn = '*ERROR';
            pMessage = 'Error connecting to server: ' + %char(ftp);
          else;
            // change to ascii so imports aren't garbage
            ftp_binary(*off);
          endif;

        endsr;  // zzConnect
      /end-free

     *----------------------------------------------------------------
     *  zzExpAdj     Exports Adjustment Files
     *----------------------------------------------------------------
      /free
        begsr zzExpAdj;

          // Check if Export is active
          if optead <> 'Y';
            leavesr;
          endif;

          // submit to batch
          cmdstr = 'SBMJOB CMD(CALL PGM(IT728SCL) PARM('+sq+'001'+sq+')) '
                 + 'JOB(EXPORTADJ) JOBD(' + %trim(optjbd)
                 + ') JOBQ(' + %trim(optjqe) + ') INLLIBL(*JOBD) '
730aM            + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
730aD        //  + 'MSGQ(*NONE) OUTQ(*LIBL/BFCIMPORT)';
          cmdlen = %len(%trim(cmdstr));
          RunCmd ( cmdstr : cmdlen );
        //msgtxt = cmdstr;
        //WrtLog(#prog: '*INFO': msgtxt);

        endsr;  // zzExpAdj
      /end-free

     *----------------------------------------------------------------
     *  zzExpPOs     Exports PO Files
     *----------------------------------------------------------------
      /free
        begsr zzExpPOs;

          // Check if Export is active
          if optepo <> 'Y';
            leavesr;
          endif;

          // submit to batch
          cmdstr = 'SBMJOB CMD(CALL PGM(PO726CL) PARM('+sq+'001'+sq+')) '
                 + 'JOB(EXPORTPO) JOBD(' + %trim(optjbd)
                 + ') JOBQ(' + %trim(optjqe) + ') INLLIBL(*JOBD) '
730aM            + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
730aD     //     + 'MSGQ(*NONE) OUTQ(*LIBL/BFCIMPORT)';
          cmdlen = %len(%trim(cmdstr));
          RunCmd ( cmdstr : cmdlen );
        //msgtxt = cmdstr;
        //WrtLog(#prog: '*INFO': msgtxt);

        endsr;  // zzExpPOs
      /end-free

     *----------------------------------------------------------------
     *  zzImpItems   Imports Item Files
     *----------------------------------------------------------------
      /free
        begsr zzImpItems;

          // Check if Import is active
          if optiit <> 'Y';
            leavesr;
          endif;

          // Pull list of Item files into array
          getpath = %trim(opipth) + 'IMPFITM4*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'FTPIMP';
            // Set paths
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFITM4.FILE/' + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfccpj/backup/impitem/' + %trim(filelist(fileno));
            // Get ITM4
            if ftp_get(ftp:%trim(opipth) + filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;
              ftp_get(ftp:%trim(opipth) + filelist(fileno): putbak);
              // Get ITMM
              putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFITMM.FILE/' + %trim(mbrnam) + '.MBR';
              %subst(filelist(fileno):8:1) = 'M';
              ftp_get(ftp:%trim(opipth) + filelist(fileno): putstr);
              ftp_get(ftp:%trim(opipth) + filelist(fileno): putbak);
              // Remove files
              ftp_delete(ftp:%trim(opipth) + filelist(fileno));
              %subst(filelist(fileno):8:1) = '4';
              ftp_delete(ftp:%trim(opipth) + filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ITM4STP '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTITEM) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'USER(' + %trim(sbmuser) + ') '
                     + 'OUTQ(*LIBL/' + %trim(optoq) + ')';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
            endif;

            fileno = fileno + 1;
          enddo;

        endsr; // zzImpItems
      /end-free

     *----------------------------------------------------------------
     *  zzImpOrd   Imports Order Files
     *----------------------------------------------------------------
      /free
        begsr zzImpOrd;

          // Check if Import is active
          if optior <> 'Y';
            leavesr;
          endif;

          // Pull list of Order Route files into array
          getpath = %trim(opipth) + 'IMPFORDH_*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
          //mbrnam = %subst(filelist(fileno):ftppathlen+11:8);
            mbrnam = 'FTPROUTE';
            // Get Order header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFORDH9.FILE/'
                     + %trim(mbrnam) + '.MBR';
            // backup file
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
          //ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: %trim(opipth) + filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching Order detail file
              %subst(filelist(fileno):8:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDD9.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            //ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: %trim(opipth) + filelist(fileno): putstr);

              // remove detail
              ftp_delete(ftp: %trim(opipth) + filelist(fileno));
              // remove header
              %subst(filelist(fileno):8:1) = 'H';
              ftp_delete(ftp: %trim(opipth) + filelist(fileno));
              // remove stop flags
              %subst(filelist(fileno):7:2) = 'SF';
              ftp_delete(ftp: %trim(opipth) + filelist(fileno));
              // remove detail misc
              %subst(filelist(fileno):10:100) = %subst(filelist(fileno):9:100);
              %subst(filelist(fileno):7:3) = 'DDM';
              ftp_delete(ftp: %trim(opipth) + filelist(fileno));
              // remove header misc
              %subst(filelist(fileno):7:3) = 'DHM';
              ftp_delete(ftp: %trim(opipth) + filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ROUTE9 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTORD) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'OUTQ(*LIBL/' + %trim(optoq) + ')';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
              log.pgm = #pgm;
              log.type = 'ERROR    ';
              log.text = 'Error retrieving file from Canopy. '
                       + filelist(fileno);
              WrtLog(log.pgm: log.type: log.text);
            endif;
            fileno = fileno + 1;

          enddo;

        endsr;  // zzImpOrd
      /end-free

     *----------------------------------------------------------------
     *  zzImpOrdQty  Imports Ordered Qty File for Replen
     *----------------------------------------------------------------
      /free
        begsr zzImpOrdQty;

          // Check if Import is active
          if optioq <> 'Y';
            leavesr;
          endif;

          // Pull list of files into array
          getpath = %trim(opipth) + 'IMPFITMO*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'FTPIMP';
            // Get file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFITMO.FILE/'
                     + %trim(mbrnam) + '.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ORDQTY '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTORDQ) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
            endif;
            fileno = fileno + 1;

          enddo;

        endsr;  // zzImpOrdQty
      /end-free

     *----------------------------------------------------------------
     *  zzImpPOs     Imports PO Files
     *----------------------------------------------------------------
      /free
        begsr zzImpPOs;

          // Check if Import is active
          if optipo <> 'Y';
            leavesr;
          endif;

          // Pull list of PO Header files into array
          getpath = %trim(opipth) + 'IMPFPOH*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'FTPIMP';
            // Get PO header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPOH2.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfccpj/backup/imppo/' + %trim(filelist(fileno));
            if ftp_get(ftp:%trim(opipth) + filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;
              ftp_get(ftp:%trim(opipth) + filelist(fileno): putbak);

              // Get matching PO detail file
              %subst(filelist(fileno):7:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFPOD2.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfccpj/backup/imppo/' + %trim(filelist(fileno));
              monitor;
                ftp_get(ftp:%trim(opipth) + filelist(fileno): putstr);
                ftp_get(ftp:%trim(opipth) + filelist(fileno): putbak);
              on-error;
                iter;
              endmon;

              // remove files
              ftp_delete(ftp:%trim(opipth) + filelist(fileno));
              %subst(filelist(fileno):7:1) = 'H';
              ftp_delete(ftp:%trim(opipth) + filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*PO2 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPO) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
730aM                + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
            endif;
            fileno = fileno + 1;

          enddo;

        endsr;  // zzImpPOs
      /end-free

     *----------------------------------------------------------------
     *  zzImpPckQty  Imports Picked Qty Files
     *----------------------------------------------------------------
      /free
        begsr zzImpPckQty;

          // Check if Import is active
          if optipq <> 'Y';
            leavesr;
          endif;

          // Pull list of files into array
          getpath = %trim(opipth) + 'IMPFPCKQ*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              msgtxt = 'FTP Error Listing IMPFPCKQ* files: ' + %char(ErrNum);
              WrtLog(#prog: '*ERROR': msgtxt);
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'FTPIMP';
          //mbrbak = 'X' + %subst(filelist(fileno):11:2)
          //             + %subst(filelist(fileno):15:6);
            // Get file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPCKQ.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfccpj/backup/imppckq/' + %trim(filelist(fileno));
730bM       if ftp_get(ftp: %trim(opipth) + filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // put in backup member
              ftp_get(ftp:%trim(opipth) + filelist(fileno): putbak);

              // remove file
              ftp_delete(ftp:%trim(opipth) + filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ADJDEMD '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPCKQ)'
                     + ' JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
730aM                + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
730aD         //     + 'MSGQ(IMPADJ) OUTQ(*LIBL/BFCIMPORT)';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              msgtxt = 'FTP Error reading file: ' + filelist(fileno);
              WrtLog(#prog: '*ERROR': msgtxt);
            endif;
            fileno = fileno + 1;

          enddo;

        endsr;  // zzImpPckQty
      /end-free

     *----------------------------------------------------------------
     *  zzImpQtyCmp  Imports Qty File for Compare Report
     *----------------------------------------------------------------
      /free
        begsr zzImpQtyCmp;

          // Check if Import is active
          if opticq <> 'Y';
            leavesr;
          endif;

          // Pull list of files into array
          getpath = %trim(opipth) + 'IMPFCQTY*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // change to line mode
          //ftp_LinMod(*on);

            // Create member name
            mbrnam = 'FTPIMP';

            // Get file
          //putstr = '/home/bfc/' + %trim(filelist(fileno));
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFCQTY.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            // backup file
          //ftp_get(ftp: filelist(fileno): putbak);
740bD     //if ftp_get(ftp: filelist(fileno): putstr)>=0;
740bM       if ftp_get(ftp: %trim(opipth) + filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // remove file
740bD       //ftp_delete(ftp: filelist(fileno));
740bM         ftp_delete(ftp: %trim(opipth) + filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(IT970CL) PARM(*EXCPTN '
                     + %trim(mbrnam)
                     + ' *INTER *JOB *STD)) JOB(IMPORTCOMP) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
730aM                + 'MSGQ(*NONE) OUTQ(*LIBL/' + %trim(optoq) + ')';
730aD         //     + 'OUTQ(*LIBL/BFCIMPORT)';
              //     + 'MSGQ(IMPITEM) OUTQ(*LIBL/BFCIMPORT)';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
            endif;
            fileno = fileno + 1;

          enddo;

          // turn line mode off
          ftp_LinMod(*off);
        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzImpWill  Imports Will Call Files
     *----------------------------------------------------------------
      /free
        begsr zzImpWill;

          // Check if Import is active
          if optiwc <> 'Y';
            leavesr;
          endif;

          // Pull list files into array
          rc = ftp_list(ftp: 'IMPFWILH*': 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // not processing will call now, delete files from server
          //ftp_delete(ftp: filelist(fileno));
          //%subst(filelist(fileno):8:1) = 'D';
          //ftp_delete(ftp: filelist(fileno));
          //fileno = fileno + 1;

          //// Create member name
          //mbrnam = 'T' + %subst(filelist(fileno):11:2)
          //             + %subst(filelist(fileno):15:6);
          //// Get Order header file
          //putstr = '/QSYS.LIB/' + %trim(optlib)
          //         + '.LIB/IMPFORDH4.FILE/'
          //         + %trim(mbrnam) + '.MBR';
          //if ftp_get(ftp: filelist(fileno): putstr)>=0;
          //  gotfiles = gotfiles + 1;

          //  // Get matching Order detail file
          //  %subst(filelist(fileno):8:1) = 'D';
          //  putstr = '/QSYS.LIB/' + %trim(optlib)
          //           + '.LIB/IMPFORDD4.FILE/'
          //           + %trim(mbrnam) + '.MBR';
          //  ftp_get(ftp: filelist(fileno): putstr);

          //  // remove files
          //  ftp_delete(ftp: filelist(fileno));
          //  %subst(filelist(fileno):8:1) = 'H';
          //  ftp_delete(ftp: filelist(fileno));

          //  // submit that sucker!
          //  cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*WILL4 '
          //         + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTWILL) '
          //         + 'JOBD(' + %trim(optjbd)
          //         + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
          //         + 'MSGQ(IMPORD) OUTQ(*LIBL/BFCIMPORT)';
          //  cmdlen = %len(%trim(cmdstr));
          //  RunCmd ( cmdstr : cmdlen );
          //  msgtxt = cmdstr;
          //  WrtLog(#prog: '*INFO': msgtxt);

          //else;
          //  // log error with filelist(fileno) ******************
          //endif;
          //fileno = fileno + 1;

          enddo;

        endsr;  // zzImpWill
      /end-free

