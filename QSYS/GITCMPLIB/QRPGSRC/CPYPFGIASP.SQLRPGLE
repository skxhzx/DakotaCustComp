      /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *
     *  CPYPFGIASP   Copy PFG filed from iASP to *SYSBASE
     *  16 December 2019
     *  Dave Sommerville
     *
     *  Revisions
     *
730 A*    12/16/19  DAS  7.30
     *      - Created using CPYROUTE programs.
     *
730aA*    12/26/19  DAS  7.30a
     *      - Added SHIFT/CREW tables
     *
730bA*    12/26/19  DAS  7.30b
     *      - Initialized PIRRECID# based on max Lbl# / Trn#.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D usrec         E ds                  extname(piruser) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d iASP            s             10    varying
     d fromLib         s             10    varying inz('pirf')
     d toLib           s             10    varying inz('pirfmw')

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CopyFile        pr
     d  file                         10    const varying
     d  field                        10    const varying

     d CopyFileUser    pr

     d UserExists      pr              n
     d  toFile                       25    const varying
     d  usr                          10    const

730bAd SetLbl#         pr

730bAd SetTrn#         pr

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pcmd    Command - must be *COPY
     *      pWhse   Warehouse - Zero fill
     *      pSys    P=Production, T=Test, 1/2=BFC IASP1/2
     *      pBFC    1=IASP1, 2=IASP2  (optional)
     *
     *    Returned Parameters
     *      None
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pCmd             10
     c                   parm                    pWhse             3
     c                   parm                    pSys              1
     c                   parm                    pBFC              1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

       // Prevent accidents

       if pCmd <> '*COPY';
         dsply 'Invalid command sent';
         return;
       endif;

       // Set From/To libraries to use

       select;
         when pSys = 'P';
           fromLib = 'pirf';
           toLib = 'pirfmw';
         when pSys = 'T';
           fromLib = 'pirtestf';
           toLib = 'pirtestfmw';
         other;
           dsply 'Invalid system type sent';
           return;
       endsl;

       // Set iASP to use

       iASP = 'B' + pWhse;

       // Override iASP for testing on BFC box

       if %parms >= 4;
         select;
           when pBFC = '1';
             iASP = 'IASP1';
           when pBFC = '2';
             iASP = 'IASP2';
           other;
             dsply 'Invalid BFC type sent';
             return;
         endsl;
       endif;

       // Copy files

       copyFileUser();

       copyFile('nexttmpl': 'tnwhse');
       copyFile('optiond': 'opdwhs');
       copyFile('options': 'opwhse');
       copyFile('optionz': 'opzwhs');
       copyFile('pircolorsh': 'clrhwhse');
       copyFile('pircolorsd': 'clrdwhse');
       copyFile('pirord#': 'nxowhs');
       copyFile('pirrecid#': 'nriwhse');
       copyFile('pirrte#': 'nxrwhs');
       copyFile('trkcomp': 'tpwhse');
       copyFile('trkcompclr': 'tpcwhse');
       copyFile('truckh': 'thwhse');
       copyFile('truckd': 'tdwhse');
       copyFile('truckhm': 'tmwhse');
       copyFile('truckdft': 'tdwhse');
       copyFile('warehs': 'whcode');
       copyFile('warehsad': 'whacod');
       copyFile('whdept': 'wdwhse');
       copyFile('zoneh': 'zhwhse');
       copyFile('zoned': 'zdwhse');
730aA  copyFile('shift': 'shwhse');
730aA  copyFile('crew': 'crwhse');

