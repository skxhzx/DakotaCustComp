417cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TESTRSET3   Test result sets 3
     *  02 February 2011
     *  Dave Sommerville
     *----------------------------------------------------------------

     D sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     D  recId          s             11p 0
     D  recIdA         s             11
     D  whse3S         s              3s 0

     D GetRecId        pr                  extpgm('GETRECID')
     D  pWhse                         3s 0 const
     D  pFile                        10    const
     D  pRecId                       11p 0

      /free

         *inlr = *on;

         sbwhse = 900;
         sbbatid = '12345';
         sbtype  = 'DUMMY';
         sbstatus = 'R';

         exec sql insert into stgbatch values(:sbrec);

           whse3S = 900;

           monitor;
             GetRecId(whse3S: 'DKTEXPORT': recId);
           on-error;
             return;
           endmon;

           recIdA = %trim(%char(recId));

         exec sql
           update stgbatch
           set sbexpid = :recIdA, sbstatus='P'
           where sbbatid = '12345';

         exec sql
           declare resultset1 cursor for
           select *
             from stgbatch
             where sbexpid = :recIdA;

         exec sql
           declare resultset2 cursor for
           select ititem
             from piritem
             fetch first 5 rows only;

         exec sql open resultset1;
         exec sql open resultset2;

         exec sql
           set result sets with return to client
               cursor resultset1,
               cursor resultset2;

         return;
      /end-free
