      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO)
     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  DOCK100   Add missing POs to POSTATUS if there is a POHDR.
     *  Todd Chopp
     *  8 October 2021
     *
     *  Revisions
     *                                                                  *
770aA*    03/08/23  DAS  7.70a                                          *
     *      - Moved H specs to top of program                           *
     *      - Added comments in definitions                             *
     *
770bA*    05/15/23  CAU  7.70b                                          *
     *      - Added changes to Ignore Super PO's.                       *
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fPOHDR     if   e           k disk
770bDf***POSTATUS  if   e           k disk
770bMfPOSTATUS  if   e           k disk    prefix(ss_)
770bAfPOSPO     if   e           k disk    prefix(s_)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D p_phwhse        s              3  0
     D p_phpo          s              9
     D p_phstat        s              1
     D TZ              s               Z   inz
     D TZ2             s               Z   inz

     *----------------------------------------------------------------
     * Program prototype
     *----------------------------------------------------------------

     d DOCK100         pr                  extpgm('DOCK100')
     d p_poswhs                       3  0
     d p_pospo                        9

     d DOCK100         pi
     d i_poswhs                       3  0
     d i_pospo                        9

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

        // Process the selected PO if one was passed into the program.
        // If the po parametr is blank, process all of the purchase orders
        // for the selected warehouse.
        if i_pospo <> *blank;
          exsr ProcessOnePO;
        else;
          exsr ProcessAllPO;
        endif;

        *Inlr = *On;

      *------------------------------------------------------------------*
      * Process one PO if the input PO number is not blank.              *
      *------------------------------------------------------------------*
        begsr ProcessOnePO;

          chain (i_poswhs:i_pospo)POHDR;
          if %found(POHDR);
            chain (phwhse:phpo)POSTATUS;
            if not %found(POSTATUS);
770bA         chain (phwhse:phpo)POSPO;
770bA         if not %found(POSPO);
                exsr InsertPOSTATUS;
770bA         endif;
            endif;
          endif;

        endsr;
      *------------------------------------------------------------------*
      * Process all POHDR records if the input PO Number is blank.       *
      *------------------------------------------------------------------*
        begsr ProcessAllPO;

          setll (i_poswhs)POHDR;
          reade (i_poswhs)POHDR;
          if %eof(POHDR);
            leavesr;
          endif;

          dow not %eof(POHDR);
            chain (phwhse:phpo)POSTATUS;
            if not %found(POSTATUS);
770bA         chain (phwhse:phpo)POSPO;
770bA         if not %found(POSPO);
                exsr InsertPOSTATUS;
770bA         endif;
            endif;
            reade (i_poswhs)POHDR;
          enddo;

        endsr;
      *------------------------------------------------------------------*
      * Insert the missing PO in POSTATUS                                *
      *------------------------------------------------------------------*
        begSr InsertPOSTATUS;

         chain (phwhse:phpo) POSTATUS;
         If not %found(POSTATUS);
           TZ = %timestamp();
           exec sql insert into postatus
             values (:phwhse,:phpo,:phstat,
                     :TZ,:TZ2);
          endif;

        endsr;
