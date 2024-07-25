      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2020 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETZPCKUP    Get RF Zone Pickup flag
     *  28 May 2020
     *  Dave Sommerville
     *
740 A*    05/28/20  DAS  7.40a
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------
     Fworklblw  if   e           k disk
     Foptionz   if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D opdata          s            117

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *
     * Fields
     *
740aA*    OZRFZP  -  RF Zone Pickup
     *
     *----------------------------------------------------------------
     * Data structure
     *
     D opzdta          ds                  inz
740aAD  ozrfzp                92     92
     D  opend1               117    117

     *----------------------------------------------------------------
     * Parameters
     *   Parameters:
     *     pWhse  - Warehouse
     *     PLbl#  - Label #
     *
     *   Return Value:
     *     pOZRFZP    -  OZRFZP value
     *
     *----------------------------------------------------------------

     D GETZPCKUP       pr                  extpgm('GETZPCKUP')
     D  pWhse                         3s 0 CONST
     D  pLbl#                         7p 0 CONST
     D  pOZRFZP                       1

     D GETZPCKUP       pi
     D  pWhse                         3s 0 CONST
     D  pLbl#                         7p 0 CONST
     D  pOZRFZP                       1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

       pOZRFZP = '';

       chain (pWhse: pLbl#) worklblw;
       if not %found(worklblw);
         return;
       endif;

       chain ('*PICK': pwhse: lwtruk: lwszon) optionz;
       if %found(optionz);
         pOZRFZP = ozrfzp;
       endif;

       return;

      /end-free

