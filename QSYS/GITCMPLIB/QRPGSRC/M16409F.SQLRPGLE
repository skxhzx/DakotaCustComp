      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*no)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------

      *----------------------------------------------------------
      *
      *  M16409F     Item/Component Filter Process.
      *  07 Feb 2019
      *  Mike Rooker
      *
      *  Revisions:
      *
     *    02/07/19  MR  7.30
     *      - Created.
     *
     *----------------------------------------------------------

     *----------------------------------------------------------
     * File Specs
     *----------------------------------------------------------
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk
     *----------------------------------------------------------
     * Variables
     *----------------------------------------------------------
     d bWhse           S              3
     d bcmd            S              2
     d pRmitem         S             15
     d bRtnMsg         S            100
     d parr3w          S             15    dim(500)
     d parr3c          S            500    dim(100)
     d cntr            s              3s 0

     * Call to BOM Procedures
720aAd pcompwo         pr                  extpgm('PCOMPWO')
720aAd  parm1                         3
720aAd  parm2                         2
720aAd  parm3                        15
720aAd  parm4                        15
720aAd  parm5                       100
720aAd  parm6                        15    dim(500)
720aAd  parm7                       500    dim(100)
     *----------------------------------------------------------
     * Program informas data structure
     *----------------------------------------------------------

     d*copy qcopysrc,c#pgminfds
      /copy qcopysrc,c#stdvar

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
650aA /copy qcopysrc,p.wrtsessl

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pSessId        s             40    varying
     D  pUser          s             10    varying
     D  pPgm           s             20    varying
     D  pObjLoc        s             10    varying
     D  pSubCmd        s              1

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     D bfcoffset       s              3  0 inz(0)
     D dbgflgExists    s               n
     D debug           s               n
     D $preturn        s             10
     D $pmessage       s             60
     d pcomponent      s             15
     d poutstr         s           5000
     d perr            s             99

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse
     *      pComponent   Item Component
     *
     *    Returned Parameters
610aA*      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
650aAc                   parm                    pSessId
650aAc                   parm                    pUser
650aAc                   parm                    pPgm
     c                   parm                    pWhse
610aAc                   parm                    pComponent
     c                   parm                    pOutStr

      /free

          *inlr = *on;
          exsr init;
          exsr getWoInfo;

      /end-free

     *----------------------------------------------------------------
     *  errorCheck  Check screen entry for errors
     *----------------------------------------------------------------

      /free
       begsr errorCheck;

       endsr;

       //---------------------------------------------------------
       // getWoInfo  Get Work Order Production Information
       //---------------------------------------------------------

          begsr getWoInfo;
          bcmd = 'BI';
720aA     bWhse = %char(pWhse);
          parr3w = *blanks;
          parr3c = *blanks;
          bRtnMsg = *blanks;
720aA     pcompwo (bWhse:bcmd:pComponent:pRmItem:bRtnMsg:parr3w:parr3c);
          //
          cntr=0;
          poutStr = '?rls_WOITEM=LS&val_WOITEM='+%trim(pcomponent);
          dow forever = forever;
             cntr = cntr + 1;
             if parr3w(cntr) = *blanks;
                leave;
             endif;
             if parr3w(cntr) = 'X';
                iter;
             endif;
             poutStr = %trim(poutStr)+' '+%trim(parr3w(cntr));
          enddo;

          endsr;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

             pErr = ' ';
             error = *off;

        endsr;
      /end-free

     *----------------------------------------------------------
     *  wrtDebugParms  Write out debug parm record
     *----------------------------------------------------------

      /free
       begsr wrtDebugParm;

         bdtype = 'PARMS';

        // bdvalues = '&pWoNo = ' + pWo#
        //          + '&pUser=' + %trimr(pUser)
        //          + '&pNeed=' + %trimr(%char(pNeed))
        //          + '&pMake =' + %trimr(%char(pMake))
        //          + '&pOut=' + %trimr(pOutStr);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  *PSSR  Unexpected error handler
      *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free
