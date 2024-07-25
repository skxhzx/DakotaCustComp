      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M20500    Maintain Remote Writer User Access
     *  17 April 2016
     *  Kenneth Elder
     *  Revisions:
     *
     *
700 A*    04/17/16  KDE  7.00
     *      - Created.
700aA*    04/23/16  KDE  7.00a
     *      - Allow for multiple outq selections per user.  This
     *        will allow one user to see outqs that begin with
     *        D* and H* and specific queue PRT140 instead of just D*
710 A*    09/20/17  KDE  7.10
     *      - Correct DUP entry issue
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fglousrwtr uf a e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pWtrUsr     Remote Writer User to Maintain Writers
     *      pOutq       Outq(s) to be maintained
     *      pNewOq      Old Outq usd when changing Outq since part key
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     D m20500          pr                  extpgm('M20500')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pAction                      10
     D  pWtrUsr                      10
     D  pOutq                        10
     D  pNewOq                       10

     D m20500          pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pAction                      10
     D  pWtrUsr                      10
     D  pOutq                        10
     D  pNewOq                       10

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D usrcnt          s              5  0
     D pos             s              5  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;
710aA    pErrMsg=*blanks;

         pAction = %xlate(xlower: xupper: pAction);
         pWtrUsr = %xlate(xlower: xupper: pWtrUsr);
         pOutq = %xlate(xlower: xupper: pOutq);
         pNewOq = %xlate(xlower: xupper: pNewOq);

         exsr EdtFields;
710aA    if pErrMsg=*blanks;
            exsr updRecord;
710aA    endif;

         return;
      /end-free

     *----------------------------------------------------------------
     *  UpdRecord    Process update
     *----------------------------------------------------------------

      /free
       begsr updRecord;

         select;

           when pAction = 'A';
             exsr DeleteRec;
             exsr AddRec;

           when pAction = 'U';
             exsr ChangeRec;

           when pAction = 'D';
             exsr DeleteRec;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec      Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         uwuser = pWtrUsr;
         uwoutqs = pOutq;
         uwoldoq = pOutq;
         write(e) uwrec;
         if %error;
           if pAction = 'A';
             exsr ChangeRec;
           else;
             pErrMsg = 'Error updating GLOUSRWTR for '
                     + pWtrUsr;
           endif;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChangeRec   Change record
     *----------------------------------------------------------------

      /free
       begsr ChangeRec;

         // when outq is changed look for hidden existing name
         // to delete since the change will result in an addition
         // The reason being is the outq is part of the key
         Exsr DeleteRec;

         pOutq = pNewOq;
         chain (pWtrUsr:pOutq) glousrwtr;

         if not %found(glousrwtr);
           if pAction <> 'A';
             exsr AddRec;
           else;
             pErrMsg = 'Error updating GLOUSRWTR for '
                     + pWtrUsr;
           endif;
           leavesr;
         else;
           // Update Record
           uwoutqs = pOutq;
           uwoldoq = pOutq;
           update uwrec;
         endif;


       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRec   Delete record
     *----------------------------------------------------------------

      /free
       begsr DeleteRec;

         chain (pWtrUsr:pOutq) glousrwtr;

         if not %found(glousrwtr);
           leavesr;
         endif;

         delete(e) uwrec;
         if %error and pAction<>'A';
           pErrMsg = 'Error deleting GLOUSRWTR for '
                   + pWtrUsr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  EdtFields   Edit Fields
     *----------------------------------------------------------------

      /free
       begsr EdtFields;

          usrcnt = *zeros;
          exec sql
               select count(*) into :usrcnt
                  from glousr
                  where guuser = :pWtrUsr;
          if usrcnt = *zeros;
             pErrmsg = 'Invalid User.  Please re-enter !';
          endif;

          // if outq is *ALL accept and move on
          if pOutq = '*ALL';
             leavesr;
          endif;

          if pOutq = *blanks;
             pErrMsg = 'Either full outq or partial with * must be entered';
             leavesr;
          endif;

          pos = 0;
          pos = %scan ('*' : pOutq);
          if pos <> 0;

             if %subst(pOutq:pos+1:1) <> ' ';
                // if position after * is not blank then error
                pErrMsg = '* can only be at end of outq';
                leavesr;
             endif;

             pos = %scan ('*' : pOutq: pos+1);
             if pos <> 0;
                pErrmsg = 'Only one * is allowed as last position of outq';
                leavesr;
             endif;

          endif;

       endsr;
