      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2004 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETTS    Get current datestamp for legacy programs
     *  09 July 2004
     *  Dave Sommerville
     *
     *  Revisions
     *
417 A*    07/09/04  DAS  4.17
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Notes
     *
     *  This program was created to allow legacy RPG programs to update
     *  a timestamp file field (type 'z'). The legacy program just calls
     *  this program to get the current time in datestamp format in an
     *  alpha field. The program would then MOVEL this into the datestamp
     *  field in the file.
     *
     *  IMPORTANT!! The legacy program must be compiled with parameter
     *    CVTOPT(*DATETIME) in order to work with the datestamp field.
     *
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D currdatestamp   s               z

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    none
     *
     *   Output
     *
     *    $stamp  - Alpha datestamp
     *
     *----------------------------------------------------------------

     C     *entry        plist
417cAC                   parm                    $stamp           26

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C                   time                    currdatestamp
     C                   eval      $stamp = %char(currdatestamp)

     C                   return
