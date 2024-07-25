      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  PM03000     Get next Emp#
     *
     *  17 August 2015
     *  Lynn McMahon
     *
     *  Revisions:
     *
700 A*    08/17/15  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pErrMsg        s             99
     D  pEmp#          s              5p 0
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dbgflgExists    s               n
     D debug           s               n

     D NextEmp         s              5p 0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Process control(previously Haccp) question file
     *----------------------------------------------------------------

     D gurec         E Ds                  Extname(glousr1)
     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *       pEmp#  Employee number
     *
     *    Returned Parameters
     *       pErrMsg     Error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Work field data structure
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pEmp#
     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';


         Nextemp = 0;
         // if we already have a value we are not in add mode.
         // Do Not need to get next seq#, just return
         if pEmp# > 0;
           return;
         endif;

         exsr getnextEmp;

         pEmp# = Nextemp;
         // Write error to log

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR   Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *INZSR;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  GetNextEmp  Get the next available Employee #
     *----------------------------------------------------------------

      /free
       begsr GetNextEmp;

         exec sql select * into :gurec
                  from glousr1
                  order by guemp# desc
                 fetch first 1 rows only;

         If sqlstt = sqlSuccess;
           NextEmp = guemp# + 1;
         else;
           Nextemp = 1;
         endif;

       endsr;
      /end-free
