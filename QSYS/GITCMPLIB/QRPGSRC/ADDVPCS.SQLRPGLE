      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  ADDVPCS   Add voice pieces
     *  04 August 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650 A*    08/04/14  DAS  6.50
     *      - Created.
     *
730aA*    10/04/19  DAS  7.30
     *      - Added warehouse when connection to LABEL and LABELDO.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d fromStamp       s               z
     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')
     d seconds         s              7p 0
     d toStamp         s               z
     d voiceGrossPcs   s              5p 0
     d voiceGrossMrg   s              5p 0
640iAd voiceGrossBlk   s              5p 0
     d voicePcs        s              5p 0
     d voiceMrgPcs     s              5p 0
640iAd voiceBlkPcs     s              5p 0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pTran          s              7p 0
     D  pTranStat      s              1
     D  pTranStart     s             26
     D  pTranEmp       s              5p 0
     D  pSelFlag       s              1p 0
     D  pInclMrg       s              1p 0
     D  pInclBulk      s              1p 0
     D  pPcs           s              9p 0
     D  pSec           s              7p 0
     D  pSecIdle       s              7p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d GetVoicePcs     pr
     d  grossPcs                      5p 0
     d  grossMrg                      5p 0
640iAd  grossBlk                      5p 0
     d  pcs                           5p 0
     d  mrgPcs                        5p 0
640iAd  blkPcs                        5p 0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pTran        Transaction number
     *      pTranStat    Transaction status
     *      pTranStart   Transaction start timestamp
     *      pTranEmp     Transaction employee number
     *      pSelFlag     PIRTRAND selection flag (0,1)
     *      pInclMrg     Include non-bulk merge pieces flag (0,1)
     *      pInclBulk    Include bulk merge pieces flag (0,1)
     *      pPcs         Pieces
     *      pSec         Seconds
     *      pSecIdle     Seconds including Idle time
     *
     *    Returned Parameters
     *      pPcs         Pieces
     *      pSec         Seconds
     *      pSecIdle     Seconds including Idle time
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pTran
     c                   parm                    pTranStat
     c                   parm                    pTranStart
     c                   parm                    pTranEmp
     c                   parm                    pSelFlag
     c                   parm                    pInclMrg
     c                   parm                    pInclBulk
     c                   parm                    pPcs
     c                   parm                    pSec
     c                   parm                    pSecIdle

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         // If transaction is not a Selection tran, get out

         if pSelFlag = 0;
           return;
         endif;

         // If status is not 2=Started, get out

         if pTranStat <> '2';
           return;
         endif;

         // Calculate voice pieces for started selection tran

         GetVoicePcs(voiceGrossPcs: voiceGrossMrg: voiceGrossBlk:
                     voicePcs: voiceMrgPcs: voiceBlkPcs);

         // Add voice pieces to the pieces sent in.
           // In theory, the pieces sent in should be zero because when
           // this was written the pieces in PIRTRAND2 were not being
           // updated until after the transaction is ended.

         pPcs = voicePcs
              + (voiceMrgPcs * pInclMrg)
              + (voiceBlkPcs * pInclBulk);

         // Calculate elapsed seconds for transaction

         fromStamp = %timestamp(pTranStart);
         toStamp = %timestamp();
         seconds = CalcSeconds(fromStamp: toStamp);

         // Add seconds to the sent in seconds

         pSec += seconds;
         pSecIdle += seconds;

         return;

      /end-free

     *----------------------------------------------------------------
     *  CalcSeconds   Calculate seconds between timestamps
     *----------------------------------------------------------------

     p CalcSeconds     b
     d CalcSeconds     pi             7p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D seconds         s              7p 0

      /free

        select;
          when fromTS = noStamp;
            seconds = 0;
          when toTS = noStamp;
            seconds = 0;
          when fromTS > toTS;
            seconds = 0;
          other;
            monitor;
              seconds = %diff(toTS: fromTS: *SECONDS);
            on-error;
              seconds = 0;
            endmon;
        endsl;

        return seconds;

      /end-free

     p CalcSeconds     e

     *----------------------------------------------------------------
     *  GetVoicePcs   Get Pieces picked with voice
     *----------------------------------------------------------------

     p GetVoicePcs     b
     d GetVoicePcs     pi
     d  outGrossPcs                   5p 0
     d  outGrossMrg                   5p 0
640iAd  outGrossBlk                   5p 0
     d  outPcs                        5p 0
     d  outMrgPcs                     5p 0
640iAd  outBlkPcs                     5p 0

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D short           s              5p 0
     D shortInd        s              2b 0

      /free

        // Calculate non-merge pcs picked via voice

        exec sql select sum(lboqty), sum(lboqtys)
                 into :pcs :pcsInd,
                      :short :shortInd
                 from labeldo
730aD            //where lbotrn# = :pTran
730aA            where lbowhse = :pWhse
730aM              and lbotrn# = :pTran
                   and lboemp# = :pTranEmp
650aM              and (lboltype = 'O' or lboltype = 'B');

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossPcs = 0;
            outPcs =0;
          other;
            outGrossPcs = pcs + short;
            outPcs = pcs;
        endsl;

640iA   // Calculate merge pcs picked via voice not associated with bulk pick

        exec sql select sum(lboqty), sum(lboqtys)
                 into :pcs :pcsInd,
                      :short :shortInd
                 from labeldo
730aD            //left outer join label m on m.lblbl# = lbolbl#
730aD            //left outer join label b on b.lblbl# = m.lbctr#
730aD            //where lbotrn# = :pTran
730aM            left outer join label m
730aM                       on m.lbwhse = lbowhse and m.lblbl# = lbolbl#
730aM            left outer join label b
730aM                       on b.lbwhse = m.lbwhse and b.lblbl# = m.lbctr#
730aA            where lbowhse = :pWhse
730aM              and lbotrn# = :pTran
                   and lboemp# = :pTranEmp
                   and lboltype = 'M'
640iA              and b.lbtype <> 'B';

        select;
          when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
            outGrossMrg = 0;
            outMrgPcs =0;
          other;
            outGrossMrg = pcs + short;
            outMrgPcs = pcs;
        endsl;

640iA   // Calculate merge pcs picked via voice associated with bulk pick
640iA
640iA   exec sql select sum(lboqty), sum(lboqtys)
640iA            into :pcs :pcsInd,
640iA                 :short :shortInd
640iA            from labeldo
730aD            //left outer join label m on m.lblbl# = lbolbl#
730aD            //left outer join label b on b.lblbl# = m.lbctr#
730aM            left outer join label m
730aM                 on m.lbwhse = lbowhse and m.lblbl# = lbolbl#
730aM            left outer join label b
730aM                 on b.lbwhse = m.lbwhse and b.lblbl# = m.lbctr#
640iA            where lbotrn# = :pTran
730aA              and lbowhse = :pWhse
640iA              and lboemp# = :pTranEmp
640iA              and lboltype = 'M'
640iA              and b.lbtype = 'B';
640iA
640iA   select;
640iA     when sqlstt <> sqlSuccess
640tA          and sqlstt <> sqlNullValElim;
640iA       outGrossBlk = 0;
640iA       outBlkPcs =0;
640iA     other;
640iA       outGrossBlk = pcs + short;
640iA       outBlkPcs = pcs;
640iA   endsl;

      /end-free

     p GetVoicePcs     e
