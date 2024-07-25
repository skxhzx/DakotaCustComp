     H/COPY *libl/qcopysrc,hspecs
     HDFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  TARGETINTR    Target FTP Interface Retrieval Program
     *  02 October 2014
     *  Rod Roller
     *
     *----------------------------------------------------------------
650  *    10/02/14  RTR  6.50
     *      - Created
700a *    07/17/15  RTR  7.00a
     *      - Changed to get submit jobqs from option record.
740a *    02/13/20  RTR  7.40a
     *      - Added FTP port and timeout from OPTIONINT. This should
     *        resolve occasional process hangs because FTP API defaults
     *        to indefinite timeout.
740bA*    03/03/20  RTR  7.40b
     *      - Revised routine impord to add monitor cmd on IMPFORDD4
     *        ftp get command.
740cA*    03/05/20  RTR  7.40c
     *      - Revised routine impord to add monitor cmd on IMPFORDD4
     *        ftp get command.
     *
     *----------------------------------------------------------------
     *
     *  Compile instructions
     *
     *    CRTRPGMOD MODULE(*) SRCFILE(*) TGTRLS(V4R5M0)
     *
     *    CRTPGM PGM(*) MODULE(*) ACTGRP(*NEW)
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *   - This program is intended to process FTP interfaces for
     *     a Target host system. Target does not FTP but places files
     *     in a folder on their AIX system which we must FTP into and
     *     retrieve the file from.
     *   - Process Summary:
     *     1) Connect to Target server defined in OPTIONS *FTPIMP rec.
     *     2) For each import type, if flag is set in OPTIONS *TARGET,
     *        a) Get list of files for that interface.
     *        b) Ftp 'get' file into Dakota file/member for type.
     *        c) Ftp 'del' file from Target server.
     *        d) Submit interface program using PIRFTPIMP.
     *        e) Repeat for files in list.
     *     3) For each export type, if flag is set in OPTIONS *TARGET,
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
740aAfoptionint if   e           k disk

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
     D opdata          ds
     D  opiftp                 1      1
     D  opisrv                 2     33
     D  opiusr                34     48
     D  opipwd                49     63
     D  opipth                64     95
     D  opiend               117    117

     *----------------------------------------------------------------
     *  *TARGET   -  Target Interface Options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTINT  -  Use Target Interfaces (Y,N)
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
700aA*    OPTJQI  -  Job Queue for Imports
700aA*    OPTJQE  -  Job Queue for Exports
     *
     * Data structure
     *
     D opdatat         ds
     D  optint                 1      1
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
700aAD  optjqi                43     52
700aAD  optjqe                53     62
     D  optend               117    117

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------

     D cmdstr          S            250a
     D cmdlen          S             15p 5
     D ftp             S             10i 0
     D ftpreturn       S             10i 0
     D ftppwd          s             30a
     D ftppath         s             32a
740aAd ftpport         s             10i 0
     D ftpserver       s             30a
740aAd ftptimeout      s             10i 0
     D ftpuser         s             30a
     D mbrbak          s             10a
     D mbrnam          s             10a
     D msgtxt          s           1024a
     D putbak          s            200a
     D putbak2         s            200a
     D putstr          s            200a
740aAd sbmoutq         s             10a
740aAd sbmuser         s             10a

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

     d WrtLog          pr                  extpgm('WRTLOG')
     d                               10    const
     d                               10    const
     d                             1024    const

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
     D main            pr                  extpgm('TARGETINTR')
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
          if %found and opiftp = 'Y';
            ftpserver = opisrv;
            ftpuser = opiusr;
            ftppwd = opipwd;
            ftppath = opipth;

          // If FTP Import not configured, set error
          else;
            pReturn = '*ERROR';
            pMessage = 'FTP Import not configured in OPTIONS.';
            leavesr;
          endif;

          // Retrieve Target interface info from OPTIONS
          opwhse = 1;
          opcode = '*TARGET';

          chain (opwhse: opcode) options;
          if %found;
            opdatat = opdata;
            if optint <> 'Y'
              or optlib = *blanks
              or optjbd = *blanks
