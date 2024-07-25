      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  QDACC012  Calc ITEMQTY-IMPSCQTY into IMPSPCKQ Qty2
     *  January 19, 2019
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
ACC  *    01/19/19  RTR  ACC
     *      - Created.
     *
750 A*    05/26/21  MLB  7.50
     *      - Enh: Recompiled pgm due to new fields added to IMPSPCKQ.
     *
     *----------------------------------------------------------------
     fimpscqty  ip   e           k disk
     fitemqty   if   e           k disk
     fimpspckq  o  a e             disk

      /free

        if icbatid = '19011900004';

          chain (icwhse: icitem) itemqty;
          ipqwhs = iqwhse;
          ipqbatid = '19011899997';
          ipqstatus ='R';
          ipqitm = icitem;
          ipqwhd = *blanks;
          ipqdsp = *blanks;
          ipqqp1 = 0;
          ipqqp2 = 0;
          ipqqp3 = 0;
          ipqadj = 'DK';
          ipqmem = 'Fix-force Dakota match';
          if %found(itemqty);
            ipqqp2 = iqstk2 - ictqh2;
            if ipqqp2 <> 0;
              write ipqrec;
            endif;
          endif;

        endif;

      /end-free
