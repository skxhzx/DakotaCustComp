      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')
      *----------------------------------------------------------
      *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M23700      Class Maintenance
      *  06 July 2017
      *  Lynn McMahon
      *
      *  Revisions:
      *
710 A *    07/06/17  LMC  7.10
      *      - Created.
     *      - Returns value field for displaying on list.
      *
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pSess          s             40
     D  pClass         s             10
     D  pOutStr        s           1024    varying

     *
     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

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

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D RulesExist      s              1
     D ItemExist       s              1
     D AlwDlt          s              1
     D chk4err         s               n
     D zmflag          s               n
     D zmsflag         s               n

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D iclrec        E Ds                  Extname(itemcls)
     D carrec        E Ds                  Extname(classrule)

     *----------------------------------------------------------------
     *  Called programs
     *

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSess        Session Id
     *      pClass       Class Code
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSess
     c                   parm                    pClass
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pOutStr = ' ';
        RulesExist  = ' ';
        ItemExist   = ' ';

        // delete is not allowed if class is linked to an item
        exec sql select * into :iclrec
              from itemcls
              where iclcde = :pClass;

        If sqlstt = sqlSuccess;
          ItemExist = 'Y';
        endif;

        // delete is not allowed if rules exist for the class
        exec sql select * into :carrec
              from classrule
              where carcl1 = :pClass;

        If sqlstt = sqlSuccess;
          RulesExist = 'Y';
        endif;

        // delete is not allowed if rules exist for the class
        exec sql select * into :carrec
              from classrule
              where carcl2 = :pClass;

        If sqlstt = sqlSuccess;
          RulesExist = 'Y';
        endif;

        if RulesExist = 'Y' or ItemExist = 'Y';
          AlwDlt = ' ';
        else;
          AlwDlt = 'Y';
        endif;
         // Put together JSON string
         pOutStr = '{'
                +  '"AlwDlt":"'  + %trimr(AlwDlt) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

          endsr;
      /end-free