700aA         or optjqi = *blanks
700aA         or optjqe = *blanks;
                pReturn = '*ERROR';
                pMessage = 'Target Interface not configured in OPTIONS.';
                leavesr;
            endif;

740aA     // Get options from OPTIONINT
740aA     chain ('Interface': 'FTP Interface': 'FTP Port') optionint;
740aA     if %found;
740aA       ftpport = opivaln;
740aA     else;
740aA       ftpport = 21;
740aA     endif;
740aA     chain ('Interface': 'FTP Interface': 'FTP Timeout') optionint;
740aA     if %found;
740aA       ftptimeout = opivaln;
740aA     else;
740aA       ftptimeout = 15;
740aA     endif;
740aA     chain ('Interface': 'General Options': 'Submit Batch User') optionint;
740aA     if %found;
740aA       sbmuser = opivala;
740aA     else;
740aA       sbmuser = '*CURRENT';
740aA     endif;
740aA     chain ('Interface': 'General Options': 'Interface Outque ') optionint;
740aA     if %found;
740aA       sbmoutq = opivala;
740aA     else;
740aA       sbmoutq = '*CURRENT';
740aA     endif;

          // If FTP Import not configured, set error
          else;
            pReturn = '*ERROR';
            pMessage = 'Target Interface not configured in OPTIONS.';
            leavesr;
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
740aD     //ftp = ftp_conn(%trim(ftpserver): %trim(ftpuser): %trim(ftppwd));
740aM     ftp = ftp_conn(%trim(ftpserver): %trim(ftpuser): %trim(ftppwd)
740aA           :ftpport :ftptimeout);
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
700aD   //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM            + ') JOBQ(' + %trim(optjqe) + ') INLLIBL(*JOBD) '
                 + 'MSGQ(EXPADJ) OUTQ(*LIBL/BFCIMPORT)';
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
700aD   //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM            + ') JOBQ(' + %trim(optjqe) + ') INLLIBL(*JOBD) '
                 + 'MSGQ(EXPPO) OUTQ(*LIBL/BFCIMPORT)';
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
          rc = ftp_list(ftp: 'IMPFITM4*': 500: %addr(filelist): num_files);
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
            mbrnam = 'T' + %subst(filelist(fileno):11:2)
                         + %subst(filelist(fileno):15:6);
            // Get Item file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFITM4.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            putbak2 = '/QSYS.LIB/' + %trim(optlib)
                      + '.LIB/IMPFITM4.FILE/LAST.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // backup file
              ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putbak2);

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ITM4PAR '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTITEM) '
                     + 'JOBD(' + %trim(optjbd)
700aD       //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPITEM) OUTQ(*LIBL/BFCIMPORT)';
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
          rc = ftp_list(ftp: 'IMPFORDH4*': 500: %addr(filelist): num_files);
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
            mbrnam = 'T' + %subst(filelist(fileno):11:2)
                         + %subst(filelist(fileno):15:6);
            // Get Order header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFORDH4.FILE/'
                     + %trim(mbrnam) + '.MBR';
            // backup file
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching Order detail file
              %subst(filelist(fileno):8:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDD4.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
740bA         monitor;
              ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putstr);
740bA         on-error;
740bA           leavesr;
740bA         endmon;

              // Get matching Order detail misc file
              %subst(filelist(fileno):8:2) = 'DM';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDDM.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
740cA         monitor;
              ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putstr);
740cA         on-error;
740cA           leavesr;
740cA         endmon;

              // Get matching Order header misc file
              %subst(filelist(fileno):8:2) = 'HM';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFORDHM.FILE/'
                       + %trim(mbrnam) + '.MBR';
              putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
740cA         monitor;
              ftp_get(ftp: filelist(fileno): putbak);
              ftp_get(ftp: filelist(fileno): putstr);
