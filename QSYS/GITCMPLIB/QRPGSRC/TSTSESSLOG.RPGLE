      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTSESSLOG   Test WRTSESSLOG
     *  04 February 2014
     *  Dave Sommerville
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     D chrSessId       s             40
     D chrUser         s             10
     D chrPgmId        s             20
     D text            s            100

      /copy qcopysrc,p.wrtsessl

      /free

        chrSessId = 'ABCD1234';
        chrUser   = 'GUIUSER';
        chrPgmId  = 'GUIPGM.M00000';
        Text = 'Test 1';

        wrtsesslog(chrSessId: #pgm: chrPgmId: chrUser: Text);

        wrtsesslog('123456': #pgm: 'pgm': 'usr': 'Test 2');

        *inlr = *on;
        return;

      /end-free
