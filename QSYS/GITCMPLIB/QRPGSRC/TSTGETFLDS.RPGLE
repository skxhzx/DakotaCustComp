      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)

     *----------------------------------------------------------------
     *  TSTGETFLDS   Test GETFLDS
     *  30 December 2017
     *  Dave Sommerville
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  GETFLDS parameters
     *----------------------------------------------------------------

     d gfString        s          65535A   varying
     d gfDelimiter     s              1A
     d gfStartFld      s              3  0
     d gfRtnCode       s             10
     d gfFldsReturned  s              3  0
     d gfFld1          s          65535A   varying
     d gfFld2          s          65535A   varying
     d gfFld3          s          65535A   varying
     d gfFld4          s          65535A   varying
     d gfFld5          s          65535A   varying
     d gfFld6          s          65535A   varying
     d gfFld7          s          65535A   varying
     d gfFld8          s          65535A   varying
     d gfFld9          s          65535A   varying
     d gfFld10         s          65535A   varying
     d gfFld11         s          65535A   varying
     d gfFld12         s          65535A   varying
     d gfFld13         s          65535A   varying
     d gfFld14         s          65535A   varying
     d gfFld15         s          65535A   varying
     d gfFld16         s          65535A   varying
     d gfFld17         s          65535A   varying
     d gfFld18         s          65535A   varying
     d gfFld19         s          65535A   varying
     d gfFld20         s          65535A   varying

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CallGetFlds     pr

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

      /copy qcopysrc,p.getflds

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
       *inlr = *on;

       gfDelimiter = ',';

       gfString = '1,2,3,4,5';
       gfStartFld = 1;
       CallGetFlds();

       gfString = '1,2,3,4,5,6,7,8,9,10,'
                + '11,12,13,14,15,16,17,18,19,20,'
                + '21,22,23,24,25,26,27,28,29,30';

       gfStartFld = 1;
       CallGetFlds();

       gfStartFld = 21;
       CallGetFlds();

       return;

      /end-free

     *----------------------------------------------------------------
     C*  CallGetFlds  Call GETFLDS
     *----------------------------------------------------------------

     p CallGetFlds     b
     d CallGetFlds     pi

      /free

       GetFlds(gfString: gfDelimiter: gfStartFld: gfRtnCode: gfFldsReturned:
               gfFld1: gfFld2: gfFld3: gfFld4: gfFld5:
               gfFld6: gfFld7: gfFld8: gfFld9: gfFld10:
               gfFld11: gfFld12: gfFld13: gfFld14: gfFld15:
               gfFld16: gfFld17: gfFld18: gfFld19: gfFld20);

      /end-free
     p                 e


