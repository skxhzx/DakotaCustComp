      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  HQ243      Convert Will Call Orders to MV Picks
     *  09 January 2015
     *  Rod Roller
     *
     *  Revisions
     *
650  *    04/04/14  RTR  6.50
     *      - Created as a QD program for HMW.
700  *    01/25/16  RTR  7.00
     *      - Renamed as HQ243 and updated for base code.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     D $pwhse          s              3  0
     D $proute         s              5a

     *----------------------------------------------------------------
     *  Variables
     D count           s              6s 0

     D detds           ds
     D  dswhse                        3  0
     D  dscord                        7  0
     D  dsseq                         5  0
     D  dsitem                       15a
     D  dsqor1                        5  0
     D  dsqor2                        5  0
     D  dsqor3                        5  0

     D othds           ds
     D  dswhdp                        5a
     D  dsdisp                       12a
     D  dsadj                         2a   inz('MV')
     D  dsmemo                       30a
     D  dssof                         1a   inz('Y')

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse   - Warehouse
     *      $proute  - Route ID
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $proute

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        // select ordh/d records to create adjustments for
        Exec sql Declare C1 Cursor For
          SELECT ORDH.OHWHSE, ORDH.OHCORD,
                 ORDD.ODSEQ, ORDD.ODITEM,
                 ORDD.ODQOR1, ORDD.ODQOR2, ORDD.ODQOR3
            FROM ordh, ordd
           WHERE ohwhse = odwhse
             and ohord = odord
             and ohwhse = :$pwhse
             and ohrte = :$proute;
        Exec sql Open C1;

        Exec sql Fetch C1 into :detds;

        dow SQLSTT = '00000';

          // Get department
          Exec sql select itwhdp into :dswhdp
                     from piritem
                    where itwhse = :dswhse
                      and ititem = :dsitem;
          if sqlstt <> sqlsuccess;
            dswhdp = *blanks;
          endif;
          // Get showroom slot
          Exec sql select min(sldisp) into :dsdisp
                     from slot
                    where slwhse = :dswhse
                      and slitem = :dsitem
                      and slstat = 'SR';
          if sqlstt <> sqlsuccess;
            dsdisp = *blanks;
          endif;
          // Build memo info
          dsmemo = 'Ord:' + %trim(%char(dscord)) + '-' + %trim(%char(dsseq))
                 + ' WC Rt:' + $proute;

          Exec sql Insert into impfpckq
                          (ipqwhs, ipqwhd, ipqdsp, ipqitm, ipqqp1,
                           ipqqp2, ipqqp3, ipqadj, ipqmem, ipqsof)
                   values (:dswhse, :dswhdp, :dsdisp, :dsitem, :dsqor1,
                           :dsqor2, :dsqor3, :dsadj, :dsmemo, :dssof);

          Exec sql Fetch C1 into :detds;
        enddo;

        Exec sql Close C1;

        // Set route to exported status, so visible if needed.
        Exec sql update rtehed
                    set rhstat = '6'
                  where rhrtid = :$proute;

        *inlr = *on;
        return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *inzsr;

       endsr;
      /end-free

