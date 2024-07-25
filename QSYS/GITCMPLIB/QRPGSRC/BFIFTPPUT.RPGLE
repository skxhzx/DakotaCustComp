     h/copy *libl/qcopysrc,hspecs
     h dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  BFIFTPPUT     BFC Flexible Interface - FTP Put
     *  01 June 2016
     *  Rod Roller
     *
700  *    07/05/16  RTR  7.00
     *      - Created
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     h bnddir('BFCFTPBND')

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------
     f*ptions   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     * Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     * Function prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.ftpapi

     *----------------------------------------------------------------
     *  Program Variables
     *----------------------------------------------------------------
     d ftpconn         S             10i 0
     d fromstr         s            200a
     d msgtxt          s           1024a
     d tostr           s            200a
     d rc              S             10i 0

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------
     d WrtLog          pr                  extpgm('WRTLOG')
     d                               10    const
     d                               10    const
     d                             1024    const

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pFtpHost   - Interface option key.
     *      pFtpUser   - Interface option key.
     *      pFtpPwd    - Interface option key.
     *      pFilLib    - File library to send.
     *      pFilName   - File name to send.
     *      pFilMbr    - File member to send.
     *      pFtpFile   - FTP put path/file string.
     *
     *    Returned Parameters
     *
     *      pReturn    - *OK, *ERROR.
     *      pMessage   - Message
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('BFIFTPPUT')
     D                               50    const
     D                               10    const
     D                               10    const
     D                               10    const
     D                               10    const
     D                               10    const
     D                              100    const
     D                               10
     D                              200

     D main            pi
     D   pFtpHost                    50    const
     D   pFtpUser                    10    const
     D   pFtpPwd                     10    const
     D   pFilLib                     10    const
     D   pFilName                    10    const
     D   pFilMbr                     10    const
     D   pFtpFile                   100    const
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     *  Let the show begin ...
     *----------------------------------------------------------------
      /free
        exsr zzConnect;

        if pReturn = '*OK';

          fromstr = '/QSYS.LIB/' + %trim(pFilLib) + '.LIB/'
                  + %trim(pFilName) + '.FILE/'
                  + %trim(pFilMbr) + '.MBR';
          tostr = %trim(pFtpFile);
          rc = ftp_put(ftpconn: fromstr: tostr);

          msgtxt = 'File sent: ' + tostr;
          WrtLog(#prog: '*INFO': msgtxt);

          exsr zzClose;

        else;

          msgtxt = 'Error connecting to: ' + pFtpHost;
          WrtLog(#prog: '*INFO': msgtxt);

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

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  zzClose      Close FTP server
     *----------------------------------------------------------------
      /free
        begsr zzClose;

          ftp_quit(ftpconn);

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
          ftpconn = ftp_conn(%trim(pFtpHost): %trim(pFtpUser): %trim(pFtpPwd));
          if ftpconn < 0;
            // return error
            pReturn = '*ERROR';
            pMessage = 'Error connecting to server: ' + %char(ftpconn);
          else;
            // change to ascii so imports aren't garbage
            ftp_binary(*off);
            pReturn = '*OK';
            pMessage = 'Connected.';
          endif;

        endsr;  // zzConnect
      /end-free
