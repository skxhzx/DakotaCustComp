      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2017 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M24500      Cycle Count Adjustment Information
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

      /COPY *libl/qcopysrc,C#LICENSE
     D saveVer#        s                   like($liver#)

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
     D  pDept          s              5
     D  pDisp          s             12
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

     D License         s             15
     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------



     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pDept        Department
     *      pDisp        Slot Display
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pDept
     c                   parm                    pdisp
     c                   parm                    pUser
     c                   parm                    psess
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        pOutStr = ' ';

        savever# = $liver#;
        clear $license;
        clear $license2;
        clear $license3;

        $liToWhseu = *on;
        $liToWhse = pWhse;
        $liToWhdpU = *on;
        $liToWhdp = pDept;
        $liToDispU = *on;
        $liToDisp = pDisp;
        $dricommand = '*LICENSE';
        $drisys2upd = 'D';
        $driprogram = #pgm;
        $drisubcmd  = '%GETSLTLIC';
        $dridata = $license;
        $dridata2 = $license2;
        $dridata3 = $license3;

        // Call DRI program.

        driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
               $drireturn: $drimessage: $dridata: $dridata2: $dridata3);

        $license = $dridata;
        $license2 = $dridata2;
        $license3 = $dridata3;

        License = $litolcns;

        // Put together JSON string
        pOutStr = '{'
                +  '"Lcns":"'  + %trimr(License) + '"';

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

