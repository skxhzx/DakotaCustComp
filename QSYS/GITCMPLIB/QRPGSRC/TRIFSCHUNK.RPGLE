      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *  NOTE: Input parm could only be 30 characters (max 33)
     *        because this program is being called from command line.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  TRIFSCHUNK IFS write file chunks to individual files
     *  24 May 2018
     *  Mike Rooker
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D chunk           S            100    dim(200)

     *----------------------------------------------------------------
     *  Working Variables
     *----------------------------------------------------------------


     d fd              s             10I 0
     D forever         S               n
     D dirLen          S              3  0
     D*dirName         S           2048A   varying
     D*prefix          S            100    varying
     D*postfix         S            100    varying
     D dirName         S            100A
     D prefix          S            100
     D postfix         S            100
     D chunkCount      s              3  0
     D i               s              3  0
     D msg             s             32
     D outputFile      s            100
     D chunkData       s         524288

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D CreateOutFile   PR            10i 0
     D OpenOutput      PR            10i 0

     D GetChunks       PR
     D*  fd                          10i 0 const

     D WriteChunks     PR
     D*  fd                          10i 0 const
     D   filename                   100    const
      *
     DDelayB           PR                  Extpgm('DELAY')
     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    dirName
     C                   parm                    outputFile
     C                   parm                    chunkData

      /free
                       //DelayB();
         *inlr = *on;

         //dirName = '/BFCTraxDave/';
         //prefix = 'W001D99999R91485C';
         //postfix = 'ITh001_001_20180515T150334_595.txt';
         //outputFile = 'aaacombo.xml';

         // Open/Create/Clear output file
         CreateOutFile();

         // Create list of chunks

         writeChunks(outputFile);

         return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CreateOutFile Open/Create/Clear output file
     *----------------------------------------------------------------

     p CreateOutFile   b
     d CreateOutFile   pi            10I 0

     *  Local Variables

     d error           S               n
     d xfd             s             10I 0
     d errorStr        s            100A   varying
     d*filename        s           2048A   varying
     d filename        s            100A

      /free

        // Open directory

         filename = %trim(dirName) + %trim(outputFile);

         xfd = open(%trim(fileName):
                   O_TRUNC+O_CREAT+O_WRONLY+O_CODEPAGE:
                   S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:
                   819);

         if xfd < 0;
           errorStr = %str(strerror(errno));
           dsply 'Error creating output file';
           return xfd;
         endif;

         // Close file.

         callp close(xfd);
         return xfd;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  OpenOutput    Open output file
     *----------------------------------------------------------------
     p OpenOutput      b
     d OpenOutput      pi            10I 0

     *  Local Variables

     d error           S               n
     d fd              s             10I 0
     d errorStr        s            100A   varying
     d*filename        s           2048A   varying
     d filename        s            100A

      /free

        // Open directory

         filename = %trim(dirName) + %trim(outputFile);

         fd = open(%trim(fileName):
                   O_WRONLY+O_TEXTDATA);

         if fd < 0;
           errorStr = %str(strerror(errno));
           dsply 'error reopening aaacombo.xml file';
           return fd;
         endif;

        return fd;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  WriteChunks   Write chunk to file
     *----------------------------------------------------------------

     p WriteChunks     b
     d WriteChunks     pi
     d* fd                           10I 0 const
     d  filename                    100A   const

     *  Local Variables

     d ifd             s             10I 0
     D iflags          S             10U 0
     D ilen            S             10I 0
     D wlen            s             10I 0
     D wlenR           s             10I 0
     d buffer          s         524288
     d path            s           2048    varying

      /free

        path = %trim(dirname) + %trim(filename);
        fd = openOutput();

        // Open chunk file
        eval buffer = chunkData;

        // Buffer has been set to 512K, which is the current chunk size

         wlen = write(fd: %addr(buffer): %len(%trimr(buffer)));

       callp close(fd);

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
