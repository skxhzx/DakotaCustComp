      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETENV      Get environment (Prod/Test)
     *  30 August 2012
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
640aA*    08/30/12  DAS  6.40
     *      - Created
     *
710 A*    04/20/17  MLB  7.10
     *      - Enh: Revised pgm to use %scan for 'T' starting at pos 4
     *        due to change in library naming convention. On the Cloud
     *        sites and new clients, naming is iiiPIRF or iiiPIRTSTF
     *        where iii=Client Initials. Some clients will still con-
     *        tinue to use PIRF or PIRTESTF and this mod will work for
     *        existing library naming.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Factivity  if   e           k disk    infds(file1ds)

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54
     D  ft1library            93    102
710 AD pos             s              3s 0 inz(0)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      none
     *
     *    Returned Parameters
     *      pEnv         Environment (P=Production, T=Test)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pEnv              1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        // We are assuming that the files in the test environment will be
        // in a library that has 'T' as the 4th character, like PIRTESTF.

710 D   // if %subst(ft1library: 4: 1) = 'T';
710 A   pos = 0;
710 A   pos = %scan('T' : ft1library: 4);
710 A   if pos >= 4;
          pEnv = 'T';
        else;
          pEnv = 'P';
        endif;

        return;

      /end-free
