417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTGETSINF  Test get session info
     *  20 March 2013
     *  Dave Sommerville
     *----------------------------------------------------------------

     D  pSessId        s             40
     D  pos            s              3  0
     D glosess       E ds
      /copy qcopysrc,c#stdsql

      /free
        *inlr = *on;

        pSessId = '3420897B7C1A31AF58F39EC51EE6D2E9';
650aA   pos =  %check('0123456789': pSessId);

        exec sql select * into :glosess
                 from glosess
                 where gssessid = char(:pSessId);
             //  where gssessid = cast(:pSessId as char);
             //  where gssessid = ''':pSessId''';
             //  where gssessid = '3420897B7C1A31AF58F39EC51EE6D2E9';

         If sqlstt = sqlSuccess;
         endif;
