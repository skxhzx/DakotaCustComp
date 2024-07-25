     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  OI400   Create Xref between File Import Member and Actual IFS file being imported
     *  20 January 2020
     *  Kenneth Elder
     *
     *  Revisions
     *
510 A*    01/20/20  KDE  7.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftbfmtoifs uf a e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#usfcorp

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D whse            s              3  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $whse    -  Warehouse  (Char)
     *     $Mbr     -  File Member in IMPFORDH
     *     &path    -  IFS Actual File being imported
     *
     *  Output parameters
     *
     *     None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $mbr             10
     C                   parm                    $path            80

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
          if $whse='000';
             $whse='001';
          endif;
          monitor;
            whse = %dec($whse:3:0);
          on-error;
            whse=1;
          endmon;

          chain (whse:$mbr) tbfmtoifs;
          if %found(tbfmtoifs);
            twfaddts=noStamp;
            update twfrec;
          else;
            twfwhs=whse;
            twfmbr=$mbr;
            twfifn=%trim($path);
            twfaddts=nostamp;
            twfjob=#job;
            twfuser=#user;
            twfjobn=#jobn;
            write twfrec;
          endif;
      /end-free

     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return
