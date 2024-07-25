      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DDOPTSUPD  Update DDOPTS file
     *  11 August 2014
     *  Dave Sommerville
     *
     *  Revisions:
     *
650 A*    08/11/14  DAS  6.50
     *      - Created.
     *
730 A*    10/14/19  KDE  7.30
     *      - Force include hover tips for DD1 since it fails without it checked
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits an External Program parameter to 999 characters.
     *
     *   The JSON string that is passed in is not true JSON. The
     *   string will contain the following:
     *
     *   {"opt":"aaa","val":"bbb"},{"opt":"aaa","val":"bbb"},...
     *
     *   were aaa is the DDOPTS code and val is the value.
     *
     *   One {"opt"} will be sent for each compartment. The code
     *   will be BFC_CUSTOM_COLORSc, where c is the comparment code.
     *   The TRKCOMPCLR file will be updated from these records. Then
     *   after all options have been process TRKCOMPCLR will be read
     *   to create the value for BFC_CUSTOM_COLORS.
     *
     *   True JSON would have bundled all of the {opt}'s into
     *   a JSON array.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fddopts    uf a e           k disk
     Ftrkcompclruf a e           k disk
     Ftrkcomp   if   e           k disk
     Fglosess   if   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pJSON       JSON String
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     D ddoptsupd       pr                  extpgm('DDOPTSUPD')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pJSON                       999    varying

     D ddoptsupd       pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pJSON                       999    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n

     D opt             s             40    varying
     D val             s            400    varying
     D delimiter       s              1    varying
     D comp            s              1

     D i               s              5p 0
     D optBeg          s              5p 0
     D optEnd          s              5p 0
     D optLen          s              5p 0
     D optPos          s              5p 0
     D valBeg          s              5p 0
     D valEnd          s              5p 0
     D valLen          s              5p 0
     D valPos          s              5p 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         select;

           when pObjLoc = 'FLDVALID';
             exsr ProcessJSON;

         endsl;

         return;
      /end-free

     *----------------------------------------------------------------
     *  ProcessJSON   Process JSON string
     *----------------------------------------------------------------

      /free
       begsr ProcessJSON;

         if %len(pJSON) = 0;
           leavesr;
         endif;

         chain (pSessId) glosess;
         if not %found(glosess);
           leavesr;
         endif;

         i = 1;
         dow forever = forever;

           // Get next option

           optPos = %scan('"opt"': pJSON: i);
           if optPos = 0;
             leave;
           endif;

           // Calculate beginning of option code

           optBeg = optPos + 7;

           // Get end of option code

           optEnd = %scan('",': pJSON: optBeg);
           if optEnd = 0;
             leave;
           endif;

           // Calculate length of option code

           optLen = optEnd - optBeg;

           // Get option code

           opt = %subst(pJSON: optBeg: optLen);

           // Calculate beginning of value

           valBeg = optEnd + 9;
           if valBeg > %len(pJSON);
             leave;
           endif;

           // Get end of value

           valEnd = %scan('"}': pJSON: valBeg);
           if valEnd = 0;
             leave;
           endif;

           // Calculate length of value

           valLen = valEnd - valBeg;

           // Get option code

           val = %subst(pJSON: valBeg: valLen);

           // Update record

           if %len(opt) > 17 and %subst(opt:1:17) = 'BFC_CUSTOM_COLORS';
             exsr UpdateComp;
           else;
730 A        // if DD_Tips force checked (On).  DD1 fails if not checked
730 A        if %trim(opt) = 'BFC_DD_TIPS' and %trim(val)<>'ON';
730 A           pErrmsg = 'Include hover tips must be checked';
730 A        else;
                exsr UpdateOpt;
730 A        endif;
           endif;

           i = valEnd;

         enddo;

         exsr UpdateOptColor;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateOpt    Update option value
     *----------------------------------------------------------------

      /free
       begsr UpdateOpt;

         chain (opt) ddopts;

         if not %found(ddopts);
           docode = opt;
           dovalue = val;
           write(e) dorec;
           if %error;
             pErrmsg = 'Error writing ' + opt + ' record';
           endif;
         else;
           dovalue = val;
           update(e) dorec;
           if %error;
             pErrmsg = 'Error updating ' + opt + ' record';
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateOptColor   Update BFC_CUSTOM_COLOR option
     *----------------------------------------------------------------

      /free
       begsr UpdateOptColor;

         val = '';
         delimiter = '';

         setll (gswhse) trkcomp;

         dow forever = forever;

           reade (gswhse) trkcomp;
           if %eof(trkcomp);
             leave;
           endif;

           chain(n) (tpwhse: tpcode) trkcompclr;
           if not %found(trkcompclr);
             iter;
           endif;

           if tpccolor > '';
             val += delimiter + tpccode + ',' + %trimr(%subst(tpccolor: 2));
             delimiter = ',';
           endif;

         enddo;

         opt = 'BFC_CUSTOM_COLORS';
         exsr UpdateOpt;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateComp   Update Compartment color
     *----------------------------------------------------------------

      /free
       begsr UpdateComp;

         // Extract the compartment code

         comp = %subst(opt: 18: 1);

         // Update comparment color record.

         chain (gswhse: comp) trkcompclr;

         if not %found(trkcompclr);
           tpcwhse = gswhse;
           tpccode = comp;
           tpccolor = val;
           if tpccolor > '';
             write(e) tpcrec;
             if %error;
               pErrmsg = 'Error writing color ' + val + ' record';
             endif;
           endif;
         else;
           tpccolor = val;
           update(e) tpcrec;
           if %error;
             pErrmsg = 'Error updating color ' + val + ' record';
           endif;
         endif;

       endsr;
      /end-free
