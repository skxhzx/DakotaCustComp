      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M24600      Cycle Count Adjustment Information
      *  16 August 2017
      *  Lynn McMahon
      *
      *  Revisions:
      *
710 A *    08/16/17  LMC  7.10
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

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.cvtcase
      /copy qcopysrc,p.dricop
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
      /COPY *libl/qcopysrc,C#DRIPARMP

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D cvt2Upper       pr           500
     D  zIn                         500    const

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pItem          s             15
     D  pUser          s             10
     D  pSess          s             40
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------


     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D NUomcd          s              2
     D B1Uomcd         s              2
     D B2Uomcd         s              2
     D NUom            s              5
     D B1Uom           s              5
     D B2Uom           s              5
     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D umrec         E Ds                  Extname(unmesr)
     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pItem        Item
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pitem
     c                   parm                    pUser
     c                   parm                    psess
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        pOutStr = ' ';

        savever# = $itver#;
        clear $item;
        clear $item2;

        $itWhse = pWhse;
        $itItem = pItem;
        $dricommand = '*ITEM';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $drisubcmd  = '%GETALL';
        $dridata = $item;
        $dridata2 = $item2;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata);

        $item = $dridata;
        $item2 = $dridata2;

        NUomcd = $itum1;
        B1Uomcd = $itum2;
        B2Uomcd = $itum3;

        // now get the short description for the uom codes
        Nuom = ' ';
        // normal
        exec sql select * into :umrec
             from unmesr
             where umcode = :nuomcd;

        If sqlstt = sqlSuccess;
          Nuom = umshrt;
        endif;

        b1uom = ' ';
        if $itflg1 = 'Y';
          // breakdown1
          exec sql select * into :umrec
               from unmesr
               where umcode = :b1uomcd;

          If sqlstt = sqlSuccess;
            b1uom = umshrt;
          endif;
        endif;

        b2uom = ' ';
        if $itflg2 = 'Y';
          // breakdown2
          exec sql select * into :umrec
               from unmesr
               where umcode = :b2uomcd;

          If sqlstt = sqlSuccess;
            b2uom = umshrt;
          endif;
        endif;

        // Put together JSON string
        pOutStr = '{'
                +  '"Cwgt":"'  + %trimr($itcwgt) + '",'
                +  '"nUOM":"'  + %trimr(nuom) + '",'
                +  '"b1UOM":"'  + %trimr(b1uom) + '",'
                +  '"b2UOM":"'  + %trimr(b2uom) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;

        getclient(client: clientLoc);
           endsr;

      /end-free

     *----------------------------------------------------------------
     *  cvt2Upper  Convert to upper case
     *----------------------------------------------------------------

     p cvt2Upper       b
     d cvt2Upper       pi           500
     d  sIn                         500    const

     * Local variables

     d  sOut           s            500

      /free

         cvtCase('*LOW2UPR': sIn: sOut);
         return sOut;

      /end-free
     p cvt2Upper       e

