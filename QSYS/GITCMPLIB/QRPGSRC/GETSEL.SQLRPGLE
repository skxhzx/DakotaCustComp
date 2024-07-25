      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  GETSEL     Get selector
     *  03 June 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
530 A*    06/03/10  DAS  5.30
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.getempl

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D label         E ds
     D labeldo       E ds
     D pirtran       E ds
     D runner        E ds

     D dsRun           ds                  occurs(2) inz
     D  rEmp#                              like(ptemp#)
     D  rQty                               like(ruqyfd)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  i              s              3  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pLbl#          s              7  0
     D  pSelEmp#       s              5  0
     D  pSelName       s             40
     D  pSelQty        s              5  0
     D  pSelVoice      s              1
     D  pRun1Emp#      s              5  0
     D  pRun1Name      s             40
     D  pRun1Qty       s              5  0
     D  pRun2Emp#      s              5  0
     D  pRun2Name      s             40
     D  pRun2Qty       s              5  0
     D  pReturn        s             10

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d GetEmplName     pr            40a
     D  empl#                         5p 0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pLbl#       Label #
     *
     *    Returned Parameters
     *      pSelEmp#    Selector Emp#
     *      pSelName    Selector Name
     *      pSelQty     Selector picked qty
     *      pSelVoice   Selector picked by voice flag (Y,N)
     *      pRun1Emp#   Runner 1 Emp#
     *      pRun1Name   Runner 1 Name
     *      pRun1Qty    Runner 1 picked qty
     *      pRun2Emp#   Runner 2 Emp#
     *      pRun2Name   Runner 2 Name
     *      pRun2Qty    Runner 2 picked qty
     *      pRetrun     Return code
     *                    *OK
     *                    *LBLNOTSNT - No label number sent
     *                    *LBLNOTFND - Label not found
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pLbl#
     c                   parm                    pSelEmp#
     c                   parm                    pSelName
     c                   parm                    pSelQty
     c                   parm                    pSelVoice
     c                   parm                    pRun1Emp#
     c                   parm                    pRun1Name
     c                   parm                    pRun1Qty
     c                   parm                    pRun2Emp#
     c                   parm                    pRun2Name
     c                   parm                    pRun2Qty
     c                   parm                    pReturn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        // Initialize Return parms

        clear pSelEmp#;
        clear pSelName;
        clear pSelQty;
        clear pSelVoice;
        clear pRun1Emp#;
        clear pRun1Name;
        clear pRun1Qty;
        clear pRun2Emp#;
        clear pRun2Name;
        clear pRun2Qty;
        pReturn = '*OK';

        // If Label number is zero, get out.

        if pLbl# = 0;
          pReturn = '*LBLNOTSNT';
          return;
        endif;

        // Get Label record

        exec sql select * into :label
                 from label
                 where lblbl# = :pLbl#;

        If sqlstt <> sqlSuccess;
          pReturn = '*LBLNOTFND';
          return;
        endif;

        // Get LabelDo record

        exec sql select * into :labeldo
                 from labeldo
                 where lbolbl# = :lblbl#
                   and lbotrn# = :lbtrn#;

        If sqlstt = sqlSuccess;
          pSelEmp#  = lboemp#;
          pSelName  = GetEmplName(pSelEmp#);
          pSelQty   = lboqty;
          pSelVoice = 'Y';
        else;
          pSelVoice = 'N';
        endif;

        // If LabelDo not found, get employee information from transaction.

        If pSelVoice = 'N';

          exec sql select * into :pirtran
                   from pirtran
                   where pttrn# = :lbtrn#;

          If sqlstt = sqlSuccess;
            pSelEmp#  = ptemp#;
            pSelName  = GetEmplName(pSelEmp#);
            pSelQty   = ptpcs;
          endif;

        endif;

        // Now look for Runners

        clear dsRun;

        SqlStmt = 'select ptemp#,ruqyfd from runner '
                + 'inner join pirtran on pttrn#=rutrn# '
                + 'where ruwhse=' + %char(lbwhse) + ' '
                +   'and rulbl#=' + %char(lblbl#);
        exec sql prepare sel from :SqlStmt;
        exec sql declare mycsr cursor for sel;
        exec sql open mycsr;
        exec sql fetch next from mycsr
                 for 2 rows
                 into :dsRun;

        If sqlstt = sqlSuccess;

          for i = 1 to 2;
            %occur(dsRun) = i;
            if rEmp# = 0;
              leave;
            endif;
            select;
              when i = 1;
                pRun1Emp#  = rEmp#;
                pRun1Name  = GetEmplName(pRun1Emp#);
                pRun1Qty   = rQty;
              when i = 2;
                pRun2Emp#  = rEmp#;
                pRun2Name  = GetEmplName(pRun2Emp#);
                pRun2Qty   = rQty;
            endsl;
          endfor;

        endif;

        exec sql close mycsr;

        // Last of all, if not originally picked by voice,
        // Then calculate how much selector picked.

        if pSelVoice <> 'Y';
          pSelQty = lbqpck - pRun1Qty - pRun2Qty;
          if pSelQty < 0;
            pSelQty = 0;
          endif;
        endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GetEmplName  Get employee name
     *----------------------------------------------------------------

     p GetEmplName     b
     d GetEmplName     pi            40
     d  empl#                         5p 0

     *  Local Variables

     D e$whse          s              3  0
     D e$user          s             10
     D e$fnam          s             15
     D e$init          s              1
     D e$lnam          s             20
     D e$whdp          s              5
     D e$styp          s              1
     D e$shft          s              6
     D e$crew          s              6
     D e$nhrs          s              3  1
     D e$rtn           s              8
     D e$bpu           s              1
     D e$lng           s              2

      /free

        getEmpl(empl#: e$whse: e$user: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);

        return %trim(e$lnam) + ', ' + %trim(e$fnam) + ' ' + e$init;

      /end-free

     p GetEmplName     e
