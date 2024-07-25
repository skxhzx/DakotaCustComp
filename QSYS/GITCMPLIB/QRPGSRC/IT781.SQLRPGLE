      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  IT781   Create ITEMADJL records - using LICADJ
     *  10 February 2016
     *  Rod Roller
     *
     *  Revisions
     *
700  *    02/10/16  RTR  7.00
     *      - Created from IT780.
700a *    03/02/16  RTR  7.00a
     *      - Fix: Check for system licenses and replace with original
     *        or from licenses.
     *
750  *    12/10/21  KDE  7.50
     *      - Change sql where clause to find record differently
750aA*    12/21/21  RH/MLB  7.50a
     *      - Fix: Revised pgm to correctly search LICLOG for license
     *        records when :plcns = *MUTIPLE.
750bA*    12/22/21  RH/MLB  7.50b
     *      - Fix: Revised pgm to correctly search LICLOG for license
     *        records when :plcns = blanks. The record written to
     *        LICADJ for a Slot Status change to/from any non-active
     *        slot status to/from an active slot status causes the
     *        LICADJ ADJLCNS field to be blank.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    05/18/17  RTR  SBRa
     *      - Changed to convert OSSF to whse 6 in export.
SBRb *    08/01/18  RTR  SBRb
     *      - Changed to convert OSSI to whse 9 in export.
     *
     *----------------------------------------------------------------
     fitemadjl  o  a e             disk
     fexpfadjl  o  a e             disk

     *----------------------------------------------------------------
     * Notes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data structure
     *----------------------------------------------------------------

     D llrec         E ds                  extname(liclog) inz(*EXTDFT)
     D porrec        E ds                  extname(porcv) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Customer id
      /copy qcopysrc,id#sbr

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     d cntrecs         s             10s 0

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     D wkStampBeg      s               z
     D wkStampEnd      s               z

     *----------------------------------------------------------------
     *  Main procedure prototype
     *----------------------------------------------------------------

     d Main            pr                  extpgm('IT781')
     d                                3  0 const
     d                               15    const
     d                                8  0 const
     d                                6  0 const
     d                               10    const
     d                                5    const
     d                               12    const
     d                                5  0 const
     d                                5  0 const
     d                                5  0 const
     d                               15    const
     d Main            pi
     d  pwhs                          3  0 const
     d  pitem                        15a   const
     d  pdate                         8  0 const
     d  ptime                         6  0 const
     d  pby                          10a   const
     d  pwhdp                         5a   const
     d  pdisp                        12a   const
     d  pqty1                         5  0 const
     d  pqty2                         5  0 const
     d  pqty3                         5  0 const
     d  plcns                        15a   const

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CreateTS        pr              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     d CreateDt        pr             8p 0
     d  stamp                          z   const

     d CreateTm        pr             6p 0
     d  stamp                          z   const

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhs        Warehouse
     *      pItem       Item
     *      pDate       Date
     *      pTime       Time
     *      pby         User
     *      pwhdp       Department
     *      pdisp       Slot Display
     *      pqty1       Qty 1
     *      pqty2       Qty 2
     *      pqty3       Qty 3
     *      plcns       License
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        if %parms < 4;
          *inlr = *on;
          return;
        endif;

        // build beginning timestamp from passed date/time
        wkStampBeg = CreateTS(pDate:(PTime)) - %seconds(2);
750 D   //wkStampEnd = CreateTS(pDate:(PTime)) + %seconds(2);
750 M   wkStampEnd = CreateTS(pDate:(PTime)) + %seconds(15);

        // check for invalid range, would cause entire LICLOG to be read
        if wkStampBeg = noStamp
         or wkStampEnd = noStamp;
          *inlr = *on;
            llwhse = pwhs;
            llitem = pitem;
            llaqty1 = pqty1;
            llaqty2 = pqty2;
            llaqty3 = pqty3;
            lllcns = plcns;
            llolcns = plcns;
            exsr WrtAdjl;
            exsr WrtExpl;
            return;
          return;
        endif;

        // Find out if we have any licenses at all
        Exec sql
          Select count(*) into :cntrecs
            from LICLOG
           where LLWHSE = :pWhs
750 D        //and LLITEM = :pItem
750 M        and LLSITEM = :pItem
750 A        and LLDISP = :pDisp
750 A        and LLOLCNS = :pLcns
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
             and LLACTION <> 'USR'
