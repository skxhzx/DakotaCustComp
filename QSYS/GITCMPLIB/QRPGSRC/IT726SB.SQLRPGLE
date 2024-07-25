      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  IT726SB   Stage Export - Item adjustments - LICADJ w/status
     *  18 March 2016
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    03/18/16  RTR  7.00
     *      - Created.
700aA*    08/12/16  MLB  7.00a
     *      - Enh: Added client custom code support to pgm.
700bA*    08/12/16  MLB  7.00b
     *      - Enh: Added INFDS to EXPSADJ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/04/13  MLB  DRY
     *      - Revised pgm to call Host export program, BFCEIA05C to send
     *        exported adjustments to Host JDEdwards system.
     *      - Added /copy mbr, C#FILE1DS to retrieve files library to
     *        pass to Host pgm, along with whse number.
DRYaA*    07/26/18  MLB  DRYa
     *      - Revised pgm to retrieve Before Adjustment Slot Status from
     *        field ADJMEMO, positions 29-30. Load the Before Slot
     *        Status into IETEXT in positions 3-4.
DRYbA*    03/15/19  MLB  DRYb
     *      - Revised pgm to add new file, ITEMADJCW2. This file will be
     *        used to send adjustments to JDE ahead of the actual
     *        adjustment entries to ensure that the quarantine qty's
     *        are updated correctly.
     *      - Revised pgm to map misc1-4 fields into IETEXT field of
     *        ITEMADJCW. There is no room for CWIAMSC5.
     *      - Per Melissa M email dated 02.25.2019
DRYc *    10/20/20  RTR  DRYc
     *      - Revised pgm to add call to EXPSSSTS program SL755S.
     *
     *----------------------------------------------------------------
     * File Specs
     Fexpsadj   o  a e           k disk
700bAF                                     infds(file1ds)
DRYbAFitemadjcw2uf   e           k disk    usropn
DRYbAF                                     infds(file2ds)

     *----------------------------------------------------------------
     *  Data Formats
     D adjrec        e ds                  extname(licadj) inz(*EXTDFT)

     *----------------------------------------------------------------
700aA*  Customer id
700aA*
700aAD client          s             10a
700aAD clientloc       s             10a
DRY A /copy qcopysrc,id#dairyla
700aA
700aA*----------------------------------------------------------------
     *  Program info data structure
      /copy *libl/qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy *libl/qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy *libl/qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Working variables
     D batId           s             11
     D clear           s              5  0
     D cntexp          s              9s 0
     D cntskp          s              9s 0
DRYbAD exportdte       s              8s 0
DRYbAD exporttim       s              6s 0
     D haveBatId       s               n
DRY Ad hrtn            s              8
     D iWhse           s              3  0
     D rtnCode         s             10a
     D rtnMessage      s            200a
     D logMessage      s           1024a
     D stamp           s               z
     D stampUC         s               z

     *----------------------------------------------------------------
     *  Called Program Prototypes
DRYbA*
DRYbAD$CVTDT           DS
DRYbAD $cvcmd                  1      8
DRYbAD $cvprg                  9     18
DRYbAD $cvd6i                 19     24
DRYbAD $cvd8i                 25     32
DRYbAD $cvd6o                 33     38  0
DRYbAD $cvd8o                 39     46  0
DRYbAD $cvsto                 47     64
DRYbAD $cvrtn                 65     72
DRYbAD $cverm                 73    132
DRYbAD $cvmsg                 73     76
DRYbA*
DRYbAD CvtDte          pr                  extpgm('CVTDTE')
DRYbAD  $CVTDT                      132a
DRYbA
     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     D WrtLog          pr                  extpgm('WRTLOG')
     D                               10    const
     D                               10    const
     D                             1024    const
700aA
700aAD GetClient       pr                  extpgm('GETCLIENT')
700aAD* Output
700aAD   Client                      10
700aAD   ClientLoc                   10
DRY A*
DRYcAd RunSL755S       pr                  extpgm('SL755S')
DRYcAd* Input
DRYcAd   xwhsa                        3    const
DRYcA*
DRY Ad DryExportPgm    pr                  Extpgm('BFCEIA05C')
DRY Ad* Input
DRY Ad   $hWhsen                      3  0
DRY Ad   $hbatid                     11
DRY Ad   $hflib                      10
DRY Ad* Output
DRY Ad   $hrtn                        8

