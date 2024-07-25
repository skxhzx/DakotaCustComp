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
     *  TRIFSCONC  IFS Concat file chunks
     *  15 May 2018
     *  Dave Sommerville
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
     d xfd             s             10I 0
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

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D CreateOutFile   PR            10i 0
     D OpenOutput      PR            10i 0
     D DeleteFile      PR            10I 0 ExtProc('unlink')
     D   path                          *   Value options(*string)

     D GetChunks       PR
     D*  fd                          10i 0 const

     D AppendChunks    PR
     D*  fd                          10i 0 const
     D   filename                   100    const
     DDelayB           PR                  Extpgm('DELAY')
     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    dirName
     C                   parm                    Prefix
     C                   parm                    Postfix
     C                   parm                    outputFile

      /free
                       //DelayB();
         *inlr = *on;

         //dirName = '/BFCTraxDave/';
         //prefix = 'W001D99999R91485C';
         //postfix = 'ITh001_001_20180515T150334_595.txt';
         //outputFile = 'aaacombo.xml';

         // Open/Create/Clear output file
         CreateOutFile();
         if xfd < 0;
           return;
         endif;

         openOutput();
         if fd < 0;
           return;
         endif;

         // Create list of chunks

         chunkCount = 0;
         //GetChunks(fd);
         GetChunks();

         for i = 1 to chunkCount;
           //AppendChunks(fd: chunk(i));
           AppendChunks(chunk(i));
           //leave;
         endfor;


         // Close ouput file

         //callp close(fd);

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
           dsply 'Error creating aaacombo.xml file';
           return fd;
         endif;

         // Close file and reopen it in text mode.

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
                   O_WRONLY+O_APPEND+O_TEXTDATA);

         if fd < 0;
           errorStr = %str(strerror(errno));
           dsply 'error reopening aaacombo.xml file';
           return fd;
         endif;

        return fd;

      /end-free

     p                 e
     *----------------------------------------------------------------
     *  GetChunks    Get list of chunks
     *----------------------------------------------------------------

     p GetChunks       b
     d GetChunks       pi
     d* fd                           10I 0 const

     *  Local Variables

     d dir             s               *
     d filename        S           2048A   varying
     d mystat          S                   like(statds)
     d filenameLen     s              3  0
     d prefixLen       s              3  0
     d postfixLen      s              3  0
     d chunkAlpha      s              3
     d ChunkNum        s              3  0
     d prefile         s            100
     d posfile         s            100


      /free

        prefixLen = %len(%trim(prefix));
        postfixLen = %len(%trim(postfix));

        // Open directory

        dir = opendir('' + %trim(dirName) + '');

        if dir = *NULL;
           dsply 'Error opening directory';
          return;
        endif;

        // Read directory lookin for chuncks
        // No guarantee that chunks will be read in order.

        p_statds = %addr(mystat);

        dow forever = forever;

          p_dirent = readdir(dir);
          if p_dirent = *null;
            leave;
          endif;

          // Skip if filename doesn't match prefix and postfix

          filename = %subst(d_name:1:d_namelen);
          filenameLen = %len(filename);

          if filenameLen < prefixLen or filenameLen < postfixLen;
            iter;
          endif;

          eval prefile = %subst(filename: 1: prefixLen);
          if %subst(filename: 1: prefixLen) <> prefix;
            iter;
          endif;

          eval posfile =
                %subst(filename: filenameLen-postfixLen+1: postfixLen);
          if %subst(filename: filenameLen-postfixLen+1: postfixLen)
                <> postfix;
            iter;
          endif;

          // Extract chuck number

          chunkAlpha = %subst(filename:
                              prefixLen+1: filenameLen-prefixLen-postfixLen);

          monitor;
            chunkNum = %dec(chunkAlpha: 3: 0);
          on-error;
            msg = 'Invalid chunk number ' + chunkAlpha;
            dsply msg;
          endmon;

          if chunkNum > chunkCount;
            chunkCount = chunkNum;
          endif;

          // Put chunk name in to corresponding array element

          chunk(chunkNum) = filename;


        enddo;

        callp closedir(dir);

        return;

      /end-free

     p                 e


     *----------------------------------------------------------------
     *  AppendChunk    Append chunck to combo file
     *----------------------------------------------------------------

     p AppendChunks    b
     d AppendChunks    pi
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
        // Buffer has been set to 512K, which is the current chunk size

       iflags = o_rdonly + O_TEXTDATA;
       ifd = open(%trimr(path):iflags);
       if ifd < 0;
         die('opendir(): '+%str(strerror(errno)));
         // some kind of error message.....
       endif;

       dow forever = forever;

         ilen = read(ifd: %addr(buffer): %size(buffer));

         if ilen <= 0;
           leave;
         endif;

         wlen = write(fd: %addr(buffer): %len(%trimr(buffer)));

       enddo;

       callp close(ifd);
       callp close(fd);

       // Delete chunk file
       deleteFile(%trim(path));

       return;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
