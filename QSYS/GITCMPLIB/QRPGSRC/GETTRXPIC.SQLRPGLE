      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTRXPIC   Get Trax Pictures based on Type Passed
     *  06 Feb 2018
     *  Kenneth Elder
     *
     *  Revisions:
     *
720 A*    02/06/18  KDE  7.20
     *      - Created.
720aA*    08/31/18  LMC  7.20a
     *      - Added PCM pictures
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk
     Fttpics    if   e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  *TRAX2  -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPTSBU  -  Use system suspend battery power timeout.
     *    OPTSB   -  System suspend battery power timeout.
     *    OPTSEU  -  Use system suspend external power timeout.
     *    OPTSE   -  System suspend external power timeout.
     *    OPTBBU  -  Use backlight off battery power timeout.
     *    OPTBB   -  Backlight off battery power timeout.
     *    OPTBEU  -  Use backlight off external power timeout.
     *    OPTBE   -  Backlight off external power timeout.
710bA*    OPTV12  -  Default = N.  Y = create V1.2 xml.
710bA*    OPTV20  -  Default = N.  Y = create V2.0 xml.
710cA*    OPTDIR  -  IFS main directory
710dA*    OPTIU   -  IFS user
     *
     * Data structure
     *
     D opdata          ds
     D  optsbu                 1      1
     D  optsb                  2      4  0
     D  optseu                 5      5
     D  optse                  6      8  0
     D  optbbu                 9      9
     D  optbb                 10     13  0
     D  optbeu                14     14
     D  optbe                 15     17  0
710bAD  optv12                18     18
710bAD  optv20                19     19
710cAD  optdir                20     39
710dAD  optiu                 40     49
     D  opten2               117    117

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d pathDefined     s              1
     d sigPicFound     s              1
720aAd PCMPicFound     s              1
     d imgCount        s              3  0

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3  0
     D  pRteid         s              5    varying
     D  pPicTp         s             10    varying
     D  pStp           s              2  0
     D  pOrd           s              7  0
     D  pSeq           s              5  0
     D  pItem          s             15    varying
     D  pLbl#          s              7  0
     D  pTrax#         s              5  0
     D  pOutStr        s           1024    varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pWhse       Warehouse
     *      pRteId      Route ID
     *      pPicTp      Picture Type
     *      pStp        Route Stop Number
     *      pOrd        Order Number
     *      pSeq        Sequence
     *      pItem       Item Number
     *      pLbl#       Label Number
     *      pTrax#      Trax Number
     *
     *    Returned Parameters
     *      pOutStr     Json Return String
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse
     C                   parm                    pRteid
     C                   parm                    pPicTp
     C                   parm                    pStp
     C                   parm                    pOrd
     C                   parm                    pSeq
     C                   parm                    pItem
     C                   parm                    plbl#
     C                   parm                    pTrax#
     C                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;
        pOutStr = ' ';
        exsr getPicPath;

        select;
           when pPicTp = 'SIG';       // Signature
              exsr getSig;
           when pPicTp = 'STOP';      // Stop Pictures
              exsr getStop;
           when pPicTp = 'RETURNS';   // Return Pictures
              exsr getReturn;
