      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *  TSTCHR     Test of %chr function
     *----------------------------------------------------------------

     D temp2a          s              2
     D varLen          s              2  0
     D varString       s            100
     D v1              s             30
     D value           s              7  0

      /free
           v1 = 'Hello';
           varLen = %len(%trimr(v1));
           varString = %trimr(varString)
                     + %editc(varLen:'X')
                     + v1;

           value = 0;
           varString = %editw(value:'     0 ');

           value = 123;
           varString = %editw(value:'     0 ');

           value = 123456;
           varString = %editw(value:'     0 ');

           *inlr = *on;
      /end-free
