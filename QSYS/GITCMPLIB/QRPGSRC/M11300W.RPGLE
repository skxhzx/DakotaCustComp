      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  M11300W  Override label cw warning
     *  24 April 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650  *    04/24/14  DAS  6.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.dricop

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ORDC
     D saveVer#        s                   like($ocver#)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pWhse          s              3p 0
     D  pLbl           s              7p 0
     D  pType          s             10
     D  pUser          s             10
     D  pOutStr        s            512    varying

     *----------------------------------------------------------------
     *  Standard Variables
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D cCmd            s             10    inz(' ')
     D chrOutStr       s            512

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pWhse        Warehouse
     *      pLbl         Label number
     *      pUser        User code (upper case)
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pWhse
     c                   parm                    pLbl
     c                   parm                    pType
     c                   parm                    pUser
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        // Call DRIORDC to override label flag

         savever# = $ocver#;
         clear $ordc;
         $ocver# = savever#;

         $ocwhseu = *on;
         $ocwhse = pWhse;
         $oclbl#u = *on;
         $oclbl# = pLbl;
         $dridata = $ordc;

         $dricommand = '*ORDC';
         select;
           when pType = 'count';
             $drisubcmd = '%OVRLBLCNT';
           when pType = 'variance';
             $drisubcmd = '%OVRLBLVAR';
           Other;
             $drisubcmd = pType;
         endsl;
         $drisys2upd = 'D';
         $driprogram = #pgm;

         driCop($dricommand: $drisubcmd: $drisys2upd: $driprogram:
                $drireturn: $drimessage: $dridata);

         $ordc = $dridata;

         pOutStr = '{'
                 +  '"rtn":"' + %trimr($drireturn) + '",'
                 +  '"msg":"' + %trimr($drimessage) + '"'
                 +  '}';

        return;
      /end-free