730bA  SetLbl#();
730bA  SetTrn#();

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CopyFile    Copy file from iASP to *SYSBASE
     *----------------------------------------------------------------

     p CopyFile        b
     d CopyFile        pi
     d  file                         10    const varying
     d  field                        10    const varying

     *  Local Variables

     D fromFile        s             25    varying
     D toFile          s             25    varying
     D msg             s             32

      /free

       // Copy all recs for warehouse from iASP to *SYSBASE

       fromFile = iASP + '.' + fromLib + '.' + file;
       toFile = toLib + '.' + file;

       sqlstmt = 'insert into ' + toFile + ' '
               + 'select * from ' + fromFile + ' '
               + 'where ' + field + '=' + pWhse;

       exec sql execute immediate :sqlstmt;

       if sqlstt <> sqlSuccess;
         msg = file + ' SQL Error ' + sqlstt;
         dsply msg;
       endif;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CopyFileUser    Copy PIRUSER file from iASP to *SYSBASE
     *----------------------------------------------------------------

     p CopyFileUser    b
     d CopyFileUser    pi

     *  Local Variables

     D fromFile        s             25    varying
     D toFile          s             25    varying
     D msg             s             32
     D first           s               n   inz(*on)
     D count           s              5p 0
     D countInd        s              2b 0

      /free

       // Copy all recs that do not exist from iASP to *SYSBASE

       fromFile = iASP + '.' + fromLib + '.piruser';
       toFile = toLib + '.piruser';

       sqlstmt = 'select * from ' + fromFile;

       exec sql prepare stmt from :SqlStmt;
       if sqlstt <> sqlSuccess;
         msg = 'piruser SQL Prepare Error ' + sqlstt;
         dsply msg;
         return;
       endif;

       exec sql declare csr cursor for stmt;
       if sqlstt <> sqlSuccess;
         msg = 'piruser SQL Declare Error ' + sqlstt;
         dsply msg;
         return;
       endif;

       exec sql open csr;
       if sqlstt <> sqlSuccess;
         msg = 'piruser SQL Open Error ' + sqlstt;
         dsply msg;
         return;
       endif;

       dow forever = forever;

         exec sql fetch next from csr into :usrec;

         if sqlstt <> sqlSuccess;
           if first;
             msg = 'piruser SQL Fetch Error ' + sqlstt;
             dsply msg;
           endif;
           leave;
         endif;

         first = *off;

         // Skip if user already exists

         if UserExists(toFile: uscode);
           iter;
         endif;

         // Insert new user code

         sqlstmt = 'insert into ' + toFile + ' '
                 + 'select * from ' + fromFile + ' '
                 + 'where uscode=' + sq + %trim(uscode) + sq;

         exec sql execute immediate :sqlstmt;

         if sqlstt = sqlSuccess;
         endif;

       enddo;

       exec sql close csr;

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  UserExists      Check if user exists
     *----------------------------------------------------------------

     p UserExists      b
     d UserExists      pi              n
     D  toFile                       25    const varying
     d  usr                          10    const

     *  Local Variables

     D msg             s             32
     D count           s              5p 0
     D countInd        s              2b 0
     D sqlStmt2        s            500    varying

      /free

       sqlstmt2 = 'select count(*) from ' + toFile + ' '
                + 'where uscode = ' + sq + %trim(usr) + sq;

       exec sql prepare stmt2 from :SqlStmt2;
       exec sql declare csr2 cursor for stmt2;
       exec sql open csr2;

       exec sql fetch next from csr2 into :count :countInd;
       if sqlstt <> sqlSuccess or count > 0;
         exec sql close csr2;
         return *on;
       endif;

       exec sql close csr2;
       return *off;

      /end-free

     p                 e

730bA*----------------------------------------------------------------
730bA*  SetLbl#     Set next Lbl# based on WORKLBL
730bA*----------------------------------------------------------------
730bA
730bAp SetLbl#         b
     d SetLbl#         pi

     *  Local Variables

     D fromFile        s             25    varying
     D toFile          s             25    varying
     D msg             s             32
     D maxLbl#         s              7  0

      /free

       fromFile = iASP + '.' + fromLib + '.WORKLBL';
       toFile = toLib + '.PIRRECID#';

       // Get maximum Lbl# from iASP WORKLBL

       sqlstmt = 'select max(lwlbl#) from ' + fromFile + ' '
               + 'where lwwhse=' + pWhse;

       exec sql prepare stmtL from :sqlStmt;
       exec sql declare csrL cursor for stmtL;
       exec sql open csrL;
       exec sql fetch next from csrL into :maxLbl#;
       exec sql close csrL;

       // Insert LABEL PIRECID# record.

       if maxLbl# = 9999999;
         maxLbl# = 0;
       else;
         maxLbl# += 1;
       endif;

       sqlstmt = 'insert into ' + toFile + ' '
               + 'values ('
               + pwhse + ','
               + sq + 'LABEL' + sq + ','
               + %char(maxLbl#) + ')';

       exec sql execute immediate :sqlstmt;

       if sqlstt = sqlSuccess;
       endif;

      /end-free

     p                 e

730bA*----------------------------------------------------------------
730bA*  SetTrn#     Set next Trn# based on PIRTRAN
730bA*----------------------------------------------------------------
730bA
730bAp SetTrn#         b
     d SetTrn#         pi

     *  Local Variables

     D fromFile        s             25    varying
     D toFile          s             25    varying
     D msg             s             32
     D maxTrn#         s              7  0

      /free

       fromFile = iASP + '.' + fromLib + '.PIRTRAN';
       toFile = toLib + '.PIRRECID#';

       // Get maximum Lbl# from iASP WORKLBL

       sqlstmt = 'select max(pttrn#) from ' + fromFile + ' '
               + 'where ptwhse=' + pWhse;

       exec sql prepare stmtT from :sqlStmt;
       exec sql declare csrT cursor for stmtT;
       exec sql open csrT;
       exec sql fetch next from csrT into :maxTrn#;
       exec sql close csrT;

       // Insert PIRTRAN PIRECID# record.

       if maxTrn# = 9999999;
         maxTrn# = 0;
       else;
         maxTrn# += 1;
       endif;

       sqlstmt = 'insert into ' + toFile + ' '
               + 'values ('
               + pwhse + ','
               + sq + 'PIRTRAN' + sq + ','
               + %char(maxTrn#) + ')';

       exec sql execute immediate :sqlstmt;

       if sqlstt = sqlSuccess;
       endif;

      /end-free

     p                 e

