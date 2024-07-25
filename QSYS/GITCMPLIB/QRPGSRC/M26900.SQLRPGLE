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
     *  M26900     Maintenance Company GS1 Prefix
     *  09 April  2018
     *  Kenneth Elder
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    04/09/18  KDE  7.20
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
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     * DRI Parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n
     d n               s             18  0

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
     D  paction        s              1
     D  pwhse          s              3  0
     D  pPckType       s              1
     D  pLocName       s             40
     D  pGs1pre        s             15

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

700aAD gprec         e ds                  extname(gs1whspre)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pMessage    Message
     *      pUser       User
     *      pPgm        Program
     *      pAction     Action from MRC (A, C, D)
     *      pWhse       Warehouse
     *      pPckType    Packaging Type
     *      pGS1Pre     GS1 Prefix
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
     C                   parm                    pAction
     C                   parm                    pWhse
     C                   parm                    pPckType
     C                   parm                    pLocName
     C                   parm                    pGs1Pre
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        exsr getcurrstamp;

        exsr Edit;
        if error = *off;
          exsr Update;
        endif;

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
         plocname  = %xlate(xlower: xupper: pLocName);
         ppckType  = %xlate(xlower: xupper: pPckType);
         pgs1pre  = %xlate(xlower: xupper: pgs1pre);
         getclient(client: clientLoc);


         getUser(puser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                 e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                 e$bpu: e$lng);

      /end-free

      /free
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Edit              Edit validation
     *----------------------------------------------------------------

      /free
       begsr Edit;

        // make sure Packaging Type is sent
        if pPckType = *blanks;
           pMessage = 'Packaging Type cannot be empty';
           error = *on;
           leavesr;
        endif;

        // Make sure GS1 Packagin Type is numeric
        if %check('0123456789 ':pPckType) <> 0;
           pMessage = 'GS1 Packaging Type must be numeric';
           error=*on;
           leavesr;
        endif;

        // make sure Location Name is sent
        if pLocName = *blanks;
           pMessage = 'Location Name cannot be empty';
           error = *on;
           leavesr;
        endif;

        // Make sure GS1 Prefix sent
        if pGS1Pre = *blanks;
           pMessage = 'GS1 Prefix cannot be empty';
           error=*on;
           leavesr;
        endif;

        // Make sure GS1 Prefix is numeric
        if %check('0123456789 ':pGS1Pre) <> 0;
           pMessage = 'GS1 Prefix must be numeric';
           error=*on;
           leavesr;
        endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Update            Add/Delete Itemsub record
     *----------------------------------------------------------------

      /free
       begsr Update;

        error = *off;
        if pAction = 'A' or pAction = 'U';
           if pAction = 'U';
              exec sql select * into :gprec
                 from gs1whspre
                   where gpwhse=:pWhse and gppcktype=:pPckType;
           endif;

           gpwhse = pWhse;
           gpPckType = pPckType;
           gpLocName = pLocName;
           gpPrefix = pGs1Pre;

        endif;

        select;
          when paction = 'A';
            exec sql insert into gs1whspre
                 values(:gpwhse,
                        :gppcktype,
                        :gplocname,
                        :gpPrefix);
          when paction = 'U';
            exec sql update gs1whspre set
               gpwhse = :gpwhse,
               gppcktype = :gppcktype,
               gplocname = :gplocname,
               gpPreFix = :gpPreFix
                where gpwhse=:pWhse and gppcktype=:ppcktype;
          when paction = 'D';
            exec sql delete
                 from gs1whspre
                 where gpwhse = :pwhse
                   and gppcktype=:ppcktype;
            If sqlstt = sqlSuccess;
            else;
            endif;
          other;
        endsl;

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
