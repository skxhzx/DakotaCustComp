      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2016 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M15600      Purchase Order History Receiving Header
      *  02 June 2016
      *  Lynn McMahon
      *
      *  Revisions:
      *
700 A *    06/02/16  LMC  7.00
      *      - Created.
     *      - Returns value field for displaying on list.
      *
720a *    08/22/18  LMC  7.20a
     *      - Recompile only - Databases changes.
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getpales
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chklist
      /copy qcopysrc,p.cvtcase
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
     D  pPO            s              9
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#coastal
      /COPY QCOPYSRC,ID#SAVAL
      /COPY QCOPYSRC,ID#GFS
      /COPY QCOPYSRC,ID#EGF
      /COPY QCOPYSRC,ID#CITYLIN
      /COPY QCOPYSRC,ID#PACKERS
      /COPY QCOPYSRC,ID#JORDANO
      /COPY QCOPYSRC,ID#GLAZIER

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D count           s              5p 0
     D option          s             20
     D PCMExist        s              1

     D QtyRec          s              6s 0
     D Qty1            s              6s 0
     D Qty2            s              6s 0
     D Qty3            s              6s 0
     D WgtRec          s             10s 2
     D Wgt             s             10s 2
     D QtyOrd          s              6s 0
     D QtyO1           s              6s 0
     D QtyO2           s              6s 0
     D QtyO3           s              6s 0

     D client          s             10
     D clientloc       s             10
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D phdrec        E Ds                  Extname(pohdtl)
     D opsrcv        E Ds                  Extname(opsrcvlbl)
     D hlrec         e ds                  extname(haccplog)


     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pPO          Purchase Order
     *      pUser        User
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pPO
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        pOutStr = ' ';
        // get quantity ordered and received
        QtyRec = 0;
        QtyOrd = 0;
        WgtRec = 0;

        exec sql select sum(phdqr1), sum(phdqr2), sum(phdqr3),
                        sum(phdwgt),
                        sum(phdqo1), sum(phdqo2), sum(phdqo3)
                 into :qty1,:qty2,:qty3,:wgt,:qtyO1,:qtyO2,:qtyO3
                 from pohdtl
                 where phdwhs = :pWhse
                   and phdpo  = :pPO
                   and phdspc <>'BR';
            If sqlstt = sqlSuccess;
              QtyRec = qty1 + qty2 + qty3;
              QtyOrd = qtyO1 + qtyO2 + qtyO3;
              WgtRec = wgt;
            endif;

        // check user security for delete allowed
        // check to see if pcm records exist
        PCMExist = ' ';
        exec sql select * into :hlrec
                 from haccplog
                 where hlwhse = :pwhse
                   and hlpo   = :ppo
                   and hlexpts = '0001-01-01-00.00.00.000000'
                   and hlobsolete <> 'Y'
                 fetch first row only;
        if sqlstt = sqlSuccess;
          PCMExist = 'Y';
        endif;

         // Put together JSON string
         pOutStr = '{'
                +  '"QtyO":"'  + %char(QtyOrd) + '",'
                +  '"QtyR":"'  + %char(QtyRec) + '",'
                +  '"WgtR":"'  + %char(WgtRec) + '",'
                +  '"PCMExist":"'  + %trimr(pcmexist) + '"';

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
        // see if all lines must be touched
        exec sql select * into :opsrcv
                 from opsrcvlbl
                 where opwhse  = :pWhse;
        if sqlstt = sqlsuccess;
        else;
          opfrcm = 'N';
        endif;
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

