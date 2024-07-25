     H/COPY *libl/qcopysrc,hspecs
     HDFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  ASPENINTR    Aspen FTP Interface Retrieval Program
     *  15 May 2018
     *  Rod Roller
     *
720  *    05/15/18  RTR  7.20
     *      - Created from Target version.
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720a *    05/22/18  RTR  7.20a
     *      - Added FTP port and job submit user set in OPTIONINT.
     *
740a *    05/12/20  RTR  7.40a
     *      - Changed path logic to adjust for changes to option path.
740b *    05/12/20  RTR  7.40b
     *      - Added FTP timeout and job submit outq set in OPTIONINT.
     *
750 A*    07/28/21  MLB  7.50
     *      - Fix: Revised ZZIMPORDQTY to activate call to QCMD to run
     *        SBMJOB cmd for job IMPORTORDQ.
     *      - Corrected msgq to IMPQTY from IMPDEMD in ZZIMPORDQTY.
     *
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *   - This program is intended to process FTP interfaces for
     *     an Aspen host system. Aspen does not FTP but places files
     *     in a folder on their system which we must FTP into and
     *     retrieve the file from.
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
     *----------------------------------------------------------------
     H bnddir('BFCFTPBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     Foptions   if   e           k disk
740bAfoptionint if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
     D/copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------
     D/copy qcopysrc,p.ftpapi
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
     D opdataf         ds
     D  opiftp                 1      1
     D  opisrv                 2     33
     D  opiusr                34     48
     D  opipwd                49     63
     D  opipth                64     95
     D  opiend               117    117

     *----------------------------------------------------------------
     *  *ASPEN    -  Aspen Interface Options
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
     *
     * Data structure
     *
     D opdatat         ds
     D  optinto                1      1
     D  optiit                 2      2
     D  optipo                 3      3
     D  optipq                 4      4
     D  optior                 5      5
     D  opticq                 6      6
     D  optioq                 7      7
     D  optiwc                 8      8
     D  optepo                10     10
     D  optead                11     11
     D  opteor                12     12
     D  optlib                20     29
     D  optjbd                30     39
     D  optdly                40     42
     D  optjqi                43     52
     D  optjqe                53     62
     D  optend               117    117

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D cmdstr          S            250a
     D cmdlen          S             15p 5
     d DebugFlag       s               n   inz('0')
     D ftp             S             10i 0
     D ftpreturn       S             10i 0
     D ftppwd          s             30a
     D ftppath         s             32a
720aAD ftppathlen      s              3s 0
720aAd ftpport         s             10i 0
     D ftpserver       s             30a
740bAd ftptimeout      s             10i 0
     D ftpuser         s             30a
     D getpath         s            200a
     D mbrbak          s             10a
     D mbrnam          s             10a
     D msgtxt          s           1024a
     D putbak          s            200a
     D putbak2         s            200a
     D putstr          s            200a
740bAd sbmoutq         s             10a
720aAd sbmuser         s             10a

     D filelist        S            256a   dim(9999)
     D num_files       S             10i 0
     D fileno          S             10i 0
     D rc              S             10i 0
     D ErrNum          S             10i 0
     D gotfiles        S             10i 0

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
     D RunCmd          pr                  extpgm('QCMDEXC')
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
     D main            pr                  extpgm('ASPENINTR')
     D   pReturn                     10
     D   pMessage                   200

     D main            pi
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------
      /free
        exsr zzConnect;

        if pReturn = '*OK';

          exsr zzExpPOs;
          exsr zzExpAdj;
          exsr zzImpItems;
          exsr zzImpPOs;
          exsr zzImpPckQty;
          exsr zzImpOrd;
          exsr zzImpOrdQty;
          exsr zzImpWill;
          exsr zzImpQtyCmp;
          exsr zzClose;

        endif;

      /free
        // Log program end
        if debugflag;
          log.pgm = #pgm;
          log.type = 'End      ';
          log.text = 'Aspen Interface ending normally.';
          WrtLog(log.pgm: log.type: log.text);
        endif;
      /end-free

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

          // Retrieve interface options from OPTIONS
          opwhse = 1;
          opcode = '*ASPEN ';

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
                log.text = 'Aspen Interface not configured in OPTIONS for '
                         + %trim(optlib) + '.';
                WrtLog(log.pgm: log.type: log.text);
                leavesr;
            endif;

          // If FTP Import not configured, set error
          else;
            log.pgm = #pgm;
            log.type = 'Error';
            log.text = 'Aspen Interface not configured in OPTIONS for '
                     + %trim(optlib) + '.';
            WrtLog(log.pgm: log.type: log.text);
            leavesr;
          endif;

          // Get options from OPTIONINT
720aA     chain ('Interface': 'FTP Interface': 'FTP Port') optionint;
720aA     if %found;
720aA       ftpport = opivaln;
720aA     else;
720aA       ftpport = 21;
720aA     endif;
740bA     chain ('Interface': 'FTP Interface': 'FTP Timeout') optionint;
740bA     if %found;
740bA       ftptimeout = opivaln;
740bA     else;
740bA       ftptimeout = 15;
740bA     endif;
720aA     chain ('Interface': 'General Options': 'Submit Batch User') optionint;
720aA     if %found;
720aA       sbmuser = opivala;
720aA     else;
720aA       sbmuser = '*CURRENT';
720aA     endif;
740bA     chain ('Interface': 'General Options': 'Interface Outque ') optionint;
740bA     if %found;
740bA       sbmoutq = opivala;
740bA     else;
740bA       sbmoutq = '*CURRENT';
740bA     endif;

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
            log.text = 'Aspen Interface Starting for ' + %trim(optlib) + '.';
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
740bD   //ftp = ftp_conn(%trim(ftpserver): %trim(ftpuser): %trim(ftppwd));
740bM     ftp = ftp_conn(%trim(ftpserver) :%trim(ftpuser) :%trim(ftppwd)
740bM           :ftpport :ftptimeout);
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
740bM            + 'MSGQ(EXPADJ) OUTQ(' + %trim(sbmoutq) + ')';
740bD        //  + 'MSGQ(EXPADJ) OUTQ(*LIBL/BFCIMPORT)';
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
740bM            + 'MSGQ(EXPPO) OUTQ(' + %trim(sbmoutq) + ')';
740bD        //  + 'MSGQ(EXPPO) OUTQ(*LIBL/BFCIMPORT)';
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
          getpath = %trim(opipth) + 'IFPFITM4*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
              log.pgm = #pgm;
              log.type = 'ERROR    ';
              log.text = 'Error retrieving list of item files.';
              WrtLog(log.pgm: log.type: log.text);
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'ASPEN';
            // Get Item file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFITM4.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            putbak2 = '/QSYS.LIB/' + %trim(optlib)
                      + '.LIB/IMPFITM4.FILE/LAST.MBR';
            if ftp_get(ftp: filelist(fileno): putstr) >= 0;
              gotfiles = gotfiles + 1;

              // backup file
            //ftp_get(ftp: filelist(fileno): putbak);
            //ftp_get(ftp: filelist(fileno): putbak2);

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ITM4PAR '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTITEM) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(IMPITEM) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPITEM) OUTQ(*LIBL/BFCIMPORT)';
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
          getpath = %trim(opipth) + 'IMPFORDH*';
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
740aD     //mbrnam = %subst(filelist(fileno):23:8);
740aM       mbrnam = %subst(filelist(fileno):ftppathlen+11:8);
            // Get Order header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFORDH4.FILE/'
                     + %trim(mbrnam) + '.MBR';
            // backup file
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
          //ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching Order detail file
740aD       //%subst(filelist(fileno):20:1) = 'D';
740aM         %subst(filelist(fileno):ftppathlen+8:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDD4.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            //ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putstr);

              // remove detail
              ftp_delete(ftp: filelist(fileno));
              // remove header
740aD       //%subst(filelist(fileno):20:2) = 'H5';
740aM         %subst(filelist(fileno):ftppathlen+8:2) = 'H5';
              ftp_delete(ftp: filelist(fileno));
              // remove detail misc
740aD       //%subst(filelist(fileno):20:2) = 'DM';
740aM         %subst(filelist(fileno):ftppathlen+8:2) = 'DM';
              ftp_delete(ftp: filelist(fileno));
              // remove header misc
740aD       //%subst(filelist(fileno):19:3) = 'HM.';
740aM         %subst(filelist(fileno):ftppathlen+7:3) = 'HM.';
740aD       //%subst(filelist(fileno):22:8) = mbrnam;
740aM         %subst(filelist(fileno):ftppathlen+10:10) = mbrnam + '  ';
              ftp_delete(ftp: filelist(fileno));
              // remove stop flags
740aD       //%subst(filelist(fileno):19:3) = 'SF.';
740aM         %subst(filelist(fileno):ftppathlen+7:3) = 'SF.';
740aD       //%subst(filelist(fileno):22:8) = mbrnam;
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ROUTE4 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTORD) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(IMPORD) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPORD) OUTQ(*LIBL/BFCIMPORT)';
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
            mbrnam = 'ASPEN';
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
750 M                + 'MSGQ(IMPQTY) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPDEMD) OUTQ(*LIBL/BFCIMPORT)';
              cmdlen = %len(%trim(cmdstr));