720aA      when %subst(pPicTp:1:1)  = 's';   // Return Pictures
720aA         exsr getPCM;
        endsl;

        // ---   getPicPath - Determine Picture Context Path from Trax
        // ---                options record *TRAX2

         begsr getPicPath;

            chain (pWhse:'*TRAX2') options;
            if  not %found(options);
               pathdefined = 'N';
            else;
               pathdefined = 'Y';
            endif;

         endsr;

        // ---   getSig - Get Signature image for Stop

         begsr getSig;

            chain (pWhse:pRteId:pPicTp:pStp) TTPICS;
            if  not %found(ttPics) or pathDefined = 'N';
               sigPicFound = 'N';
               pOutStr = '{'
                   +  '"pathdefined":"'  + %trim(pathdefined) + '",'
                   +  '"sigPicFound":"'  + %trim(sigPicFound) + '",'
                   +  '"sigPic":"'  + 'No Signature' + '"}';
               return;
            else;
               sigPicFound = 'Y';
               pOutStr = '{'
                   +  '"pathdefined":"'  + %trim(pathdefined) + '",'
                   +  '"sigPicFound":"'  + %trim(sigPicFound) + '",'
                   +  '"sigPic":"/' + %trim(optdir)  + '/'
                   +  'Pictures/JPG/'
                                    + %trim(ttpcfnam) + '"}';
               return;
            endif;
         endsr;

        // ---   getSTop - Get and Stop notes for Stop

         begsr getStop;

            setll (pWhse:pRteId:pPicTp:pStp) TTPICS;
            reade (pWhse:pRteId:pPicTp:pStp) TTPICS;

            // setup initial json string based on finding record
            pOutStr = '{'
                +  '"pathdefined":"'  + %trim(pathdefined) + '",';
            if %equal(ttpics);
               sigPicFound = 'Y';
               pOutstr = %trim(pOutStr)
                   +  '"sigPicFound":"'  + %trim(sigPicFound);
            else;
               sigPicFound = 'N';
               pOutstr = %trim(pOutStr)
                   +  '"sigPicFound":"'  + %trim(sigPicFound);
            endif;

            imgCount = 0;
            // if stop record found loop thru up to 10 records
            dow not %eof(ttPics) and pathDefined = 'Y'
               and imgCount <10;
               imgCount = imgCount + 1;
               pOutStr = %trim(pOutStr) + '",'
                   +  '"sigPic' + %char(imgCount) + '":"/'
                   +  %trim(optdir)  + '/' + 'Pictures/JPG/'
                                    + %trim(ttpcfnam);
               reade (pWhse:pRteId:pPicTp:pStp) TTPICS;
            enddo;

            // Set remainding images up to 10 at No Image
            dow imgCount <10;
               imgCount = imgCount + 1;
               pOutStr = %trim(pOutStr) + '",'
                   +  '"sigPic' + %char(imgCount) + '":"'
                   +  'No Stop';
            enddo;

            // terminate json string
            pOutStr = %trim(pOutStr) + '"}';

         endsr;

        // ---   getSTop - Get and Stop notes for Stop

         begsr getReturn;

            setll (pWhse:pRteId:pPicTp:pStp:pItem:pTrax#) TTPICS;
            reade (pWhse:pRteId:pPicTp:pStp:pItem:pTrax#) TTPICS;

            // setup initial json string based on finding record
            pOutStr = '{'
                +  '"pathdefined":"'  + %trim(pathdefined) + '",';
            if %equal(ttpics);
               sigPicFound = 'Y';
               pOutstr = %trim(pOutStr)
                   +  '"sigPicFound":"'  + %trim(sigPicFound);
            else;
               sigPicFound = 'N';
               pOutstr = %trim(pOutStr)
                   +  '"sigPicFound":"'  + %trim(sigPicFound);
            endif;

            imgCount = 0;
            // if stop record found loop thru up to 10 records
            dow not %eof(ttPics) and pathDefined = 'Y'
               and imgCount <10;
               imgCount = imgCount + 1;
               pOutStr = %trim(pOutStr) + '",'
                   +  '"sigPic' + %char(imgCount) + '":"/'
                   +  %trim(optdir)  + '/' + 'Pictures/JPG/'
                                    + %trim(ttpcfnam);
               reade (pWhse:pRteId:pPicTp:pStp:pItem:pTrax#) TTPICS;
            enddo;

            // Set remainding images up to 10 at No Image
            dow imgCount <10;
               imgCount = imgCount + 1;
               pOutStr = %trim(pOutStr) + '",'
                   +  '"sigPic' + %char(imgCount) + '":"'
                   +  'No Return';
            enddo;

            // terminate json string
            pOutStr = %trim(pOutStr) + '"}';

         endsr;
720aA   // ---   getPCM  - Get Pcm pictures
720aA    begsr getPCM;

720aA       chain (pWhse:pRteId:pPicTp) TTPICS;
720aA       if  not %found(ttPics) or pathDefined = 'N';
720aA          PCMPicFound = 'N';
720aA          pOutStr = '{'
720aA              +  '"pathdefined":"'  + %trim(pathdefined) + '",'
720aA              +  '"PCMPicFound":"'  + %trim(PCMPicFound) + '",'
720aA              +  '"PCMPic":"'  + 'No Picture' + '"}';
720aA          return;
720aA       else;
720aA          PCMPicFound = 'Y';
720aA          pOutStr = '{'
720aA              +  '"pathdefined":"'  + %trim(pathdefined) + '",'
720aA              +  '"PCMPicFound":"'  + %trim(PCMPicFound) + '",'
720aA              +  '"PCMPic":"/' + %trim(optdir)  + '/'
720aA              +  'Pictures/JPG/'
720aA                               + %trim(ttpcfnam) + '"}';
720aA          return;
720aA       endif;
720aA    endsr;

      /end-free