740cA         on-error;
740cA           leavesr;
740cA         endmon;

              // remove files
              ftp_delete(ftp: filelist(fileno));
              %subst(filelist(fileno):8:2) = 'DM';
              ftp_delete(ftp: filelist(fileno));
              %subst(filelist(fileno):8:2) = 'D4';
              ftp_delete(ftp: filelist(fileno));
              %subst(filelist(fileno):8:2) = 'H4';
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ROUTE4 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTORD) '
                     + 'JOBD(' + %trim(optjbd)
700aD       //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPORD) OUTQ(*LIBL/BFCIMPORT)';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            else;
              // log error with filelist(fileno) ******************
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
          rc = ftp_list(ftp: 'IMPITMO*': 500: %addr(filelist): num_files);
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
            mbrnam = 'O' + %subst(filelist(fileno):8:4)
                         + %subst(filelist(fileno):15:4);
            // Get Item file
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
700aD       //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPDEMD) OUTQ(*LIBL/BFCIMPORT)';
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
          rc = ftp_list(ftp: 'IMPFPOH*': 500: %addr(filelist): num_files);
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
            mbrnam = 'T' + %subst(filelist(fileno):11:2)
                         + %subst(filelist(fileno):15:6);
            // Get PO header file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPOH2.FILE/'
                     + %trim(mbrnam) + '.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // Get matching PO detail file
              %subst(filelist(fileno):7:1) = 'D';
              putstr = '/QSYS.LIB/' + %trim(optlib)
                       + '.LIB/IMPFPOD2.FILE/'
                       + %trim(mbrnam) + '.MBR';
              ftp_get(ftp: filelist(fileno): putstr);

              // remove files
              ftp_delete(ftp: filelist(fileno));
              %subst(filelist(fileno):7:1) = 'H';
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*PO2 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPO) '
                     + 'JOBD(' + %trim(optjbd)
700aD       //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPPO) OUTQ(*LIBL/BFCIMPORT)';
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
          rc = ftp_list(ftp: 'IMPFPCKQ*': 500: %addr(filelist): num_files);
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
            mbrnam = 'T' + %subst(filelist(fileno):11:2)
                         + %subst(filelist(fileno):15:6);
            mbrbak = 'X' + %subst(filelist(fileno):11:2)
                         + %subst(filelist(fileno):15:6);
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
              ftp_get(ftp: filelist(fileno): putbak);

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*ADJDEMD '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(IMPORTPCKQ) '
                     + 'JOBD(' + %trim(optjbd)
700aD       //       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPADJ) OUTQ(*LIBL/BFCIMPORT)';
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
          rc = ftp_list(ftp: 'slotsq_*': 500: %addr(filelist): num_files);
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
            ftp_LinMod(*on);

            // Create member name
            mbrnam = 'Q' + %subst(filelist(fileno):8:4)
                         + %subst(filelist(fileno):14:4);

            // Get file
          //putstr = '/home/bfc/' + %trim(filelist(fileno));
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/impfflat1.FILE/'
                     + %trim(mbrnam) + '.MBR';
            putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            // backup file
            ftp_get(ftp: filelist(fileno): putbak);
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(IT971CL) PARM('
                     + sq + %trim(mbrnam) + sq + ' ' + sq
                     + %trim(putstr) + sq + ')) JOB(IMPORTCOMP) '
                     + 'JOBD(' + %trim(optjbd)
700aD   //           + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM                + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
                     + 'MSGQ(IMPITEM) OUTQ(*LIBL/BFCIMPORT)';
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

            // not processing will call now, delete files from Target
            ftp_delete(ftp: filelist(fileno));
            %subst(filelist(fileno):8:1) = 'D';
            ftp_delete(ftp: filelist(fileno));
            fileno = fileno + 1;

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
700aD     ////       + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
700aM     //         + ') JOBQ(' + %trim(optjqi) + ') INLLIBL(*JOBD) '
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

