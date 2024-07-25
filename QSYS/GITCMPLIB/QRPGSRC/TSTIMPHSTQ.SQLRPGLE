      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTIMPHSTQ   Test IMPHSTQTY
     *  08 April 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ijrec         E ds                  extname(impspqty) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  batId          s             11
     D  rtnCode        s             10
     D  rtnMessage     s            200
     D  uStatus        s              1
     D  uType          s             10
     D  whse3S         s              3s 0

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

     D dktimport       pr                  extpgm('DKTIMPORT')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pBatId                      11    const
     D   pRunType                     1    const
     D   pProgram                    10    const
      * Output
     D   pReturn                     10
     D   pMessage                   200
640aA
640aAD GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

     *----------------------------------------------------------------
     * Input parameters
     *----------------------------------------------------------------

     D $pWhse15        S             15p 5
     D $pWhse3         S              3p 0
     D $pType          S             10
     D $pBatId         S             11
     D $pRunType       S              1

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  pReturn        s             10
     D  pMessage       s            200

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         exsr GetBatchId;
         exsr WriteIMPSPQTY1;
         exsr DoImport;

         return;
      /end-free

     *----------------------------------------------------------------
     *  DoImport     Call DktImport
     *----------------------------------------------------------------

      /free
       begsr DoImport;

         DktImport(900: 'IMPHSTQTY': batId: 'I':
                   'TSTIMPHSTQ': rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetBatchId   Get batch id
     *----------------------------------------------------------------

      /free
       begsr GetBatchId;

         GetBatId(900: 'IMPHSTQTY': 'R':
                  batId: rtnCode: rtnMessage);

         if rtnCode <> '*OK';
           dsply rtnCode;
           dsply %subst(rtnMessage:1:32);
           return;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteIMPSPQTY    Write IMPSPQTY record
     *----------------------------------------------------------------

      /free
       begsr WriteIMPSPQTY;

         exec sql insert into impspqty
                  (ijwhse, ijbatid, ijitem,
                   ijstatus, ijststs, ijstsuc, ijtext,
                   ijtqh1, ijtqh2,
                   ijaddts, ijadduc)
                  values(:ijwhse, :ijbatid, :ijitem, :ijstatus,
                         current_timestamp,
                         current_timestamp - current_timezone,
                         :ijtext, :ijtqh1, :ijtqh2,
                         current_timestamp,
                         current_timestamp - current_timezone);

        if sqlstt <> sqlSuccess;
           rtnMessage = 'IMPSPQTY error - ' + sqlstt;
           dsply %subst(rtnMessage:1:32);
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  WriteIMPSPQTY1   Write IMPSPQTY record
     *----------------------------------------------------------------

      /free
       begsr WriteIMPSPQTY1;

         clear ijrec;

         ijwhse = 900;
         ijbatid = batId;
         ijstatus = 'R';
         ijitem = 'DA101';
         ijtqh1 = 180;

         exsr WriteIMPSPQTY;

       endsr;
      /end-free
