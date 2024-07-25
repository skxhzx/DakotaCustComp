     H/COPY *libl/qcopysrc,hspecs
     HDFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PI410     FTP Import - P.O. Smartdock file NEP
     *  Rod Roller
     *  11 July 2017
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710a *    07/11/17  RTR  7.10a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *
     H bnddir('BFCFTPBND')

     *----------------------------------------------------------------
     *  Standard variables and constants
     *
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program info data structure
     *
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Function prototypes.
     *
      /copy qcopysrc,p.ftpapi
      /copy qcopysrc,p.getopint

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *
     d RunCmd          pr                  extpgm('QCMDEXC')
     d  parmcmd                     250
     d  parmlen                      15  5

     d WrtLog          pr                  extpgm('WRTLOG')
     d                               10    const
     d                               10    const
     d                             1024    const

     *----------------------------------------------------------------
     *  Working Variables
     *
     d cmdstr          S            250a
     d cmdlen          S             15p 5
     d ftp             S             10i 0
     d ftpreturn       S             10i 0
     d ftppwd          s             30a
     d ftppath         s             32a
     d ftpserver       s             30a
     d ftpuser         s             30a
     d mbrbak          s             10a
     d mbrnam          s             10a
     d msgtxt          s           1024a
     d optjbd          s             10a
     d optlib          s             10a
     d preturn         s             10a
     d putbak          s            200a
     d putbak2         s            200a
     d putstr          s            200a

     d filelist        S            256a   dim(500)
     d num_files       S             10i 0
     d fileno          S             10i 0
     d rc              S             10i 0
     d ErrNum          S             10i 0
     d gotfiles        S             10i 0

     d*cmdexcerr       s              1    inz('0')
     d*rtnCode         s             10
     d*rtnMessage      s            200
     d*stamp           s               z
     d*stampUC         s               z

     d*dsWhse          ds
     d* batWhse                1      3  0
     d* batWhsea               1      3a

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

        exsr zzConnect;

        if pReturn = '*OK';

          exsr zzImport;

        endif;

        // We are finished so get out
        *inlr = *on;
        return;

      /end-free

     *----------------------------------------------------------------
     *
     *          Subroutines In Alphabetical Order
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

         // Retrieve FTP info from OPTIONS
         pReturn = '*OK';
         optint.type = 'Import';
         optint.cat = 'Powerdock';

         optint.name = 'FTP Server';
         GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                   optint.valn: optint.vala: optint.return);
         if optint.return = '*OK';
           ftpserver = optint.vala;
         else;
           ftpserver = *blanks;
           pReturn = '*ERROR';
         endif;

         optint.name = 'FTP User';
         GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                   optint.valn: optint.vala: optint.return);
         if optint.return = '*OK';
           ftpuser = optint.vala;
         else;
           ftpuser = *blanks;
           pReturn = '*ERROR';
         endif;

         optint.name = 'FTP Password';
         GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                   optint.valn: optint.vala: optint.return);
         if optint.return = '*OK';
           ftppwd = optint.vala;
         else;
           ftppwd = *blanks;
           pReturn = '*ERROR';
         endif;

         optint.name = 'Submit Jobd';
         GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                   optint.valn: optint.vala: optint.return);
         if optint.return = '*OK';
           optjbd = optint.vala;
         else;
           optjbd = *blanks;
           pReturn = '*ERROR';
         endif;

         optint.name = 'Current Library';
         GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
                   optint.valn: optint.vala: optint.return);
         if optint.return = '*OK';
           optlib = optint.vala;
         else;
           optlib = *blanks;
           pReturn = '*ERROR';
         endif;

        endsr;  // *inzsr
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
          ftp = ftp_conn(%trim(ftpserver): %trim(ftpuser): %trim(ftppwd));
          if ftp < 0;
            // return error
          //pReturn = '*ERROR';
          //pMessage = 'Error connecting to server: ' + %char(ftp);
          else;
            // change to ascii so imports aren't garbage
            ftp_binary(*off);
          endif;

        endsr;  // zzConnect
      /end-free

     *----------------------------------------------------------------
     *  zzImport     Imports Files
     *----------------------------------------------------------------
      /free
        begsr zzImport;

          // Pull list of files into array
          rc = ftp_list(ftp: '/OUT/smartdoc.*': 500: %addr(filelist):
               num_files);
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
            mbrnam = 'SD' + %subst(filelist(fileno):15:3);
            // Get file
            putstr = '/QSYS.LIB/' + %trim(optlib)
                     + '.LIB/IMPFPOSD.FILE/'
                     + %trim(mbrnam) + '.MBR';
            //putbak = '/home/bfc/backup/' + %trim(filelist(fileno));
            //putbak2 = '/QSYS.LIB/' + %trim(optlib)
            //          + '.LIB/IMPFITM4.FILE/LAST.MBR';
            if ftp_get(ftp: filelist(fileno): putstr)>=0;
              gotfiles = gotfiles + 1;

              // backup file
              //ftp_get(ftp: filelist(fileno): putbak);
              //ftp_get(ftp: filelist(fileno): putbak2);

              // remove file
              ftp_delete(ftp: filelist(fileno));

              // submit that sucker!
              cmdstr = 'SBMJOB CMD(CALL PGM(PIRFTPIMP) PARM(*POSD1 '
                     + %trim(mbrnam) + ' *INTER *JOB *STD)) JOB(BFCPOSDIMP) '
                     + 'JOBD(' + %trim(optjbd)
                     + ') JOBQ(QBATCH) INLLIBL(*JOBD) '
                     + 'MSGQ(IMPPOSD) OUTQ(*LIBL/BFCTEST)';
              cmdlen = %len(%trim(cmdstr));
              RunCmd ( cmdstr : cmdlen );
              msgtxt = cmdstr;
              WrtLog(#prog: '*INFO': msgtxt);

            endif;
            fileno = fileno + 1;
          enddo;

        endsr; // zzImport
      /end-free
