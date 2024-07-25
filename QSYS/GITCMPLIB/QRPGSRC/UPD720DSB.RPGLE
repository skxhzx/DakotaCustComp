      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  UPD720DSB   Create PALLETEXA recs for PALLETRECS
     *  02 June 2018
     *  Dave Sommerville
     *
     *  Revisions
     *
720  *    06/02/18  DAS  7.20a
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fpallet    if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d pltType         s              1
     d rtnCode         s             10
     d rtnMsg          s             60

     *----------------------------------------------------------------
     *  Called Program Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.expallet

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       dow 1=1;

         read pallet;
         if %eof(pallet);
           leave;
         endif;

         if %subst(plcode: 1: 1) = '*';
           platype = 'W';
         else;
           platype = 'B';
         endif;

         expallet ('*ADD': rtnCode: rtnMsg: plcode: platype);

       enddo;

       expallet ('*CLOSE');

       return;
      /end-free

