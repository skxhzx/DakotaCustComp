      /copy qcopysrc,hspecs
501jAH dftactgrp(*NO)
501jAH actgrp(*NEW)

     *----------------------------------------------------------------
     *
     *  GETJOBINFO   Get job information
     *  30 September 2008
     *  Dave Sommerville
     *
     *  Revisions
     *
720aA*   01/09/19  DAS  7.20a
     *     - Replaced BNDDIR PIRSQLPGM with BFCBND.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

720aDH*bnddir('PIRSQLPGM')
720aMH bnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfclibl

     *----------------------------------------------------------------
     * API Error Data Structure
     *----------------------------------------------------------------

     D APIErrorDS      DS
     D  BytesProvided                10I 0 Inz( %Size( APIErrorDS ) )
     D  BytesAvail                   10I 0 Inz( *Zero )
     D  MsgID                         7    Inz( *Blanks )
     D  Reserved                      1    Inz( X'00' )
     D  MsgDta                      256    Inz( *Blanks )

     D NoAPIError      C                   Const( *Zero )

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D  i              s              5  0
     D  liblAry        s             11    DIM(250)
     D  llCount        s              5I 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pCount         s              3  0
     D  pJob           s             10
     D  pJobNbr        s              6
     D  pUser          s             10
     D  pCurrUser      s             10
     D  pLiblCount     s              3  0
     D  pLibl          s            275

     *----------------------------------------------------------------
     * Parameters
     *
     *   Incoming:
     *     pName    - List name
     *     pAction  - *CREATE, *CHANGE
     *
     *   Return Value:
     *     none
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCount
     C                   parm                    pJob
     C                   parm                    pJobNbr
     C                   parm                    pUser
     C                   parm                    pCurrUser
     C                   parm                    pLiblCount
     C                   parm                    pLibl

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        //*inlr = *on;

          pCount += 2;

          pJob = #job;
          pJobNbr = #jobnbr;
          pUser   = #user;
          pCurrUser = #curruser;
          exsr getLiblcsv;

          return;


       //---------------------------------------------------------------
       //  getLiblcsv   Get first 25 libraries of user library list
       //               separated by commas.
       //---------------------------------------------------------------

       begsr getLiblCSV;

         liblAry = getLibL(llUsrLibl: llCount);

         pLiblCount = llCount;
         pLibl = ' ';

         for i = 1 to 25;

           if liblAry(i) = ' ';
             leave;
           endif;

           select;
             when i = 1;
               pLibl = liblAry(i);
             other;
               pLibl = %trimr(pLibl) + ',' + liblAry(i);
           endsl;

         endfor;

       endsr;

      /end-free
