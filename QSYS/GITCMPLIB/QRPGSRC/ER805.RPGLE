      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  ER805     EPM Custom export trans data
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740  *    01/10/20  RTR  7.40
     *      - Created.
740a *    12/10/20  RTR  7.40a
     *      - Fix for PIRTRAND records with no user number.
740b *    12/18/20  RTR  7.40b
     *      - Fix for other missing user records.
740c *    01/03/21  RTR  7.40c
     *      - Fix for XDK Putaway and BULKF.
740d *    01/06/21  RTR  7.40d
     *      - Fix for PUTRTN where PTD emp=0.
     *
     *----------------------------------------------------------------
     *  Notes -
     *
     *----------------------------------------------------------------
     * File Specs
     fpirtrand5 if   e           k disk
     fliclog2   if   e           k disk
     fpiruser1  if   e           k disk
     fer805f    uf a e           k disk    prefix(out_)

     *----------------------------------------------------------------
     *  Variables
     *
     d datework        s               d   datfmt(*iso)
     d pWhse           s              3s 0
     d pRundate        s              6s 0

     *----------------------------------------------------------------
     *  Called program parameters
740aA /copy qcopysrc,p.getuser
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Parameters
     d main            pr                  extpgm('ER805')
     d                                3
     d                                6
     d main            pi
     d   pWhsea                       3
     d   pRundatea                    6

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     * Main line
     *
      /free

         pWhse = 1;

         // If date not passed, use current minus 1 day
         if pRunDatea = *blanks;
           datework = %date() - %days(1);
           pRunDate = %dec(%char(datework:*ymd0):6:0);
           pRunDatea = %char(pRunDate);
         else;
           pRunDate = %dec(pRunDatea:6:0);
         endif;

         setll (pWhse:pRundate) pirtrand5;
         reade (pWhse:pRundate) pirtrand5;

         dow ptdshftday = pRundate;

           if ptdtask <> 'FIXED'
740cA       and ptdtask <> 'BULKF';

740bA        lladdemp = 0;
740bA        llaction = *blanks;
740bA        llaqty1 = 0;
740bA        llaqty2 = 0;
740bA        llaqty3 = 0;
740bA        llrqty1 = 0;
740bA        llrqty2 = 0;
740bA        llrqty3 = 0;
740bA        lldisp = *blanks;
740bA        llitem = *blanks;

             // get liclog rec if has trans number
             clear llrec;
             if ptdtran > 0;
               chain (ptdwhse: ptdtran) liclog2;
               if not %found(liclog2);
                 clear llrec;
               endif;
             endif;

740bA        if ptdempnum > 0
740bA         or lladdemp > 0;

               // get user name
               clear usrec;
740bA          usemp# = 0;
740bA          usfnam = *blanks;
740bA          uslnam = *blanks;
               if ptdempnum > 0;
                 chain (ptdempnum) piruser1;
                 if not %found(piruser1);
                   clear usrec;
                 endif;
740aA          else;
740dA           if ptdtask <> 'PUTRTN';
740aA            chain (lladdemp) piruser1;
740aA            if not %found(piruser1);
740aA              clear usrec;
740aA            endif;
740dA           endif;
               endif;

740cA          select;
740cA            when ptdtask = 'PUTEMP' and llaction = 'XDK';
740cA              // skip, do nothing
740cA            other;
740cA              exsr wrtRec;
740cA          endsl;

740bA        endif;
           endif;

           reade (pWhse:pRundate) pirtrand5;
           if %eof(pirtrand5);
             leave;
           endif;

         enddo;

         *inlr = *on;
      /end-free
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     C                   endsr

740cA*----------------------------------------------------------------
740cA*  wrtRec  Write Record
740cA /free
740cA   begsr wrtRec;
740cA
740dA          clear rec805;
740cA          out_PTDWHSE    = PTDWHSE;
740cA          out_PTDTASK    = PTDTASK;
740cA          out_LLACTION   = LLACTION;
740cA          out_PTDGRSPCS  = PTDGRSPCS;
740cA          out_LLAQTY1    = LLAQTY1;
740cA          out_LLAQTY2    = LLAQTY2;
740cA          out_LLAQTY3    = LLAQTY3;
740cA          out_LLRQTY1    = LLRQTY1;
740cA          out_LLRQTY2    = LLRQTY2;
740cA          out_LLRQTY3    = LLRQTY3;
740cA          out_LLDISP     = LLDISP;
740cA          out_LLITEM     = LLITEM;
740aD        //out_PTDEMPNUM  = PTDEMPNUM;
740aM          out_PTDEMPNUM  = USEMP#;
740cA          if USFNAM <> *blanks;
740cA            out_EMPNAME  = %trim(uslnam) + ', ' + %trim(usfnam);
740dA          else;
740dA            out_EMPNAME  = *blanks;
740cA          endif;
740cA          out_LLLCNS     = LLLCNS;
740cA          out_LLOLCNS    = LLOLCNS;
740cA          out_PTDTRAN    = PTDTRAN;
740cA          out_LLLBL#     = LLLBL#;
740cA          out_PTDGDTE    = PTDGDTE;
740cA          out_PTDGTIM    = PTDGTIM;
740cA          out_PTDSHFTDAY = PTDSHFTDAY;
740cA          out_LLWHSE     = LLWHSE;
740cA          write rec805;
740cA
740cA   endsr; //  wrtRec
740cA