700bA*----------------------------------------------------------------
700bA*  File info data structures
700b *----------------------------------------------------------------
700bA
700bA /COPY qcopysrc,c#file1ds
DRYbA /COPY qcopysrc,c#file2ds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     D main            pr                  extpgm('IT726SB')
      * Input
     D   iWhsea                       3    const

     D main            pi
      * Input
     D   iWhsea                       3a   const

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------
      /free

        // Select records not already processed.
        exec Sql
          declare recs dynamic scroll cursor for
            select *
              from licadj
             where adjexpflag = ' ';

        exec sql open recs;
        if sqlstt <> sqlSuccess;
          logMessage = 'SQL:' + sqlstt + ' Unable to open cursor recs.';
          WrtLog(#pgm: '*ERROR': logMessage);
        endif;

        dow forever = forever;

          // Read next record.
          exec sql fetch next from recs
                   into :adjrec;

          // If no more, you are done.
          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if (adjcsys <> 'B' and adjcsys <> 'H')
           or (%subst(adjcode:1:1) = '@')
           or adjitem = *blanks;
            exec sql update licadj
                     set adjexpflag = 'X'
                     where current of recs;
            cntskp = cntskp + 1;
            iter;
          endif;

          if not haveBatId;
            exsr zzzGetBatId;
            if batId = *blanks;
              leave;
            else;
              haveBatId = *on;
            endif;
          endif;

          exsr zzzGetStamps;
          iewhse = adjwhs;
          iebatid = batid;
          ieitem = adjitem;
          iestatus = 'R';
        //ieststs =
        //iestsuc =
DRYaA     if client = Dairyland;
DRYaA   //Send both After Slot Status and Before Slot Status to Host.
DRYaA     ietext = adjstat + %subst(adjmemo:29:2);
DRYaA     else;
DRYaA
          ietext = adjstat;
DRYaA     endif;
DRYaA
          iedate = %int(%char(%date(ADJADDTS): *iso0));
          ietime = %int(%char(%time(ADJADDTS): *hms0));
          ieby = adjaddcusr;
          iewhdp = adjwhdp;
          iedisp = adjdisp;
          iecwta = adjcqta;
          ieqty1 = adjaqty1;
          ieqty2 = adjaqty2;
          ieqty3 = adjaqty3;
          iecode = adjcode;
          iememo = adjmemo;
DRYcA     ieaddts = stamp;
DRYcA     ieadduc = stampuc;
          write ierec;

          cntexp = cntexp + 1;

          exec sql update licadj
                   set adjexpflag = 'S',
                       adjexpts = CURRENT_TIMESTAMP,
                       adjexpuc = CURRENT_TIMESTAMP - CURRENT_TIMEZONE,
                       adjexpjusr = :#user,
                       adjexpjob = :#job,
                       adjexpnbr = :#jobnbr
                   where current of recs;
          if sqlstt <> sqlSuccess;
            logMessage = 'SQL:' + sqlstt + ' Unable to update LICADJ record.';
            WrtLog(#pgm: '*ERROR': logMessage);
          endif;

        enddo;
DRYbA
DRYbA     if client = Dairyland;
DRYbA       exsr zzreadIaCW;
DRYbA     endif;

        exec sql close recs;
        exsr zzzEnd;
DRY A
DRY A    if haveBatId;
DRY A      if client = Dairyland;
DRY A        if sqlstt = sqlSuccess;
DRY A          callp(e) DryExportPgm(iwhse:batid:f1library:hrtn);
DRY A        endif;
DRY A      endif;
DRY A    endif;
DRY A
DRYcA    if client = Dairyland;
DRYcA      RunSL755S(iWhsea);
DRYcA    endif;
DRYcA
        logMessage = 'End of LICADJ Export. ' + batid + ' - '
                   + %trimr(%char(cntexp)) + ' exported, '
                   + %trimr(%char(cntskp)) + ' skipped. ';
        WrtLog(#pgm: '*INFO': logMessage);
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

700aA     GetClient(Client: ClientLoc);

          WrtLog(#pgm: '*INFO': 'Running LICADJ Export.');
          haveBatId = *off;
          iWhse = %dec(iWhsea: 3: 0);

DRYbA     //Retrieve current date and time.
DRYbA     eval $cvcmd = '*CURCMD';
DRYbA     CvtDte ($cvtdt);
DRYbA     eval exportdte = $cvd8o;
DRYbA /end-free
DRYbAC                   time                    exporttim
DRYbA /free

DRYbA     if client = Dairyland;
DRYbA       if not %open(itemadjcw2);
DRYbA         open itemadjcw2;
DRYbA       endif;
DRYbA     endif;
DRYbA
        endsr;
      /end-free

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------
      /free
        begsr *pssr;

          // Attempt to log, may not work.
          monitor;
            WrtLog(#pgm: '*ERROR': 'Abnormal end: *PSSR.');
          on-error;
          endmon;

          // Make sure we don't get caught in an infinite loop
          if pssrflag;
            *inlr = *on;
            return;
          endif;

          pssrflag = *on;
          *inlr = *on;
          return;

        endsr;   // *pssr
      /end-free
DRYbA
DRYbA*----------------------------------------------------------------
DRYbA*  zzReadIaCW   Read ITEMADJCW file for Chef's
DRYbA*----------------------------------------------------------------
DRYbA /free
DRYbA  begsr zzReadIaCW;
DRYbA
DRYbA    exsr zzzGetStamps;
DRYbA    setll (*loval) itemadjcw2;
DRYbA    dow not %eof(itemadjcw2);
DRYbA      read itemadjcw2;
DRYbA        if %eof(itemadjcw2);
DRYbA          leave;
DRYbA        endif;
DRYcM        // getbatid moved from above
DRYbA        if not haveBatId;
DRYbA          exsr zzzGetBatId;
DRYbA          if batId = *blanks;
DRYbA           return;
DRYbA         else;
DRYbA           haveBatId = *on;
DRYbA         endif;
DRYbA       endif;
DRYbA        exsr zzFillieCW;
DRYbA        write ierec;
DRYbA        cwiaudte = exportdte;
DRYbA        cwiautim = exporttim;
DRYbA        update cwiarec;
DRYbA   enddo;
DRYbA
DRYbA  endsr; // zzReadIaCW
DRYbA /end-free
DRYbA
DRYbA*----------------------------------------------------------------
DRYbA*  zzFillieCW   Fill Chefs Warehouse Export Adj fields
DRYbA*----------------------------------------------------------------
DRYbA /free
DRYbA  begsr zzFillieCW;
DRYbA
DRYbA     iewhse = cwiawhse;
DRYbA     iebatid = batid;
DRYbA     ieitem = cwiaitem;
DRYbA     iestatus = 'R';
DRYbA     ietext = %subst(cwiamemo:1:4);
DRYbA     ietext = %replace(cwiamsc1:ietext:41:40);
DRYbA     ietext = %replace(cwiamsc2:ietext:81:40);
DRYbA     ietext = %replace(cwiamsc3:ietext:121:40);
DRYbA     ietext = %replace(cwiamsc4:ietext:161:40);
DRYbA
DRYbA     ieststs= stamp;
DRYbA     iestsuc= stampuc;
DRYbA     iedate = cwiadate;
DRYbA     ietime = cwiatime;
DRYbA     ieby   = cwiaby;
DRYbA     iewhdp = cwiawhdp;
DRYbA     iedisp = cwiadisp;
DRYbA     iecwta = cwiacwta;
DRYbA     ieqty1 = cwiaqty1;
DRYbA     ieqty2 = cwiaqty2;
DRYbA     ieqty3 = cwiaqty3;
DRYbA     iecode = cwiacode;
DRYbA     iememo = cwiamemo;
DRYbA     //Added CW flag to indicate where rcds came from since they won't be
DRYbA     //found in ITEMADJ/LICADJ files. These are from Ed's trigger pgm.
DRYbA     iememo = %replace('CW':iememo:29:2);
DRYbA     ieaddts= stamp;
DRYbA     ieadduc= stampuc;
DRYbA
DRYbA  endsr; // zzFillCWie
DRYbA /end-free

     *----------------------------------------------------------------
     *  zzzEnd     End processing
     *----------------------------------------------------------------
      /free
       begsr zzzEnd;

        exec sql
          update stgbatch
          set sbstatus = 'R',
              sbtext   = ' ',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone
          where sbwhse = :iWhse
            and sbbatid = :batId;

        if sqlstt <> sqlSuccess;
        endif;

       endsr; // zzzEnd
      /end-free

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------
      /free
       begsr zzzGetBatId;
        monitor;
          GetBatId(iWhse: 'EXPADJUST': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

       endsr; // zzzGetBatId
      /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------
      /free
       begsr zzzGetStamps;

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

       endsr; // zzzGetStamps
      /end-free
