      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     H BNDDIR('QC2LE':'BFCIFSBND':'BFCBND')
     *----------------------------------------------------------------
     *
     *  CRTCATOUTL   Create catout log session id summary
     *  19 May 2015
     *  Dave Sommerville
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    - Source code for this program courtesy of Scott Klement's
     *      Working with the IFS in RPG IV e-book.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fglotomsrv if   e           k disk
     Fcatoutlog o  a e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D sessIdList      S             40    dim(50)

     *----------------------------------------------------------------
     *  Prototypes and IFS variables
     *----------------------------------------------------------------

     D/copy qcopysrc,c#ifsio_h
     D/copy qcopysrc,c#errno_h

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dir             s               *
     D filename        S            640A
     D forever         S              1A   inz('1')
     D ifd             S             10I 0
     D iflags          S             10U 0
     D msg             S             52A
     D path            S            640A
     D rddata          S            512A
     D pos             S              3  0 inz(0)
     D sessId          S             40A
     D count           S              3  0 inz(0)

     *----------------------------------------------------------------
     * Mainline
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         dow forever = forever;

            read glotomsrv;

            if %eof(glotomsrv);
              leave;
            endif;

            if gtsapploc = ' ';
              iter;
            endif;

            colSessId = '';
            colFile = '';
            colPort = gtsport;
            colFolder = %trim(gtstompath) + '/' + %trim(gtsapploc) + '/logs';
            write(e) colrec;

            // Open director (no '/' at end)

            dir = opendir('' + %trimr(colFolder) + '');

            if dir = *NULL;
              msg = 'Directory not found: ' + colFolder;
              //dsply msg;
              iter;
            endif;

            // Process directory

            dow forever = forever;

              p_dirent = readdir(dir);

              select;
                when p_dirent = *null;
                  leave;
                other;
                  colfile = %subst(d_name:1:d_namelen);
                  if %subst(colfile: 1: 6) = 'catout';
                    colSessId = '';
                    write(e) colrec;
                    exsr ProcessFile;
                  endif;
              endsl;

            enddo;

            callp closedir(dir);

         enddo;

      /end-free

     *----------------------------------------------------------------
     *
     *          Subroutines in Alphabetical Order
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ProcessFile    Process file
     *----------------------------------------------------------------

      /free
       begsr ProcessFile;

         path = %trimr(colfolder) + '/' + colfile;
         iflags = o_rdonly + o_textdata;
         ifd = open(%trimr(path):iflags);
         if ifd < 0;
           callp die('opendir(): '+%str(strerror(errno)));
           // some kind of error message.....
         endif;

         // Read file by line looking

         dow readline(ifd: %addr(rddata):%size(rddata))>=0;

           // Grab session id from record with GetLnkPgm

           pos = %scan('GetLnkPgm': rddata);
           if pos > 0;
             colSessId = %subst(rddata: pos+11: 32);
             exsr AddToList;
           endif;

         enddo;

         // Close Import Data file opened for read.

         callp close(ifd);

       endsr;

      /end-free

     *----------------------------------------------------------------
     *  AddToList   Add session id to list
     *----------------------------------------------------------------

      /free
       begsr AddToList;

         pos = %lookup(colSessId : sessIdList);
         if pos > 0;
           leavesr;
         endif;

         if count < 50;
           count += 1;
           sessIdList(count) = colSessId;
           write(e) colrec;
         endif;

       endsr;

      /end-free

     *----------------------------------------------------------------
     *          IFS Procedure API's / Error Handling
     *----------------------------------------------------------------
      /define errno_load_procedure
      /copy qcopysrc,c#errno_h