750aA
750aA        or  llwhse = :pWhs
750aA        and LLSITEM = :pItem
750aA        and LLDISP = :pDisp
750aA        and LLADDEUSR = :pby
750bM        and (:pLcns = '*MULTIPLE'
750bA         or  :pLcns = ' ')
750aA        and LLADDTS >= :wkStampBeg
750aA        and LLADDTS <= :wkStampEnd
750aA        and LLACTION <> 'USR';

        // if nothing found, write record and exit
        if SQLSTT <> '00000'
          or cntrecs = 0;
            llwhse = pwhs;
            llitem = pItem;
            llaqty1 = pqty1;
            llaqty2 = pqty2;
            llaqty3 = pqty3;
            lllcns = plcns;
            llolcns = plcns;
            exsr WrtAdjl;
            exsr WrtExpl;
            return;
        endif;

        // Find out if we have an exact qty match
        Exec sql
          Select count(*) into :cntrecs
            from LICLOG
           where LLWHSE = :pWhs
750 D        //and LLITEM = :pItem
750 M        and LLSITEM = :pItem
750 A        and LLDISP = :pDisp
750 A        and LLOLCNS = :pLcns
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
             and LLACTION <> 'USR'
             and LLAQTY1 = :pqty1
             and LLAQTY2 = :pqty2
             and LLAQTY3 = :pqty3;

        // if one qty match found, write record and exit
        if SQLSTT = '00000'
          and cntrecs = 1;
          Exec sql
            Select * into :llrec
              from LICLOG
             where LLWHSE = :pWhs
750 D        //and LLITEM = :pItem
750 M        and LLSITEM = :pItem
750 A        and LLDISP = :pDisp
750 A        and LLOLCNS = :pLcns
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
             and LLACTION <> 'USR'
               and LLAQTY1 = :pqty1
               and LLAQTY2 = :pqty2
               and LLAQTY3 = :pqty3;
            exsr GetPo;
            exsr WrtAdjl;
            exsr WrtExpl;
            return;
        endif;

        // select liclog records matching adjustment
        Exec sql Declare C1 Cursor For
          Select *
            from LICLOG
           where LLWHSE = :pWhs
750 D        //and LLITEM = :pItem
750 M        and LLSITEM = :pItem
750 A        and LLDISP = :pDisp
750 A        and LLOLCNS = :pLcns
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
750aM        and LLACTION <> 'USR'
750aA
750aA        or  llwhse = :pWhs
750aA        and LLSITEM = :pItem
750aA        and LLDISP = :pDisp
750aA        and LLADDEUSR = :pby
750bM        and (:pLcns = '*MULTIPLE'
750bA         or  :pLcns = ' ')
750aA        and LLADDTS >= :wkStampBeg
750aA        and LLADDTS <= :wkStampEnd
750aA        and LLACTION <> 'USR';
        Exec sql Open C1;

        Exec sql Fetch C1 into :llrec;
        dow SQLSTT = '00000';

            exsr GetPo;
            exsr WrtAdjl;
            exsr WrtExpl;

          Exec sql Fetch C1 into :llrec;
        enddo;

        Exec sql Close C1;

        return;

      /end-free

     *----------------------------------------------------------------
     *                      Subroutines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GetPo      Get PO number/sequence for license
     *----------------------------------------------------------------
      /free
        begsr GetPo;

          ialolcns = llolcns;
          Exec Sql Select * into :porrec from PORCV
                    Where PORLIC = :llolcns;

          if SQLSTT <> '00000';
            clear porrec;
          endif;

        endsr;  // GetPo
      /end-free

     *----------------------------------------------------------------
     *  WrtAdjl    Write record to ITEMADJL file
     *----------------------------------------------------------------
      /free
        begsr WrtAdjl;

          if client = SBertram
           and %subst(pdisp:1:3) = 'OSS';
            select;
              when %subst(pdisp:4:1) = 'A';
                llwhse = 1;
              when %subst(pdisp:4:1) = 'B';
                llwhse = 2;
              when %subst(pdisp:4:1) = 'C';
                llwhse = 3;
              when %subst(pdisp:4:1) = 'D';
                llwhse = 4;
              when %subst(pdisp:4:1) = 'E';
                llwhse = 5;
