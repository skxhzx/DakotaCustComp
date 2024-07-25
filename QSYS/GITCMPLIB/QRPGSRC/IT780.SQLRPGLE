      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  IT780   Create ITEMADJL records
     *  25 March 2013
     *  Rod Roller
     *
     *  Revisions
     *
650  *    03/25/13  RTR  6.50
     *      - Created.
700a *    02/10/16  RTR  7.00a
     *      - Fix: Timestamp calc didn't work when time seconds
     *        were 00, 01, or 59.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    01/21/15  RTR  SBRa
     *      - Revise to uppercase DEPT and default blank dept to BLANK.
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

     d Main            pr                  extpgm('IT780')
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
700aD   // wkStampBeg = CreateTS(pDate:(PTime-1));
700aM   wkStampBeg = CreateTS(pDate:(PTime))-%seconds(2);
700aD   // wkStampEnd = CreateTS(pDate:(PTime+1));
700aM   wkStampEnd = CreateTS(pDate:(PTime))+%seconds(2);

        // check for invalid range, would cause entire LICLOG to be read
        if wkStampBeg = noStamp
         or wkStampEnd = noStamp;
          *inlr = *on;
          return;
        endif;

        // Find out if we have any licenses at all
        Exec sql
          Select count(*) into :cntrecs
            from LICLOG
           where LLWHSE = :pWhs
             and LLITEM = :pItem
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
             and LLACTION <> 'USR';

        // if nothing found, write record and exit
        if SQLSTT <> '00000'
          or cntrecs = 0;
            llwhse = pwhs;
            llitem = pitem;
            llaqty1 = pqty1;
            llaqty2 = pqty2;
            llaqty3 = pqty3;
            exsr WrtAdjl;
            exsr WrtExpl;
            return;
        endif;

        // Find out if we have an exact qty match
        Exec sql
          Select count(*) into :cntrecs
            from LICLOG
           where LLWHSE = :pWhs
             and LLITEM = :pItem
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
               and LLITEM = :pItem
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
             and LLITEM = :pItem
             and LLADDTS >= :wkStampBeg
             and LLADDTS <= :wkStampEnd
             and LLACTION <> 'USR';
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
              other;
                llwhse = pwhs;
            endsl;
          else;
            llwhse = pwhs;
          endif;

          ialwhse =  llwhse;
          ialitem =  llitem;
        //ialdate =  CreateDt(lladdts);
        //ialtime =  CreateTm(lladdts);
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

          ielwhse =  llwhse;
          ielitem =  llitem;
        //ieldate =  CreateDt(lladdts);
        //ieltime =  CreateTm(lladdts);
          ieldate =  pdate;
          ieltime =  ptime;
          ielby =    pby;
          ielwhdp =  pwhdp;
          ieldisp =  pdisp;
          iellcns =  lllcns;
          ielolcns = llolcns;
          ielqty1 =  %editc(llaqty1:'L');
          ielqty2 =  %editc(llaqty2:'L');
          ielqty3 =  %editc(llaqty3:'L');
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