750 M         RunCmd ( cmdstr : cmdlen );
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
            mbrnam = 'ASPEN';
            // Get PO header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPOH2.FILE/'
                     + %trim(mbrnam) + '.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching PO detail file
              %subst(filelist(fileno):19:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFPOD2.FILE/'
                       + %trim(mbrnam) + '.MBR';
              ftp_get(ftp: filelist(fileno): putstr);

              // remove files
              ftp_delete(ftp: filelist(fileno));
              %subst(filelist(fileno):19:1) = 'H';
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*PO2 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPO) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(IMPPO) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPPO) OUTQ(*LIBL/BFCIMPORT)';
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
              msgtxt = 'FTP Error Listing IMPFPCKQ* files: ' + %char(rc);
              WrtLog(#prog: '*ERROR': msgtxt);
              num_files = 0;
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = 'ASPEN';
          //mbrbak = 'X' + %subst(filelist(fileno):11:2)
          //             + %subst(filelist(fileno):15:6);
            // Get file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPCKQ.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPCKQ.FILE/'
                     + %trim(mbrbak) + '.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // put in backup member
            //ftp_get(ftp: filelist(fileno): putbak);

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ADJDEMD '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPCKQ)'
                     + ' JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(PCKADJ) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPADJ) OUTQ(*LIBL/BFCIMPORT)';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              log.pgm = #pgm;
              log.type = 'ERROR    ';
              log.text = 'Error retrieving file from Canopy. '
                       + filelist(fileno);
              WrtLog(log.pgm: log.type: log.text);
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
            mbrnam = 'ASPEN';

            // Get file
          //putstr = '/home/bfc/' + %trim(filelist(fileno));
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFCQTY.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            // backup file
          //ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(IT970CL) PARM(*EXCPTN '
                     + %trim(mbrnam) + ' ' + sq + '001' + sq
                     + ' *INTER *JOB *STD)) JOB(IMPORTCOMP) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(IMPCQTY) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPITEM) OUTQ(*LIBL/BFCIMPORT)';
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

          // Pull list of Order Route files into array
          getpath = %trim(opipth) + 'IMPFWILH*';
          rc = ftp_list(ftp: getpath: 500: %addr(filelist): num_files);
          if rc<0;
            if ErrNum = FTP_NOFILE;
              num_files = 0;
            else;
              // log unknown error **************************
              num_files = 0;
              // log error with connection ******************
              log.pgm = #pgm;
              log.type = 'ERROR    ';
              log.text = 'Error retrieving file list from FTP Server: '
                       + %char(rc) + ' : ' + getpath;
              WrtLog(log.pgm: log.type: log.text);
            endif;
          endif;

          // Process files in array
          gotfiles = 0;
          fileno = 1;

          dow fileno <= num_files;

            // Create member name
            mbrnam = %subst(filelist(fileno):23:8);
            // Get Order header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFORDH4.FILE/'
                     + %trim(mbrnam) + '.MBR';
            // backup file
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
          //ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching Order detail file
              %subst(filelist(fileno):20:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDD4.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            //ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putstr);

              // remove detail
              ftp_delete(ftp: filelist(fileno));
              // remove header
              %subst(filelist(fileno):20:2) = 'H5';
              ftp_delete(ftp: filelist(fileno));
              // remove detail misc
              %subst(filelist(fileno):20:2) = 'DM';
              ftp_delete(ftp: filelist(fileno));
              // remove header misc
              %subst(filelist(fileno):20:2) = 'HM';
              ftp_delete(ftp: filelist(fileno));
              // remove stop flags
              %subst(filelist(fileno):20:2) = 'SF';
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*WILL4 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTORD) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
740bM                + 'MSGQ(IMPORD) OUTQ(' + %trim(sbmoutq) + ')';
740bD            //  + 'MSGQ(IMPORD) OUTQ(*LIBL/BFCIMPORT)';
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

        endsr;  // zzImpWill
      /end-free

