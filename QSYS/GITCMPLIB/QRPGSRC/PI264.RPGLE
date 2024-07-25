     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  PI264     Preprocess FTP Purchase Orders
     *  Rod Roller
     *  September 27, 2018
     *
     *----------------------------------------------------------------
     *  Revisions
     *
720  *    09/27/18  RTR  7.20
     *      - Created
     *
     *----------------------------------------------------------------
     *  Notes
     *
     *----------------------------------------------------------------
     * File Specs
     *
     fimpfpoh2  uf   e             disk    usropn
     fimpfpod2  uf   e             disk    usropn
     *----------------------------------------------------------------
     *  Customer id
     *
     d @getcl          c                   const('GETCLIENT')
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Variables
     *
     d AspenWhse       s               n   inz('1')
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

          select;

            when AspenWhse;
              exsr SetAspenWhse;

          endsl;

        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     c     *inzsr        begsr
     *
     * Get client id.
     c                   call      @getcl
     c                   parm      *blanks       client           10
     c                   parm      *blanks       cliloc           10
     *
     c                   endsr
     *----------------------------------------------------------------
     *  SetAspenWhse    Set Aspen multi warehouse on item
     *----------------------------------------------------------------
      /free
        begsr SetAspenWhse;

          open impfpoh2;
          dow forever = forever;

            read impfpoh2;
            if %eof(impfpoh2);
              leave;
            endif;

            pihwhs = 1;
            update pihrec;

          enddo;
          close impfpoh2;

          open impfpod2;
          dow forever = forever;

            read impfpod2;
            if %eof(impfpod2);
              leave;
            endif;

            piditm = %trim(piditm) + '-'
                   + %subst(%editc(pidwhs:'X'):2:2);
            pidwhs = 1;
            update pidrec;

          enddo;
          close impfpod2;

        endsr;  // SetAspenWhse
      /end-free
