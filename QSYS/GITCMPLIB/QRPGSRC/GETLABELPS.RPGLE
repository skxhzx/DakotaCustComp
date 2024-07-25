      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETLABELPS   Get LABELPS section code counts
     *  27 October 2014
     *  Jeffrey Jahnke
     *
650aA*    10/27/14  JCJ  6.50a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     flabelps   if   e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D count           s              5s 0
     D temp5           s              5
     D prevSSCID       s              2
     D firstpass       s               n   inz(*on)

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     pLabel - Label
     *
     *   Return Value:
     *     pSectCnt   -  Pallet Section Count
     *
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pWhse             3 0
     C                   parm                    pLabel            7 0
     C                   parm                    pSectCnt         20
     C                   parm                    pSCount           2 0

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       // Initialize return parms

         pSectCnt = ' ';
         PrevSSCID = ' ';

       // Get LABELPS record

         setll (pWhse: pLabel) labelps;

         dow forever = forever;

           reade (pWhse: pLabel) labelps;

           if %eof(labelps);
             leave;
           endif;

           select;
           when FirstPass;
             FirstPass = *off;
             PrevSSCID = LSSCID;
             Count = 1;
             PSCount = 1;
           when PrevSSCID <> LSSCID;
             temp5 = %trim(PrevSSCID) + %char(count);
             pSectCnt = %trim(pSectCnt) + temp5;
             PrevSSCID = LSSCID;
             Count = 1;
             PSCount += 1;
           other;
             Count += 1;
           endsl;

         enddo;

         temp5 = %trim(PrevSSCID) + %char(count);
         pSectCnt = %trim(pSectCnt) + temp5;

        *inlr = *on;
        return;

      /end-free
