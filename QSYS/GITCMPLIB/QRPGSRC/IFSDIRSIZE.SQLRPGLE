710 AH dftactgrp( *NO )
     H   actgrp( *NEW )
     H bnddir( 'QC2LE' )

     f*  Files
710kAfifsDirSizeif a e           k disk    usropn
710kAfifsDirLog o    e           k disk    usropn

      /copy qcopysrc,c#stdsql
     D PATHTOLIST      s            256

       // ---  Prototypes  ---
     D main            PR                    ExtPgm('IFSDIRSIZE')
     D                               32
     D                                1
       // --- Main procedure interface ---
     D main            PI
     D   ppPath                      32
     D   ppLog                        1

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0

     d calcDirSize     PR           414
     d  drnm                        384    value

     d ifsdircl        pr                  extpgm('IFSDIRCL')
     d  pPath                       384
     d  pName                       384
     d  pLevel                        3

     D* a few local variables...
     d @command        s            350
     d FileName        s             21
     d returnCode      s             10i 0
     d sq              c                   x'7d'
     d posHold         s              5  0
     d dirHold         s            384
     d pathlevel       s              3  0
     D wrkPath         s            384
     D Msg             s            100
     D Name            s            384
     D dir             s               *
     D ErrorFree       s               n
     D rtnVal          s             10u 0
     D reccnt          s              7  0
     d level           s              3  0
     d wk_type         s             10
     d wk_alcsize      s             15  0
     d wk_entries      s             10  0
     d y               s              3  0

      *  Variable Length definition used for path field in file IFSDIRSIZE
     D ifsPath         s            384a   inz(' ') varying

      *  Return Directory information (Name, Size in Bytes and File Count
     D drValues        ds           414
     d  drName                      384    inz(' ')
     D  drFileSize                   15p 0 inz(0)
     D  drFileCnt                    15p 0 inz(0)

     d  pDirEnt        s            384    inz(' ')
     d  pDirBk         s                   like(pDirEnt) dim(100)

      /free

       // clear flat text file and append this html to flat file
       @command = 'CLRPFM FILE(IFSDIRSIZE)';
       returnCode = goCmd(%trim(@command));
       @command = 'CLRPFM FILE(IFSDIRlog)';
       returnCode = goCmd(%trim(@command));

       if not %open(ifsdirsize);
          open ifsdirsize;
       endif;
       if not %open(ifsdirlog);
          open ifsdirlog;
       endif;

       //  Open up the directory.
       // Make sure you close off path with '/' or it will not work
       // pathtoList = '/home/DMOTOMDKTAA/';
       // pathtoList = '/Tomcat618/Webapps/proddataxxx/';
       // start from root directory
       // pathtoList = '/';
       pathtoList = ppPath;
       pathlevel=1;

       drValues = calcDirSize(pathToList);

       *inlr = *on;
       return;
       //  End Program
      /end-free

      * Calculate and write Directory Sizes for IFS

     p calcDirSize     b

     fifsDir    uf a e           k disk    USROPN
     f                                     Extfile(FileName)

     d calcDirSize     pi           414
     d  pDirent                     384    value
     d  pSize          s             15p 0
     d  pFiles         s             15p 0
      *
     d  recurPath      s            384
     d  pPath          s            384
     d  pName          s            384
     d  pfilel         s             10
     d  position       s              5  0

     d  dd             ds                  LikeRec(ifssrc: *input) inz
      *
      /free
         // loop through directories using QSH.
         // Will start with passed in path and read
         // each directory after that doing recursive
         // calls to this same procedure as you go levels
         // deep. This sub-procedure will use QSH to put
         // entries for each directory in file IFSDIR. It
         // will then use SQL to get entry count and total
         // directory size. Lastly it will read each
         // directory in this directory and make recusive
         // calls to do the same for that directory
         // As a subprocedure file IFSDIR is being opened
         // along with record pointer being maintained for
         // each recursive call
         pDirBk(pathlevel) = %trim(pDirent);
         pPath = %trim(pDirEnt);
         pName = *blanks;

         // This CL will create the individual directory listing file
         // per the level deep it currently is.  These files get
         // created in QTEMP and go away when job ends.  As different
         // libraries reuse the same level file it is cleared
         pfilel = 'IFSDIR' + %char(pathlevel);
         callp ifsdircl (pPath:pName:pfilel);     // create ifsdir file

         // get position of where directory names begin in record
         // based on the .. directory record.  Found in testing the
         // so called fixed record length that QSH builds can be several
         // positions off from directory to directory
         position=0;
         // get starting position of directory name in ifsdirxxx file
         // created in CL ifsdircl above.  This creates a QSH file
         // we are using SQL below to get the stating directory position
         // by looking for the standard '..' directory
         sqlStmt = 'select instr(' + 'IFSFLD' + ','
                   + sq + '..' + sq + ',25) ' + 'from QTEMP/' + pfilel +
                  ' where instr(' + 'IFSFLD' + ',' +
                           sq + '..' + sq +
                          ',25)<>0 fetch first row only';
         exec sql PREPARE post FROM :SqlStmt;
         exec sql DECLARE posr SCROLL CURSOR FOR post;
         exec sql OPEN posr;
         exec sql fetch first from posr into :position;
         exec sql close posr;

         wk_entries =0;
         wk_alcsize =0;

         // get number of entries and allocated size for directory in kb
         // excluding the '.' and '..' directories
         sqlStmt = 'select count(*),sum(cast(substring(' +
                    'IFSFLD' + ',1,20) as int))' +
                    ' from QTEMP/' + pfilel +
                    ' where substring(' + 'IFSFLD' + ',1,5)' +
                       ' = ' + sq + '     ' + sq + ' and substring' +
                     '(IFSFLD,' + %char(position) + ',2)<>' + sq + '..' +
                     sq + ' and substring(IFSFLD,' + %char(position) +
                     ',2)<>' + sq + '. ' + sq;
         exec sql PREPARE cntt FROM :SqlStmt;
         exec sql DECLARE cntr SCROLL CURSOR FOR cntt;
         exec sql OPEN cntr;
         exec sql fetch first from cntr into :wk_entries,:wk_alcsize;
         exec sql close cntr;

         if wk_entries < 0;
            wk_entries = 0;
            wk_alcsize = 0;
         endif;

         // add base entry count and allocated usage to counters for directory
         psize = psize + wk_alcsize;
         pFiles= pFiles + wk_entries;

         // delete everything other than directory entires
         // from the ifsdir work file for this level
         sqlStmt = 'delete from QTEMP/' + %trim(pfilel) +
                    ' where substring(' + 'IFSFLD' + ',22,1)' +
                      '<>' + sq + 'd' + sq;
         exec sql execute immediate :sqlStmt;

         // now loop through directory and make recursive call
         // for any sub-directories
         FileName = 'QTEMP/' + %trim(pfilel);
         if not %open(ifsdir);
            open ifsdir;
         endif;
         read ifsdir dd;

         dow not %eof(ifsdir);

            wk_type = '*DIR';

            if position <> 0;
               // write log record to understand how written
               Name = %trim(%subst(dd.ifsfld:position:
                             %len(%trim(dd.ifsfld))));
               ilpath = %trim(pDirent) + '/' + %trim(%subst(dd.ifsfld:position:
                             %len(%trim(dd.ifsfld))));

               // exclude '.', '..', IBM Q direcotries first level
               if ((%subst(name:1:1)<>'Q' and %subst(name:1:1)<>'q')
                 or ((%subst(name:1:1)='Q' or %subst(name:1:1)='q')
                 and pathLevel > 2))
                 and %trim(name) <> '.'
                 and %trim(name) <> '..'
                 and %trim(name) <> *blanks;

                  iltype = wk_type;
                  ilqsh = 'N';
                  ilsqlfind = 'O';
                  illevel = pathlevel;
                  eval ilpath = %trim(ilpath);
                  if ppLog = 'Y';
                     write ilrec;
                  endif;

                  // process the directory entry...
                  // When sub-directory we must call this procedure
                  // recursively to calculate the full size to return
                  // make sure pDirEnt has / on end of it before appending
                  // next name
                  if %subst(pDirent:%len(%trim(pDirEnt)):1)<>'/';
                     %subst(pDirent:%len(%trim(pDirEnt))+1:1)='/';
                  endif;
                  recurPath = %trim(pDirent) + %trim(Name);
                  pathlevel = pathlevel + 1;
                  // call this subprocedure recusively to gather info
                  // for each subdirectory
                  drValues = calcDirSize(recurPath);
                  monitor;
                     pSize = pSize + drFileSize;
                  on-error;
                  pSize=*zeros;
                  endmon;
                  monitor;
                     pfiles = pfiles + drFileCnt;
                  on-error;
                     pfiles=*zeros;
                  endmon;
               endif;
            endif;
            //exec sql fetch next from filr into :ifsdrr;
            read ifsdir dd;
         enddo;

         // exec sql close filr;
         close ifsdir;
         drName = pdirent;
         drFileSize = psize;
         drFileCnt = pFiles;
         level = pathLevel;
         pathlevel = pathlevel - 1;
         if pathlevel > 0;
            pDirEnt = pDirBk(pathlevel);
            pDirBk(pathLevel+1) = *blanks;
         else;
            pathlevel = 1;
            pDirent = pDirBk(pathLevel);
            pDirBk(pathLevel) = *blanks;
         endif;
         // create record in Directory Size Work File
         // if (drFileSize<>*zeros or drFileCnt<>*zeros)
         if pathLevel <= 10;
            chain drName ifsDirSize;
            if %found(ifsDirSize);
               drName=drName;
            else;
               eval ifspath = %trim(drName);
               iffilecnt = drFileCnt;
               ifDirSize = drFileSize;
               iflevel = level;
               write ifsrec;
            endif;
         endif;
         return drValues;

      /end-free
     p                 e
