      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  R25200     Selection Special Adjustment pcs
     *  08 August 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    08/08/17  LMC  7.10
     *      - Created
     *
710aA*    11/03/17  DAS  7.10a
     *      - Revised to exclude lbtype 'A'.
     *
710bA*    11/06/17  DAS  7.10b
     *      - Revised to use LABELDO pick qty if it exists.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D FromStamp       s               z
     D ToStamp         s               z
     D oldeststamp     s               z
     D ts              s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)


     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------


      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n
     d worknet         s              5  0

     D e$whse          s              3  0
     D e$emp#          s              5  0
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
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  puser          s             10
     D  ppgm           s             10
     D  pwhse          s              3  0
     D  ptran          s              7  0
     D  plabel         s              7  0
     D  psplnet        s              5  0
     D  psplnetadj     s              5  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D lsrrec        E Ds                  Extname(logselrto)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pTran       Transaction
     *      plabel      Transaction
     *      pSplNet     Special net pcs
     *      pSplNetAdj  Special Adjusted Net pieces
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pUser
     C                   parm                    pPgm
     C                   parm                    pWhse
     C                   parm                    pTran
     C                   parm                    pLabel
     C                   parm                    pSplNet
     C                   parm                    pSplNetAdj

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;
        if ptran = 0
           and plabel = 0;
          return;
        endif;

        select;
          when ptran > 0;
            // get special pcs
710bD       //exec sql SELECT SUM(FLOOR(LBQPCK/ESRRATIO)
710bD       //+ MOD(LBQPCK,ESRRATIO)),SUM(LBQPCK)
710bD       //into :psplnetadj, :worknet
710bD       //from label,EPMSELRTO
710bD       //WHERE LBTRN# = :PTRAN AND LBITEM = ESRITEM
710bD       //AND LBTYPE <> 'A'
710bD       //AND ESRRATIO > 0;

710bA       // The COALESCE function returns the first field that is not
710bA       // null. If a LABELDO record is not found, its fields will
710bA       // be null. Therefore, we are getting the value from LABELDO
710bA       // if it exists, otherwise we use the LABEL value.

710bM       exec sql
710bM       SELECT SUM(FLOOR(COALESCE(LBOQTY,LBQPCK)/ESRRATIO)
710bM                  + MOD(COALESCE(LBOQTY,LBQPCK),ESRRATIO)),
710bM              SUM(COALESCE(LBOQTY,LBQPCK))
710bM       into :psplnetadj, :worknet
710bM       from label
710bM       inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO > 0
710bM       left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
710bM                       and LBOACT='VPICK' and LBOPTYPE='SELECT'
710bM       WHERE LBTRN# = :PTRAN AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

            // get Excluded pcs
710bD       //exec sql SELECT
710bD       //SUM(LBQPCK)  into  :worknet
710bD       //from label,EPMSELRTO
710bD       //WHERE LBTRN# = :PTRAN AND LBITEM = ESRITEM
710bD       //AND LBTYPE <> 'A'
710bD       //AND ESRRATIO = 0;

710bA       // See above comment about COALESCE

710bM       exec sql
710bM       SELECT SUM(COALESCE(LBOQTY,LBQPCK)) into :worknet
710bM       from label
710bM       inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO = 0
710bM       left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
710bM                       and LBOACT='VPICK' and LBOPTYPE='SELECT'
710bM       WHERE LBTRN# = :PTRAN AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

          when plabel > 0;
            // get special pcs
710bD       //exec sql SELECT SUM(FLOOR(LBQPCK/ESRRATIO)
710bD       //+ MOD(LBQPCK,ESRRATIO)),SUM(LBQPCK)
710bD       //into :psplnetadj, :worknet
710bD       //from label,EPMSELRTO
710bD       //WHERE LBLBL# = :PLABEL AND LBITEM = ESRITEM
710bD       //AND ESRRATIO > 0;

710bA       // See above comment about COALESCE

710bM       exec sql
710bM       SELECT SUM(FLOOR(COALESCE(LBOQTY,LBQPCK)/ESRRATIO)
710bM                  + MOD(COALESCE(LBOQTY,LBQPCK),ESRRATIO)),
710bM              SUM(COALESCE(LBOQTY,LBQPCK))
710bM       into :psplnetadj, :worknet
710bM       from label
710bM       inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO > 0
710bM       left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
710bM                       and LBOACT='VPICK' and LBOPTYPE='SELECT'
710bM       WHERE LBLBL# = :PLABEL AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;

            // get Excluded pcs
710bD       //exec sql SELECT
710bD       //SUM(LBQPCK)  into  :worknet
710bD       //from label,EPMSELRTO
710bD       //WHERE LBLBL# = :PLABEL AND LBITEM = ESRITEM
710bD       //AND ESRRATIO = 0;

710bA       // See above comment about COALESCE

710bM       exec sql
710bM       SELECT SUM(COALESCE(LBOQTY,LBQPCK)) into :worknet
710bM       from label
710bM       inner join EPMSELRTO on LBITEM = ESRITEM AND ESRRATIO = 0
710bM       left outer join LABELDO on LBOLBL#=LBLBL# and LBOTRN#=LBTRN#
710bM                       and LBOACT='VPICK' and LBOPTYPE='SELECT'
710bM       WHERE LBLBL# = :PLABEL AND LBTYPE <> 'A';

            if sqlstt <> sqlSuccess;
              pmessage = %char(sqlcode);
            else;
              psplnet = psplnet + worknet;
            endif;
        endsl;
        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         // Convert fields to uppercase

         puser   = %xlate(xlower: xupper: puser);
         ppgm    = %xlate(xlower: xupper: ppgm);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

      /free
       begsr getCurrStamp;

         getmicrotime(currstampuc:currstampsys);
         currstamploc = currstampsys + %hours(bfcoffset);

       endsr;
      /end-free
