     h/copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  QDACC030     FIX: Set missing slot exp date from license exp
     *  December 20, 2019
     *  Rod Roller
     *
     *  Notes:
     *
     *----------------------------------------------------------------
     *  Revisions
     *
730  *   12/20/19  RTR  7.30
     *     - Created.
740  *   03/17/20  RH   7.40
     *     - Enh: Change to update slot expiration date, don't iter
     *       if slot date is <> 0.
     *
     *----------------------------------------------------------------
     *  File Specs
     flicactive if   e           k disk
     fslot2     if   e           k disk
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Prototypes
     d FixSlot         pr                  extpgm('LTFIXDTECL')
     d   pWhse                        3  0 const
     d   pDept                        5    const
     d   pSlot                       12    const
     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
      /free

        dou forever <> forever;
          read larec;
          if %eof();
            leave;
          endif;

          // Skip if no exp date;
          if laexpd = 0;
            iter;
          endif;

          chain (lawhse:lawhdp:ladisp) slot2;
          if not %found(slot2);
          // or slexpd > 0;
            iter;
          endif;

          FixSlot (lawhse:lawhdp:ladisp);

        enddo;

        *inlr = *on;
        return;
      /end-free
