      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTRTEDOOR   Test RTEDOOR
     *  09 March 2015
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pSessId        s             40
     D  pUser          s             10
     D  pPgm           s             20
     D  pWhse          s              3  0
     D  pRtid          s              5
     D  pDoor          s              3  0
     D  pDept          s              5

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D RteDoor         pr                  extpgm('RTEDOOR')
     D  pMessage                     99
     D  pSessId                      40
     D  pUser                        10
     D  pCombo                       20
     D  pWhse                         3p 0
     D  pRtid                         5
     D  pDoor                         3p 0
     D  pWhdp                         5

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         pSessId  = '1234';
         pUser = 'dave';
         pPgm = 'TSTRTEDOOR';
         pWhse = 505;
         pRtid = '00015';
         pDoor = 8;
         pDept = '4';

         RteDoor(pMessage:
                 pSessId:
                 pUser:
                 pPgm:
                 pWhse:
                 pRtid:
                 pDoor:
                 pDept);

         if %error();
           pwhse=pwhse;
         endif;

         return;
      /end-free
