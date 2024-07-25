      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II297S    Staging - Pre-Cleanup
     *  January 5, 2021
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
740a *   01/05/21  RTR  7.40a
     *     - Created
     *
     *----------------------------------------------------------------
     * Files
     fimpsitmn1 uf   e           k disk
     *----------------------------------------------------------------
     *  Customer id
      /copy qcopysrc,id#eop
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
      /copy qcopysrc,c#stdsql
     *----------------------------------------------------------------
     *  File data structures
     d prvrec        e ds                  extname(impsitmn)
     d                                     prefix(prv_)
     *----------------------------------------------------------------
     *  Working variables
     d pWhse           s              3p 0
     d itemchanged     s               n
     d prvbatid        s             11a

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------
     d main            pr                  extpgm('II297S')
      * Input
     d   $pWhsea                      3    const
     d   $pBatId                     11    const

     d main            pi
      * Input
     d   $pWhsea                      3    const
     d   $pBatId                     11    const

     *----------------------------------------------------------------
     * Main line
     *
      /free

        // Start with Whse/Batch passed
        setll (pWhse:$pBatId) impsitmn1;
        reade (pWhse:$pBatId) impsitmn1;

        // Read each item record in current batch
        dou %eof();

          // select previous batid for this item
          exec sql select max(iubatid) into :prvbatid
                     from impsitmn
                    where iuwhse = :iuwhse
                      and iubatid < :iubatId
                      and iuitem = :iuitem;
          if sqlstt <> sqlsuccess;
            reade (pWhse:$pBatId) impsitmn1;
            iter;
          endif;

          // select previous batid for this item
          exec sql select * into :prvrec
                     from impsitmn
                    where iuwhse = :iuwhse
                      and iubatid = :prvbatid
                      and iuitem = :iuitem;
          if sqlstt <> sqlsuccess;
            reade (pWhse:$pBatId) impsitmn1;
            iter;
          endif;

          exsr zzCompItem;

          if not itemchanged;
            delete iurec;
          endif;

          reade (pWhse:$pBatId) impsitmn1;
        enddo;

        *inlr = *on;
      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *
      /free
        begsr *inzsr;

          monitor;
            pWhse = %dec($pWhsea: 3: 0);
          on-error;
            pWhse = 1;
          endmon;

        endsr; // *inzsr
      /end-free

     *----------------------------------------------------------------
     *  zzCompItem      Compare Item Data
     *----------------------------------------------------------------
      /free
        begsr zzCompItem;

          itemchanged = *off;
          if IUUTYP  <> prv_IUUTYP
           or IUITEM <> prv_IUITEM
           or IUTYPE <> prv_IUTYPE
           or IUDESC <> prv_IUDESC
           or IUWHDP <> prv_IUWHDP
           or IUSTYP <> prv_IUSTYP
           or IUDESG <> prv_IUDESG
           or IUACTV <> prv_IUACTV
           or IUBLD  <> prv_IUBLD
           or IUVEN  <> prv_IUVEN
           or IUVITM <> prv_IUVITM
           or IUPDSC <> prv_IUPDSC
           or IUUM1  <> prv_IUUM1
           or IUUM2  <> prv_IUUM2
           or IUUMQ2 <> prv_IUUMQ2
           or IUFLG1 <> prv_IUFLG1
           or IUUM3  <> prv_IUUM3
           or IUUMQ3 <> prv_IUUMQ3
           or IUFLG2 <> prv_IUFLG2
           or IUULEN <> prv_IUULEN
           or IUUWDT <> prv_IUUWDT
           or IUUHGT <> prv_IUUHGT
           or IUCUBE <> prv_IUCUBE
           or IUSWGT <> prv_IUSWGT
           or IUCWGT <> prv_IUCWGT
           or IUREPL <> prv_IUREPL
           or IUBLNK <> prv_IUBLNK
           or IUFLGD <> prv_IUFLGD
           or IUFLGB <> prv_IUFLGB
           or IUSLIF <> prv_IUSLIF
           or IUNDAY <> prv_IUNDAY
           or IUTIE  <> prv_IUTIE
           or IUHIGH <> prv_IUHIGH
           or IUMFLG <> prv_IUMFLG
           or IUDDAY <> prv_IUDDAY
           or IUUDAY <> prv_IUUDAY
           or IUMDAY <> prv_IUMDAY
           or IUMITM <> prv_IUMITM
           or IUCITM <> prv_IUCITM
           or IUNSLT <> prv_IUNSLT
           or IUXDCK <> prv_IUXDCK
           or IUBNBR <> prv_IUBNBR
           or IUBNAM <> prv_IUBNAM
           or IUVNAM <> prv_IUVNAM
           or IUBRND <> prv_IUBRND
           or IULOT  <> prv_IULOT
           or IULTRK <> prv_IULTRK
           or IUODAY <> prv_IUODAY
           or IURG1C <> prv_IURG1C
           or IURG2C <> prv_IURG2C
           or IUPQN1 <> prv_IUPQN1
           or IUPQN2 <> prv_IUPQN2
           or IUPQN3 <> prv_IUPQN3
           or IMPGRP <> prv_IMPGRP
           or IMPPNT <> prv_IMPPNT
           or IMPVAR <> prv_IMPVAR
           or IMPCAT <> prv_IMPCAT
           or IMPMS1 <> prv_IMPMS1
           or IMPMS2 <> prv_IMPMS2
           or IMPMS3 <> prv_IMPMS3
           or IMPMS4 <> prv_IMPMS4
           or IMPMS5 <> prv_IMPMS5;
            itemchanged = *on;
          endif;

        endsr; // zzCompItem
      /end-free

