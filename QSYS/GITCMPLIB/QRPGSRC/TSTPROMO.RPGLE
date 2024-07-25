     H/COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTPROMO     Test program CALCPROMO
     *  21 July 2007
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D pWhse           s              3s 0
     D pRtid           s              5
     D pType           s              1
     D pTrn#           s              7  0
     D pTblEnt         s              3  0
     D pRtn            s              8

     D pTbl            ds                  occurs(30)
     D  pTblValue                     7  0
     D  pTblPcs1                      5  0
     D  pTblPcs2                      5  0
     D  pTblPcs3                      5  0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
           clear *all pTbl;
      /end-free

     C                   call      'CALCPROMO'
     C                   parm      900           pWhse
     C                   parm      '00001'       pRtid
     C                   parm      'STOP'        pType
     C                   parm      2005          pTrn#
     C                   parm                    pTbl
     C                   parm                    pTblEnt
     C                   parm                    pRtn

     C                   call      'CALCPROMO'
     C                   parm      900           pWhse
     C                   parm      '00001'       pRtid
     C                   parm      'ORDER'       pType
     C                   parm      2005          pTrn#
     C                   parm                    pTbl
     C                   parm                    pTblEnt
     C                   parm                    pRtn

     C                   eval      *inlr = *on
     C                   return
