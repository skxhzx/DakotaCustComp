      /copy *libl/qcopysrc,hspecs
      *****************************************************************
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
      *****************************************************************
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ORDCUBE   Get ordered cube
     *  07 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    08/07/12  DAS  6.40
     *      - Created.
     *
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

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D sqlUser         s             10
     D sqlView         s              1
     D sqlAuth         s              1

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse   - Warehouse
     *      pRtid   - Route id
     *
     *    Returned Parameters
     *      pCube   - Ordered cube
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pRtid             5
     C                   parm                    pCube             9 3

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         exec sql select sum(rsordc) into :pCube
                  from rtesum
                  where rswhse = :pWhse and rsrtid = :pRtid;

         if sqlstt <> sqlSuccess;
           pCube = 0;
         endif;

         return;

      /end-free
