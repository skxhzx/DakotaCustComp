      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTRTECLS    Test RTECLSTRN
     *  16 April 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D dpCombo         s             20
     D whse            s              3p 0
     D trn             s              7p 0
     D chrCmd          s              8
     D chrOutStr       s            512
     D chrSessId       s             40
     D chrUser         s             10
     D chrRtid         s              5

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D RteClsTrn       pr                  extpgm('RTECLSTRN')
     D  pCmd                          8
     D  pSessId                      40
     D  pUser                        10
     D  pCombo                       20
     D  pWhse                         3p 0
     D  pRtid                         5
     D  pTrn                          7p 0
     D  pOutStr                     512

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;

         chrOutStr = '';
         chrSessId  = 'FC3110B7D71BE1C174A5027F10A0739A';
         chrUser = 'dave';
         dpCombo = 'TSTRTECLS';
         chrRtid = '00019';
         whse = 900;
         trn = 2043;
         //chrCmd = '*FLAGS';
         chrCmd = '*CLOSE';

         RteClsTrn(chrCmd:
                   chrSessId:
                   chrUser:
                   dpCombo:
                   whse:
                   chrRtid:
                   trn:
                   chrOutStr);

         if %error();
           whse=whse;
         endif;

         return;
      /end-free
