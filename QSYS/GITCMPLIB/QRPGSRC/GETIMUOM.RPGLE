     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETIMUOM    Get Item Maintenance option for UOM for weight
     *  28 March 2016
     *  Lynn McMahon
     *
     *  Revisions
     *
700aA*    03/28/16  LMC  7.00
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *ITEMMNT -  Item Maintenance options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPWUM   -  Unit of measure for weight.
     *
     * Data structure
     *
     D opdata          ds
     D  opwum                 58     72
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $WHSE    -  Warehouse
     *
     *  Output parameters
     *
     *     $KILOLBS -  K OR P
     *     $IMUOM
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3 0
     C                   parm                    $kilolbs          1
     C                   parm                    $IMUom            3

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Get Item Maintenance options

      /free
        opcode = '*ITEMMNT';
        chain ($whse: opcode) options;
        if %found(options);
          select;
            when opwum = 'KGS'
             or  opwum = 'kgs'
             or  opwum = 'Kgs';
              $KiloLbs = 'K';
              $IMUom  = opwum;
            other;
              $KiloLbs = 'P';
              $IMUom  = 'Lbs';
          endsl;
        else;
          $KiloLbs = 'P';
          $IMuom  = 'Lbs';
        endif;
      /end-free


     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return
