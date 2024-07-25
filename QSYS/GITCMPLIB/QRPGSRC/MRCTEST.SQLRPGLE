      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  MRCTEST   MRC External program test
     *  12 August 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    08/12/11  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D logmrctst     E ds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------
      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pErrMsg      Error message for *FLDVALID
     *      pExtLoc      External location
     *      pSessId      Session Id
     *      pParmFld     Parameter field
     *      pAppFld      Application field
     *
     *    Returned Parameters
     *      pMessage     Return message
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pErrMsg          99
     C                   parm                    pExtLoc          10
     C                   parm                    pSessId          40
     C                   parm                    pParmFld         10
     C                   parm                    pAppFld          10
     C                   parm                    pMessage         60

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // Set return fields

        pMessage = 'Processed External Location ' + pExtLoc;

        // Write log record

        clear logmrctst;

        lmtextloc = pExtLoc;
        lmtsessid = pSessId;
        lmtparmfld = pParmFld;
        lmtappfld = pAppFld;

        exec sql insert into logmrctst
               values(:pExtLoc,
                      :pSessId,
                      :pParmFld,
                      :pAppFld,
                      current timestamp,
                      current timestamp - current timezone) ;

        return;
      /end-free