SBRaA         when %subst(pdisp:4:1) = 'F';
SBRaA           llwhse = 6;
SBRbA         when %subst(pdisp:4:1) = 'I';
SBRbA           llwhse = 9;
              other;
                llwhse = pwhs;
            endsl;
          else;
            llwhse = pwhs;
          endif;

          ialwhse =  llwhse;
          ialitem =  llitem;
          ialdate =  pdate;
          ialtime =  ptime;
          ialby =    pby;
          ialwhdp =  pwhdp;
          ialdisp =  pdisp;
          iallcns =  lllcns;
          ialolcns = llolcns;
          ialqty1 =  llaqty1;
          ialqty2 =  llaqty2;
          ialqty3 =  llaqty3;
          ialudte =  %dec(%char(%date():*iso0):8:0);
          ialutim =  %dec(%char(%time():*hms0):6:0);
          ialpo   =  porpo;
          ialseq  =  porseq;

          write ialrec;

        endsr;  // WrtAdjl
      /end-free

     *----------------------------------------------------------------
     *  WrtExpl    Write record to EXPFADJL file
     *----------------------------------------------------------------
      /free
        begsr WrtExpl;

700aA     // fix system licenses
700aA     if %subst(llolcns:1:1) = '*';
700aA       llolcns = llflcns;
700aA     endif;
700aA     if %subst(lllcns:1:1) = '*';
700aA       lllcns = llolcns;
700aA     endif;

700aA     // fix system licenses
700aA     if llwhse = 1
700aA      and llaqty1 < 0;
700aA       llolcns = llflcns;
700aA     endif;

          ielwhse =  llwhse;
          ielitem =  llitem;
          ieldate =  pdate;
          ieltime =  ptime;
          ielby =    pby;
          ielwhdp =  pwhdp;
          ieldisp =  pdisp;
          iellcns =  lllcns;
          ielolcns = llolcns;
750bA
750bA     if plcns = ' ';
750bA     // When activity was due to Slot Status change, use qty sent in.
750bA       ielqty1 =  %editc(pqty1:'L');
750bA       ielqty2 =  %editc(pqty2:'L');
750bA       ielqty3 =  %editc(pqty3:'L');
750bA     else;
750bA
          ielqty1 =  %editc(llaqty1:'L');
          ielqty2 =  %editc(llaqty2:'L');
          ielqty3 =  %editc(llaqty3:'L');
750bA     endif;
750bA
          ielpo   =  porpo;
          ielseq  =  porseq;

          write ielrec;

        endsr;  // WrtExpl
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------
      /free
        begsr *inzsr;

      /end-free
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
      /free

        endsr;
      /end-free

     *----------------------------------------------------------------
     *  CreateTS   Create timestamp from Date/Time
     *----------------------------------------------------------------

     p CreateTS        b
     d CreateTS        pi              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *  Local Variables

     D stamp           s               z
     D temp26          s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6


      /free

        clear stamp;

        if date = 0;
          return stamp;
        endif;

        yyyymmdd = date;
        hhmiss = time;
        temp26 = yyyy + '-' + mm + '-' + dd + '-'
               + hh + '.' + mi + '.' + ss + '.000000';

        monitor;
          stamp = %timestamp(temp26);
        on-error;
          clear stamp;
        endmon;

        return stamp;

      /end-free

     p CreateTS        e

     *----------------------------------------------------------------
     *  CreateDt   Create Date from Timestamp
     *----------------------------------------------------------------

     p CreateDt        b
     d CreateDt        pi             8p 0
     d  stamp                          z   const

     *  Local Variables

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  temp26                 1     26a
     D    yyyyin               1      4
     D    mmin                 6      7
     D    ddin                 9     10

      /free

        clear yyyymmdd;

        if stamp = nostamp;
          return yyyymmdd;
        endif;

        temp26 = %char(stamp);
        yyyy = yyyyin;
        mm = mmin;
        dd = ddin;

        return yyyymmdd;

      /end-free

     p CreateDt        e

     *----------------------------------------------------------------
     *  CreateTm   Create Time from Timestamp
     *----------------------------------------------------------------

     p CreateTm        b
     d CreateTm        pi             6p 0
     d  stamp                          z   const

     *  Local Variables

     D                 ds
     D  hhmmss                 1      6s 0
     D    hh                   1      2
     D    mm                   3      4
     D    ss                   5      6
     D                 ds
     D  temp26                 1     26a
     D    hhin                12     13
     D    mmin                15     16
     D    ssin                18     19

      /free

        clear hhmmss;

        if stamp = nostamp;
          return hhmmss;
        endif;

        temp26 = %char(stamp);
        hh = hhin;
        mm = mmin;
        ss = ssin;

        return hhmmss;

      /end-free

     p CreateTm        e

