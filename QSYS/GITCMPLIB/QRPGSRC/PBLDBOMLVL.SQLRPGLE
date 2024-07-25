710 AHdftactgrp( *NO )
     H  actgrp( *NEW )
     Hbnddir( 'QC2LE' )
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PBLDBOMLVL - Production Rebuild PBOMLVL file
     *  22 January 2019
     *  Mike Rooker
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
520 A*  01/19/19  MR   7.30
     *    - Created.
     *----------------------------------------------------------------
     *  Procedure Call
     *----------------------------------------------------------------
720aAd pcompwo         pr                  extpgm('PCOMPWO')
720aAd  parm1                         3
720aAd  parm2                         2
720aAd  parm3                        15
720aAd  parm4                        15
720aAd  parm5                       100
720aAd  parm6                        15    dim(500)
720aAd  parm7                       500    dim(100)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     d component       S             15
     d pwhse           S              3
     d forever         S              1
     d bcmd            S              2
     d pFgItm          s            100
     d pRmitm          S             15
     d bRtnMsg         s            100
     d parr3w          s             15    dim(500)
     d parr3c          s            500    dim(100)
     d sqlstmt         s            100
     *
     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
     *
     c     *entry        plist
     c                   parm                    pwhse
      //
      /free
            exsr inzStmt;
           //************************************************
           // Get Finished Goods and components for rebuild *
           //************************************************
            exec sql Delete from PBOMLVL;
            exec sql Declare cursor1 scroll cursor for mainStmt;
            exec sql Prepare mainStmt from :Sqlstmt;
            exec sql Open cursor1;
            dow forever = forever;
               exec sql fetch next from cursor1 into :component;
             if sqlcod = 100;
               leave;
             endif;
             //
             bcmd = 'BR';
             pFgItm = component;
             pRmItm = *blanks;
             bRtnMsg = *blanks;
             parr3w = *blanks;
             parr3c = *blanks;

             //**********************
             //Call Rebuild Process *
             //**********************
720aA        pcompwo (pwhse:bcmd:pFgItm:pRmItm:bRtnMsg:parr3w:parr3c);
             //
           enddo;
           exec sql Close cursor1;
           *inlr = *on;
        //
        //********************************
        //* Initialize the sql statement *
        //********************************
        begsr inzStmt;
        //
          sqlstmt = 'select distinct bmfgi from pbom join itemprd +
                     on bmfgi=ipitem where ipprdflg in (''C'',''F'')';
        endsr;
        //
      /end-free
