      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (630) 790-8383
     *----------------------------------------------------------------
     *
     *  TRKROWCOL  Truck Builder - Determine Row/Col for Truck Map sent
     *  13 April 2018
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720 A*    04/13/18  KDE  7.20
     *      - Created
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     * Notes:
     *
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Foptions   if   e           k disk
     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------
     *
     *----------------------------------------------------------------
     *  Customer id
     *
     D                 ds
     D  client                 1     10
     D  cliloc                11     20
     D @getcl          c                   const('GETCLIENT')
     *

      *----------------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D wkrec           Ds
     d  topl                   1      6
     d  botr                   7     12
     d  rowcol                13     15

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *
     *----------------------------------------------------------------
     *  *GENPICK -  General picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N).
     *    OPNRSC  -  Number of pallet sections (1-9).
     *    OPPLSQ  -  Load Sequence
     *
     * Data structure
     *
     D opdata          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4  0
     D  opplsq                 7      7
     D  optend               117    117
     *----------------------------------------------------------------
     * Variable
     *----------------------------------------------------------------
     D recnumber       s             10p 0
     D seq             s              7  0
     D toplchar        s              6
     D botrchar        s              6
     D row             s              2  0
     D col             s              1  0
     D rc              s              3
     d yFrom           s              3
     d yTo             s              3

     *----------------------------------------------------------------
     *  XY Top Left points
     *----------------------------------------------------------------
     D                 ds
     d topla                                dim(200)
     D  toplx                         3  0  overlay(topla:*next)
     D  toply                         3  0  overlay(topla:*next)

     *----------------------------------------------------------------
     *  XY Bottom Right points
     *----------------------------------------------------------------
     D                 ds
     d botra                               dim(200)
     D  botrx                         3  0  overlay(botra:*next)
     D  botry                         3  0  overlay(botra:*next)

     *----------------------------------------------------------------
     *  XY Top Right points (calculated from Top left/Bottom right)
     *----------------------------------------------------------------
     D                 ds
     d Topra                                dim(200)
     D  Toprx                         3  0  overlay(topra:*next)
     D  Topry                         3  0  overlay(topra:*next)

     *----------------------------------------------------------------
     *  XY Bottom Left points (calculated from Top left/Bottom right)
     *----------------------------------------------------------------
     D                 ds
     d botla                                dim(200)
     D  botlx                         3  0  overlay(botla:*next)
     D  botly                         3  0  overlay(botla:*next)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse
     *      $PRTID  Route ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $scenario         1
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     *
      /free
               exsr loadXYpts;
               exsr bldTruck;
      /end-free
     *
     * Close up shop and return home.
     *
     C                   eval      *inlr = *on
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     * Get client id
     *
     C                   call      @getcl
     C                   parm                    client
     *
     *    Get general picking options from OPTIONS file.
     *
      /free
        //   chain ($pWhse:'*GENPICK') options;
      /end-free
     C*                  if        not %found(options)
     C*                  eval      operpt = 'Y'
     C*                  eval      opelbl = 'N'
     C*                  eval      opnrsc = 1
     C*                  eval      opplsq = '1'
     C*                  endif
     *
     C                   endsr
     * ----------------------------------------------------------------------------------*
     *  loadXYpts -  Load the Xy points for Top left and Bottom right of Truck           *
     *               pallet positions                                                    *
     * ----------------------------------------------------------------------------------*
     C     loadXYpts     begsr
      /free
           clear toplx;
           clear toply;
           clear botrx;
           clear botry;
        if $scenario = '1';
           // Truck 1 for DragDrop 2.0 Truck Grid
           // Load Top Left XY axis
                 toplx(1)=0;
                 toply(1)=0;
                 toplx(2)=0;
                 toply(2)=48;
                 toplx(3)=0;
                 toply(3)=81;
                 toplx(4)=0;
                 toply(4)=114;
                 toplx(5)=0;
                 toply(5)=147;
                 toplx(6)=0;
                 toply(6)=180;
                 toplx(7)=33;
                 toply(7)=0;
                 toplx(8)=66;
                 toply(8)=0;
                 toplx(9)=48;
                 toply(9)=48;
                 toplx(10)=48;
                 toply(10)=96;
                 toplx(11)=48;
                 toply(11)=147;
                 toplx(12)=33;
                 toply(12)=180;
                 toplx(13)=66;
                 toply(13)=180;

           // Truck 1 for DragDrop 2.0 Truck Grid
           // Load Bottom Right XY axis
                 botrx(1)=30;
                 botry(1)=45;
                 botrx(2)=45;
                 botry(2)=78;
                 botrx(3)=45;
                 botry(3)=111;
                 botrx(4)=45;
                 botry(4)=144;
                 botrx(5)=45;
                 botry(5)=177;
                 botrx(6)=30;
                 botry(6)=225;
                 botrx(7)=63;
                 botry(7)=45;
                 botrx(8)=96;
                 botry(8)=45;
                 botrx(9)=78;
                 botry(9)=93;
                 botrx(10)=78;
                 botry(10)=141;
                 botrx(11)=93;
                 botry(11)=177;
                 botrx(12)=66;
                 botry(12)=225;
                 botrx(13)=96;
                 botry(13)=225;
          else;
           // Truck 2 for DragDrop 2.0 Truck Grid
           // Load Top Left XY axis
                 toplx(1)=0;
                 toply(1)=0;
                 toplx(2)=0;
                 toply(2)=43;
                 toplx(3)=0;
                 toply(3)=86;
                 toplx(4)=0;
                 toply(4)=129;
                 toplx(5)=0;
                 toply(5)=172;
                 toplx(6)=0;
                 toply(6)=215;
                 toplx(7)=51;
                 toply(7)=0;
                 toplx(8)=51;
                 toply(8)=48;
                 toplx(9)=51;
                 toply(9)=99;
                 toplx(10)=51;
                 toply(10)=147;
                 toplx(11)=51;
                 toply(11)=195;

           // Truck 1 for DragDrop 2.0 Truck Grid
           // Load Bottom Right XY axis
                 botrx(1)=48;
                 botry(1)=40;
                 botrx(2)=48;
                 botry(2)=83;
                 botrx(3)=48;
                 botry(3)=126;
                 botrx(4)=48;
                 botry(4)=169;
                 botrx(5)=48;
                 botry(5)=212;
                 botrx(6)=48;
                 botry(6)=255;
                 botrx(7)=91;
                 botry(7)=48;
                 botrx(8)=91;
                 botry(8)=99;
                 botrx(9)=91;
                 botry(9)=147;
                 botrx(10)=91;
                 botry(10)=195;
                 botrx(11)=91;
                 botry(11)=243;
          endif;
      /end-free
     C                   endsr
     * ----------------------------------------------------------------------------------*
     *  bldTruck  -  Determine Truck Rows and Columns based on incoming x,y pairs        *
     *               x,y is sent for top left and bottom right of pallet position        *
     * ----------------------------------------------------------------------------------*
     C     bldTruck      begsr
      /free

            row=1;
            col=1;
            // Create SQL Work File in Qtemp
            exec sql drop table qtemp/kenwork;
            exec sql create table qtemp/kenwork
                    (topl char(6), botr char(6), rowcol char(3))
                    rcdfmt wkrec;

            exec sql delete from kenwork;

            // Load XY Top left and XY Bottom Right points into SQL work file
            // X Top left is loaded as "000000" where X is 000 and Y is 0000
            // Y Bottom right is loaded as "000000" where X is 000 and Y is 000
            seq=1;
            dow seq<201;
               if toplx(seq)=*zeros and botrx(seq)=*zeros
                  and toply(seq)=*zeros and botry(seq)=*zeros;
                  leave;
               else;
                  toplchar = %editc(toplx(seq):'X') + %editc(toply(seq):'X');
                  botrchar = %editc(botrx(seq):'X') + %editc(botry(seq):'X');
               endif;
               // insert xypts into sql work file
               exec sql insert into kenwork
                  values(:toplchar, :botrchar, ' ');
               seq=seq+1;
            enddo;

            sqlstmt = 'select * from KENWORK ' +
                      'order by topl,botr';

            exec sql PREPARE tb FROM :SqlStmt;
            exec sql DECLARE tpbt SCROLL CURSOR FOR tb;
            exec sql OPEN tpbt;

            exec sql fetch first from tpbt into :wkrec;

             dow sqlStt = sqlSuccess;

                exec sql select rowcol into :rowcol
                   from kenwork
                     where topl=:topl and botr=:botr;
                if rowCol <>*blanks;
      /end-free
     c                   goto      rdNext
      /free
                endif;
                rc = %editc(row:'X') + %editc(col:'X');
                exec sql
                  update kenwork set rowcol = :rc
                        where topl=:topl and botr = :botr;
                rowcol = rc;
                yFrom = %subst(topl:4:3);
                yTo = %subst(botr:4:3);
                // Now look look in sql work file for other xypts
                // that have edges that falls within the xy points
                // of currently read xy pts
                sqlstmt = 'select rrn(a) from qtemp/kenwork as a ' +
                          'where substring(a.topl,4,3) >= ' + sq +
                          %trim(yFrom) + sq + ' and ' +
                          'substring(a.topl,4,3) <= ' + sq + %trim(yTo) + sq +
                          'and rowcol=' + sq + ' ' + sq +
                          ' order by a.topl,a.botr';

                exec sql PREPARE sl FROM :SqlStmt;
                exec sql DECLARE selct SCROLL CURSOR FOR sl;
                exec sql OPEN selct;

                exec sql fetch first from selct into :recNumber;

                dow sqlStt = sqlSuccess;
                   // update the relative record number with new row/column
                   col = col +1;
                   rc = %editc(row:'X') + %editc(col:'X');
                   exec sql
                     update kenwork set rowcol = :rc
                           where rrn(kenwork) = :recNumber;
                   exec sql fetch next from selct into :recNumber;
                enddo;
                exec sql close selct;
                row=row+1;
                col = 1;
      /end-free
     c     rdNext        Tag
      /free
                exec sql fetch next from tpbt into :wkrec;

             enddo;
             exec sql close tpbt;

      /end-free
     C                   endsr
