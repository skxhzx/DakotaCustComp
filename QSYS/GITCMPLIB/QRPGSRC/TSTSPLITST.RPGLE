      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  TSTSPLITST   Test SPLITSTR
     *  30 January 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     D  strToSplit     s           1000    varying
     D  delimiter      s              3    varying
     D  strArray       s            100    dim(50)

     D splitstr        pr                  extpgm('SPLITSTR')
     D  strToSplit                 1000    const varying
     D  delimiter                     3    const varying
     D  strArray                    100    dim(50)

      /free
         *inlr = *on;

         SplitStr('blue+++green+++yellow+++fuchsia': '+++': strArray);

         strToSplit = 'Please.split.this.string.into.pieces';
         SplitStr(strToSplit: '.': strArray);

         strToSplit = '12345678901234567890123456789012345678901234567890'
                    + '12345678901234567890123456789012345678901234567890'
                    + '12345+'
                    + 'Parm2';
         SplitStr(strToSplit: '+': strArray);

         strToSplit = 'P1+'
                    + '+'
                    + 'P3+'
                    + 'P4';
         SplitStr(strToSplit: '+': strArray);

         strToSplit = *ALL'1234567890123456789+';
         SplitStr(strToSplit: '+': strArray);

         return;
      /end-free
