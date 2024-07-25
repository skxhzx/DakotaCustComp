      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *
     *  WRKIFSLCK   Work with IFS Object Locks
     *  16 August 2021
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
750 A*    08/16/21  MLB  7.50
     *      - Created.
     *      - Src retrieved from IBM website.
     *        https://www.ibm.com/support/pages/sample-program-list
     *        -list-lock-information-ifs-objects
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes
     *
     *  - There is no command on the IBM i OS that allows you to do the IFS
     *    equivalent of WRKOBJLCK for the native file system. However, the
     *    following command source and RPGLE source will create a command
     *    that will allow you to view lock information for an IFS directory
     *    or stream file. The output of the command will be a spooled file
     *    that contains information about jobs that are holding locks on
     *    an IFS object (file or directory) and the reason they have the lock.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
     D spaceloc        S              3P 0
     D  $ppath         S            500
     D  CMD            S           1024    INZ(' ')
     D**QUOTE          S              1    INZ('''')
     D  CMDL           S             15  0 INZ(1024)
     D  QCMDEXC        PR                  EXTPGM('QCMDEXC')
     D  CMD                        1024A   OPTIONS(*VARSIZE) CONST
     D  CMDL                         15p 5 CONST
     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

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
     D startStampLoc   s               z
     D startStampSys   s               z
     D startStampUC    s               z

     D Duration        s              7  2
     D TtlMin          s              5  0
     D TtlMinSec       s              9  0
     D TtlSec          s              9  0
     D RemSec          s              3  0

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      $ppath      IFS folder path/object
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    $ppath
     c*                  parm                    $prtn

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        spaceloc = %scan(' ':$ppath);
             $ppath = %subst($ppath:1:spaceloc);
             cmd='CALL QP0FPTOS PARM(*LSTOBJREF '+ QUOTE +
                 %trim($ppath) + QUOTE + ' +
                 *FORMAT2)';
            QCMDEXC (CMD : %SIZE(CMD));
            *inlr = *on;

      /end-free

     *----------------------------------------------------------------

