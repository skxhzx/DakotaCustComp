      /copy qcopysrc,hspecs
720 AH DFTACTGRP(*NO)
720 AH Bnddir('QC2LE':'BFCBND')
     *----------------------------------------------------------------
     *
     *  GETUPDINFO   Get record update info
     *  12 February 2010
     *  Dave Sommerville
     *
     *  Revisions
     *
610  *    02/12/10  DAS  6.10
     *      - Created.
     *
720 A*    01/23/18  KDE  7.20
     *      - Add code to use getmicrotime instead of sql time
     *        Getmicrotime was changed to return proper time based
     *        on use of TimeZone/400
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *    This program is called from a maintenance MRC program before
     *    a record is added or changed in order to retrieve the
     *    general update information about the job, which is then put
     *    into the appropriate record fields.
     *
     *    The reason for all of the returned parameters being
     *    duplicated is because of how the MRC external program call
     *    works. When defining an external program to be called you
     *    can assign a return field to one of the record fields, but
     *    only one. Since we want to fill in the 'Change' fields even
     *    when the record is added, we needed to pass back 2 copies
     *    of the fields.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getuser
720 A /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

720 AD CurrStampsys    s               z
720 AD CurrStampuc     s               z
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
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pUser          s             10
     D  pPgm           s             10
     D  pSysTS         s             26
     D  pSysTS2        s             26
     D  pUcTS          s             26
     D  pUcTS2         s             26
     D  pCallPgm       s             10
     D  pCallPgm2      s             10
     D  pJobPgm        s             10
     D  pJobPgm2       s             10
     D  pEmpNbr        s              5p 0
     D  pEmpNbr2       s              5p 0
     D  pEmpUser       s             10
     D  pEmpUser2      s             10
     D  pJob           s             10
     D  pJob2          s             10
     D  pJobNbr        s              6
     D  pJobNbr2       s              6
     D  pJobUser       s             10
     D  pJobUser2      s             10
     D  pJobCurrUser   s             10
     D  pJobCurrUser2  s             10

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pUser       User
     *      pPgm        Update program
     *
     *    Returned Parameters
     *      pSysTS      System timestamp
     *      pSysTS2     System timestamp - copy
     *      pUcTS       UC timestamp
     *      pUcTS2      UC timestamp - copy
     *      pCallPgm    Calling program
     *      pCallPgm2   Calling program - copy
     *      pJobPgm     Job program
     *      pJobPgm2    Job program - copy
     *      pEmpNbr     Employee number
     *      pEmpNbr2    Employee number - copy
     *      pEmpUser    Employee user
     *      pEmpUser2   Employee user - copy
     *      pCurUser    Current user
     *      pCurUser2   Current user - copy
     *      pJobUser    Job user
     *      pJobUser2   Job user - copy
     *      pJob        Job name
     *      pJob2       Job name - copy
     *      pJobNbr     Job number
     *      pJobNbr2    Job number - copy
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pSysTS
     c                   parm                    pSysTS2
     c                   parm                    pUcTS
     c                   parm                    pUcTS2
     c                   parm                    pCallPgm
     c                   parm                    pCallPgm2
     c                   parm                    pJobPgm
     c                   parm                    pJobPgm2
     c                   parm                    pEmpNbr
     c                   parm                    pEmpNbr2
     c                   parm                    pEmpUser
     c                   parm                    pEmpUser2
     c                   parm                    pJob
     c                   parm                    pJob2
     c                   parm                    pJobNbr
     c                   parm                    pJobNbr2
     c                   parm                    pJobUser
     c                   parm                    pJobUser2
     c                   parm                    pJobCurrUser
     c                   parm                    pJobCurrUser2

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

        pCallPgm = pPgm;
        pCallPgm2 = pPgm;
        pJobPgm = #pgm;
        pJobPgm2 = #pgm;

        getUser(pUser: e$whse: e$emp#: e$fnam: e$init: e$lnam:
                e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
                e$bpu: e$lng);
        pEmpNbr = e$emp#;
        pEmpNbr2 = e$emp#;

        pEmpUser = pUser;
        pEmpUser2 = pUser;
        pJob = #job;
        pJob2 = #job;
        pJobNbr = #jobnbr;
        pJobNbr2 = #jobnbr;
        pJobUser = #user;
        pJobUser2 = #user;
        pJobCurrUser = #curruser;
        pJobCurrUser2 = #curruser;

720 D   //exec sql values (current timestamp,
720 D   //                 (current timestamp - current timezone))
720 D   //         into :pSysTS, :pUcTS;

720 A   getmicrotime(currstampuc:currstampsys);
720 A   pSysTS = %char(currstampsys);
720 A   pUcTS  = %char(currstampuc);
        pSysTS2 = pSysTS;
        pUcTS2  = pUcTS;

        return;
