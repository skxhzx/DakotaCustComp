      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2012 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  RV640RTR01   Add Pallet Stop Flags to DDOPTS
     *  29 August 2012
     *  Rod Roller
     *
     *  Revisions:
     *
640 A*    08/29/12  RTR  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     D*----------------------------------------------------------------
     D*  Working variable(s)
     D*
     D optcode         s             40a
     D optvalue        s            400a
     D x               s              1  0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

      /free

         exsr StopCustNum;
         exsr StopCustName;
         exsr StopPieces;

         *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  Check/Write BFC_STOP_DISPLAY_CUSTOMER_NUMBER
     *----------------------------------------------------------------

      /free
        begsr StopCustNum;

          // Check for BFC_STOP_DISPLAY_CUSTOMER_NUMBER
          optcode = 'BFC_STOP_DISPLAY_CUSTOMER_NUMBER';
          optvalue = 'OFF';
          Exec Sql Select 1 into :x
                     from DDOPTS
                    where DOCODE = :optcode;

          // If not found, write it
          if SQLCOD <> 0;
            // If UCI code is blank, set N and update
            Exec Sql Insert into DDOPTS (DOCODE, DOVALUE)
                          values(:optcode, :optvalue);
          endif;                        // end SQLCOD = 0

        endsr;  // StopCustNum
      /end-free

     *----------------------------------------------------------------
     *  Check/Write BFC_STOP_DISPLAY_CUSTOMER_NAME
     *----------------------------------------------------------------

      /free
        begsr StopCustName;

          // Check for BFC_STOP_DISPLAY_CUSTOMER_NAME
          optcode = 'BFC_STOP_DISPLAY_CUSTOMER_NAME  ';
          optvalue = 'OFF';
          Exec Sql Select 1 into :x
                     from DDOPTS
                    where DOCODE = :optcode;

          // If not found, write it
          if SQLCOD <> 0;
            // If UCI code is blank, set N and update
            Exec Sql Insert into DDOPTS (DOCODE, DOVALUE)
                          values(:optcode, :optvalue);
          endif;                        // end SQLCOD = 0

        endsr;  // StopCustName
      /end-free

     *----------------------------------------------------------------
     *  Check/Write BFC_STOP_DISPLAY_PIECES
     *----------------------------------------------------------------

      /free
        begsr StopPieces;

          // Check for BFC_STOP_DISPLAY_PIECES
          optcode = 'BFC_STOP_DISPLAY_PIECES         ';
          optvalue = 'OFF';
          Exec Sql Select 1 into :x
                     from DDOPTS
                    where DOCODE = :optcode;

          // If not found, write it
          if SQLCOD <> 0;
            // If UCI code is blank, set N and update
            Exec Sql Insert into DDOPTS (DOCODE, DOVALUE)
                          values(:optcode, :optvalue);
          endif;                        // end SQLCOD = 0

        endsr;  // StopPieces
      /end-free
