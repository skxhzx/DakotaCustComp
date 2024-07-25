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
     *  M24100     EPM Selection Ratio log add/update/delete
     *  07 August 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    08/07/17  LMC  7.10
     *      - Created
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
     D  pitem          s             15
     D  pratio         s              5  0
     D  paction        s              3

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
     *      pItem       Item
     *      pRatio      Ratio
     *      pAction     Action
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
     C                   parm                    pItem
     C                   parm                    pRatio
     C                   parm                    pAction

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        clear lsrrec;
        exsr getcurrstamp;
        lsraddts = currstampsys;
        lsradduc = currstampuc;


        Select;
          When pAction = 'ADD' or
               pAction = 'CHG' or
               pAction = 'DLT';
            exsr WriteLog;

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
     *  WriteLog          Write epm selection ratio  log entries
     *----------------------------------------------------------------

      /free
       begsr WriteLog;
         lsrwhse = pwhse;
         lsritem = pitem;
         lsrratio = pratio;
         lsraction = paction;
         lsraddusr = puser;
         lsraddpgm = ppgm;
         lsraddemp = e$emp#;
         exec sql insert into logselrto
                values(:lsrwhse,
                       :lsritem,
                       :lsrratio,
                       :lsraction,
                       :lsraddts,
                       :lsradduc,
                       :lsraddpgm,
                       :lsraddemp,
                       :lsraddusr,
                       :lsraddjob,
                       :lsraddnbr);

         If sqlstt = sqlSuccess;
           error = *on;
           pMessage = 'Error: Log not written';
           leavesr;
         Endif;
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
