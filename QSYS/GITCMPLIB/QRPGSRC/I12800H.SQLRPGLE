      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
      *  H Bnddir('QC2LE')
      *----------------------------------------------------------
      *   Copyright (C) 2015 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  I12800H     PO Receiving - Receiving History Header
      *  24 March 2015
      *  Lynn McMahon
      *
      *  Revisions:
      *
650 A *    03/24/15  LMC  6.50
      *      - Created.
     *      - Returns value field for displaying on list.
700a  *    06/07/16  LMC  7.00a
      *      - Enh - Added to check for Branded Items, send flag back
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------


     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.chklist
      /copy qcopysrc,p.cvtcase
700aA /copy qcopysrc,p.GETBRAND
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
     D  pitem          s             15
     D  pUser          s             10
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

650eA*----------------------------------------------------------------
650eA*  Customer id
650eA*----------------------------------------------------------------

650eA /COPY QCOPYSRC,ID#CITYLIN

     *----------------------------------------------------------
     *  Variables
     *----------------------------------------------------------

     D AllowTag        s              1


     D client          s             10
     D clientloc       s             10

700aAD pBrand          s              1
700aAD bCmd            s             10
700aAD bBrand          s             10
700aAD bParentitm      s             15
700aAD bBranditm       s             15
700aAD bBrandFlg       s              1
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D ifrec         E Ds                  Extname(itemfld)


     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pItem        Item
     *      pUser        User
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pItem
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        pUser  = cvt2Upper(pUser);
        allowTag    = 'N';
        pOutStr = ' ';

        exec sql select * into :ifrec
             from itemfld
             where ifwhse = :pWhse
               and ifitem = :pItem;

        If sqlstt = sqlSuccess;
          if ifcat = 'CLAMS';
            allowTag = 'Y';
          endif;
        endif;

700aA    // See if the item in label is a parent Item for Branding
700aA    bCmd = '*GETFLAG';
700aA    bBrand = ' ';
700aA    bParentitm = pitem;
700aA    bBrandItm = ' ';
700aA    bBrandFlg = ' ';
700aA    GetBranded(bCmd: pwhse: bParentitm: bBrand:
700aA               bBrandItm: bBrandFlg);

700aA    pBrand = bBrandFlg;
700aA    if bBrandflg = ' ';
700aA      // See if the item in label is a branded item
700aA      bCmd = '*GET4BITM';
700aA      bBrand = ' ';
700aA      bParentitm = ' ';
700aA      bBrandItm = pitem;
700aA      bBrandFlg = ' ';
700aA      GetBranded(bCmd: pwhse: bParentitm: bBrand:
700aA                 bBrandItm: bBrandFlg);

700aA      pBrand = bBrandFlg;

700aA    endif;

        // Put together JSON string

         pOutStr = '{'
700aA           +  '"Brand":"'  + %trimr(pBrand) + '",'
                +  '"ALWTAG":"'  + %trimr(allowTAG) + '"';

         // Close off the JSON string
         pOutStr += '}';

          *inlr = *on;

      /end-free

      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
        begsr *INZSR;

650eA     getclient(client: clientLoc);
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

